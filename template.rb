# encoding: utf-8

require "fileutils"
require "shellwords"
require "pp"

RAILS_REQUIREMENT = "~> 7.0.1".freeze

##
# This single template file will be downloaded and run by the `rails new`
# command so all code it needs must be inlined we cannot load other files from
# this repo.
#
class Config
  DEFAULT_CONFIG_FILE_PATH = "./ackama_rails_template.config.yml".freeze

  def initialize
    config_file_path = File.absolute_path(ENV.fetch("CONFIG_PATH", DEFAULT_CONFIG_FILE_PATH))
    @yaml_config = YAML.load(File.read(config_file_path))
  end

  def staging_hostname
    @yaml_config.fetch("staging_hostname")
  end

  def production_hostname
    @yaml_config.fetch("production_hostname")
  end

  def git_repo_url
    @yaml_config.fetch("git_repo_url")
  end

  def apply_variant_react?
    @yaml_config.fetch("apply_variant_react")
  end

  def apply_variant_devise?
    @yaml_config.fetch("apply_variant_devise")
  end

  def apply_variant_sidekiq?
    @yaml_config.fetch("apply_variant_sidekiq")
  end

  def apply_variant_typescript?
    @yaml_config.fetch("apply_variant_typescript")
  end

  def apply_variant_bootstrap?
    @yaml_config.fetch("apply_variant_bootstrap")
  end
end

# Allow access to our configuration as a global
$config = Config.new

def apply_template!
  assert_minimum_rails_version
  assert_valid_options
  assert_postgresql
  add_template_repository_to_source_path

  template "Gemfile.tt", force: true

  template "README.md.tt", force: true
  remove_file "README.rdoc"

  template "example.env.tt", "example.env"
  template "example.env", ".env"
  copy_file "editorconfig", ".editorconfig"
  copy_file "gitignore", ".gitignore", force: true
  copy_file "overcommit.yml", ".overcommit.yml"
  template "ruby-version.tt", ".ruby-version", force: true
  copy_file "simplecov", ".simplecov"

  copy_file "Procfile"
  copy_file ".nvmrc"
  copy_file "Dockerfile"
  copy_file "docker-compose.yml"
  copy_file ".dockerignore"

  apply "Rakefile.rb"
  apply "config.ru.rb"
  apply "app/template.rb"
  apply "bin/template.rb"
  apply "config/template.rb"
  apply "doc/template.rb"
  apply "lib/template.rb"
  apply "public/template.rb"
  apply "spec/template.rb"

  # The block passed to "after_bundle" seems to run after `bundle install`
  # but also after `webpacker:install` and after Rails has initialized the git
  # repo
  after_bundle do
    # Remove the `test/` directory because we always use RSpec which creates
    # its own `spec/` directory
    remove_dir "test"

    run_with_clean_bundler_env "bin/setup"

    apply "variants/frontend-base/template.rb"
    apply "variants/frontend-bootstrap/template.rb" if $config.apply_variant_bootstrap?

    apply "variants/frontend-base/sentry/template.rb"
    apply "variants/frontend-base/js-lint/template.rb"

    if $config.apply_variant_react?
      apply "variants/frontend-react/template.rb"
      apply "variants/frontend-typescript/template.rb" if $config.apply_variant_typescript?
    end

    create_initial_migration

    # Apply variants after setup and initial install, but before commit
    apply "variants/accessibility/template.rb"
    # The accessibility template brings in the lighthouse and
    # lighthouse matcher parts we need to run performance specs
    apply "variants/performance/template.rb"
    apply "variants/bullet/template.rb"
    apply "variants/sidekiq/template.rb" if $config.apply_variant_sidekiq?

    binstubs = %w[
      brakeman bundler bundler-audit rubocop
    ]
    run_with_clean_bundler_env "bundle binstubs #{binstubs.join(' ')} --force"

    template "rubocop.yml.tt", ".rubocop.yml"
    run_rubocop_autocorrections

    apply "variants/frontend-audit-app/template.rb"
    apply "variants/frontend-base/js-lint/fixes.rb"

    unless any_local_git_commits?
      git add: "-A ."
      git commit: "-n -m 'Initial commit' -m 'Project generated with options:\n\n#{options.pretty_inspect}'"
      if git_repo_specified?
        git remote: "add origin #{git_repo_url.shellescape}"
      end
    end

    # we deliberately place this after the initial git commit because it
    # contains a lot of changes and adds its own git commit
    apply "variants/devise/template.rb" if $config.apply_variant_devise?
  end
end

# Adds the given <code>packages</code> as dependencies using <code>yarn add</code>
#
# @param [Array<String>] packages
def yarn_add_dependencies(packages)
  run "yarn add #{packages.join " "}"
end

# Adds the given <code>packages</code> as devDependencies using <code>yarn add --dev</code>
#
# @param [Array<String>] packages
def yarn_add_dev_dependencies(packages)
  run "yarn add --dev #{packages.join " "}"
end

# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require "tmpdir"
    source_paths.unshift(tempdir = Dir.mktmpdir("rails-template-"))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      "--quiet",
      "https://github.com/rabid/rails-template.git",
      tempdir
    ].map(&:shellescape).join(" ")

    if (branch = __FILE__[%r{rails-template/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def assert_minimum_rails_version
  requirement = Gem::Requirement.new(RAILS_REQUIREMENT)
  rails_version = Gem::Version.new(Rails::VERSION::STRING)
  return if requirement.satisfied_by?(rails_version)

  puts "ERROR: This template requires Rails #{RAILS_REQUIREMENT}. You are using #{rails_version}"
  exit 1
end

# Bail out if user has passed in contradictory generator options.
def assert_valid_options
  valid_options = {
    skip_gemfile: false,
    skip_bundle: false,
    skip_git: false,
    skip_test_unit: true,
    skip_active_storage: false,
    edge: false
  }
  valid_options.each do |key, expected|
    next unless options.key?(key)
    actual = options[key]
    unless actual == expected
      fail Rails::Generators::Error, "Unsupported option: #{key}=#{actual}"
    end
  end
end

def assert_postgresql
  return if IO.read("Gemfile") =~ /^\s*gem ['"]pg['"]/
  fail Rails::Generators::Error,
       "This template requires PostgreSQL, "\
       "but the pg gem isn't present in your Gemfile."
end

def any_local_git_commits?
  system("git log > /dev/null 2>&1")
end

def gemfile_requirement(name)
  @original_gemfile ||= IO.read("Gemfile")
  req = @original_gemfile[/gem\s+['"]#{name}['"]\s*(, +['"][><~= \t\d\.\w'"]*)?.*$/, 1]
  req && req.gsub("'", %(")).strip.sub(/^,\s*"/, ', "')
end

def git_repo_specified?
  $config.git_repo_url != "skip" && !$config.git_repo_url.strip.empty?
end

def preexisting_git_repo?
  @preexisting_git_repo ||= (File.exist?(".git") || :nope)
  @preexisting_git_repo == true
end

def run_with_clean_bundler_env(cmd)
  success = if defined?(Bundler)
              Bundler.with_clean_env { run(cmd) }
            else
              run(cmd)
            end
  unless success
    puts "Command failed, exiting: #{cmd}"
    exit(1)
  end
end

def run_rubocop_autocorrections
  run_with_clean_bundler_env "bin/rubocop -a --fail-level A > /dev/null || true"
end

def create_initial_migration
  return if Dir["db/migrate/**/*.rb"].any?
  run_with_clean_bundler_env "bin/rails generate migration initial_migration"
  run_with_clean_bundler_env "bin/rake db:migrate"
end

apply_template!

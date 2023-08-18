require "fileutils"
require "shellwords"
require "pp"

##
# This single template file will be downloaded and run by the `rails new`
# command so all code it needs must be inlined we cannot load other files from
# this repo.
#
class Config
  DEFAULT_CONFIG_PATH = "../ackama_rails_template.config.yml".freeze
  DEFAULT_TARGET_VERSIONS_PATH = "../target_versions.yml".freeze

  attr_reader :acceptable_rails_versions_specifier

  def initialize
    config_file_path = File.absolute_path(ENV.fetch("CONFIG_PATH", DEFAULT_CONFIG_PATH))
    @yaml_config = YAML.safe_load_file(config_file_path)
    @acceptable_rails_versions_specifier = load_acceptable_rails_versions_specifier
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

  def use_typescript?
    @yaml_config.fetch("use_typescript")
  end

  def apply_variant_github_actions_ci?
    @yaml_config.fetch("apply_variant_github_actions_ci")
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

  def apply_variant_bootstrap?
    @yaml_config.fetch("apply_variant_bootstrap")
  end

  def apply_variant_deploy_with_capistrano?
    @yaml_config.fetch("apply_variant_deploy_with_capistrano")
  end

  def apply_variant_deploy_with_ackama_ec2_capistrano?
    @yaml_config.fetch("apply_variant_deploy_with_ackama_ec2_capistrano")
  end

  private

  ##
  # Rails version constraint is stored in a separate file so that it can be used
  # outside of just the template
  #
  def load_acceptable_rails_versions_specifier
    rel_path = ENV.fetch("TARGET_VERSIONS_PATH", DEFAULT_TARGET_VERSIONS_PATH)
    abs_path = Pathname.new(rel_path).realpath
    major_minor = YAML.safe_load(abs_path.read).fetch("target_rails_major_minor")

    # Use the major.minor we got from the YAML file to build a RubyGems
    # compatible specifier that will match all patch versions
    "~> #{major_minor}.0"
  end
end

class Terminal
  def puts_header(msg)
    puts "=" * 80
    puts msg
    puts "=" * 80
  end
end

# Allow access to our configuration as a global
TEMPLATE_CONFIG = Config.new
TERMINAL = Terminal.new

def require_package_json_gem
  require "bundler/inline"

  gemfile(true) do
    source "https://rubygems.org"
    gem "package_json"
  end

  puts "using package_json v#{PackageJson::VERSION}"
end

def apply_template! # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  assert_minimum_rails_version
  assert_valid_options
  assert_postgresql
  add_template_repository_to_source_path

  template "variants/backend-base/Gemfile.tt", "Gemfile", force: true

  template "variants/backend-base/example.env.tt", "example.env"
  copy_file "variants/backend-base/editorconfig", ".editorconfig"
  copy_file "variants/backend-base/gitignore", ".gitignore", force: true
  copy_file "variants/backend-base/overcommit.yml", ".overcommit.yml"
  template "variants/backend-base/ruby-version.tt", ".ruby-version", force: true

  copy_file "variants/backend-base/Procfile", "Procfile"

  copy_file "variants/backend-base/.node-version", ".node-version"

  copy_file "variants/backend-base/Dockerfile", "Dockerfile", force: true
  copy_file "variants/backend-base/docker-compose.yml", "docker-compose.yml"
  copy_file "variants/backend-base/.osv-detector.yml", ".osv-detector.yml"
  copy_file "variants/backend-base/.dockerignore", ".dockerignore", force: true

  apply "variants/backend-base/Rakefile.rb"
  apply "variants/backend-base/config.ru.rb"
  apply "variants/backend-base/app/template.rb"
  apply "variants/backend-base/bin/template.rb"
  apply "variants/backend-base/config/template.rb"
  apply "variants/backend-base/doc/template.rb"
  apply "variants/backend-base/public/template.rb"
  apply "variants/backend-base/spec/template.rb"

  # The block passed to "after_bundle" seems to run after `bundle install`
  # but also after `shakapacker:install` and after Rails has initialized the git
  # repo
  after_bundle do # rubocop:disable Metrics/BlockLength
    require_package_json_gem

    apply "variants/backend-base/lib/template.rb"

    template "variants/backend-base/bin/setup.tt", "bin/setup", force: true

    # Remove the `test/` directory because we always use RSpec which creates
    # its own `spec/` directory
    remove_dir "test"

    run_with_clean_bundler_env "bin/setup"

    apply "variants/frontend-base/template.rb"
    apply "variants/frontend-base/sentry/template.rb"
    apply "variants/frontend-base/js-lint/template.rb"

    apply "variants/frontend-stimulus/template.rb"
    apply "variants/frontend-bootstrap/template.rb" if TEMPLATE_CONFIG.apply_variant_bootstrap?
    apply "variants/frontend-react/template.rb" if TEMPLATE_CONFIG.apply_variant_react?

    if TEMPLATE_CONFIG.use_typescript?
      apply "variants/frontend-base-typescript/template.rb"

      apply "variants/frontend-stimulus-typescript/template.rb"
      apply "variants/frontend-bootstrap-typescript/template.rb" if TEMPLATE_CONFIG.apply_variant_bootstrap?
      apply "variants/frontend-react-typescript/template.rb" if TEMPLATE_CONFIG.apply_variant_react?

      package_json.manager.run("typecheck")
    end

    # apply any js linting fixes after all frontend variants have run
    package_json.manager.run("js-lint-fix")

    create_initial_migration

    # Apply variants after setup and initial install, but before commit
    apply "variants/accessibility/template.rb"
    # The accessibility template brings in the lighthouse and
    # lighthouse matcher parts we need to run performance specs
    apply "variants/performance/template.rb"
    apply "variants/bullet/template.rb"
    apply "variants/pundit/template.rb"
    apply "variants/audit-logging/template.rb"
    apply "variants/sidekiq/template.rb" if TEMPLATE_CONFIG.apply_variant_sidekiq?

    apply "variants/github_actions_ci/template.rb" if TEMPLATE_CONFIG.apply_variant_github_actions_ci?

    if TEMPLATE_CONFIG.apply_variant_deploy_with_ackama_ec2_capistrano?
      apply "variants/deploy_with_ackama_ec2_capistrano/template.rb"
    elsif TEMPLATE_CONFIG.apply_variant_deploy_with_capistrano?
      apply "variants/deploy_with_capistrano/template.rb"
    end

    binstubs = %w[
      brakeman bundler rubocop
    ]
    run_with_clean_bundler_env "bundle binstubs #{binstubs.join(" ")} --force"

    template "variants/backend-base/rubocop.yml.tt", ".rubocop.yml", force: true
    run_rubocop_autocorrections

    cleanup_package_json

    # add the Linux x86-64 platform to the lock file. Gems with native
    # extensions will not install on Linux will not install without this.
    # See https://bundler.io/man/bundle-lock.1.html
    run_with_clean_bundler_env "bundle lock --add-platform x86_64-linux"

    unless any_local_git_commits?
      git add: "-A ."
      git commit: "-n -m 'Initial commit' -m 'Project generated with options:\n\n#{options.pretty_inspect}'"
      git remote: "add origin #{TEMPLATE_CONFIG.git_repo_url.shellescape}" if TEMPLATE_CONFIG.git_repo_url.present?
    end

    # we deliberately place this after the initial git commit because it
    # contains a lot of changes and adds its own git commit
    apply "variants/devise/template.rb" if TEMPLATE_CONFIG.apply_variant_devise?

    # We apply code annotation **after** all the other variants which might
    # generate routes and models
    apply "variants/code-annotation/template.rb"

    # erblint does not like some of Rails auto-generated ERB code e.g.
    # `app/views/layouts/mailer.html.erb` so we auto-correct it.
    copy_file "variants/backend-base/.erb-lint.yml", ".erb-lint.yml"
    run_with_clean_bundler_env "bundle exec erblint --autocorrect ."
    git add: "-A ."
    git commit: "-n -m 'Set up erblint'"

    # Run strong_migrations generator near the end so that it doesn't block
    # other parts of the template from creating migrations.
    run_with_clean_bundler_env "bundle exec rails g strong_migrations:install"
    run_with_clean_bundler_env "bundle exec rubocop -A -c ./.rubocop.yml"
    git add: "-A ."
    git commit: "-n -m 'Set up strong_migrations'"

    # Run the README template at the end because it introspects the app to
    # discover rake tasks etc.
    apply_readme_template

    # Run prettier one last time to ensure that everything is formatted
    apply_prettier_all_over
  end
end

def apply_readme_template
  template "variants/backend-base/README.md.tt", "README.md", force: true

  git commit: "README.md -n -m 'Update README'"
end

def apply_prettier_all_over
  package_json.manager.run("format-fix")

  git commit: ". -m 'Run prettier one last time'"
end

def package_json
  @package_json ||= PackageJson.new
end

# Normalizes the constraints of the given hash of dependencies so that they
# all have an explicit constraint and define a minor & patch version
#
# @param [Hash] deps
#
# @return [Hash]
def normalize_dependency_constraints(deps)
  deps.transform_values do |v|
    v = "^#{v}" unless v.start_with? "^"
    v = "#{v}.0.0" if v.count(".").zero?
    v
  end
end

def build_engines_field(existing)
  node_version = File.read("./.node-version").strip

  existing.merge({
    "node" => "^#{node_version}",
    "yarn" => "^1.0.0"
  })
end

def cleanup_package_json
  package_json.merge! do |pj|
    {
      "name" => File.basename(__dir__),
      "engines" => build_engines_field(pj.fetch("engines", {})),
      "dependencies" => normalize_dependency_constraints(pj.fetch("dependencies", {})),
      "devDependencies" => normalize_dependency_constraints(pj.fetch("devDependencies", {}))
    }
  end

  run "npx -y sort-package-json"

  # ensure the lockfile is up to date with any changes we've made to package.json
  package_json.manager.install
end

# Adds the given <code>packages</code> as dependencies using <code>yarn add</code>
#
# @param [Array<String>] packages
def yarn_add_dependencies(packages)
  puts "adding #{packages.join(" ")} as dependencies"

  package_json.manager.add(packages)
end

# Adds the given <code>packages</code> as devDependencies using <code>yarn add --dev</code>
#
# @param [Array<String>] packages
def yarn_add_dev_dependencies(packages)
  puts "adding #{packages.join(" ")} as dev dependencies"

  package_json.manager.add(packages, type: :dev)
end

# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__.match?(%r{\Ahttps?://})
    require "tmpdir"
    source_paths.unshift(tempdir = Dir.mktmpdir("rails-template-"))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      "--quiet",
      "https://github.com/ackama/rails-template.git",
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
  requirement = Gem::Requirement.new(TEMPLATE_CONFIG.acceptable_rails_versions_specifier)
  rails_version = Gem::Version.new(Rails::VERSION::STRING)
  return if requirement.satisfied_by?(rails_version)

  puts "ERROR: This template requires Rails #{TEMPLATE_CONFIG.acceptable_rails_versions_specifier}. You are using #{rails_version}"
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
    skip_javascript: true,
    skip_docker: true,
    edge: false
  }
  valid_options.each do |key, expected|
    next unless options.key?(key)

    actual = options[key]
    raise Rails::Generators::Error, "Unsupported option: #{key}=#{actual}" unless actual == expected
  end
end

def assert_postgresql
  return if /^\s*gem ['"]pg['"]/.match?(File.read("Gemfile"))

  raise Rails::Generators::Error,
        "This template requires PostgreSQL, " \
        "but the pg gem isn't present in your Gemfile."
end

def any_local_git_commits?
  system("git log > /dev/null 2>&1")
end

def gemfile_requirement(name)
  @original_gemfile ||= File.read("Gemfile")
  req = @original_gemfile[/gem\s+['"]#{name}['"]\s*(, +['"][><~= \t\d.\w'"]*)?.*$/, 1]
  req && req.tr("'", '"').strip.sub(/^,\s*"/, ', "')
end

def preexisting_git_repo?
  @preexisting_git_repo ||= File.exist?(".git") || :nope
  @preexisting_git_repo == true
end

def run_with_clean_bundler_env(cmd)
  success = if defined?(Bundler)
              Bundler.with_unbundled_env { run(cmd) }
            else
              run(cmd)
            end

  return if success

  puts "Command failed, exiting: #{cmd}"
  exit(1)
end

def run_rubocop_autocorrections
  run_with_clean_bundler_env "bin/rubocop -c .rubocop.yml -A --fail-level A > /dev/null || true"
end

def create_initial_migration
  return if Dir["db/migrate/**/*.rb"].any?

  run_with_clean_bundler_env "bin/rails generate migration initial_migration"
  run_with_clean_bundler_env "bin/rake db:migrate"
end

def gsub_file!(path, flag, ...)
  content = File.binread(path)

  gsub_file(path, flag, ...)

  raise StandardError, "the contents of #{path} did not change!" if content == File.binread(path)
end

apply_template!

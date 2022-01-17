# encoding: utf-8

require "fileutils"
require "shellwords"
require "pp"

RAILS_REQUIREMENT = "~> 7.0.1".freeze

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

  run "rails webpacker:install"

  # The block passed to "after_bundle" seems to run after `bundle install`
  # but also after `webpacker:install` and after Rails has initialized the git
  # repo
  after_bundle do
    # Remove the `test/` directory because we always use RSpec which creates
    # its own `spec/` directory
    remove_dir "test"

    run_with_clean_bundler_env "bin/setup"

    apply "variants/frontend-base/template.rb"

    apply "variants/frontend-base/sentry/template.rb"
    apply "variants/frontend-base/js-lint/template.rb"

    if apply_variant?(:react)
      apply "variants/frontend-react/template.rb"
      apply "variants/frontend-typescript/template.rb" if apply_variant?(:typescript)
    end

    create_initial_migration

    # Apply variants after setup and initial install, but before commit
    apply "variants/accessibility/template.rb"
    # The accessibility template brings in the lighthouse and
    # lighthouse matcher parts we need to run performance specs
    apply "variants/performance/template.rb"
    apply "variants/bullet/template.rb"
    apply "variants/sidekiq/template.rb" if apply_variant?(:sidekiq)

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
    apply "variants/devise/template.rb" if apply_variant?(:devise)
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

  prompt = "This template requires Rails #{RAILS_REQUIREMENT}. "\
           "You are using #{rails_version}. Continue anyway?"
  exit 1 if no?(prompt)
end

# Bail out if user has passed in contradictory generator options.
def assert_valid_options
  valid_options = {
    skip_gemfile: false,
    skip_bundle: false,
    skip_git: false,
    skip_test_unit: true,
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
       "but the pg gem isn’t present in your Gemfile."
end

def git_repo_url
  @git_repo_url ||= ask_with_default(
    "What is the git remote URL for this project?",
    :blue,
    "skip",
    "RT_GIT_REPO_URL"
  )
end

def production_hostname
  @production_hostname ||= ask_with_default(
    "Production hostname?",
    :blue,
    "example.com",
    "RT_HOSTNAME_PRODUCTION"
  )
end

def staging_hostname
  @staging_hostname ||= ask_with_default(
    "Staging hostname?",
    :blue,
    "staging.example.com",
    "RT_HOSTNAME_STAGING"
  )
end

def any_local_git_commits?
  system("git log > /dev/null 2>&1")
end


def gemfile_requirement(name)
  @original_gemfile ||= IO.read("Gemfile")
  req = @original_gemfile[/gem\s+['"]#{name}['"]\s*(, +['"][><~= \t\d\.\w'"]*)?.*$/, 1]
  req && req.gsub("'", %(")).strip.sub(/^,\s*"/, ', "')
end

def apply_variant?(name)
  return true if ENV.fetch("VARIANTS", "").split(",").include?(name.to_s)

  ask_with_default(
    "Add #{name} to this application?",
    :blue,
    'N',
    "RT_APPLY_VARIANT_#{name}".gsub("-", "_").upcase
  ).downcase.start_with?("y")
end

def fetch_answer(question, color, env_variable)
  env_answer = ENV.fetch(env_variable, nil).to_s.strip

  return ask(question, color) if env_answer.empty?

  say "#{question}: #{env_answer}", color
  env_answer
end

def ask_with_default(question, color, default, env_variable)
  question = (question.split("?") << " [#{default}]?").join
  answer = fetch_answer(question, color, env_variable)
  answer.to_s.strip.empty? ? default : answer
end

def git_repo_specified?
  git_repo_url != "skip" && !git_repo_url.strip.empty?
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

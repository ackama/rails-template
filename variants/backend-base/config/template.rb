apply "variants/backend-base/config/application.rb"

template "variants/backend-base/config/database.yml.tt", "config/database.yml", force: true

copy_file "variants/backend-base/config/app.yml", "config/app.yml"
remove_file "config/master.key"
remove_file "config/credentials.yml.enc"

remove_file "config/ci"
remove_file "config/bundler-audit.yml"

copy_file "variants/backend-base/config/puma.rb", "config/puma.rb", force: true

copy_file "variants/backend-base/config/initializers/generators.rb", "config/initializers/generators.rb"
copy_file "variants/backend-base/config/initializers/version.rb", "config/initializers/version.rb"
copy_file "variants/backend-base/config/initializers/lograge.rb", "config/initializers/lograge.rb"
copy_file "variants/backend-base/config/initializers/content_security_policy.rb", "config/initializers/content_security_policy.rb", force: true
copy_file "variants/backend-base/config/initializers/health_checks.rb", "config/initializers/health_checks.rb"
copy_file "variants/backend-base/config/initializers/check_env.rb", "config/initializers/check_env.rb"
copy_file "variants/backend-base/config/initializers/sentry.rb", "config/initializers/sentry.rb"

gsub_file! "config/initializers/filter_parameter_logging.rb",
           /:ssn/,
           ":ssn, :session, :cookie, :csrf"

apply "variants/backend-base/config/environments/development.rb"
apply "variants/backend-base/config/environments/production.rb"
apply "variants/backend-base/config/environments/test.rb"
template "variants/backend-base/config/environments/staging.rb.tt", "config/environments/staging.rb"

route <<~HEALTH_CHECK_ROUTES
  mount OkComputer::Engine, at: "/healthchecks"
HEALTH_CHECK_ROUTES

route <<-EO_ROUTES
  ##
  # Workaround a "bug" in lighthouse CLI
  #
  # Lighthouse CLI (versions 5.4 - 5.6 tested) issues a `GET /asset-manifest.json`
  # request during its run - the URL seems to be hard-coded. This file does not
  # exist so, during tests, your test will fail because rails will die with a 404.
  #
  # Lighthouse run from Chrome Dev-tools does not have the same behaviour.
  #
  # This hack works around this. This behaviour might be fixed by the time you
  # read this. You can check by commenting out this block and running the
  # accessibility and performance tests. You are encouraged to remove this hack
  # as soon as it is no longer needed.
  #
  if defined?(Shakapacker) && Rails.env.test?
    # manifest paths depend on your shakapacker config so we inspect it
    manifest_path = Shakapacker::Configuration
      .new(root_path: Rails.root, config_path: Rails.root.join("config/shakapacker.yml"), env: Rails.env)
      .public_manifest_path
      .relative_path_from(Rails.public_path)
      .to_s
    get "/asset-manifest.json", to: redirect(manifest_path)
  end

  root "home#index"
EO_ROUTES

gsub_file! "config/storage.yml", /#   service: S3/ do
  <<~YAML
    #   service: S3
    #   upload:
    #     # TEAM DECISION REQUIRED: The correct caching duration for files
    #     # stored by Active Storage is project dependent so you should discuss
    #     # this with you team if you don't feel able to make the decision solo.
    #     #
    #     # These options are are not well documented in ActiveStorage. They
    #     # are passed directly to the S3 SDK. Details:
    #     # https://github.com/rails/rails/blob/master/activestorage/lib/active_storage/service/s3_service.rb
    #     #
    #     # * private: the browser should cache but intermediate proxies (e.g. CDNs) should not
    #     # * max-age: the number of seconds to cache the file for
    #     #
    #     cache_control: 'private, max-age=<%= 365.days.seconds %>'
  YAML
end

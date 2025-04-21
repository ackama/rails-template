apply "variants/backend-base/config/application.rb"

template "variants/backend-base/config/database.yml.tt", "config/database.yml", force: true

copy_file "variants/backend-base/config/app.yml", "config/app.yml"
remove_file "config/master.key"
remove_file "config/credentials.yml.enc"

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

copy_file "variants/backend-base/config/routes.rb", "config/routes.rb", force: true

if File.exist? "config/storage.yml"
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
end

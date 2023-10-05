##
# * https://sentry.io/for/rails/
# * https://github.com/getsentry/sentry-ruby
#
Sentry.init do |config|
  # Sentry will be enabled if SENTRY_DSN exists. Sentry reporting will work if
  # SENTRY_DSN has a meaningful value.
  config.dsn = ENV.fetch("SENTRY_DSN", nil)

  # Set Sentry environment to be current environment if SENTRY_ENV is not set
  config.environment = ENV.fetch("SENTRY_ENV", Rails.env)

  config.breadcrumbs_logger = %i[active_support_logger http_logger]

  # To activate performance monitoring, use the environment variable
  config.traces_sample_rate = ENV.fetch("SENTRY_TRACES_SAMPLE_RATE", 0)
end

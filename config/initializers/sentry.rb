##
# * https://sentry.io/for/rails/
# * https://github.com/getsentry/sentry-ruby
#
Sentry.configure do |config|
  # Sentry will be enabled if SENTRY_DSN exists. Sentry reporting will work if
  # SENTRY_DSN has a meaningful value.
  config.dsn = ENV["SENTRY_DSN"]

  # Set Sentry environment to be current environment if SENTRY_ENV is not set
  config.current_environment = ENV.fetch("SENTRY_ENV", Rails.env)
end

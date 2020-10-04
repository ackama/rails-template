##
# * https://sentry.io/for/rails/
# * https://github.com/getsentry/raven-ruby
#
Raven.configure do |config|
  # Sentry will be enabled if SENTRY_DSN exists. Sentry reporting will work if
  # SENTRY_DSN has a meaningful value.
  config.dsn = ENV["SENTRY_DSN"]

  # We expect SENTRY_ENV to always be set so fail with an error if it is
  # missing
  config.current_environment = ENV.fetch("SENTRY_ENV", Rails.env)
end

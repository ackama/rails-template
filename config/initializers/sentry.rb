##
# * https://sentry.io/for/rails/
# * https://github.com/getsentry/raven-ruby
#
Raven.configure do |config|
  config.dsn = ENV.fetch("SENTRY_DSN")
end

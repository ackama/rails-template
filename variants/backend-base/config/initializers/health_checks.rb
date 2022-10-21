# okcomputer is used for health checks
# https://github.com/sportngin/okcomputer/

username = ENV.fetch("HEALTHCHECK_HTTP_BASIC_AUTH_USERNAME") { ENV.fetch("HTTP_BASIC_AUTH_USERNAME", nil) }
password = ENV.fetch("HEALTHCHECK_HTTP_BASIC_AUTH_PASSWORD") { ENV.fetch("HTTP_BASIC_AUTH_PASSWORD", nil) }
OkComputer.require_authentication(username, password) if username && password

# Sets the app version from known Heroku environment variables
ENV["SHA"] ||= ENV.fetch("HEROKU_SLUG_COMMIT", nil)

# Checks the deployed commit. This is discovered from:
# A 'REVISION' file that is created during a Capistrano deploy
# ENV['SHA'] that can be set within e.g. a Docker container
# ENV['HEROKU_SLUG_COMMIT'] set above
OkComputer::Registry.register "app_version", OkComputer::AppVersionCheck.new

# Additional checks can be added, e.g.
# OkComputer::Registry.register "mailing", OkComputer::ActionMailerCheck.new
# OkComputer::Registry.register "redis", OkComputer::RedisCheck.new({})
# OkComputer::Registry.register "sidekiq_default", OkComputer::SidekiqLatencyCheck.new(:default)
# OkComputer::Registry.register "sidekiq_mailers", OkComputer::SidekiqLatencyCheck.new(:mailers)
# => More at https://github.com/sportngin/okcomputer/tree/master/lib/ok_computer/built_in_checks/

# Checks can be made optional. This means that the status of the checks is still reported,
# but the overall health check status won't be affected.
# From the checks above, we do not want our overall server health to be determined
# based on mailing, redis or sidekiq, but we do want to report on any of these checks
# that have failed.
# OkComputer.make_optional %w[mailing redis sidekiq_default sidekiq_mailers]

# Run checks in parallel
OkComputer.check_in_parallel = true

# Mount at /healthchecks in config/routes.rb
OkComputer.mount_at = false

# Log when health checks are run
OkComputer.logger = Rails.logger

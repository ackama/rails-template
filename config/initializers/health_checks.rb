# okcomputer is used for health checks

username = ENV["HEALTHCHECK_HTTP_BASIC_AUTH_USERNAME"] || ENV["HTTP_BASIC_AUTH_USERNAME"]
password = ENV["HEALTHCHECK_HTTP_BASIC_AUTH_PASSWORD"] || ENV["HTTP_BASIC_AUTH_PASSWORD"]
OkComputer.require_authentication(username, password) if username && password

# Check that Redis is available
OkComputer::Registry.register "app_version", OkComputer::AppVersionCheck.new

# Additional checks can be added, e.g.
# OkComputer::Registry.register "mailing", OkComputer::ActionMailerCheck.new
# OkComputer::Registry.register "redis", OkComputer::RedisCheck.new({})
# OkComputer::Registry.register "sidekiq_default", OkComputer::SidekiqLatencyCheck.new(:default)
# OkComputer::Registry.register "sidekiq_mailers", OkComputer::SidekiqLatencyCheck.new(:mailers)
# => More at https://github.com/sportngin/okcomputer/tree/master/lib/ok_computer/built_in_checks/

# Run checks in parallel
OkComputer.check_in_parallel = true

# Mount at /healthchecks in config/routes.rb
OkComputer.mount_at = false

# Log when health checks are run
OkComputer.logger = Rails.logger

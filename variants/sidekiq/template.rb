source_paths.unshift(File.dirname(__FILE__))

gem "sidekiq"
gem "sentry-sidekiq"

run "bundle install"
run "bundle binstubs sidekiq --force"

append_to_file "Procfile", "worker:  bundle exec sidekiq -C config/sidekiq.yml"

%w[example.env .env].each do |env_file|
  append_to_file env_file do
    <<~CONTENT
      REDIS_URL=redis://localhost:6379/#{rand(16)}
      SIDEKIQ_WEB_USERNAME=admin
      SIDEKIQ_WEB_PASSWORD=password
    CONTENT
  end
end

template "config/initializers/sidekiq.rb"
copy_file "config/sidekiq.yml"

insert_into_file "config/application.rb", before: /^  end/ do
  <<-RUBY

    # Use sidekiq to process Active Jobs (e.g. ActionMailer's deliver_later)
    config.active_job.queue_adapter = :sidekiq
  RUBY
end

insert_into_file "docker-compose.yml", "
  worker:
    <<: *rails
    command: bundle exec sidekiq
    links:
      - redis
  redis:
    image: redis
", after: /^services:$"/

route <<~ROUTE
  ##
  # If you want the Sidekiq web console in production environments you need to
  # put it behind some authentication first.
  #
  if defined?(Sidekiq::Web) && Rails.env.development?
    mount Sidekiq::Web => "/sidekiq" # Sidekiq monitoring console
    require "sidekiq/web"
  end
ROUTE

original_health_check_chunk = <<~EO_OLD
  # OkComputer::Registry.register "redis", OkComputer::RedisCheck.new({})
  # OkComputer::Registry.register "sidekiq_default", OkComputer::SidekiqLatencyCheck.new(:default)
  # OkComputer::Registry.register "sidekiq_mailers", OkComputer::SidekiqLatencyCheck.new(:mailers)
EO_OLD

new_health_checks_chunk = <<~EO_NEW
  OkComputer::Registry.register "redis", OkComputer::RedisCheck.new({})
  OkComputer::Registry.register "sidekiq_default", OkComputer::SidekiqLatencyCheck.new(:default)
  OkComputer::Registry.register "sidekiq_mailers", OkComputer::SidekiqLatencyCheck.new(:mailers)
EO_NEW

gsub_file("config/initializers/health_checks.rb", original_health_check_chunk, new_health_checks_chunk, force: true)

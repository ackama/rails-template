gsub_file "config/application.rb",
          "# config.time_zone = 'Central Time (US & Canada)'",
          "config.time_zone = 'Wellington'"

insert_into_file "config/application.rb", before: /^  end/ do
  # the empty line at the beginning of this string is required
  <<-'RUBY'

    # Use sidekiq to process Active Jobs (e.g. ActionMailer's deliver_later)
    config.active_job.queue_adapter = :sidekiq
  RUBY
end

insert_into_file "config/application.rb", after: /^require 'rails\/all'/ do
  # the empty line at the beginning of this string is required
  <<-'RUBY'

    require_relative '../app/middleware/http_basic_auth'
  RUBY
end

insert_into_file "config/application.rb", before: /^  end/ do
  # the empty line at the beginning of this string is required
  <<-'RUBY'

    config.middleware.insert_before Rack::Sendfile, HttpBasicAuth
  RUBY
end
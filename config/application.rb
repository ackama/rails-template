gsub_file "config/application.rb",
          "# config.time_zone = 'Central Time (US & Canada)'",
          "config.time_zone = 'Wellington'"

insert_into_file "config/application.rb", after: /^require ['"]rails\/all['"]/ do
  # the empty line at the beginning of this string is required
  <<-'RUBY'

    require_relative '../app/middleware/http_basic_auth'
  RUBY
end

insert_into_file "config/application.rb", before: /^  end/ do
  # the empty line at the beginning of this string is required
  <<-'RUBY'

    config.middleware.insert_before Rack::Sendfile, HttpBasicAuth
    config.action_dispatch.default_headers["Permissions-Policy"] = "interest-cohort=()"
  RUBY
end

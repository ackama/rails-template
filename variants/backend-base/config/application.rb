gsub_file "config/application.rb",
          "# config.time_zone = 'Central Time (US & Canada)'",
          "config.time_zone = 'Wellington'"

insert_into_file "config/application.rb", after: /^require_relative ['"]boot['"]/ do
  # the empty line at the beginning of this string is required
  <<~RUBY

    require_relative "../app/middleware/http_basic_auth"
  RUBY
end

insert_into_file "config/application.rb", before: /^  end/ do
  # the empty line at the beginning of this string is required
  <<-RUBY

    # load config/app.yml into Rails.application.config.app.*
    config.app = config_for(:app)

    config.middleware.insert_before Rack::Sendfile, HttpBasicAuth
    config.action_dispatch.default_headers["Permissions-Policy"] = "interest-cohort=()"

    # ActiveRecord encrypted attributes expectes to find the key secrets under
    # `config.active_record.encryption.*`. If the secrets were stored in Rails
    # encrypted credentials file then Rails would map them automatically for us.
    # We prefer to store the secrets in the ENV and load them through
    # `config/secrets.yml` so we have to manually assign them here.
    config.active_record.encryption.primary_key = Rails.application.secrets.active_record_encryption_primary_key
    config.active_record.encryption.deterministic_key = Rails.application.secrets.active_record_encryption_deterministic_key
    config.active_record.encryption.key_derivation_salt = Rails.application.secrets.active_record_encryption_key_derivation_salt

    config.action_dispatch.default_headers["X-Frame-Options"] = "DENY"

    # gzip Rails responses to help browsers on slow network connections.
    config.middleware.use Rack::Deflater
  RUBY
end

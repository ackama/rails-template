gsub_file! "config/application.rb",
           /# config.time_zone = ['"]Central Time \(US & Canada\)['"]/,
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

    # pull the secret_key_base from our app config
    config.secret_key_base = config.app.secret_key_base

    config.middleware.insert_before Rack::Sendfile, HttpBasicAuth
    config.action_dispatch.default_headers["Permissions-Policy"] = "interest-cohort=()"

    # Configure the encryption key for ActiveRecord encrypted attributes with values from our app config,
    # as Rails only automatically picks them up if they're sourced from `config/credentials.yml.enc`
    config.active_record.encryption.primary_key = Rails.application.config.app.active_record_encryption_primary_key
    config.active_record.encryption.deterministic_key = Rails.application.config.app.active_record_encryption_deterministic_key
    config.active_record.encryption.key_derivation_salt = Rails.application.config.app.active_record_encryption_key_derivation_salt

    config.action_dispatch.default_headers["X-Frame-Options"] = "DENY"

    # gzip Rails responses to help browsers on slow network connections.
    config.middleware.use Rack::Deflater
  RUBY
end

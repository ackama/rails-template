class VerifyPlaceholderSecretsNotUsedForReal
  class << self
    DB_ENCRYPTION_ENV_VAR_NAMES = %w[
      ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY
      ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY
      ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT
    ].freeze

    def run
      return if Rails.env.local?

      verify_secret_key_base
      verify_activerecord_encryption_secrets
    end

    private

    def verify_secret_key_base
      return unless Rails.root.join("example.env").read.include?(ENV.fetch("RAILS_SECRET_KEY_BASE"))

      raise "RAILS_SECRET_KEY_BASE is unchanged from example.env. Generate a new one with `bundle exec rails secret`"
    end

    # Verify that placeholder values created by the Ackama rails template are
    # not being used for real.
    def verify_activerecord_encryption_secrets
      example_env_contents = Rails.root.join("example.env").read

      DB_ENCRYPTION_ENV_VAR_NAMES.each do |env_var_name|
        raise "#{env_var_name} is unchanged from example.env. Generate a new one with `bundle exec rails db:encryption:init`" if example_env_contents.include?(ENV.fetch(env_var_name))
      end
    end
  end
end

VerifyPlaceholderSecretsNotUsedForReal.run

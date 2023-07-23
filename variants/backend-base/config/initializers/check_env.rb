class VerifyPlaceholderSecretsNotUsedForReal
  class << self
    PLACEHOLDER_PREFIX_REGEX = /(PLACEHOLDER|FAILED_TO_GENERATE)/.freeze

    def run
      return if local?

      verify_secret_key_base
      verify_activerecord_encryption_secrets
    end

    private

    def verify_secret_key_base
      return unless Rails.root.join("example.env").read.include?(ENV.fetch("RAILS_SECRET_KEY_BASE"))

      fail "RAILS_SECRET_KEY_BASE is unchanged from example.env. Generate a new one with `bundle exec rails secret`"
    end

    ##
    # Verify that placeholder values created by the Ackama rails template are
    # not being used for real.
    #
    def verify_activerecord_encryption_secrets # rubocop:disable Metrics/AbcSize
      secrets = [
        Rails.application.config.active_record.encryption.primary_key,
        Rails.application.config.active_record.encryption.deterministic_key,
        Rails.application.config.active_record.encryption.key_derivation_salt
      ]

      secrets.each do |secret|
        fail "Insecure ENV: ActiveRecored encrypted credentials env contain in insecure placeholder value." if secret.match?(PLACEHOLDER_PREFIX_REGEX)
      end
    end

    def local?
      Rails.env.development? || Rails.env.test?
    end
  end

VerifyPlaceholderSecretsNotUsedForReal.run

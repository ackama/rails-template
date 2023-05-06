class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :timeoutable, :trackable and :omniauthable
  #
  # NOTE: devise-two-factor requests that database_authenticatable is replaced
  # with two_factor_authenticatable. We do NOT do this, because we have a
  # two-step authentication process. We use DatabaseAuthenticatable to validate
  # the email and password, and then validate the OTP code or backup code in a
  # second step. The same is true of two_factor_backupable. Including this
  # strategy means that a failed auth attempt is flagged as a failed attempt,
  # even when rendering the MFA validation page. We DO include the model
  # methods, because we still use them
  #
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :lockable

  include Devise::Models::TwoFactorAuthenticatable
  include Devise::Models::TwoFactorBackupable

  ##
  # The `session_token` attribute is used to build the Devise
  # `authenticatable_salt` so changing the `session_token` has the effect of
  # invalidating any existing sessions for the current user.
  #
  # This method is called by Users::SessionsController#destroy to make sure
  # that when a user logs out (i.e. destroys their session) then the session
  # cookie they had cannot be used again. This closes a security issue with
  # cookie based sessions.
  #
  # References
  #   * https://github.com/plataformatec/devise/issues/3031
  #   * http://maverickblogging.com/logout-is-broken-by-default-ruby-on-rails-web-applications/
  #   * https://makandracards.com/makandra/53562-devise-invalidating-all-sessions-for-a-user
  #
  def invalidate_all_sessions!
    update!(session_token: SecureRandom.hex(16))
  end

  ##
  # devise calls this method to generate a salt for creating the session
  # cookie. We override the built-in devise implementation (which comes from
  # the devise `authenticable` module - see link below) to also include our
  # `session_token` attribute. This means that whenever the session_token
  # changes, the user's session cookie will be invalidated.
  #
  # `session_token` is `nil` until the user has signed out once. That is fine
  # because we only care about making the `session_token` **different** after
  # they logout so that the cookie is invalidated.
  #
  # References
  #  * https://github.com/heartcombo/devise/blob/master/lib/devise/models/authenticatable.rb#L97-L98
  #
  def authenticatable_salt
    "#{super}#{session_token}"
  end

  def enable_otp!
    update!(otp_secret: User.generate_otp_secret)
  end

  # this resets the secret but deliberately does not touch the
  # `otp_required_for_login` flag
  def reset_otp_secret!
    update!(otp_secret: User.generate_otp_secret)
  end

  def require_otp!
    update!(otp_required_for_login: true)
  end

  def otp_enabled_and_required?
    otp_secret.present? && otp_required_for_login
  end

  def disable_otp!
    update!(otp_secret: nil, otp_required_for_login: false, otp_backup_codes: nil)
  end

  def discard_otp_secret!
    update!(otp_secret: nil)
  end
end

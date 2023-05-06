module Users
  ##
  # This controller contains overrides to support multi-factor authentication. Each action
  # has a comment describing it's function. Also see doc/multi_factor_authentication.md for
  # a more verbose description of the sequence of events for MFA.
  class SessionsController < Devise::SessionsController
    RESOURCE_OTP_TOKEN_EXPIRY = 15.minutes # Must sign in within this time
    RESOURCE_OTP_TOKEN_PURPOSE = "mfa_attempt".freeze # Used to scope generated signed IDs

    ##
    # We do not want Warden to try and authenticate the user in middleware,
    # since this runs before any controller actions, resulting in the user
    # being signed in (AND stored, which we definitely do not want),
    # before our customised create action is run. Inside our create action, we
    # enable this setting again to allow Devise::Strategies::Authenticatable to
    # run.
    #
    # NOTE: This should be fixed in devise 5.x
    # https://github.com/heartcombo/devise/issues/5013
    # https://github.com/heartcombo/devise/pull/5032
    # https://github.com/heartcombo/devise/blob/6d32d2447cc0f3739d9732246b5a5bde98d9e032/lib/devise/strategies/authenticatable.rb#L103
    skip_before_action :allow_params_authentication!, only: :create

    ## We need to intercept the sign-in attempt if the user has OTP enabled, and
    # present them with UI to enter their MFA code. To do this, we check if the
    # user requires MFA to sign in. If it does not, we proceed as-is. If it
    # does, we render a turbo response to request their MFA code, which then
    # submits to the #validate_otp action.
    def create
      # Once we are inside the controller action, we _do_ want to allow params authentication,
      # otherwise Devise won't authenticate the user from params
      allow_params_authentication!
      disable_user_tracking!

      # NOTE: store: false is IMPORTANT - we want to authenticate the user, but not
      # actually log them in.
      self.resource = warden.authenticate!(**auth_options, store: false)
      return after_successful_sign_in unless resource.otp_required_for_login?

      store_otp_identifier(resource_to_otp_identifier)
      render :mfa_prompt, status: :forbidden
    end

    ## Validates the OTP code before signing in the user. This requires a
    # valid, non-expired signed ID representing the user to exist in the
    # session. This is set by successfully authenticating to #create. We do this
    # to avoid leaking the signed ID to the user. Even though it has a short
    # expiry, it could be used in a social phishing attack, and without
    # requiring it in the session, would allow for remote sign in without
    # authenticating the user beforehand.
    def validate_otp
      self.resource = resource_from_otp_identifier(retrieve_otp_identifer)
      return after_successful_sign_in if otp_validated

      flash[:alert] = t("devise.failure.invalid", authentication_keys: User.human_attribute_name(:email))
      redirect_to new_user_session_path
    end

    ##
    # We want to make sure that when a user logs out (i.e. destroys their
    # session) then the session cookie they had cannot be used again. We
    # achieve this by overriding the built-in devise implementation of
    # `Devise::SessionsController#destroy` action to invalidate all existing
    # user sessions and then call `super` to run the built-in devise
    # implementation of the method.
    #
    # References
    #   * https://github.com/plataformatec/devise/issues/3031
    #   * http://maverickblogging.com/logout-is-broken-by-default-ruby-on-rails-web-applications/
    #   * https://makandracards.com/makandra/53562-devise-invalidating-all-sessions-for-a-user
    #
    def destroy
      current_user.invalidate_all_sessions!
      super
    end

    private

    ##
    # Validates that a given token is eiher:
    #   1. A valid OTP code
    #   2. A valid OTP backup code
    def otp_validated
      code = otp_params[:otp_attempt].presence
      return false unless resource && code

      resource.validate_and_consume_otp!(code) ||
        (resource.invalidate_otp_backup_code!(code) && resource.save!)
    end

    def after_successful_sign_in
      set_flash_message!(:notice, :signed_in)
      enable_user_tracking!
      sign_in(resource, scope: resource_name, force: true)
      respond_with resource, location: after_sign_in_path_for(resource)
    end

    def resource_to_otp_identifier
      resource.to_signed_global_id(expires_in: RESOURCE_OTP_TOKEN_EXPIRY, for: RESOURCE_OTP_TOKEN_PURPOSE)
    end

    def resource_from_otp_identifier(otp_identifier)
      GlobalID::Locator.locate_signed(otp_identifier, for: RESOURCE_OTP_TOKEN_PURPOSE,
                                                      only: User)
    end

    def store_otp_identifier(otp_identifier)
      flash[:otp_identifier] = otp_identifier&.to_s
    end

    def retrieve_otp_identifer
      flash[:otp_identifier].presence
    end

    def otp_params
      params.require(resource_name).permit(:otp_attempt, :resource_identifier)
    end

    ##
    # Tell Devise not to track the user after any call to set_user.
    # We set this because we don't want to track a successful sign in until
    # after MFA verification.
    def disable_user_tracking!
      request.env["devise.skip_trackable"] = true
    end

    def enable_user_tracking!
      request.env["devise.skip_trackable"] = false
    end
  end
end

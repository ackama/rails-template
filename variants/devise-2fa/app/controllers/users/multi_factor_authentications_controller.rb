##
# This controller allows users to manage their MFA credential(s). This
# controller is not involved in signing in or out.
#
# Conceptually each user has one MFA resource which they can
# manage because devise-two-factor only supports one 2fa code per user
#
module Users
  class MultiFactorAuthenticationsController < ApplicationController
    before_action :authenticate_user!

    # We want users who don't already have MFA set up to be able to set it up so
    # we don't check their MFA status before controller actions which are on the
    # path to set MFA up.
    skip_before_action :require_multi_factor_authentication!, only: %i[new show create]

    # before_action { authorize :multi_factor_authentication } # TODO: fix this

    # Add the environment name to the two-factor authentication (2FA) string so that
    # you can more easily tell the 2FA codes for different environments
    # apart in your 2FA app.
    #
    # Keep this name short. Some TOTP management applications (e.g. Google
    # Authenticator) do not let users edit this name and do not show many
    # characters on screen.
    #
    ISSUER = if Rails.env.production?
               I18n.t("application.name").freeze
             else
               "#{I18n.t("application.name")} #{Rails.env}".freeze
             end

    # Allow the template to access issuer
    helper_method :issuer

    ##
    # #show is the entry point for a user managing their two-factor
    # authentication (2FA). It displays a summary of the current state of their
    # two-factor authentication (2FA) setup and buttons/links to take actions on
    # it.
    #
    def show
    end

    ##
    # #new starts the process of setting up two-factor authentication (2FA) for
    # the user
    #
    def new
      @otp_secret = User.generate_otp_secret
    end

    ##
    # #create accepts the form submission from #new and checks that the TOTP
    # code supplied by the user is valid. If the user gives us a valid TOTP code
    # then we can we be confident they have correctly setup OTP so we can
    # require it at next sign in.
    def create
      if current_user.validate_and_consume_otp!(otp_param, otp_secret: otp_secret_param)
        current_user.update!(otp_secret: otp_secret_param, otp_required_for_login: true)
        redirect_to users_multi_factor_authentication_path, notice: t(".success")
      else
        @otp_secret = otp_secret_param
        flash.now[:alert] = t(".invalid_code")
        render :new
      end
    end

    def create_backup_codes
      @backup_codes = current_user.generate_otp_backup_codes!
      current_user.save!
    end

    def destroy_backup_codes
      current_user.update!(otp_backup_codes: nil)
      redirect_to users_multi_factor_authentication_path, notice: t(".success")
    end

    private

    def otp_param
      params.require(:otp_attempt).gsub(/\A[^\d+]\z/, "")
    end

    def otp_secret_param
      params.require(:otp_secret)
    end

    def issuer
      ISSUER
    end
  end
end

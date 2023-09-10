module Users
  class DeviseController < ApplicationController
    # class DeviseController < Devise::DeviseController
    # TODO: this doesn't really need to inherit from Application controller anymore
    # Is it more or less surprising to
    before_action :configure_permitted_parameters, if: :devise_controller?

    protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
    end
  end
end

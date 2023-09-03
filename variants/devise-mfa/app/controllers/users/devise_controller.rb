# TODO: is this still the best way to do this with latest devise?
module Users
  class DeviseController < ApplicationController
    ##
    # A custom responder for Devise, required for the 'responders' gem
    # which Devise uses ('respond_with'). Without this, form
    # submissions do not respond with the correct status, meaning that
    # Turbo does not update the page.
    class Responder < ActionController::Responder
      def to_turbo_stream
        controller.render(options.merge(formats: :html))
      rescue ActionView::MissingTemplate => e
        raise e if get?

        if has_errors? && default_action
          render rendering_options.merge(formats: :html, status: :unprocessable_entity)
        else
          redirect_to navigation_location
        end
      end
    end

    self.responder = Responder
    respond_to :html, :turbo_stream

    # TODO: consider the utility of a custom authenticaiton layout
    # layout "authentication"

    before_action :configure_permitted_parameters, if: :devise_controller?

    protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
    end
  end
end

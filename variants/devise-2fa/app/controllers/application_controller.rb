class ApplicationController < ActionController::Base
  before_action :require_multi_factor_authentication!

  protected

  def require_multi_factor_authentication!
    return unless user_signed_in?
    return if devise_controller?
    return if current_user.otp_required_for_login?

    redirect_to new_users_multi_factor_authentication_path, alert: "MFA required"
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || dashboards_path
  end
end

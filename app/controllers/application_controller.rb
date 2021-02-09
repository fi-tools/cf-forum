class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_user

  before_action do
    if true || (current_user && current_user.is_admin?)
      Rack::MiniProfiler.authorize_request
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:username, :email, :password) }

    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:email, :password, :current_password) }
  end
end

class ApplicationController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter.sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter.sanitizer.permit(:account_update, keys: [:name])
  end
end

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :check_maintenance_mode
  before_action :store_user_location!, if: :storable_location?
  before_action :configure_permitted_parameters, if: :devise_controller?

  def index
    @projects = Project.public_gallery.recent.limit(9)
  end

  # Devise: redirigir tras login/logout
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || public_dashboard_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  def after_sign_up_path_for(resource)
    public_dashboard_path
  end

  private

  def check_maintenance_mode
    # Permitir acceso a cualquier ruta bajo /admin o a la página de login aunque esté en mantenimiento
    if File.exist?(Rails.root.join("tmp", "maintenance_mode")) && !(current_user&.admin?) && request.path !~ %r{^/admin} && request.path !~ %r{^/users/sign_in}
      render file: Rails.root.join("public", "503.html"), status: 503, layout: false
    end
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :full_name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :full_name ])
  end
end

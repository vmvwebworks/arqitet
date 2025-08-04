class SubscriptionRequired
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)

    # Permitir rutas públicas y de autenticación
    return @app.call(env) if allowed_path?(request.path)

    # Verificar si el usuario está autenticado
    return @app.call(env) unless request.session[:user_id] || request.env["warden"]&.authenticated?

    # Obtener usuario actual
    user = get_current_user(request)
    return @app.call(env) unless user

    # Los admins siempre tienen acceso
    return @app.call(env) if user.admin?

    # Verificar suscripción para rutas protegidas
    if protected_path?(request.path) && !user.subscribed?
      return redirect_to_subscription_page(request)
    end

    @app.call(env)
  end

  private

  def allowed_path?(path)
    # Rutas que no requieren suscripción
    allowed_paths = [
      "/", "/users/sign_in", "/users/sign_up", "/users/sign_out",
      "/subscription_plans", "/subscriptions", "/dashboard"
    ]

    allowed_paths.any? { |allowed| path.start_with?(allowed) } ||
      path.match?(/\A\/assets\//) ||
      path.match?(/\A\/packs\//) ||
      path.match?(/\A\/rails\//)
  end

  def protected_path?(path)
    # Rutas que requieren suscripción
    protected_paths = [
      "/projects/new", '/projects/\d+/edit'
    ]

    protected_paths.any? { |protected| path.match?(Regexp.new(protected)) }
  end

  def get_current_user(request)
    if request.env["warden"]&.authenticated?
      request.env["warden"].user
    elsif request.session[:user_id]
      User.find_by(id: request.session[:user_id])
    end
  end

  def redirect_to_subscription_page(request)
    [ 302, { "Location" => "/subscription_plans" }, [ "Redirecting..." ] ]
  end
end

module Subscribable
  extend ActiveSupport::Concern

  included do
    before_action :check_feature_access, only: []
  end

  private

  def check_feature_access
    return if current_user&.admin?

    unless current_user&.subscribed?
      flash[:alert] = "Esta función requiere una suscripción activa."
      redirect_to subscription_plans_path
    end
  end

  def require_feature(feature_name)
    return true if current_user&.admin?

    unless current_user&.has_feature?(feature_name)
      flash[:alert] = "Esta función no está disponible en tu plan actual. Actualiza tu suscripción para acceder."
      redirect_to subscription_plans_path
      return false
    end

    true
  end

  def subscription_required!
    return if current_user&.admin?

    unless current_user&.subscribed?
      flash[:alert] = "Necesitas una suscripción activa para acceder a esta función."
      redirect_to subscription_plans_path
    end
  end

  # Métodos helper para verificar límites
  def check_project_limit
    return true if current_user&.admin?
    return true if current_user&.subscribed?

    if current_user.projects.count >= 3
      flash[:alert] = "Has alcanzado el límite de proyectos para el plan gratuito. Actualiza tu suscripción para crear más proyectos."
      redirect_to subscription_plans_path
      return false
    end

    true
  end

  def check_chat_limit
    return true if current_user&.admin?
    return true if current_user&.has_feature?("Chat avanzado")

    # Implementar lógica de límite de mensajes si es necesario
    true
  end
end

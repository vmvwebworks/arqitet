class ConsentBannerController < ApplicationController
  protect_from_forgery with: :null_session, only: [ :accept ]
  before_action :authenticate_user!, only: [ :accept ]

  def accept
    if current_user
      consent_data = params.require(:consent).permit(:version, preferences: {})
      current_user.update(consent_preferences: consent_data.to_h)
      render json: { success: true, message: "Preferencias guardadas." }
    else
      render json: { success: false, message: "Usuario no autenticado." }, status: :unauthorized
    end
  end
end

module ConsentHelper
  def consent_given_for?(category)
    consent_data = fetch_consent_data

    # Si no hay datos de consentimiento, por defecto es falso.
    return false unless consent_data.is_a?(Hash)

    # Comprueba la preferencia para la categoría específica.
    # Aseguramos que la clave 'preferences' exista y que el valor para la categoría sea true.
    consent_data.dig("preferences", category.to_s) == true
  end

  def show_consent_banner?
    consent_text = ConsentText.first
    return false unless consent_text

    consent_version = consent_text.updated_at.to_i
    user_consent_version = 0

    if user_signed_in?
      if current_user.consent_preferences.is_a?(Hash)
        user_consent_version = current_user.consent_preferences["version"].to_i
      end
    else
      cookie = cookies[:consent_preferences]
      if cookie
        begin
          cookie_data = JSON.parse(cookie)
          user_consent_version = cookie_data["version"].to_i
        rescue JSON::ParserError
          # Cookie inválida, forzamos mostrar el banner
          return true
        end
      end
    end

    user_consent_version < consent_version
  end

  private

  def fetch_consent_data
    if user_signed_in?
      # Para usuarios registrados, la fuente de verdad es la base de datos.
      current_user.consent_preferences
    else
      # Para visitantes, leemos la cookie.
      cookie = cookies[:consent_preferences]
      return nil unless cookie

      begin
        JSON.parse(cookie)
      rescue JSON::ParserError
        # Si la cookie está malformada, la tratamos como si no hubiera consentimiento.
        nil
      end
    end
  end
end

# Configuración de Stripe
Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key) || ENV["STRIPE_SECRET_KEY"]

# Configuración según el entorno
Rails.configuration.stripe = {
  publishable_key: Rails.application.credentials.dig(:stripe, :publishable_key) || ENV["STRIPE_PUBLISHABLE_KEY"],
  secret_key: Rails.application.credentials.dig(:stripe, :secret_key) || ENV["STRIPE_SECRET_KEY"],
  webhook_secret: Rails.application.credentials.dig(:stripe, :webhook_secret) || ENV["STRIPE_WEBHOOK_SECRET"]
}

# Configurar webhooks de Stripe
StripeEvent.signing_secret = Rails.configuration.stripe[:webhook_secret] if defined?(StripeEvent)

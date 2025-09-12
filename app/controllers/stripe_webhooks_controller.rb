class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, Rails.application.credentials.dig(:stripe, :webhook_secret) || ENV['STRIPE_WEBHOOK_SECRET']
      )
    rescue JSON::ParserError => e
      render json: { error: 'Invalid payload' }, status: 400 and return
    rescue Stripe::SignatureVerificationError => e
      render json: { error: 'Invalid signature' }, status: 400 and return
    end

    case event['type']
    when 'checkout.session.completed'
      session = event['data']['object']
      user = User.find_by(email: session['customer_email'])
      if user
        # Aquí deberías actualizar la suscripción del usuario
        user.update(role: 'premium') # Ejemplo simple
      end
    end

    render json: { status: 'success' }
  end

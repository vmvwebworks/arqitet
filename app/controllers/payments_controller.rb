class PaymentsController < ApplicationController
  before_action :authenticate_user!

  def create_checkout_session
    plan = SubscriptionPlan.find(params[:plan_id])
    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card', 'google_pay'],
      line_items: [{
        price_data: {
          currency: 'eur',
          product_data: {
            name: plan.name
          },
          unit_amount: (plan.price * 100).to_i
        },
        quantity: 1
      }],
      mode: 'subscription',
      customer_email: current_user.email,
      success_url: payments_success_url + '?session_id={CHECKOUT_SESSION_ID}',
      cancel_url: payments_cancel_url
    )
    redirect_to session.url, allow_other_host: true
  end

  def success
    # Aquí puedes manejar la lógica tras el pago exitoso
  end

  def cancel
    # Aquí puedes manejar la lógica si el usuario cancela el pago
  end
end

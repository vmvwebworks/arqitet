class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_subscription, only: [ :edit, :update, :destroy ]

  def new
    @subscription_plan = SubscriptionPlan.find(params[:plan_id])
    @subscription = current_user.subscriptions.build
  end

  def create
    @subscription_plan = SubscriptionPlan.find(params[:subscription][:subscription_plan_id])

    if @subscription_plan.free?
      create_free_subscription
    else
      create_paid_subscription
    end
  rescue Stripe::CardError => e
    flash[:error] = "Error en el pago: #{e.message}"
    redirect_to subscription_plans_path
  end

  def edit
  end

  def update
    # Implementar actualización de suscripción
    if @subscription.update(subscription_params)
      flash[:notice] = "Suscripción actualizada correctamente"
      redirect_to subscription_plans_path
    else
      render :edit
    end
  end

  def destroy
    if @subscription.stripe_subscription_id.present?
      begin
        Stripe::Subscription.delete(@subscription.stripe_subscription_id)
      rescue Stripe::StripeError => e
        flash[:error] = "Error al cancelar la suscripción: #{e.message}"
        redirect_to subscription_plans_path and return
      end
    end

    @subscription.update(status: "canceled")
    flash[:notice] = "Suscripción cancelada correctamente"
    redirect_to subscription_plans_path
  end

  private

  def set_subscription
    @subscription = current_user.current_subscription
    redirect_to subscription_plans_path unless @subscription
  end

  def subscription_params
    params.require(:subscription).permit(:subscription_plan_id)
  end

  def create_free_subscription
    @subscription = current_user.subscriptions.build(
      subscription_plan: @subscription_plan,
      status: "active",
      current_period_start: Time.current,
      current_period_end: 1.year.from_now
    )

    if @subscription.save
      # Cancelar suscripción anterior si existe
      current_user.subscriptions.where.not(id: @subscription.id).update_all(status: "canceled")
      flash[:notice] = "Te has suscrito al plan gratuito correctamente"
      redirect_to subscription_plans_path
    else
      flash[:error] = "No se pudo crear la suscripción"
      redirect_to subscription_plans_path
    end
  end

  def create_paid_subscription
    # Crear o recuperar customer en Stripe
    customer = create_or_get_stripe_customer

    # Crear suscripción en Stripe
    stripe_subscription = Stripe::Subscription.create({
      customer: customer.id,
      items: [ {
        price_data: {
          currency: "eur",
          product_data: {
            name: @subscription_plan.name
          },
          recurring: {
            interval: @subscription_plan.interval
          },
          unit_amount: @subscription_plan.price_cents
        }
      } ],
      payment_behavior: "default_incomplete",
      payment_settings: { save_default_payment_method: "on_subscription" },
      expand: [ "latest_invoice.payment_intent" ]
    })

    # Crear suscripción local
    @subscription = current_user.subscriptions.build(
      subscription_plan: @subscription_plan,
      status: stripe_subscription.status,
      stripe_subscription_id: stripe_subscription.id,
      current_period_start: Time.at(stripe_subscription.current_period_start),
      current_period_end: Time.at(stripe_subscription.current_period_end)
    )

    if @subscription.save
      # Cancelar suscripción anterior si existe
      current_user.subscriptions.where.not(id: @subscription.id).update_all(status: "canceled")

      render json: {
        subscription_id: stripe_subscription.id,
        client_secret: stripe_subscription.latest_invoice.payment_intent.client_secret
      }
    else
      render json: { error: "No se pudo crear la suscripción" }, status: 422
    end
  end

  def create_or_get_stripe_customer
    if current_user.stripe_customer_id.present?
      Stripe::Customer.retrieve(current_user.stripe_customer_id)
    else
      customer = Stripe::Customer.create({
        email: current_user.email,
        name: current_user.full_name
      })
      current_user.update(stripe_customer_id: customer.id)
      customer
    end
  end
end

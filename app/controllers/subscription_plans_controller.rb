class SubscriptionPlansController < ApplicationController
  before_action :set_subscription_plan, only: [ :show ]

  def index
    @subscription_plans = SubscriptionPlan.active.order(:price_cents)
    @current_plan = current_user&.subscription_plan
  end

  def show
  end

  private

  def set_subscription_plan
    @subscription_plan = SubscriptionPlan.find(params[:id])
  end
end

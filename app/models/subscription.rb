class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :subscription_plan

  validates :status, presence: true, inclusion: {
    in: %w[active canceled past_due unpaid trialing incomplete]
  }

  scope :active, -> { where(status: [ "active", "trialing" ]) }
  scope :canceled, -> { where(status: "canceled") }

  def active?
    %w[active trialing].include?(status)
  end

  def canceled?
    status == "canceled"
  end

  def trialing?
    status == "trialing"
  end

  def trial_active?
    trialing? && trial_end&.future?
  end

  def current?
    active? && current_period_end&.future?
  end

  def expired?
    current_period_end&.past?
  end
end

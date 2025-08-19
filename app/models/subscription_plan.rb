class SubscriptionPlan < ApplicationRecord
  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions

  validates :name, presence: true, uniqueness: true
  validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :interval, presence: true, inclusion: { in: %w[month year] }

  serialize :features, coder: JSON

  monetize :price_cents

  scope :active, -> { where(active: true) }
  scope :monthly, -> { where(interval: "month") }
  scope :yearly, -> { where(interval: "year") }

  def monthly?
    interval == "month"
  end

  def yearly?
    interval == "year"
  end

  def free?
    price_cents == 0
  end

  def pro_plan?
    name.downcase.include?("pro")
  end
end

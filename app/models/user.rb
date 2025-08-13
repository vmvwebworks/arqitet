class User < ApplicationRecord
  extend FriendlyId
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  friendly_id :full_name, use: :slugged

  has_many :projects
  has_many :project_favorites, dependent: :destroy
  has_many :favorite_projects, through: :project_favorites, source: :project
  has_many :subscriptions, dependent: :destroy
  has_one :current_subscription, -> { where(status: [ "active", "trialing" ]).order(created_at: :desc) }, class_name: "Subscription"
  has_many :honorary_calculations, dependent: :destroy
  has_one_attached :avatar

  validates :full_name, presence: true

  serialize :consent_preferences, coder: JSON

  def admin?
    respond_to?(:role) ? role == "admin" : false
  end

  # Métodos para manejar favoritos
  def favorite_project(project)
    project_favorites.find_or_create_by(project: project)
  end

  def unfavorite_project(project)
    project_favorites.find_by(project: project)&.destroy
  end

  def has_favorited?(project)
    project_favorites.exists?(project: project)
  end

  # Métodos para suscripciones
  def subscribed?
    current_subscription&.active?
  end

  def subscription_plan
    current_subscription&.subscription_plan
  end

  def has_feature?(feature)
    return true if admin?
    return false unless subscribed?
    subscription_plan&.features&.include?(feature)
  end

  def trial_active?
    current_subscription&.trial_active?
  end

  # Métodos para calculadora de honorarios
  def can_create_calculation?
    return true if admin? || subscribed?
    honorary_calculations.count < 3  # Límite para usuarios gratuitos
  end

  def calculations_remaining
    return Float::INFINITY if admin? || subscribed?
    [3 - honorary_calculations.count, 0].max
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id email role created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[projects]
  end
end

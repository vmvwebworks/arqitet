class User < ApplicationRecord
  extend FriendlyId
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  friendly_id :full_name, use: :slugged

  has_many :projects
  has_many :public_projects, -> { where(is_public: true) }, class_name: 'Project'
  has_many :management_projects, -> { where(is_public: false) }, class_name: 'Project'
  has_many :project_favorites, dependent: :destroy
  has_many :favorite_projects, through: :project_favorites, source: :project
  has_many :subscriptions, dependent: :destroy
  has_one :current_subscription, -> { where(status: [ "active", "trialing" ]).order(created_at: :desc) }, class_name: "Subscription"
  has_many :honorary_calculations, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :clients, dependent: :destroy
  has_many :interactions, dependent: :destroy
  has_many :documents, dependent: :destroy
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

  # Límites basados en el plan (simple)
  def project_limit
    return Float::INFINITY if admin?
    return Float::INFINITY if subscribed?  # Plan Pro = ilimitado
    3  # Plan gratuito = 3 proyectos
  end

  def can_create_project?
    return true if admin?
    projects.count < project_limit
  end

  def projects_remaining
    limit = project_limit
    return Float::INFINITY if limit == Float::INFINITY
    [limit - projects.count, 0].max
  end

  def can_manage_clients?
    return true if admin?
    subscribed?  # Solo usuarios Pro pueden gestionar clientes
  end

  def can_calculate_honorary?
    return true if admin?
    subscribed?  # Solo usuarios Pro tienen calculadora
  end

  # Métodos para calculadora de honorarios
  def can_create_calculation?
    return true if admin?
    can_calculate_honorary?
  end

  def calculations_remaining
    return Float::INFINITY if admin? || can_calculate_honorary?
    0  # Plan gratuito no tiene acceso
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id email role created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[projects]
  end
end

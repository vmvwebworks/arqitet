class Client < ApplicationRecord
  belongs_to :user
  belongs_to :created_by, class_name: 'User', optional: true
  has_many :projects, dependent: :nullify
  has_many :invoices, through: :projects
  has_many :interactions, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { scope: :user_id }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :status, presence: true

  enum status: {
    lead: 0,
    prospect: 1,
    active: 2,
    inactive: 3,
    closed: 4
  }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }

  def full_name
    name
  end

  def display_status
    case status
    when 'lead' then 'Contacto'
    when 'prospect' then 'Prospecto'
    when 'active' then 'Cliente Activo'
    when 'inactive' then 'Inactivo'
    when 'closed' then 'Cerrado'
    end
  end

  def status_badge_class
    case status
    when 'lead' then 'bg-blue-100 text-blue-800'
    when 'prospect' then 'bg-yellow-100 text-yellow-800'
    when 'active' then 'bg-green-100 text-green-800'
    when 'inactive' then 'bg-gray-100 text-gray-800'
    when 'closed' then 'bg-red-100 text-red-800'
    end
  end

  def total_project_value
    projects.sum(:budget) || 0
  end

  def projects_count
    projects.count
  end

  def last_interaction
    interactions.order(:created_at).last
  end
end

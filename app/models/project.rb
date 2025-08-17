class Project < ApplicationRecord
  belongs_to :user
  belongs_to :client, optional: true
  has_many_attached :images
  has_many :project_favorites, dependent: :destroy
  has_many :favorited_by_users, through: :project_favorites, source: :user
  has_many :invoices, dependent: :destroy
  has_many :documents, dependent: :destroy

  # Enum para estados de proyecto (gestión arquitectónica)
  enum status: {
    proposal: 0,
    in_progress: 1,
    completed: 2,
    cancelled: 3
  }, _prefix: :project

  validates :title, :description, :category, presence: true
  # Validaciones para proyectos de gestión
  validates :client_name, presence: true, if: :is_management_project?
  validates :budget, presence: true, numericality: { greater_than: 0 }, if: :is_management_project?
  validates :surface_area, numericality: { greater_than: 0 }, allow_blank: true
  validates :client_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  paginates_per 9

  # Scopes
  scope :public_gallery, -> { where(is_public: true) }
  scope :management_projects, -> { where(is_public: false) }
  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where(status: [:proposal, :in_progress]) }

  # Incrementa el contador de visitas
  def increment_visits!
    self.class.increment_counter(:visits, id)
  end

  # Métodos para proyectos de gestión arquitectónica
  def is_management_project?
    !is_public
  end

  def status_badge_class
    return nil unless is_management_project?
    
    case status
    when 'proposal' then 'bg-yellow-100 text-yellow-800'
    when 'in_progress' then 'bg-blue-100 text-blue-800'
    when 'completed' then 'bg-green-100 text-green-800'
    when 'cancelled' then 'bg-red-100 text-red-800'
    end
  end
  
  def status_spanish
    return nil unless is_management_project?
    
    case status
    when 'proposal' then 'Propuesta'
    when 'in_progress' then 'En Progreso'
    when 'completed' then 'Finalizado'
    when 'cancelled' then 'Cancelado'
    end
  end
  
  def progress_percentage
    return nil unless is_management_project?
    
    case status
    when 'proposal' then 10
    when 'in_progress' then 50
    when 'completed' then 100
    when 'cancelled' then 0
    end
  end
  
  def total_invoiced
    invoices.paid.sum(:total_amount)
  end
  
  def pending_invoice_amount
    invoices.pending.sum(:total_amount)
  end

  def client_display_name
    if client.present?
      client.name
    elsif client_name.present?
      client_name
    else
      "Sin cliente"
    end
  end

  def client_display_email
    if client.present?
      client.email
    elsif client_email.present?
      client_email
    else
      nil
    end
  end

  # Método para crear proyecto de gestión
  def self.create_management_project(attributes)
    create(attributes.merge(is_public: false))
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id title description category location user_id created_at updated_at visits status client_name]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user]
  end
end

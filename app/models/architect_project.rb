class ArchitectProject < ApplicationRecord
  belongs_to :user
  has_many :invoices, dependent: :destroy

  enum status: {
    proposal: 0,
    in_progress: 1,
    completed: 2,
    cancelled: 3
  }

  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :client_name, presence: true
  validates :budget, presence: true, numericality: { greater_than: 0 }
  validates :surface_area, numericality: { greater_than: 0 }, allow_blank: true
  validates :client_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where(status: [ :proposal, :in_progress ]) }

  def status_badge_class
    case status
    when "proposal" then "bg-yellow-100 text-yellow-800"
    when "in_progress" then "bg-blue-100 text-blue-800"
    when "completed" then "bg-green-100 text-green-800"
    when "cancelled" then "bg-red-100 text-red-800"
    end
  end

  def status_spanish
    case status
    when "proposal" then "Propuesta"
    when "in_progress" then "En Progreso"
    when "completed" then "Finalizado"
    when "cancelled" then "Cancelado"
    end
  end

  def progress_percentage
    case status
    when "proposal" then 10
    when "in_progress" then 50
    when "completed" then 100
    when "cancelled" then 0
    end
  end

  def total_invoiced
    invoices.paid.sum(:total_amount)
  end

  def pending_invoice_amount
    invoices.pending.sum(:total_amount)
  end
end

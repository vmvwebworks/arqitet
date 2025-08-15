class Invoice < ApplicationRecord
  belongs_to :user
  belongs_to :project
  has_many :invoice_items, dependent: :destroy
  
  accepts_nested_attributes_for :invoice_items, allow_destroy: true, reject_if: :all_blank
  
  enum status: {
    draft: 0,
    sent: 1,
    paid: 2,
    overdue: 3,
    cancelled: 4
  }
  
  validates :invoice_number, presence: true, uniqueness: true
  validates :client_name, presence: true
  validates :issue_date, presence: true
  validates :tax_rate, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :subtotal, :tax_amount, :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  before_validation :generate_invoice_number, on: :create
  before_save :calculate_totals
  
  scope :recent, -> { order(created_at: :desc) }
  scope :this_year, -> { where(issue_date: Date.current.beginning_of_year..Date.current.end_of_year) }
  scope :pending, -> { where(status: [:draft, :sent]) }
  
  def status_badge_class
    case status
    when 'draft' then 'bg-gray-100 text-gray-800'
    when 'sent' then 'bg-blue-100 text-blue-800'
    when 'paid' then 'bg-green-100 text-green-800'
    when 'overdue' then 'bg-red-100 text-red-800'
    when 'cancelled' then 'bg-red-100 text-red-800'
    end
  end
  
  def status_spanish
    case status
    when 'draft' then 'Borrador'
    when 'sent' then 'Enviada'
    when 'paid' then 'Pagada'
    when 'overdue' then 'Vencida'
    when 'cancelled' then 'Cancelada'
    end
  end
  
  def overdue?
    due_date.present? && due_date < Date.current && !paid?
  end
  
  def days_until_due
    return nil unless due_date.present?
    (due_date - Date.current).to_i
  end
  
  private
  
  def generate_invoice_number
    return if invoice_number.present?
    
    year = Date.current.year
    last_invoice = user.invoices.where('invoice_number LIKE ?', "#{year}-%").order(:invoice_number).last
    
    if last_invoice
      last_number = last_invoice.invoice_number.split('-').last.to_i
      next_number = last_number + 1
    else
      next_number = 1
    end
    
    self.invoice_number = "#{year}-#{next_number.to_s.rjust(4, '0')}"
  end
  
  def calculate_totals
    self.subtotal = invoice_items.sum { |item| item.quantity * item.unit_price }
    self.tax_amount = subtotal * (tax_rate / 100)
    self.total_amount = subtotal + tax_amount
  end
end

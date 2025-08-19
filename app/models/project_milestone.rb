class ProjectMilestone < ApplicationRecord
  belongs_to :project

  validates :name, presence: true, length: { maximum: 200 }
  validates :target_date, presence: true
  validates :status, presence: true

  enum status: {
    pending: "pending",
    completed: "completed",
    overdue: "overdue",
    cancelled: "cancelled"
  }

  scope :by_target_date, -> { order(:target_date, :position) }
  scope :upcoming, -> { where("target_date >= ?", Date.current).pending }
  scope :overdue_milestones, -> { where("target_date < ? AND status = ?", Date.current, "pending") }

  before_save :update_status_based_on_date

  def overdue?
    target_date < Date.current && pending?
  end

  def days_until_target
    (target_date - Date.current).to_i
  end

  def status_spanish
    case status
    when "pending" then "Pendiente"
    when "completed" then "Completado"
    when "overdue" then "Atrasado"
    when "cancelled" then "Cancelado"
    else "Desconocido"
    end
  end

  def status_color
    case status
    when "pending"
      if overdue?
        "red"
      elsif days_until_target <= 7
        "yellow"
      else
        "blue"
      end
    when "completed" then "green"
    when "overdue" then "red"
    when "cancelled" then "gray"
    else "gray"
    end
  end

  def mark_as_completed!
    update!(status: :completed, completed_at: Time.current)
  end

  def mark_as_cancelled!
    update!(status: :cancelled)
  end

  private

  def update_status_based_on_date
    if pending? && target_date < Date.current
      self.status = :overdue
    end
  end
end

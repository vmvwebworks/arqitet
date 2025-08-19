class ProjectTask < ApplicationRecord
  belongs_to :project
  belongs_to :assigned_to, class_name: "User", optional: true

  has_many :predecessor_dependencies, class_name: "TaskDependency",
           foreign_key: "successor_task_id", dependent: :destroy
  has_many :successor_dependencies, class_name: "TaskDependency",
           foreign_key: "predecessor_task_id", dependent: :destroy

  has_many :predecessor_tasks, through: :predecessor_dependencies, source: :predecessor_task
  has_many :successor_tasks, through: :successor_dependencies, source: :successor_task

  validates :name, presence: true, length: { maximum: 200 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :progress, presence: true, inclusion: { in: 0..100 }
  validates :priority, presence: true
  validates :status, presence: true

  validate :end_date_after_start_date

  enum status: {
    pending: "pending",
    in_progress: "in_progress",
    completed: "completed",
    on_hold: "on_hold",
    cancelled: "cancelled"
  }

  enum priority: {
    very_low: 1,
    low: 2,
    normal: 3,
    high: 4,
    critical: 5
  }

  scope :by_start_date, -> { order(:start_date, :position) }
  scope :active, -> { where.not(status: [ "completed", "cancelled" ]) }
  scope :overdue, -> { where("end_date < ? AND status != ?", Date.current, "completed") }

  def duration_days
    return 0 unless start_date && end_date
    (end_date - start_date).to_i + 1
  end

  def overdue?
    end_date < Date.current && !completed?
  end

  def on_schedule?
    return true if completed?
    expected_progress = calculate_expected_progress
    progress >= expected_progress - 10 # 10% tolerance
  end

  def status_spanish
    case status
    when "pending" then "Pendiente"
    when "in_progress" then "En Progreso"
    when "completed" then "Completada"
    when "on_hold" then "En Espera"
    when "cancelled" then "Cancelada"
    else "Desconocido"
    end
  end

  def priority_spanish
    case priority
    when "very_low" then "Muy Baja"
    when "low" then "Baja"
    when "normal" then "Normal"
    when "high" then "Alta"
    when "critical" then "Crítica"
    else "Normal"
    end
  end

  def status_color
    case status
    when "pending" then "gray"
    when "in_progress" then "blue"
    when "completed" then "green"
    when "on_hold" then "yellow"
    when "cancelled" then "red"
    else "gray"
    end
  end

  def priority_color
    case priority
    when "very_low", "low" then "green"
    when "normal" then "blue"
    when "high" then "yellow"
    when "critical" then "red"
    else "gray"
    end
  end

  def can_start?
    predecessor_tasks.all?(&:completed?)
  end

  private

  def end_date_after_start_date
    return unless start_date && end_date
    if end_date < start_date
      errors.add(:end_date, "debe ser posterior a la fecha de inicio")
    end
  end

  def calculate_expected_progress
    return 0 unless start_date && end_date

    total_days = duration_days
    return 100 if total_days <= 0

    elapsed_days = [ 0, (Date.current - start_date).to_i ].max
    return 100 if elapsed_days >= total_days

    (elapsed_days.to_f / total_days * 100).round
  end
end

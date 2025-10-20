class ProjectSlot < ApplicationRecord
  belongs_to :project
  has_many :slot_applications, dependent: :destroy

  belongs_to :assigned_user, class_name: 'User', optional: true

  validates :role, presence: true
  validates :max_professionals, numericality: { greater_than: 0 }

  # Scopes
  scope :available, -> { where(assigned_user: nil) }
  scope :occupied, -> { where.not(assigned_user: nil) }

  # Status methods
  def available?
    assigned_user.nil?
  end

  def occupied?
    !available?
  end

  def pending_applications_count
    slot_applications.pending.count
  end

  def has_pending_applications?
    pending_applications_count > 0
  end

  def can_receive_applications?
    available? && project.user != assigned_user
  end

  def user_has_applied?(user)
    return false unless user
    slot_applications.where(user: user).exists?
  end

  def user_application_status(user)
    return nil unless user
    application = slot_applications.find_by(user: user)
    application&.status
  end
end

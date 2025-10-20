class SlotApplication < ApplicationRecord
  belongs_to :project_slot
  belongs_to :user

  STATUSES = %w[pending accepted rejected].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :user_id, uniqueness: { scope: :project_slot_id, message: "Ya has aplicado a este slot" }
  
  scope :pending, -> { where(status: 'pending') }
  scope :accepted, -> { where(status: 'accepted') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :recent, -> { order(created_at: :desc) }

  # Status methods
  def pending?
    status == 'pending'
  end

  def accepted?
    status == 'accepted'
  end

  def rejected?
    status == 'rejected'
  end

  def accept!
    update!(status: 'accepted')
    project_slot.update!(assigned_user: user)
  end

  def reject!
    update!(status: 'rejected')
  end

  def project
    project_slot.project
  end
end

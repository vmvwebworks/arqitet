class SlotApplication < ApplicationRecord
  belongs_to :project_slot
  belongs_to :user

  STATUSES = %w[pending accepted rejected]

  validates :status, inclusion: { in: STATUSES }
  
  scope :pending, -> { where(status: 'pending') }
  scope :accepted, -> { where(status: 'accepted') }
  scope :rejected, -> { where(status: 'rejected') }
end

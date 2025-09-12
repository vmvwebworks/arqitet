class ProjectSlot < ApplicationRecord
  belongs_to :project
  has_many :slot_applications, dependent: :destroy

  belongs_to :assigned_user, class_name: 'User', optional: true

  validates :role, presence: true
  validates :max_professionals, numericality: { greater_than: 0 }
end

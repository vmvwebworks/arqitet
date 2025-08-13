class RateTariff < ApplicationRecord
  validates :region, presence: true
  validates :project_type, presence: true
  validates :base_rate, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }
  scope :by_region, ->(region) { where(region: region) }
  scope :by_project_type, ->(type) { where(project_type: type) }

  def self.get_rate(region, project_type)
    find_by(
      region: region,
      project_type: project_type,
      active: true
    ) || find_by(
      region: 'General',
      project_type: project_type,
      active: true
    )
  end
end

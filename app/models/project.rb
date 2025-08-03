class Project < ApplicationRecord
  belongs_to :user
  has_many_attached :images

  validates :title, :description, :category, presence: true

  paginates_per 9

  # Incrementa el contador de visitas
  def increment_visits!
    self.class.increment_counter(:visits, id)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id title description category location user_id created_at updated_at visits]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user]
  end
end
class User < ApplicationRecord
  extend FriendlyId
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  friendly_id :full_name, use: :slugged

  has_many :projects
  has_one_attached :avatar

  validates :full_name, presence: true

  serialize :consent_preferences, coder: JSON

  def admin?
    respond_to?(:role) ? role == "admin" : false
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id email role created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[projects]
  end
end

class Interaction < ApplicationRecord
  belongs_to :client
  belongs_to :user

  validates :interaction_type, presence: true
  validates :subject, presence: true
  validates :date, presence: true

  enum interaction_type: {
    call: 'call',
    email: 'email',
    meeting: 'meeting',
    note: 'note',
    proposal: 'proposal',
    contract: 'contract'
  }

  scope :recent, -> { order(date: :desc) }
  scope :by_type, ->(type) { where(interaction_type: type) }

  def interaction_type_spanish
    case interaction_type
    when 'call' then 'Llamada'
    when 'email' then 'Email'
    when 'meeting' then 'Reunión'
    when 'note' then 'Nota'
    when 'proposal' then 'Propuesta'
    when 'contract' then 'Contrato'
    end
  end

  def interaction_type_icon
    case interaction_type
    when 'call' then 'phone'
    when 'email' then 'mail'
    when 'meeting' then 'users'
    when 'note' then 'edit'
    when 'proposal' then 'file-text'
    when 'contract' then 'file-check'
    end
  end

  def interaction_type_badge_class
    case interaction_type
    when 'call' then 'bg-blue-100 text-blue-800'
    when 'email' then 'bg-green-100 text-green-800'
    when 'meeting' then 'bg-purple-100 text-purple-800'
    when 'note' then 'bg-gray-100 text-gray-800'
    when 'proposal' then 'bg-yellow-100 text-yellow-800'
    when 'contract' then 'bg-red-100 text-red-800'
    end
  end
end

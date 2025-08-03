class AddConsentAcceptedToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :consent_accepted, :boolean, default: false, null: false
    add_column :users, :consent_accepted_at, :datetime
  end
end

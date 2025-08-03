class AddConsentPreferencesToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :consent_preferences, :text
  end
end

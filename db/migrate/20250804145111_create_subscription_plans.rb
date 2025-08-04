class CreateSubscriptionPlans < ActiveRecord::Migration[7.2]
  def change
    create_table :subscription_plans do |t|
      t.string :name
      t.text :description
      t.integer :price_cents
      t.string :interval
      t.text :features
      t.boolean :active

      t.timestamps
    end
  end
end

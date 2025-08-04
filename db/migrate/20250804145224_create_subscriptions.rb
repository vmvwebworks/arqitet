class CreateSubscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :subscription_plan, null: false, foreign_key: true
      t.string :status
      t.string :stripe_subscription_id
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.datetime :trial_end

      t.timestamps
    end
  end
end

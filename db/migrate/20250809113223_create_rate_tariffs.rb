class CreateRateTariffs < ActiveRecord::Migration[7.2]
  def change
    create_table :rate_tariffs do |t|
      t.string :region
      t.string :project_type
      t.decimal :min_rate
      t.decimal :max_rate
      t.decimal :base_rate
      t.boolean :active

      t.timestamps
    end
  end
end

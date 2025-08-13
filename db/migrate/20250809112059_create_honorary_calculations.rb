class CreateHonoraryCalculations < ActiveRecord::Migration[7.2]
  def change
    create_table :honorary_calculations do |t|
      t.references :user, null: false, foreign_key: true
      t.string :project_type
      t.decimal :surface_area
      t.string :location
      t.decimal :complexity_factor
      t.decimal :base_rate
      t.decimal :total_amount
      t.text :calculation_data

      t.timestamps
    end
  end
end

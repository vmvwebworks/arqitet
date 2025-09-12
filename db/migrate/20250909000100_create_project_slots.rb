class CreateProjectSlots < ActiveRecord::Migration[7.2]
  def change
    create_table :project_slots do |t|
      t.references :project, null: false, foreign_key: true
      t.string :role, null: false # Ej: arquitecto, ingeniero, etc.
      t.text :description
      t.integer :max_professionals, default: 1
      t.timestamps
    end
  end
end

class CreateArchitectProjects < ActiveRecord::Migration[7.2]
  def change
    create_table :architect_projects do |t|
      t.string :name, null: false
      t.text :description
      t.string :client_name, null: false
      t.string :client_email
      t.string :client_phone
      t.decimal :budget, precision: 10, scale: 2
      t.decimal :surface_area, precision: 8, scale: 2
      t.string :location
      t.integer :status, default: 0
      t.date :start_date
      t.date :expected_end_date
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :architect_projects, :status
  end
end

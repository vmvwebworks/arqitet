class CreateProjectTasks < ActiveRecord::Migration[7.2]
  def change
    create_table :project_tasks do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :progress, default: 0
      t.integer :priority, default: 1
      t.string :status, default: 'pending'
      t.references :assigned_to, null: true, foreign_key: { to_table: :users }
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :project_tasks, [ :project_id, :position ]
    add_index :project_tasks, :status
  end
end

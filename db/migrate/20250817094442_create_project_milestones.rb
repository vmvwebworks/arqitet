class CreateProjectMilestones < ActiveRecord::Migration[7.2]
  def change
    create_table :project_milestones do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.date :target_date, null: false
      t.datetime :completed_at
      t.string :status, default: 'pending'
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :project_milestones, [ :project_id, :position ]
    add_index :project_milestones, :status
    add_index :project_milestones, :target_date
  end
end

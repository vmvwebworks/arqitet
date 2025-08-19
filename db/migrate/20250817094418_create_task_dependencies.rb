class CreateTaskDependencies < ActiveRecord::Migration[7.2]
  def change
    create_table :task_dependencies do |t|
      t.references :predecessor_task, null: false, foreign_key: { to_table: :project_tasks }
      t.references :successor_task, null: false, foreign_key: { to_table: :project_tasks }
      t.string :dependency_type, default: 'finish_to_start'

      t.timestamps
    end

    add_index :task_dependencies, [ :predecessor_task_id, :successor_task_id ],
              unique: true, name: 'index_task_dependencies_unique'
  end
end

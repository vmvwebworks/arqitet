class ExtendProjectsForArchitectureManagement < ActiveRecord::Migration[7.2]
  def change
    add_column :projects, :client_name, :string
    add_column :projects, :client_email, :string
    add_column :projects, :client_phone, :string
    add_column :projects, :budget, :decimal, precision: 10, scale: 2
    add_column :projects, :surface_area, :decimal, precision: 8, scale: 2
    add_column :projects, :status, :integer, default: 0
    add_column :projects, :start_date, :date
    add_column :projects, :expected_end_date, :date
    add_column :projects, :project_type, :string
    add_column :projects, :is_public, :boolean, default: true
    
    add_index :projects, :status
    add_index :projects, :is_public
  end
end

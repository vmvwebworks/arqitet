class ChangeArchitectProjectToProjectInInvoices < ActiveRecord::Migration[7.2]
  def change
    # Renombrar la columna de architect_project_id a project_id
    rename_column :invoices, :architect_project_id, :project_id
    
    # Cambiar la foreign key
    remove_foreign_key :invoices, :architect_projects if foreign_key_exists?(:invoices, :architect_projects)
    add_foreign_key :invoices, :projects
  end
end

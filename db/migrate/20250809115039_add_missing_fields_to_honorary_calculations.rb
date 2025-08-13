class AddMissingFieldsToHonoraryCalculations < ActiveRecord::Migration[7.2]
  def change
    add_column :honorary_calculations, :project_name, :string
    add_column :honorary_calculations, :client_name, :string
    add_column :honorary_calculations, :notes, :text
    add_column :honorary_calculations, :complexity, :string
  end
end

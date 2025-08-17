class FixUploadedByReference < ActiveRecord::Migration[7.2]
  def change
    # Eliminar la referencia incorrecta
    remove_reference :documents, :uploaded_by, null: false, foreign_key: true
    
    # Agregar la referencia correcta que apunta a la tabla users
    add_reference :documents, :uploaded_by, null: true, foreign_key: { to_table: :users }
  end
end

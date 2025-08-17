class FixCreatedByReference < ActiveRecord::Migration[7.2]
  def change
    # Eliminar la referencia incorrecta
    remove_reference :clients, :created_by, foreign_key: true
    
    # Agregar la referencia correcta apuntando a users
    add_reference :clients, :created_by, null: true, foreign_key: { to_table: :users }
  end
end

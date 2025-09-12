class AddProfileTypeToUsers < ActiveRecord::Migration[7.2]
  def change
  add_column :users, :profile_type, :string, default: "standard" # standard, professional, empresa
  add_column :users, :profession, :string # Ej: arquitecto, ingeniero, etc.
  end
end

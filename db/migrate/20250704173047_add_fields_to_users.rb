class AddFieldsToUsers < ActiveRecord::Migration[7.2]
  def up
    add_column :users, :full_name, :string
    add_column :users, :bio, :text
    add_column :users, :location, :string
    add_column :users, :specialty, :string
    add_column :users, :slug, :string
    add_index :users, :slug, unique: true
  end
end

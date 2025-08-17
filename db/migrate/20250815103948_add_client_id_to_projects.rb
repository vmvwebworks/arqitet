class AddClientIdToProjects < ActiveRecord::Migration[7.2]
  def change
    add_reference :projects, :client, null: true, foreign_key: true
  end
end

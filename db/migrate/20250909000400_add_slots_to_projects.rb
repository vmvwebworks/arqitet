class AddSlotsToProjects < ActiveRecord::Migration[7.2]
  def change
    add_column :projects, :slots_enabled, :boolean, default: false
  end
end

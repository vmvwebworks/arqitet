class AddAssignedUserToProjectSlots < ActiveRecord::Migration[7.2]
  def change
    add_reference :project_slots, :assigned_user, null: true, foreign_key: { to_table: :users }
  end
end

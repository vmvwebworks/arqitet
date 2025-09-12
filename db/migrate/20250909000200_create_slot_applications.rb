class CreateSlotApplications < ActiveRecord::Migration[7.2]
  def change
    create_table :slot_applications do |t|
      t.references :project_slot, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, default: "pending" # pending, accepted, rejected
      t.text :message
      t.timestamps
    end
  end
end

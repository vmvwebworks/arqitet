class CreateInteractions < ActiveRecord::Migration[7.2]
  def change
    create_table :interactions do |t|
      t.references :client, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :interaction_type
      t.string :subject
      t.text :content
      t.datetime :date

      t.timestamps
    end
  end
end

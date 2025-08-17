class CreateClients < ActiveRecord::Migration[7.2]
  def change
    create_table :clients do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :email
      t.string :phone
      t.text :address
      t.string :company
      t.string :tax_id
      t.string :website
      t.text :notes
      t.integer :status
      t.references :created_by, null: false, foreign_key: true

      t.timestamps
    end
  end
end

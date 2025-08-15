class CreateInvoiceItems < ActiveRecord::Migration[7.2]
  def change
    create_table :invoice_items do |t|
      t.references :invoice, null: false, foreign_key: true
      t.string :description, null: false
      t.decimal :quantity, precision: 8, scale: 2, default: 1.0
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.decimal :total, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end

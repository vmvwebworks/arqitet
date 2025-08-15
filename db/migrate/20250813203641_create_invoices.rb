class CreateInvoices < ActiveRecord::Migration[7.2]
  def change
    create_table :invoices do |t|
      t.references :user, null: false, foreign_key: true
      t.references :architect_project, null: false, foreign_key: true
      t.string :invoice_number, null: false
      t.string :client_name, null: false
      t.string :client_email
      t.text :client_address
      t.decimal :subtotal, precision: 10, scale: 2, default: 0
      t.decimal :tax_rate, precision: 5, scale: 2, default: 21.0
      t.decimal :tax_amount, precision: 10, scale: 2, default: 0
      t.decimal :total_amount, precision: 10, scale: 2, default: 0
      t.integer :status, default: 0
      t.date :issue_date, null: false
      t.date :due_date
      t.text :notes

      t.timestamps
    end

    add_index :invoices, :invoice_number, unique: true
    add_index :invoices, :status
  end
end

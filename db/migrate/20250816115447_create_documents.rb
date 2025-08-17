class CreateDocuments < ActiveRecord::Migration[7.2]
  def change
    create_table :documents do |t|
      t.references :project, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :file_type
      t.integer :file_size
      t.text :description
      t.string :category
      t.integer :version
      t.references :uploaded_by, null: false, foreign_key: true

      t.timestamps
    end
  end
end

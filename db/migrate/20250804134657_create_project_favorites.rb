class CreateProjectFavorites < ActiveRecord::Migration[7.2]
  def change
    create_table :project_favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end

    add_index :project_favorites, [ :user_id, :project_id ], unique: true
  end
end

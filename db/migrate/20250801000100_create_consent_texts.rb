class CreateConsentTexts < ActiveRecord::Migration[7.0]
  def change
    create_table :consent_texts do |t|
      t.text :content, null: false
      t.string :locale, default: 'es'
      t.timestamps
    end
  end
end

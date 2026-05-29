class CreateTechnicalStudies < ActiveRecord::Migration[8.0]
  def change
    create_table :technical_studies do |t|
      t.references :api_document, null: false, foreign_key: true, index: { unique: true }
      t.text :content, null: false, default: ""
      t.text :summary, null: false, default: ""
      t.string :status, null: false, default: "pending"

      t.timestamps
    end

    add_index :technical_studies, :status
  end
end

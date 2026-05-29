class CreateApiDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :api_documents do |t|
      t.string :title, null: false
      t.string :source_type, null: false
      t.string :source_url
      t.string :status, null: false, default: "pending"
      t.text :raw_content
      t.text :normalized_content
      t.jsonb :metadata, null: false, default: {}
      t.datetime :processed_at

      t.timestamps
    end

    add_index :api_documents, :source_type
    add_index :api_documents, :status
  end
end

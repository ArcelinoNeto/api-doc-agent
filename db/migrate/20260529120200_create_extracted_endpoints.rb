class CreateExtractedEndpoints < ActiveRecord::Migration[8.0]
  def change
    create_table :extracted_endpoints do |t|
      t.references :api_document, null: false, foreign_key: true
      t.string :http_method, null: false
      t.string :path, null: false
      t.text :description
      t.jsonb :headers, null: false, default: {}
      t.jsonb :query_params, null: false, default: {}
      t.jsonb :body_params, null: false, default: {}
      t.jsonb :response_examples, null: false, default: {}
      t.jsonb :error_examples, null: false, default: {}

      t.timestamps
    end

    add_index :extracted_endpoints, [ :api_document_id, :http_method, :path ], unique: true
  end
end

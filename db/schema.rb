# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_06_03_141000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "agent_executions", force: :cascade do |t|
    t.bigint "api_document_id", null: false
    t.string "agent_name", null: false
    t.string "status", default: "pending", null: false
    t.jsonb "input", default: {}, null: false
    t.jsonb "output", default: {}, null: false
    t.text "error_message"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_name"], name: "index_agent_executions_on_agent_name"
    t.index ["api_document_id"], name: "index_agent_executions_on_api_document_id"
    t.index ["status"], name: "index_agent_executions_on_status"
  end

  create_table "api_documents", force: :cascade do |t|
    t.string "title", null: false
    t.string "source_type", null: false
    t.string "source_url"
    t.string "status", default: "pending", null: false
    t.text "raw_content"
    t.text "normalized_content"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "failure_reason"
    t.index ["source_type"], name: "index_api_documents_on_source_type"
    t.index ["status"], name: "index_api_documents_on_status"
  end

  create_table "extracted_endpoints", force: :cascade do |t|
    t.bigint "api_document_id", null: false
    t.string "http_method", null: false
    t.string "path", null: false
    t.text "description"
    t.jsonb "headers", default: {}, null: false
    t.jsonb "query_params", default: {}, null: false
    t.jsonb "body_params", default: {}, null: false
    t.jsonb "response_examples", default: {}, null: false
    t.jsonb "error_examples", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["api_document_id", "http_method", "path"], name: "idx_on_api_document_id_http_method_path_64a0284503", unique: true
    t.index ["api_document_id"], name: "index_extracted_endpoints_on_api_document_id"
  end

  create_table "technical_studies", force: :cascade do |t|
    t.bigint "api_document_id", null: false
    t.text "content", default: "", null: false
    t.text "summary", default: "", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["api_document_id"], name: "index_technical_studies_on_api_document_id", unique: true
    t.index ["status"], name: "index_technical_studies_on_status"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "agent_executions", "api_documents"
  add_foreign_key "extracted_endpoints", "api_documents"
  add_foreign_key "technical_studies", "api_documents"
end

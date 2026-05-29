class CreateAgentExecutions < ActiveRecord::Migration[8.0]
  def change
    create_table :agent_executions do |t|
      t.references :api_document, null: false, foreign_key: true
      t.string :agent_name, null: false
      t.string :status, null: false, default: "pending"
      t.jsonb :input, null: false, default: {}
      t.jsonb :output, null: false, default: {}
      t.text :error_message
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end

    add_index :agent_executions, :agent_name
    add_index :agent_executions, :status
  end
end

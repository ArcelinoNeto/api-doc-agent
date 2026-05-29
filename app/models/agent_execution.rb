class AgentExecution < ApplicationRecord
  enum :status, {
    pending: "pending",
    running: "running",
    completed: "completed",
    failed: "failed"
  }

  belongs_to :api_document

  validates :agent_name, presence: true
end

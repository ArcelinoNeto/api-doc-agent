class TechnicalStudy < ApplicationRecord
  enum :status, {
    pending: "pending",
    completed: "completed",
    failed: "failed"
  }

  belongs_to :api_document

  validates :api_document_id, uniqueness: true
  validates :content, :summary, presence: true, if: :completed?
end

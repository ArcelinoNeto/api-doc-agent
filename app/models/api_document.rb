class ApiDocument < ApplicationRecord
  SOURCE_TYPES = {
    url: "url",
    pdf: "pdf"
  }.freeze

  enum :source_type, SOURCE_TYPES
  enum :status, {
    pending: "pending",
    processing: "processing",
    completed: "completed",
    failed: "failed"
  }

  has_many :agent_executions, dependent: :destroy
  has_many :extracted_endpoints, dependent: :destroy
  has_one :technical_study, dependent: :destroy
  has_one_attached :pdf_file

  validates :title, presence: true
  validates :source_type, presence: true
  validates :source_url, presence: true, if: :url?
  validate :pdf_file_required_for_pdf

  private

  def pdf_file_required_for_pdf
    return unless pdf?
    return if pdf_file.attached?

    errors.add(:pdf_file, "must be attached for PDF documents")
  end
end

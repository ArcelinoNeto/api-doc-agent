class ApiDocumentSerializer
  def self.call(api_document)
    {
      id: api_document.id,
      title: api_document.title,
      source_type: api_document.source_type,
      source_url: api_document.source_url,
      status: api_document.status,
      metadata: api_document.metadata,
      failure_reason: api_document.failure_reason,
      processed_at: api_document.processed_at,
      created_at: api_document.created_at,
      updated_at: api_document.updated_at,
      pdf_attached: api_document.pdf_file.attached?
    }
  end
end

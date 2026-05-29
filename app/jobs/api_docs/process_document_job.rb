module ApiDocs
  class ProcessDocumentJob < ApplicationJob
    queue_as :default

    def perform(api_document_id)
      api_document = ApiDocument.find(api_document_id)

      ApiDocs::ProcessDocument.call(api_document)
    end
  end
end

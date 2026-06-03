module ApiDocs
  class ProcessDocument
    AGENTS = [
      Agents::DocumentReaderAgent,
      Agents::EndpointExtractorAgent,
      Agents::TechnicalStudyAgent
    ].freeze

    def self.call(api_document)
      new(api_document).call
    end

    def initialize(api_document)
      @api_document = api_document
    end

    def call
      prepare_document!
      AGENTS.each { |agent_class| agent_class.new(api_document).execute }
      api_document.update!(status: :completed, processed_at: Time.current, failure_reason: nil)
    rescue StandardError => error
      api_document.update!(status: :failed, failure_reason: error.message)
      raise
    end

    private

    attr_reader :api_document

    def prepare_document!
      api_document.with_lock do
        api_document.extracted_endpoints.destroy_all
        api_document.technical_study&.destroy
        api_document.association(:extracted_endpoints).reset
        api_document.association(:technical_study).reset
        api_document.update!(
          status: :processing,
          failure_reason: nil,
          processed_at: nil
        )
      end

      api_document.reload
    end
  end
end

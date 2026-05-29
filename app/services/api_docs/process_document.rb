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
      api_document.processing!
      AGENTS.each { |agent_class| agent_class.new(api_document).execute }
      api_document.update!(status: :completed, processed_at: Time.current)
    rescue StandardError
      api_document.failed!
      raise
    end

    private

    attr_reader :api_document
  end
end

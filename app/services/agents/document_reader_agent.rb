require "net/http"

module Agents
  class DocumentReaderAgent < BaseAgent
    private

    def perform
      raw_content = api_document.url? ? fetch_url_content : pdf_placeholder_content
      normalized_content = normalize(raw_content)

      api_document.update!(
        raw_content: raw_content,
        normalized_content: normalized_content,
        metadata: api_document.metadata.merge(reader_metadata)
      )

      {
        "source_type" => api_document.source_type,
        "content_length" => normalized_content.length
      }
    end

    def fetch_url_content
      uri = URI.parse(api_document.source_url)
      response = Net::HTTP.get_response(uri)
      raise AgentError, "Could not read URL: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      response.body.to_s
    end

    def pdf_placeholder_content
      attachment = api_document.pdf_file
      "PDF attached: #{attachment.filename} (#{attachment.byte_size} bytes). PDF text extraction will be implemented next."
    end

    def normalize(content)
      content.to_s.gsub(/[[:space:]]+/, " ").strip
    end

    def reader_metadata
      {
        "read_at" => Time.current.iso8601,
        "pdf_attached" => api_document.pdf_file.attached?
      }
    end
  end
end

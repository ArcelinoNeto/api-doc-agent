require "pdf-reader"
require "tempfile"

module ApiDocs
  class PdfTextExtractor
    Error = Class.new(StandardError)

    MAX_PDF_BYTES = 10.megabytes

    def self.call(attachment)
      new(attachment).call
    end

    def initialize(attachment)
      @attachment = attachment
    end

    def call
      validate_attachment!

      Tempfile.create([ "api-doc-agent", ".pdf" ], binmode: true) do |file|
        file.write(attachment.download)
        file.rewind

        text = PDF::Reader.new(file.path).pages.map(&:text).join("\n\n").strip
        raise Error, "PDF text extraction returned no content" if text.blank?

        text
      end
    rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError => error
      raise Error, "Could not extract PDF text: #{error.message}"
    end

    private

    attr_reader :attachment

    def validate_attachment!
      raise Error, "PDF file is not attached" unless attachment.attached?
      raise Error, "PDF file is too large" if attachment.byte_size > MAX_PDF_BYTES

      return if attachment.content_type == "application/pdf"

      raise Error, "Attachment must be a PDF"
    end
  end
end

require "rails_helper"

RSpec.describe ApiDocs::PdfTextExtractor do
  it "extracts text from a PDF attachment" do
    document = ApiDocument.new(title: "Payments", source_type: :pdf)
    document.pdf_file.attach(
      io: Rails.root.join("spec/fixtures/files/sample.pdf").open,
      filename: "sample.pdf",
      content_type: "application/pdf"
    )
    document.save!
    page = instance_double(PDF::Reader::Page, text: "GET /v1/payments")
    reader = instance_double(PDF::Reader, pages: [ page ])
    allow(PDF::Reader).to receive(:new).and_return(reader)

    expect(described_class.call(document.pdf_file)).to include("GET /v1/payments")
  end

  it "rejects non-PDF attachments" do
    document = ApiDocument.new(title: "Payments", source_type: :pdf)
    document.pdf_file.attach(io: StringIO.new("text"), filename: "sample.txt", content_type: "text/plain")
    document.save!(validate: false)

    expect do
      described_class.call(document.pdf_file)
    end.to raise_error(described_class::Error, /must be a PDF/)
  end
end

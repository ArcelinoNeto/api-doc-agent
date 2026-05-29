require "rails_helper"

RSpec.describe ApiDocs::ProcessDocumentJob, type: :job do
  it "delegates processing to the service" do
    document = ApiDocument.create!(title: "Payments", source_type: :url, source_url: "https://example.com/docs")

    allow(ApiDocs::ProcessDocument).to receive(:call)

    described_class.perform_now(document.id)

    expect(ApiDocs::ProcessDocument).to have_received(:call).with(document)
  end
end

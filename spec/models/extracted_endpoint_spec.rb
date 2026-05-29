require "rails_helper"

RSpec.describe ExtractedEndpoint, type: :model do
  it "normalizes HTTP method before validation" do
    document = ApiDocument.create!(title: "Payments", source_type: :url, source_url: "https://example.com/docs")
    endpoint = described_class.new(api_document: document, http_method: "get", path: "/payments")

    expect(endpoint).to be_valid
    expect(endpoint.http_method).to eq("GET")
  end
end

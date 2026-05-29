require "rails_helper"

RSpec.describe Agents::EndpointExtractorAgent do
  it "extracts endpoints from normalized content" do
    document = ApiDocument.create!(
      title: "Payments",
      source_type: :url,
      source_url: "https://example.com/docs",
      normalized_content: "Create payment with POST /v1/payments and fetch with GET /v1/payments/{id}"
    )

    output = described_class.new(document).execute

    expect(output).to eq("endpoints_count" => 2)
    expect(document.extracted_endpoints.pluck(:http_method, :path)).to contain_exactly(
      [ "POST", "/v1/payments" ],
      [ "GET", "/v1/payments/{id}" ]
    )
  end
end

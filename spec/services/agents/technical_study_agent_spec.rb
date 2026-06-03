require "rails_helper"

RSpec.describe Agents::TechnicalStudyAgent do
  it "uses the local fallback when OpenAI is not configured" do
    document = ApiDocument.create!(
      title: "Payments",
      source_type: :url,
      source_url: "https://example.com/docs",
      normalized_content: "GET /v1/payments"
    )
    document.extracted_endpoints.create!(http_method: "GET", path: "/v1/payments")
    client = instance_double(Openai::Client, available?: false)
    allow(Openai::Client).to receive(:new).and_return(client)

    output = described_class.new(document).execute

    expect(output).to include("generator" => "local_fallback", "endpoints_count" => 1)
    expect(document.technical_study).to be_completed
  end
end

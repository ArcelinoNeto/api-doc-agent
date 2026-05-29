require "rails_helper"

RSpec.describe ApiDocs::ProcessDocument do
  it "runs the MVP agent pipeline" do
    document = ApiDocument.create!(title: "Payments", source_type: :url, source_url: "https://example.com/docs")

    allow(Net::HTTP).to receive(:get_response).and_return(
      double("http_response", is_a?: true, body: "List payments: GET /v1/payments")
    )

    described_class.call(document)

    expect(document.reload).to be_completed
    expect(document.agent_executions.completed.count).to eq(3)
    expect(document.extracted_endpoints.count).to eq(1)
    expect(document.technical_study).to be_completed
  end
end

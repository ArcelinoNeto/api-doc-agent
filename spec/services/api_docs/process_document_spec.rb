require "rails_helper"

RSpec.describe ApiDocs::ProcessDocument do
  it "runs the MVP agent pipeline" do
    document = ApiDocument.create!(title: "Payments", source_type: :url, source_url: "https://example.com/docs")

    allow(ApiDocs::UrlContentFetcher).to receive(:call).and_return("List payments: GET /v1/payments")

    described_class.call(document)

    expect(document.reload).to be_completed
    expect(document.agent_executions.completed.count).to eq(3)
    expect(document.extracted_endpoints.count).to eq(1)
    expect(document.technical_study).to be_completed
  end

  it "marks the document as failed with a reason when an agent fails" do
    document = ApiDocument.create!(title: "Payments", source_type: :url, source_url: "https://example.com/docs")

    allow(ApiDocs::UrlContentFetcher).to receive(:call).and_raise(ApiDocs::UrlContentFetcher::Error, "blocked URL")

    expect do
      described_class.call(document)
    end.to raise_error(ApiDocs::UrlContentFetcher::Error)

    expect(document.reload).to be_failed
    expect(document.failure_reason).to eq("blocked URL")
    expect(document.agent_executions.failed.count).to eq(1)
  end

  it "clears previous extracted results before reprocessing" do
    document = ApiDocument.create!(title: "Payments", source_type: :url, source_url: "https://example.com/docs")
    document.extracted_endpoints.create!(http_method: "GET", path: "/old")
    document.create_technical_study!(status: :completed, summary: "Old", content: "Old")

    allow(ApiDocs::UrlContentFetcher).to receive(:call).and_return("GET /new")

    described_class.call(document)

    expect(document.extracted_endpoints.pluck(:path)).to eq([ "/new" ])
    expect(document.technical_study.summary).to include("1 extracted endpoint")
  end
end

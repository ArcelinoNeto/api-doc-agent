require "rails_helper"

RSpec.describe "API documents", type: :request do
  describe "POST /api/api_documents" do
    it "creates a URL document and enqueues processing" do
      expect do
        post "/api/api_documents", params: {
          api_document: {
            title: "Payments",
            source_type: "url",
            source_url: "https://example.com/docs"
          }
        }
      end.to have_enqueued_job(ApiDocs::ProcessDocumentJob)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to include("title" => "Payments", "status" => "pending")
    end
  end

  describe "GET /api/api_documents/:id/status" do
    it "returns processing status" do
      document = ApiDocument.create!(title: "Payments", source_type: :url, source_url: "https://example.com/docs")

      get "/api/api_documents/#{document.id}/status"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include("id" => document.id, "status" => "pending")
    end
  end

  describe "GET /api/api_documents/:id/technical_study" do
    it "returns the generated technical study" do
      document = ApiDocument.create!(title: "Payments", source_type: :url, source_url: "https://example.com/docs")
      study = document.create_technical_study!(status: :completed, summary: "Summary", content: "Content")

      get "/api/api_documents/#{document.id}/technical_study"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include("id" => study.id, "summary" => "Summary")
    end
  end
end

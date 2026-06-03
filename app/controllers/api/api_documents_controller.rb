module Api
  class ApiDocumentsController < ApplicationController
    before_action :set_api_document, only: %i[
      show
      status
      agent_executions
      extracted_endpoints
      technical_study
    ]

    def create
      api_document = ApiDocument.new(api_document_params)

      if api_document.save
        ApiDocs::ProcessDocumentJob.perform_later(api_document.id)
        render json: serialize_api_document(api_document), status: :created
      else
        render json: { errors: api_document.errors.to_hash(true) }, status: :unprocessable_entity
      end
    end

    def show
      render json: serialize_api_document(@api_document)
    end

    def status
      render json: {
        id: @api_document.id,
        status: @api_document.status,
        failure_reason: @api_document.failure_reason,
        processed_at: @api_document.processed_at
      }
    end

    def agent_executions
      render json: @api_document.agent_executions.order(:created_at).map { |execution| AgentExecutionSerializer.call(execution) }
    end

    def extracted_endpoints
      render json: @api_document.extracted_endpoints.order(:path, :http_method).map { |endpoint| ExtractedEndpointSerializer.call(endpoint) }
    end

    def technical_study
      study = @api_document.technical_study
      return render json: { error: "Technical study not found" }, status: :not_found unless study

      render json: TechnicalStudySerializer.call(study)
    end

    private

    def set_api_document
      @api_document = ApiDocument.find(params[:id])
    end

    def api_document_params
      params.require(:api_document).permit(:title, :source_type, :source_url, :pdf_file)
    end

    def serialize_api_document(api_document)
      ApiDocumentSerializer.call(api_document)
    end
  end
end

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
        processed_at: @api_document.processed_at
      }
    end

    def agent_executions
      render json: @api_document.agent_executions.order(:created_at).map { |execution| serialize_agent_execution(execution) }
    end

    def extracted_endpoints
      render json: @api_document.extracted_endpoints.order(:path, :http_method).map { |endpoint| serialize_extracted_endpoint(endpoint) }
    end

    def technical_study
      study = @api_document.technical_study
      return render json: { error: "Technical study not found" }, status: :not_found unless study

      render json: serialize_technical_study(study)
    end

    private

    def set_api_document
      @api_document = ApiDocument.find(params[:id])
    end

    def api_document_params
      params.require(:api_document).permit(:title, :source_type, :source_url, :pdf_file)
    end

    def serialize_api_document(api_document)
      {
        id: api_document.id,
        title: api_document.title,
        source_type: api_document.source_type,
        source_url: api_document.source_url,
        status: api_document.status,
        metadata: api_document.metadata,
        processed_at: api_document.processed_at,
        created_at: api_document.created_at,
        updated_at: api_document.updated_at,
        pdf_attached: api_document.pdf_file.attached?
      }
    end

    def serialize_agent_execution(execution)
      {
        id: execution.id,
        agent_name: execution.agent_name,
        status: execution.status,
        input: execution.input,
        output: execution.output,
        error_message: execution.error_message,
        started_at: execution.started_at,
        finished_at: execution.finished_at
      }
    end

    def serialize_extracted_endpoint(endpoint)
      {
        id: endpoint.id,
        http_method: endpoint.http_method,
        path: endpoint.path,
        description: endpoint.description,
        headers: endpoint.headers,
        query_params: endpoint.query_params,
        body_params: endpoint.body_params,
        response_examples: endpoint.response_examples,
        error_examples: endpoint.error_examples
      }
    end

    def serialize_technical_study(study)
      {
        id: study.id,
        status: study.status,
        summary: study.summary,
        content: study.content,
        created_at: study.created_at,
        updated_at: study.updated_at
      }
    end
  end
end

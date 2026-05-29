module Agents
  class TechnicalStudyAgent < BaseAgent
    private

    def perform
      endpoints = api_document.extracted_endpoints.order(:path, :http_method)
      study = api_document.technical_study || api_document.build_technical_study

      study.update!(
        status: :completed,
        summary: build_summary(endpoints),
        content: build_content(endpoints)
      )

      {
        "technical_study_id" => study.id,
        "endpoints_count" => endpoints.size
      }
    end

    def build_summary(endpoints)
      "Technical study generated for #{api_document.title} with #{endpoints.size} extracted endpoint(s)."
    end

    def build_content(endpoints)
      [
        "# #{api_document.title}",
        "",
        "## Authentication",
        "Pending automated analysis.",
        "",
        "## Endpoints",
        endpoint_lines(endpoints),
        "",
        "## Parameters",
        "Pending automated analysis.",
        "",
        "## Request and Response Examples",
        "Pending automated analysis.",
        "",
        "## Known Errors",
        "Pending automated analysis.",
        "",
        "## Points of Attention",
        "Validate authentication, pagination, rate limits, idempotency, and error handling before implementation.",
        "",
        "## Implementation Suggestions",
        "Create a small client layer, isolate API errors, add request specs, and keep credentials outside source control."
      ].join("\n")
    end

    def endpoint_lines(endpoints)
      return "No endpoints were extracted." if endpoints.empty?

      endpoints.map { |endpoint| "- #{endpoint.http_method} #{endpoint.path}" }.join("\n")
    end
  end
end

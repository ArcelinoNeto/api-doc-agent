module Agents
  class TechnicalStudyAgent < BaseAgent
    private

    def perform
      endpoints = api_document.extracted_endpoints.order(:path, :http_method)
      study = api_document.technical_study || api_document.build_technical_study
      result = generate_study(endpoints)

      study.update!(
        status: :completed,
        summary: result.fetch("summary"),
        content: result.fetch("content")
      )

      {
        "technical_study_id" => study.id,
        "endpoints_count" => endpoints.size,
        "generator" => result.fetch("generator")
      }
    end

    def generate_study(endpoints)
      client = Openai::Client.new
      return fallback_study(endpoints).merge("generator" => "local_fallback") unless client.available?

      response = client.structured_response(
        system: system_prompt,
        user: user_prompt(endpoints),
        schema: study_schema,
        name: "technical_study"
      )

      response.slice("summary", "content").merge("generator" => "openai")
    rescue Openai::Client::Error => error
      fallback_study(endpoints).merge(
        "generator" => "local_fallback",
        "openai_error" => error.message
      )
    end

    def fallback_study(endpoints)
      {
        "summary" => build_summary(endpoints),
        "content" => build_content(endpoints)
      }
    end

    def system_prompt
      <<~PROMPT
        You are a senior backend engineer creating implementation-oriented API documentation studies.
        Return only JSON that matches the provided schema.
      PROMPT
    end

    def user_prompt(endpoints)
      <<~PROMPT
        Create a technical study in English for this API documentation.

        Document title: #{api_document.title}

        Normalized documentation content:
        #{api_document.normalized_content.to_s.truncate(12_000)}

        Extracted endpoints:
        #{endpoint_lines(endpoints)}

        The study must cover authentication, endpoints, parameters, request/response examples,
        known errors, points of attention, and implementation suggestions.
      PROMPT
    end

    def study_schema
      {
        type: "object",
        additionalProperties: false,
        required: %w[summary content],
        properties: {
          summary: { type: "string" },
          content: { type: "string" }
        }
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

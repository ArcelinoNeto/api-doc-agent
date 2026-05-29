module Agents
  class EndpointExtractorAgent < BaseAgent
    ENDPOINT_PATTERN = %r{\b(GET|POST|PUT|PATCH|DELETE|OPTIONS|HEAD)\s+((?:/|\{base_url\}/)[^\s,;`"']+)}i

    private

    def perform
      extracted = extract_endpoints

      extracted.each do |attributes|
        api_document.extracted_endpoints.find_or_create_by!(
          http_method: attributes[:http_method],
          path: attributes[:path]
        ) do |endpoint|
          endpoint.description = attributes[:description]
        end
      end

      { "endpoints_count" => extracted.size }
    end

    def extract_endpoints
      api_document.normalized_content.to_s.scan(ENDPOINT_PATTERN).map do |method, path|
        normalized_path = path.sub(%r{\A\{base_url\}}, "")

        {
          http_method: method.upcase,
          path: normalized_path,
          description: "Endpoint extracted from API documentation."
        }
      end.uniq { |endpoint| [ endpoint[:http_method], endpoint[:path] ] }
    end
  end
end

require "json"
require "net/http"
require "uri"

module Openai
  class Client
    Error = Class.new(StandardError)

    API_URL = "https://api.openai.com/v1/responses"
    DEFAULT_MODEL = "gpt-4o-mini"
    OPEN_TIMEOUT = 5
    READ_TIMEOUT = 60

    def initialize(api_key: ENV["OPENAI_API_KEY"], model: ENV.fetch("OPENAI_MODEL", DEFAULT_MODEL))
      @api_key = api_key
      @model = model
    end

    def available?
      api_key.present?
    end

    def structured_response(system:, user:, schema:, name:)
      raise Error, "OPENAI_API_KEY is not configured" unless available?

      response = post_json(
        model: model,
        input: [
          { role: "system", content: system },
          { role: "user", content: user }
        ],
        text: {
          format: {
            type: "json_schema",
            name: name,
            strict: true,
            schema: schema
          }
        }
      )

      parse_output_text(response)
    end

    private

    attr_reader :api_key, :model

    def post_json(payload)
      uri = URI.parse(API_URL)

      Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT) do |http|
        request = Net::HTTP::Post.new(uri)
        request["Authorization"] = "Bearer #{api_key}"
        request["Content-Type"] = "application/json"
        request.body = payload.to_json

        response = http.request(request)
        body = JSON.parse(response.body)

        raise Error, body.dig("error", "message").presence || "OpenAI request failed with HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

        body
      end
    rescue JSON::ParserError => error
      raise Error, "OpenAI returned invalid JSON: #{error.message}"
    end

    def parse_output_text(response)
      text = response.fetch("output", []).flat_map { |item| item.fetch("content", []) }
                     .find { |content| content["type"] == "output_text" }
                     &.fetch("text", nil)

      raise Error, "OpenAI response did not include output text" if text.blank?

      JSON.parse(text)
    rescue JSON::ParserError => error
      raise Error, "OpenAI output was not valid JSON: #{error.message}"
    end
  end
end

require "rails_helper"

RSpec.describe Openai::Client do
  it "reports unavailable when the API key is blank" do
    expect(described_class.new(api_key: nil)).not_to be_available
  end

  it "parses structured output text from the Responses API" do
    http = instance_double(Net::HTTP)
    response = double(
      "response",
      code: "200",
      body: {
      output: [
        {
          content: [
            { type: "output_text", text: { summary: "Summary", content: "Content" }.to_json }
          ]
        }
      ]
      }.to_json
    )
    allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)

    allow(Net::HTTP).to receive(:start).and_yield(http)
    allow(http).to receive(:request).and_return(response)

    result = described_class.new(api_key: "token").structured_response(
      system: "Return JSON.",
      user: "Build a study.",
      name: "technical_study",
      schema: {
        type: "object",
        additionalProperties: false,
        required: %w[summary content],
        properties: {
          summary: { type: "string" },
          content: { type: "string" }
        }
      }
    )

    expect(result).to eq("summary" => "Summary", "content" => "Content")
  end
end

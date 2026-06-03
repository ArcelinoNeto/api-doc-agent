require "rails_helper"

RSpec.describe ApiDocs::UrlContentFetcher do
  it "fetches public HTTP content with timeouts" do
    http = instance_double(Net::HTTP)
    response = double("response", body: "GET /v1/payments")
    allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)

    allow(Resolv).to receive(:getaddresses).with("example.com").and_return([ "93.184.216.34" ])
    allow(Net::HTTP).to receive(:start).and_yield(http)
    allow(http).to receive(:request).and_return(response)

    content = described_class.call("https://example.com/docs")

    expect(content).to eq("GET /v1/payments")
    expect(Net::HTTP).to have_received(:start).with(
      "example.com",
      443,
      use_ssl: true,
      open_timeout: described_class::OPEN_TIMEOUT,
      read_timeout: described_class::READ_TIMEOUT
    )
  end

  it "blocks hosts that resolve to private addresses" do
    allow(Resolv).to receive(:getaddresses).with("internal.example").and_return([ "127.0.0.1" ])

    expect do
      described_class.call("https://internal.example/docs")
    end.to raise_error(described_class::Error, /private or local/)
  end

  it "rejects unsupported URL schemes" do
    expect do
      described_class.call("file:///etc/passwd")
    end.to raise_error(described_class::Error, /HTTP or HTTPS/)
  end
end

require "rails_helper"

RSpec.describe ApiDocument, type: :model do
  it "requires a source URL when source type is url" do
    document = described_class.new(title: "Payments", source_type: :url)

    expect(document).not_to be_valid
    expect(document.errors[:source_url]).to be_present
  end

  it "accepts a URL document with a source URL" do
    document = described_class.new(title: "Payments", source_type: :url, source_url: "https://example.com/docs")

    expect(document).to be_valid
  end

  it "rejects unsupported URL schemes" do
    document = described_class.new(title: "Payments", source_type: :url, source_url: "ftp://example.com/docs")

    expect(document).not_to be_valid
    expect(document.errors[:source_url]).to include("must be a valid HTTP or HTTPS URL")
  end

  it "requires a PDF attachment when source type is pdf" do
    document = described_class.new(title: "Payments", source_type: :pdf)

    expect(document).not_to be_valid
    expect(document.errors[:pdf_file]).to be_present
  end
end

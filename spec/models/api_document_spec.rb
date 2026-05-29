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
end

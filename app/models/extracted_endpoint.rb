class ExtractedEndpoint < ApplicationRecord
  HTTP_METHODS = %w[GET POST PUT PATCH DELETE OPTIONS HEAD].freeze

  belongs_to :api_document

  validates :http_method, presence: true, inclusion: { in: HTTP_METHODS }
  validates :path, presence: true, uniqueness: { scope: [ :api_document_id, :http_method ] }

  before_validation :normalize_http_method

  private

  def normalize_http_method
    self.http_method = http_method.to_s.upcase if http_method.present?
  end
end

class ExtractedEndpointSerializer
  def self.call(endpoint)
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
end

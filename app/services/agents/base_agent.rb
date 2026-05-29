module Agents
  class BaseAgent
    class AgentError < StandardError; end

    attr_reader :api_document, :input

    def initialize(api_document, input: {})
      @api_document = api_document
      @input = input
    end

    def execute
      execution = api_document.agent_executions.create!(
        agent_name: self.class.name,
        input: input,
        status: :running,
        started_at: Time.current
      )

      output = perform
      execution.update!(status: :completed, output: output, finished_at: Time.current)
      output
    rescue StandardError => error
      execution&.update!(
        status: :failed,
        error_message: error.message,
        finished_at: Time.current
      )
      raise
    end

    private

    def perform
      raise NotImplementedError, "#{self.class.name} must implement #perform"
    end
  end
end

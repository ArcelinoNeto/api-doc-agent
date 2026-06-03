class AgentExecutionSerializer
  def self.call(execution)
    {
      id: execution.id,
      agent_name: execution.agent_name,
      status: execution.status,
      input: execution.input,
      output: execution.output,
      error_message: execution.error_message,
      started_at: execution.started_at,
      finished_at: execution.finished_at
    }
  end
end

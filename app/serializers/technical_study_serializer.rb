class TechnicalStudySerializer
  def self.call(study)
    {
      id: study.id,
      status: study.status,
      summary: study.summary,
      content: study.content,
      created_at: study.created_at,
      updated_at: study.updated_at
    }
  end
end

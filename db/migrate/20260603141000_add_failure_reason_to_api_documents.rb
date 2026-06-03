class AddFailureReasonToApiDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :api_documents, :failure_reason, :text
  end
end

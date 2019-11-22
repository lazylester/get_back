class AddArchiveRetrievalJobIdToGlacierArchive < ActiveRecord::Migration[5.0]
  def change
    add_column :glacier_archives, :archive_retrieval_job_id, :string
  end
end

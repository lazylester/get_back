# GlacierArchive lifecycle:
# instance is created when AwsBackend#create_db_archive is invoked, status is 'available'
# when AwsBackend#retrieve_db_archive is invoked, status becomes 'pending'
# when AWS SNS notification is received (aws_sns_subscriptions_controller), status becomes 'ready'
# when AwsArchiveController#fetch is invoked by the user, and backup file is saved locally, status becomes 'local'
class GlacierArchive < ActiveRecord::Base
  scope :with_pending_retrieval, ->{ where("archive_retrieval_job_id is not null") }
  default_scope ->{ order("created_at asc") }

  LocalFileDir = Rails.root.join('tmp','aws')

  before_create do |archive|
    if resp = AwsBackend.new.create_db_archive
      archive.attributes = resp.to_h
    end
  end

  def initiate_retrieve_job
    if resp = AwsBackend.new.retrieve_db_archive(self)
      update_attribute(:archive_retrieval_job_id, resp[:job_id])
    end
  end


  def retrieval_status
    local_status || ready_status || pending_status || 'available'
  end

  private
  def local_filepath
    LocalFileDir.join(local_filename).to_s
  end

  def local_filename
    created_at.strftime("%Y_%m_%d_%H_%M_%S.gz")
  end

  # archive_retrieval job output has been retrieved
  def local_status
    'local' if File.exists? local_filepath
  end

  # ready to retrieve archive_retrieve job output
  def ready_status
    'ready' if notification
  end

  # archive_retrieve job has been initiated, but notification not yet received
  def pending_status
    'pending' if archive_retrieval_job_id
  end
end

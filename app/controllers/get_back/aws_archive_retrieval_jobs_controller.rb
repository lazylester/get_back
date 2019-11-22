class GetBack::AwsArchiveRetrievalJobsController < ApplicationController
  def create
    archive = GlacierArchive.find(params[:archive_id])
    AwsBackend.new.retrieve_db_archive(archive)
    @glacier_archives = GlacierArchive.all
    render :partial => 'glacier_archive', :collection => @glacier_archives, :as => :archive
  end
end

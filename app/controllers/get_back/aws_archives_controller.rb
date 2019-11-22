class GetBack::AwsArchivesController < ApplicationController
  def fetch
    AwsBackend.new.get_job_output(GlacierArchive.find(params[:archive_id]))
    @glacier_archives = GlacierArchive.all
    render :partial => 'glacier_archive', :collection => @glacier_archives, :as => :archive
  end

  def restore
    archive = GlacierArchive.find(params[:archive_id])
    if ApplicationDatabase.new.restore_from_file(archive.local_filepath)
      render :js => "flash.set('confirm_message', 'database restored');flash.notify();"
    else
      render :js => "flash.set('error_message', 'database restore failed');flash.notify();"
    end
  end
end

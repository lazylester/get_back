module GetBack
  class DbBackupsController < ApplicationController
    def index
      @backups = DbBackup.find(:all).sort
    end

    # creates a new backup file from the database
    def create
      backup = DbBackup.new # creates new DbBackup object with current date/time
      backup.save
      redirect_to backups_path
    end

    # restores the selected backup file (denoted by the passed-in param[:id]) to be the active database
    # the passed-in :id field is not the typical numeric table index but instead has the filename root, like:
    # "backups_2009-08-16_07-50-26_development_dump"
    def restore
      backfile = DbBackup.find(params[:backup_id])
      if write_db(backfile)
        flash[:notice] = "Database has been restored to backup version dated:<br/>#{backfile.date}"
      else
        flash[:error] ||= "Restore database failed<br/>file was probably corrupted."
      end
      redirect_to backups_path
    end

    def restore_from_upload
      if params[:upload][:uploaded_file].blank?
        flash[:error] = "Please click \"Browse\" to select a local database file to upload" # this should never be called, as the detection is now done in javascript at the client. Leave it here for posterity!
      else
        backfile = DbBackup.new(:filename=>uploaded_file_path)
        if write_db(backfile)
          flash[:notice] = "Database restored from uploaded file<br/>with date #{backfile.date}"
        else
          flash[:error] ||= "Database restore failed"
        end
      end
      redirect_to backups_path
    end

    def destroy
      db_backup = DbBackup.find(params[:id])
      if db_backup.destroy
        flash[:notice] = "Backup file was deleted"
      else
        flash[:error] = "Delete backup file failed"
      end
      redirect_to backups_path
    end

    # here "show" is used for REST conformance. Here we download the file instead of displaying it
    def show
      db_backup = DbBackup.find(params[:id])
      send_file db_backup.filename, :type => 'text/plain'
    end

    private

    # overwrites the active database with the file passed in
    def write_db(backfile)
      if backfile.valid?
        ApplicationDatabase.restore_from_compressed_file(backfile) # returns false if restore fails
      else
        flash[:error] = "File name does not have correct format.<br/>Are you sure it's a database backup file?<br/>Database was not restored."
        false
      end
    end

    def uploaded_file_path
      filename = params[:upload][:uploaded_file].original_filename
      directory = "tmp/uploads"
      path = File.join(directory, filename)
      File.open(path,"wb"){|f| f.write(params[:upload][:uploaded_file].read)}
      Rails.root.join(path)
    end

  end
end

class BackupMailer < ActionMailer::Base
  def db_backup(zipfile)
    mail(:to => BACKUP_RECIPIENTS,
         :from => "#{ORGANIZATION_NAME} Database Administrator<#{ADMIN_EMAIL}>",
         :headers => ["Reply-to" => "#{ADMIN_EMAIL}",
                      "Message-ID"=>"<#{DateTime.now.to_formatted_s(:number)}@#{SITE_URL}>"],
         :subject => "#{ORGANIZATION_NAME} daily backup file",
         :attachments => {DateTime.now.to_formatted_s(:db)+"_production_backup.zip" =>
                               {:mime_type => "application/x-gzip", :content => zipfile}}
         )
  end
end

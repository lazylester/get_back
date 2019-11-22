desc "Send email with daily backup"
task :email_backup => "db:backup" do
  puts "sending backup file by email"
  backfile = DbBackup.most_recent
  BackupMailer.db_backup(backfile.gzipped).deliver
end

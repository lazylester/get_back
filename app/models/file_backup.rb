class FileBackup
  def self.create
    files = Dir.glob(Rails.root.join(GetBack::Engine::SharedFilesDirectory,'uploads','*'))
    File.open(Rails.root.join(GetBack::Engine::TempDirectory, "file_backup.zip"), 'wb') do |f|
      f.write ActiveSupport::Gzip.compress(files)
    end
  end
end

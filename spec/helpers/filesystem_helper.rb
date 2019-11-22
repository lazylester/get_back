require 'rspec/core/shared_context'
module FilesystemHelper
  extend RSpec::Core::SharedContext

  def create_filesystem_to_backup
    FileUtils.makedirs(Rails.root.join(GetBack::Engine::SharedFilesDirectory,"uploads"))
    FileUtils.touch(Rails.root.join(GetBack::Engine::SharedFilesDirectory,"uploads","boo_bar_baz.doc"))
    FileUtils.touch(Rails.root.join(GetBack::Engine::SharedFilesDirectory,"uploads","bish_bash_bosh.doc"))
  end

  def clean_up_filesystem
    FileUtils.rm(Dir.glob(Rails.root.join(GetBack::Engine::SharedFilesDirectory,"uploads","*")))
    FileUtils.rm(Rails.root.join(GetBack::Engine::TempDirectory,'file_backup.zip'))
  end

end

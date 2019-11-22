require 'spec_helper'
require_relative '../helpers/filesystem_helper'

describe 'backup_files' do
include FilesystemHelper
  before do
    create_filesystem_to_backup
    FileBackup.create
  end

  it "should create the shared files directory structure" do
    expect(File.exists?(File.new(Rails.root.join(GetBack::Engine::SharedFilesDirectory, "uploads","boo_bar_baz.doc")))).to eq true
    expect(File.exists?(File.new(Rails.root.join(GetBack::Engine::SharedFilesDirectory, "uploads","bish_bash_bosh.doc")))).to eq true
    expect(File.exists?(File.new(Rails.root.join(GetBack::Engine::TempDirectory, "file_backup.zip")))).to eq true
  end

  after do
    clean_up_filesystem
  end
end

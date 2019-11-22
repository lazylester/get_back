require 'spec_helper'
require_relative '../helpers/aws_helper'

describe 'GlacierArchive.create' do
  include AwsHelper
    before do
      get_vault_list_request
      create_vault_request
      upload_archive_post
      @glacier_archive = GlacierArchive.create
    end

    it 'should create instance of GlacierArchive in the database' do
      expect(get_vault_list_request).to have_been_requested.once
      expect(create_vault_request).to have_been_requested.once
      expect(upload_archive_post).to have_been_requested.once

      expect(@glacier_archive.archive_id).not_to be_nil
      expect(@glacier_archive.checksum).not_to be_nil
      expect(@glacier_archive.location).not_to be_nil
      expect(@glacier_archive.retrieval_status).to eq 'available'
    end
end

describe 'GlacierArchive.initiate_retrieve_job' do
  include AwsHelper
    before do
      get_vault_list_request
      create_vault_request
      upload_archive_post
      @glacier_archive = GlacierArchive.create
      @glacier_archive.initiate_retrieve_job
    end

    it "should send archive retrieval job initiation request" do
      expect(initiate_retrieve_job).to have_been_requested.once
    end
  
end

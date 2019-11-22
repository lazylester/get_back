require 'rspec/core/shared_context'

module AwsHelper
  extend RSpec::Core::SharedContext
  #get vault list
  def get_vault_list_request
    stub_request(:get, "https://glacier.us-east-1.amazonaws.com/-/vaults").
       to_return(:status => 200, :body =>"{ \"VaultList\": [{ \"CreationDate\": \"2015-04-06 21:23:45 UTC\", \"LastInventoryDate\": \"2015-04-07 00:26:19 UTC\", \"NumberOfArchives\": 1, \"SizeInBytes\": 3178496, \"VaultArn\": \"arn:aws:glacier:us-west-2:0123456789012:vaults/my-vault\", \"VaultName\": \"my-vault\" }]}")
  end

  def create_vault_request
    stub_request(:put, "https://glacier.us-east-1.amazonaws.com/-/vaults/OZ").
       to_return(status: 200, body: "", headers: {})
  end

  def upload_archive_post
    upload_response = "{
      \"archiveId\": \"kKB7ymWJVpPSwhGP6ycSOAekp9ZYe_--zM_mw6k76ZFGEIWQX-ybtRDvc2VkPSDtfKmQrj0IRQLSGsNuDp-AJVlu2ccmDSyDUmZwKbwbpAdGATGDiB3hHO0bjbGehXTcApVud_wyDw\",
      \"checksum\": \"969fb39823836d81f0cc028195fcdbcbbe76cdde932d4646fa7de5f21e18aa67\",
      \"location\": \"/0123456789012/vaults/my-vault/archives/kKB7ymWJVpPSwhGP6ycSOAekp9ZYe_--zM_mw6k76ZFGEIWQX-ybtRDvc2VkPSDtfKmQrj0IRQLSGsNuDp-AJVlu2ccmDSyDUmZwKbwbpAdGATGDiB3hHO0bjbGehXTcApVud_wyDw\"
    }"

    upload_archive_post = stub_request(:post, "https://glacier.us-east-1.amazonaws.com/-/vaults/OZ/archives").
      to_return(status: 200, body:upload_response, headers:{'x-amz-archive-id':'foo', 'x-amz-sha256-tree-hash':'bar', 'Location':'bosh'})
  end

end

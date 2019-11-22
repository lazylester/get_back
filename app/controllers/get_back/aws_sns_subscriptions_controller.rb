require 'httparty'

module GetBack
  class AwsSnsSubscriptionsController < ApplicationController
    class MessageWasNotAuthentic < StandardError; end

    skip_before_action :verify_authenticity_token, :check_permissions, :only=>[:create]
    def create
      if request.headers["x-amz-sns-message-type"] == "SubscriptionConfirmation" # AWS sends a post to confirm subscription to notifications
        subscribe_url = JSON.parse(request.raw_post)["SubscribeURL"]
        raise MessageWasNotAuthentic unless subscribe_url =~ /^https.*amazonaws\.com\//
        HTTParty.get subscribe_url # confirms subscription
        head :ok
      else # this is the notification from AWS Glacier that the retrieval job is completed
        # capture the response to a file while developing, so we can see what's coming in
        File.open(Rails.root.join('tmp','notification.txt'),'w') do |file|
          file.write(request.raw_post)
        end
        # the notification that the retrieve_archive job has completed
        message = JSON.parse(request.raw_post)["Message"]
        json_message = JSON.parse(message)
        job_id = json_message["JobId"]
        glacier_archive = GlacierArchive.find_by(:archive_retrieval_job_id => job_id)
        glacier_archive.update_attributes(:notification => json_message) if glacier_archive
        head :ok
      end
    end
  end
end

# Notification example, note that message is a string and must be parsed by JSON.parse
# {
#   "Type" : "Notification",
#   "MessageId" : "b221d7d9-73c3-5e6d-9caf-8649cb198736",
#   "TopicArn" : "arn:aws:sns:us-east-1:918359762546:retrieve_archive",
#   "Message" : "{\"Action\":\"ArchiveRetrieval\",\"ArchiveId\":\"_vs0qWot3GIg7I3bsBomHTheu73qNkCW28_B1hKjXhvOMR5vh7rGQs4Ra_UEYdXCA1N6-F8aF-lN7SMqLl6pRyy7HX6mA0DPwhpXSPoOA7FixG1roXtx7O7QN8gFiz_GAyMR8OeqpQ\",\"ArchiveSHA256TreeHash\":\"0c47aee75a9587d83648fc1ea05d52646a67f704fbd23952c134d89776eccbe6\",\"ArchiveSizeInBytes\":285544,\"Completed\":true,\"CompletionDate\":\"2017-05-13T07:32:42.098Z\",\"CreationDate\":\"2017-05-13T03:40:19.264Z\",\"InventoryRetrievalParameters\":null,\"InventorySizeInBytes\":null,\"JobDescription\":\"put anything here\",\"JobId\":\"krCLWk6m7NJWppiy2SxdhP60f98PdrdaZBfhdDTZufrAkoh-ikrvb_NA0Q1vg2WcAhzZLL92kiwjOijUEDh0U7X09YQK\",\"RetrievalByteRange\":\"0-285543\",\"SHA256TreeHash\":\"0c47aee75a9587d83648fc1ea05d52646a67f704fbd23952c134d89776eccbe6\",\"SNSTopic\":\"arn:aws:sns:us-east-1:918359762546:retrieve_archive\",\"StatusCode\":\"Succeeded\",\"StatusMessage\":\"Succeeded\",\"Tier\":\"Standard\",\"VaultARN\":\"arn:aws:glacier:us-east-1:918359762546:vaults/demo\"}",
#   "Timestamp" : "2017-05-13T07:32:42.229Z",
#   "SignatureVersion" : "1",
#   "Signature" : "i95PuF62vsfsrViAbgeHWP8vxZCzX+wMhUi4c8oveMkKT9PqmCXhQT6Jza86NCYMOOoxs8avUKE0mjuLlcrYqS6Iw3wLrx0P3Op/OJy2OQMelBp7nlWWvJpkRnsvY5EOpZF0auvsbsBLUrxgkoPAfP6/B3rO2BZubsu28fA0Qq4/Gzp2tM2U50NmggvRoD7Trt4usrgh8GCQ4iDr7Ce7jrxRglUgKA6/I4frlJG4l/bBwm6h5VzQgwO2xylPyaOSL2IIjiwcXeEwsYw8rGR2Qf+6/yLh4OiYxyp2X58MJSB4B7cenvziS+R95LC45LJrfmk3lK8x3L9xFPZPNjwzeA==",
#   "SigningCertURL" : "https://sns.us-east-1.amazonaws.com/SimpleNotificationService-b95095beb82e8f6a046b3aafc7f4149a.pem",
#   "UnsubscribeURL" : "https://sns.us-east-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-east-1:918359762546:retrieve_archive:fb8925ed-cc03-4f60-8301-27a4d5ad36d8"
# }

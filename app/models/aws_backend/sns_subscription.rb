class AwsBackend
  class SnsSubscription
    attr_accessor :resp
    # format is:   "arn:aws:sns:region:account-id:topicname"
    # see http://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html#arn-syntax-glacier
    Topic_ARN = "arn:aws:sns:#{AwsBackend::Region}:#{::AWS_ACCOUNT_ID}:retrieve_archive"
    #Resource_ARN = ""

    def initialize
      client = Aws::SNS::Client.new(:region => AwsBackend::Region, :credentials => credentials)
      sns = Aws::SNS::Resource.new(region:AwsBackend::Region)

      topic = sns.create_topic(name: 'retrieve_archive')
      topic.set_attributes({
        attribute_name: "Policy",
        attribute_value: policy
      })

      @resp = client.subscribe({
        topic_arn: Topic_ARN,
        protocol: "https", # required
        endpoint: GetBack::Engine.routes.url_helpers.aws_subscription_notify_url
      })
    rescue Exception => e
      puts "AWS Error: #{e.message}"
      #puts e.backtrace.inspect
      # Rescue
    end

    private
    def credentials
      Aws::SharedCredentials.new(:profile_name => AwsBackend::ProfileName)
    end

    def policy
      # see http://docs.aws.amazon.com/sdk-for-ruby/v2/developer-guide/sns-example-enable-resource.html
      "{
        'Version':'2014-05-06',
        'Id':'__default_policy_ID',
        'Statement':[{
          'Sid':'__default_statement_ID',
          'Effect':'Allow',
          'Principal':{
            'AWS':'*'
          },
          'Action':['SNS:Publish'],
          'Resource':'#{Topic_ARN}',
          'Condition':{
            'ArnEquals':{
              'AWS:SourceArn': #{Resource_ARN}}
           }
        }]
      }"
    end
  end
end

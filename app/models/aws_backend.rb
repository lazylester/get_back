class AwsBackend
  class ArchiveRetrievalNotPending < StandardError; end
  class ArchiveRetrievalNotReady < StandardError; end

  Region = 'us-east-1'
  ProfileName = 'default'

  attr_accessor :glacier

  def initialize
    @glacier = Aws::Glacier::Client.new(:region => Region, :credentials => AwsBackend.credentials)
    unless vault_list.map(&:vault_name).include?(::SITE_NAME)
      @glacier.create_vault({:account_id => "-", :vault_name => ::SITE_NAME})
    end
  end

  def self.credentials
    Aws::SharedCredentials.new(:profile_name => ProfileName)
  end

  def vault_list
    vault_list_info = @glacier.list_vaults({:account_id => "-"})
    vault_list_info.vault_list
  end

  def create_file_archive
    # create an aws archive that contains all the docs saved by the refile gem
  end

  def create_db_archive
    db = ApplicationDatabase.new
    archive_contents = db.zipped_contents
    description = "backup of postgres database"
    begin
      resp = glacier.upload_archive({
        account_id: "-",
        archive_description: description,
        body: archive_contents,
        checksum: checksum(archive_contents),
        vault_name: ::SITE_NAME,
      })
    rescue Aws::Glacier::Errors::ServiceError
      puts "Aws::Glacier error, archive not saved" # for now do this, later something else
    end
  end

  # archive is a GlacierArchive instance from the database
  def retrieve_db_archive(archive)
    resp = glacier.initiate_job({ account_id: "-", # required
                                  vault_name: ::SITE_NAME, # required
                                  job_parameters: {
                                    #format: "string", # we don't specify output format, take what we get
                                    type: "archive-retrieval", # valid types are "archive-retrieval" and "inventory-retrieval"
                                    archive_id: archive.archive_id,
                                    description: "put anything here",
                                    sns_topic: SnsSubscription::Topic_ARN,
                                    #retrieval_byte_range: "string",
                                    tier: "Standard"# it's the default, but put it here to be explicit
                                    #inventory_retrieval_parameters: {
                                      #start_date: Time.now,
                                      #end_date: Time.now,
                                      #limit: "string",
                                      #marker: "string",
                                    #}
                                  }
                                })

    # while in development, capture to file so we can see what is coming in
    #File.open(Rails.root.join('tmp','retrieve_archive_response.txt'),'w') do |file|
      #file.write resp
    #end

    #archive.update_attribute(:archive_retrieval_job_id, resp[:job_id])

    #response looks like this:
    #<struct Aws::Glacier::Types::InitiateJobOutput location="/918359762546/vaults/demo/jobs/krCLWk6m7NJWppiy2SxdhP60f98PdrdaZBfhdDTZufrAkoh-ikrvb_NA0Q1vg2WcAhzZLL92kiwjOijUEDh0U7X09YQK", job_id="krCLWk6m7NJWppiy2SxdhP60f98PdrdaZBfhdDTZufrAkoh-ikrvb_NA0Q1vg2WcAhzZLL92kiwjOijUEDh0U7X09YQK">
  end

  # archive is a GlacierArchive instance from the database
  def get_job_info(archive)
    glacier.describe_job({:account_id => '-',
                          :vault_name => ::SITE_NAME,
                          :job_id => archive.archive_retrieval_job_id})
  end

  # archive is a GlacierArchive instance from the database
  def get_job_output(archive)
    raise ArchiveRetrievalNotReady unless retrieval_ready? archive
    glacier.get_job_output({
      :response_target => filepath(archive),
      :account_id => '-',
      :vault_name => ::SITE_NAME,
      :job_id => archive.archive_retrieval_job_id
    })
  end

  # archive is a GlacierArchive instance from the database
  def retrieval_ready?(archive)
    job_info = get_job_info(archive)
    job_info.completed
  end

  private

  def checksum(contents)
    tree_hash = Aws::TreeHash.new
    tree_hash.update(contents)
    tree_hash.digest
  end

  def filepath(archive)
    path = archive.local_filepath
    FileUtils.makedirs(File.dirname(path))
    path
  end

end

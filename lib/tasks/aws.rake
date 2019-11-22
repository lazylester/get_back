namespace :aws do
  desc "create and save to aws glacier a copy of the postgres database"
  task :create_db_archive => :environment do
    AwsBackend.new.create_db_archive
  end
end

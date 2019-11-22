# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rspec/rails'
require 'byebug'
require 'webmock/rspec'
include WebMock::API

ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')
DbBackup::BACKUP_DIR = Rails.root.join('tmp')
# this is intended to be the Capistrano shared files directory.
# in development we store them in tmp
# in production it's typically at ../shared
GetBack::Engine::SharedFilesDirectory = Rails.root.join('tmp','shared')
GetBack::Engine::TempDirectory = Rails.root.join('tmp')

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }

RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false # apparently pg_dump cannot run while there is a transaction active

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

end

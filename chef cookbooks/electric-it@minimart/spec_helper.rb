begin
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
rescue LoadError
end

begin; require 'pry'; rescue LoadError; end

require 'dotenv'
Dotenv.load
require 'rspec'
require 'vcr'
require 'webmock/rspec'

require 'minimart'
require 'minimart/commands/mirror'
require 'minimart/commands/web'

Dir['spec/support/*.rb'].each { |f| require File.expand_path(f) }

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
end

RSpec.configure do |config|
  config.include Minimart::RSpecSupport::FileSystem

  config.before(:each) { make_test_directory }
  config.after(:each) { remove_test_directory }

  config.mock_with :rspec

  Minimart::Configuration.output = StringIO.new
end

require 'rubygems'
require 'bundler'

Bundler.require(:default, :test)

require File.join(File.dirname(__FILE__), '..', 'lib/fifthgear_integration')
require File.join(File.dirname(__FILE__), '..', 'fifthgear_endpoint')

Dir["./spec/support/**/*.rb"].each { |f| require f }

require 'spree/testing_support/controllers'

Sinatra::Base.environment = 'test'

ENV['FIFTHGEAR_USERNAME'] ||= 'user'
ENV['FIFTHGEAR_PASSWORD'] ||= 'passwd'
ENV['FIFTHGEAR_COMPANYID'] ||= 'companyid'

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = false
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock

  c.filter_sensitive_data("FIFTHGEAR_USERNAME") { ENV["FIFTHGEAR_USERNAME"] }
  c.filter_sensitive_data("FIFTHGEAR_PASSWORD") { ENV["FIFTHGEAR_PASSWORD"] }
  c.filter_sensitive_data("FIFTHGEAR_COMPANYID") { ENV["FIFTHGEAR_COMPANYID"] }
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Spree::TestingSupport::Controllers
end

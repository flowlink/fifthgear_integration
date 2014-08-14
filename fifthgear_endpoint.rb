require "sinatra"
require "endpoint_base"

require File.expand_path(File.dirname(__FILE__) + '/lib/fifthgear_integration')

class FifthGearEndpoint < EndpointBase::Sinatra::Base
  post "/add_order" do
    order = FifthGearIntegration::Order.new(@config, @payload).post!
    result 200, "Order successfully placed in FifthGear. Receipt #{order[:receipt]}"
  end
end

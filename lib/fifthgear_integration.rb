$:.unshift File.dirname(__FILE__)

require 'fifthgear'

module FifthGearIntegration
  class Base
    def initialize(config, payload = {})
      if config[:fifthgear_production]
        FifthGear.base_uri "https://commerceservices.infifthgear.com/v2.0/CommerceServices.svc/Rest"
      else
        FifthGear.base_uri "https://commerceservicestest.infifthgear.com/v2.0/CommerceServices.svc/Rest"
      end

      FifthGear.basic_auth config[:fifthgear_username], config[:fifthgear_password]
      FifthGear.company_id config[:fifthgear_company_id]
    end
  end

  class InvalidShipCodeError < StandardError; end
end

require 'fifthgear_integration/order'
require 'fifthgear_integration/inventory'
require 'fifthgear_integration/shipment'

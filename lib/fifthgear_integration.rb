$:.unshift File.dirname(__FILE__)

require 'fifthgear'

module FifthGearIntegration
  class Base
    attr_reader :config

    def initialize(config, payload = {})
      @config = config

      if config[:fifthgear_production].to_s == "true" || config[:fifthgear_production].to_s == "1"
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

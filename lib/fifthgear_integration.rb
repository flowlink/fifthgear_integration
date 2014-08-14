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

  class Helper
    class << self
      # All dates need to be passed in the .NET serialized date format
      # See http://stackoverflow.com/questions/17315394/how-to-format-a-php-date-in-net-datacontractjsonserializer-format
      # for PHP where logic was taken
      def dotnet_date_contract(date_string)
        time = Time.parse date_string
        "/Date(#{time.to_i * 1000}#{time.utc_offset})/"
      end
    end
  end
end

require 'fifthgear_integration/order'

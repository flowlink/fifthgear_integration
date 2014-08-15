require 'spec_helper'

describe FifthGear do
  let(:cart_order) do
    JSON.parse(IO.read("#{File.dirname(__FILE__)}/support/samples/cart_submit.json"))
  end

  subject { described_class }

  before(:all) do
    FifthGear.base_uri ENV['FIFTHGEAR_URL']
    FifthGear.basic_auth ENV['FIFTHGEAR_USERNAME'], ENV['FIFTHGEAR_PASSWORD']
    FifthGear.company_id ENV['FIFTHGEAR_COMPANYID']
  end

  it "fetches inventory" do
    VCR.use_cassette("inventory/bulk") do
      inventories = subject.item_inventory_bulk_lookup

      expect(inventories.count).to be >= 1
      expect(inventories.first[:sku]).to be
    end
  end

  it "places an order" do
    number = cart_order["Request"]["OrderReferenceNumber"] = "R3243243498"

    VCR.use_cassette("orders/#{number}") do
      response = subject.cart_submit cart_order
    end
  end

  it "looks up order statuses" do
    options = {
      "Request" => nil,
      "FromDate" => FifthGear::Helper.dotnet_date_contract("2000-01-03T17:29:15.219Z"),
      "ToDate" => FifthGear::Helper.dotnet_date_contract("2014-08-14T17:29:15.219Z"),
      "StartRange" => 1,
      "EndRange" => 25
    }

    VCR.use_cassette("orders/bulk") do
      response = subject.order_status_bulk_lookup options
      expect(response.count).to be >= 0
    end
  end

  describe FifthGear::Helper do
    it "converts date to dotnet format" do
      date = "2014-02-03T17:29:15.219Z"
      dotnet = described_class.dotnet_date_contract date
      expect(dotnet).to match "Date"
    end
  end
end

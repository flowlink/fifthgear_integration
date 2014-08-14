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
    VCR.use_cassette("inventory/bulks") do
      inventories = subject.inventory_bulk_lookup

      expect(inventories.count).to be >= 1
      expect(inventories.first["ItemNumber"]).to be
    end
  end

  it "places an order" do
    number = cart_order["Request"]["OrderReferenceNumber"] = "R3243243498"

    VCR.use_cassette("orders/#{number}") do
      response = subject.cart_submit cart_order
    end
  end

  it "looks up order statuses" do
    VCR.use_cassette("orders/bulk") do
      response = subject.order_status_bulk_lookup
    end
  end
end

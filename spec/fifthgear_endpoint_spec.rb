require 'spec_helper'

describe FifthGearEndpoint do
  let(:config) do
    {
      fifthgear_production: false,
      fifthgear_username: ENV['FIFTHGEAR_USERNAME'],
      fifthgear_password: ENV['FIFTHGEAR_PASSWORD'],
      fifthgear_company_id: ENV['FIFTHGEAR_COMPANYID']
    }
  end

  let(:order) do
    JSON.parse(IO.read("#{File.dirname(__FILE__)}/support/samples/order.json")).with_indifferent_access
  end

  it "places an order" do
    order[:id] = "R435245787896RGDGFS"
    payload = { order: order, parameters: config }

    VCR.use_cassette("orders/#{order[:id]}") do
      post "/add_order", payload.to_json, auth
      expect(last_response.status).to eq 200
    end
  end

  it "fetches inventory" do
    payload = {
      parameters: config.merge(fifthgear_startrange: 1, fifthgear_endrange: 5)
    }

    VCR.use_cassette("inventory/bulk_lookup") do
      post "/get_inventory", payload.to_json, auth

      expect(last_response.status).to eq 200
      expect(json_response[:inventories].count).to be >= 1

      expect(json_response[:parameters]).to have_key "fifthgear_startrange"
      expect(json_response[:parameters]).to have_key "fifthgear_endrange"
    end
  end

  it "fetches single inventory record" do
    payload = { inventory: { sku: "BDVQ-1.2101G" }, parameters: config }

    VCR.use_cassette("inventory/single_lookup") do
      post "/get_inventory", payload.to_json, auth
      expect(last_response.status).to eq 200
      expect(json_response[:inventories].count).to eq 1
      expect(json_response[:parameters]).to eq nil
    end
  end

  it "fetches order updates 0 results" do
    payload = {
      parameters: config.merge(fifthgear_orders_since: "2014-08-21T14:58:56-00:00")
    }

    VCR.use_cassette("orders/bulk_lookup") do
      post "/get_shipments", payload.to_json, auth
      expect(last_response.status).to eq 200
      expect(json_response[:parameters][:fifthgear_orders_since]).to be_present
    end
  end

  # api no longer returns any result, contact their team
  pending "fetches order updates with results" do
    payload = {
      parameters: config.merge(fifthgear_orders_since: "2014-01-21T14:58:56-00:00")
    }

    VCR.use_cassette("orders/bulk_results") do
      post "/get_shipments", payload.to_json, auth
      expect(last_response.status).to eq 200
      expect(json_response[:shipments].count).to be >= 1
    end
  end
end

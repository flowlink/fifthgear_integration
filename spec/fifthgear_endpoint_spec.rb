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
    order[:id] = "R4359ERGRG435325"
    payload = { order: order, parameters: config }

    VCR.use_cassette("orders/#{order[:id]}") do
      post "/add_order", payload.to_json, auth
      expect(last_response.status).to eq 200
    end
  end
end

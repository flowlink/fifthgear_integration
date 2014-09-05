require 'spec_helper'

describe FifthGear do
  let(:cart_order) do
    JSON.parse(IO.read("#{File.dirname(__FILE__)}/support/samples/cart_submit.json"))
  end

  subject { described_class }

  describe FifthGear::Helper do
    it "converts date to dotnet format" do
      date = "2014-02-03T17:29:15.219Z"
      dotnet = described_class.dotnet_date_contract date
      expect(dotnet).to match "Date"
    end
  end
end

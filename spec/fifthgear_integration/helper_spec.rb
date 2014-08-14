require 'spec_helper'

module FifthGearIntegration
  describe Helper do
    it "converts date to dotnet format" do
      date = "2014-02-03T17:29:15.219Z"
      dotnet = described_class.dotnet_date_contract date
      expect(dotnet).to match "Date"
    end
  end
end

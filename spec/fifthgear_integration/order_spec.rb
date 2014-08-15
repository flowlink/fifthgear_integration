require 'spec_helper'

module FifthGearIntegration
  describe Order do
    subject { described_class.new({}) }

    it "country code default to USA" do
      expect(subject.country_code "USA").to eq 231
      expect(subject.country_code "NONONONO").to eq 231
      expect(subject.country_code "AFG").to eq 1
    end

    it "state code default to 0" do
      expect(subject.state_code "California").to eq 13
      expect(subject.state_code "NONONONONO").to eq 0
    end

    it "ship code defaults to FDXOS (Next Day)" do
      expect(subject.ship_code nil).to eq "FDXOS"
      expect(subject.ship_code "FDXOS").to eq "FDXOS"
    end

    it "raise if given invalid ship code" do
      expect {
        subject.ship_code "WRONG"
      }.to raise_error InvalidShipCodeError
    end
  end
end

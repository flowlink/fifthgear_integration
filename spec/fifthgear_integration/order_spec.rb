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

    it "maps 2 digit state code as well" do
      expect(subject.state_code "QC").to eq 72
    end
  end
end

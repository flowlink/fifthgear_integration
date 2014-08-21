require 'spec_helper'

module FifthGearIntegration
  describe Inventory do
    subject { described_class.new config, {} }

    it "resets ranges properly" do
      config = { fifthgear_startrange: 1, fifthgear_endrange: 100 }
      subject = described_class.new config, {}
      subject.collection = [1]

      expect(subject.next_start).to eq 101
      expect(subject.next_end).to eq 200

      config = { fifthgear_startrange: 101, fifthgear_endrange: 200 }
      subject = described_class.new config, {}
      subject.collection = [1]

      expect(subject.next_start).to eq 201
      expect(subject.next_end).to eq 300

      config = { fifthgear_startrange: 201, fifthgear_endrange: 300 }
      subject = described_class.new config, {}
      subject.collection = []

      expect(subject.next_start).to eq 1
      expect(subject.next_end).to eq 100
    end
  end
end

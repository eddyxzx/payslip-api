require 'rails_helper'

RSpec.describe ProgressiveTaxCalculator do
  describe '#annual_tax' do
    it 'taxes a 60000 salary as 6000 (sample 1)' do
      expect(ProgressiveTaxCalculator.new.annual_tax(60000)).to eq(6000)
    end

    it 'taxes a 200000 salary as 48000 (sample 2)' do
      expect(ProgressiveTaxCalculator.new.annual_tax(200000)).to eq(48000)
    end

    it 'taxes a 80150 salary as 10045 (sample 3)' do
      expect(ProgressiveTaxCalculator.new.annual_tax(80150)).to eq(10045)
    end

    it 'taxes income within the tax-free bracket as 0' do
      expect(ProgressiveTaxCalculator.new.annual_tax(20000)).to eq(0)
    end
  end

  describe '#breakdown' do
    it 'returns each bracket with its range, rate and tax' do
      breakdown = ProgressiveTaxCalculator.new.breakdown(60000)

      expect(breakdown).to include(
        { range: "0-20000", rate: "0%", tax: "0.00" },
        { range: "20001-40000", rate: "10%", tax: "2000.00" },
        { range: "40001-80000", rate: "20%", tax: "4000.00" }
      )
    end
  end
end

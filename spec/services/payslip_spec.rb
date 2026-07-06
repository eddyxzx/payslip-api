require 'rails_helper'

RSpec.describe Payslip do
  it 'calculates the gross monthly income (annual salary / 12)' do
    payslip = Payslip.new("Ren", 60000)
    expect(payslip.gross_monthly_income).to eq(5000.00)
  end

  it 'calculates the monthly income tax (annual tax / 12)' do
    payslip = Payslip.new("Ren", 60000)
    expect(payslip.monthly_income_tax).to eq(500.00)
  end

  it 'calculates the net monthly income (gross - tax)' do
    payslip = Payslip.new("Ren", 60000)
    expect(payslip.net_monthly_income).to eq(4500.00)
  end

    it 'formats each line with a dollar sign and two decimals' do
    payslip = Payslip.new("Ren", 60000)
    output = payslip.to_s

    expect(output).to include('Monthly Payslip for: "Ren"')
    expect(output).to include('Gross Monthly Income: $5000.00')
    expect(output).to include('Monthly Income Tax: $500.00')
    expect(output).to include('Net Monthly Income: $4500.00')
  end
end

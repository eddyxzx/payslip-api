# console logss
module Payroll
  def self.generate_monthly_payslip(name, annual_salary)
    payslip = Payslip.new(name, annual_salary)
    puts payslip     # puts calls payslip.to_s
    payslip          # return it to api
  end
end

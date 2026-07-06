class SalaryComputation < ApplicationRecord
  validates :employee_name, presence: true
  validates :annual_salary, numericality: { greater_than: 0 }

  def to_listing
    {
      time_stamp: created_at.iso8601,
      employee_name: employee_name,
      annual_salary: annual_salary.to_s,
      monthly_income_tax: format("%.2f", monthly_income_tax)
    }
  end
end

# Builds a monthly payslip for one person, based on their annual salary.
class Payslip
  MONTHS_IN_YEAR = 12

  attr_reader :name, :annual_salary

  def initialize(name, annual_salary, calculator = ProgressiveTaxCalculator.new)
    @name = name
    @annual_salary = annual_salary
    @calculator = calculator
  end

  def gross_monthly_income
    (annual_salary / MONTHS_IN_YEAR.to_f).round(2)
  end

  def monthly_income_tax
    annual_tax = @calculator.annual_tax(annual_salary)
    (annual_tax / MONTHS_IN_YEAR.to_f).round(2)
  end

  def net_monthly_income
    (gross_monthly_income - monthly_income_tax).round(2)
  end

  def to_s
    [
      " Monthly Payslip for: \"#{name}\"",
      " Gross Monthly Income: $#{money(gross_monthly_income)}",
      " Monthly Income Tax: $#{money(monthly_income_tax)}",
      " Net Monthly Income: $#{money(net_monthly_income)}"
    ].join("\n")
  end
  # payslip as a # for the JSON API.
  def to_h
    {
      employee_name: name,
      gross_monthly_income: money(gross_monthly_income),
      monthly_income_tax: money(monthly_income_tax),
      net_monthly_income: money(net_monthly_income)
    }
  end

  private

  def money(amount)
    format("%.2f", amount)
  end
end

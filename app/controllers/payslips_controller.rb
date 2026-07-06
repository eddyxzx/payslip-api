class PayslipsController < ApplicationController
  # POST /payslips
  def create
    payslip = Payslip.new(params[:employee_name], params[:annual_salary].to_i)

    SalaryComputation.create!(
      employee_name: payslip.name,
      annual_salary: payslip.annual_salary,
      monthly_income_tax: payslip.monthly_income_tax
    )

    render json: payslip.to_h
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
  end

  # GET /payslips
  def index
    computations = SalaryComputation.order(created_at: :desc)
    render json: { salary_computations: computations.map(&:to_listing) }
  end

  # GET /payslips/breakdown?annual_salary=60000
  def breakdown
    salary = params[:annual_salary].to_i
    calculator = ProgressiveTaxCalculator.new

    render json: {
      annual_salary: salary.to_s,
      brackets: calculator.breakdown(salary),
      total_annual_tax: format("%.2f", calculator.annual_tax(salary))
    }
  end
end

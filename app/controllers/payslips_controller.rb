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

  # GET /payslips?page=1
  def index
    per_page = 6
    page = params[:page].to_i
    page = 1 if page < 1

    total = SalaryComputation.count
    computations = SalaryComputation.order(created_at: :desc)
                                    .offset((page - 1) * per_page)
                                    .limit(per_page)

    render json: {
      salary_computations: computations.map(&:to_listing),
      pagination: {
        page: page,
        per_page: per_page,
        total_count: total,
        total_pages: [ (total.to_f / per_page).ceil, 1 ].max
      }
    }
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

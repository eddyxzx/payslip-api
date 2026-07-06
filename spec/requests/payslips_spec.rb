require 'rails_helper'

RSpec.describe "POST /payslips", type: :request do
  it "returns the calculated payslip as JSON" do
    post "/payslips", params: { employee_name: "Ren", annual_salary: 60000 }

    expect(response).to have_http_status(:ok)

    body = JSON.parse(response.body)
    expect(body).to eq(
      "employee_name"        => "Ren",
      "gross_monthly_income" => "5000.00",
      "monthly_income_tax"   => "500.00",
      "net_monthly_income"   => "4500.00"
    )
  end

  it "saves the computation to the database" do
    expect {
      post "/payslips", params: { employee_name: "Ren", annual_salary: 60000 }
    }.to change(SalaryComputation, :count).by(1)

    record = SalaryComputation.last
    expect(record.employee_name).to eq("Ren")
    expect(record.annual_salary).to eq(60000)
    expect(record.monthly_income_tax).to eq(500)
  end
end

RSpec.describe "POST /payslips validation", type: :request do
  it "rejects a blank employee name with 422" do
    post "/payslips", params: { employee_name: "", annual_salary: 60000 }

    expect(response).to have_http_status(:unprocessable_content)
    expect(JSON.parse(response.body)["errors"]).to include("Employee name can't be blank")
  end

  it "rejects a non-positive salary with 422" do
    post "/payslips", params: { employee_name: "Ren", annual_salary: -5 }

    expect(response).to have_http_status(:unprocessable_content)
    expect(JSON.parse(response.body)["errors"]).to include("Annual salary must be greater than 0")
  end

  it "does not save a record when the input is invalid" do
    expect {
      post "/payslips", params: { employee_name: "", annual_salary: 60000 }
    }.not_to change(SalaryComputation, :count)
  end
end

RSpec.describe "GET /payslips", type: :request do
  it "lists all saved computations as JSON" do
    SalaryComputation.create!(employee_name: "Ren", annual_salary: 60000, monthly_income_tax: 500)

    get "/payslips"

    expect(response).to have_http_status(:ok)

    body = JSON.parse(response.body)
    expect(body["salary_computations"].size).to eq(1)

    record = body["salary_computations"].first
    expect(record["employee_name"]).to eq("Ren")
    expect(record["annual_salary"]).to eq("60000")
    expect(record["monthly_income_tax"]).to eq("500.00")
    expect(record).to have_key("time_stamp")
  end
end

RSpec.describe "GET /payslips/breakdown", type: :request do
  it "returns the per-bracket tax breakdown as JSON" do
    get "/payslips/breakdown", params: { annual_salary: 60000 }

    expect(response).to have_http_status(:ok)

    body = JSON.parse(response.body)
    expect(body["annual_salary"]).to eq("60000")
    expect(body["total_annual_tax"]).to eq("6000.00")
    expect(body["brackets"].size).to eq(5)

    expect(body["brackets"][0]).to eq("range" => "0-20000", "rate" => "0%", "tax" => "0.00")
    expect(body["brackets"][1]).to eq("range" => "20001-40000", "rate" => "10%", "tax" => "2000.00")
    expect(body["brackets"][2]).to eq("range" => "40001-80000", "rate" => "20%", "tax" => "4000.00")
  end
end

class CreateSalaryComputations < ActiveRecord::Migration[8.1]
  def change
    create_table :salary_computations do |t|
      t.string :employee_name
      t.integer :annual_salary
      t.decimal :monthly_income_tax, precision: 10, scale: 2

      t.timestamps
    end
  end
end

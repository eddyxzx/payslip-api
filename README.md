# Payslip API 💵

A REST API that computes an individual's **monthly payslip** from their annual salary using a **progressive (marginal) income‑tax** model, persists each computation, and exposes the results as JSON. Built with Ruby on Rails.

Given an annual salary, the API returns the monthly gross income, income tax, and net income — taxing each slice of income at its bracket's rate, the way real progressive tax systems work.

---

## ✨ Features

- **Progressive tax engine** — income is split across brackets and each slice is taxed at its own rate.
- **`POST /payslips`** — compute a payslip and persist the record.
- **`GET /payslips`** — list every saved computation.
- **`GET /payslips/breakdown`** — see the per‑bracket tax breakdown for any salary.
- **Input validation** — invalid requests return `422` with a clear JSON error.
- **Fully tested** — RSpec unit + request specs, run automatically in CI.

## 🧱 Tech stack

| Concern | Choice |
|---|---|
| Language / framework | Ruby, Ruby on Rails (API‑only) |
| Database | SQLite (zero‑config; swappable for PostgreSQL) |
| Testing | RSpec (unit + request specs) |
| CI | GitHub Actions (RSpec, RuboCop, Brakeman) |

## 🏗️ Architecture & design

The business logic is deliberately kept out of the controllers, in small single‑responsibility objects:

| Object | Responsibility |
|---|---|
| `TaxBracket` | Models one bracket; taxes only the slice of income within its range. |
| `ProgressiveTaxCalculator` | Sums each bracket's contribution. Brackets are **injected** as data — the **Strategy pattern** — so tax rules can change without touching the algorithm. |
| `Payslip` | Turns an annual salary into monthly gross / tax / net figures and formats output. |
| `SalaryComputation` | ActiveRecord model that persists each computation. |
| `PayslipsController` | Thin — reads params, delegates to the services, renders JSON. |

**Time complexity:** `O(n)` over the number of tax brackets (effectively constant, since the bracket set is small and fixed).

### Tax brackets

| Salary bracket | Rate |
|---|---|
| 0 – 20,000 | 0% |
| 20,001 – 40,000 | 10% |
| 40,001 – 80,000 | 20% |
| 80,001 – 180,000 | 30% |
| 180,001 and above | 40% |

Brackets live as data in `ProgressiveTaxCalculator::DEFAULT_BRACKETS` — changing the tax rules is a one‑line edit, no logic changes.

## 🚀 Getting started

```bash
# Prerequisites: Ruby (see .ruby-version) and Bundler

bundle install          # install gems
bin/rails db:migrate    # set up the database
bin/rails server        # start the API at http://localhost:3000
```

## 📡 API

### `POST /payslips` — compute & save a payslip

```bash
curl -X POST http://localhost:3000/payslips \
  -H "Content-Type: application/json" \
  -d '{"employee_name": "Ren", "annual_salary": 60000}'
```

```json
{
  "employee_name": "Ren",
  "gross_monthly_income": "5000.00",
  "monthly_income_tax": "500.00",
  "net_monthly_income": "4500.00"
}
```

Invalid input returns `422`:

```json
{ "errors": ["Employee name can't be blank", "Annual salary must be greater than 0"] }
```

### `GET /payslips` — list all saved computations

```json
{
  "salary_computations": [
    {
      "time_stamp": "2026-07-06T08:01:00Z",
      "employee_name": "Ren",
      "annual_salary": "60000",
      "monthly_income_tax": "500.00"
    }
  ]
}
```

### `GET /payslips/breakdown?annual_salary=60000` — per‑bracket breakdown

```json
{
  "annual_salary": "60000",
  "brackets": [
    { "range": "0-20000",     "rate": "0%",  "tax": "0.00" },
    { "range": "20001-40000", "rate": "10%", "tax": "2000.00" },
    { "range": "40001-80000", "rate": "20%", "tax": "4000.00" },
    { "range": "80001-180000","rate": "30%", "tax": "0.00" },
    { "range": "180001 and above", "rate": "40%", "tax": "0.00" }
  ],
  "total_annual_tax": "6000.00"
}
```

## 🧪 Tests

```bash
bundle exec rspec
```

## 👤 Author

**Eddy** — [eddyxzx.com](https://eddyxzx.com) · [github.com/eddyxzx](https://github.com/eddyxzx)

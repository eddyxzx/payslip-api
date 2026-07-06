class ProgressiveTaxCalculator
  # tax rules
  DEFAULT_BRACKETS = [
    TaxBracket.new(0,      20000,  0),
    TaxBracket.new(20000,  40000,  10),
    TaxBracket.new(40000,  80000,  20),
    TaxBracket.new(80000,  180000, 30),
    TaxBracket.new(180000, nil,    40)   # nil ceiling = "180001 and above"
  ]

  def initialize(brackets = DEFAULT_BRACKETS)
    @brackets = brackets
  end

  def annual_tax(salary)
    total = 0
    @brackets.each do |bracket|
      total += bracket.tax_for(salary)
    end
    total.round(2)
  end

  # A per-bracket breakdown of the tax for a salary, mirroring the assessment's
  # "Sample Tax Computation" tables.
  def breakdown(salary)
    @brackets.map do |bracket|
      {
        range: bracket.range_label,
        rate: "#{bracket.rate}%",
        tax: format("%.2f", bracket.tax_for(salary))
      }
    end
  end
end

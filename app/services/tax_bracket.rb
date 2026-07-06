class TaxBracket
  attr_reader :floor, :ceiling, :rate

  def initialize(floor, ceiling, rate)
    @floor = floor       # bottom of bracket
    @ceiling = ceiling   # top of the bracket (nil means no upper limit)
    @rate = rate         # tax rate as a percentage, e.g. 10 means 10%
  end

  def tax_for(salary)
    return 0 if salary <= floor

    if ceiling.nil? || salary < ceiling
      upper = salary       # salary sits inside this bracket
    else
      upper = ceiling      # salary goes past this bracket, so cap at the ceiling
    end

    taxable_amount = upper - floor
    taxable_amount * rate / 100.0
  end

  # A human-readable label for this bracket's range, matching the assessment's
  # table, e.g. "0-20000", "20001-40000", "180001 and above".
  def range_label
    lower = floor.zero? ? 0 : floor + 1
    return "#{lower} and above" if ceiling.nil?

    "#{lower}-#{ceiling}"
  end
end

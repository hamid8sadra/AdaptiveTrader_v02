```markdown
# INDICATOR SPEC — `<NAME>`

## Name
`<e.g. MomentumCrossover>`

## Definition (FILL THIS EACH TIME)

- What it measures: `<One paragraph in plain language>`
- Inputs (name, type, default, range):
  - InpFastPeriod: int, 14, 1..200
  - InpSlowPeriod: int, 28, 2..400
- Buffers (FIXED ORDER — must match contract):
  - Buffer 0: FastValue (double)
  - Buffer 1: SlowValue (double)
- Warmup bars: `max(periods) + 2`
- Calculation rules (precise and unambiguous):
  - `<Define exactly how each buffer value is calculated.>`
  - `<Define any conditions, comparisons, or special cases.>`
- Numeric examples (at least 2 examples):
  - Input data and parameters.
  - Expected buffer values.
  - Show enough calculation steps to verify the results.

## Files to generate
- `Indicators/Ind_<NAME>.mq5`
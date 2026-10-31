```markdown
# INDICATOR SPEC — <NAME>

## Name
<e.g. MomentumCrossover>

## Definition (FILL THIS EACH TIME)
- What it measures: <one paragraph, plain language>
- Inputs (name, type, default, range):
    - InpFastPeriod  : int, 14, 1..200
    - InpSlowPeriod  : int, 28, 2..400
- Buffers (FIXED ORDER — must match contract):
    - Buffer 0: FastValue   (double, price scale)
    - Buffer 1: SlowValue   (double, price scale)
    - Buffer 2: Signal      (double: +1 buy, -1 sell, 0 none)
- Warmup bars: max(InpFastPeriod, InpSlowPeriod) + 2
- Rule (precise, unambiguous):
    - Signal = +1 at bar i if Fast[i] > Slow[i] AND Fast[i-1] <= Slow[i-1]
    - Signal = -1 at bar i if Fast[i] < Slow[i] AND Fast[i-1] >= Slow[i-1]
    - Else Signal = 0
- Numeric examples (given OHLC, expected output — 2 examples)

## Files to generate
- Indicators/Ind_<NAME>.mq5
# PROMPT — Level 3: Three-mode Expert (NORMAL / CALC / OPTIMIZE)

Generate ONE file: `Experts/EA_L3_<NAME>.mq5`.

Inputs:
- InpMode      : enum { MODE_NORMAL, MODE_CALC, MODE_OPTIMIZE } = MODE_NORMAL
- InpCSVFolder : string = "L3_<NAME>"
- (indicator inputs, lots, SL/TP, magic as L1)

Behavior:
- MODE_NORMAL: identical to EA_L1 (indicator handle, trade per signal).
- MODE_CALC:
    - open indicator handle.
    - on each new 1-minute bar: write a CSV row
      `time;buf0;buf1;buf2` to `<Folder>/indicator.csv` (append).
    - NEVER open trades.
    - OnDeinit: release handle, close file.
- MODE_OPTIMIZE:
    - do NOT create indicator handle.
    - at OnInit: load `<Folder>/indicator.csv` into a map<datetime, double[]>.
    - on each new 1-minute bar: look up bar's datetime in map.
      If missing → skip bar entirely (do NOT use previous value).
    - trading logic identical to L1 but reads from map instead of handle.

Rules:
- CSV separator `;`, header row `time;b0;b1;b2`.
- Same `datetime` key format between CALC and OPTIMIZE:
  `TimeToString(t, TIME_DATE|TIME_SECONDS)`.
- Trading logic lives in ONE private method `Trade(double sig)` used by
  NORMAL and OPTIMIZE so behaviors cannot drift.

Output: only the .mq5 code.
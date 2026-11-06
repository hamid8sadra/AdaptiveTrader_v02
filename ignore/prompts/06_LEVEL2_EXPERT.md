
---

## فایل ۷ — `06_LEVEL2_EXPERT.md`

```markdown
# PROMPT — Level 2: Expert that drives Child

Generate ONE file: `Experts/EA_L2_<NAME>.mq5`.

Inputs:
- InpMode         : ENUM_STRAT_MODE = MODE_LIVE
- InpSimStart     : datetime = D'2024.01.01'
- InpSimEnd       : datetime = D'2024.12.31'
- InpParams       : string   = "InpFastPeriod=14;InpSlowPeriod=28"
- InpCSVFolder    : string   = "L2_<NAME>"

Behavior:
1. OnInit: create `new CChild_<NAME>()`, call `Init(InpParams)`.
   If fails → `INIT_FAILED`.
2. OnTick: call `m_child.RunLive()` — child decides bar-close internally.
   (Child stores its own `m_lastBar`, so re-entry per tick is safe.)
3. OnDeinit:
   - if tester is running (`MQLInfoInteger(MQL_TESTER)`) AND
     `InpMode == MODE_LIVE`:
        → at end of test, call `m_child.RunBacktestSim(InpSimStart, InpSimEnd)`,
          then `m_child.ExportCSV(InpCSVFolder)`.
   - if `InpMode == MODE_BACKTEST_SIM`: do nothing during test;
     in OnDeinit call `RunBacktestSim` + `ExportCSV` (this is the main path).
   - always `m_child.Deinit(); delete m_child;`
4. Never open trades directly — all through child.

CRITICAL: in MODE_LIVE under tester, child does its normal live-like trading;
the extra simulation at OnDeinit is for comparison CSV, not for replacing it.

Output: only the .mq5 code.
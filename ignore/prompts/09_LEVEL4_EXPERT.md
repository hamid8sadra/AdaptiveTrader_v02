
---

## فایل ۱۰ — `09_LEVEL4_EXPERT.md`

```markdown
# PROMPT — Level 4: Metrics Expert

Generate ONE file: `Experts/EA_L4_<NAME>.mq5`.

Inputs:
- InpSimStart  : datetime
- InpSimEnd    : datetime
- InpParams    : string
- InpCSVFolder : string = "L4_<NAME>"

OnInit: create child, do NOT start live trading.
During whole backtest: do nothing (return from OnTick immediately).
OnDeinit (before tester closes):
  1. bool ok = child.RunBacktestSim(InpSimStart, InpSimEnd);
  2. STrade trades[]; SBalancePoint bal[];
     child.GetTrades(trades); child.GetBalance(bal);
  3. CMetrics m; double pf = m.Profit(trades); ... etc. for all 5.
  4. Write `<Folder>/metrics.csv` with one row:
     `metric;value` per line (5 rows). Also call child.ExportCSV(folder).
  5. Deinit child, delete.

Output: only the .mq5 code.
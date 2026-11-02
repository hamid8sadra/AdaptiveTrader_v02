# PROMPT — Level 5: Parameter scan + multi-run

Generate ONE file: `Experts/EA_L5_<NAME>.mq5`.

Inputs:
- InpScanDays    : int = 30      // n days back for scoring
- InpTopK        : int = 5
- InpRunDays     : int = 7       // m days to run LIVE before closing
- InpRankMetric  : enum {RANK_SHARPE, RANK_PF, RANK_MAXDD} = RANK_SHARPE
- InpCSVFolder   : string = "L5_<NAME>"

Hardcoded scan grid (child params as strings, one per set):
```mql5
string g_sets[] = {
   "InpFastPeriod=10;InpSlowPeriod=20",
   "InpFastPeriod=14;InpSlowPeriod=28",
   "InpFastPeriod=20;InpSlowPeriod=40"
};

State machine: SCAN → RUN → CLOSING → SCAN ...

Scan phase:
for each set:
child = new CChild_<NAME>(); child.Init(set);
from = TimeCurrent() - InpScanDays*86400;
to = TimeCurrent();
child.RunBacktestSim(from, to);
child.GetTrades/GetBalance → CMetrics → score
store {set, score} in SResult[]
delete child
sort SResult[] by chosen metric (desc for sharpe/pf, asc for maxdd)
take top K → create live instances array

Run phase:
each new 1-minute bar: for each live instance → RunLive()
check cycle timer: if TimeCurrent() - cycleStart >= InpRunDays*86400
→ switch to CLOSING

Closing phase:
each new bar: for each instance → if(RunClosing()==false) delete instance
when array empty → SCAN again

Rules:

NEVER call ScanPhase inside OnTick of LIVE — use OnTimer(60).

Keep total live instances <= InpTopK.

Log cycle events to Logs/L5_<NAME>.log (not Comment).

All file paths inside InpCSVFolder.

Output: only the .mq5 code.
# PROMPT — Level 2: Base Class

Generate ONE file: `Include/Base/BaseStrategy.mqh`.

This file is written ONCE and never modified per indicator. It must be
fully generic. Child classes only override the virtual methods.

Public API (MUST match exactly — child and EA depend on it):
```mql5
class CBaseStrategy
{
public:
   virtual bool  Init(const string params_json_or_csv)   = 0;
   virtual void  Deinit()                                 = 0;
   virtual bool  OnBar(datetime barTime, int shift)       = 0; // return true if trade opened/closed
   virtual int   IndicatorBufferCount() const             = 0;
   virtual bool  GetIndicatorValue(int shift, int buf, double &out) = 0;

   // Modes
   bool  RunLive();                          // called by EA on each new bar
   bool  RunClosing();                       // returns false when ready to destroy
   bool  RunBacktestSim(datetime from, datetime to);

   // Results (only valid after RunBacktestSim)
   int   GetTrades(STrade &out[]);
   int   GetBalance(SBalancePoint &out[]);
   bool  ExportCSV(const string folder);
};

Implementation notes:

RunBacktestSim iterates 1-minute bars from from to to using
CopyRates/CopyTime (load chunks of 10_000 bars; loop).

For each bar: call OnBar(time, 0) on the SIMULATED bar, then append
SBalancePoint{time, balance, balance + floatingPnL}.

Floating PnL computed from open STrade entries vs bar Close.

ExportCSV writes trades.csv and balance.csv in folder.

RunClosing returns false when no open simulated or real trades.

NO indicator handle in this file — handled by child.

NO assumptions about which indicator. All indicator access via virtual.

Output: only the .mqh code. Include <Trade\Trade.mqh>.
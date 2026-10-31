# PROMPT — Level 4: Metrics class

Generate ONE file: `Include/Metrics/Metrics.mqh`.

Class `CMetrics` with each metric in its OWN public method (no combined
method). All take const-ref arrays.

```mql5
class CMetrics
{
public:
   double Profit(const STrade &t[]);
   double ProfitFactor(const STrade &t[]);
   double DrawdownPercent(const SBalancePoint &b[]);      // on equity
   double MaxDrawdownPercent(const SBalancePoint &b[]);   // on equity
   double SharpeRatio(const SBalancePoint &b[], double rfAnnual = 0.0,
                      int barsPerYear = 0 /*0 => auto from points*/);
};

Exact formulas (do NOT deviate):

Profit = Σ profit

ProfitFactor = Σ profit>0 / |Σ profit<0|; if no losses → return 0
(not infinity), document this choice.

DrawdownPercent : peak = max(balance[0..i]); dd = (peak - equity[i]) / peak * 100;
return MAX over i (this is max drawdown, but keep both
functions separate as required). For DrawdownPercent
(non-max) return the LAST bar's dd.

MaxDrawdownPercent: as above but return MAX.

SharpeRatio:
returns r[i] = (equity[i] - equity[i-1]) / equity[i-1]
(skip i=0; skip if equity[i-1]==0)
mean = avg(r); sd = sqrt( Σ (r-mean)^2 / (N-1) )
if sd == 0 return 0
annualize: barsPerYear>0 ? sqrt(barsPerYear) : sqrt(1440*252)
return (mean - rfAnnual/barsPerYear) / sd * sqrt(barsPerYear)

Rules:

No I/O inside metric methods.

No hardcoded symbol/period.

Guard every division by zero, empty array, single-element array.

Output: only the .mqh code.
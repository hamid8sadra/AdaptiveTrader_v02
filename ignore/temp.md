prompts\00_AGENT.md
prompts\00_MASTER_CONTEXT.md

prompts\01_INDICATOR_SPEC_template.md
prompts\01_INDICATOR_SPEC_WeightedPricePDF.md
prompts\01_INDICATOR.md
   MQL5\Indicators\AdaptiveTrader\Ind_WeightedPricePDF.mq5
   MQL5\Indicators\AdaptiveTrader\Ind_WeightedPricePDF.md

prompts\02_NBO_EXPERT.md
   MQL5\Experts\AdaptiveTrader\EA_NBO_WeightedPricePDF.mq5

prompts\03_INDICATORCLASS.md
   MQL5\Include\AdaptiveTrader\IndC_WeightedPricePDF.mqh
   MQL5\Include\AdaptiveTrader\IndC_WeightedPricePDF.md
   MQL5\Experts\AdaptiveTrader\EA_IndC_WeightedPricePDF_test.mq5     // delet

prompts\04_EXPERTCLASS.md

	MQL5\Experts\AdaptiveTrader\EA_NBO_WeightedPricePDF_normal.mq5      // temp
	MQL5\Experts\AdaptiveTrader\EA_NBO_WeightedPricePDF_IndC.mq5        // temp

   MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF_basic.mqh         // temp
   MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF_basic.md         // temp
   MQL5\Experts\AdaptiveTrader\EAC_WeightedPricePDF_basic_test.mq5      // temp

   MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF.mqh
   MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF.md
   MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF_test.mq5    // temp






enum ENUM_MODE { MODE_LIVE, MODE_CLOSING, MODE_BACKTEST_SIM };
enum ENUM_SIGNAL { BUY,SELL,CLOSE,NA};
ENUM_MODE m_mode; // default = MODE_LIVE, new input
double m_deposite; // default = 1000, new input
bool save_to_csv; // default = true, new input

struct STrade {
   datetime openTime, closeTime; // closeTime = 0 for open positions
   double   openPrice, closePrice; // closePrice = 0 for open positions
   double   lots;
   int      direction;      // +1 buy, -1 sell
   double   profit,profit_max,profit_min;         // net of commission/swap . last profit for open positions
   double   commission, swap;
   ulong    ticket;         // 0 in simulation
   ulong    magic;
   strting  comment; // in form of "/magic"
   string   symbol;
};
m_Trade[];

struct SBalancePoint {
   datetime time;
   double   balance;
   double   equity;
};
m_BalancePoint[];

struct SIndicatorSample {
   datetime time;
   string   values;       // one slot per indicator buffer , rounded by _digite and sepreted by ',' 
   ENUM_SIGNAL signal;
};
m_IndicatorSample[];

public:
setMode(ENUM_MODE inp_mod);
getTrade(STrade &out_Trade);
getBalancePoint(SBalancePoint &out_BalancePoint);
getIndicatorSample(SIndicatorSample &out_IndicatorSample);
setDeposite();
saveTocsv()
backtestSim(
   datetime start_sim,end_sim;
   double deposite;
   STrade &out_Trade;
   SBalancePoint &out_BalancePoint;
   SIndicatorSample &out_IndicatorSample
   int &progrecc_percent;
);

read following files in order and follow instructions:{
	"MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF_basic.mqh"
}
create following files: {

   MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF.mqh
   MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF.md
   MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF_test.mq5    // temp
}


read "MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF_basic.mqh"
این موارد رو بهش اضافه کن:
enum ENUM_MODE { MODE_LIVE, MODE_CLOSING, MODE_BACKTEST_SIM };
enum ENUM_SIGNAL { BUY,SELL,CLOSE,NA};
ENUM_MODE m_mode; // default = MODE_LIVE, new input
double m_deposite; // default = 1000, new input
bool save_to_csv; // default = true, new input

struct STrade {
   datetime openTime, closeTime; // closeTime = 0 for open positions
   double   openPrice, closePrice; // closePrice = 0 for open positions
   double   lots;
   int      direction;      // +1 buy, -1 sell
   double   profit,profit_max,profit_min;         // net of commission/swap . last profit for open positions
   double   commission, swap;
   ulong    ticket;         // 0 in simulation
   ulong    magic;
   strting  comment; // in form of "/magic"
   string   symbol;
};
m_Trade[];
struct SBalancePoint {
   datetime time;
   double   balance;
   double   equity;
};
m_BalancePoint[];
struct SIndicatorSample {
   datetime time;
   string   values;       // one slot per indicator buffer , rounded by _digite and sepreted by ','
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
توضیحات:
 **MODE_LIVE :**
 در این مود کلاس همه در محاسبات و رفتار فعلی را به همین صورت که هست حفظ میکند. به علاوه یک کارکرد جدید به آن اضافه می شود. به ازای هر کندل یک دقیقه ای بسته شده، مقادر بالانس و اکوئیتی را بدون استفاده از توابع داخلی متاتریدر محاسبه کرده و در آرایه SBalancePoint ذخیره میکند. همچنین برای هر کندل مقادیر بافرها و سیگنال را در آرایه m_IndicatorSample ذخیره میکند. برای پوزیشن ها هم m_Trade را پر میکند. مقادیر داخلی برای پوزشن های باز در هر کندل آپدیت می شوند.
 اگر save_to_csv=true باشد، با هر بار باز یا بسته کردن معاملات، یا فراخوانی تابع saveTocsv توسط کلاسهای بالادستی و همچنین یک بار در زمان حذف شدن کلاس، آرایه های m_Trade و m_BalancePoint و m_IndicatorSample در فایلهای csv در پوشه common files ذخیره می شوند. (overwrite) الگوی نامگذاری:
 "symbol_{magic}_Trades.csv"
 "symbol_{magic}_BalancePoint.csv"
"symbol_{magic}_IndicatorSample.csv"

  **MODE_CLOSING :**
  همه ی قابلیت های مود MODE_LIVE فقط با یک تفاورت: معامله ی جدید باز نمیکند.
**MODE_BACKTEST_SIM :**
در این مود، کلاس از اول تا آخر بازه ی درخواستی ، برای همه ی کندلهای یک دقیقه ای بسته شده، محاسبات اندیکاتور را انجام میدهد. معاملات را شبیه سازی میکند و نتایج را بر میگرداند.

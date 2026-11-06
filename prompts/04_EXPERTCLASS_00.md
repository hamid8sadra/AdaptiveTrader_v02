read following files in order and follow instructions:{
	MQL5\Experts\AdaptiveTrader\EA_NBO_WeightedPricePDF.mq5
}
create following files: {
   MQL5\Experts\AdaptiveTrader\EA_NBO_WeightedPricePDF_normal.mq5      // temp
   MQL5\Experts\AdaptiveTrader\EA_NBO_WeightedPricePDF_IndC.mq5        // temp

   MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF_basic.mqh         // temp
   MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF_basic.md         // temp
   MQL5\Experts\AdaptiveTrader\EAC_WeightedPricePDF_basic_test.mq5      // temp

   MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF.mqh
   MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF.md
   MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF_test.mq5    // temp
}

# step1
read "MQL5\Include\AdaptiveTrader\IndC_WeightedPricePDF.mqh"
قدم اول:
مود های BackTest و Optimizer رو به طور کامل حذف کن. هم از ورودی و هم از توابع. این حذف کردن نباید اختلالی در کارکرد حالت Normal ایجاد کنه. اسکلت کد تا حد امکان همین طور که هست بمونه و عینا کپی بشه. نتیجه رو در این فایل ذخیره کن:
save to "MQL5\Experts\AdaptiveTrader\EA_NBO_WeightedPricePDF_normal.mq5"
# step2
قدم دوم:
read "MQL5\Experts\AdaptiveTrader\EA_NBO_WeightedPricePDF_normal.mq5"
read "MQL5\Include\AdaptiveTrader\IndC_WeightedPricePDF.md"

با توجه به "MQL5\Include\AdaptiveTrader\IndC_WeightedPricePDF.md" این کلاس رو در اکسپرت لود کن. مقادیری که در حال حاضر به عنوان ورودی به اندیکاتور داده میشه رو عینا به عنوان ورودی به این کلاس بده. اسامی بافرها رو دریافت کن. در هر کندل یک دقیقه ای جدید، تاریخ آخرین کندل یک دقیقه ای بسته شده رو به کلاس بده و مقادیر بافرها رو دریافت کن. در بقیه ی کد هر جا نیاز به مقادیر یا اسامی بافرها بود از خروجی های کلاس به جای خروجی های اندیکاتور استفاده کن. بعد از اطمینان از اینکه همه ی کارکردهای اندیکاتور به کلاس منتقل شده، اندیکاتور رو به طور کامل و تمیز از کد حذف کن.
کد رو در این مرحله به این اسم ذخیره کن:
save to "MQL5\Experts\AdaptiveTrader\EA_NBO_WeightedPricePDF_IndC.mq5"
# step3
قدم اول:
read "MQL5\Experts\AdaptiveTrader\EA_NBO_WeightedPricePDF_IndC.mq5"
یک نسخه از این اکسپرت رو به فرم کلاس بنویس.  "symbol" رو هم به لیست ورودی های کلاس اضافه کن و مقدار پیش فرض اون رو  _symbol در نظر بگیر.
متدهای معادل برای توابع داخلی متاتریدر به همان فرم بنویس. مثلا به جای OnTick() یک متد به نام m_OnTick بنویس. ورودی ها را مشابه نگه دار.
save to "MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF_basic.mqh"
قدم دوم:
بعد از نوشتن کد کلاس، یک فایل متنی بنوس. در این فایل، بدون توضیح منطق داخلی کلاس، به صورت مختصر و مفید، نام و  اینترفس کلاس و خروجی های اون رو در قالب json معرفی کن. اطلاعات باید برای کلاسهای بالادستی که میخوان از این کلاس استفاده کنند لازم و کافی باشه.
save to "MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF_basic.md"

روش تست عملکرد کلاس:
یک اکسپرت بسیار ساده و مینیمال بنویس. همه ی ورودی های لازم برای راه اندازی کلاس رو به صورت ورودی input بگیر.
save to "MQL5\Experts\AdaptiveTrader\EAC_WeightedPricePDF_basic_test.mq5"
معیار موفقیت این مرحله :
کد اکسپرت و کلاس در کامپایلر متاتریدر بدون ارور و وارنینگ کامپایل شود.
کلاس بتواند به درستی معاملات را باز و بسته کند.
نقاط ورود و خروج معاملات اکسپرت های 
"MQL5\Experts\AdaptiveTrader\EAC_WeightedPricePDF_basic_test.mq5"
و

"MQL5\Experts\AdaptiveTrader\EA_NBO_WeightedPricePDF_IndC.mq5"
باید دقیقا منطبق باشند.

# step4
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

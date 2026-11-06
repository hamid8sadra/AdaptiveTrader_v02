read following files in order :{
    "prompts\00_MASTER_CONTEXT.md";
    "MQL5\Indicators\AdaptiveTrader\Ind_WeightedPricePDF.mq5"
    "MQL5\Indicators\AdaptiveTrader\Ind_WeightedPricePDF.md"
}
میخوام سه تا فایل بنویسی:
"MQL5\Experts\AdaptiveTrader\EA_L4_WeightedPricePDF.mq5"
 "MQL5\Include\AdaptiveTrader\Ind_WeightedPricePDF.mqh"
  "MQL5\Include\AdaptiveTrader\Ind_WeightedPricePDF.md"
# step1
میخوام یک کلاس به اسم "MQL5\Include\AdaptiveTrader\Ind_WeightedPricePDF.mqh "  بنویسی.
ورودی های کلاس رو از <calss_inputs> بگیر.
نیاز به رسم هیچ بافری روی چارت نیست.
کلاس بایدمتد ها را هم داشته باشد: 
get_buffers_names(& string buffer_names[] )
برای نوشتن نام بافرها در یک آرایه خالی. تغییر سایز آرایه دینامیک خالی را خود کلاس انجام بدهد.
get_buffers_values(datetime requsted_M1_time, & doble buffer_values[] )
برای نوشتن مقادیر بافرها در یک آرایه خالی.  تغییر سایز آرایه دینامیک خالی را خود کلاس انجام بدهد. مقادیر برای تاریخ خواسته شده محاسبه می شود. تاریخ ورودی باید حتما تاریخ بسته شدن یک کندل یک دقیقه ای در سمبل باشد
set_inputs(string csv_string_inputs)
برای دریافت مقادیر ورودی، با حفظ ترتیب و جدا شده با علامت کاما. نام، تایپ، مقدار پیش فرض و رنج ورودی ها باید مطابق  <calss_inputs> باشه.
توابع، نام گذاری ها و منطق باید از اندیکاتور تقلید و در صورت امکان دقیقا کپی شوند.
کلاس حافظه داخلی برای نگهداری مقادیر محاسبه شده قبلی نداره و مقادیر بافرها در لحظه درخواست محاسبه و برگردانده میشن.
برای گرد کردن مقادیر بافرها از _Digits استفاده بشه
اسکلت فایل کلاس به صورت زیر باشه:
```
//+------------------------------------------------------------------+
//|                                             WeightedPricePDF.mqh |
//|                                   Copyright 2026, AdaptiveTrader |
//|                                           https://www.mql5.com   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, AdaptiveTrader"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "A volume-weighted price distribution indicator that estimates price quantiles and the most populated price level over a rolling candle window."

#property strict
class CWeightedPricePDF
  {
private:

public:
                     CWeightedPricePDF();
                    ~CWeightedPricePDF();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CWeightedPricePDF::CWeightedPricePDF()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CWeightedPricePDF::~CWeightedPricePDF()
  {
  }
//+------------------------------------------------------------------+

```
# step2
بعد از نوشتن کد کلاس، یک فایل متنی به نام   "MQL5\Include\AdaptiveTrader\Ind_WeightedPricePDF.md" بنوس.
در این فایل، بدون توضیح منطق داخلی کلاس، به صورت مختصر و مفید، نام و  اینترفس کلاس و خروجی های اون رو در قالب json معرفی کن. اطلاعات باید برای کلاسهای بالادستی که میخوان از این کلاس استفاده کنند لازم و کافی باشه.
# step3
روش تست عملکرد کلاس:
یک اکسپرت بسیار ساده و مینیمال به نام "MQL5\Experts\AdaptiveTrader\EA_L4_WeightedPricePDF.mq5" بنویس.
این اکسپرت اندیکاتور "MQL5\Indicators\AdaptiveTrader\Ind_WeightedPricePDF.mq5" و کلاس  "MQL5\Include\AdaptiveTrader\Ind_WeightedPricePDF.mqh" رو لود میکنه.
همه ی ورودی های لازم برای اندیکاتور رو به صورت Input  دریافت میکنه.
اندیکاتور و کلاس رو با ورودی های مشابه ران میکنه.

یک متغییر به صورت زیر تعریف میکنه:
int candles = 0;
در هر کندل یک دقیقه ای بسته شده:
candles += 1;
در هر تیک این عبارت رو کامنت میکنه:
comment("ok ", candels)
برای هر کندل 1 دقیقه ای بسته شده جدید، مقادیر بافرهای اندیکاتور رو میخونه، تاریخ همون کندل بسته شده رو به کلاس میده و خروجی اون رو میخونه.
مقادیر گرد شده تک تک بافرهای اندیکاتور باید دقیقا با مقادیر نظیر اونها در خروجی کلاس یکی باشه. در غیر این صورت با مشاهده اولی خطا ، پس از اعلام خطا در journal ، اکسپرت خودش رو متوقف میکنه و خارج میشه.

معیارهای موفقیت:
کلاس و اکسپرت بدون خطا و هشدار در کامپایلر متاتریدر کامپایل شود.
اکسپرت بدون اعلام خطا در هر بازه تاریخی در بک تستر متاتریدر عمل کند. به این معنی که مقادیر بافرها  به ازای هر کندل تاریخی یک دقیقه ای با مقادیر گرد شده اندیکاتور موجود در همان تاریخ دقیقا برابر باشد.
سایر برنامه نویسان بدون اطلاع از محتوای کد کلاس و فقط با دسترسی به "MQL5\Include\AdaptiveTrader\Ind_WeightedPricePDF.md" بتوانند به درستی آن را در کد های خود استفاده کنند.
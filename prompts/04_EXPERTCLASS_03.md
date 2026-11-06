read following files in order and follow instructions:{
	"MQL5\Experts\AdaptiveTrader\EA_NBO_WeightedPricePDF_IndC.mq5"
}
create following files: {
  
   MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF_basic.mqh         // temp
   MQL5\Include\AdaptiveTrader\EAC_WeightedPricePDF_basic.md         // temp
   MQL5\Experts\AdaptiveTrader\EAC_WeightedPricePDF_basic_test.mq5      // temp
}

# step2
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


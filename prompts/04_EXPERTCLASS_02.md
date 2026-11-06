read following files in order and follow instructions:{
	"MQL5\Experts\AdaptiveTrader\EA_NBO_WeightedPricePDF_normal.mq5"
}
create following files: {
   MQL5\Experts\AdaptiveTrader\EA_NBO_WeightedPricePDF_IndC.mq5        // temp
}



قدم دوم:
read "MQL5\Experts\AdaptiveTrader\EA_NBO_WeightedPricePDF_normal.mq5"
read "MQL5\Include\AdaptiveTrader\IndC_WeightedPricePDF.md"

با توجه به "MQL5\Include\AdaptiveTrader\IndC_WeightedPricePDF.md" این کلاس رو در اکسپرت لود کن. مقادیری که در حال حاضر به عنوان ورودی به اندیکاتور داده میشه رو عینا به عنوان ورودی به این کلاس بده. اسامی بافرها رو دریافت کن. در هر کندل یک دقیقه ای جدید، تاریخ آخرین کندل یک دقیقه ای بسته شده رو به کلاس بده و مقادیر بافرها رو دریافت کن. در بقیه ی کد هر جا نیاز به مقادیر یا اسامی بافرها بود از خروجی های کلاس به جای خروجی های اندیکاتور استفاده کن. بعد از اطمینان از اینکه همه ی کارکردهای اندیکاتور به کلاس منتقل شده، اندیکاتور رو به طور کامل و تمیز از کد حذف کن.
کد رو در این مرحله به این اسم ذخیره کن:
save to "MQL5\Experts\AdaptiveTrader\EA_NBO_WeightedPricePDF_IndC.mq5"


---

## فایل ۱۲ — `99_CHECKLIST.md`

این را بعد از هر خروجی مدل اجرا کنید.

```markdown
# AI OUTPUT REVIEW CHECKLIST

Compile:
- [ ] 0 errors, 0 warnings in MetaEditor
- [ ] MQL5 only (grep for `OrderSend(`, `MarketInfo(`, `iCustom(..., MODE_...)` in MQL4 form)
- [ ] Includes present: Trade.mqh, required .mqh

Logic:
- [ ] Trading decisions on bar 1 (closed), never bar 0
- [ ] Indicator handle released in OnDeinit
- [ ] Magic number used for both open and close filters
- [ ] No trades on attach bar
- [ ] Warmup respected before reading buffers

Sim vs Live parity:
- [ ] Same trigger function for both (no duplicated logic)
- [ ] CSV key = datetime, no fallback to previous value
- [ ] Sharpe uses same annualization in sim and metric class

Level 4 comparison (vs MT5 tester):
- [ ] Trade count identical
- [ ] Each metric within 10%

Housekeeping:
- [ ] No TODOs, no placeholders
- [ ] All magic numbers replaced by named constants
- [ ] Class/member naming follows master context

نحوه استفاده (workflow روزانه)
برای اضافه‌کردن اندیکاتور جدید، فقط این سه گام:

01_INDICATOR_SPEC.md را با اندیکاتور جدید پر کنید (Name، Buffers، Rule، Examples).

مدل را با ترکیب 00_MASTER_CONTEXT.md + 01_INDICATOR_SPEC.md + 02_LEVEL1_INDICATOR.md صدا بزنید → فایل اندیکاتور.

سپس به ترتیب سطح‌ها را با پرامپت‌های ۰۳ تا ۱۰ صدا بزنید و خروجی هر مرحله را به‌عنوان پیوست به مرحله بعد بدهید. در پایان 99_CHECKLIST را اجرا کنید.

نکات مهم برای مدل‌های سبک
همیشه context را کامل بدهید. مدل سبک حافظه ندارد. 00_MASTER_CONTEXT.md را در هر پرامپت دوباره بفرستید.

خروجی هر مرحله را به مرحله بعد پیوست کنید. مثلاً برای تولید Child_<NAME>.mqh، کد BaseStrategy.mqh و Ind_<NAME>.mq5 را در متن پرامپت بگذارید.

یکی یکی تولید کنید. هرگز از یک مدل سبک نخواهید ۵ فایل را همزمان بسازد. یک فایل، یک پاسخ.

خطاها را برگردانید. اگر MetaEditor خطا داد، متن کامل خطا + کد را به مدل بدهید و بگویید: «فقط خطاها را رفع کن، ساختار را تغییر نده.»

قفل قرارداد: هرگز از مدل نخواهید امضای CBaseStrategy را تغییر دهد. اگر مدل خواست تغییر دهد، رد کنید.

مزیت این ساختار
افزودن اندیکاتور جدید = ویرایش فقط 01_INDICATOR_SPEC.md. بقیه ۱۱ فایل ثابت می‌مانند.

مدل سبک فقط باید یک فایل کوچک با قرارداد مشخص تولید کند → نرخ خطای کم.

تطابق شبیه‌سازی/لایو به‌صورت ساختاری تضمین می‌شود چون منطق در یک تابع مشترک (OnBar) است.

شاخص‌های سطح ۴ مستقل از اندیکاتور هستند و برای همه اندیکاتورها یکسان کار می‌کنند.

اگر بخواهید، می‌توانم این ۱۲ فایل را به‌صورت یک آرشیو متنی کامل و آماده کپی (بدون تیترهای توضیحی من) دوباره بفرستم تا مستقیماً در پوشه prompts/ بگذارید.
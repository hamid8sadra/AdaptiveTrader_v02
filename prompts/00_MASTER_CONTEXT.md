# CONTEXT — MQL5 Modular Trading Framework (AdaptiveTrader)

You are generating code for MetaTrader 5 (MQL5). Follow ALL rules below
strictly. 

## Global rules

   - Language: MQL5 only. Do not use MQL4 functions, conventions, or APIs.
   - Do not use external DLLs.
   - Use #property strict.
   - Every file must compile in MetaEditor with ZERO errors and ZERO warnings.
   - Use CTrade from <Trade\Trade.mqh> for all order operations.
   - All timing decisions use the LAST CLOSED bar: `iTime(_Symbol,_Period,1)`. Never decide on the currently forming bar.
   - All indicator buffer access via `CopyBuffer`. Check `BarsCalculated` before reading. If not ready, return false — never read garbage.
   - All money math uses `NormalizeDouble(value, _Digits)` for prices and `NormalizeDouble(value, 2)` for money.
   - File IO: use `FileOpen` with `FILE_CSV|FILE_WRITE|FILE_ANSI`, separator `;`, always `FileClose`. Timestamps written as `TimeToString(t, TIME_DATE|TIME_SECONDS)`.
   - Use descriptive and consistent names.
   - Names: classes `C<Name>`, structs `S<Name>`, enums `ENUM_<NAME>`, constants `UPPER_SNAKE`, member vars `m_<name>`, globals `g_<name>`.
   - Every public method has a `//---` comment: purpose, params, return.
   - Do NOT generate placeholder comments like "// TODO". Generate full code.
   - Never use Comment() or Sleep() .
   - Do not use ObjectCreate() for trading logic.
   - Do not invent APIs or use deprecated functions.
   - Files must be self-contained unless the task explicitly specifies existing project dependencies.
   - Do not generate or modify unrelated indicators, classes, libraries, or project files.

## Project structure (fixed)
MQL/
   Experts/
      AdaptiveTrader/
         EA_L1_<Name>.mq5
   Indicators/
      AdaptiveTrader/
         Ind_<Name>.mq5





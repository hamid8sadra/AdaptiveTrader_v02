# CONTEXT — MQL5 Modular Trading Framework

You are generating code for MetaTrader 5 (MQL5). Follow ALL rules below
strictly. Do NOT invent APIs. Do NOT use deprecated MQL4 functions.

## Global rules
1. Language: MQL5 only. No MQL4. No external DLLs.
2. Every file must compile in MetaEditor with ZERO errors and ZERO warnings
   treated as errors (fix `#property strict`-style issues).
3. Use `CTrade` from `<Trade\Trade.mqh>` for order operations.
4. Never use `Sleep()` in indicators. Never use `Comment()` in EAs.
5. All indicator buffer access via `CopyBuffer`. Check `BarsCalculated`
   before reading. If not ready, return false — never read garbage.
6. All timing decisions use the LAST CLOSED bar: `iTime(_Symbol,_Period,1)`.
   Never decide on the currently forming bar.
7. All money math uses `NormalizeDouble(value, _Digits)` for prices and
   `NormalizeDouble(value, 2)` for money.
8. File IO: use `FileOpen` with `FILE_CSV|FILE_WRITE|FILE_ANSI`, separator
   `;`, always `FileClose`. Timestamps written as `TimeToString(t, TIME_DATE|TIME_SECONDS)`.
9. Names: classes `C<Name>`, structs `S<Name>`, enums `ENUM_<NAME>`,
   constants `UPPER_SNAKE`, member vars `m_<name>`, globals `g_<name>`.
10. Every public method has a `//---` comment: purpose, params, return.
11. No magic numbers. Define `#define` or `const` at top of file.
12. Do NOT generate placeholder comments like "// TODO". Generate full code.

## Project structure (fixed)
/Indicators/ Ind_<Name>.mq5
/Include/
    /Base/ BaseStrategy.mqh
    /Child/ Child_<Name>.mqh
    /Metrics/ Metrics.mqh
    /Common/ Types.mqh (structs shared by all levels)
/Experts/ 
    EA_L1_<Name>.mq5
    EA_L2_<Name>.mq5
    EA_L3_<Name>.mq5
    EA_L4_<Name>.mq5
    EA_L5_<Name>.mq5


## Shared types (already exist in Include/Common/Types.mqh)
```mql5
enum ENUM_STRAT_MODE { MODE_LIVE, MODE_CLOSING, MODE_BACKTEST_SIM };

struct STrade {
   datetime openTime, closeTime;
   double   openPrice, closePrice;
   double   lots;
   int      direction;      // +1 buy, -1 sell
   double   profit;         // net of commission/swap
   double   commission, swap;
   ulong    ticket;         // 0 in simulation
};

struct SBalancePoint {
   datetime time;
   double   balance;
   double   equity;
};

struct SIndicatorSample {
   datetime time;
   double   values[];       // one slot per indicator buffer
};
Contract between levels (must never change)
Indicator (L1) exposes buffers in a FIXED order. Documented in INDICATOR_SPEC.

EA L1 reads buffers with CopyBuffer(handle, bufIdx, ...).

ChildStrategy (L2) implements CBaseStrategy virtual methods only.

Metrics class (L4) receives STrade[] and SBalancePoint[] and nothing else.

EA L5 receives a hardcoded SParamSet[] and calls ChildStrategy in
BACKTEST_SIM mode to score, then LIVE mode to run.

Forbidden
Do not modify Types.mqh or BaseStrategy.mqh when generating child code.

Do not rename public methods of CBaseStrategy.

Do not add new modes.

Do not use ObjectCreate for logic.

Do not use iCustom inside indicator's OnCalculate.

---

## فایل ۲ — `01_INDICATOR_SPEC.md` (تنها فایلی که هر بار عوض می‌شود)

این فایل **قالب** دارد. هر بار فقط بخش «Definition» را پر می‌کنید.


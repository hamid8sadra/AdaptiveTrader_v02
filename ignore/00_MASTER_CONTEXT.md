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




```


# CONTEXT — AdaptiveTrader L1 Expert Advisor

You are generating code for a MetaTrader 5 (MQL5) Expert Advisor (EA).

This EA is the L1 execution layer associated with one specific indicator. It reads the indicator's output buffers, evaluates its trading conditions, and executes trading operations.

Follow ALL rules below strictly.

## 1. Global Rules

1. Language: MQL5 only. Do not use MQL4 functions, conventions, or APIs.
2. Do not use external DLLs.
3. Use `#property strict`.
4. The generated EA must compile in MetaEditor with zero errors and zero warnings.
5. Use `CTrade` from `<Trade\Trade.mqh>` for all order operations.
6. Never use `Comment()` in the EA.
7. Never use `Sleep()`.
8. Do not use `ObjectCreate()` for trading logic.
9. Do not invent APIs or use deprecated functions.
10. Do not generate placeholder comments such as `// TODO`. Generate complete implementations.
11. Use descriptive and consistent names.
12. No magic numbers. Define constants or named inputs for configurable values.

## 2. Indicator Integration

- The EA is associated with exactly one indicator.
- Use `iCustom()` in `OnInit()` to create the indicator handle.
- Release the indicator handle in `OnDeinit()` using `IndicatorRelease()`.
- Read indicator output buffers exclusively through `CopyBuffer()`.
- Use the exact buffer indices and order defined in the corresponding indicator specification.
- Do not assume buffer indices, labels, or meanings.
- Check `BarsCalculated()` before attempting to read indicator data.
- Check the return value of every `CopyBuffer()` call.
- If indicator data is not ready or cannot be read completely, do not generate a trading decision.
- Never use uninitialized or invalid indicator values.
- Handle `EMPTY_VALUE` explicitly.

## 3. Trading-Time Rules

- All trading decisions must use the most recently closed candle.
- Use `iTime(_Symbol, _Period, 1)` as the reference time of the last closed candle.
- Never make trading decisions using the currently forming candle.
- Evaluate trading conditions only once per newly closed candle.
- Prevent duplicate decisions or order submissions for the same candle.
- Do not use `TimeCurrent()` to determine indicator-based trading signals.

## 4. Trading Operations

- Use `CTrade` for opening, modifying, and closing positions.
- Check the return value of every trading operation.
- Where appropriate, also inspect the trade server return code and its description.
- Respect symbol trading constraints, including:
  - Minimum and maximum volume.
  - Volume step.
  - Minimum stop distance.
  - Supported filling modes.
  - Allowed order types.
- Normalize prices using `_Digits` or the symbol's actual tick size where required.
- Normalize volume according to the symbol's volume constraints.
- Do not assume that every symbol uses the same number of digits, tick size, or volume step.
- Do not submit orders when required market data or indicator values are invalid.
- Do not assume an order was successfully executed merely because the local method returned successfully.

## 5. Position Management

- Define the EA's position-management rules explicitly.
- Do not assume that the EA is allowed to manage every position on the account.
- Use the EA's configured Magic Number to identify its own positions.
- Do not modify or close positions belonging to other EAs or manual trading unless explicitly required by the specification.
- Respect the position-management rules defined for this EA, including whether multiple positions are allowed.
- Handle both hedging and netting account behavior correctly where applicable.

## 6. Input Parameters

- Declare all inputs specified in the EA specification.
- Preserve their exact names, types, default values, and allowed ranges.
- Do not invent additional strategy parameters.
- Validate inputs in `OnInit()`.
- Return `INIT_PARAMETERS_INCORRECT` when an input is invalid.

## 7. Event Handling

Use the appropriate MQL5 event handlers:

- `OnInit()`:
  - Validate inputs.
  - Initialize `CTrade`.
  - Create the indicator handle.
  - Validate indicator initialization.
  - Initialize internal state.

- `OnTick()`:
  - Detect a newly closed candle.
  - Ensure the candle has not already been processed.
  - Verify indicator readiness.
  - Read required indicator values using `CopyBuffer()`.
  - Evaluate trading conditions.
  - Execute the specified trading actions.

- `OnDeinit()`:
  - Release the indicator handle.
  - Perform necessary cleanup.

Use additional event handlers only when required by the EA specification.

## 8. Naming Conventions

- Classes: `C<Name>`
- Structs: `S<Name>`
- Enums: `ENUM_<NAME>`
- Constants: `UPPER_SNAKE`
- Member variables: `m_<name>`
- Global variables: `g_<name>`

Every public method must have a `//---` comment describing its purpose, parameters, and return value.

## 9. File Structure

Generate the EA at the path specified by the task.

The EA must be self-contained unless the task explicitly specifies existing project dependencies.

Do not generate or modify unrelated indicators, classes, libraries, or project files.

## 10. Final Self-Check

Before returning the code, verify:

- [ ] The code uses MQL5 only.
- [ ] The EA is associated with the correct indicator.
- [ ] The indicator handle is created and released correctly.
- [ ] Buffer indices match the indicator specification.
- [ ] All buffer reads use `CopyBuffer()`.
- [ ] `BarsCalculated()` is checked before reading buffers.
- [ ] Invalid and `EMPTY_VALUE` data are handled.
- [ ] Decisions use only the last closed candle.
- [ ] Each closed candle is processed at most once.
- [ ] Trading operations use `CTrade`.
- [ ] Trade operation results are checked.
- [ ] Only positions belonging to this EA are managed.
- [ ] Inputs are validated.
- [ ] No MQL4 leftovers or incomplete code remain.
- [ ] The code has been checked for compilation errors and warnings.

If an MQL5 compiler is available, compile the generated EA and fix all errors and warnings before returning it. Do not claim successful compilation unless compilation was actually performed.
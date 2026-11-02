
---

## فایل ۶ — `05_LEVEL2_CHILD.md`

```markdown
# PROMPT — Level 2: Child Strategy

Prereq: 00_MASTER_CONTEXT.md, 01_INDICATOR_SPEC.md, BaseStrategy.mqh code.
Attach: Ind_<NAME>.mq5 code, BaseStrategy.mqh code.

Generate ONE file: `Include/Child/Child_<NAME>.mqh`.

Class: `CChild_<NAME> : public CBaseStrategy`

Requirements:
1. Member: `int m_handle; datetime m_lastBar; double m_lastSignal;`
2. `Init(params)`: parse params as `key=value;key=value;...` for indicator
   inputs. Create indicator handle via `iCustom(_Symbol,_Period,"Ind_<NAME>",
   in1, in2, ...)`. Return false if handle == INVALID_HANDLE.
3. `Deinit`: `IndicatorRelease(m_handle)`.
4. `OnBar(barTime, shift)`:
   - if `barTime == m_lastBar` return false; else `m_lastBar = barTime`.
   - if `BarsCalculated(m_handle) <= WarmupBars+2` return false.
   - read all buffers of bar `shift` (usually 1) into local array.
   - apply entry/exit rules IDENTICAL to EA L1:
       +1 → open buy; -1 → open sell; opposite → close.
   - return true if any action taken.
5. `IndicatorBufferCount()` returns the number of buffers from spec.
6. `GetIndicatorValue(shift, buf, out)`: safe CopyBuffer with 1 value.
7. `RunBacktestSim` inherited — no override.
8. NEVER touch chart objects. NEVER use Comment/Print for logic.
9. Handle already-open position check via a member list of STrade (simulation)
   OR real positions filtered by magic (live). One code path:

```mql5
bool HasOpen(int dir) { /* checks m_open[] for sim, and OrdersTotal for live */ }

Output: only the .mqh code.

Self-check:

□ buffer indices match spec order
□ same trigger bar (shift=1) as EA L1
□ no duplicated trade logic (only in OnBar)
□ compiles without touching BaseStrategy.mqh
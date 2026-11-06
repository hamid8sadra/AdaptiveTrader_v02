# PROMPT — Level 1: Basic Expert

Prereq: 00_MASTER_CONTEXT.md, 01_INDICATOR_SPEC.md.
Read the produced `Ind_<NAME>.mq5` (attach its code).

Generate ONE file: `Experts/EA_L1_<NAME>.mq5`.

Requirements:
1. Inputs:
   - InpLots        : double = 0.10
   - InpSLPoints    : int    = 200   (0 = disabled)
   - InpTPPoints    : int    = 400   (0 = disabled)
   - InpMagic       : ulong  = 20240001
   - indicator inputs identical to the indicator (same names/defaults)
2. OnTick:
   - Only act when a NEW 1-minute bar closed: compare `iTime(_Symbol,_Period,0)`
     against stored `m_lastBarTime`. If same, return.
   - Read Signal buffer of bar 1 via `CopyBuffer(m_handle, 2, 1, 1, tmp)`.
   - If `BarsCalculated(m_handle) < WarmupBars+2` → return.
3. Entry: Signal == +1 → `trade.Buy`; Signal == -1 → `trade.Sell`.
   Skip if a position with `InpMagic` already open in that direction.
4. Exit: opposite signal → close position with that magic.
5. SL/TP: convert points with `_Point * points`. Skip if 0.
6. OnDeinit: release handle with `IndicatorRelease`.
7. Never open two positions with same magic on same symbol.
8. Works identically in Strategy Tester (visual mode) and live.

Output: only the .mq5 code.

Self-check:
- [ ] handle released
- [ ] bar-close trigger only
- [ ] magic number filter on close
- [ ] no trade on first bar after attach
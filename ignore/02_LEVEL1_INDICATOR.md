# PROMPT — Level 1: Indicator

Read 00_MASTER_CONTEXT.md and 01_INDICATOR_SPEC.md first.

Generate ONE file: `Indicators/Ind_<NAME>.mq5`.

Requirements (all mandatory):
1. `#property indicator_chart_window`
2. One `#property indicator_buffers` equal to number of buffers in spec + 0.
3. `#property indicator_plots` for visible buffers only.
4. Declare buffer arrays as `double Buf0[], Buf1[], Buf2[];`
5. `OnInit`:
   - validate inputs, return INIT_PARAMETERS_INCORRECT on bad values
   - `SetIndexBuffer(idx, BufX, INDICATOR_DATA)` for ALL buffers
   - set plot labels, colors, `PLOT_DRAW_BEGIN` = warmup bars
6. `OnCalculate`:
   - compute `start = MathMax(prev_calculated - 1, WarmupBars)`
   - loop `for(int i = start; i < rates_total; i++)` and fill ALL buffers
   - for bars `i < WarmupBars` set buffers to `EMPTY_VALUE`
   - return `rates_total`
7. NO indicator logic may depend on `TimeCurrent()`. Only on bar data.
8. NO use of `iCustom` inside OnCalculate.
9. Historical correctness: running OnCalculate twice from scratch on same
   history must produce byte-identical buffers.

Output format:
- Only the .mq5 code, no explanation.
- File ends with one blank line.

Self-check before answering:
- [ ] compiles with zero errors
- [ ] buffers order matches spec
- [ ] warmup respected
- [ ] no MQL4 leftovers
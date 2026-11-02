# PROMPT — Generate an MT5 Indicator

Use the indicator specification as the single source of truth for the indicator's name, description, inputs, calculation rules, output buffers, labels, and buffer order.

Generate exactly ONE file:

`Indicators/AdaptiveTrader/Ind_<NAME>.mq5`

Do not generate, modify, or reference any other source file.

## 1. General Rules

- Generate a complete, self-contained MQL5 custom indicator.
- Follow the common structure and coding conventions defined in `00_MASTER_CONTEXT.md`.
- Implement the indicator exactly as specified in `01_INDICATOR_SPEC_LIST_.md`.
- Do not invent additional inputs, output buffers, calculation rules, or features.
- Do not silently omit any specified requirement.
- Use descriptive and consistent variable and function names.
- Use English for all identifiers, comments, labels, and descriptions.
- Do not use external libraries or custom dependencies unless explicitly required by the specification.

## 2. File Header

The file must start with the following header. Replace `<NAME>` and `<short_Description>` with the corresponding values from the specification.

```cpp
//+------------------------------------------------------------------+
//|                                                   <NAME>.mq5     |
//|                                   Copyright 2024, AdaptiveTrader |
//|                                           https://www.mql5.com   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, AdaptiveTrader"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "<short_Description>"
```

## 3. Indicator Properties

- Use `#property indicator_chart_window` unless the specification explicitly defines another supported indicator type.
- Set `indicator_buffers` and `indicator_plots` to the exact number of output buffers/plots defined in the specification.
- Every output plot must use `DRAW_LINE` by default.
- Every output plot must have a width of `1`.
- Assign plot colors from this palette, in the listed order:

  `{clrDodgerBlue, clrRed, clrLimeGreen, clrOrange, clrLightSeaGreen}`

- For more than five plots, reuse the palette cyclically.
- Preserve the exact output buffer order defined in the specification.

For each plot, generate the corresponding indexed properties:

```cpp
#property indicator_label1  "<BUFFER_LABEL>"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  1
```

Use the appropriate plot index and assigned color for every additional plot.

## 4. Inputs

- Declare every input specified in the indicator specification.
- Preserve each input's name, type, default value, and allowed range.
- Do not change input names or defaults.
- For every output buffer, declare an independent visibility input:

```cpp
input bool show_<buffer_label> = true;
```

- Also declare:

```cpp
input bool debug_mode = false;
```

- Do not add other inputs unless explicitly required by the specification.

Visibility inputs must control the corresponding plot's drawing state. Use `PLOT_DRAW_TYPE` with `DRAW_LINE` or `DRAW_NONE` as appropriate.

## 5. Output Buffers

- Declare one `double` indicator buffer for each specified output.
- Buffer names must follow this exact convention:

  `<BUFFER_LABEL>Buffer`

- Preserve the exact buffer order from the specification.
- Bind every buffer using:

```cpp
SetIndexBuffer(index, BufferName, INDICATOR_DATA);
```

- Do not use additional calculation buffers unless they are genuinely necessary and are not exposed as output plots.
- Set the plot label to the exact label specified for its corresponding buffer.

## 6. Global Variables and Warmup

Include a clearly marked section:

```cpp
//--- global variables
```

Declare:

```cpp
int warmup_bars = 0;
```

In `OnInit`, calculate and assign:

```cpp
warmup_bars = inp_period + 2;
```

Use the actual period input name defined in the specification if it differs from `inp_period`.

If the specification does not define a period input, derive the minimum warmup requirement from the calculation rules. Do not invent a period input.

The warmup value must be used consistently throughout initialization and calculation.

## 7. OnInit

`OnInit` must:

1. Validate all inputs against their specified ranges and constraints.
2. Validate any required relationships between inputs.
3. Return `INIT_PARAMETERS_INCORRECT` if any input is invalid.
4. Bind all output buffers using `SetIndexBuffer`.
5. Explicitly configure array indexing after buffer binding.
6. Set plot labels, drawing types, colors, and widths.
7. Apply each visibility input to its corresponding plot.
8. Set `PLOT_DRAW_BEGIN` to `warmup_bars` for every output plot.
9. Set `PLOT_EMPTY_VALUE` to `EMPTY_VALUE` for every output plot.
10. Return `INIT_SUCCEEDED` only after successful initialization.

Do not silently clamp invalid inputs to acceptable values.

## 8. OnCalculate

Use the standard MQL5 `OnCalculate` event handler.

The calculation must follow these rules:

- Explicitly establish chronological indexing for all input price arrays and output buffers. Use the same indexing convention throughout the implementation.
- Use the previous calculation count to avoid recalculating the entire history unnecessarily.
- Calculate the starting index as:

```cpp
int start = MathMax(prev_calculated - 1, warmup_bars);
```

- When `prev_calculated == 0`, initialize all output buffers to `EMPTY_VALUE` before performing calculations.
- For every bar with an index smaller than `warmup_bars`, set all output buffers to `EMPTY_VALUE`.
- Calculate all output buffers for every bar from `start` to `rates_total - 1`.
- Every valid calculated bar must have its corresponding output values written to all applicable buffers.
- Do not leave stale or uninitialized buffer values.
- Return `rates_total`.

If the available history is insufficient for calculation, keep the affected output values as `EMPTY_VALUE`.

Do not use future bars or information that would not have been available at the time represented by the bar being calculated.

## 9. Calculation Logic

- Implement the calculation rules exactly as defined in the indicator specification.
- Keep calculation logic separate from `OnCalculate` when doing so improves readability and makes individual functions easier to verify.
- Every helper function must have a clearly defined responsibility.
- Avoid unnecessary abstractions and excessive function splitting.
- Do not replace specified mathematical formulas with approximations or alternative methods.
- Do not use trading operations, order management, or position management inside the indicator.
- Do not use `iCustom()` inside `OnCalculate`.
- Indicator calculations must not depend on `TimeCurrent()`, local system time, or other external time-dependent values.
- Use only the historical market data and inputs required by the specification.

## 10. Historical Determinism

The indicator must produce deterministic historical results.

For identical input parameters and identical historical price data:

- Running the calculation from scratch multiple times must produce identical output buffers.
- Recalculating a previously calculated bar must produce the same result as its original calculation.
- Results must not depend on the number of previous `OnCalculate` calls.
- Results must not depend on the current system time or execution timing.

Do not use random values, uninitialized memory, external state, or non-deterministic data sources.

## 11. Debugging

- `debug_mode` must control diagnostic logging.
- When disabled, do not produce diagnostic logs.
- When enabled, log useful information such as initialization parameters, calculation errors, and important calculation milestones.
- Avoid excessive logging inside the per-bar calculation loop.
- Debugging must not change calculation results.

## 12. MQL5 Compatibility

- Use valid MQL5 syntax and APIs.
- Do not use MQL4-only functions or conventions.
- Do not use undeclared identifiers, implicit assumptions about array direction, or unsupported language features.
- Handle insufficient history and invalid calculation ranges safely.
- Ensure all declared buffers and variables are initialized appropriately.
- Do not leave placeholders, TODO comments, incomplete functions, or unused code.

## 13. Output Format

- Output only the complete `.mq5` source code.
- Do not include explanations, Markdown fences, or additional files.
- The file must end with exactly one blank line.

## 14. Final Self-Check

Before producing the code, verify:

- [ ] The generated filename matches the specified indicator name.
- [ ] All indicator properties match the actual number of plots.
- [ ] All inputs match the specification.
- [ ] Every output buffer exists and follows the specified order.
- [ ] Buffer names and plot labels match the specification.
- [ ] Every output buffer is correctly bound with `SetIndexBuffer`.
- [ ] Every plot has an independent visibility input.
- [ ] All plot colors come from the specified palette.
- [ ] All plot widths are `1`.
- [ ] Input validation is complete.
- [ ] Warmup is correctly calculated and respected.
- [ ] Array indexing is explicit and consistent.
- [ ] All buffers are initialized and updated correctly.
- [ ] Historical calculations are deterministic.
- [ ] No calculation depends on `TimeCurrent()`.
- [ ] No `iCustom()` call exists inside `OnCalculate`.
- [ ] No MQL4 leftovers or incomplete code remain.
- [ ] The code has been checked for MQL5 compilation errors.

## Companion Indicator Usage Metadata

If an MQL5 compiler is available, compile the generated file and fix all errors before returning it. Do not claim successful compilation unless compilation was actually performed.

After generating and saving the indicator source file, create a companion metadata file at:

`MQL5\Indicators\AdaptiveTrader\Ind_<NAME>.md`

This addendum authorizes exactly one additional output file: the companion `.md` metadata file. Do not modify unrelated files.

The companion file must contain one valid JSON object only, with no Markdown fences or prose around it. Write all JSON text in English. Populate it from the final indicator code so an AI can call the indicator correctly from an MQL5 Expert Advisor without reading its source.

Use this structure:

{  
"name": "<NAME>",  
"iCustom_path": "Indicators\AdaptiveTrader\Ind_<NAME>",  
"inputs_in_order": [  
{"name": "<input_name>", "type": "<type>", "default": <value>, "range": "<valid range or constraints>"}  
],  
"buffers": {  
"0": "<buffer_label>"  
},  
"usage_notes": [  
"Use iCustom with the inputs in the listed order.",  
"Escape path separators as \\ in the JSON value for iCustom_path.",  
"<Add only essential usage notes supported by the indicator code.>"  
]  
}

Requirements:

- Replace every placeholder with information from the generated indicator. Do not leave placeholders in the completed JSON.
    
- Set `<NAME>` to the indicator name without the `Ind_` filename prefix.
    
- Set `iCustom_path` to the indicator path used by MQL5, including the `Ind_` filename prefix but without `.mq5` or `.md`.
    
- List every declared indicator input in exact declaration order. Use valid JSON values for defaults, such as `60`, `true`, or `false`.
    
- Describe each input’s valid range and any required relationships between inputs. Use `"unrestricted"` only when the code imposes no range or constraint.
    
- List every output buffer by its zero-based index and exact plot label, preserving buffer order.
    
- Include concise notes only when they help an EA call or read the indicator correctly. Mention `EMPTY_VALUE` or the recommended `CopyBuffer` position only if applicable to the generated code.
    
- Check that the JSON parses and matches the final indicator code before saving the companion file.
{
  "name": "WeightedPricePDF",
  "iCustom_path": "Indicators\AdaptiveTrader\Ind_WeightedPricePDF",
  "inputs_in_order": [
    {"name": "inp_period", "type": "int", "default": 60, "range": ">=30"},
    {"name": "upper_quantile", "type": "int", "default": 95, "range": "65-95"},
    {"name": "lower_quantile", "type": "int", "default": 5, "range": "5-35; always less than upper_quantile"},
    {"name": "histogram_bins", "type": "int", "default": 100, "range": "5-100"},
    {"name": "show_Q50", "type": "bool", "default": true, "range": "true or false"},
    {"name": "show_QUP", "type": "bool", "default": true, "range": "true or false"},
    {"name": "show_QDN", "type": "bool", "default": true, "range": "true or false"},
    {"name": "show_Mode", "type": "bool", "default": true, "range": "true or false"},
    {"name": "debug_mode", "type": "bool", "default": false, "range": "true or false"}
  ],
  "buffers": {
    "0": "Q50",
    "1": "QUP",
    "2": "QDN",
    "3": "Mode"
  },
  "usage_notes": [
    "Use iCustom with the inputs in the listed order.",
    "Escape path separators as \\ in the JSON value for iCustom_path.",
    "Read values with CopyBuffer; start_pos=1 returns the last closed chart bar.",
    "Values may be EMPTY_VALUE during warmup or when M1 source history is insufficient."
  ]
}

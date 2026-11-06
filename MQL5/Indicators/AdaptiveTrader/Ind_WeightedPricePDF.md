{
  "name": "WeightedPricePDF",
  "description":"A volume-weighted price distribution indicator that estimates price quantiles and the most populated price level over a rolling candle window.",
  "iCustom_path": "AdaptiveTrader\Ind_WeightedPricePDF",
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

  logic_count:7
  logic_levels:{
      key1 = price , value1 = Q50;
      key2 = price , value2 = QUP;
      key3 = price , value3 = QDN;
      key4 = price , value4 = Mode;

      key5 = Mode , value5 = Q50;
      key6 = Mode , value6 = QUP;
      key7 = Mode , value7 = QDN;
  }
  back_test_inputs: [upper_quantile,lower_quantile,histogram_bins]
{
  "calss_inputs":[
      {"name": "symbol", "type": "string", "default": null, "range": null},
      
      {"name": "inp_period", "type": "int", "default": 60, "range": ">=30"},
      {"name": "upper_quantile", "type": "int", "default": 95, "range": "65-95"},
      {"name": "lower_quantile", "type": "int", "default": 5, "range": "5-35; always less than upper_quantile"},
      {"name": "histogram_bins", "type": "int", "default": 100, "range": "5-100"},
      {"name": "debug_mode", "type": "bool", "default": false, "range": "true or false"}
  ]
}
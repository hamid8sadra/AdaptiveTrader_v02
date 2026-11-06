{
  "class": "CWeightedPricePDF",
  "header": "<AdaptiveTrader\\Ind_WeightedPricePDF.mqh>",
  "inputs": {
    "set_inputs": {
      "signature": "bool set_inputs(string csv_string_inputs)",
      "fields_in_order": [
        {"name":"symbol","type":"string","default":"_Symbol","range":"non-empty symbol name"},
        {"name":"inp_period","type":"int","default":60,"range":">=30"},
        {"name":"upper_quantile","type":"int","default":95,"range":"65-95"},
        {"name":"lower_quantile","type":"int","default":5,"range":"5-35 and less than upper_quantile"},
        {"name":"histogram_bins","type":"int","default":100,"range":"5-100"},
        {"name":"debug_mode","type":"bool","default":false,"range":"true/false or 1/0"}
      ],
      "example":"EURUSD,60,95,5,100,false"
    }
  },
  "methods": {
    "get_buffers_names": {"signature":"bool get_buffers_names(string &buffer_names[])","result":"Resizes the array to four names in output order."},
    "get_buffers_values": {"signature":"bool get_buffers_values(datetime requested_M1_time, double &buffer_values[])","result":"Resizes the array to four values in output order. requested_M1_time must exactly equal the opening timestamp of a closed M1 bar; the corresponding indicator buffer values are calculated using the indicator's M1 history alignment."}
  },
  "outputs_in_order": ["Q50","QUP","QDN","Mode"],
  "return_behavior": {"true":"Requested output data was calculated successfully.","false":"Inputs/time are invalid or source history/volume is unavailable; do not use output values."},
  "example": "CWeightedPricePDF pdf; string names[]; double values[]; bool configured=pdf.set_inputs(\"EURUSD,60,95,5,100,false\"); bool named=pdf.get_buffers_names(names); bool calculated=pdf.get_buffers_values(closed_m1_bar_open_time,values);"
}

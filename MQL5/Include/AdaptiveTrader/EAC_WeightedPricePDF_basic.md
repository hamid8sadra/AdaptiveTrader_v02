{
  "class": "CEACWeightedPricePDFBasic",
  "header": "<AdaptiveTrader\\EAC_WeightedPricePDF_basic.mqh>",
  "constructor": "CEACWeightedPricePDFBasic() initializes defaults; symbol defaults to _Symbol.",
  "configuration": {
    "signature": "bool m_SetInputs(string symbol, ENUM_WPDF_POSITION_TYPE direction, double lot_size, int max_positions, int period_base, int period_step, int price_step, int upper_quantile, int lower_quantile, int histogram_bins, bool debug_mode, ulong magic_number, int o01...o07, int c01...c07)",
    "symbol": "Empty string selects _Symbol; defaults to _Symbol.",
    "relations": "Each relation is 1 (left > right), -1 (left < right), or 0 (ignored); open and close rule ordering is price/Q50, price/QUP, price/QDN, price/Mode, Mode/Q50, Mode/QUP, Mode/QDN."
  },
  "lifecycle": {
    "m_OnInit": {"signature":"int m_OnInit()","result":"INIT_SUCCEEDED or initialization error code; configures data and starts bar tracking."},
    "m_OnTick": {"signature":"void m_OnTick()","result":"Processes each newly closed M1 bar and manages configured positions."},
    "m_OnDeinit": {"signature":"void m_OnDeinit(const int reason)","result":"Prints summary and releases active state."}
  },
  "trading_behavior": "Uses CTrade; manages positions matching configured symbol and magic number; opens on a rising edge of the open condition subject to capacity and entry-distance rules; evaluates close rules before opening.",
  "outputs": {"m_OnInit":"initialization status", "m_OnTick":"trade actions", "m_OnDeinit":"summary in terminal log"}
}

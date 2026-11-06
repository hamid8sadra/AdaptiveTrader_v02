//+------------------------------------------------------------------+
//|                                      WeightedPricePDF.mq5        |
//|                                   Copyright 2024, AdaptiveTrader |
//|                                           https://www.mql5.com   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, AdaptiveTrader"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "A volume-weighted price distribution indicator that estimates price quantiles and the most populated price level over a rolling candle window."
#property strict

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4

#property indicator_label1  "Q50"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  1

#property indicator_label2  "QUP"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_width2  1

#property indicator_label3  "QDN"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLimeGreen
#property indicator_width3  1

#property indicator_label4  "Mode"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrOrange
#property indicator_width4  1

input int  inp_period       = 60;
input int  upper_quantile   = 95;
input int  lower_quantile   = 5;
input int  histogram_bins   = 100;
input bool show_Q50         = true;
input bool show_QUP         = true;
input bool show_QDN         = true;
input bool show_Mode        = true;
input bool debug_mode       = false;

double Q50Buffer[];
double QUPBuffer[];
double QDNBuffer[];
double ModeBuffer[];

//--- global variables
int warmup_bars = 0;

//--- Calculate a percentile from the weighted histogram.
double HistogramQuantile(const double &bin_weights[],
                         const double minimum_price,
                         const double bin_width,
                         const double total_weight,
                         const int percentile)
  {
   const double target_weight = total_weight * (double)percentile / 100.0;
   double cumulative_weight = 0.0;
   const int bins_count = ArraySize(bin_weights);

   for(int bin_index = 0; bin_index < bins_count; bin_index++)
     {
      const double current_weight = bin_weights[bin_index];
      if(current_weight <= 0.0)
         continue;

      const double previous_weight = cumulative_weight;
      cumulative_weight += current_weight;
      if(target_weight <= cumulative_weight)
        {
         const double fraction = (target_weight - previous_weight) / current_weight;
         return minimum_price + ((double)bin_index + fraction) * bin_width;
        }
     }

   return minimum_price + (double)bins_count * bin_width;
  }

//--- Build the weighted price histogram and extract its four statistical levels.
bool CalculateDistribution(const datetime reference_time,
                           double &q50,
                           double &qup,
                           double &qdn,
                           double &mode)
  {
   q50 = EMPTY_VALUE;
   qup = EMPTY_VALUE;
   qdn = EMPTY_VALUE;
   mode = EMPTY_VALUE;

   const ENUM_TIMEFRAMES source_timeframe =  PERIOD_M1;
   const int source_shift = iBarShift(_Symbol, source_timeframe, reference_time - 1, false);
   if(source_shift < 0)
      return false;

   MqlRates source_rates[];
   ArraySetAsSeries(source_rates, true);
   const int copied_rates = CopyRates(_Symbol, source_timeframe, source_shift, inp_period, source_rates);
   if(copied_rates != inp_period)
      return false;

   double minimum_price = source_rates[0].low;
   double maximum_price = source_rates[0].high;
   for(int rate_index = 1; rate_index < copied_rates; rate_index++)
     {
      if(source_rates[rate_index].low < minimum_price)
         minimum_price = source_rates[rate_index].low;
      if(source_rates[rate_index].high > maximum_price)
         maximum_price = source_rates[rate_index].high;
     }

   if(maximum_price <= minimum_price)
     {
      double total_volume = 0.0;
      for(int rate_index = 0; rate_index < copied_rates; rate_index++)
         total_volume += (double)source_rates[rate_index].tick_volume;
      if(total_volume <= 0.0)
         return false;

      q50 = NormalizeDouble(minimum_price, _Digits);
      qup = NormalizeDouble(minimum_price, _Digits);
      qdn = NormalizeDouble(minimum_price, _Digits);
      mode = NormalizeDouble(minimum_price, _Digits);
      return true;
     }

   const double bin_width = (maximum_price - minimum_price) / (double)histogram_bins;
   if(bin_width <= 0.0)
      return false;

   double bin_weights[];
   if(ArrayResize(bin_weights, histogram_bins) != histogram_bins)
      return false;
   ArrayInitialize(bin_weights, 0.0);

   double total_weight = 0.0;
   for(int rate_index = 0; rate_index < copied_rates; rate_index++)
     {
      const double candle_weight = (double)source_rates[rate_index].tick_volume;
      if(candle_weight <= 0.0)
         continue;

      const double candle_low = source_rates[rate_index].low;
      const double candle_high = source_rates[rate_index].high;
      const double candle_range = candle_high - candle_low;
      if(candle_range <= 0.0)
        {
         int point_bin = (int)MathFloor((candle_low - minimum_price) / bin_width);
         point_bin = (int)MathMax(0, MathMin(histogram_bins - 1, point_bin));
         bin_weights[point_bin] += candle_weight;
         total_weight += candle_weight;
         continue;
        }

      int first_bin = (int)MathFloor((candle_low - minimum_price) / bin_width);
      int last_bin = (int)MathFloor((candle_high - minimum_price) / bin_width);
      first_bin = (int)MathMax(0, MathMin(histogram_bins - 1, first_bin));
      last_bin = (int)MathMax(0, MathMin(histogram_bins - 1, last_bin));

      double distributed_weight = 0.0;
      int last_overlapping_bin = -1;
      for(int bin_index = first_bin; bin_index <= last_bin; bin_index++)
        {
         const double bin_low = minimum_price + (double)bin_index * bin_width;
         const double bin_high = bin_low + bin_width;
         const double overlap = MathMin(candle_high, bin_high) - MathMax(candle_low, bin_low);
         if(overlap <= 0.0)
            continue;

         const double partial_weight = candle_weight * overlap / candle_range;
         bin_weights[bin_index] += partial_weight;
         distributed_weight += partial_weight;
         last_overlapping_bin = bin_index;
        }

      if(last_overlapping_bin >= 0)
        {
         bin_weights[last_overlapping_bin] += candle_weight - distributed_weight;
         total_weight += candle_weight;
        }
     }

   if(total_weight <= 0.0)
      return false;

   int mode_bin = 0;
   for(int bin_index = 1; bin_index < histogram_bins; bin_index++)
      if(bin_weights[bin_index] > bin_weights[mode_bin])
         mode_bin = bin_index;

   q50 = NormalizeDouble(HistogramQuantile(bin_weights, minimum_price, bin_width, total_weight, 50), _Digits);
   qup = NormalizeDouble(HistogramQuantile(bin_weights, minimum_price, bin_width, total_weight, upper_quantile), _Digits);
   qdn = NormalizeDouble(HistogramQuantile(bin_weights, minimum_price, bin_width, total_weight, lower_quantile), _Digits);
   mode = NormalizeDouble(minimum_price + ((double)mode_bin + 0.5) * bin_width, _Digits);
   return true;
  }

//--- Initialize and validate the indicator inputs, buffers, and plots.
int OnInit()
  {
   if(inp_period < 30 || upper_quantile < 65 || upper_quantile > 95 ||
      lower_quantile < 5 || lower_quantile > 35 || histogram_bins < 5 || histogram_bins > 100)
     {
      Print("WeightedPricePDF: one or more input parameters are outside their allowed ranges.");
      return INIT_PARAMETERS_INCORRECT;
     }

   warmup_bars = inp_period + 2;

   if(!SetIndexBuffer(0, Q50Buffer, INDICATOR_DATA) ||
      !SetIndexBuffer(1, QUPBuffer, INDICATOR_DATA) ||
      !SetIndexBuffer(2, QDNBuffer, INDICATOR_DATA) ||
      !SetIndexBuffer(3, ModeBuffer, INDICATOR_DATA))
      return INIT_FAILED;

   ArraySetAsSeries(Q50Buffer, false);
   ArraySetAsSeries(QUPBuffer, false);
   ArraySetAsSeries(QDNBuffer, false);
   ArraySetAsSeries(ModeBuffer, false);

   PlotIndexSetString(0, PLOT_LABEL, "Q50");
   PlotIndexSetString(1, PLOT_LABEL, "QUP");
   PlotIndexSetString(2, PLOT_LABEL, "QDN");
   PlotIndexSetString(3, PLOT_LABEL, "Mode");

   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, (show_Q50 ? DRAW_LINE : DRAW_NONE));
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, (show_QUP ? DRAW_LINE : DRAW_NONE));
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, (show_QDN ? DRAW_LINE : DRAW_NONE));
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, (show_Mode ? DRAW_LINE : DRAW_NONE));
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrDodgerBlue);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, clrLimeGreen);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, clrOrange);

   for(int plot_index = 0; plot_index < 4; plot_index++)
     {
      PlotIndexSetInteger(plot_index, PLOT_LINE_WIDTH, 1);
      PlotIndexSetInteger(plot_index, PLOT_DRAW_BEGIN, warmup_bars);
      PlotIndexSetDouble(plot_index, PLOT_EMPTY_VALUE, EMPTY_VALUE);
     }

   if(debug_mode)
      PrintFormat("WeightedPricePDF initialized: period=%d, upper=%d, lower=%d, bins=%d, source=%s, warmup=%d",
                  inp_period, upper_quantile, lower_quantile, histogram_bins,"M1", warmup_bars);

   return INIT_SUCCEEDED;
  }

//--- Calculate the four price distribution levels for each eligible chart bar.
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   ArraySetAsSeries(time, false);
   ArraySetAsSeries(Q50Buffer, false);
   ArraySetAsSeries(QUPBuffer, false);
   ArraySetAsSeries(QDNBuffer, false);
   ArraySetAsSeries(ModeBuffer, false);

   if(rates_total <= 0)
      return 0;

   if(prev_calculated == 0)
     {
      ArrayInitialize(Q50Buffer, EMPTY_VALUE);
      ArrayInitialize(QUPBuffer, EMPTY_VALUE);
      ArrayInitialize(QDNBuffer, EMPTY_VALUE);
      ArrayInitialize(ModeBuffer, EMPTY_VALUE);
     }

   const int start = (int)MathMax(prev_calculated - 1, warmup_bars);
   bool diagnostic_printed = false;
   for(int bar_index = 0; bar_index < MathMin(start, rates_total); bar_index++)
     {
      if(bar_index < warmup_bars)
        {
         Q50Buffer[bar_index] = EMPTY_VALUE;
         QUPBuffer[bar_index] = EMPTY_VALUE;
         QDNBuffer[bar_index] = EMPTY_VALUE;
         ModeBuffer[bar_index] = EMPTY_VALUE;
        }
     }

   for(int bar_index = start; bar_index < rates_total; bar_index++)
     {
      if(bar_index < warmup_bars)
        {
         Q50Buffer[bar_index] = EMPTY_VALUE;
         QUPBuffer[bar_index] = EMPTY_VALUE;
         QDNBuffer[bar_index] = EMPTY_VALUE;
         ModeBuffer[bar_index] = EMPTY_VALUE;
         continue;
        }

      double q50 = EMPTY_VALUE;
      double qup = EMPTY_VALUE;
      double qdn = EMPTY_VALUE;
      double mode = EMPTY_VALUE;
      if(CalculateDistribution(time[bar_index], q50, qup, qdn, mode))
        {
         Q50Buffer[bar_index] = q50;
         QUPBuffer[bar_index] = qup;
         QDNBuffer[bar_index] = qdn;
         ModeBuffer[bar_index] = mode;
        }
      else
        {
         Q50Buffer[bar_index] = EMPTY_VALUE;
         QUPBuffer[bar_index] = EMPTY_VALUE;
         QDNBuffer[bar_index] = EMPTY_VALUE;
         ModeBuffer[bar_index] = EMPTY_VALUE;
         if(debug_mode && !diagnostic_printed)
           {
            PrintFormat("WeightedPricePDF: source history or volume is insufficient at chart bar %d.", bar_index);
            diagnostic_printed = true;
           }
        }
     }

   return rates_total;
  }

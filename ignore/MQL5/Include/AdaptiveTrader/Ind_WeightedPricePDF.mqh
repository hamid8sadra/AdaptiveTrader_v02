//+------------------------------------------------------------------+
//|                                      WeightedPricePDF.mqh        |
//|                                   Copyright 2026, AdaptiveTrader |
//|                                           https://www.mql5.com   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, AdaptiveTrader"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "A volume-weighted price distribution indicator that estimates price quantiles and the most populated price level over a rolling candle window."
#property strict

class CWeightedPricePDF
  {
private:
   string m_symbol;
   int m_period;
   int m_upper_quantile;
   int m_lower_quantile;
   int m_histogram_bins;
   bool m_debug_mode;
   bool m_valid;
   double HistogramQuantile(const double &bin_weights[],const double minimum_price,const double bin_width,const double total_weight,const int percentile);
   bool CalculateDistribution(const datetime reference_time,double &q50,double &qup,double &qdn,double &mode);
public:
   //--- Construct the calculator with default inputs.
                     CWeightedPricePDF();
   //--- Release class resources.
                    ~CWeightedPricePDF();
   //--- Return output names in buffer order. Params: buffer_names; returns success.
   bool get_buffers_names(string &buffer_names[]);
   //--- Calculate outputs for a closed M1 bar time. Params: requested_M1_time, buffer_values; returns success.
   bool get_buffers_values(datetime requested_M1_time,double &buffer_values[]);
   //--- Set symbol and parameters from ordered CSV fields. Params: csv_string_inputs; returns success.
   bool set_inputs(string csv_string_inputs);
  };

CWeightedPricePDF::CWeightedPricePDF()
  {
   m_symbol=_Symbol;
   m_period=60;
   m_upper_quantile=95;
   m_lower_quantile=5;
   m_histogram_bins=100;
   m_debug_mode=false;
   m_valid=true;
  }

CWeightedPricePDF::~CWeightedPricePDF()
  {
  }

bool CWeightedPricePDF::get_buffers_names(string &buffer_names[])
  {
   if(ArrayResize(buffer_names,4)!=4) return false;
   buffer_names[0]="Q50"; buffer_names[1]="QUP"; buffer_names[2]="QDN"; buffer_names[3]="Mode";
   return true;
  }

bool CWeightedPricePDF::set_inputs(string csv_string_inputs)
  {
   string fields[];
   if(StringSplit(csv_string_inputs,',',fields)!=6) return false;
   string symbol=fields[0];
   int period=(int)StringToInteger(fields[1]);
   int upper=(int)StringToInteger(fields[2]);
   int lower=(int)StringToInteger(fields[3]);
   int bins=(int)StringToInteger(fields[4]);
   string debug_text=fields[5];
   StringToLower(debug_text);
   if(StringLen(symbol)==0 || period<30 || upper<65 || upper>95 || lower<5 || lower>35 || lower>=upper || bins<5 || bins>100 || (debug_text!="true" && debug_text!="false" && debug_text!="1" && debug_text!="0"))
     { m_valid=false; return false; }
   m_symbol=symbol; m_period=period; m_upper_quantile=upper; m_lower_quantile=lower; m_histogram_bins=bins;
   m_debug_mode=(debug_text=="true" || debug_text=="1");
   m_valid=true;
   return true;
  }

double CWeightedPricePDF::HistogramQuantile(const double &bin_weights[],const double minimum_price,const double bin_width,const double total_weight,const int percentile)
  {
   const double target_weight=total_weight*(double)percentile/100.0;
   double cumulative_weight=0.0;
   const int bins_count=ArraySize(bin_weights);
   for(int bin_index=0;bin_index<bins_count;bin_index++)
     {
      const double current_weight=bin_weights[bin_index];
      if(current_weight<=0.0) continue;
      const double previous_weight=cumulative_weight;
      cumulative_weight+=current_weight;
      if(target_weight<=cumulative_weight)
        {
         const double fraction=(target_weight-previous_weight)/current_weight;
         return minimum_price+((double)bin_index+fraction)*bin_width;
        }
     }
   return minimum_price+(double)bins_count*bin_width;
  }

bool CWeightedPricePDF::CalculateDistribution(const datetime reference_time,double &q50,double &qup,double &qdn,double &mode)
  {
   q50=EMPTY_VALUE; qup=EMPTY_VALUE; qdn=EMPTY_VALUE; mode=EMPTY_VALUE;
   const int source_shift=iBarShift(m_symbol,PERIOD_M1,reference_time-1,false);
   if(source_shift<0) return false;
   MqlRates source_rates[];
   ArraySetAsSeries(source_rates,true);
   const int copied_rates=CopyRates(m_symbol,PERIOD_M1,source_shift,m_period,source_rates);
   if(copied_rates!=m_period) return false;
   double minimum_price=source_rates[0].low, maximum_price=source_rates[0].high;
   for(int i=1;i<copied_rates;i++)
     { if(source_rates[i].low<minimum_price) minimum_price=source_rates[i].low; if(source_rates[i].high>maximum_price) maximum_price=source_rates[i].high; }
   if(maximum_price<=minimum_price)
     {
      double total_volume=0.0;
      for(int i=0;i<copied_rates;i++) total_volume+=(double)source_rates[i].tick_volume;
      if(total_volume<=0.0) return false;
      q50=NormalizeDouble(minimum_price,_Digits); qup=q50; qdn=q50; mode=q50; return true;
     }
   const double bin_width=(maximum_price-minimum_price)/(double)m_histogram_bins;
   if(bin_width<=0.0) return false;
   double bin_weights[];
   if(ArrayResize(bin_weights,m_histogram_bins)!=m_histogram_bins) return false;
   ArrayInitialize(bin_weights,0.0);
   double total_weight=0.0;
   for(int rate_index=0;rate_index<copied_rates;rate_index++)
     {
      const double candle_weight=(double)source_rates[rate_index].tick_volume;
      if(candle_weight<=0.0) continue;
      const double candle_low=source_rates[rate_index].low, candle_high=source_rates[rate_index].high;
      const double candle_range=candle_high-candle_low;
      if(candle_range<=0.0)
        {
         int point_bin=(int)MathFloor((candle_low-minimum_price)/bin_width);
         point_bin=(int)MathMax(0,MathMin(m_histogram_bins-1,point_bin));
         bin_weights[point_bin]+=candle_weight; total_weight+=candle_weight; continue;
        }
      int first_bin=(int)MathFloor((candle_low-minimum_price)/bin_width);
      int last_bin=(int)MathFloor((candle_high-minimum_price)/bin_width);
      first_bin=(int)MathMax(0,MathMin(m_histogram_bins-1,first_bin));
      last_bin=(int)MathMax(0,MathMin(m_histogram_bins-1,last_bin));
      double distributed_weight=0.0; int last_overlapping_bin=-1;
      for(int bin_index=first_bin;bin_index<=last_bin;bin_index++)
        {
         const double bin_low=minimum_price+(double)bin_index*bin_width, bin_high=bin_low+bin_width;
         const double overlap=MathMin(candle_high,bin_high)-MathMax(candle_low,bin_low);
         if(overlap<=0.0) continue;
         const double partial_weight=candle_weight*overlap/candle_range;
         bin_weights[bin_index]+=partial_weight; distributed_weight+=partial_weight; last_overlapping_bin=bin_index;
        }
      if(last_overlapping_bin>=0) { bin_weights[last_overlapping_bin]+=candle_weight-distributed_weight; total_weight+=candle_weight; }
     }
   if(total_weight<=0.0) return false;
   int mode_bin=0;
   for(int bin_index=1;bin_index<m_histogram_bins;bin_index++) if(bin_weights[bin_index]>bin_weights[mode_bin]) mode_bin=bin_index;
   q50=NormalizeDouble(HistogramQuantile(bin_weights,minimum_price,bin_width,total_weight,50),_Digits);
   qup=NormalizeDouble(HistogramQuantile(bin_weights,minimum_price,bin_width,total_weight,m_upper_quantile),_Digits);
   qdn=NormalizeDouble(HistogramQuantile(bin_weights,minimum_price,bin_width,total_weight,m_lower_quantile),_Digits);
   mode=NormalizeDouble(minimum_price+((double)mode_bin+0.5)*bin_width,_Digits);
   return true;
  }

bool CWeightedPricePDF::get_buffers_values(datetime requested_M1_time,double &buffer_values[])
  {
   if(!m_valid || requested_M1_time<=0 || ArrayResize(buffer_values,4)!=4) return false;
   const int shift=iBarShift(m_symbol,PERIOD_M1,requested_M1_time,true);
   if(shift<0 || iTime(m_symbol,PERIOD_M1,shift)!=requested_M1_time) return false;
   const int total_bars=Bars(m_symbol,PERIOD_M1);
   if(total_bars<=0) return false;
   if(total_bars-shift-1<m_period+2)
     {
      buffer_values[0]=EMPTY_VALUE; buffer_values[1]=EMPTY_VALUE; buffer_values[2]=EMPTY_VALUE; buffer_values[3]=EMPTY_VALUE;
      return true;
     }
   double q50,qup,qdn,mode;
   if(!CalculateDistribution(requested_M1_time,q50,qup,qdn,mode)) return false;
   buffer_values[0]=q50; buffer_values[1]=qup; buffer_values[2]=qdn; buffer_values[3]=mode;
   return true;
  }
//+------------------------------------------------------------------+

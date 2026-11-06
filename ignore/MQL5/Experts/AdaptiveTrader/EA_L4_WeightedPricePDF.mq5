//+------------------------------------------------------------------+
//|                                  EA_L4_WeightedPricePDF.mq5      |
//|                                   Copyright 2026, AdaptiveTrader |
//|                                           https://www.mql5.com   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, AdaptiveTrader"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Compares WeightedPricePDF indicator buffers with the class outputs."
#property strict

#include <AdaptiveTrader\Ind_WeightedPricePDF.mqh>

input int inp_period=60;
input int upper_quantile=95;
input int lower_quantile=5;
input int histogram_bins=100;
input bool show_Q50=true;
input bool show_QUP=true;
input bool show_QDN=true;
input bool show_Mode=true;
input bool debug_mode=false;

int g_indicator_handle=INVALID_HANDLE;
datetime g_last_m1_open=0;
int candles=0;
CWeightedPricePDF g_pdf;

int OnInit()
  {
   if(inp_period<30 || upper_quantile<65 || upper_quantile>95 || lower_quantile<5 || lower_quantile>35 || lower_quantile>=upper_quantile || histogram_bins<5 || histogram_bins>100)
      return INIT_PARAMETERS_INCORRECT;
   string csv_inputs=StringFormat("%s,%d,%d,%d,%d,%s",_Symbol,inp_period,upper_quantile,lower_quantile,histogram_bins,(debug_mode ? "true" : "false"));
   if(!g_pdf.set_inputs(csv_inputs)) return INIT_PARAMETERS_INCORRECT;
   g_indicator_handle=iCustom(_Symbol,PERIOD_M1,"AdaptiveTrader\\Ind_WeightedPricePDF",inp_period,upper_quantile,lower_quantile,histogram_bins,show_Q50,show_QUP,show_QDN,show_Mode,debug_mode);
   if(g_indicator_handle==INVALID_HANDLE)
     { PrintFormat("WeightedPricePDF test: iCustom failed, error=%d",GetLastError()); return INIT_FAILED; }
   g_last_m1_open=iTime(_Symbol,PERIOD_M1,0);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   if(g_indicator_handle!=INVALID_HANDLE) IndicatorRelease(g_indicator_handle);
  }

void OnTick()
  {
   // Comment("ok ",candles);
   const datetime current_m1_open=iTime(_Symbol,PERIOD_M1,0);
   if(current_m1_open==0 || current_m1_open==g_last_m1_open) return;
   g_last_m1_open=current_m1_open;
   const datetime closed_m1_open=iTime(_Symbol,PERIOD_M1,1);
   if(closed_m1_open==0) return;
   candles++;
   if(BarsCalculated(g_indicator_handle)<=1) return;
   const int shift=iBarShift(_Symbol,PERIOD_M1,closed_m1_open,true);
   if(shift<0) return;
   double indicator_values[4];
   for(int buffer_index=0;buffer_index<4;buffer_index++)
     {
      double one_value[1];
      if(CopyBuffer(g_indicator_handle,buffer_index,shift,1,one_value)!=1) return;
      indicator_values[buffer_index]=one_value[0];
     }
   double class_values[];
   if(!g_pdf.get_buffers_values(closed_m1_open,class_values)) return;
   for(int buffer_index=0;buffer_index<4;buffer_index++)
     {
      if(indicator_values[buffer_index]==EMPTY_VALUE && class_values[buffer_index]==EMPTY_VALUE) continue;
      if(indicator_values[buffer_index]==EMPTY_VALUE || class_values[buffer_index]==EMPTY_VALUE || NormalizeDouble(indicator_values[buffer_index],_Digits)!=NormalizeDouble(class_values[buffer_index],_Digits))
        {
         string names[]={"Q50","QUP","QDN","Mode"};
         PrintFormat("WeightedPricePDF mismatch at %s buffer %s: indicator=%s class=%s. Expert stopped.",TimeToString(closed_m1_open,TIME_DATE|TIME_MINUTES),names[buffer_index],DoubleToString(indicator_values[buffer_index],_Digits),DoubleToString(class_values[buffer_index],_Digits));
         ExpertRemove();
         return;
        }
     }
  }
//+------------------------------------------------------------------+

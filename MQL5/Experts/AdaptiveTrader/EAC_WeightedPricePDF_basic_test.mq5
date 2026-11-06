#property copyright "Copyright 2026, MetaQuotes Ltd."
#property version   "1.00"
#property strict

#include "..\..\Include\AdaptiveTrader\EAC_WeightedPricePDF_basic.mqh"

input string inp_symbol="";
input ENUM_WPDF_POSITION_TYPE inp_position_type=WPDF_BUY;
input double inp_lot_size=0.01;
input int inp_max_positions=1;
input int inp_period_base=60;
input int inp_period_step=0;
input int inp_price_step=-2;
input bool inp_debug_mode=false;
input ulong inp_magic_number=2601001;
input int inp_upper_quantile=95;
input int inp_lower_quantile=5;
input int inp_histogram_bins=100;
input int inp_O01=0; input int inp_O02=0; input int inp_O03=0; input int inp_O04=0; input int inp_O05=0; input int inp_O06=0; input int inp_O07=0;
input int inp_C01=0; input int inp_C02=0; input int inp_C03=0; input int inp_C04=0; input int inp_C05=0; input int inp_C06=0; input int inp_C07=0;

CEACWeightedPricePDFBasic g_expert;

int OnInit()
  {
   if(!g_expert.m_SetInputs(inp_symbol,inp_position_type,inp_lot_size,inp_max_positions,inp_period_base,inp_period_step,inp_price_step,
      inp_upper_quantile,inp_lower_quantile,inp_histogram_bins,inp_debug_mode,inp_magic_number,
      inp_O01,inp_O02,inp_O03,inp_O04,inp_O05,inp_O06,inp_O07,inp_C01,inp_C02,inp_C03,inp_C04,inp_C05,inp_C06,inp_C07)) return INIT_PARAMETERS_INCORRECT;
   return g_expert.m_OnInit();
  }

void OnTick() { g_expert.m_OnTick(); }

void OnDeinit(const int reason) { g_expert.m_OnDeinit(reason); }

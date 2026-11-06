#ifndef EAC_WEIGHTEDPRICEPDF_BASIC_MQH
#define EAC_WEIGHTEDPRICEPDF_BASIC_MQH

#property strict
#include <Trade/Trade.mqh>
#include "IndC_WeightedPricePDF.mqh"

enum ENUM_WPDF_POSITION_TYPE { WPDF_BUY=0, WPDF_SELL=1 };

class CEACWeightedPricePDFBasic
  {
private:
   string m_symbol;
   ENUM_WPDF_POSITION_TYPE m_position_type;
   double m_lot_size;
   int m_max_positions,m_period_base,m_period_step,m_price_step;
   bool m_debug_mode;
   ulong m_magic_number;
   int m_upper_quantile,m_lower_quantile,m_histogram_bins;
   int m_open_rules[7],m_close_rules[7];
   CTrade m_trade;
   CWeightedPricePDF m_pdf;
   string m_buffer_names[];
   datetime m_last_bar_time;
   int m_actual_period,m_open_count,m_close_count;
   bool m_previous_open_condition,m_has_entry_price,m_initialized;
   double m_current_bid,m_current_ask,m_last_max_entry_price,m_last_min_entry_price;

   void DebugPrint(const string text) { if(m_debug_mode) Print("[EAC_WeightedPricePDF_basic] ",text); }
   int CalculateActualPeriod() const { int p=(int)((double)m_period_base*MathPow(1.6,m_period_step)); return (p<1 ? 1 : p); }
   bool CompareValues(const double left,const double right,const int relation) const
     { if(relation==0) return true; if(relation==1) return left>right; if(relation==-1) return left<right; return false; }
   double DecisionPrice() const { return (m_position_type==WPDF_BUY ? m_current_ask : m_current_bid); }
   int CountManagedPositions() const
     {
      int count=0;
      for(int i=PositionsTotal()-1;i>=0;--i)
        { ulong ticket=PositionGetTicket(i); if(ticket==0) continue;
          if(PositionGetString(POSITION_SYMBOL)==m_symbol && (ulong)PositionGetInteger(POSITION_MAGIC)==m_magic_number) ++count; }
      return count;
     }
   bool GetValues(const datetime bar_time,double &q50,double &qup,double &qdn,double &mode)
     {
      double values[]; if(!m_pdf.get_buffers_values(bar_time,values) || ArraySize(values)!=4) return false;
      int i50=-1,iup=-1,idn=-1,imode=-1;
      for(int i=0;i<ArraySize(m_buffer_names);++i)
        { if(m_buffer_names[i]=="Q50") i50=i; else if(m_buffer_names[i]=="QUP") iup=i; else if(m_buffer_names[i]=="QDN") idn=i; else if(m_buffer_names[i]=="Mode") imode=i; }
      if(i50<0 || iup<0 || idn<0 || imode<0) return false;
      q50=values[i50]; qup=values[iup]; qdn=values[idn]; mode=values[imode];
      return (q50!=EMPTY_VALUE && qup!=EMPTY_VALUE && qdn!=EMPTY_VALUE && mode!=EMPTY_VALUE);
     }
   bool Evaluate(const double q50,const double qup,const double qdn,const double mode,const int &rules[]) const
     {
      const double p=DecisionPrice();
      return CompareValues(p,q50,rules[0]) && CompareValues(p,qup,rules[1]) && CompareValues(p,qdn,rules[2]) &&
             CompareValues(p,mode,rules[3]) && CompareValues(mode,q50,rules[4]) && CompareValues(mode,qup,rules[5]) && CompareValues(mode,qdn,rules[6]);
     }
   bool HasRule(const int &rules[]) const { for(int i=0;i<7;++i) if(rules[i]!=0) return true; return false; }
   void RegisterEntry(const double price)
     {
      if(price<=0.0) return;
      if(!m_has_entry_price) { m_last_max_entry_price=price; m_last_min_entry_price=price; m_has_entry_price=true; }
      else { if(price>m_last_max_entry_price) m_last_max_entry_price=price; if(price<m_last_min_entry_price) m_last_min_entry_price=price; }
     }
   bool CanOpen(const double price) const
     {
      if(!m_has_entry_price) return true;
      const double distance=price*MathPow(1.6,m_price_step)/100.0;
      if(!MathIsValidNumber(distance) || distance<=0.0) return false;
      const double candidate=DecisionPrice();
      return candidate>m_last_max_entry_price+distance || candidate<m_last_min_entry_price-distance;
     }
   bool OpenPosition()
     {
      m_trade.SetExpertMagicNumber(m_magic_number);
      bool result=(m_position_type==WPDF_BUY ? m_trade.Buy(m_lot_size,m_symbol,0.0,0.0,0.0,"EA_L3_WeightedPricePDF") : m_trade.Sell(m_lot_size,m_symbol,0.0,0.0,0.0,"EA_L3_WeightedPricePDF"));
      if(result) { ++m_open_count; double price=m_trade.ResultPrice(); if(price<=0.0) price=(m_position_type==WPDF_BUY ? m_current_ask : m_current_bid); RegisterEntry(price); }
      else DebugPrint(StringFormat("OPEN FAILED | retcode=%u | %s",m_trade.ResultRetcode(),m_trade.ResultRetcodeDescription()));
      return result;
     }
   void CloseAllPositions()
     {
      m_trade.SetExpertMagicNumber(m_magic_number);
      for(int i=PositionsTotal()-1;i>=0;--i)
        { ulong ticket=PositionGetTicket(i); if(ticket==0) continue;
          if(PositionGetString(POSITION_SYMBOL)!=m_symbol || (ulong)PositionGetInteger(POSITION_MAGIC)!=m_magic_number) continue;
          if(m_trade.PositionClose(ticket)) ++m_close_count;
          else DebugPrint(StringFormat("CLOSE FAILED | ticket=%I64u | retcode=%u | %s",ticket,m_trade.ResultRetcode(),m_trade.ResultRetcodeDescription())); }
      if(CountManagedPositions()==0) { m_last_max_entry_price=0.0; m_last_min_entry_price=0.0; m_has_entry_price=false; }
     }
   void ProcessNewBar(const datetime bar_time)
     {
      double q50,qup,qdn,mode;
      if(!GetValues(bar_time,q50,qup,qdn,mode)) { DebugPrint("Data unavailable for this bar."); return; }
      MqlTick tick; if(!SymbolInfoTick(m_symbol,tick) || tick.bid<=0.0 || tick.ask<=0.0) return;
      m_current_bid=tick.bid; m_current_ask=tick.ask;
      const bool open_condition=(HasRule(m_open_rules) && Evaluate(q50,qup,qdn,mode,m_open_rules));
      const bool open_edge=open_condition && !m_previous_open_condition;
      m_previous_open_condition=open_condition;
      int positions=CountManagedPositions();
      if(positions>0 && HasRule(m_close_rules) && Evaluate(q50,qup,qdn,mode,m_close_rules)) { CloseAllPositions(); return; }
      if(open_edge && m_max_positions>0 && positions<m_max_positions && CanOpen(DecisionPrice())) OpenPosition();
      if(m_debug_mode) DebugPrint(StringFormat("BAR | time=%s | bid=%.*f | ask=%.*f | Q50=%.*f | QUP=%.*f | QDN=%.*f | Mode=%.*f | positions=%d/%d | open=%d | edge=%d",
         TimeToString(bar_time,TIME_DATE|TIME_MINUTES),_Digits,m_current_bid,_Digits,m_current_ask,_Digits,q50,_Digits,qup,_Digits,qdn,_Digits,mode,CountManagedPositions(),m_max_positions,(int)open_condition,(int)open_edge));
     }

public:
   //--- Construct with the current chart symbol and source expert defaults.
   CEACWeightedPricePDFBasic()
     {
      m_symbol=_Symbol; m_position_type=WPDF_BUY; m_lot_size=0.01; m_max_positions=1;
      m_period_base=60; m_period_step=0; m_price_step=-2; m_debug_mode=false; m_magic_number=2601001;
      m_upper_quantile=95; m_lower_quantile=5; m_histogram_bins=100;
      ArrayInitialize(m_open_rules,0); ArrayInitialize(m_close_rules,0);
      m_last_bar_time=0; m_actual_period=0; m_open_count=0; m_close_count=0; m_previous_open_condition=false;
      m_has_entry_price=false; m_initialized=false; m_current_bid=0.0; m_current_ask=0.0; m_last_max_entry_price=0.0; m_last_min_entry_price=0.0;
     }
   //--- Configure all expert inputs. Params: symbol, direction, size, capacity, period settings, PDF settings, debug, magic, and seven open/close relations; returns true when accepted.
   bool m_SetInputs(const string symbol="",const ENUM_WPDF_POSITION_TYPE direction=WPDF_BUY,const double lot_size=0.01,const int max_positions=1,
                    const int period_base=60,const int period_step=0,const int price_step=-2,const int upper_quantile=95,const int lower_quantile=5,
                    const int histogram_bins=100,const bool debug_mode=false,const ulong magic_number=2601001,
                    const int o01=0,const int o02=0,const int o03=0,const int o04=0,const int o05=0,const int o06=0,const int o07=0,
                    const int c01=0,const int c02=0,const int c03=0,const int c04=0,const int c05=0,const int c06=0,const int c07=0)
     {
      m_symbol=(StringLen(symbol)==0 ? _Symbol : symbol); m_position_type=direction; m_lot_size=lot_size; m_max_positions=max_positions;
      m_period_base=period_base; m_period_step=period_step; m_price_step=price_step; m_upper_quantile=upper_quantile; m_lower_quantile=lower_quantile;
      m_histogram_bins=histogram_bins; m_debug_mode=debug_mode; m_magic_number=magic_number;
      m_open_rules[0]=o01; m_open_rules[1]=o02; m_open_rules[2]=o03; m_open_rules[3]=o04; m_open_rules[4]=o05; m_open_rules[5]=o06; m_open_rules[6]=o07;
      m_close_rules[0]=c01; m_close_rules[1]=c02; m_close_rules[2]=c03; m_close_rules[3]=c04; m_close_rules[4]=c05; m_close_rules[5]=c06; m_close_rules[6]=c07;
      return (StringLen(m_symbol)>0 && (direction==WPDF_BUY || direction==WPDF_SELL) && lot_size>0.0 && max_positions>=0 &&
              period_base>0 && upper_quantile>=65 && upper_quantile<=95 && lower_quantile>=5 && lower_quantile<=35 && lower_quantile<upper_quantile && histogram_bins>=5 && histogram_bins<=100);
     }
   //--- Initialize and configure the PDF calculator and bar tracking. Params: none; returns INIT_SUCCEEDED or an initialization error code.
   int m_OnInit()
     {
      m_initialized=false; m_trade.SetExpertMagicNumber(m_magic_number);
      m_actual_period=CalculateActualPeriod(); if(m_max_positions<0 || m_lot_size<=0.0 || m_actual_period<30) return INIT_PARAMETERS_INCORRECT;
      string csv=StringFormat("%s,%d,%d,%d,%d,%s",m_symbol,m_actual_period,m_upper_quantile,m_lower_quantile,m_histogram_bins,(m_debug_mode ? "true" : "false"));
      if(!m_pdf.set_inputs(csv) || !m_pdf.get_buffers_names(m_buffer_names) || ArraySize(m_buffer_names)!=4) return INIT_FAILED;
      m_last_bar_time=iTime(m_symbol,PERIOD_M1,0); m_previous_open_condition=false; m_last_max_entry_price=0.0; m_last_min_entry_price=0.0; m_has_entry_price=false;
      m_initialized=true; return INIT_SUCCEEDED;
     }
   //--- Handle a tick and process each newly closed M1 bar once. Params: none; returns nothing.
   void m_OnTick()
     {
      if(!m_initialized) return;
      const datetime current=iTime(m_symbol,PERIOD_M1,0); if(current==0 || current==m_last_bar_time) return;
      m_last_bar_time=current; const datetime closed=iTime(m_symbol,PERIOD_M1,1); if(closed>0) ProcessNewBar(closed);
     }
   //--- Deinitialize and print run summary. Params: reason, as passed to OnDeinit; returns nothing.
   void m_OnDeinit(const int reason)
     {
      if(!m_initialized) return;
      Print(StringFormat("[EAC_WeightedPricePDF_basic] SUMMARY | symbol=%s | period=%d | step=%d | Price_step=%d | direction=%s | opened=%d | closed=%d | reason=%d",
         m_symbol,m_period_base,m_period_step,m_price_step,(m_position_type==WPDF_BUY ? "BUY" : "SELL"),m_open_count,m_close_count,reason));
      m_initialized=false;
     }
  };

#endif

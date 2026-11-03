//+------------------------------------------------------------------+
//|                                       EA_L3_WeightedPricePDF.mq5 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Normal / BackTest / Optimizer modes"
#property strict

#include <Trade/Trade.mqh>

CTrade trade;

//--- Enumerations
enum PositionType
{
   BUY,
   SELL
};

enum Inp_Mode
{
   Normal,
   BackTest,
   Optimizer
};

//--- General inputs
input Inp_Mode      inp_mode = Normal;
input PositionType  position_type = BUY;
input double        lot_size = 0.01;
input int           max_positions = 1;

input int           period_base = 60;
input int           period_step = 0;

input bool          show_lines = true;
input int           Price_step = -2;

input bool          debug_mode = false;
input ulong         magic_number = 2601001;

//--- WeightedPricePDF indicator inputs 

input int           upper_quantile = 95;
input int           lower_quantile = 5;
input int           histogram_bins = 100;


// 1 = left > right
// -1 = left < right
// 0 = ignored

//--- Open conditions
input int O01 = 0; // price vs Q50
input int O02 = 0; // price vs QUP
input int O03 = 0; // price vs QDN
input int O04 = 0; // price vs Mode
input int O05 = 0; // Mode vs Q50
input int O06 = 0; // Mode vs QUP
input int O07 = 0; // Mode vs QDN


//--- Close conditions
input int C01 = 0; // price vs Q50
input int C02 = 0; // price vs QUP
input int C03 = 0; // price vs QDN
input int C04 = 0; // price vs Mode
input int C05 = 0; // Mode vs Q50
input int C06 = 0; // Mode vs QUP
input int C07 = 0; // Mode vs QDN


//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+

string INDICATOR_NAME =
   "AdaptiveTrader\\Ind_WeightedPricePDF";

int      g_indicator_handle = INVALID_HANDLE;

datetime g_last_bar_time = 0;

int      g_actual_period = 0;

int      g_open_count = 0;
int      g_close_count = 0;

double   g_last_Q50 = 0.0;
double   g_last_QUP = 0.0;
double   g_last_QDN = 0.0;
double   g_last_Mode = 0.0;


bool     g_previous_open_condition = false;

double   g_current_bid = 0.0;
double   g_current_ask = 0.0;

int      g_data_file = INVALID_HANDLE;
string   g_data_filename = "";

double   g_last_max_entry_price = 0.0;
double   g_last_min_entry_price = 0.0;
bool     g_has_entry_price = false;


//+------------------------------------------------------------------+
//| Indicator record                                                 |
//+------------------------------------------------------------------+

struct IndicatorRecord
{
   datetime time;

   double Q50;
   double QUP;
   double QDN;
   double Mode;


   double bid;
   double ask;
};

IndicatorRecord g_records[];

int g_record_count = 0;


//+------------------------------------------------------------------+
//| Debug output                                                     |
//+------------------------------------------------------------------+

void DebugPrint(const string text)
{
   if(debug_mode)
      Print("[EA_L3_WeightedPricePDF] ", text);
}


//+------------------------------------------------------------------+
//| Calculate actual indicator period                               |
//+------------------------------------------------------------------+

int CalculateActualPeriod()
{
   int period =
      (int)((double)period_base * MathPow(1.6, period_step));

   return (period < 1 ? 1 : period);
}


//+------------------------------------------------------------------+
//| Shared data filename                                             |
//+------------------------------------------------------------------+

string BuildDataFilename()
{
   return StringFormat("AdaptiveTrader\\Ad_%s_M1_%d_%d_%d_%d_%d.csv",
      _Symbol, period_base, period_step, upper_quantile, lower_quantile, histogram_bins);
}


//+------------------------------------------------------------------+
//| Create indicator                                                 |
//+------------------------------------------------------------------+

bool CreateIndicator()
{
   g_actual_period = CalculateActualPeriod();

   if(g_actual_period < 30)
   {
      Print(
         "[EA_L3_WeightedPricePDF] ERROR: Indicator period "
         "must be >= 30. Actual period=",
         g_actual_period
      );

      return false;
   }

   ResetLastError();

    g_indicator_handle = iCustom(
    _Symbol,
    PERIOD_M1,
    INDICATOR_NAME,

    g_actual_period,
    upper_quantile,
    lower_quantile,
    histogram_bins,
    true,
    true,
    true,
    true,
    debug_mode
    );

   if(g_indicator_handle == INVALID_HANDLE)
   {
      Print(
         "[EA_L3_WeightedPricePDF] ERROR: Cannot create indicator. ",
         "Name=",
         INDICATOR_NAME,
         " Error=",
         GetLastError()
      );

      return false;
   }

   if(show_lines)
   {
      if(!ChartIndicatorAdd(0, 0, g_indicator_handle))
      {
         DebugPrint(
            StringFormat(
               "ChartIndicatorAdd failed. Error=%d",
               GetLastError()
            )
         );
      }
   }

   DebugPrint(
      StringFormat(
         "Indicator created. period=%d period_step=%d",
         g_actual_period,
         period_step
      )
   );

   return true;
}


//+------------------------------------------------------------------+
//| Read indicator values from previous closed bar                  |
//+------------------------------------------------------------------+

bool GetIndicatorValues(double &Q50, double &QUP, double &QDN, double &Mode)
{
   if(g_indicator_handle == INVALID_HANDLE || BarsCalculated(g_indicator_handle) <= 1) return false;
   double b_Q50[1], b_QUP[1], b_QDN[1], b_Mode[1];
   if(CopyBuffer(g_indicator_handle,0,1,1,b_Q50)!=1 || CopyBuffer(g_indicator_handle,1,1,1,b_QUP)!=1 ||
      CopyBuffer(g_indicator_handle,2,1,1,b_QDN)!=1 || CopyBuffer(g_indicator_handle,3,1,1,b_Mode)!=1) return false;
   Q50=b_Q50[0]; QUP=b_QUP[0]; QDN=b_QDN[0]; Mode=b_Mode[0];
   if(Q50==EMPTY_VALUE || QUP==EMPTY_VALUE || QDN==EMPTY_VALUE || Mode==EMPTY_VALUE) return false;
   return true;
}


//+------------------------------------------------------------------+
//| Compare values                                                   |
//+------------------------------------------------------------------+

bool CompareValues(
   const double left,
   const double right,
   const int relation
)
{
   if(relation == 0)
      return true;

   if(relation == 1)
      return left > right;

   if(relation == -1)
      return left < right;

   return false;
}


//+------------------------------------------------------------------+
//| Get executable price                                             |
//+------------------------------------------------------------------+

double GetDecisionPrice()
{
   if(position_type == BUY)
      return g_current_ask;

   return g_current_bid;
}


//+------------------------------------------------------------------+
//| Evaluate open conditions                                         |
//+------------------------------------------------------------------+

bool EvaluateOpenConditions(const double Q50,const double QUP,const double QDN,const double Mode)
{
   const double price=GetDecisionPrice();
   return CompareValues(price,Q50,O01) && CompareValues(price,QUP,O02) && CompareValues(price,QDN,O03) &&
      CompareValues(price,Mode,O04) && CompareValues(Mode,Q50,O05) && CompareValues(Mode,QUP,O06) && CompareValues(Mode,QDN,O07);
}


//+------------------------------------------------------------------+
//| Evaluate close conditions                                        |
//+------------------------------------------------------------------+

bool EvaluateCloseConditions(const double Q50,const double QUP,const double QDN,const double Mode)
{
   const double price=GetDecisionPrice();
   return CompareValues(price,Q50,C01) && CompareValues(price,QUP,C02) && CompareValues(price,QDN,C03) &&
      CompareValues(price,Mode,C04) && CompareValues(Mode,Q50,C05) && CompareValues(Mode,QUP,C06) && CompareValues(Mode,QDN,C07);
}


//+------------------------------------------------------------------+
//| Check whether any open condition is enabled                      |
//+------------------------------------------------------------------+

bool HasOpenCondition()
{
   return O01!=0 || O02!=0 || O03!=0 || O04!=0 || O05!=0 || O06!=0 || O07!=0;
}


//+------------------------------------------------------------------+
//| Check whether any close condition is enabled                     |
//+------------------------------------------------------------------+

bool HasCloseCondition()
{
   return C01!=0 || C02!=0 || C03!=0 || C04!=0 || C05!=0 || C06!=0 || C07!=0;
}


//+------------------------------------------------------------------+
//| Count managed positions                                          |
//+------------------------------------------------------------------+

int CountManagedPositions()
{
   int count = 0;

   for(int i = PositionsTotal() - 1; i >= 0; --i)
   {
      ulong ticket = PositionGetTicket(i);

      if(ticket == 0)
         continue;

      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;

      if((ulong)PositionGetInteger(POSITION_MAGIC) != magic_number)
         continue;

      ++count;
   }

   return count;
}


//+------------------------------------------------------------------+
//| Update entry-price extremes after successful trade               |
//+------------------------------------------------------------------+

void RegisterEntryPrice(const double entry_price)
{
   if(entry_price <= 0.0)
      return;

   if(!g_has_entry_price)
   {
      g_last_max_entry_price = entry_price;
      g_last_min_entry_price = entry_price;

      g_has_entry_price = true;
   }
   else
   {
      if(entry_price > g_last_max_entry_price)
         g_last_max_entry_price = entry_price;

      if(entry_price < g_last_min_entry_price)
         g_last_min_entry_price = entry_price;
   }

   DebugPrint(
      StringFormat(
         "ENTRY RANGE UPDATED | price=%.5f | min=%.5f | max=%.5f",
         entry_price,
         g_last_min_entry_price,
         g_last_max_entry_price
      )
   );
}


//+------------------------------------------------------------------+
//| Calculate minimum distance for a new entry                       |
//+------------------------------------------------------------------+

double CalculateMinPriceMove(const double Price)
{
   return Price * MathPow(1.6, Price_step) / 100.0;
}


//+------------------------------------------------------------------+
//| Final entry-distance filter                                      |
//+------------------------------------------------------------------+

bool CanOpenAtCurrentPrice(const double Price)
{
   // First trade is not restricted.
   if(!g_has_entry_price)
      return true;

   double min_price_move = CalculateMinPriceMove(Price);

   if(!MathIsValidNumber(min_price_move) ||
      min_price_move <= 0.0)
   {
      DebugPrint("ENTRY BLOCKED | Invalid minimum price movement.");

      return false;
   }

   double candidate_price = GetDecisionPrice();

   bool outside_upper =
      candidate_price >
      g_last_max_entry_price + min_price_move;

   bool outside_lower =
      candidate_price <
      g_last_min_entry_price - min_price_move;

   bool allowed = outside_upper || outside_lower;

   if(!allowed)
   {
      DebugPrint(
         StringFormat(
            "ENTRY BLOCKED BY DISTANCE | type=%s | price=%.5f | "
            "min=%.5f | max=%.5f | required_distance=%.5f",
            EnumToString(position_type),
            candidate_price,
            g_last_min_entry_price,
            g_last_max_entry_price,
            min_price_move
         )
      );
   }
   else
   {
      DebugPrint(
         StringFormat(
            "ENTRY DISTANCE PASSED | type=%s | price=%.5f | "
            "min=%.5f | max=%.5f | required_distance=%.5f",
            EnumToString(position_type),
            candidate_price,
            g_last_min_entry_price,
            g_last_max_entry_price,
            min_price_move
         )
      );
   }

   return allowed;
}


//+------------------------------------------------------------------+
//| Open BUY                                                         |
//+------------------------------------------------------------------+

bool OpenBuy()
{
   trade.SetExpertMagicNumber(magic_number);

   bool result = trade.Buy(
      lot_size,
      _Symbol,
      0.0,
      0.0,
      0.0,
      "EA_L3_WeightedPricePDF"
   );

   if(result)
   {
      ++g_open_count;

      double entry_price = trade.ResultPrice();

      if(entry_price <= 0.0)
         entry_price = g_current_ask;

      RegisterEntryPrice(entry_price);

      DebugPrint(
         StringFormat(
            "OPEN BUY | lot=%.2f | price=%.5f | positions=%d/%d",
            lot_size,
            entry_price,
            CountManagedPositions(),
            max_positions
         )
      );
   }
   else
   {
      DebugPrint(
         StringFormat(
            "OPEN BUY FAILED | retcode=%u | %s",
            trade.ResultRetcode(),
            trade.ResultRetcodeDescription()
         )
      );
   }

   return result;
}


//+------------------------------------------------------------------+
//| Open SELL                                                        |
//+------------------------------------------------------------------+

bool OpenSell()
{
   trade.SetExpertMagicNumber(magic_number);

   bool result = trade.Sell(
      lot_size,
      _Symbol,
      0.0,
      0.0,
      0.0,
      "EA_L3_WeightedPricePDF"
   );

   if(result)
   {
      ++g_open_count;

      double entry_price = trade.ResultPrice();

      if(entry_price <= 0.0)
         entry_price = g_current_bid;

      RegisterEntryPrice(entry_price);

      DebugPrint(
         StringFormat(
            "OPEN SELL | lot=%.2f | price=%.5f | positions=%d/%d",
            lot_size,
            entry_price,
            CountManagedPositions(),
            max_positions
         )
      );
   }
   else
   {
      DebugPrint(
         StringFormat(
            "OPEN SELL FAILED | retcode=%u | %s",
            trade.ResultRetcode(),
            trade.ResultRetcodeDescription()
         )
      );
   }

   return result;
}


//+------------------------------------------------------------------+
//| Open position according to configured direction                 |
//+------------------------------------------------------------------+

bool OpenPosition()
{
   if(position_type == BUY)
      return OpenBuy();

   if(position_type == SELL)
      return OpenSell();

   return false;
}


//+------------------------------------------------------------------+
//| Close all managed positions                                      |
//+------------------------------------------------------------------+

void CloseAllPositions()
{
   trade.SetExpertMagicNumber(magic_number);

   for(int i = PositionsTotal() - 1; i >= 0; --i)
   {
      ulong ticket = PositionGetTicket(i);

      if(ticket == 0)
         continue;

      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;

      if((ulong)PositionGetInteger(POSITION_MAGIC) != magic_number)
         continue;

      if(trade.PositionClose(ticket))
      {
         ++g_close_count;

         DebugPrint(
            StringFormat(
               "CLOSE SUCCESS | ticket=%I64u | price=%.5f",
               ticket,
               g_current_bid
            )
         );
      }
      else
      {
         DebugPrint(
            StringFormat(
               "CLOSE FAILED | ticket=%I64u | retcode=%u | %s",
               ticket,
               trade.ResultRetcode(),
               trade.ResultRetcodeDescription()
            )
         );
      }
   }

   int remaining = CountManagedPositions();

   DebugPrint(
      StringFormat(
         "CLOSE ALL FINISHED | remaining_positions=%d",
         remaining
      )
   );

   if(remaining == 0)
   {
      g_last_max_entry_price = 0.0;
      g_last_min_entry_price = 0.0;
      g_has_entry_price = false;
   }
}


//+------------------------------------------------------------------+
//| Create CSV for BackTest mode                                     |
//+------------------------------------------------------------------+

bool OpenBackTestDataFile()
{
   ResetLastError();

   FolderCreate("AdaptiveTrader", FILE_COMMON);

   g_data_filename = BuildDataFilename();

   g_data_file = FileOpen(
      g_data_filename,
      FILE_WRITE |
      FILE_CSV |
      FILE_COMMON |
      FILE_ANSI |
      FILE_SHARE_READ |
      FILE_SHARE_WRITE,
      ';'
   );

   if(g_data_file == INVALID_HANDLE)
   {
      Print(
         "[EA_L3_WeightedPricePDF] ERROR: Cannot create data file ",
         g_data_filename,
         " Error=",
         GetLastError()
      );

      return false;
   }

   FileWrite(
      g_data_file,
      "time",
      "bid",
      "ask",
      "Q50",
      "QUP",
      "QDN",
      "Mode"
   );

   FileFlush(g_data_file);

   return true;
}


//+------------------------------------------------------------------+
//| Write one BackTest data record                                   |
//+------------------------------------------------------------------+

bool WriteBackTestRecord(
   const datetime bar_time,
   const double bid,
   const double ask,
   const double Q50,
   const double QUP,
   const double QDN,
   const double Mode
)
{
   if(g_data_file == INVALID_HANDLE)
      return false;

   uint written = FileWrite(
      g_data_file,

      TimeToString(bar_time, TIME_DATE | TIME_SECONDS),
	  
      DoubleToString(bid, _Digits),
      DoubleToString(ask, _Digits),

      DoubleToString(Q50, _Digits),
      DoubleToString(QUP, _Digits),
      DoubleToString(QDN, _Digits),
      DoubleToString(Mode, _Digits)
   );

   FileFlush(g_data_file);

   return (written > 0);
}


//+------------------------------------------------------------------+
//| Load shared CSV for Optimizer mode                               |
//+------------------------------------------------------------------+

bool LoadOptimizerData()
{
   g_data_filename = BuildDataFilename();

   while(!IsStopped())
   {
      ResetLastError();

      int handle = FileOpen(
         g_data_filename,
         FILE_READ |
         FILE_CSV |
         FILE_COMMON |
         FILE_ANSI |
         FILE_SHARE_READ |
         FILE_SHARE_WRITE,
         ';'
      );

      if(handle == INVALID_HANDLE)
      {
         Print(
            "[EA_L3_WeightedPricePDF] Waiting for data file: ",
            g_data_filename,
            " Error=",
            GetLastError()
         );

         Sleep(250);

         continue;
      }

      // Skip CSV header fields.
      for(int k = 0; k < 7 && !FileIsEnding(handle); ++k) 
         FileReadString(handle);

      ArrayResize(g_records, 0);

      g_record_count = 0;

      bool malformed = false;

      while(!FileIsEnding(handle))
      {
         string time_text = FileReadString(handle);

         if(time_text == "" && FileIsEnding(handle))
            break;
         string s_bid  = FileReadString(handle);
         string s_ask  = FileReadString(handle);
         string s_Q50  = FileReadString(handle);
         string s_QUP  = FileReadString(handle);
         string s_QDN  = FileReadString(handle);
         string s_Mode = FileReadString(handle);



         if(time_text == "" ||
            s_bid == "" ||
            s_ask == "" ||
            s_Q50 == "" ||
            s_QUP == "" || s_QDN == "" || s_Mode == "")
         {
            malformed = true;
            break;
         }

         datetime record_time = StringToTime(time_text);

         if(record_time <= 0)
         {
            malformed = true;
            break;
         }

         int n = g_record_count;

         if(ArrayResize(g_records, n + 1, 4096) != n + 1)
         {
            malformed = true;
            break;
         }

         g_records[n].time = record_time;

         g_records[n].bid = StringToDouble(s_bid);
         g_records[n].ask = StringToDouble(s_ask);
		 
         g_records[n].Q50  = StringToDouble(s_Q50);
         g_records[n].QUP  = StringToDouble(s_QUP);
         g_records[n].QDN  = StringToDouble(s_QDN);
         g_records[n].Mode = StringToDouble(s_Mode);



         if(g_records[n].bid <= 0.0 ||
            g_records[n].ask <= 0.0 ||
            !MathIsValidNumber(g_records[n].Q50) ||
            !MathIsValidNumber(g_records[n].QUP) ||
            !MathIsValidNumber(g_records[n].QDN) ||
            !MathIsValidNumber(g_records[n].Mode))
         {
            malformed = true;
            break;
         }

         if(n > 0 &&
            g_records[n].time <= g_records[n - 1].time)
         {
            malformed = true;
            break;
         }

         ++g_record_count;
      }

      FileClose(handle);

      if(!malformed && g_record_count > 0)
      {
         DebugPrint(
            StringFormat(
               "Loaded %d records from %s",
               g_record_count,
               g_data_filename
            )
         );

         return true;
      }

      Print(
         "[EA_L3_WeightedPricePDF] Data file empty/incomplete "
         "or malformed; retrying: ",
         g_data_filename
      );

      ArrayResize(g_records, 0);

      g_record_count = 0;

      Sleep(250);
   }

   return false;
}


//+------------------------------------------------------------------+
//| Binary search for record by bar time                             |
//+------------------------------------------------------------------+

int FindRecordByTime(const datetime bar_time)
{
   int left = 0;
   int right = g_record_count - 1;

   while(left <= right)
   {
      int mid = left + (right - left) / 2;

      if(g_records[mid].time == bar_time)
         return mid;

      if(g_records[mid].time < bar_time)
         left = mid + 1;
      else
         right = mid - 1;
   }

   return -1;
}


//+------------------------------------------------------------------+
//| Get current indicator and market data                            |
//+------------------------------------------------------------------+

bool GetCurrentData(
   const datetime bar_time,
   double &Q50,
   double &QUP,
   double &QDN,
   double &Mode
)
{
   //--- Optimizer mode reads only from CSV.
   if(inp_mode == Optimizer)
   {
      int index = FindRecordByTime(bar_time);

      if(index < 0)
      {
         Print(
            "[EA_L3_WeightedPricePDF] No CSV record for bar time ",
            TimeToString(bar_time, TIME_DATE | TIME_MINUTES),
            ". Bar skipped."
         );

         return false;
      }

      g_current_bid = g_records[index].bid;
      g_current_ask = g_records[index].ask;
	  
      Q50  = g_records[index].Q50;
      QUP  = g_records[index].QUP;
      QDN  = g_records[index].QDN;
      Mode = g_records[index].Mode;



      return true;
   }

   //--- Normal and BackTest modes read the indicator.
   if(!GetIndicatorValues(Q50, QUP, QDN, Mode)) 
      return false;

   MqlTick tick;

   if(!SymbolInfoTick(_Symbol, tick))
      return false;

   if(tick.bid <= 0.0 || tick.ask <= 0.0)
      return false;

   g_current_bid = tick.bid;
   g_current_ask = tick.ask;

   //--- BackTest mode records data and never trades.
   if(inp_mode == BackTest)
   {
      if(!WriteBackTestRecord(
         bar_time,
         g_current_bid,
         g_current_ask,
         Q50,
         QUP,
         QDN,
         Mode
      ))
      {
         Print(
            "[EA_L3_WeightedPricePDF] ERROR writing CSV record. Error=",
            GetLastError()
         );

         return false;
      }
   }

   return true;
}


//+------------------------------------------------------------------+
//| Process a new bar                                                |
//+------------------------------------------------------------------+

void ProcessNewBar(const datetime bar_time)
{
   double Q50;
   double QUP;
   double QDN;
   double Mode;


   if(!GetCurrentData(bar_time, Q50, QUP, QDN, Mode))
   {
      DebugPrint("Data unavailable for this bar.");

      return;
   }

   g_last_Q50  = Q50;
   g_last_QUP  = QUP;
   g_last_QDN  = QDN;
   g_last_Mode = Mode;


   //--- BackTest only records data.
   if(inp_mode == BackTest)
      return;

   //--- Evaluate open condition.
   bool open_condition = false;

   if(HasOpenCondition())
   {
      open_condition = EvaluateOpenConditions(
         Q50,
         QUP,
         QDN,
         Mode
      );
   }

   bool open_edge =
      open_condition && !g_previous_open_condition;

   g_previous_open_condition = open_condition;

   int position_count = CountManagedPositions();

   //--- Close existing positions first.
   if(position_count > 0 && HasCloseCondition())
   {
      if(EvaluateCloseConditions(
         Q50,
         QUP,
         QDN,
         Mode
      ))
      {
         DebugPrint(
            StringFormat(
               "CLOSE SIGNAL | positions=%d | "
               "Q50=%.5f | QUP=%.5f | QDN=%.5f | Mode=%.5f",
               position_count,
               Q50,
               QUP,
               QDN,
               Mode
            )
         );

         CloseAllPositions();

         return;
      }
   }

   //--- Open position on rising edge of open condition.
   if(open_edge)
   {
      int current_positions = CountManagedPositions();

      if(max_positions > 0 &&
         current_positions < max_positions)
      {
         DebugPrint(
            StringFormat(
               "OPEN SIGNAL | Q50=%.5f | QUP=%.5f | QDN=%.5f | Mode=%.5f",
               Q50,
               QUP,
               QDN,
               Mode
            )
         );

         //--- Final entry-distance filter.
         if(CanOpenAtCurrentPrice(GetDecisionPrice()))
            OpenPosition();
      }
      else
      {
         DebugPrint(
            StringFormat(
               "OPEN EDGE DETECTED BUT CAPACITY FULL | "
               "positions=%d | max=%d",
               current_positions,
               max_positions
            )
         );
      }
   }

   //--- Debug summary.
   if(debug_mode)
   {
      Print(
         "[EA_L3_WeightedPricePDF] BAR | mode=",
         EnumToString(inp_mode),

         " | time=",
         TimeToString(bar_time, TIME_DATE | TIME_MINUTES),

         " | Bid=",
         DoubleToString(g_current_bid, _Digits),

         " | Ask=",
         DoubleToString(g_current_ask, _Digits),

         " | Q50=",
         DoubleToString(Q50, _Digits),

         " | QUP=",
         DoubleToString(QUP, _Digits),
         " | QDN=", DoubleToString(QDN,_Digits),
         " | Mode=", DoubleToString(Mode,_Digits),



         " | Positions=",
         CountManagedPositions(),
         "/",
         max_positions,

         " | OpenCondition=",
         (open_condition ? "1" : "0"),

         " | OpenEdge=",
         (open_edge ? "1" : "0"),

         " | EntryMin=",
         DoubleToString(g_last_min_entry_price, _Digits),

         " | EntryMax=",
         DoubleToString(g_last_max_entry_price, _Digits)
      );
   }
}


//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+

int OnInit()
{
   trade.SetExpertMagicNumber(magic_number);

   //--- Validate general inputs.
   if(max_positions < 0)
   {
      Print(
         "[EA_L3_WeightedPricePDF] ERROR: "
         "max_positions cannot be negative."
      );

      return INIT_PARAMETERS_INCORRECT;
   }

   if(lot_size <= 0.0)
   {
      Print(
         "[EA_L3_WeightedPricePDF] ERROR: "
         "lot_size must be greater than zero."
      );

      return INIT_PARAMETERS_INCORRECT;
   }


   g_actual_period = CalculateActualPeriod();

   if(g_actual_period < 30)
      return INIT_PARAMETERS_INCORRECT;

   //--- Normal mode.
   if(inp_mode == Normal)
   {
      if(!CreateIndicator())
         return INIT_FAILED;
   }

   //--- BackTest mode.
   else if(inp_mode == BackTest)
   {
      if(!CreateIndicator())
         return INIT_FAILED;

      if(!OpenBackTestDataFile())
         return INIT_FAILED;
   }

   //--- Optimizer mode.
   else if(inp_mode == Optimizer)
   {
      // Do not create or call the indicator.
      if(!LoadOptimizerData())
         return INIT_FAILED;
   }
   else
   {
      return INIT_PARAMETERS_INCORRECT;
   }

   //--- Initialize bar tracking.
   g_last_bar_time = iTime(_Symbol, _Period, 0);

   g_previous_open_condition = false;

   //--- Initialize entry-price range.
   g_last_max_entry_price = 0.0;
   g_last_min_entry_price = 0.0;
   g_has_entry_price = false;

   DebugPrint(
      StringFormat(
         "INIT | mode=%s | symbol=%s | period=%d | "
         "step=%d | Price_step=%d | max_positions=%d",
         EnumToString(inp_mode),
         _Symbol,
         period_base,
         period_step,
         Price_step,
         max_positions
      )
   );

   return INIT_SUCCEEDED;
}


//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
{
   if(g_indicator_handle != INVALID_HANDLE)
   {
      IndicatorRelease(g_indicator_handle);

      g_indicator_handle = INVALID_HANDLE;
   }

   if(g_data_file != INVALID_HANDLE)
   {
      FileFlush(g_data_file);

      FileClose(g_data_file);

      g_data_file = INVALID_HANDLE;
   }

   Print(
      "[EA_L3_WeightedPricePDF] SUMMARY | mode=",
      EnumToString(inp_mode),

      " | symbol=",
      _Symbol,

      " | period=",
      period_base,

      " | step=",
      period_step,

      " | Price_step=",
      Price_step,

      " | max_positions=",
      max_positions,

      " | direction=",
      EnumToString(position_type),

      " | O=",
      O01, ",",
      O02, ",", O03, ",", O04, ",", O05, ",", O06, ",", O07, ",",

      " | C=",
      C01, ",",
      C02, ",", C03, ",", C04, ",", C05, ",", C06, ",", C07, ",",

      " | opened=",
      g_open_count,

      " | closed=",
      g_close_count,

      " | entry_min=",
      DoubleToString(g_last_min_entry_price, _Digits),

      " | entry_max=",
      DoubleToString(g_last_max_entry_price, _Digits),

      " | data_records=",
      g_record_count
   );
}


//+------------------------------------------------------------------+
//| Tick handler                                                     |
//+------------------------------------------------------------------+

void OnTick()
{
   datetime current_bar_time = iTime(_Symbol, PERIOD_M1, 0);

   if(current_bar_time == 0 ||
      current_bar_time == g_last_bar_time)
   {
      return;
   }

   g_last_bar_time = current_bar_time;

   datetime closed_bar_time = iTime(_Symbol, PERIOD_M1, 1);

   if(closed_bar_time == 0)
      return;

   ProcessNewBar(closed_bar_time);
}

//+------------------------------------------------------------------+

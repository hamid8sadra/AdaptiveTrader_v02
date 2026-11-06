# PROMPT — Generate a Level 3 MQL5 Expert Advisor from the Fixed EA Template

## ROLE

You are a code-generation model. Your task is to generate one complete MQL5 Expert Advisor by adapting the fixed EA template included at the end of this prompt.

You are NOT being asked to design a trading system, invent an architecture, improve the framework, or write an EA from scratch.

The fixed template is the authoritative implementation. Preserve its structure, function names, global state, execution flow, trading mechanics, CSV workflow, and general coding style. Make only the indicator-specific substitutions required by the two project documents and the explicitly permitted corrections in this prompt.

This instruction applies even if you are a small or weak model. Do not try to be creative.

---

## REQUIRED INPUT DOCUMENTS

If a document is missing, unreadable, or contradictory, do not guess. Report the exact missing or conflicting information.

The fixed EA template is embedded in this prompt. Do not search for another template and do not replace it with a newly designed architecture.

---

## OUTPUT CONTRACT

Generate exactly one complete source file:

`MQL5/Experts/AdaptiveTrader/EA_L3_<IndicatorName>.mq5`

Replace `<IndicatorName>` with the indicator's actual name, following the naming convention in the project documents.
like `MQL5\Indicators\AdaptiveTrader\Ind_<IndicatorName>.md`
Output the complete `.mq5` source code, from the first line to the last line. Do not omit functions, shorten repeated code, use placeholders, write `...`, or say that unchanged sections are omitted.

Do not create or propose additional files.

Do not modify the two input documents.

Do not push, commit, or upload anything to GitHub.

Do not include a long explanation before or after the source code. If an essential specification is missing, stop and report the missing item instead of fabricating code.

---

## SOURCE OF TRUTH AND PRIORITY

Apply the following priority:

1. `prompts\00_MASTER_CONTEXT.md` governs general MQL5 coding rules and project conventions.
2. `MQL5\Indicators\AdaptiveTrader\Ind_<IndicatorName>.md` governs the current indicator's name, path, inputs, buffers, buffer meanings, warm-up behavior, and indicator-specific data.
3. The embedded fixed EA template governs the EA architecture, control flow, position management, entry-distance filter, BackTest mode, Optimizer mode, CSV format/workflow, and general implementation.
4. This prompt governs how the template may be adapted and lists the permitted corrections.

If the documents appear to conflict, do not silently invent a compromise. Follow the higher-priority source where the priority above resolves the conflict; otherwise report the conflict.

---

## FIXED ARCHITECTURE — DO NOT REDESIGN

The generated EA must retain all of the following template elements:

- `#property strict`
- `CTrade` for all order operations.
- The `PositionType` enumeration with `BUY` and `SELL`.
- The `Inp_Mode` enumeration with `Normal`, `BackTest`, and `Optimizer`.
- The general input group and its execution semantics.
- The open-condition inputs `O01` through `O02`. (adjust `O07` numbers by <logic_count> )
- The close-condition inputs `C01` through `C02`. (adjust `C07` by <logic_count> )
- The global-state approach used by the template.
- The `IndicatorRecord` structure and in-memory record array.
- The same function-level architecture and substantially the same function order.
- The same `Normal`, `BackTest`, and `Optimizer` mode behavior.
- The same position filtering by `_Symbol` and `magic_number`.
- The same maximum-position behavior.
- The same rising-edge behavior for opening positions.
- The same close-before-open processing order.
- The same entry-price-extremes tracking and entry-distance filter.
- The same CSV-based transfer of indicator and market data from BackTest to Optimizer.
- The same time-based binary search for Optimizer records.
- The same one-bar-at-a-time processing model.

Do not replace these mechanisms with classes, inheritance, interfaces, arrays of condition objects, event frameworks, state machines, new managers, or other abstractions.

Do not rename or reorganize general-purpose functions merely because you prefer different names.

Do not remove code because you think it is unnecessary.

Do not add features such as stop loss, take profit, trailing stop, risk-based lot sizing, spread filters, time filters, or additional trading signals unless the two required documents explicitly require them.

---
## PERMITTED CORRECTIONS

The embedded template is the primary implementation. Do not rewrite it wholesale.

Do not make speculative improvements. Do not change behavior just because another implementation might be more elegant.

If you identify a possible improvement that is not required for correctness, do not implement it. Mention it briefly after the code only if it is important.

---

## STRICT PROHIBITIONS

You MUST NOT:

- Design a new EA architecture.
- Replace the template with a shorter or cleaner implementation.
- Remove or merge functions.
- Replace the template's global variables with classes or other structures.
- Introduce a new framework or manager.
- Change the three operating modes.
- Change the M1-only behavior.
- Change the CSV-based Optimizer workflow.
- Change the comparison semantics.
- Change the entry-distance formula.
- Change the rising-edge opening behavior.
- Add trading features not requested by the specification.
- Guess missing indicator inputs, buffers, or relationships.
- Invent indicator calculations inside the EA.
- Use MQL4 functions or syntax.
- Use DLLs.
- Use placeholders or incomplete code.
- Claim that code has been compiled or tested in MetaEditor unless you actually performed that test.
- Erase comments that dose not start with `AGENT`

If you are uncertain whether a change is allowed, preserve the template and do not make the change.

---

## REQUIRED SELF-CHECK BEFORE OUTPUT

Before returning the source code, silently compare the generated EA against the template and verify every item below.

### Structure

- [ ] All template functions are present.
- [ ] The functions remain in substantially the same order.
- [ ] The global variables and record structure are preserved, with only necessary indicator-specific adaptations.
- [ ] No new architecture or unnecessary abstraction has been introduced.
- [ ] The generated file path and name follow the required convention.

### Indicator

- [ ] Indicator name and `iCustom` path come from the indicator specification.
- [ ] Every indicator input is declared and passed in the exact specified order.
- [ ] Buffer indexes match the specification.


### CSV
- [ ] The header is skipped correctly.

### MQL5 quality

- [ ] No MQL4-only API is used.
- [ ] No DLL is used.
- [ ] No undeclared identifiers or invented indicator parameters remain.
- [ ] Every function has a complete implementation.
- [ ] No placeholder or omitted code remains.
- [ ] Do not claim successful compilation unless MetaEditor compilation was actually performed.

If any essential check cannot be satisfied from the supplied documents, do not guess. State exactly what is missing.

---

## 13. FIXED EA TEMPLATE — PRIMARY SOURCE CODE

The following code is the primary EA template. Preserve it as closely as possible. Adapt only the indicator-dependent parts and the explicitly permitted corrections described above.

Do not treat this code as an example that can be replaced. Treat it as the implementation to be continued and adapted.

```cpp
//+------------------------------------------------------------------+
//|                                                 EA_L3_<NAME>.mq5 |
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

//--- <NAME> indicator inputs 
// AGENT only inputs in <back_test_inputs> , preserve "name","type","default"
input <type>  <input_nam> = <default_value>;


// 1 = left > right
// -1 = left < right
// 0 = ignored

//--- Open conditions
input int O01 = 0; // <logic_levels.key1> vs <logic_levels.value1>
input int O02 = 0; // <logic_levels.key2> vs <logic_levels.value2>
// AGENT Fill for all key value in <logic_levels>

//--- Close conditions
input int C01 = 0; // <logic_levels.key1> vs <logic_levels.value1>
input int C02 = 0; // <logic_levels.key2> vs <logic_levels.value2>
// AGENT Fill for all key value in <logic_levels>

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+

string INDICATOR_NAME =
   "AdaptiveTrader\\Ind_<NAME>";

int      g_indicator_handle = INVALID_HANDLE;

datetime g_last_bar_time = 0;

int      g_actual_period = 0;

int      g_open_count = 0;
int      g_close_count = 0;

double   g_last_<buffers1> = 0.0;
double   g_last_<buffers2> = 0.0;
// AGENT Fill for all <buffers>

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

   double <buffers1>;
   double <buffers2>;
// AGENT Fill for all <buffers>

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
      Print("[EA_L3_<NAME>] ", text);
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
   return StringFormat(
      "AdaptiveTrader\\Ad_%s_M1_%d_%d_%d_%d.csv", // adjust for all <back_test_inputs>
      _Symbol,
      period_base,
      period_step,
      <back_test_inputs1>,
      <back_test_inputs1>,
// AGENT Fill for all <back_test_inputs>
   );
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
         "[EA_L3_<NAME>] ERROR: Indicator period "
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
// AGENT Fill the rest of indicator inputs in order
    debug_mode
    );

   if(g_indicator_handle == INVALID_HANDLE)
   {
      Print(
         "[EA_L3_<NAME>] ERROR: Cannot create indicator. ",
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

bool GetIndicatorValues(
   double &<buffers1>,
   double &<buffers2>,
// AGENT Fill for all <buffers>
)
{
   if(g_indicator_handle == INVALID_HANDLE)
      return false;

   if(BarsCalculated(g_indicator_handle) <= 1)
      return false;

   double b_<buffers1>[1];
   double b_<buffers2>[1];
// AGENT Fill for all <buffers>

   if(CopyBuffer(g_indicator_handle, 0, 1, 1, b_<buffers1>) != 1)
      return false;

   if(CopyBuffer(g_indicator_handle, 1, 1, 1, b_<buffers2>) != 1)
      return false;
// AGENT Fill for all <buffers>

   <buffers1>  = b_<buffers1>[0];
   <buffers2>  = b_<buffers2>[0];
// AGENT Fill for all <buffers>

   if(<buffers1> == EMPTY_VALUE ||
      <buffers2> == EMPTY_VALUE ||
// AGENT Fill for all <buffers>
   {
      return false;
   }

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

bool EvaluateOpenConditions(
   const double <logic_levels.key1>,
   const double <logic_levels.value1>,
// AGENT Fill for all unique key value in <logic_levels>
)
{
   const double price = GetDecisionPrice();

   return
      CompareValues(<logic_levels.key1>, <logic_levels.value1>, O01) &&
      CompareValues(<logic_levels.key2>, <logic_levels.value2>, O02) &&
// AGENT Fill for all key value in <logic_levels>
}


//+------------------------------------------------------------------+
//| Evaluate close conditions                                        |
//+------------------------------------------------------------------+

bool EvaluateCloseConditions(
   const double <logic_levels.key1>,
   const double <logic_levels.value1>,
// AGENT Fill for all unique key value in <logic_levels>
)
{
   const double price = GetDecisionPrice();

   return
      CompareValues(<logic_levels.key1>, <logic_levels.value1>, C01) &&
      CompareValues(<logic_levels.key2>, <logic_levels.value2>, C02) &&
// AGENT Fill for all key value in <logic_levels>
}


//+------------------------------------------------------------------+
//| Check whether any open condition is enabled                      |
//+------------------------------------------------------------------+

bool HasOpenCondition()
{
   return
      O01 != 0 ||
      O02 != 0 ||
// AGENT Fill  for all Open Conditions
}


//+------------------------------------------------------------------+
//| Check whether any close condition is enabled                     |
//+------------------------------------------------------------------+

bool HasCloseCondition()
{
   return
      C01 != 0 ||
      C02 != 0 ||
// AGENT Fill for all Close Conditions
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
      "EA_L3_<NAME>"
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
      "EA_L3_<NAME>"
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
         "[EA_L3_<NAME>] ERROR: Cannot create data file ",
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
      "<buffers1>",
      "<buffers2>",
// AGENT Fill for all <buffers>

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
   const double <buffers1>,
   const double <buffers2>,
// AGENT Fill for all <buffers>

)
{
   if(g_data_file == INVALID_HANDLE)
      return false;

   uint written = FileWrite(
      g_data_file,

      TimeToString(bar_time, TIME_DATE | TIME_SECONDS),
	  
      DoubleToString(bid, _Digits),
      DoubleToString(ask, _Digits),

      DoubleToString(<buffers1>, _Digits),
      DoubleToString(<buffers2>, _Digits),
// AGENT Fill for all <buffers>


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
            "[EA_L3_<NAME>] Waiting for data file: ",
            g_data_filename,
            " Error=",
            GetLastError()
         );

         Sleep(250);

         continue;
      }

      // Skip CSV header fields.
      for(int k = 0; k < 7 && !FileIsEnding(handle); ++k) // replace `7` by (3 + <buffers> count)
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
         string s_<buffers1>  = FileReadString(handle);
         string s_<buffers2>  = FileReadString(handle);
// AGENT Fill for all <buffers>


         if(time_text == "" ||
            s_bid == "" ||
            s_ask == "" ||
            s_<buffers1> == "" ||
            s_<buffers2> == "" ||
// AGENT Fill for all <buffers>

			)
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
		 
         g_records[n].<buffers1>  = StringToDouble(s_<buffers1>);
         g_records[n].<buffers2>  = StringToDouble(s_<buffers2>);
// AGENT Fill for all <buffers>


         if(g_records[n].bid <= 0.0 ||
            g_records[n].ask <= 0.0 ||
            !MathIsValidNumber(g_records[n].<buffers1>) ||
            !MathIsValidNumber(g_records[n].<buffers2>) ||
// AGENT Fill for all <buffers>
			)
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
         "[EA_L3_<NAME>] Data file empty/incomplete "
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
   double &<buffers1>,
   double &<buffers2>,
// AGENT Fill for all <buffers>
)
{
   //--- Optimizer mode reads only from CSV.
   if(inp_mode == Optimizer)
   {
      int index = FindRecordByTime(bar_time);

      if(index < 0)
      {
         Print(
            "[EA_L3_<NAME>] No CSV record for bar time ",
            TimeToString(bar_time, TIME_DATE | TIME_MINUTES),
            ". Bar skipped."
         );

         return false;
      }

      g_current_bid = g_records[index].bid;
      g_current_ask = g_records[index].ask;
	  
      <buffers1>  = g_records[index].<buffers1>;
      <buffers2>  = g_records[index].<buffers2>;
// AGENT Fill for all <buffers>


      return true;
   }

   //--- Normal and BackTest modes read the indicator.
   if(!GetIndicatorValues(<buffers1>, <buffers2>,)) // AGENT Fill for all <buffers>
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
         <buffers1>,
         <buffers2>,
// AGENT Fill for all <buffers>

      ))
      {
         Print(
            "[EA_L3_<NAME>] ERROR writing CSV record. Error=",
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
   double <buffers1>;
   double <buffers2>;
// AGENT Fill for all <buffers>

   if(!GetCurrentData(
      bar_time,
      <buffers1>,
      <buffers2>,
// AGENT Fill for all <buffers>
   ))
   {
      DebugPrint("Data unavailable for this bar.");

      return;
   }

   g_last_<buffers1>  = <buffers1>;
   g_last_<buffers2>  = <buffers2>;
// AGENT Fill for all <buffers>

   //--- BackTest only records data.
   if(inp_mode == BackTest)
      return;

   //--- Evaluate open condition.
   bool open_condition = false;

   if(HasOpenCondition())
   {
      open_condition = EvaluateOpenConditions(
         <buffers1>,
         <buffers2>,
// AGENT Fill for all <buffers>
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
         <buffers1>,
         <buffers2>,
// AGENT Fill for all <buffers>
      ))
      {
         DebugPrint(
            StringFormat(
               "CLOSE SIGNAL | positions=%d | "
               "<buffers1>=%.5f | <buffers2>=%.5f", // AGENT Fill for all <buffers>
               position_count,
               <buffers1>,
               <buffers2>,
// AGENT Fill for all <buffers>
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
               "OPEN SIGNAL | <buffers1>=%.5f | <buffers2>=%.5f | ",// fill for all <buffers>
               <buffers1>,
               <buffers2>,
// AGENT Fill for all <buffers>
            )
         );

         //--- Final entry-distance filter.
         if(CanOpenAtCurrentPrice(<buffers1>))
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
         "[EA_L3_<NAME>] BAR | mode=",
         EnumToString(inp_mode),

         " | time=",
         TimeToString(bar_time, TIME_DATE | TIME_MINUTES),

         " | Bid=",
         DoubleToString(g_current_bid, _Digits),

         " | Ask=",
         DoubleToString(g_current_ask, _Digits),

         " | Q50=",
         DoubleToString(<buffers1>, _Digits),

         " | QUP=",
         DoubleToString(<buffers2>, _Digits),

// AGENT Fill for all <buffers>

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
         "[EA_L3_<NAME>] ERROR: "
         "max_positions cannot be negative."
      );

      return INIT_PARAMETERS_INCORRECT;
   }

   if(lot_size <= 0.0)
   {
      Print(
         "[EA_L3_<NAME>] ERROR: "
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
      "[EA_L3_<NAME>] SUMMARY | mode=",
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
      O02, ",",
// AGENT Fill for all Open Conditions

      " | C=",
      C01, ",",
      C02, ",",
// AGENT Fill for all Close Conditions

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
```

---

## 14. FINAL RESPONSE FORMAT

If the specification is sufficient, return:

1. The complete source code for `MQL5/Experts/AdaptiveTrader/EA_L3_<IndicatorName>.mq5`. remove comments that start with `AGENT` first.


Do not include a lengthy design explanation.

If the specification is insufficient or incompatible with the fixed template, do not generate speculative code. State the exact missing or incompatible fields and wait for clarification.
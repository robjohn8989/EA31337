//+------------------------------------------------------------------+
//|                                                       EA31337    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Predefined code configurations.
//+------------------------------------------------------------------+
#define __advanced__  // Enable advanced configuration.
//#define __release__ // Enable release settings.
//#define __testing__   // Mode for testing each component.
//#define __safe__ // Define safe options.
#define __rider__     // Activate rider strategy.

#ifdef __testing__
  #define __disabled__  // Disable all strategies by default.
  #define __noactions__ // Disable conditioned actions by default.
  #define __noboost__   // Disable boosting by default.
  #define __nospreads__ // Disable spread limits.
  #define __nodebug__   // Disable debug messages by default.
#endif

#ifdef __release__
  #undef __disabled__  // Enable all strategies by default.
  #undef __noboost__   // Enable boosting by default.
  #undef __nospreads__ // Enable spread limitation by default.
  #undef __safe__      // Disable safe mode by default.
  #undef __rider__     // Disable rider strategy by default.
#endif

//#undef __disabled__

//+------------------------------------------------------------------+
//| EA properties.
//+------------------------------------------------------------------+
#ifdef __advanced__
#ifndef __rider__
  #define ea_name    "EA31337"
#else
  #define ea_name    "EA31337 Rider"
#endif
#else
  #define ea_name    "EA31337 Lite"
#endif
#define ea_desc    "Multi-strategy advanced trading robot."
#define ea_version "1.056"
#define ea_build   __DATETIME__ // FIXME: It's empty
#define ea_link    "http://www.ea31337.com"
#define ea_author  "kenorb"

#property description ea_name
#property description ea_desc
#property copyright   ea_author
#property link        ea_link
#property version     ea_version
// #property tester_file "trade_patterns.csv"    // file with the data to be read by an Expert Advisor
//#property strict

//+------------------------------------------------------------------+
//| EA includes.
//+------------------------------------------------------------------+
#include <stderror.mqh>
#include <stdlib.mqh> // Used for: ErrorDescription(), RGB(), CompareDoubles(), DoubleToStrMorePrecision(), IntegerToHexString()
// #include "debug.mqh"

//+------------------------------------------------------------------+
//| EA enumerations.
//+------------------------------------------------------------------+
enum ENUM_STRATEGY_TYPE { // Define type of strategies.
  // Type of strategy being used (used for strategy identification, new strategies append to the end, but in general - do not change!).
  MA1,
  MA5,
  MA15,
  MA30,
  MACD1,
  MACD5,
  MACD15,
  MACD30,
  ALLIGATOR1,
  ALLIGATOR5,
  ALLIGATOR15,
  ALLIGATOR30,
  RSI1,
  RSI5,
  RSI15,
  RSI30,
  SAR1,
  SAR5,
  SAR15,
  SAR30,
  BANDS1,
  BANDS5,
  BANDS15,
  BANDS30,
  ENVELOPES1,
  ENVELOPES5,
  ENVELOPES15,
  ENVELOPES30,
  DEMARKER1,
  DEMARKER5,
  DEMARKER15,
  DEMARKER30,
  WPR1,
  WPR5,
  WPR15,
  WPR30,
  FRACTALS1,
  FRACTALS5,
  FRACTALS15,
  FRACTALS30,
#ifdef __advanced__
  CUSTOM1,
  CUSTOM2,
#endif
  FINAL_STRATEGY_TYPE_ENTRY // Should be the last one. Used to calculate the number of enum items.
};

enum ENUM_STRATEGY_INFO { // Define type of strategy information entry.
  ACTIVE,
  TIMEFRAME,
  OPEN_METHOD,
  STOP_METHOD,
  PROFIT_METHOD,
  CUSTOM_PERIOD,
  OPEN_CONDITION1,
  OPEN_CONDITION2,
  CLOSE_CONDITION,
  OPEN_ORDERS,
  TOTAL_ORDERS,
  TOTAL_ORDERS_LOSS,
  TOTAL_ORDERS_WON,
  TOTAL_ERRORS,
  FINAL_STRATEGY_INFO_ENTRY // Should be the last one. Used to calculate the number of enum items.
};

enum ENUM_STRATEGY_VALUE { // Define strategy value entry.
  LOT_SIZE, // Lot size to trade.
  FACTOR, // Multiply lot factor.
  SPREAD_LIMIT,
  FINAL_STRATEGY_VALUE_ENTRY // Should be the last one. Used to calculate the number of enum items.
};

enum ENUM_STRATEGY_STAT_VALUE { // Define strategy statistics entries.
  DAILY_PROFIT,
  WEEKLY_PROFIT,
  MONTHLY_PROFIT,
  TOTAL_GROSS_PROFIT,
  TOTAL_GROSS_LOSS,
  TOTAL_NET_PROFIT,
  AVG_SPREAD,
  FINAL_STRATEGY_STAT_ENTRY // Should be the last one. Used to calculate the number of enum items.
};

enum ENUM_TASK_TYPE { // Define type of tasks.
  TASK_ORDER_OPEN,
  TASK_ORDER_CLOSE,
  TASK_CALC_STATS,
};

enum ENUM_VALUE_TYPE { // Define type of values in order to store.
  MAX_LOW,
  MAX_HIGH,
  MAX_SPREAD,
  MAX_DROP,
  MAX_TICK,
  MAX_LOSS,
  MAX_PROFIT,
  MAX_BALANCE,
  MAX_EQUITY,
  FINAL_VALUE_TYPE_ENTRY // Should be the last one. Used to calculate the number of enum items.
};

enum ENUM_TRAIL_TYPE { // Define type of trailing types.
  T_NONE              =  0, // None
  T_FIXED             =  1, // Fixed
  T_CLOSE_PREV        =  2, // Previous close
  T_2_BARS_PEAK       =  3, // 2 bars peak
  T_5_BARS_PEAK       =  4, // 5 bars peak
  T_10_BARS_PEAK      =  5, // 10 bars peak
  T_50_BARS_PEAK      =  6, // 50 bars peak
  T_150_BARS_PEAK     =  7, // 150 bars peak
  T_HALF_200_BARS     =  8, // 200 bars half price
  T_MA_F_PREV         =  9, // MA Fast Prev
  T_MA_F_FAR          = 10, // MA Fast Far
  // T_MA_F_LOW          = 11, // MA Fast Low
  T_MA_F_TRAIL        = 12, // MA Fast+Trail
  T_MA_F_FAR_TRAIL    = 13, // MA Fast Far+Trail
  T_MA_M              = 14, // MA Med
  T_MA_M_FAR          = 15, // MA Med Far
  // T_MA_M_LOW          = 16, // MA Med Low
  T_MA_M_TRAIL        = 17, // MA Med+Trail
  T_MA_M_FAR_TRAIL    = 18, // MA Med Far+Trail
  T_MA_S              = 19, // MA Slow
  T_MA_S_FAR          = 20, // MA Slow Far
  T_MA_S_TRAIL        = 21, // MA Slow+Trail
  T_MA_FMS_PEAK       = 22, // MA F+M+S Peak
  T_SAR               = 23, // SAR
  T_SAR_PEAK          = 24, // SAR Peak
  T_BANDS             = 25, // Bands
  T_BANDS_PEAK        = 26, // Bands Peak
  T_ENVELOPES         = 27, // Envelopes
};

// Define market event conditions.
enum ENUM_MARKET_EVENT {
  C_EVENT_NONE          =  0, // None
  C_MA_BUY_SELL         =  1, // MA on buy/sell
  C_MACD_BUY_SELL       =  2, // MACD on buy/sell
  C_ALLIGATOR_BUY_SELL  =  3, // Alligator on buy/sell
  C_RSI_BUY_SELL        =  4, // RSI on buy/sell
  C_SAR_BUY_SELL        =  5, // SAR on buy/sell
  C_BANDS_BUY_SELL      =  6, // Bands on buy/sell
  C_ENVELOPES_BUY_SELL  =  7, // Envelopes on buy/sell
  C_DEMARKER_BUY_SELL   =  8, // DeMarker on buy/sell
  C_WPR_BUY_SELL        =  9, // WPR on buy/sell
  C_FRACTALS_BUY_SELL   = 10, // Fractals on buy/sell
  C_CUSTOM1_BUY_SELL    = 11, // Custom 1 on buy/sell
  C_CUSTOM2_BUY_SELL    = 12, // Custom 2 on buy/sell
  C_CUSTOM3_BUY_SELL    = 13, // Custom 3 on buy/sell
  C_CUSTOM4_MARKET_COND = 14, // Custom 4 market condition
  C_CUSTOM5_MARKET_COND = 15, // Custom 5 market condition
  C_CUSTOM6_MARKET_COND = 16, // Custom 6 market condition
};

enum ENUM_PERIOD_TYPE { // Define type of tasks.
  M1  = 0, // 1 minute
  M5  = 1, // 5 minutes
  M15 = 2, // 15 minutes
  M30 = 3, // 30 minutes
  H1  = 4, // 1 hour
  H4  = 5, // 4 hours
  D1  = 6, // daily
  W1  = 7, // weekly
  MN1 = 8, // monthly
  FINAL_PERIOD_TYPE_ENTRY = 9  // Should be the last one. Used to calculate the number of enum items.
};

enum ENUM_STAT_PERIOD_TYPE { // Define type of tasks.
  DAILY   = 0,  // Daily
  WEEKLY  = 1, // Weekly
  MONTHLY = 2, // Monthly
  YEARLY  = 3,  // Yearly
  FINAL_STAT_PERIOD_TYPE_ENTRY // Should be the last one. Used to calculate the number of enum items.
};

enum ENUM_INDICATOR_INDEX { // Define indicator constants.
  CURR = 0,
  PREV = 1,
  FAR = 2
};

enum ENUM_ALLIGATOR { JAW = 0, TEETH = 1, LIPS = 2 };

//+------------------------------------------------------------------+
//| User input variables.
//+------------------------------------------------------------------+
//extern string __EA_Parameters__ = "-- General EA parameters --";
extern string __EA_Trailing_Parameters__ = "-- Settings for trailing stops --";
extern int TrailingStop = 40;
extern ENUM_TRAIL_TYPE DefaultTrailingStopMethod = T_FIXED; // TrailingStop method. Set 0 to disable. See: ENUM_TRAIL_TYPE.
extern bool TrailingStopOneWay = TRUE; // Change trailing stop towards one direction only. Suggested value: TRUE
extern int TrailingProfit = 30;
extern ENUM_TRAIL_TYPE DefaultTrailingProfitMethod = T_NONE; // Trailing Profit method. Set 0 to disable. See: ENUM_TRAIL_TYPE.
extern bool TrailingProfitOneWay = TRUE; // Change trailing profit take towards one direction only.
extern double TrailingStopAddPerMinute = 0.0; // Decrease trailing stop (in pips) per each bar. Set 0 to disable. Suggested value: 0.
//+------------------------------------------------------------------+
extern string __EA_Order_Parameters__ = "-- Profit/Loss settings (set 0 for auto) --";
#ifndef __safe__
  extern double LotSize = 0; // Default lot size. Set 0 for auto.
#else
  extern double LotSize = 0.01;
#endif
extern double TakeProfit = 0.0; // Take profit value in pips.
extern double StopLoss = 0.0; // Stop loss value in pips.
#ifndef __safe__
  extern int MaxOrders = 0; // Maximum orders. Set 0 for auto.
#else
  extern int MaxOrders = 30;
#endif
extern int MaxOrdersPerType = 0; // Maximum orders per strategy type. Set 0 for auto.
//extern int MaxOrdersPerDay = 30; // TODO
#ifndef __safe__
  extern int MinimumIntervalSec = 0; // Minimum interval between subsequent trade signals. Suggested value: 0 or 60.
#else
  extern int MinimumIntervalSec = 240;
#endif
extern bool TradeMicroLots = TRUE;
//+------------------------------------------------------------------+
extern string __EA_Risk_Parameters__ = "-- Risk management --";
extern double RiskRatio = 0; // Suggested value: 1.0. Do not change unless testing.
#ifndef __safe__
  extern bool TradeWithTrend = FALSE; // Default. Trade with trend only to minimalize the risk.
#else
  extern bool TradeWithTrend = TRUE; // Safe mode.
#endif
extern bool MinimalizeLosses = FALSE; // Set stop loss to zero, once the order is profitable.
#ifdef __advanced__
  extern int RiskRatioDecreaseMethod = 3; // Risk ratio calculation method when RiskRatio is set to 0. Valid range: 0-63.
  extern int RiskRatioIncreaseMethod = 0; // Risk ratio calculation method when RiskRatio is set to 0. Valid range: 0-63.
  #ifndef __nospreads__
    extern bool ApplySpreadLimits = TRUE; // Apply strategy spread limits.
  #else
    extern bool ApplySpreadLimits = FALSE;
  #endif
#endif
//+------------------------------------------------------------------+
extern string __Strategy_Boosting_Parameters__ = "-- Strategy boosting (set 1.0 to default) --";
#ifndef __noboost__
  extern bool Boosting_Enabled                       = TRUE; // Default. Enable boosting section.
#else
  extern bool Boosting_Enabled                       = FALSE;
#endif
extern double BestDailyStrategyMultiplierFactor    = 1.1; // Lot multiplier boosting factor for the most profitable daily strategy.
extern double BestWeeklyStrategyMultiplierFactor   = 1.2; // Lot multiplier boosting factor for the most profitable weekly strategy.
extern double BestMonthlyStrategyMultiplierFactor  = 1.5; // Lot multiplier boosting factor for the most profitable monthly strategy.
extern double WorseDailyStrategyDividerFactor      = 1.2; // Lot divider factor for the most profitable daily strategy. Useful for low-balance accounts or non-profitable periods.
extern double WorseWeeklyStrategyDividerFactor     = 1.2; // Lot divider factor for the most profitable weekly strategy. Useful for low-balance accounts or non-profitable periods.
extern double WorseMonthlyStrategyDividerFactor    = 1.2; // Lot divider factor for the most profitable monthly strategy. Useful for low-balance accounts or non-profitable periods.
extern double BoostTrendFactor                     = 1.2; // Additional boost when trade is with trend.
#ifdef __advanced__
  extern bool BoostByProfitFactor                  = TRUE; // Boost strategy by its profit factor. To be more accurate, it requires at least 10 orders to be placed by strategy. It's 1.0 by default.
  extern bool HandicapByProfitFactor               = FALSE; // Handicap by low profit factor.
#endif
//+------------------------------------------------------------------+
extern string __Market_Parameters__ = "-- Market parameters --";
extern int TrendMethod = 181; // Method of main trend calculation. Valid range: 0-255. Suggested values: 65!, 71, 81, 83!, 87, 181, etc.
// �11347.25	20908	1.03	0.54	17245.91	58.84%	0.00000000	TrendMethod=181 (d: �10k, spread 24)
// �11383.51	20278	1.04	0.56	22825.00	67.72%	0.00000000	TrendMethod=81 (d: �10k, spread 24)
// �3146.85	20099	1.01	0.16	25575.87	77.54%	0.00000000	TrendMethod=81 (d: �10k, spread 28)
// �1668.90	20747	1.01	0.08	17142.41	71.64%	0.00000000	TrendMethod=181 (d: �10k, spread 28)
extern int TrendMethodAction = 238; // Method of trend calculation on action execution (See: A_CLOSE_ALL_TREND/A_CLOSE_ALL_NON_TREND). Valid range: 0-255.
extern int MinVolumeToTrade = 2; // Minimum volume to trade.
extern int MaxOrderPriceSlippage = 5; // Maximum price slippage for buy or sell orders (in pips).
extern int DemoMarketStopLevel = 10;
extern int MaxTries = 5; // Number of maximum attempts to execute the order.
extern int MarketSuddenDropSize = 10; // Size of sudden price drop in pips to react when the market drops.
extern int MarketBigDropSize = 50; // Size of big sudden price drop in pips to react when the market drops.
extern double MinPipChangeToTrade = 0.7; // Minimum pip change to trade before the bar change. Set 0 to process every tick. Lower is better for small spreads and other way round.
extern int MinPipGap = 10; // Minimum gap in pips between trades of the same strategy.
extern double MaxSpreadToTrade = 10.0; // Maximum spread to trade (in pips).
//+------------------------------------------------------------------+
#ifdef __advanced__
  extern string __Advanced_Parameters__ = "-- Advanced parameters --";
  extern bool DisableCloseConditions = FALSE; // Set TRUE to disable all close conditions for strategies. Not useful apart of testing.
  extern int CloseConditionCustom1Method = 0; // Custom 1 indicator-based close condition. Valid range: 0-1023.
  extern int CloseConditionCustom2Method = 0; // Custom 2 indicator-based close condition. Valid range: 0-1023.
  extern int CloseConditionCustom3Method = 0; // Custom 3 indicator-based close condition. Valid range: 0-1023.
  extern int CloseConditionCustom4Method = 0; // Custom 4 market-based close condition. Valid range: 0-1023.
  extern int CloseConditionCustom5Method = 0; // Custom 5 market-based close condition. Valid range: 0-1023.
  extern int CloseConditionCustom6Method = 0; // Custom 6 market-based close condition. Valid range: 0-1023.
  extern bool DynamicSpreadConf = FALSE; // Dynamically calculate most optimal settings based on the current spread (MinPipChangeToTrade/MinPipGap).
  int SpreadRatio = 1.0;
#endif
//+------------------------------------------------------------------+
extern string __MA_Parameters__ = "-- Settings for the Moving Average indicator --";
#ifndef __disabled__
  extern bool MA1_Active = TRUE, MA5_Active = TRUE, MA15_Active = TRUE, MA30_Active = TRUE; // Enable MA-based strategy for specific timeframe.
#else
  extern bool MA1_Active = FALSE, MA5_Active = FALSE, MA15_Active = FALSE, MA30_Active = FALSE;
#endif
extern int MA_Period_Fast = 8; // Averaging period for calculation.
extern int MA_Period_Medium = 20; // Averaging period for calculation.
extern int MA_Period_Slow = 40; // Averaging period for calculation.
// extern double MA_Period_Ratio = 2; // Testing
extern int MA_Shift = 0;
extern int MA_Shift_Fast = 0; // Index of the value taken from the indicator buffer. Shift relative to the previous bar (+1).
extern int MA_Shift_Medium = 2; // Index of the value taken from the indicator buffer. Shift relative to the previous bar (+1).
extern int MA_Shift_Slow = 4; // Index of the value taken from the indicator buffer. Shift relative to the previous bar (+1).
extern int MA_Shift_Far = 4; // Far shift. Shift relative to the 2 previous bars (+2).
extern ENUM_MA_METHOD MA_Method = MODE_LWMA; // MA method (See: ENUM_MA_METHOD). Range: 0-3. Suggested value: MODE_EMA.
extern ENUM_APPLIED_PRICE MA_Applied_Price = PRICE_CLOSE; // MA applied price (See: ENUM_APPLIED_PRICE). Range: 0-6.
#ifndef __rider__
  extern ENUM_TRAIL_TYPE MA_TrailingStopMethod = T_MA_FMS_PEAK; // Trailing Stop method for MA. Set 0 to default (DefaultTrailingStopMethod). See: ENUM_TRAIL_TYPE.
  extern ENUM_TRAIL_TYPE MA_TrailingProfitMethod = T_50_BARS_PEAK; // Trailing Profit method for MA. Set 0 to default (DefaultTrailingProfitMethod). See: ENUM_TRAIL_TYPE.
#else
  extern ENUM_TRAIL_TYPE MA_TrailingStopMethod = T_MA_FMS_PEAK;
  extern ENUM_TRAIL_TYPE MA_TrailingProfitMethod = T_50_BARS_PEAK;
#endif
extern double MA_OpenLevel  = 1.0; // Minimum open level between moving averages to raise the trade signal.
extern int MA1_OpenMethod = 57; // Valid range: 0-127.
extern int MA5_OpenMethod = 51; // Valid range: 0-127.
extern int MA15_OpenMethod = 65; // Valid range: 0-127.
extern int MA30_OpenMethod = 71; // Valid range: 0-127. This value is used for close condition.
#ifdef __advanced__
  extern int MA1_OpenCondition1 = 512; // Valid range: 0-1023.
  extern int MA1_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT MA1_CloseCondition = C_MACD_BUY_SELL;
  extern int MA5_OpenCondition1 = 0; // Valid range: 0-1023.
  extern int MA5_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT MA5_CloseCondition = C_MACD_BUY_SELL;
  extern int MA15_OpenCondition1 = 0; // Valid range: 0-1023.
  extern int MA15_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT MA15_CloseCondition = C_MA_BUY_SELL;
  extern int MA30_OpenCondition1 = 0; // Valid range: 0-1023.
  extern int MA30_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT MA30_CloseCondition = C_MA_BUY_SELL;
#endif
#ifdef __advanced__
  extern double MA1_MaxSpread  =  6.0; // Maximum spread to trade (in pips).
  extern double MA5_MaxSpread  =  7.0; // Maximum spread to trade (in pips).
  extern double MA15_MaxSpread =  8.0; // Maximum spread to trade (in pips).
  extern double MA30_MaxSpread = 10.0; // Maximum spread to trade (in pips).
#endif
/*
 * MA backtest log [2015.01.01-2015.06.30 based on MT4 FXCM backtest data, 9,5mln ticks, quality 25%]:
 *   �49952.57	2906	1.29	17.19	17750.78	29.01%	TradeWithTrend=0 (d: �10k, spread: 25, no boosting, no actions, lot size: auto, with C_EVENT_NONE)
 *   �34911.40	2422	1.30	14.41	11890.54	26.95%	TradeWithTrend=1 (d: �10k, spread: 25, no boosting, no actions, lot size: auto, with C_EVENT_NONE)
 *   �27566.63	3177	1.23	8.68	13847.12	33.39%	TradeWithTrend=0 (d: �10k, spread: 25, no boosting, no actions, lot size: auto, with C_MA_BUY_SELL)
 *   �24780.05	2920	1.27	8.49	10192.43	32.01%	TradeWithTrend=0 (d: �10k, spread: 20, no boosting, no actions, lot size: auto, with C_MA_BUY_SELL)
 *   �22280.33	2413	1.31	9.23	6611.29	28.83%	TradeWithTrend=1 (d: �10k, spread: 20, no boosting, no actions, lot size: auto, with C_MA_BUY_SELL)
 */
//+------------------------------------------------------------------+
extern string __MACD_Parameters__ = "-- Settings for the Moving Averages Convergence/Divergence indicator --";
#ifndef __disabled__
  extern bool MACD1_Active = TRUE, MACD5_Active = TRUE, MACD15_Active = TRUE, MACD30_Active = TRUE; // Enable MACD-based strategy for specific timeframe.
#else
  extern bool MACD1_Active = FALSE, MACD5_Active = FALSE, MACD15_Active = FALSE, MACD30_Active = FALSE;
#endif
extern int MACD_Fast_Period = 14; // Fast EMA averaging period.
extern int MACD_Slow_Period = 35; // Slow EMA averaging period.
extern int MACD_Signal_Period = 9; // Signal line averaging period.
extern ENUM_APPLIED_PRICE MACD_Applied_Price = PRICE_WEIGHTED; // MACD applied price (See: ENUM_APPLIED_PRICE). Range: 0-6.
extern int MACD_Shift = 2; // Past MACD value in number of bars. Shift relative to the current bar the given amount of periods ago. Suggested value: 1
extern int MACD_ShiftFar = 0; // Additional MACD far value in number of bars relatively to MACD_Shift.
#ifndef __rider__
  extern ENUM_TRAIL_TYPE MACD_TrailingStopMethod = T_MA_FMS_PEAK; // Trailing Stop method for MACD. Set 0 to default (DefaultTrailingStopMethod). See: ENUM_TRAIL_TYPE.
  extern ENUM_TRAIL_TYPE MACD_TrailingProfitMethod = T_FIXED; // Trailing Profit method for MACD. Set 0 to default (DefaultTrailingProfitMethod). See: ENUM_TRAIL_TYPE.
#else
  extern ENUM_TRAIL_TYPE MACD_TrailingStopMethod = T_MA_FMS_PEAK;
  extern ENUM_TRAIL_TYPE MACD_TrailingProfitMethod = T_FIXED;
#endif
extern double MACD_OpenLevel  = 0.2;
extern int MACD1_OpenMethod = 0; // Valid range: 0-31.
extern int MACD5_OpenMethod = 0; // Valid range: 0-31.
extern int MACD15_OpenMethod = 0; // Valid range: 0-31.
extern int MACD30_OpenMethod = 15; // Valid range: 0-31. This value is used for close condition.
#ifdef __advanced__
  extern int MACD1_OpenCondition1 = 0; // Valid range: 0-1023.
  extern int MACD1_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT MACD1_CloseCondition = C_MACD_BUY_SELL;
  extern int MACD5_OpenCondition1 = 0; // Valid range: 0-1023.
  extern int MACD5_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT MACD5_CloseCondition = C_MACD_BUY_SELL;
  extern int MACD15_OpenCondition1 = 0; // Valid range: 0-1023.
  extern int MACD15_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT MACD15_CloseCondition = C_MACD_BUY_SELL;
  extern int MACD30_OpenCondition1 = 0; // Valid range: 0-1023.
  extern int MACD30_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT MACD30_CloseCondition = C_MACD_BUY_SELL;
#endif
#ifdef __advanced__
  extern double MACD1_MaxSpread  =  6.0; // Maximum spread to trade (in pips).
  extern double MACD5_MaxSpread  =  7.0; // Maximum spread to trade (in pips).
  extern double MACD15_MaxSpread =  8.0; // Maximum spread to trade (in pips).
  extern double MACD30_MaxSpread = 10.0; // Maximum spread to trade (in pips).
#endif
/*
 * MACD backtest log (auto,ts:40,tp:30,gap:10) [2015.01.01-2015.06.30 based on MT4 FXCM backtest data, 9,5mln ticks, quality 25%]:
 *   �33714.17	5911	1.37	5.70	8643.29	53.15%	0.00000000	MACD_Fast_Period=12 	MACD_Slow_Period=30 	MACD_Signal_Period=9 (deposit �10000, spread 25, no boosting, no actions)
 *
 */
//+------------------------------------------------------------------+
extern string __Alligator_Parameters__ = "-- Settings for the Alligator indicator --";
#ifndef __disabled__
  extern bool Alligator1_Active = TRUE, Alligator5_Active = TRUE, Alligator15_Active = TRUE, Alligator30_Active = TRUE; // Enable Alligator custom-based strategy for specific timeframe.
#else
  extern bool Alligator1_Active = FALSE, Alligator5_Active = FALSE, Alligator15_Active = FALSE, Alligator30_Active = FALSE;
#endif
// extern ENUM_TIMEFRAMES Alligator_Timeframe = PERIOD_M1; // Timeframe (0 means the current chart).
extern int Alligator_Jaw_Period = 22; // Blue line averaging period (Alligator's Jaw).
extern int Alligator_Jaw_Shift = 0; // Blue line shift relative to the chart.
extern int Alligator_Teeth_Period = 10; // Red line averaging period (Alligator's Teeth).
extern int Alligator_Teeth_Shift = 4; // Red line shift relative to the chart.
extern int Alligator_Lips_Period = 9; // Green line averaging period (Alligator's Lips).
extern int Alligator_Lips_Shift = 2; // Green line shift relative to the chart.
extern ENUM_MA_METHOD Alligator_MA_Method = MODE_EMA; // MA method (See: ENUM_MA_METHOD).
extern ENUM_APPLIED_PRICE Alligator_Applied_Price = PRICE_HIGH; // Applied price. It can be any of ENUM_APPLIED_PRICE enumeration values.
extern int Alligator_Shift = 0; // The indicator shift relative to the chart.
extern int Alligator_Shift_Far = 1; // The indicator shift relative to the chart.
#ifndef __rider__
  extern ENUM_TRAIL_TYPE Alligator_TrailingStopMethod = T_MA_FMS_PEAK; // Trailing Stop method for Alligator. Set 0 to default (DefaultTrailingStopMethod). See: ENUM_TRAIL_TYPE.
  extern ENUM_TRAIL_TYPE Alligator_TrailingProfitMethod = T_BANDS_PEAK; // Trailing Profit method for Alligator. Set 0 to default (DefaultTrailingProfitMethod). See: ENUM_TRAIL_TYPE.
#else
  extern ENUM_TRAIL_TYPE Alligator_TrailingStopMethod = T_MA_FMS_PEAK;
  extern ENUM_TRAIL_TYPE Alligator_TrailingProfitMethod = T_BANDS_PEAK;
#endif
extern double Alligator_OpenLevel = 0.01; // Minimum open level between moving averages to raise the trade signal.
extern int Alligator1_OpenMethod  = 6; // Valid range: 0-63.
extern int Alligator5_OpenMethod  = 6; // Valid range: 0-63.
extern int Alligator15_OpenMethod  = 9; // Valid range: 0-63.
extern int Alligator30_OpenMethod  = 13; // Valid range: 0-63. This value is used for close condition. Used for C_MA_BUY_SELL close condition (6). (2765/1.20)
#ifdef __advanced__
  extern int Alligator1_OpenCondition1 = 0; // Valid range: 0-1023.
  extern int Alligator1_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT Alligator1_CloseCondition = C_MA_BUY_SELL;
  extern int Alligator5_OpenCondition1 = 0; // Valid range: 0-1023.
  extern int Alligator5_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT Alligator5_CloseCondition = C_MA_BUY_SELL;
  extern int Alligator15_OpenCondition1 = 0; // Valid range: 0-1023.
  extern int Alligator15_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT Alligator15_CloseCondition = C_MA_BUY_SELL;
  extern int Alligator30_OpenCondition1 = 0; // Valid range: 0-1023.
  extern int Alligator30_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT Alligator30_CloseCondition = C_MACD_BUY_SELL;
#endif
#ifdef __advanced__
  extern double Alligator1_MaxSpread  =  6.0;  // Maximum spread to trade (in pips).
  extern double Alligator5_MaxSpread  =  7.0;  // Maximum spread to trade (in pips).
  extern double Alligator15_MaxSpread =  8.0; // Maximum spread to trade (in pips).
  extern double Alligator30_MaxSpread = 10.0; // Maximum spread to trade (in pips).
#endif
/*
 * Alligator backtest log (ts:40,tp:30,gap:10) [2015.01.01-2015.06.30 based on MT4 FXCM backtest data, 9,5mln ticks, quality 25%]:
 *   �18429.60	4363	1.32	4.22	14102.48	63.82% (d: �10k, spread 25, lot size: 0.1, no boosts/actions)
 *   �21362.41	2753	1.48	7.76	5174.72	36.07%	0.00000000	Alligator_TrailingStopMethod=22 (rider: d: �10k, spread 20, lot size: 0.1, no boosts, with actions)
 *   �22299.85	2753	1.51	8.10	5106.04	35.06%	0.00000000	Alligator_Jaw_Period=22 	Alligator_Teeth_Period=10 	Alligator_Lips_Period=9 (rider: d: �10k, spread 20, lot size: 0.1, no boosts, with actions)
 */
//+------------------------------------------------------------------+
extern string __RSI_Parameters__ = "-- Settings for the Relative Strength Index indicator --";
#ifndef __disabled__
  extern bool RSI1_Active = TRUE, RSI5_Active = TRUE, RSI15_Active = TRUE, RSI30_Active = TRUE; // Enable RSI-based strategy for specific timeframe.
#else
  extern bool RSI1_Active = FALSE, RSI5_Active = FALSE, RSI15_Active = FALSE, RSI30_Active = FALSE;
#endif
extern int RSI_Period = 20; // Averaging period for calculation.
extern ENUM_APPLIED_PRICE RSI_Applied_Price = PRICE_MEDIAN; // RSI applied price (See: ENUM_APPLIED_PRICE). Range: 0-6.
extern int RSI_Shift = 0; // Shift relative to the chart.
extern int RSI_OpenLevel = 20;
#ifndef __rider__
  extern ENUM_TRAIL_TYPE RSI_TrailingStopMethod = T_5_BARS_PEAK; // Trailing Stop method for RSI. Set 0 to default (DefaultTrailingStopMethod). See: ENUM_TRAIL_TYPE.
  extern ENUM_TRAIL_TYPE RSI_TrailingProfitMethod = T_5_BARS_PEAK; // Trailing Profit method for RSI. Set 0 to default (DefaultTrailingProfitMethod). See: ENUM_TRAIL_TYPE.
#else
  extern ENUM_TRAIL_TYPE RSI_TrailingStopMethod = T_MA_FMS_PEAK;
  extern ENUM_TRAIL_TYPE RSI_TrailingProfitMethod = T_MA_FMS_PEAK;
#endif
extern int RSI1_OpenMethod  = 0; // Valid range: 0-63.
extern int RSI5_OpenMethod  = 0; // Valid range: 0-63. Optimized based on genetic algorithm between 2015.01.01-2015.06.30 with spread 20. 2, 5, 306, 374, 388, 642
extern int RSI15_OpenMethod = 0; // Valid range: 0-63.
extern int RSI30_OpenMethod = 2; // Valid range: 0-63. Used for C_RSI_BUY_SELL close condition (6).
#ifdef __advanced__
  extern int RSI1_OpenCondition1 = 0; // Valid range: 0-1023. Optimized based on genetic algorithm between 2015.01.01-2015.06.30 with spread 20.
  extern int RSI1_OpenCondition2 = 0; // Valid range: 0-1023. Optimized based on genetic algorithm between 2015.01.01-2015.06.30 with spread 20.
  extern ENUM_MARKET_EVENT RSI1_CloseCondition = C_MACD_BUY_SELL;
  // �6077.73	982	1.31	6.19	6150.06	19.66%	RSI1_CloseCondition=2 (deposit: �10000, spread 20, __testing__)
  extern int RSI5_OpenCondition1 = 0; // Valid range: 0-1023. TODO: To optimize. 36/64
  extern int RSI5_OpenCondition2 = 0; // Valid range: 0-1023. TODO: To optimize. 1/16/76/196/529
  extern ENUM_MARKET_EVENT RSI5_CloseCondition = C_MACD_BUY_SELL;
  // �7051.01	809	1.43	8.72	4789.69	22.92% (deposit: �10000, spread 20, __testing__)
  extern int RSI15_OpenCondition1 = 116; // Valid range: 0-1023. TODO
  extern int RSI15_OpenCondition2 = 1; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT RSI15_CloseCondition = C_MACD_BUY_SELL;
  // �5321.65	613	1.42	8.68	3408.52	12.33%	RSI15_CloseCondition=2 (deposit: �10000, spread 20, __testing__)
  extern int RSI30_OpenCondition1 = 0; // Valid range: 0-1023.
  extern int RSI30_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT RSI30_CloseCondition = C_MACD_BUY_SELL;
  // �4019.61	456	1.41	8.81	1737.77	15.71%	RSI30_OpenMethod=2 (deposit: �10000, spread 20, __testing__)
  // �2927.64	381	1.35	7.68	1737.20	13.53%	RSI30_CloseCondition=2, RSI30_OpenMethod=6 (deposit: �10000, spread 20, __testing__)
#endif
#ifdef __advanced__
  extern double RSI1_MaxSpread =   6.0;  // Maximum spread to trade (in pips).
  extern double RSI5_MaxSpread =   7.0;  // Maximum spread to trade (in pips).
  extern double RSI15_MaxSpread =  8.0; // Maximum spread to trade (in pips).
  extern double RSI30_MaxSpread = 10.0; // Maximum spread to trade (in pips).
#endif
#ifdef __advanced__
  extern bool RSI_DynamicPeriod = FALSE;
  int RSI1_IncreasePeriod_MinDiff = 27, RSI1_DecreasePeriod_MaxDiff = 61;
  int RSI5_IncreasePeriod_MinDiff = 20, RSI5_DecreasePeriod_MaxDiff = 68;
  int RSI15_IncreasePeriod_MinDiff = 18, RSI15_DecreasePeriod_MaxDiff = 58;
  int RSI30_IncreasePeriod_MinDiff = 26, RSI30_DecreasePeriod_MaxDiff = 60;
#endif
/*
 * RSI backtest log (ts:40,tp:30,gap:10) [2015.01.01-2015.06.30 based on MT4 FXCM backtest data, 9,5mln ticks, quality 25%]:
 *
 * RSI backtest log (auto,ts:25,tp:25,gap:10) [2015.01.05-2015.06.20 based on MT4 FXCM backtest data, spread 2, 7,6mln ticks, quality 25%]:
 *   �3367.78 2298  1.24  1.47  1032.39 42.64%  0.00000000  RSI_CloseOnChange=0 (deposit: �1000, boosting factor 1.0)
 *   �3249.67 2338  1.24  1.39  1025.47 44.49%  0.00000000  RSI_CloseOnChange=1 (deposit: �1000, boosting factor 1.0)
 *   �4551.26 2331  1.34  1.95  1030.22 9.06% RSI_TrailingProfitMethod=1 (deposit: �10000, boosting factor 1.0)
 *   Strategy stats:
 *    RSI M1: Total net profit: 23205 pips, Total orders: 2726 (Won: 68.6% [1871] | Loss: 31.4% [855]);
 *    RSI M5: Total net profit: 2257 pips, Total orders: 391 (Won: 48.1% [188] | Loss: 51.9% [203]);
 *    RSI M15: Total net profit: 4970 pips, Total orders: 496 (Won: 52.2% [259] | Loss: 47.8% [237]);
 *    RSI M30: Total net profit: 2533 pips, Total orders: 272 (Won: 48.5% [132] | Loss: 51.5% [140]);
 * Deposit: �10000 (factor = 1.0) && RSI_DynamicPeriod
 *  �3380.43  2142  1.31  1.58  541.01  5.12% 0.00000000  RSI_DynamicPeriod=1
 *  �3060.19  1307  1.44  2.34  549.59  4.66% 0.00000000  RSI_DynamicPeriod=0
 *
 * RSI backtest log (ts:40,tp:20,gap:10) [2015.01.01-2015.06.30 based on MT4 FXCM backtest data, spread 25, 9,5mln ticks, quality 25%]:
 *   TODO
 */
//+------------------------------------------------------------------+
extern string __SAR_Parameters__ = "-- Settings for the the Parabolic Stop and Reverse system indicator --";
#ifndef __disabled__
  extern bool SAR1_Active = TRUE, SAR5_Active = TRUE, SAR15_Active = TRUE, SAR30_Active = TRUE; // Enable SAR-based strategy for specific timeframe.
#else
  extern bool SAR1_Active = FALSE, SAR5_Active = FALSE, SAR15_Active = FALSE, SAR30_Active = FALSE;
#endif
extern double SAR_Step = 0.02; // Stop increment, usually 0.02.
extern double SAR_Maximum_Stop = 0.3; // Maximum stop value, usually 0.2.
extern int SAR_Shift = 0; // Shift relative to the chart.
extern double SAR_OpenLevel = 0.0; // Open gap level to raise the trade signal (in pips).
#ifndef __rider__
  extern ENUM_TRAIL_TYPE SAR_TrailingStopMethod = T_MA_FMS_PEAK; // Trailing Stop method for SAR. Set 0 to default (DefaultTrailingStopMethod). See: ENUM_TRAIL_TYPE.
  extern ENUM_TRAIL_TYPE SAR_TrailingProfitMethod = T_FIXED; // Trailing Profit method for SAR. Set 0 to default (DefaultTrailingProfitMethod). See: ENUM_TRAIL_TYPE.
#else
  extern ENUM_TRAIL_TYPE SAR_TrailingStopMethod = T_MA_FMS_PEAK;
  extern ENUM_TRAIL_TYPE SAR_TrailingProfitMethod = T_FIXED;
#endif
extern int SAR1_OpenMethod  = 0; // Valid range: 0-127. Optimized.
extern int SAR5_OpenMethod  = 4; // Valid range: 0-127. Optimized.
extern int SAR15_OpenMethod = 0; // Valid range: 0-127. Optimized.
extern int SAR30_OpenMethod = 0; // Valid range: 0-127. Used for C_SAR_BUY_SELL close condition.
#ifdef __advanced__
  extern int SAR1_OpenCondition1 = 512;
  extern int SAR1_OpenCondition2 = 0;
  extern ENUM_MARKET_EVENT SAR1_CloseCondition = C_MACD_BUY_SELL;
  // �8129.37	1079	1.38	7.53	10255.51	27.67% (d: �20k, sp: 20, ls:0.1, __testing__)
  extern int SAR5_OpenCondition1 = 514; // Valid range: 0-1023.
  extern int SAR5_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT SAR5_CloseCondition = C_MACD_BUY_SELL;
  // �9968.31	905	1.57	11.01	9781.86	25.59% (d: �20k, sp: 20, ls:0.1, __testing__)
  extern int SAR15_OpenCondition1 = 0; // Valid range: 0-1023.
  extern int SAR15_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT SAR15_CloseCondition = C_MACD_BUY_SELL;
  // �11957.61	1150	1.52	10.40	9154.70	24.23% (d: �20k, sp: 20, ls:0.1, __testing__)
  extern int SAR30_OpenCondition1 = 0; // Valid range: 0-1023.
  extern int SAR30_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT SAR30_CloseCondition = C_MACD_BUY_SELL;
  // �13420.26	1141	1.60	11.76	10032.18	24.52% (d: �20k, sp: 20, ls:0.1, __testing__)
#endif
#ifdef __advanced__
  extern double SAR1_MaxSpread  =  6.0; // Maximum spread to trade (in pips).
  extern double SAR5_MaxSpread  =  7.0; // Maximum spread to trade (in pips).
  extern double SAR15_MaxSpread =  8.0; // Maximum spread to trade (in pips).
  extern double SAR30_MaxSpread = 10.0; // Maximum spread to trade (in pips).
#endif
/*
 * SAR backtest log (auto,ts:40,tp:30,gap:10) [2015.01.01-2015.06.30 based on MT4 FXCM backtest data, 9,5mln ticks, quality 25%]:
 *   �37878.53	4274	1.21	8.86	69890.74	76.77%	TradeWithTrend=0 (d: �20k, sp: 20, ls:auto, __testing__)
 *   �25549.59	4007	1.18	6.38	60049.74	76.82%	TradeWithTrend=1 (d: �20k, sp: 20, ls:auto, __testing__)
 *   �45203.65	5586	1.18	8.09	27420.74	48.15%	Account_Conditions_Active=1 (d: �20k, sp: 20, ls:auto, with actions, no boosting)
 *
 *   Strategy stats (deposit: �10000, spread 20, ls:auto, __testing__):
      Profit factor: 1.14, Total net profit: 6131.69pips (+51196.06/-45064.37), Total orders: 1083 (Won: 27.9% [302] / Loss: 72.1% [781]) - SAR M1
      Profit factor: 1.30, Total net profit: 11347.41pips (+48828.04/-37480.63), Total orders: 901 (Won: 28.5% [257] / Loss: 71.5% [644]) - SAR M5
      Profit factor: 1.17, Total net profit: 8120.80pips (+57220.29/-49099.49), Total orders: 1145 (Won: 26.2% [300] / Loss: 73.8% [845]) - SAR M15
      Profit factor: 1.27, Total net profit: 12706.46pips (+59705.56/-46999.10), Total orders: 1131 (Won: 27.9% [315] / Loss: 72.1% [816]) - SAR M30
 *
 */
//+------------------------------------------------------------------+
extern string __Bands_Parameters__ = "-- Settings for the Bollinger Bands indicator --";
#ifndef __disabled__
  extern bool Bands1_Active = TRUE, Bands5_Active = TRUE, Bands15_Active = TRUE, Bands30_Active = TRUE; // Enable Bands-based strategy fpr specific timeframe.
#else
  extern bool Bands1_Active = FALSE, Bands5_Active = FALSE, Bands15_Active = FALSE, Bands30_Active = FALSE;
#endif
extern int Bands_Period = 26; // Averaging period to calculate the main line.
extern ENUM_APPLIED_PRICE Bands_Applied_Price = PRICE_MEDIAN; // Bands applied price (See: ENUM_APPLIED_PRICE). Range: 0-6.
extern double Bands_Deviation = 2.1; // Number of standard deviations from the main line.
extern int Bands_Shift = 0; // The indicator shift relative to the chart.
extern int Bands_Shift_Far = 0; // The indicator shift relative to the chart.
//extern bool Bands_CloseOnChange = FALSE; // Close opposite orders on market change.
#ifndef __rider__
  extern ENUM_TRAIL_TYPE Bands_TrailingStopMethod = T_MA_FMS_PEAK; // Trailing Stop method for Bands. Set 0 to default (DefaultTrailingStopMethod). See: ENUM_TRAIL_TYPE.
  extern ENUM_TRAIL_TYPE Bands_TrailingProfitMethod = T_MA_FMS_PEAK; // Trailing Profit method for Bands. Set 0 to default (DefaultTrailingProfitMethod). See: ENUM_TRAIL_TYPE.
#else
  extern ENUM_TRAIL_TYPE Bands_TrailingStopMethod = T_MA_FMS_PEAK;
  extern ENUM_TRAIL_TYPE Bands_TrailingProfitMethod = T_MA_FMS_PEAK;
#endif
extern int Bands1_OpenMethod = 0; // Valid range: 0-255.
extern int Bands5_OpenMethod = 0; // Valid range: 0-255.
extern int Bands15_OpenMethod = 16; // Valid range: 0-255.
extern int Bands30_OpenMethod = 0; // Valid range: 0-255. Previously: 417. Used for C_BANDS_BUY_SELL close condition.
#ifdef __advanced__
  extern int Bands1_OpenCondition1 = 528; // Valid range: 0-1023. // TODO
  extern int Bands1_OpenCondition2 = 0; // Valid range: 0-1023. // TODO
  extern ENUM_MARKET_EVENT Bands1_CloseCondition = C_MACD_BUY_SELL;
  // �11618.71	741	1.81	15.68	5546.73	21.70%	0.00000000	Bands1_OpenCondition1=528	TrailingStop=40 (d: �10k, sp: 20, ls:0.1, __testing__)
  // �11236.18	926	1.62	12.13	4957.40	25.95%	0.00000000	Bands1_OpenMethod=16 	Bands1_OpenCondition1=16 (d: �10k, sp: 20, ls:0.1, __testing__)
  // �10762.86	937	1.58	11.49	4835.66	26.13%	0.00000000	Bands1_OpenMethod=0 	Bands1_OpenCondition1=16 (d: �10k, sp: 20, ls:0.1, __testing__)
  extern int Bands5_OpenCondition1 = 528; // Valid range: 0-1023. // TODO
  extern int Bands5_OpenCondition2 = 0; // Valid range: 0-1023. // TODO
  extern ENUM_MARKET_EVENT Bands5_CloseCondition = C_MACD_BUY_SELL;
  // �8599.17	644	1.69	13.35	4715.84	20.73%	0.00000000	Bands5_OpenCondition1=528 (d: �10k, sp: 20, ls:0.1, __testing__)
  // �7379.55	1119	1.33	6.59	6926.42	29.15%	0.00000000	Bands5_OpenMethod=0 	Bands5_OpenCondition2=0 (d: �10k, sp: 20, ls:0.1, __testing__)
  extern int Bands15_OpenCondition1 = 0; // Valid range: 0-1023. // TODO
  extern int Bands15_OpenCondition2 = 0; // Valid range: 0-1023. // TODO
  extern ENUM_MARKET_EVENT Bands15_CloseCondition = C_MACD_BUY_SELL;
  // �6475.19	1020	1.32	6.35	7177.96	31.84%	0.00000000	Bands15_OpenMethod=16 	Bands15_OpenCondition2=0 	Bands15_CloseCondition=2 (d: �10k, sp: 20, ls:0.1, __testing__)
  extern int Bands30_OpenCondition1 = 0; // Valid range: 0-1023.
  extern int Bands30_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT Bands30_CloseCondition = C_MACD_BUY_SELL;
  // �6710.23	935	1.37	7.18	5805.15	28.88%	0.00000000	Bands30_OpenMethod=0 	Bands30_CloseCondition=2 (d: �10k, sp: 20, ls:0.1, __testing__)
#endif
#ifdef __advanced__
  extern double Bands1_MaxSpread  =  6.0; // Maximum spread to trade (in pips).
  extern double Bands5_MaxSpread  =  7.0; // Maximum spread to trade (in pips).
  extern double Bands15_MaxSpread =  8.0; // Maximum spread to trade (in pips).
  extern double Bands30_MaxSpread = 10.0; // Maximum spread to trade (in pips).
#endif
/*
 * Bands backtest log (auto,ts:40,tp:30,gap:10) [2015.01.01-2015.06.30 based on MT4 FXCM backtest data, 9,5mln ticks, quality 25%]:
 *   �30087.06	3123	1.49	9.63	21508.48	59.74% Bands_TrailingProfitMethod=7 (d: �10k, sp: 20, ls:0.1, __testing__)
 *   �28420.72	3126	1.47	9.09	20860.99	65.05% Bands_TrailingProfitMethod=1 (d: �10k, sp: 20, ls:0.1, __testing__)
 *
 *   Strategy stats (deposit: �10000, spread 20, ls:auto, __testing__):
 */
//+------------------------------------------------------------------+
extern string __Envelopes_Parameters__ = "-- Settings for the Envelopes indicator --";
#ifndef __disabled__
  extern bool Envelopes1_Active = TRUE, Envelopes5_Active = TRUE, Envelopes15_Active = TRUE, Envelopes30_Active = TRUE; // Enable Envelopes-based strategy fpr specific timeframe.
#else
  extern bool Envelopes1_Active = FALSE, Envelopes5_Active = FALSE, Envelopes15_Active = FALSE, Envelopes30_Active = FALSE;
#endif
extern int Envelopes_MA_Period = 28; // Averaging period to calculate the main line.
extern ENUM_MA_METHOD Envelopes_MA_Method = MODE_SMA; // MA method (See: ENUM_MA_METHOD).
extern int Envelopes_MA_Shift = 0; // The indicator shift relative to the chart.
extern ENUM_APPLIED_PRICE Envelopes_Applied_Price = PRICE_TYPICAL; // Applied price (See: ENUM_APPLIED_PRICE). Range: 0-6.
extern double Envelopes1_Deviation = 0.08; // Percent deviation from the main line.
// �1804.07	1620	1.12	1.11	1396.96	11.31%	0.00000000	Envelopes1_Deviation=0.07 (d:�10k)
// �1800.30	1549	1.13	1.16	1352.76	11.01%	0.00000000	Envelopes1_Deviation=0.08 (d:�10k)
extern double Envelopes5_Deviation = 0.12; // Percent deviation from the main line.
extern double Envelopes15_Deviation = 0.15; // Percent deviation from the main line.
extern double Envelopes30_Deviation = 0.4; // Percent deviation from the main line.
// extern int Envelopes_Shift_Far = 0; // The indicator shift relative to the chart.
extern int Envelopes_Shift = 2; // The indicator shift relative to the chart.
#ifndef __rider__
  extern ENUM_TRAIL_TYPE Envelopes_TrailingStopMethod = T_MA_FMS_PEAK; // Trailing Stop method for Bands. Set 0 to default (DefaultTrailingStopMethod). See: ENUM_TRAIL_TYPE.
  extern ENUM_TRAIL_TYPE Envelopes_TrailingProfitMethod = T_MA_FMS_PEAK; // Trailing Profit method for Bands. Set 0 to default (DefaultTrailingProfitMethod). See: ENUM_TRAIL_TYPE.
#else
  extern ENUM_TRAIL_TYPE Envelopes_TrailingStopMethod = T_MA_FMS_PEAK;
  extern ENUM_TRAIL_TYPE Envelopes_TrailingProfitMethod = T_MA_FMS_PEAK;
#endif
extern int Envelopes1_OpenMethod = 0; // Valid range: 0-127. Set 0 to default.
extern int Envelopes5_OpenMethod = 0; // Valid range: 0-127. Set 0 to default.
extern int Envelopes15_OpenMethod = 0; // Valid range: 0-127. Set 0 to default.
extern int Envelopes30_OpenMethod = 4; // Valid range: 0-127. Set 0 to default. Used for C_ENVELOPES_BUY_SELL close condition.
#ifdef __advanced__
  extern int Envelopes1_OpenCondition1 = 528; // Valid range: 0-1023. Optimized based on genetic algorithm between 2015.01.01-2015.06.30 with spread 20. 768-880
  extern int Envelopes1_OpenCondition2 = 0; // Valid range: 0-1023. Optimized based on genetic algorithm between 2015.01.01-2015.06.30 with spread 20. 8/24
  extern ENUM_MARKET_EVENT Envelopes1_CloseCondition = C_MACD_BUY_SELL;
  //
  extern int Envelopes5_OpenCondition1 = 528; // Valid range: 0-1023.
  extern int Envelopes5_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT Envelopes5_CloseCondition = C_MACD_BUY_SELL;
  //
  extern int Envelopes15_OpenCondition1 = 528; // Valid range: 0-1023. // TODO
  extern int Envelopes15_OpenCondition2 = 0; // Valid range: 0-1023. // TODO
  extern ENUM_MARKET_EVENT Envelopes15_CloseCondition = C_MACD_BUY_SELL;
  //
  extern int Envelopes30_OpenCondition1 = 528; // Valid range: 0-1023. Try: 512, 528
  extern int Envelopes30_OpenCondition2 = 0; // Valid range: 0-1023. Try: 0, 8, 16, 24
  extern ENUM_MARKET_EVENT Envelopes30_CloseCondition = C_MACD_BUY_SELL;
  //
#endif
#ifdef __advanced__
  extern double Envelopes1_MaxSpread  =  6.0; // Maximum spread to trade (in pips).
  extern double Envelopes5_MaxSpread  =  7.0; // Maximum spread to trade (in pips).
  extern double Envelopes15_MaxSpread =  8.0; // Maximum spread to trade (in pips).
  extern double Envelopes30_MaxSpread = 10.0; // Maximum spread to trade (in pips).
#endif
/*
 * Envelopes backtest log (auto,ts:40,tp:30,gap:10) [2015.01.01-2015.06.30 based on MT4 FXCM backtest data, 9,5mln ticks, quality 25%]:
 *  �33014.05	2758	1.61	11.97	18039.17	44.56%	Envelopes_MA_Period=26 (d: �10k, sp: 20, ls:0.1, __testing__)
 *  �34606.84	2745	1.64	12.61	17735.31	43.79%	Envelopes_MA_Period=28 (d: �10k, sp: 20, ls:0.1, __testing__)
 */
//+------------------------------------------------------------------+
extern string __WPR_Parameters__ = "-- Settings for the Larry Williams' Percent Range indicator --";
#ifndef __disabled__
  extern bool WPR1_Active = TRUE, WPR5_Active = TRUE, WPR15_Active = TRUE, WPR30_Active = TRUE; // Enable WPR-based strategy for specific timeframe.
#else
  extern bool WPR1_Active = FALSE, WPR5_Active = FALSE, WPR15_Active = FALSE, WPR30_Active = FALSE;
#endif
extern int WPR_Period = 21; // Averaging period for calculation. Suggested value: 22.
extern int WPR_Shift = 0; // Shift relative to the current bar the given amount of periods ago. Suggested value: 1.
extern int WPR_OpenLevel = 30; // Suggested range: 25-35.
//extern bool WPR_CloseOnChange = TRUE; // Close opposite orders on market change.
#ifndef __rider__
  extern ENUM_TRAIL_TYPE WPR_TrailingStopMethod = T_MA_FMS_PEAK; // Trailing Stop method for WPR. Set 0 to default (DefaultTrailingStopMethod). See: ENUM_TRAIL_TYPE. // Try: T_MA_M_FAR_TRAIL
  extern ENUM_TRAIL_TYPE WPR_TrailingProfitMethod = T_MA_FMS_PEAK; // Trailing Profit method for WPR. Set 0 to default (DefaultTrailingProfitMethod). See: ENUM_TRAIL_TYPE.
#else
  extern ENUM_TRAIL_TYPE WPR_TrailingStopMethod = T_MA_FMS_PEAK;
  extern ENUM_TRAIL_TYPE WPR_TrailingProfitMethod = T_MA_FMS_PEAK;
#endif
extern int WPR1_OpenMethod = 0; // Valid range: 0-63. Optimized.
extern int WPR5_OpenMethod = 0; // Valid range: 0-63. Optimized.
extern int WPR15_OpenMethod = 0; // Valid range: 0-63. Optimized.
extern int WPR30_OpenMethod = 0; // Valid range: 0-63. Optimized with T_MA_M_FAR_TRAIL (8). Used for C_WPR_BUY_SELL close condition (16).
#ifdef __advanced__
  extern int WPR1_OpenCondition1 = 528; // Valid range: 0-1023. 512 (4) 516
  extern int WPR1_OpenCondition2 = 0; // Valid range: 0-1023. 0 (32) 96
  extern ENUM_MARKET_EVENT WPR1_CloseCondition = C_MACD_BUY_SELL;
  //
  extern int WPR5_OpenCondition1 = 528; // Valid range: 0-1023. >512
  extern int WPR5_OpenCondition2 = 0; // Valid range: 0-1023. 0/16
  extern ENUM_MARKET_EVENT WPR5_CloseCondition = C_MACD_BUY_SELL;
  //
  extern int WPR15_OpenCondition1 = 528; // Valid range: 0-1023. // TODO: Further backtesting required.
  extern int WPR15_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT WPR15_CloseCondition = C_MACD_BUY_SELL;
  //
  extern int WPR30_OpenCondition1 = 528; // Valid range: 0-1023. // TODO: Further backtesting required.
  extern int WPR30_OpenCondition2 = 0; // Valid range: 0-1023. // TODO: Further backtesting required.
  extern ENUM_MARKET_EVENT WPR30_CloseCondition = C_MACD_BUY_SELL;
  //
#endif
#ifdef __advanced__
  extern double WPR1_MaxSpread  =  6.0; // Maximum spread to trade (in pips).
  extern double WPR5_MaxSpread  =  7.0; // Maximum spread to trade (in pips).
  extern double WPR15_MaxSpread =  8.0; // Maximum spread to trade (in pips).
  extern double WPR30_MaxSpread = 10.0; // Maximum spread to trade (in pips).
#endif
/*
 * WPR backtest log (auto,ts:40,tp:30,gap:10) [2015.01.01-2015.06.30 based on MT4 FXCM backtest data, spread 20, 9,5mln ticks, quality 25%]:
 *   �34417.03	2394	1.74	14.38	16126.15	44.53% (d: �10k, sp: 20, ls:0.1, __testing__)
 */
//+------------------------------------------------------------------+
extern string __DeMarker_Parameters__ = "-- Settings for the DeMarker indicator --";
#ifndef __disabled__
  extern bool DeMarker1_Active = TRUE, DeMarker5_Active = TRUE, DeMarker15_Active = TRUE, DeMarker30_Active = TRUE; // Enable DeMarker-based strategy for specific timeframe.
#else
  extern bool DeMarker1_Active = FALSE, DeMarker5_Active = FALSE, DeMarker15_Active = FALSE, DeMarker30_Active = FALSE;
#endif
//extern ENUM_TIMEFRAMES DeMarker_Timeframe = PERIOD_M1; // Timeframe (0 means the current chart).
extern int DeMarker_Period = 24; // DeMarker averaging period for calculation.
extern int DeMarker_Shift = 0; // Shift relative to the current bar the given amount of periods ago. Suggested value: 4.
extern double DeMarker_OpenLevel = 0.2; // Valid range: 0.0-0.4. Suggested value: 0.0.
//extern bool DeMarker_CloseOnChange = FALSE; // Close opposite orders on market change.
#ifndef __rider__
  extern ENUM_TRAIL_TYPE DeMarker_TrailingStopMethod = T_MA_FMS_PEAK; // Trailing Stop method for DeMarker. Set 0 to default (DefaultTrailingStopMethod). See: ENUM_TRAIL_TYPE.
  extern ENUM_TRAIL_TYPE DeMarker_TrailingProfitMethod = T_MA_FMS_PEAK; // Trailing Profit method for DeMarker. Set 0 to default (DefaultTrailingProfitMethod). See: ENUM_TRAIL_TYPE.
#else
  extern ENUM_TRAIL_TYPE DeMarker_TrailingStopMethod = T_MA_FMS_PEAK;
  extern ENUM_TRAIL_TYPE DeMarker_TrailingProfitMethod = T_MA_FMS_PEAK;
#endif
extern int DeMarker1_OpenMethod = 0; // Valid range: 0-31.
extern int DeMarker5_OpenMethod = 0; // Valid range: 0-31.
extern int DeMarker15_OpenMethod = 0; // Valid range: 0-31.
extern int DeMarker30_OpenMethod = 0; // Valid range: 0-31. Used for C_DEMARKER_BUY_SELL close condition.
#ifdef __advanced__
  extern int DeMarker1_OpenCondition1 = 528; // Valid range: 0-1023.
  extern int DeMarker1_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT DeMarker1_CloseCondition = C_MACD_BUY_SELL;
  extern int DeMarker5_OpenCondition1 = 528; // Valid range: 0-1023.
  extern int DeMarker5_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT DeMarker5_CloseCondition = C_MACD_BUY_SELL;
  extern int DeMarker15_OpenCondition1 = 528; // Valid range: 0-1023.
  extern int DeMarker15_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT DeMarker15_CloseCondition = C_MACD_BUY_SELL;
  extern int DeMarker30_OpenCondition1 = 528; // Valid range: 0-1023.
  extern int DeMarker30_OpenCondition2 = 0; // Valid range: 0-1023.
  extern ENUM_MARKET_EVENT DeMarker30_CloseCondition = C_MACD_BUY_SELL;
#endif
#ifdef __advanced__
  extern double DeMarker1_MaxSpread  =  6.0; // Maximum spread to trade (in pips).
  extern double DeMarker5_MaxSpread  =  7.0; // Maximum spread to trade (in pips).
  extern double DeMarker15_MaxSpread =  8.0; // Maximum spread to trade (in pips).
  extern double DeMarker30_MaxSpread = 10.0; // Maximum spread to trade (in pips).
#endif
/* DeMarker backtest log (auto,ts:40,tp:30,gap:10) [2015.01.01-2015.06.30 based on MT4 FXCM backtest data, spread 20, 9,5mln ticks, quality 25%]:
 *   �32058.66	2358	1.68	13.60	13837.63	37.93%

 *   �5968.23 5968  1.17  1.00  1314.82 47.46% (deposit: �1000, no boosting)
 *   �7465.39 5966  1.21  1.25  1306.65 9.32% (deposit: �10000, no boosting)
 *   $11414.20  5966  1.21  1.91  1776.70 12.99% (deposit: $10000, no boosting)
 *   Strategy stats:
 *   DeMarker M1: Total net profit: 930 pips, Total orders: 2145 (Won: 30.7% [659] | Loss: 69.3% [1486]);
 *   DeMarker M5: Total net profit: 1699 pips, Total orders: 1751 (Won: 31.1% [544] | Loss: 68.9% [1207]);
 *   DeMarker M15: Total net profit: 1882 pips, Total orders: 1281 (Won: 37.7% [483] | Loss: 62.3% [798]);
 *   DeMarker M30: Total net profit: 905 pips, Total orders: 789 (Won: 40.7% [321] | Loss: 59.3% [468]);
 *   Prev: �1929.90 2778  1.13  0.69  525.00  21.84% (deposit: �1000, no boosting)
 *   Prev: �3369.57 1694  1.25  1.99  588.65  21.19%  0.00000000  DeMarker_TrailingProfitMethod=19 (deposit: �1000)
 */
//+------------------------------------------------------------------+
extern string __Fractals_Parameters__ = "-- Settings for the Fractals indicator --";
#ifndef __disabled__
  extern bool Fractals1_Active = TRUE, Fractals5_Active = TRUE, Fractals15_Active = TRUE, Fractals30_Active = TRUE; // Enable Fractals-based strategy for specific timeframe.
#else
  extern bool Fractals1_Active = FALSE, Fractals5_Active = FALSE, Fractals15_Active = FALSE, Fractals30_Active = FALSE;
#endif
//extern bool Fractals_CloseOnChange = TRUE; // Close opposite orders on market change.
#ifndef __rider__
  extern ENUM_TRAIL_TYPE Fractals_TrailingStopMethod = T_MA_FMS_PEAK; // Trailing Stop method for Fractals. Set 0 to default (DefaultTrailingStopMethod). See: ENUM_TRAIL_TYPE.
  extern ENUM_TRAIL_TYPE Fractals_TrailingProfitMethod = T_MA_FMS_PEAK; // Trailing Profit method for Fractals. Set 0 to default (DefaultTrailingProfitMethod). See: ENUM_TRAIL_TYPE.
#else
  extern ENUM_TRAIL_TYPE Fractals_TrailingStopMethod = T_MA_FMS_PEAK;
  extern ENUM_TRAIL_TYPE Fractals_TrailingProfitMethod = T_MA_FMS_PEAK;
#endif
extern int Fractals1_OpenMethod = 0; // Valid range: 0-63.
extern int Fractals5_OpenMethod = 0; // Valid range: 0-63.
extern int Fractals15_OpenMethod = 0; // Valid range: 0-63. // Optimized.
extern int Fractals30_OpenMethod = 0; // Valid range: 0-63. // Optimized for C_FRACTALS_BUY_SELL close condition.
#ifdef __advanced__
  extern int Fractals1_OpenCondition1 = 528; // Valid range: 0-1023. 512, 800 ,832
  extern int Fractals1_OpenCondition2 = 0; // Valid range: 0-1023. // Optimized. // 0, 16
  extern ENUM_MARKET_EVENT Fractals1_CloseCondition = C_MACD_BUY_SELL;
  //
  extern int Fractals5_OpenCondition1 = 528; // Valid range: 0-1023.
  extern int Fractals5_OpenCondition2 = 0; // Valid range: 0-1023. // Optimized.
  extern ENUM_MARKET_EVENT Fractals5_CloseCondition = C_MACD_BUY_SELL;
  //
  extern int Fractals15_OpenCondition1 = 528; // Valid range: 0-1023. // Optimized.
  extern int Fractals15_OpenCondition2 = 0; // Valid range: 0-1023. // Optimized.
  extern ENUM_MARKET_EVENT Fractals15_CloseCondition = C_MACD_BUY_SELL;
  //
  extern int Fractals30_OpenCondition1 = 528; // Valid range: 0-1023. // Optimized.
  extern int Fractals30_OpenCondition2 = 0; // Valid range: 0-1023. // Optimized.
  extern ENUM_MARKET_EVENT Fractals30_CloseCondition = C_MACD_BUY_SELL;
  //
#endif
#ifdef __advanced__
  extern double Fractals1_MaxSpread  =  6.0; // Maximum spread to trade (in pips).
  extern double Fractals5_MaxSpread  =  7.0; // Maximum spread to trade (in pips).
  extern double Fractals15_MaxSpread =  8.0; // Maximum spread to trade (in pips).
  extern double Fractals30_MaxSpread = 10.0; // Maximum spread to trade (in pips).
#endif
/*
 * Fractals backtest log (auto,ts:40,tp:30,gap:10) [2015.01.01-2015.06.30 based on MT4 FXCM backtest data, spread 20, 9,5mln ticks, quality 25%]:
 *   �40321.54	2672	1.77	15.09	25486.83	54.12%	0.00000000	Account_Conditions_Active=0 (d: �10k, sp: 20, ls:0.1, __testing__)
 *   �21560.33	3143	1.45	6.86	4752.95	26.95%	0.00000000	Account_Conditions_Active=1 (d: �10k, sp: 20, ls:0.1, __testing__)
 */
//+------------------------------------------------------------------+
extern string __B_Power_Parameters__ = "-- Settings for the Bulls/Bears Power indicator --";
extern int B_Power_Period = 13; // Averaging period for calculation.
extern ENUM_APPLIED_PRICE B_Power_Applied_Price = PRICE_CLOSE; // MACD applied price (See: ENUM_APPLIED_PRICE). Range: 0-6.
//+------------------------------------------------------------------+
/*
 * Summary backtest log
 * All [2015.01.01-2015.06.30 based on MT4 FXCM backtest data, spread 20, 9,5mln ticks, quality 25%]:
 *
 * Deposit: �10000 (default, spread 2)
 *   �1320256.86	24613	1.27	53.64	368389.08	47.44%	TradeWithTrend=1
 *   �886195.48	33338	1.19	26.58	212549.08	38.13%	TradeWithTrend=0
 *
 * Deposit: �10000 (default, spread 20)
 *
 *   �106725.03	23907	1.11	4.46	59839.20	54.59%	TradeWithTrend=1
 *   �17257.03	32496	1.04	0.53	23297.78	64.43%	TradeWithTrend=0
 *   TODO: (Rider mode)
 *
 * Deposit: �10000 (default, spread 40)
 *
 *   �-4606.56	23095	0.98	-0.20	15646.11	84.76%	TradeWithTrend=1
 *   �-8963.90	31510	0.92	-0.28	11160.88	96.20%	TradeWithTrend=0
 *
 *   spread 30: Prev: �13338.89	8725	1.10	1.53	5290.53	28.64% MinPipChangeToTrade=1 	MinPipGap=12 (d: �10k)
 *   spread 20: Prev: �29865.34	7686	1.19	3.89	7942.79	23.12% MinPipChangeToTrade=1.2 	MinPipGap=12 (d: �10k)
 * --
 * Deposit: �1000 (default, spread 2)
 *   �88416.35	33279	1.20	2.66	21051.43	37.86%	TradeWithTrend=0
 *   �68136.05	24563	1.26	2.77	19243.73	45.89%	TradeWithTrend=1
 *
 * Deposit: �1000 (default, spread 20)
 *
 *   �7242.02	23883	1.11	0.30	4013.08	52.91%	TradeWithTrend=1
 *   �1719.22	32541	1.04	0.05	1914.97	55.15%	TradeWithTrend=0
 *
 * Deposit: �1000 (default, spread 40)
 *   �281.07	23060	1.01	0.01	1802.54	81.01%	TradeWithTrend=1
 *   �-992.10	4038	0.77	-0.25	1125.68	99.23%	TradeWithTrend=0
 *
 *
 * Strategy stats (default, deposit �10000, spread: 20):
    Bars in test	181968
    Ticks modelled	9480514
    Modelling quality	25.00%
    Mismatched charts errors	0
    Initial deposit	10000.00
    Spread	20
    Total net profit	106725.49
    Gross profit	1056738.48
    Gross loss	-950012.99
    Profit factor	1.11
    Expected payoff	4.46
    Absolute drawdown	1232.37
    Maximal drawdown	59857.65 (54.60%)
    Relative drawdown	54.60% (59857.65)
    Total trades	23907
    Short positions (won %)	12101 (37.86%)
    Long positions (won %)	11806 (39.13%)
    Profit trades (% of total)	9202 (38.49%)
    Loss trades (% of total)	14705 (61.51%)
    	Largest
    profit trade	1373.74
    loss trade	-1263.49
    	Average
    profit trade	114.84
    loss trade	-64.60
    	Maximum
    consecutive wins (profit in money)	71 (4348.10)
    consecutive losses (loss in money)	55 (-2837.81)
    	Maximal
    consecutive profit (count of wins)	25125.50 (44)
    consecutive loss (count of losses)	-5405.27 (40)
    	Average
    consecutive wins	3
    consecutive losses	5

    Profit factor: 1.00, Total net profit: -40.26pips (+0.00/-40.26), Total orders: 1 (Won: 0.0% [0] / Loss: 100.0% [1]) - MA M1
    Profit factor: 1.00, Total net profit: -130.29pips (+9.24/-139.53), Total orders: 4 (Won: 25.0% [1] / Loss: 75.0% [3]) - MA M5
    Profit factor: 1.17, Total net profit: 1471.92pips (+10143.80/-8671.88), Total orders: 311 (Won: 48.6% [151] / Loss: 51.4% [160]) - MACD M5
    Profit factor: 1.35, Total net profit: 4258.53pips (+16446.34/-12187.81), Total orders: 259 (Won: 40.9% [106] / Loss: 59.1% [153]) - MACD M15
    Profit factor: 1.16, Total net profit: 149.11pips (+1091.23/-942.12), Total orders: 17 (Won: 35.3% [6] / Loss: 64.7% [11]) - MACD M30
    Profit factor: 0.83, Total net profit: -1505.35pips (+7323.43/-8828.78), Total orders: 689 (Won: 36.4% [251] / Loss: 63.6% [438]) - Alligator M1
    Profit factor: 1.05, Total net profit: 346.08pips (+7610.28/-7264.20), Total orders: 392 (Won: 45.9% [180] / Loss: 54.1% [212]) - Alligator M5
    Profit factor: 1.19, Total net profit: 850.18pips (+5401.14/-4550.96), Total orders: 210 (Won: 46.7% [98] / Loss: 53.3% [112]) - Alligator M15
    Profit factor: 1.12, Total net profit: 804.50pips (+7643.42/-6838.92), Total orders: 183 (Won: 54.1% [99] / Loss: 45.9% [84]) - Alligator M30
    Profit factor: 0.96, Total net profit: -177.08pips (+4627.06/-4804.14), Total orders: 243 (Won: 58.4% [142] / Loss: 41.6% [101]) - RSI M1
    Profit factor: 1.00, Total net profit: -442.09pips (+291.51/-733.60), Total orders: 3 (Won: 66.7% [2] / Loss: 33.3% [1]) - RSI M5
    Profit factor: 1.43, Total net profit: 1252.53pips (+4183.01/-2930.48), Total orders: 50 (Won: 32.0% [16] / Loss: 68.0% [34]) - RSI M15
    Profit factor: 0.93, Total net profit: -715.76pips (+9928.22/-10643.98), Total orders: 159 (Won: 25.2% [40] / Loss: 74.8% [119]) - RSI M30
    Profit factor: 1.10, Total net profit: 7184.44pips (+82467.85/-75283.41), Total orders: 1561 (Won: 40.7% [636] / Loss: 59.3% [925]) - SAR M1
    Profit factor: 1.14, Total net profit: 9582.36pips (+76244.85/-66662.49), Total orders: 1300 (Won: 38.5% [500] / Loss: 61.5% [800]) - SAR M5
    Profit factor: 1.16, Total net profit: 10908.96pips (+80138.08/-69229.12), Total orders: 1231 (Won: 38.2% [470] / Loss: 61.8% [761]) - SAR M15
    Profit factor: 1.11, Total net profit: 8478.01pips (+86975.73/-78497.72), Total orders: 1305 (Won: 34.9% [455] / Loss: 65.1% [850]) - SAR M30
    Profit factor: 1.22, Total net profit: 10033.48pips (+56251.34/-46217.86), Total orders: 1428 (Won: 53.6% [766] / Loss: 46.4% [662]) - Bands M1
    Profit factor: 1.41, Total net profit: 4410.04pips (+15144.86/-10734.82), Total orders: 394 (Won: 57.1% [225] / Loss: 42.9% [169]) - Bands M5
    Profit factor: 1.06, Total net profit: 144.05pips (+2577.73/-2433.68), Total orders: 78 (Won: 52.6% [41] / Loss: 47.4% [37]) - Bands M15
    Profit factor: 0.95, Total net profit: -726.27pips (+12897.85/-13624.12), Total orders: 475 (Won: 40.0% [190] / Loss: 60.0% [285]) - Bands M30
    Profit factor: 1.08, Total net profit: 5024.51pips (+70171.08/-65146.57), Total orders: 1543 (Won: 33.3% [514] / Loss: 66.7% [1029]) - Envelopes M1
    Profit factor: 1.00, Total net profit: 92.93pips (+61306.42/-61213.49), Total orders: 1815 (Won: 28.3% [513] / Loss: 71.7% [1302]) - Envelopes M5
    Profit factor: 1.20, Total net profit: 2677.35pips (+15758.60/-13081.25), Total orders: 286 (Won: 26.6% [76] / Loss: 73.4% [210]) - Envelopes M15
    Profit factor: 1.39, Total net profit: 7823.43pips (+27670.90/-19847.47), Total orders: 709 (Won: 46.1% [327] / Loss: 53.9% [382]) - Envelopes M30
    Profit factor: 1.01, Total net profit: 530.90pips (+42697.87/-42166.97), Total orders: 1134 (Won: 41.6% [472] / Loss: 58.4% [662]) - DeMarker M1
    Profit factor: 0.93, Total net profit: -2343.02pips (+32605.81/-34948.83), Total orders: 1151 (Won: 28.2% [325] / Loss: 71.8% [826]) - DeMarker M5
    Profit factor: 0.95, Total net profit: -1211.96pips (+23343.64/-24555.60), Total orders: 961 (Won: 30.6% [294] / Loss: 69.4% [667]) - DeMarker M15
    Profit factor: 1.22, Total net profit: 3456.31pips (+19399.89/-15943.58), Total orders: 625 (Won: 42.4% [265] / Loss: 57.6% [360]) - DeMarker M30
    Profit factor: 1.25, Total net profit: 9500.00pips (+47187.78/-37687.78), Total orders: 843 (Won: 44.6% [376] / Loss: 55.4% [467]) - WPR M1
    Profit factor: 0.92, Total net profit: -3325.79pips (+36976.63/-40302.42), Total orders: 872 (Won: 36.6% [319] / Loss: 63.4% [553]) - WPR M5
    Profit factor: 1.19, Total net profit: 4395.68pips (+28104.91/-23709.23), Total orders: 626 (Won: 33.5% [210] / Loss: 66.5% [416]) - WPR M15
    Profit factor: 1.10, Total net profit: 2085.46pips (+22946.14/-20860.68), Total orders: 582 (Won: 30.1% [175] / Loss: 69.9% [407]) - WPR M30
    Profit factor: 1.15, Total net profit: 6881.90pips (+51294.91/-44413.01), Total orders: 976 (Won: 37.1% [362] / Loss: 62.9% [614]) - Fractals M1
    Profit factor: 1.06, Total net profit: 670.30pips (+12044.41/-11374.11), Total orders: 211 (Won: 38.9% [82] / Loss: 61.1% [129]) - Fractals M5
    Profit factor: 1.13, Total net profit: 4359.07pips (+39057.04/-34697.97), Total orders: 711 (Won: 31.6% [225] / Loss: 68.4% [486]) - Fractals M15
    Profit factor: 1.25, Total net profit: 6959.73pips (+34521.10/-27561.37), Total orders: 520 (Won: 43.8% [228] / Loss: 56.2% [292]) - Fractals M30

 *
 */

/*
 * All backtest log (ts:40,tp:35,gap:10) [2015.01.01-2015.06.30 based on MT4 FXCM backtest data, spread 25, 9,5mln ticks, quality 25%]:
 *   �467.77  5351  1.09  0.09  355.59  22.88%
 */
//+------------------------------------------------------------------+
// Define account conditions.
enum ENUM_ACC_CONDITION {
  C_ACC_NONE          =  0, // None (inactive)
  C_ACC_TRUE          =  1, // Always true
  C_EQUITY_LOWER      =  2, // Equity lower than balance
  C_EQUITY_HIGHER     =  3, // Equity higher than balance
  C_EQUITY_50PC_HIGH  =  4, // Equity 50% high
  C_EQUITY_20PC_HIGH  =  5, // Equity 20% high
  C_EQUITY_10PC_HIGH  =  6, // Equity 10% high
  C_EQUITY_10PC_LOW   =  7, // Equity 10% low
  C_EQUITY_20PC_LOW   =  8, // Equity 20% low
  C_EQUITY_50PC_LOW   =  9, // Equity 50% low
  C_MARGIN_USED_50PC  = 10, // 50% Margin Used
  C_MARGIN_USED_70PC  = 11, // 70% Margin Used
  C_MARGIN_USED_80PC  = 12, // 80% Margin Used
  C_MARGIN_USED_90PC  = 13, // 90% Margin Used
  C_NO_FREE_MARGIN    = 14, // No free margin.
  C_ACC_IN_LOSS       = 15, // Account in loss
  C_ACC_IN_PROFIT     = 16, // Account in profit
  C_DBAL_LT_WEEKLY    = 17, // Max. daily balance < max. weekly
  C_DBAL_GT_WEEKLY    = 18, // Max. daily balance > max. weekly
  C_WBAL_LT_MONTHLY   = 19, // Max. weekly balance < max. monthly
  C_WBAL_GT_MONTHLY   = 20, // Max. weekly balance > max. monthly
  C_ACC_IN_TREND      = 31, // Account in trend
  C_ACC_IN_NON_TREND  = 32, // Account is against trend
};

// Define market conditions.
enum ENUM_MARKET_CONDITION {
  C_MARKET_NONE       = 0, // None (false).
  C_MARKET_TRUE       = 1, // Always true
  C_MA1_FAST_SLOW_OPP = 2, // MA1 Fast&Slow opposite
  C_MA1_MED_SLOW_OPP  = 3, // MA1 Med&Slow opposite
  C_MA5_FAST_SLOW_OPP = 4, // MA5 Fast&Slow opposite
  C_MA5_MED_SLOW_OPP  = 5, // MA5 Med&Slow opposite
  C_MARKET_BIG_DROP   = 6, // Market big drop
  C_MARKET_VBIG_DROP  = 7, // Market very big drop
};

// Define type of actions which can be executed.
enum ENUM_ACTION_TYPE {
  A_NONE                   =  0, // None
  A_CLOSE_ORDER_PROFIT     =  1, // Close most profitable order
  A_CLOSE_ORDER_LOSS       =  2, // Close worse order
  A_CLOSE_ALL_IN_PROFIT    =  3, // Close all in profit
  A_CLOSE_ALL_IN_LOSS      =  4, // Close all in loss
  A_CLOSE_ALL_PROFIT_SIDE  =  5, // Close profit side
  A_CLOSE_ALL_LOSS_SIDE    =  6, // Close loss side
  A_CLOSE_ALL_TREND        =  7, // Close trend side
  A_CLOSE_ALL_NON_TREND    =  8, // Close non-trend side
  A_CLOSE_ALL_ORDERS       =  9, // Close all!
  FINAL_ACTION_TYPE_ENTRY  = 10  // (Not in use)
  // A_ORDER_STOPS_DECREASE   =  10, // Decrease loss stops
  // A_ORDER_PROFIT_DECREASE  =  11, // Decrease profit stops
};
//+------------------------------------------------------------------+
extern string __EA_Conditions__ = "-- Account conditions --"; // See: ENUM_ACTION_TYPE
#ifndef __noactions__
  extern bool Account_Conditions_Active = TRUE; // Enable account conditions. It's not advice on accounts where multi bots are trading.
#else
  extern bool Account_Conditions_Active = FALSE;
#endif
#ifndef __rider__
extern ENUM_ACC_CONDITION Account_Condition_1      = C_EQUITY_LOWER;
extern ENUM_MARKET_CONDITION Market_Condition_1    = C_MARKET_BIG_DROP;
extern ENUM_ACTION_TYPE Action_On_Condition_1      = A_CLOSE_ALL_LOSS_SIDE;

extern ENUM_ACC_CONDITION Account_Condition_2      = C_EQUITY_10PC_LOW;
extern ENUM_MARKET_CONDITION Market_Condition_2    = C_MA1_FAST_SLOW_OPP;
extern ENUM_ACTION_TYPE Action_On_Condition_2      = A_CLOSE_ORDER_PROFIT;

extern ENUM_ACC_CONDITION Account_Condition_3      = C_EQUITY_20PC_LOW;
extern ENUM_MARKET_CONDITION Market_Condition_3    = C_MARKET_TRUE;
extern ENUM_ACTION_TYPE Action_On_Condition_3      = A_CLOSE_ALL_IN_PROFIT;

extern ENUM_ACC_CONDITION Account_Condition_4      = C_EQUITY_50PC_LOW;
extern ENUM_MARKET_CONDITION Market_Condition_4    = C_MARKET_TRUE;
extern ENUM_ACTION_TYPE Action_On_Condition_4      = A_CLOSE_ALL_LOSS_SIDE;

extern ENUM_ACC_CONDITION Account_Condition_5      = C_EQUITY_10PC_HIGH;
extern ENUM_MARKET_CONDITION Market_Condition_5    = C_MA1_FAST_SLOW_OPP;
extern ENUM_ACTION_TYPE Action_On_Condition_5      = A_CLOSE_ORDER_PROFIT;

extern ENUM_ACC_CONDITION Account_Condition_6      = C_EQUITY_20PC_HIGH;
extern ENUM_MARKET_CONDITION Market_Condition_6    = C_MA1_MED_SLOW_OPP;
extern ENUM_ACTION_TYPE Action_On_Condition_6      = A_CLOSE_ALL_NON_TREND;

extern ENUM_ACC_CONDITION Account_Condition_7      = C_EQUITY_50PC_HIGH;
extern ENUM_MARKET_CONDITION Market_Condition_7    = C_MARKET_TRUE;
extern ENUM_ACTION_TYPE Action_On_Condition_7      = A_CLOSE_ALL_PROFIT_SIDE;

extern ENUM_ACC_CONDITION Account_Condition_8      = C_MARGIN_USED_80PC;
extern ENUM_MARKET_CONDITION Market_Condition_8    = C_MARKET_TRUE;
extern ENUM_ACTION_TYPE Action_On_Condition_8      = A_CLOSE_ALL_NON_TREND;

extern ENUM_ACC_CONDITION Account_Condition_9      = C_MARGIN_USED_90PC;
extern ENUM_MARKET_CONDITION Market_Condition_9    = C_MARKET_TRUE;
extern ENUM_ACTION_TYPE Action_On_Condition_9      = A_CLOSE_ORDER_LOSS;

extern ENUM_ACC_CONDITION Account_Condition_10     = C_EQUITY_HIGHER;
extern ENUM_MARKET_CONDITION Market_Condition_10   = C_MARKET_BIG_DROP;
extern ENUM_ACTION_TYPE Action_On_Condition_10     = A_CLOSE_ALL_TREND;

extern ENUM_ACC_CONDITION Account_Condition_11     = C_ACC_TRUE;
extern ENUM_MARKET_CONDITION Market_Condition_11   = C_MARKET_VBIG_DROP;
extern ENUM_ACTION_TYPE Action_On_Condition_11     = A_CLOSE_ALL_IN_LOSS;

extern ENUM_ACC_CONDITION Account_Condition_12     = C_ACC_NONE;
extern ENUM_MARKET_CONDITION Market_Condition_12   = C_MARKET_NONE;
extern ENUM_ACTION_TYPE Action_On_Condition_12     = A_NONE;
//+------------------------------------------------------------------+
#else // Rider mode.
extern ENUM_ACC_CONDITION Account_Condition_1      = C_EQUITY_LOWER;
extern ENUM_MARKET_CONDITION Market_Condition_1    = C_MARKET_NONE; // C_MARKET_BIG_DROP;
extern ENUM_ACTION_TYPE Action_On_Condition_1      = A_CLOSE_ALL_LOSS_SIDE;

extern ENUM_ACC_CONDITION Account_Condition_2      = C_EQUITY_10PC_LOW;
extern ENUM_MARKET_CONDITION Market_Condition_2    = C_MARKET_NONE; // C_MA1_FAST_SLOW_OPP;
extern ENUM_ACTION_TYPE Action_On_Condition_2      = A_CLOSE_ORDER_PROFIT;

extern ENUM_ACC_CONDITION Account_Condition_3      = C_EQUITY_20PC_LOW;
extern ENUM_MARKET_CONDITION Market_Condition_3    = C_MARKET_TRUE;
extern ENUM_ACTION_TYPE Action_On_Condition_3      = A_CLOSE_ALL_IN_PROFIT;

extern ENUM_ACC_CONDITION Account_Condition_4      = C_EQUITY_50PC_LOW;
extern ENUM_MARKET_CONDITION Market_Condition_4    = C_MARKET_TRUE;
extern ENUM_ACTION_TYPE Action_On_Condition_4      = A_CLOSE_ALL_LOSS_SIDE;

extern ENUM_ACC_CONDITION Account_Condition_5      = C_EQUITY_10PC_HIGH;
extern ENUM_MARKET_CONDITION Market_Condition_5    = C_MA1_FAST_SLOW_OPP;
extern ENUM_ACTION_TYPE Action_On_Condition_5      = A_CLOSE_ORDER_PROFIT;

extern ENUM_ACC_CONDITION Account_Condition_6      = C_EQUITY_20PC_HIGH;
extern ENUM_MARKET_CONDITION Market_Condition_6    = C_MA1_FAST_SLOW_OPP;
extern ENUM_ACTION_TYPE Action_On_Condition_6      = A_CLOSE_ORDER_PROFIT;

extern ENUM_ACC_CONDITION Account_Condition_7      = C_EQUITY_50PC_HIGH;
extern ENUM_MARKET_CONDITION Market_Condition_7    = C_MA5_FAST_SLOW_OPP;
extern ENUM_ACTION_TYPE Action_On_Condition_7      = A_CLOSE_ALL_TREND;

extern ENUM_ACC_CONDITION Account_Condition_8      = C_MARGIN_USED_80PC;
extern ENUM_MARKET_CONDITION Market_Condition_8    = C_MARKET_TRUE;
extern ENUM_ACTION_TYPE Action_On_Condition_8      = A_CLOSE_ALL_NON_TREND;

extern ENUM_ACC_CONDITION Account_Condition_9      = C_MARGIN_USED_90PC;
extern ENUM_MARKET_CONDITION Market_Condition_9    = C_MARKET_TRUE;
extern ENUM_ACTION_TYPE Action_On_Condition_9      = A_CLOSE_ORDER_LOSS;

extern ENUM_ACC_CONDITION Account_Condition_10     = C_EQUITY_HIGHER;
extern ENUM_MARKET_CONDITION Market_Condition_10   = C_MARKET_BIG_DROP;
extern ENUM_ACTION_TYPE Action_On_Condition_10     = A_CLOSE_ORDER_PROFIT;

extern ENUM_ACC_CONDITION Account_Condition_11     = C_ACC_TRUE;
extern ENUM_MARKET_CONDITION Market_Condition_11   = C_MARKET_VBIG_DROP;
extern ENUM_ACTION_TYPE Action_On_Condition_11     = A_CLOSE_ALL_IN_LOSS;

extern ENUM_ACC_CONDITION Account_Condition_12     = C_ACC_NONE;
extern ENUM_MARKET_CONDITION Market_Condition_12   = C_MARKET_NONE;
extern ENUM_ACTION_TYPE Action_On_Condition_12     = A_NONE;
#endif
//+------------------------------------------------------------------+
extern string __Logging_Parameters__ = "-- Settings for logging & messages --";
extern bool PrintLogOnChart = TRUE;
extern bool VerboseErrors = TRUE; // Show errors.
extern bool VerboseInfo = TRUE;   // Show info messages.
#ifdef __release__ || !__nodebug__
  extern bool VerboseDebug = FALSE;  // Disable messages on release.
#else
  extern bool VerboseDebug = TRUE;  // Show debug messages.
#endif
extern bool WriteReport = TRUE;  // Write report into the file on exit.
extern bool VerboseTrace = FALSE;  // Even more debugging.
//+------------------------------------------------------------------+
extern string __UI_UX_Parameters__ = "-- Settings for User Interface & Experience --";
extern bool SendEmailEachOrder = FALSE;
extern bool SoundAlert = FALSE;
extern string SoundFileAtOpen = "alert.wav";
extern string SoundFileAtClose = "alert.wav";
extern color ColorBuy = Blue;
extern color ColorSell = Red;
//+------------------------------------------------------------------+
extern string __Other_Parameters__ = "-----------------------------------------";
extern string E_Mail = "";
extern string License = "";
extern int MagicNumber = 31337; // To help identify its own orders. It can vary in additional range: +20, see: ENUM_ORDER_TYPE.

//extern int ManualGMToffset = 0;
//extern int TrailingStopDelay = 0; // How often trailing stop should be updated (in seconds). FIXME: Fix relative delay in backtesting.
// extern int JobProcessDelay = 1; // How often job list should be processed (in seconds).
//+------------------------------------------------------------------+
/*
 * Default enumerations:
 *
 * ENUM_MA_METHOD values:
 *   0: MODE_SMA (Simple averaging)
 *   1: MODE_EMA (Exponential averaging)
 *   2: MODE_SMMA (Smoothed averaging)
 *   3: MODE_LWMA (Linear-weighted averaging)
 *
 * ENUM_APPLIED_PRICE values:
 *   0: PRICE_CLOSE (Close price)
 *   1: PRICE_OPEN (Open price)
 *   2: PRICE_HIGH (The maximum price for the period)
 *   3: PRICE_LOW (The minimum price for the period)
 *   4: PRICE_MEDIAN (Median price, (high + low)/2
 *   5: PRICE_TYPICAL (Typical price, (high + low + close)/3
 *   6: PRICE_WEIGHTED (Average price, (high + low + close + close)/4
 *
 * Trade operation:
 *   0: OP_BUY (Buy operation)
 *   1: OP_SELL (Sell operation)
 *   2: OP_BUYLIMIT (Buy limit pending order)
 *   3: OP_SELLLIMIT (Sell limit pending order)
 *   4: OP_BUYSTOP (Buy stop pending order)
 *   5: OP_SELLSTOP (Sell stop pending order)
 */

/*
 * Notes:
 *   - __MQL4__  macro is defined when compiling *.mq4 file, __MQL5__ macro is defined when compiling *.mq5 one.
 */
//+------------------------------------------------------------------+

// Market/session variables.
double lot_size, pip_size;
double market_maxlot;
double market_minlot;
double market_lotstep;
double market_marginrequired;
double market_stoplevel; // Market stop level in points.
int PipDigits, VolumeDigits;
int pts_per_pip; // Number points per pip.
int gmt_offset = 0;

// Account variables.
string account_type;

// State variables.
bool session_initiated = FALSE;
bool session_active = FALSE;

// Time-based variables.
int bar_time, last_bar_time = EMPTY_VALUE; // Bar time, current and last one to check if bar has been changed since the last time.
int hour_of_day, day_of_week, day_of_month, day_of_year;

// Strategy variables.
int info[FINAL_STRATEGY_TYPE_ENTRY][FINAL_STRATEGY_INFO_ENTRY];
double conf[FINAL_STRATEGY_TYPE_ENTRY][FINAL_STRATEGY_VALUE_ENTRY], stats[FINAL_STRATEGY_TYPE_ENTRY][FINAL_STRATEGY_STAT_ENTRY];
int open_orders[FINAL_STRATEGY_TYPE_ENTRY], closed_orders[FINAL_STRATEGY_TYPE_ENTRY];
int signals[FINAL_STAT_PERIOD_TYPE_ENTRY][FINAL_STRATEGY_TYPE_ENTRY][MN1][2]; // Count signals to buy and sell per period and strategy.
int tickets[200]; // List of tickets to process.
string name[FINAL_STRATEGY_TYPE_ENTRY];
int worse_strategy[FINAL_STAT_PERIOD_TYPE_ENTRY], best_strategy[FINAL_STAT_PERIOD_TYPE_ENTRY];

// EA variables.
bool ea_active = FALSE;
double risk_ratio; // Calculated risk ratio.
int max_orders; // Maximum orders available to open.
double max_order_slippage; // Maximum price slippage for buy or sell orders (in points)
double LastAsk, LastBid; // Keep the last ask and bid price.
string AccCurrency; // Current account currency.
int err_code; // Error code.
string last_err, last_msg;
double last_tick_change; // Last tick change in pips.
int last_order_time = 0, last_action_time = 0;
int last_history_check = 0; // Last ticket position processed.
// int last_trail_update = 0, last_indicators_update = 0, last_stats_update = 0;
int GMT_Offset;
int todo_queue[100][8], last_queue_process = 0;
int total_orders = 0; // Number of total orders currently open.
double daily[FINAL_VALUE_TYPE_ENTRY], weekly[FINAL_VALUE_TYPE_ENTRY], monthly[FINAL_VALUE_TYPE_ENTRY];

// Used for writing the report file.
string log[];

// Condition and actions.
int acc_conditions[12][3], market_conditions[10][3];

// Indicator variables.
double ma_fast[H1][3], ma_medium[H1][3], ma_slow[H1][3];
double macd[H1][3], macd_signal[H1][3];
double rsi[H1][3], rsi_stats[H1][3];
double sar[H1][3]; int sar_week[H1][7][2];
double bands[H1][3][3], envelopes[H1][3][3];
double alligator[H1][3][3];
double demarker[H1][2], wpr[H1][2];
double fractals[H1][3][3];
double b_power[H1][2][3];

/* TODO:
 *   - add trailing stops/profit for support/resistence,
 *   - add the Average Directional Movement Index indicator (iADX) (http://docs.mql4.com/indicators/iadx),
 *   - add the Stochastic Oscillator (http://docs.mql4.com/indicators/istochastic),
 *   - add On Balance Volume (iOBV) (http://docs.mql4.com/indicators/iobv),
 *   - add the Standard Deviation indicator (iStdDev) (http://docs.mql4.com/indicators/istddev),
 *   - add the Money Flow Index (http://docs.mql4.com/indicators/imfi),
 *   - add the Ichimoku Kinko Hyo indicator,
 *   - daily higher highs and lower lows,
 *   - add breakage strategy (Envelopes/Bands?) with Order,
 *   - add the On Balance Volume indicator (iOBV) (http://docs.mql4.com/indicators/iobv),
 *   - add the Average True Range indicator (iATR) (http://docs.mql4.com/indicators/iatr),
 *   - add the Force Index indicator (iForce) (http://docs.mql4.com/indicators/iforce),
 *   - add the Moving Average of Oscillator indicator (iOsMA) (http://docs.mql4.com/indicators/iosma),
 *   - BearsPower, BullsPower - buy long when the bull Power is negative but increasing, selling if bulls power is positive but decreasing,
 *   - check risky dates and times,
 *   - check for risky patterns,
 *   - implement condition to close all strategy orders, buy/sell, most profitable order, when to trade, skip the day or week, etc.
 *   - take profit on abnormal spikes,
 *   - implement SendFTP,
 *   - implement SendNotification,
 *   - send daily, weekly reports (SendMail),
 *   - check TesterStatistics(),
 *   - check ResourceCreate/ResourceSave to store dynamic parameters
 *   - generate custom tick data for tester\history\EURUSD1_0.fxt


      //1. Acceleration/Deceleration � AC
      //Buy: if the indicator is above zero and 2 consecutive columns are green or if the indicator is below zero and 3 consecutive columns are green
      //Sell: if the indicator is below zero and 2 consecutive columns are red or if the indicator is above zero and 3 consecutive columns are red
      if ((iAC(NULL,piac,0)>=0&&iAC(NULL,piac,0)>iAC(NULL,piac,1)&&iAC(NULL,piac,1)>iAC(NULL,piac,2))||(iAC(NULL,piac,0)<=0&&iAC(NULL,piac,0)>iAC(NULL,piac,1)&&iAC(NULL,piac,1)>iAC(NULL,piac,2)&&iAC(NULL,piac,2)>iAC(NULL,piac,3)))
      {f1=1;}
      if ((iAC(NULL,piac,0)<=0&&iAC(NULL,piac,0)<iAC(NULL,piac,1)&&iAC(NULL,piac,1)<iAC(NULL,piac,2))||(iAC(NULL,piac,0)>=0&&iAC(NULL,piac,0)<iAC(NULL,piac,1)&&iAC(NULL,piac,1)<iAC(NULL,piac,2)&&iAC(NULL,piac,2)<iAC(NULL,piac,3)))
      {f1=-1;}
      //2. Accumulation/Distribution - A/D
      //Main principle - convergence/divergence
      //Buy: indicator growth at downtrend
      //Sell: indicator fall at uptrend
      if (iAD(NULL,piad,0)>=iAD(NULL,piad,1)&&iClose(NULL,piad2,0)<=iClose(NULL,piad2,1))
      {f2=1;}
      if (iAD(NULL,piad,0)<=iAD(NULL,piad,1)&&iClose(NULL,piad2,0)>=iClose(NULL,piad2,1))
      {f2=-1;}
      //3. Alligator & Fractals
      //Buy: all 3 Alligator lines grow/ don't fall/ (3 periods in succession) and fractal (upper line) is above teeth
      //Sell: all 3 Alligator lines fall/don't grow/ (3 periods in succession) and fractal (lower line) is below teeth
      //Fracal shift=2 because of the indicator nature
      if (iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,2)<=iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,1)&&iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,1)<=iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,0)&&iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,2)<=iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1)&&iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1)<=iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,0)&&iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,2)<=iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,1)&&iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,1)<=iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,0)&&iFractals(NULL,pifr,MODE_UPPER,2)>=iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,0))
      {f3=1;}
      if (iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,2)>=iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,1)&&iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,1)>=iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,0)&&iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,2)>=iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1)&&iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1)>=iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,0)&&iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,2)>=iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,1)&&iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,1)>=iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,0)&&iFractals(NULL,pifr,MODE_LOWER,2)<=iAlligator(NULL,piall,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,0))
      {f3=-1;}

      //4. Gator Oscillator
      //Doesn't give independent signals. Is used for Alligator correction.
      //Principle: trend must be strengthened. Together with this Gator Oscillator goes up.
      //Lower part of diagram is taken for calculations. Growth is checked on 4 periods.
      //The flag is 1 of trend is strengthened, 0 - no strengthening, -1 - never.
      //Uses part of Alligator's variables
      if (iGator(NULL,piga,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_LOWER,3)>iGator(NULL,piga,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_LOWER,2)&&iGator(NULL,piga,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_LOWER,2)>iGator(NULL,piga,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_LOWER,1)&&iGator(NULL,piga,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_LOWER,1)>iGator(NULL,piga,jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,MODE_SMMA,PRICE_MEDIAN,MODE_LOWER,0))
      {f4=1;}
      //5. Average Directional Movement Index - ADX
      //Buy: +DI line is above -DI line, ADX is more than a certain value and grows (i.e. trend strengthens)
      //Sell: -DI line is above +DI line, ADX is more than a certain value and grows (i.e. trend strengthens)
      if (iADX(NULL,piadx,piadu,PRICE_CLOSE,MODE_MINUSDI,0)<iADX(NULL,piadx,piadu,PRICE_CLOSE,MODE_PLUSDI,0)&&iADX(NULL,piadx,piadu,PRICE_CLOSE,MODE_MAIN,0)>=minadx&&iADX(NULL,piadx,piadu,PRICE_CLOSE,MODE_MAIN,0)>iADX(NULL,piadx,piadu,PRICE_CLOSE,MODE_MAIN,1))
      {f5=1;}
      if (iADX(NULL,piadx,piadu,PRICE_CLOSE,MODE_MINUSDI,0)>iADX(NULL,piadx,piadu,PRICE_CLOSE,MODE_PLUSDI,0)&&iADX(NULL,piadx,piadu,PRICE_CLOSE,MODE_MAIN,0)>=minadx&&iADX(NULL,piadx,piadu,PRICE_CLOSE,MODE_MAIN,0)>iADX(NULL,piadx,piadu,PRICE_CLOSE,MODE_MAIN,1))
      {f5=-1;}

      //6. Average True Range - ATR
      //Doesn't give independent signals. Is used to define volatility (trend strength).
      //principle: trend must be strengthened. Together with that ATR grows.
      //Because of the chart form it is inconvenient to analyze rise/fall. Only exceeding of threshold value is checked.
      //Flag is 1 when ATR is above threshold value (i.e. there is a trend), 0 - when ATR is below threshold value, -1 - never.
      if (iATR(NULL,piatr,piatru,0)>=minatr)
      {f6=1;}

      //7. Awesome Oscillator
      //Buy: 1. Signal "saucer" (3 positive columns, medium column is smaller than 2 others); 2. Changing from negative values to positive.
      //Sell: 1. Signal "saucer" (3 negative columns, medium column is larger than 2 others); 2. Changing from positive values to negative.
      if ((iAO(NULL,piao,2)>0&&iAO(NULL,piao,1)>0&&iAO(NULL,piao,0)>0&&iAO(NULL,piao,1)<iAO(NULL,piao,2)&&iAO(NULL,piao,1)<iAO(NULL,piao,0))||(iAO(NULL,piao,1)<0&&iAO(NULL,piao,0)>0))
      {f7=1;}
      if ((iAO(NULL,piao,2)<0&&iAO(NULL,piao,1)<0&&iAO(NULL,piao,0)<0&&iAO(NULL,piao,1)>iAO(NULL,piao,2)&&iAO(NULL,piao,1)>iAO(NULL,piao,0))||(iAO(NULL,piao,1)>0&&iAO(NULL,piao,0)<0))
      {f7=-1;}

      //8. Bears Power
      //Is used only together with a trend indicator. Gives only Buy signals.
      //Flag is 1, if the indicator is negative and grows, 0 - in all other cases, -1 - never.
      if (iBearsPower(NULL,pibear,pibearu,PRICE_CLOSE,2)<0&&iBearsPower(NULL,pibear,pibearu,PRICE_CLOSE,1)<0&&iBearsPower(NULL,pibear,pibearu,PRICE_CLOSE,0)<0&&iBearsPower(NULL,pibear,pibearu,PRICE_CLOSE,2)<iBearsPower(NULL,pibear,pibearu,PRICE_CLOSE,1)&&iBearsPower(NULL,pibear,pibearu,PRICE_CLOSE,1)<iBearsPower(NULL,pibear,pibearu,PRICE_CLOSE,0))
      {f8=1;}

      //9. Bollinger Bands
      //Buy: price crossed lower line upwards (returned to it from below)
      //Sell: price crossed upper line downwards (returned to it from above)
      if (iBands(NULL,piband,pibandu,ibandotkl,0,PRICE_CLOSE,MODE_LOWER,1)>iClose(NULL,piband2,1)&&iBands(NULL,piband,pibandu,ibandotkl,0,PRICE_CLOSE,MODE_LOWER,0)<=iClose(NULL,piband2,0))
      {f9=1;}
      if (iBands(NULL,piband,pibandu,ibandotkl,0,PRICE_CLOSE,MODE_UPPER,1)<iClose(NULL,piband2,1)&&iBands(NULL,piband,pibandu,ibandotkl,0,PRICE_CLOSE,MODE_UPPER,0)>=iClose(NULL,piband2,0))
      {f9=-1;}

      //10. Bulls Power
      //Is used only together with a trend indicator. Gives only Sell signals.
      //Flag is -1, if the indicator is positive and falls, 0 - in all other cases, 1 - never.
      if (iBullsPower(NULL,pibull,pibullu,PRICE_CLOSE,2)>0&&iBullsPower(NULL,pibull,pibullu,PRICE_CLOSE,1)>0&&iBullsPower(NULL,pibull,pibullu,PRICE_CLOSE,0)>0&&iBullsPower(NULL,pibull,pibullu,PRICE_CLOSE,2)>iBullsPower(NULL,pibull,pibullu,PRICE_CLOSE,1)&&iBullsPower(NULL,pibull,pibullu,PRICE_CLOSE,1)>iBullsPower(NULL,pibull,pibullu,PRICE_CLOSE,0))
      {f10=-1;}
      f10=0; //Now we don't use

      //11. Commodity Channel Index
      //Buy: 1. indicator crosses +100 from below upwards. 2. Crossing -100 from below upwards. 3.
      //Sell: 1. indicator crosses -100 from above downwards. 2. Crossing +100 downwards. 3.
      if ((iCCI(NULL,picci,picciu,PRICE_TYPICAL,1)<100&&iCCI(NULL,picci,picciu,PRICE_TYPICAL,0)>=100)||(iCCI(NULL,picci,picciu,PRICE_TYPICAL,1)<-100&&iCCI(NULL,picci,picciu,PRICE_TYPICAL,0)>=-100))
      {f11=1;}
      if ((iCCI(NULL,picci,picciu,PRICE_TYPICAL,1)>-100&&iCCI(NULL,picci,picciu,PRICE_TYPICAL,0)<=-100)||(iCCI(NULL,picci,picciu,PRICE_TYPICAL,1)>100&&iCCI(NULL,picci,picciu,PRICE_TYPICAL,0)<=100))
      {f11=-1;}
      //14. Force Index
      //To use the indicator it should be correlated with another trend indicator
      //Flag 14 is 1, when FI recommends to buy (i.e. FI<0)
      //Flag 14 is -1, when FI recommends to sell (i.e. FI>0)
      if (iForce(NULL,piforce,piforceu,MODE_SMA,PRICE_CLOSE,0)<0)
      {f14=1;}
      if (iForce(NULL,piforce,piforceu,MODE_SMA,PRICE_CLOSE,0)>0)
      {f14=-1;}

      //15. Ichimoku Kinko Hyo (1)
      //Buy: Price crosses Senkou Span-B upwards; price is outside Senkou Span cloud
      //Sell: Price crosses Senkou Span-B downwards; price is outside Senkou Span cloud
      if (iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_SENKOUSPANB,1)>iClose(NULL,pich2,1)&&iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_SENKOUSPANB,0)<=iClose(NULL,pich2,0)&&iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_SENKOUSPANA,0)<iClose(NULL,pich2,0))
      {f15=1;}
      if (iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_SENKOUSPANB,1)<iClose(NULL,pich2,1)&&iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_SENKOUSPANB,0)>=iClose(NULL,pich2,0)&&iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_SENKOUSPANA,0)>iClose(NULL,pich2,0))
      {f15=-1;}

      //16. Ichimoku Kinko Hyo (2)
      //Buy: Tenkan-sen crosses Kijun-sen upwards
      //Sell: Tenkan-sen crosses Kijun-sen downwards
      //VERSION EXISTS, IN THIS CASE PRICE MUSTN'T BE IN THE CLOUD!
      if (iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_TENKANSEN,1)<iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_KIJUNSEN,1)&&iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_TENKANSEN,0)>=iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_KIJUNSEN,0))
      {f16=1;}
      if (iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_TENKANSEN,1)>iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_KIJUNSEN,1)&&iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_TENKANSEN,0)<=iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_KIJUNSEN,0))
      {f16=-1;}

      //17. Ichimoku Kinko Hyo (3)
      //Buy: Chinkou Span crosses chart upwards; price is ib the cloud
      //Sell: Chinkou Span crosses chart downwards; price is ib the cloud
      if ((iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_CHINKOUSPAN,pkijun+1)<iClose(NULL,pich2,pkijun+1)&&iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_CHINKOUSPAN,pkijun+0)>=iClose(NULL,pich2,pkijun+0))&&((iClose(NULL,pich2,0)>iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_SENKOUSPANA,0)&&iClose(NULL,pich2,0)<iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_SENKOUSPANB,0))||(iClose(NULL,pich2,0)<iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_SENKOUSPANA,0)&&iClose(NULL,pich2,0)>iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_SENKOUSPANB,0))))
      {f17=1;}
      if ((iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_CHINKOUSPAN,pkijun+1)>iClose(NULL,pich2,pkijun+1)&&iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_CHINKOUSPAN,pkijun+0)<=iClose(NULL,pich2,pkijun+0))&&((iClose(NULL,pich2,0)>iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_SENKOUSPANA,0)&&iClose(NULL,pich2,0)<iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_SENKOUSPANB,0))||(iClose(NULL,pich2,0)<iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_SENKOUSPANA,0)&&iClose(NULL,pich2,0)>iIchimoku(NULL,pich,ptenkan,pkijun,psenkou,MODE_SENKOUSPANB,0))))
      {f17=-1;}

      //18. Money Flow Index - MFI
      //Buy: Crossing 20 upwards
      //Sell: Crossing 20 downwards
      if(iMFI(NULL,pimfi,barsimfi,1)<20&&iMFI(NULL,pimfi,barsimfi,0)>=20)
      {f18=1;}
      if(iMFI(NULL,pimfi,barsimfi,1)>80&&iMFI(NULL,pimfi,barsimfi,0)<=80)
      {f18=-1;}
      //20. MACD (1)
      //VERSION EXISTS, THAT THE SIGNAL TO BUY IS TRUE ONLY IF MACD<0, SIGNAL TO SELL - IF MACD>0
      //Buy: MACD rises above the signal line
      //Sell: MACD falls below the signal line
      if(iMACD(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,MODE_MAIN,1)<iMACD(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,MODE_SIGNAL,1)&&iMACD(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,MODE_MAIN,0)>=iMACD(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,MODE_SIGNAL,0))
      {f20=1;}
      if(iMACD(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,MODE_MAIN,1)>iMACD(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,MODE_SIGNAL,1)&&iMACD(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,MODE_MAIN,0)<=iMACD(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,MODE_SIGNAL,0))
      {f20=-1;}

      //21. MACD (2)
      //Buy: crossing 0 upwards
      //Sell: crossing 0 downwards
      if(iMACD(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,MODE_MAIN,1)<0&&iMACD(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,MODE_MAIN,0)>=0)
      {f21=1;}
      if(iMACD(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,MODE_MAIN,1)>0&&iMACD(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,MODE_MAIN,0)<=0)
      {f21=-1;}


      //22. Moving Average of Oscillator (MACD histogram) (1)
      //Buy: histogram is below zero and changes falling direction into rising (5 columns are taken)
      //Sell: histogram is above zero and changes its rising direction into falling (5 columns are taken)
      if(iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,4)<0&&iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,3)<0&&iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,2)<0&&iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,1)<0&&iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,0)<0&&iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,4)>=iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,3)&&iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,3)>=iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,2)&&iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,2)<=iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,1)&&iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,1)<=iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,0))
      {f22=1;}
      if(iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,4)>0&&iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,3)>0&&iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,2)>0&&iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,1)>0&&iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,0)>0&&iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,4)<=iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,3)&&iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,3)<=iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,2)&&iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,2)>=iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,1)&&iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,1)>=iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,0))
      {f22=-1;}

      //23. Moving Average of Oscillator (MACD histogram) (2)
      //To use the indicator it should be correlated with another trend indicator
      //Flag 23 is 1, when MACD histogram recommends to buy (i.e. histogram is sloping upwards)
      //Flag 23 is -1, when MACD histogram recommends to sell (i.e. histogram is sloping downwards)
      //3 columns are taken for calculation
      if(iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,2)<=iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,1)&&iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,1)<=iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,0))
      {f23=1;}
      if(iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,2)>=iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,1)&&iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,1)>=iOsMA(NULL,pimacd,fastpimacd,slowpimacd,signalpimacd,PRICE_CLOSE,0))
      {f23=-1;}
      //26. RVI
      //RECOMMENDED TO USE WITH A TREND INDICATOR
      //Buy: main line (green) crosses signal (red) upwards
      //Sell: main line (green) crosses signal (red) downwards
      if(iRVI(NULL,pirvi,pirviu,MODE_MAIN,1)<iRVI(NULL,pirvi,pirviu,MODE_SIGNAL,1)&&iRVI(NULL,pirvi,pirviu,MODE_MAIN,0)>=iRVI(NULL,pirvi,pirviu,MODE_SIGNAL,0))
      {f26=1;}
      if(iRVI(NULL,pirvi,pirviu,MODE_MAIN,1)>iRVI(NULL,pirvi,pirviu,MODE_SIGNAL,1)&&iRVI(NULL,pirvi,pirviu,MODE_MAIN,0)<=iRVI(NULL,pirvi,pirviu,MODE_SIGNAL,0))
      {f26=-1;}

      //27. Standard Deviation
      //Doesn't give independent signals. Is used to define volatility (trend strength).
      //Principle: the trend must be strengthened. Together with this Standard Deviation goes up.
      //Growth on 3 consecutive bars is analyzed
      //Flag is 1 when Standard Deviation rises, 0 - when no growth, -1 - never.
      if (iStdDev(NULL,pistd,pistdu,0,MODE_SMA,PRICE_CLOSE,2)<=iStdDev(NULL,pistd,pistdu,0,MODE_SMA,PRICE_CLOSE,1)&&iStdDev(NULL,pistd,pistdu,0,MODE_SMA,PRICE_CLOSE,1)<=iStdDev(NULL,pistd,pistdu,0,MODE_SMA,PRICE_CLOSE,0))
      {f27=1;}

      //28. Stochastic Oscillator (1)
      //Buy: main lline rises above 20 after it fell below this point
      //Sell: main line falls lower than 80 after it rose above this point
      if(iStochastic(NULL,pisto,pistok,pistod,istslow,MODE_EMA,0,MODE_MAIN,1)<20&&iStochastic(NULL,pisto,pistok,pistod,istslow,MODE_EMA,0,MODE_MAIN,0)>=20)
      {f28=1;}
      if(iStochastic(NULL,pisto,pistok,pistod,istslow,MODE_EMA,0,MODE_MAIN,1)>80&&iStochastic(NULL,pisto,pistok,pistod,istslow,MODE_EMA,0,MODE_MAIN,0)<=80)
      {f28=-1;}

      //29. Stochastic Oscillator (2)
      //Buy: main line goes above the signal line
      //Sell: signal line goes above the main line
      if(iStochastic(NULL,pisto,pistok,pistod,istslow,MODE_EMA,0,MODE_MAIN,1)<iStochastic(NULL,pisto,pistok,pistod,istslow,MODE_EMA,0,MODE_SIGNAL,1)&&iStochastic(NULL,pisto,pistok,pistod,istslow,MODE_EMA,0,MODE_MAIN,0)>=iStochastic(NULL,pisto,pistok,pistod,istslow,MODE_EMA,0,MODE_SIGNAL,0))
      {f29=1;}
      if(iStochastic(NULL,pisto,pistok,pistod,istslow,MODE_EMA,0,MODE_MAIN,1)>iStochastic(NULL,pisto,pistok,pistod,istslow,MODE_EMA,0,MODE_SIGNAL,1)&&iStochastic(NULL,pisto,pistok,pistod,istslow,MODE_EMA,0,MODE_MAIN,0)<=iStochastic(NULL,pisto,pistok,pistod,istslow,MODE_EMA,0,MODE_SIGNAL,0))
      {f29=-1;}


      //30. Williams Percent Range
      //Buy: crossing -80 upwards
      //Sell: crossing -20 downwards
      if (iWPR(NULL,piwpr,piwprbar,1)<-80&&iWPR(NULL,piwpr,piwprbar,0)>=-80)
      {f30=1;}
      if (iWPR(NULL,piwpr,piwprbar,1)>-20&&iWPR(NULL,piwpr,piwprbar,0)<=-20)
      {f30=-1;}

 */

/*
 * Predefined constants:
 *   Ask (for buying)  - The latest known seller's price (ask price) of the current symbol.
 *   Bid (for selling) - The latest known buyer's price (offer price, bid price) of the current symbol.
 *   Point - The current symbol point value in the quote currency.
 *   Digits - Number of digits after decimal point for the current symbol prices.
 *   Bars - Number of bars in the current chart.
 */

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
  if (!session_initiated) return;

  // Check the last tick change.
  last_tick_change = MathMax(GetPipDiff(Ask, LastAsk, TRUE), GetPipDiff(Bid, LastBid, TRUE));
  // if (VerboseDebug && last_tick_change > 1) Print("Tick change: " + tick_change + "; Ask" + Ask + ", Bid: " + Bid, ", LastAsk: " + LastAsk + ", LastBid: " + LastBid);

  // Check if we should pass the tick.
  bar_time = iTime(NULL, PERIOD_M1, 0); // - GMT_Offset
  if (bar_time <= last_bar_time || last_tick_change < MinPipChangeToTrade) {
    LastAsk = Ask; LastBid = Bid;
    return;
  } else {
    last_bar_time = bar_time;
    if (hour_of_day != Hour()) StartNewHour();
  }

  if (TradeAllowed()) {
    UpdateVariables();
    UpdateIndicators(PERIOD_M1);
    UpdateIndicators(PERIOD_M5);
    UpdateIndicators(PERIOD_M15);
    UpdateIndicators(PERIOD_M30);
    Trade();
    if (GetTotalOrders() > 0) {
      UpdateTrailingStops();
      CheckAccountConditions();
      TaskProcessList();
    }
    UpdateStats();
  }
  if (ea_active && PrintLogOnChart) DisplayInfoOnChart();
  LastAsk = Ask; LastBid = Bid;

} // end: OnTick()

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
  if (VerboseInfo) Print("EA initializing...");
  string err;

  if (!session_initiated) {
    if (!ValidSettings()) {
      err = "Error: EA parameters are not valid, please correct them.";
      Comment(err);
      Alert(err);
      if (VerboseErrors) Print(__FUNCTION__ + "():" + err);
      ExpertRemove();
      return (INIT_PARAMETERS_INCORRECT); // Incorrect set of input parameters.
    }
    if (!IsTesting() && StringLen(AccountName()) <= 1) {
      err = "Error: EA requires on-line Terminal.";
      Comment(err);
      if (VerboseErrors) Print(__FUNCTION__ + "():" + err);
      return (INIT_FAILED);
     }
     session_initiated = TRUE;
  }

  InitializeVariables();
  InitializeConditions();
  CheckHistory();

  if (IsTesting()) {
    SendEmailEachOrder = FALSE;
    SoundAlert = FALSE;
    if (!IsVisualMode()) PrintLogOnChart = FALSE;
    if (market_stoplevel == 0) market_stoplevel = DemoMarketStopLevel; // When testing, we need to simulate real MODE_STOPLEVEL = 30 (as it's in real account), in demo it's 0.
    if (IsOptimization()) {
      VerboseErrors = FALSE;
      VerboseInfo   = FALSE;
      VerboseDebug  = FALSE;
      VerboseTrace  = FALSE;
    }
  }

  if (session_initiated && VerboseInfo) {
    string output = InitInfo();
    PrintText(output);
    Comment(output);
  }

  session_active = TRUE;
  ea_active = TRUE;
  WindowRedraw();

  return (INIT_SUCCEEDED);
} // end: OnInit()

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
  ea_active = TRUE;
  if (VerboseDebug) Print("Calling " + __FUNCTION__ + "()");
  if (VerboseInfo) {
    Print(__FUNCTION__ + "():" + "EA deinitializing, reason: " + getUninitReasonText(reason) + " (code: " + reason + ")"); // Also: _UninitReason.
    Print(GetSummaryText());
  }

   if (WriteReport && !IsOptimization() && session_initiated) {
      double ExtInitialDeposit;
      if (!IsTesting()) ExtInitialDeposit = CalculateInitialDeposit();
      CalculateSummary(ExtInitialDeposit);
      string filename = TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES) + "_31337_Report.txt";
      WriteReport(filename); // Todo: Add: getUninitReasonText(reason)
      Print(__FUNCTION__ + "(): Saved report as: " + filename);
  }
  // #ifdef _DEBUG
  // DEBUG("n=" + n + " : " +  DoubleToStrMorePrecision(val,19) );
  // DEBUG("CLOSEDEBUGFILE");
  // #endif
} // end: OnDeinit()

// The init event handler for tester.
// FIXME: Doesn't seems to work.
void OnTesterInit() {
  if (VerboseDebug) Print("Calling " + __FUNCTION__ + "()");
}

// The init event handler for tester.
// FIXME: Doesn't seems to work.
void OnTesterDeinit() {
  if (VerboseDebug) Print("Calling " + __FUNCTION__ + "()");
}

// The Start event handler, which is automatically generated only for running scripts.
// FIXME: Doesn't seems to be called, however MT4 doesn't want to execute EA without it.
void start() {
  if (VerboseTrace) Print("Calling " + __FUNCTION__ + "()");
  if (VerboseInfo) Print(__FUNCTION__ + "(): " + GetMarketTextDetails());
}

/*
 * Print init variables and constants.
 */
string InitInfo(string sep = "\n") {
  string output = StringFormat("%s (%s) v%s by %s%s", ea_name, __FILE__, ea_version, ea_author, sep); // ea_link
  output += StringFormat("Platform variables: Symbol: %s, Bars: %d, Server: %s, Login: %d%s",
    _Symbol, Bars, AccountInfoString(ACCOUNT_SERVER), (int)AccountInfoInteger(ACCOUNT_LOGIN), sep);
  output += StringFormat("Broker info: Name: %s, Account type: %s, Leverage: 1:%d, Currency: %s%s", AccountCompany(), account_type, AccountLeverage(), AccCurrency, sep);
  output += StringFormat("Market variables: Ask: %f, Bid: %f, Volume: %d%s", Ask, Bid, Volume[0], sep);
  output += StringFormat("Market constants: Digits: %d, Point: %f, Min Lot: %g, Max Lot: %g, Lot Step: %g, Margin Required: %g, Stop Level: %g%s",
    Digits, NormalizeDouble(Point, Digits), NormalizeDouble(market_minlot, PipDigits), market_maxlot, market_lotstep, market_marginrequired, market_stoplevel, sep);
  output += StringFormat("Contract specification for %s: Digits: %d, Point value: %f, Spread: %g, Stop level: %g, Contract size: %g, Tick size: %f%s",
    _Symbol, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS), SymbolInfoDouble(_Symbol, SYMBOL_POINT), (int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD),
    (int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL), SymbolInfoDouble(_Symbol,SYMBOL_TRADE_CONTRACT_SIZE), SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE), sep);
  output += StringFormat("Swap specification for %s: Mode: %d, Long/buy order value: %g, Short/sell order value: %g%s",
    _Symbol, (int)SymbolInfoInteger(_Symbol, SYMBOL_SWAP_MODE), SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG), SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT), sep);
  output += StringFormat("Calculated variables: Lot size: %g, Max orders: %d (per type: %d), Active strategies: %d of %d, Pip size: %g, Points per pip: %d, Pip digits: %d, Volume digits: %d, Spread in pips: %g%s",
              NormalizeDouble(lot_size, VolumeDigits), max_orders, GetMaxOrdersPerType(), GetNoOfStrategies(), FINAL_STRATEGY_TYPE_ENTRY,
              NormalizeDouble(pip_size, PipDigits), pts_per_pip, PipDigits, VolumeDigits,
              NormalizeDouble(ValueToPips(GetMarketSpread()), PipDigits), sep);
  output += StringFormat("Time: Hour of day: %d, Day of week: %d, Day of month: %d, Day of year: %d" + sep, hour_of_day, day_of_week, day_of_month, day_of_year);
  output += GetAccountTextDetails() + sep;
  if (session_initiated && IsTradeAllowed()) {
    output += sep + "Trading is allowed, please wait to start trading...";
  } else {
    output += sep + "Error: Trading is not allowed, please check the settings and allow automated trading!";
  }
  return output;
}

/*
 * Main function to trade.
 */
bool Trade() {
  bool order_placed = FALSE;
  double trade_lot;
  int trade_cmd, pf;
  // if (VerboseTrace) Print("Calling " + __FUNCTION__ + "()");
  // vdigits = MarketInfo(Symbol(), MODE_DIGITS);

  for (int id = 0; id < FINAL_STRATEGY_TYPE_ENTRY; id++) {
    trade_cmd = EMPTY;
    if (info[id][ACTIVE]) {
      trade_lot = If(conf[id][LOT_SIZE], conf[id][LOT_SIZE], lot_size) * If(conf[id][FACTOR], conf[id][FACTOR], 1.0);
      if (TradeCondition(id, OP_BUY))  trade_cmd = OP_BUY;
      else if (TradeCondition(id, OP_SELL)) trade_cmd = OP_SELL;
      #ifdef __advanced__
      if (!DisableCloseConditions) {
        if (CheckMarketEvent(OP_BUY,  M30, info[id][CLOSE_CONDITION])) CloseOrdersByType(OP_SELL, id, "closing on market change: " + name[id], TRUE);
        if (CheckMarketEvent(OP_SELL, M30, info[id][CLOSE_CONDITION])) CloseOrdersByType(OP_BUY,  id, "closing on market change: " + name[id], TRUE);
      }
      if (trade_cmd == OP_BUY  && !CheckMarketCondition1(OP_BUY,  info[id][TIMEFRAME], info[id][OPEN_CONDITION1])) trade_cmd = EMPTY;
      if (trade_cmd == OP_SELL && !CheckMarketCondition1(OP_SELL, info[id][TIMEFRAME], info[id][OPEN_CONDITION1])) trade_cmd = EMPTY;
      if (trade_cmd == OP_BUY  &&  CheckMarketCondition1(OP_SELL, M30, info[id][OPEN_CONDITION2], FALSE)) trade_cmd = EMPTY;
      if (trade_cmd == OP_SELL &&  CheckMarketCondition1(OP_BUY,  M30, info[id][OPEN_CONDITION2], FALSE)) trade_cmd = EMPTY;
      if (Boosting_Enabled) {
        pf = GetStrategyProfitFactor(id);
        if (BoostByProfitFactor && pf > 1.0) trade_lot *= MathMax(GetStrategyProfitFactor(id), 1.0);
        else if (HandicapByProfitFactor && pf < 1.0) trade_lot *= MathMin(GetStrategyProfitFactor(id), 1.0);
      }
      #endif
      if (Boosting_Enabled && CheckTrend(TrendMethod) == trade_cmd && BoostTrendFactor != 1.0) {
        trade_lot *= BoostTrendFactor;
      }

      if (trade_cmd != EMPTY) {
        order_placed &= ExecuteOrder(trade_cmd, trade_lot, id, name[id]);
      }

    } // end: if
   } // end: for
  return order_placed;
}

/*
 * Check if strategy is on trade.
 */
bool TradeCondition(int order_type = 0, int cmd = EMPTY) {
  if (TradeWithTrend && !CheckTrend(TrendMethod) == cmd) {
    return (FALSE); // If we're against the trend, do not trade (if TradeWithTrend is set).
  }
  int timeframe = info[order_type][TIMEFRAME];
  int open_method = info[order_type][OPEN_METHOD];
  switch (order_type) {
    case MA1:
    case MA5:
    case MA15:
    case MA30:
      return ((cmd == OP_BUY && MA_On_Buy(timeframe, open_method, MA_OpenLevel)) ||
              (cmd == OP_SELL && MA_On_Sell(timeframe, open_method, MA_OpenLevel))
             );
    case MACD1:
    case MACD5:
    case MACD15:
    case MACD30:
      return ((cmd == OP_BUY && MACD_On_Buy(timeframe, open_method, MACD_OpenLevel)) ||
              (cmd == OP_SELL && MACD_On_Sell(timeframe, open_method, MACD_OpenLevel))
             );
    case ALLIGATOR1:
    case ALLIGATOR5:
    case ALLIGATOR15:
    case ALLIGATOR30:
      return ((cmd == OP_BUY && Alligator_On_Buy(timeframe, open_method, Alligator_OpenLevel)) ||
              (cmd == OP_SELL && Alligator_On_Sell(timeframe, open_method, Alligator_OpenLevel))
             );
    case RSI1:
    case RSI5:
    case RSI15:
    case RSI30:
      return ((cmd == OP_BUY && RSI_On_Buy(timeframe, open_method, RSI_OpenLevel)) ||
              (cmd == OP_SELL && RSI_On_Sell(timeframe, open_method, RSI_OpenLevel))
             );
    case SAR1:
    case SAR5:
    case SAR15:
    case SAR30:
      return ((cmd == OP_BUY && SAR_On_Buy(timeframe, open_method, SAR_OpenLevel)) ||
              (cmd == OP_SELL && SAR_On_Sell(timeframe, open_method, SAR_OpenLevel))
             );
    case BANDS1:
    case BANDS5:
    case BANDS15:
    case BANDS30:
      return ((cmd == OP_BUY && Bands_On_Buy(timeframe, open_method)) ||
              (cmd == OP_SELL && Bands_On_Sell(timeframe, open_method))
             );
    case ENVELOPES1:
    case ENVELOPES5:
    case ENVELOPES15:
    case ENVELOPES30:
      return ((cmd == OP_BUY && Envelopes_On_Buy(timeframe, open_method)) ||
              (cmd == OP_SELL && Envelopes_On_Sell(timeframe, open_method))
             );
    case DEMARKER1:
    case DEMARKER5:
    case DEMARKER15:
    case DEMARKER30:
      return ((cmd == OP_BUY && DeMarker_On_Buy(timeframe, open_method, DeMarker_OpenLevel)) ||
              (cmd == OP_SELL && DeMarker_On_Sell(timeframe, open_method, DeMarker_OpenLevel))
             );
    case WPR1:
    case WPR5:
    case WPR15:
    case WPR30:
      return ((cmd == OP_BUY && WPR_On_Buy(timeframe, open_method, WPR_OpenLevel)) ||
              (cmd == OP_SELL && WPR_On_Sell(timeframe, open_method, WPR_OpenLevel))
             );
    case FRACTALS1:
    case FRACTALS5:
    case FRACTALS15:
    case FRACTALS30:
      return ((cmd == OP_BUY && Fractals_On_Buy(timeframe, open_method)) ||
              (cmd == OP_SELL && Fractals_On_Sell(timeframe, open_method))
             );
  }
  return FALSE;
}

/*
 * Check if strategy is on trade.
 *
 * TODO: Convert this function in more flexible way by breaking down each indicator individually.
 */
bool UpdateIndicators(int timeframe = PERIOD_M1) {
/*
  // Check if bar time has been changed since last check.
  int bar_time = iTime(NULL, PERIOD_M1, 0);
  if (bar_time == last_indicators_update) {
    return (FALSE);
  } else {
    last_indicators_update = bar_time;
  }*/

  int period = M1, bands_period = Bands_Period, rsi_period = RSI_Period;
  double envelopes_deviation = Envelopes1_Deviation;
  switch (timeframe) {
    case PERIOD_M1:
      period = M1;
      bands_period = info[BANDS1][CUSTOM_PERIOD];
      rsi_period = info[RSI1][CUSTOM_PERIOD];
      envelopes_deviation = Envelopes1_Deviation;
      break;
    case PERIOD_M5:
      period = M5;
      bands_period = info[BANDS5][CUSTOM_PERIOD];
      rsi_period = info[RSI5][CUSTOM_PERIOD];
      envelopes_deviation = Envelopes5_Deviation;
      break;
    case PERIOD_M15:
      period = M15;
      bands_period = info[BANDS15][CUSTOM_PERIOD];
      rsi_period = info[RSI15][CUSTOM_PERIOD];
      envelopes_deviation = Envelopes15_Deviation;
      break;
    case PERIOD_M30:
      period = M30;
      bands_period = info[BANDS30][CUSTOM_PERIOD];
      rsi_period = info[RSI30][CUSTOM_PERIOD];
      envelopes_deviation = Envelopes30_Deviation;
      break;
  }

  int i;
  string text = __FUNCTION__ + "(): ";

  // Update Moving Averages indicator values.
  // Note: We don't limit MA calculation with MA_Active, because this indicator is used for trailing stop calculation.
  // Calculate MA Fast.
  ma_fast[period][CURR] = iMA(NULL, timeframe, MA_Period_Fast, MA_Shift, MA_Method, MA_Applied_Price, 0); // Current
  ma_fast[period][PREV] = iMA(NULL, timeframe, MA_Period_Fast, MA_Shift, MA_Method, MA_Applied_Price, 1 + MA_Shift_Fast); // Previous
  ma_fast[period][FAR]  = iMA(NULL, timeframe, MA_Period_Fast, MA_Shift, MA_Method, MA_Applied_Price, 2 + MA_Shift_Far);
  // Calculate MA Medium.
  ma_medium[period][CURR] = iMA(NULL, timeframe, MA_Period_Medium, MA_Shift, MA_Method, MA_Applied_Price, 0); // Current
  ma_medium[period][PREV] = iMA(NULL, timeframe, MA_Period_Medium, MA_Shift, MA_Method, MA_Applied_Price, 1 + MA_Shift_Medium); // Previous
  ma_medium[period][FAR]  = iMA(NULL, timeframe, MA_Period_Medium, MA_Shift, MA_Method, MA_Applied_Price, 2 + MA_Shift_Far);
  // Calculate Ma Slow.
  ma_slow[period][CURR] = iMA(NULL, timeframe, MA_Period_Slow, MA_Shift, MA_Method, MA_Applied_Price, 0); // Current
  ma_slow[period][PREV] = iMA(NULL, timeframe, MA_Period_Slow, MA_Shift, MA_Method, MA_Applied_Price, 1 + MA_Shift_Slow); // Previous
  ma_slow[period][FAR]  = iMA(NULL, timeframe, MA_Period_Slow, MA_Shift, MA_Method, MA_Applied_Price, 2 + MA_Shift_Far);

  // TODO: testing
  // ma_fast[period][0] = iMA(NULL, MA_Timeframe, MA_Period_Medium / MA_Period_Ratio, 0, MA_Method, MA_Applied_Price, 0); // Current
  // ma_fast[period][1] = iMA(NULL, MA_Timeframe, MA_Period_Medium / MA_Period_Ratio, 0, MA_Method, MA_Applied_Price, 1 + MA_Shift_Fast); // Previous
  // ma_fast[period][2] = iMA(NULL, MA_Timeframe, MA_Period_Medium / MA_Period_Ratio, 0, MA_Method, MA_Applied_Price, 2 + MA_Shift_Far);
  // ma_slow[period][0] = iMA(NULL, MA_Timeframe, MA_Period_Medium * MA_Period_Ratio, 0, MA_Method, MA_Applied_Price, 0); // Current
  // ma_slow[period][1] = iMA(NULL, MA_Timeframe, MA_Period_Medium * MA_Period_Ratio, 0, MA_Method, MA_Applied_Price, 1 + MA_Shift_Slow); // Previous
  // ma_slow[period][2] = iMA(NULL, MA_Timeframe, MA_Period_Medium * MA_Period_Ratio, 0, MA_Method, MA_Applied_Price, 2 + MA_Shift_Far);
  // if (VerboseTrace) text += "MA: MA_Fast: " + GetArrayValues(ma_fast[M1]) + "; MA_Medium: " + GetArrayValues(ma_medium[M1]) + "; MA_Slow: " + GetArrayValues(ma_slow[M1]) + "; ";
  if (VerboseDebug && IsVisualMode()) DrawMA(timeframe);

  //if (MACD_Active) {
    // Update MACD indicator values.
    macd[period][CURR] = iMACD(NULL, timeframe, MACD_Fast_Period, MACD_Slow_Period, MACD_Signal_Period, MACD_Applied_Price, MODE_MAIN, 0); // Current
    macd[period][PREV] = iMACD(NULL, timeframe, MACD_Fast_Period, MACD_Slow_Period, MACD_Signal_Period, MACD_Applied_Price, MODE_MAIN, 1 + MACD_Shift); // Previous
    macd[period][FAR]  = iMACD(NULL, timeframe, MACD_Fast_Period, MACD_Slow_Period, MACD_Signal_Period, MACD_Applied_Price, MODE_MAIN, 2 + MACD_ShiftFar);
    macd_signal[period][CURR] = iMACD(NULL, timeframe, MACD_Fast_Period, MACD_Slow_Period, MACD_Signal_Period, MACD_Applied_Price, MODE_SIGNAL, 0);
    macd_signal[period][PREV] = iMACD(NULL, timeframe, MACD_Fast_Period, MACD_Slow_Period, MACD_Signal_Period, MACD_Applied_Price, MODE_SIGNAL, 1 + MACD_Shift);
    macd_signal[period][FAR]  = iMACD(NULL, timeframe, MACD_Fast_Period, MACD_Slow_Period, MACD_Signal_Period, MACD_Applied_Price, MODE_SIGNAL, 2 + MACD_ShiftFar);
    // if (VerboseTrace) text += "MACD: " + GetArrayValues(macd[M1]) + "; Signal: " + GetArrayValues(macd_signal[M1]) + "; ";
  //}

  // if (Alligator1_Active || Alligator5_Active || Alligator15_Active || Alligator30_Active) {
    // Update Alligator indicator values.
    // Colors: Alligator's Jaw - Blue, Alligator's Teeth - Red, Alligator's Lips - Green.
    for (i = 0; i < 3; i++) {
      alligator[period][i][JAW] = iMA(NULL, timeframe, Alligator_Jaw_Period,   Alligator_Jaw_Shift,   Alligator_MA_Method, Alligator_Applied_Price, i + Alligator_Shift);
      alligator[period][i][TEETH] = iMA(NULL, timeframe, Alligator_Teeth_Period, Alligator_Teeth_Shift, Alligator_MA_Method, Alligator_Applied_Price, i + Alligator_Shift);
      alligator[period][i][LIPS]  = iMA(NULL, timeframe, Alligator_Lips_Period,  Alligator_Lips_Shift,  Alligator_MA_Method, Alligator_Applied_Price, i + Alligator_Shift_Far);
    }
    /* Which is equivalent to:
    alligator[0][0] = iAlligator(NULL, Alligator_Timeframe, Alligator_Jaw_Period, Alligator_Jaw_Shift, Alligator_Teeth_Period, Alligator_Teeth_Shift, Alligator_Lips_Period, Alligator_Lips_Shift, Alligator_MA_Method, Alligator_Applied_Price, MODE_GATORJAW,   Alligator_Shift);
    alligator[0][1] = iAlligator(NULL, Alligator_Timeframe, Alligator_Jaw_Period, Alligator_Jaw_Shift, Alligator_Teeth_Period, Alligator_Teeth_Shift, Alligator_Lips_Period, Alligator_Lips_Shift, Alligator_MA_Method, Alligator_Applied_Price, MODE_GATORTEETH, Alligator_Shift);
    alligator[0][2] = iAlligator(NULL, Alligator_Timeframe, Alligator_Jaw_Period, Alligator_Jaw_Shift, Alligator_Teeth_Period, Alligator_Teeth_Shift, Alligator_Lips_Period, Alligator_Lips_Shift, Alligator_MA_Method, Alligator_Applied_Price, MODE_GATORLIPS,  Alligator_Shift);
     */
    // if (VerboseTrace) text += "Alligator: " + GetArrayValues(alligator[0]) + GetArrayValues(alligator[1]) + "; ";
  // }

  // if (RSI_Active) {
    // Update RSI indicator values.
    for (i = 0; i < 3; i++) {
      rsi[period][i] = iRSI(NULL, timeframe, rsi_period, RSI_Applied_Price, i + RSI_Shift);
      if (rsi[period][i] > rsi_stats[period][MODE_UPPER]) rsi_stats[period][MODE_UPPER] = rsi[period][i]; // Calculate maximum value.
      if (rsi[period][i] < rsi_stats[period][MODE_LOWER] || rsi_stats[period][MODE_LOWER] == 0) rsi_stats[period][MODE_LOWER] = rsi[period][i]; // Calculate minimum value.
    }
    rsi_stats[period][0] = If(rsi_stats[period][0] > 0, (rsi_stats[period][0] + rsi[period][0] + rsi[period][1] + rsi[period][2]) / 4, (rsi[period][0] + rsi[period][1] + rsi[period][2]) / 3); // Calculate average value.
    // if (VerboseTrace) text += "RSI: " + GetArrayValues(rsi[M1]) + "; ";
  // }

  // if (SAR_Active) {
    // Update SAR indicator values.
    for (i = 0; i < 3; i++) {
      sar[period][i] = iSAR(NULL, timeframe, SAR_Step, SAR_Maximum_Stop, i + SAR_Shift);
    }
    // if (VerboseTrace) text += "SAR: " + GetArrayValues(sar[M1]) + "; ";
  // }

  // if (Bands_Active) {
    // Update the Bollinger Bands indicator values.
    for (i = 0; i < 3; i++) {
      bands[period][i][MODE_MAIN]  = iBands(NULL, timeframe, bands_period, Bands_Deviation, Bands_Shift, Bands_Applied_Price, MODE_MAIN,  i + Bands_Shift);
      bands[period][i][MODE_UPPER] = iBands(NULL, timeframe, bands_period, Bands_Deviation, Bands_Shift, Bands_Applied_Price, MODE_UPPER, i + Bands_Shift);
      bands[period][i][MODE_LOWER] = iBands(NULL, timeframe, bands_period, Bands_Deviation, Bands_Shift, Bands_Applied_Price, MODE_LOWER, i + Bands_Shift);
    }
    // if (VerboseTrace) text += "Bands: " + GetArrayValues(bands) + "; ";
  // }

  // if (Envelopes1_Active || Envelopes5_Active || Envelopes15_Active || Envelopes30_Active) {
    // Update the Envelopes indicator values.
    for (i = 0; i < 3; i++) {
      envelopes[period][i][MODE_MAIN]  = iEnvelopes(NULL, timeframe, Envelopes_MA_Period, Envelopes_MA_Method, Envelopes_MA_Shift, Envelopes_Applied_Price, envelopes_deviation, MODE_MAIN,  i + Envelopes_Shift);
      envelopes[period][i][MODE_UPPER] = iEnvelopes(NULL, timeframe, Envelopes_MA_Period, Envelopes_MA_Method, Envelopes_MA_Shift, Envelopes_Applied_Price, envelopes_deviation, MODE_UPPER, i + Envelopes_Shift);
      envelopes[period][i][MODE_LOWER] = iEnvelopes(NULL, timeframe, Envelopes_MA_Period, Envelopes_MA_Method, Envelopes_MA_Shift, Envelopes_Applied_Price, envelopes_deviation, MODE_LOWER, i + Envelopes_Shift);
    }
    // if (VerboseTrace) text += "Envelopes: " + GetArrayValues(envelopes) + "; ";
  // }

  // if (WPR1_Active || WPR5_Active || WPR15_Active || WPR30_Active) {
    // Update the Larry Williams' Percent Range indicator values.
    wpr[period][CURR] = -iWPR(NULL, timeframe, WPR_Period, 0 + WPR_Shift);
    wpr[period][PREV] = -iWPR(NULL, timeframe, WPR_Period, 1 + WPR_Shift);
    wpr[period][FAR]  = -iWPR(NULL, timeframe, WPR_Period, 2 + WPR_Shift);
    // if (VerboseTrace) text += "WPR: " + GetArrayValues(wpr[M1]) + "; ";
  // }

  // if (DeMarker1_Active || DeMarker5_Active || DeMarker15_Active || DeMarker30_Active) {
    // Update DeMarker indicator values.
    demarker[period][CURR] = iDeMarker(NULL, timeframe, DeMarker_Period, 0 + DeMarker_Shift);
    demarker[period][PREV] = iDeMarker(NULL, timeframe, DeMarker_Period, 1 + DeMarker_Shift);
    demarker[period][FAR]  = iDeMarker(NULL, timeframe, DeMarker_Period, 2 + DeMarker_Shift);
    // if (VerboseTrace) text += "DeMarker: " + GetArrayValues(demarker[M1]) + "; ";
  // }

  // if (Fractals1_Active || Fractals5_Active || Fractals15_Active || Fractals30_Active) {
    // Update Fractals indicator values.
    for (i = 0; i < 3; i++) {
      fractals[period][i][MODE_LOWER] = iFractals(NULL, timeframe, MODE_LOWER, i);
      fractals[period][i][MODE_UPPER] = iFractals(NULL, timeframe, MODE_UPPER, i);
    }
    // text += "fractals: "  + fractals_lower[M5]  + ", Fractals5_upper: " + fractals_upper[M5] + "; ";
  // }

  for (i = 0; i < 3; i++) {
    b_power[period][OP_BUY][i]  = iBullsPower(NULL, timeframe, B_Power_Period, B_Power_Applied_Price, i);
    b_power[period][OP_SELL][i] = iBearsPower(NULL, timeframe, B_Power_Period, B_Power_Applied_Price, i);
  }
  // Message("Bulls: " + b_power[period][OP_BUY][CURR] + ", Bears: " + b_power[period][OP_SELL][CURR]);

  // TODO
  // stoch[period][MODE_MAIN] = iStochastic(NULL, PERIOD_H1, 15, 9, 9, MODE_EMA, 0, MODE_MAIN, 1);
  // stoch[period][MODE_SIGNAL] = iStochastic(NULL, PERIOD_H1, 15, 9, 9, MODE_EMA, 0, MODE_SIGNAL, 1);
  // stoch[period][MODE_MAIN] = iStochastic(NULL, PERIOD_H1, 15, 9, 9, MODE_EMA, 0, MODE_MAIN, 2);
  // stoch[period][MODE_SIGNAL] = iStochastic(NULL, PERIOD_H1, 15, 9, 9, MODE_EMA, 0, MODE_SIGNAL, 2);

  if (VerboseTrace) Print(__FUNCTION__ + "():" + text);
  return (TRUE);
}

/*
 * Execute trade order.
 */
int ExecuteOrder(int cmd, double volume, int order_type, string order_comment = "", bool retry = TRUE) {
   bool result = FALSE;
   string err;
   int order_ticket;
   // int min_stop_level;
   double max_change = 1;
   volume = NormalizeLots(volume);

   if (MinimumIntervalSec > 0 && TimeCurrent() - last_order_time < MinimumIntervalSec) {
     err = "There must be a " + MinimumIntervalSec + " sec minimum interval between subsequent trade signals.";
     if (VerboseTrace && err != last_err) Print(__FUNCTION__ + "():" + err);
     last_err = err;
     return (FALSE);
   }
   // Check the limits.
   if (volume == 0) {
     err = "Lot size for strategy " + order_type + " is 0.";
     if (VerboseTrace && err != last_err) Print(__FUNCTION__ + "():" + err);
     last_err = err;
     return (FALSE);
   }
   if (GetTotalOrders() >= max_orders) {
     err = "Maximum open and pending orders reached the limit (MaxOrders).";
     if (VerboseErrors && err != last_err) Print(__FUNCTION__ + "():" + err);
     last_err = err;
     return (FALSE);
   }
   if (GetTotalOrdersByType(order_type) >= GetMaxOrdersPerType()) {
     err = name[order_type] + ": Maximum open and pending orders per type reached the limit (MaxOrdersPerType).";
     if (VerboseErrors && err != last_err) Print(__FUNCTION__ + "():" + err);
     last_err = err;
     return (FALSE);
   }
   if (!CheckFreeMargin(cmd, volume)) {
     err = "No money to open more orders.";
     if (PrintLogOnChart && err != last_err) Comment(__FUNCTION__ + "():" + last_err);
     if (VerboseErrors && err != last_err) Print(__FUNCTION__ + "():" + err);
     last_err = err;
     return (FALSE);
   }
   #ifdef __advanced__
   if (ApplySpreadLimits && !CheckSpreadLimit(order_type)) {
     double curr_spread = PointsToPips(GetMarketSpread(TRUE)); // In pips.
     err = name[order_type] + ": Not executing order, because the spread is too high." + " (spread = " + DoubleToStr(curr_spread, 1) + " pips)";
     if (VerboseTrace && err != last_err) Print(__FUNCTION__ + "():" + err);
     last_err = err;
     return (FALSE);
   }
   #endif
   if (!CheckMinPipGap(order_type)) {
     err = name[order_type] + ": Not executing order, because the gap is too small [MinPipGap].";
     if (VerboseTrace && err != last_err) Print(__FUNCTION__ + "():" + err + " (order type = " + order_type + ")");
     last_err = err;
     return (FALSE);
   }

   // Calculate take profit and stop loss.
   RefreshRates();
   if (VerboseDebug) Print(__FUNCTION__ + "(): " + GetMarketTextDetails()); // Print current market information before placing the order.
   double order_price = GetOpenPrice(cmd);
   double stoploss = 0, takeprofit = 0;
   if (StopLoss > 0.0) stoploss = NormalizeDouble(GetClosePrice(cmd) - (StopLoss + TrailingStop) * pip_size * OpTypeValue(cmd), Digits);
   else stoploss   = GetTrailingValue(cmd, -1, order_type);
   if (TakeProfit > 0.0) takeprofit = NormalizeDouble(order_price + (TakeProfit + TrailingProfit) * pip_size * OpTypeValue(cmd), Digits);
   else takeprofit = GetTrailingValue(cmd, +1, order_type);

   order_ticket = OrderSend(_Symbol, cmd, volume, NormalizeDouble(order_price, Digits), max_order_slippage, stoploss, takeprofit, order_comment, MagicNumber + order_type, 0, GetOrderColor(cmd));
   if (order_ticket >= 0) {
      if (!OrderSelect(order_ticket, SELECT_BY_TICKET) && VerboseErrors) {
        Print(__FUNCTION__ + "(): OrderSelect() error = ", ErrorDescription(GetLastError()));
        OrderPrint();
        if (retry) TaskAddOrderOpen(cmd, volume, order_type, order_comment); // Will re-try again.
        info[order_type][TOTAL_ERRORS]++;
        return (FALSE);
      }
      if (VerboseTrace) Print(__FUNCTION__, "(): Success: OrderSend(", Symbol(), ", ",  _OrderType_str(cmd), ", ", volume, ", ", NormalizeDouble(order_price, Digits), ", ", max_order_slippage, ", ", stoploss, ", ", takeprofit, ", ", order_comment, ", ", MagicNumber + order_type, ", 0, ", GetOrderColor(), ");");

      result = TRUE;
      // TicketAdd(order_ticket);
      last_order_time = TimeCurrent(); // Set last execution time.
      // last_trail_update = 0; // Set to 0, so trailing stops can be updated faster.
      order_price = OrderOpenPrice();
      if (VerboseInfo) OrderPrint();
      if (VerboseDebug) { Print(__FUNCTION__ + "(): " + GetOrderTextDetails() + GetAccountTextDetails()); }
      if (SoundAlert) PlaySound(SoundFileAtOpen);
      if (SendEmailEachOrder) SendEmail();

      /*
      if ((TakeProfit * pip_size > GetMinStopLevel() || TakeProfit == 0.0) &&
         (StopLoss * pip_size > GetMinStopLevel() || StopLoss == 0.0)) {
            result = OrderModify(order_ticket, order_price, stoploss, takeprofit, 0, ColorSell);
            if (!result && VerboseErrors) {
              Print(__FUNCTION__ + "(): Error: OrderModify() error = ", ErrorDescription(GetLastError()));
              if (VerboseDebug) Print(__FUNCTION__ + "():" + " Error: OrderModify(", order_ticket, ", ", order_price, ", ", stoploss, ", ", takeprofit, ", ", 0, ", ", ColorSell, ")");
            }
         }
      */
      // curr_bar_time = iTime(NULL, PERIOD_M1, 0);
   } else {
     result = FALSE;
     err_code = GetLastError();
     if (VerboseErrors) Print(__FUNCTION__, "(): OrderSend(): error = ", ErrorDescription(err_code));
     if (VerboseDebug) {
       PrintFormat("Error: OrderSend(%s, %d, %f, %f, %f, %f, %f, %s, %d, %d, %d)",
              _Symbol, cmd, volume, NormalizeDouble(order_price, Digits), max_order_slippage, stoploss, takeprofit, order_comment, MagicNumber + order_type, 0, GetOrderColor(cmd));
       Print(__FUNCTION__ + "(): " + GetAccountTextDetails());
       Print(__FUNCTION__ + "(): " + GetMarketTextDetails());
       OrderPrint();
     }
     // if (err_code != 136 /* OFF_QUOTES */) break;

     // Process the errors.
     if (err_code == ERR_TRADE_TOO_MANY_ORDERS) {
       // On some trade servers, the total amount of open and pending orders can be limited. If this limit has been exceeded, no new order will be opened.
       MaxOrders = GetTotalOrders(); // So we're setting new fixed limit for total orders which is allowed.
       retry = FALSE;
     }
     if (err_code == ERR_TRADE_EXPIRATION_DENIED) {
       // Applying of pending order expiration time can be disabled in some trade servers.
       retry = FALSE;
     }
     if (err_code == ERR_TOO_MANY_REQUESTS) {
       // It occurs when you send the same command OrderSend()/OrderModify() over and over again in a short period of time.
       retry = TRUE;
       Sleep(200); // Wait 200ms.
     }
     if (retry) TaskAddOrderOpen(cmd, volume, order_type, order_comment); // Will re-try again.
     info[order_type][TOTAL_ERRORS]++;
   } // end-if: order_ticket

/*
   TriesLeft--;
   if (TriesLeft > 0 && VerboseDebug) {
     Print("Price off-quote, will re-try to open the order.");
   }

   if (cmd == OP_BUY) new_price = Ask; else new_price = Bid;

   if (NormalizeDouble(MathAbs((new_price - order_price) / pip_size), 0) > max_change) {
     if (VerboseDebug) {
       Print("Price changed, not executing order: ", cmd);
     }
     break;
   }
   order_price = new_price;

   volume = NormalizeDouble(volume / 2.0, VolumeDigits);
   if (volume < market_minlot) volume = market_minlot;
   */
   return (result);
}

/*
 * Check if spread is not too high for specific strategy.
 *
 * @param
 *   sid (int) - strategy id
 * @return
 *   If TRUE, the spread is fine, otherwise return FALSE.
 */
bool CheckSpreadLimit(int sid) {
  double spread_limit = If(conf[sid][SPREAD_LIMIT] > 0, MathMin(conf[sid][SPREAD_LIMIT], MaxSpreadToTrade), MaxSpreadToTrade);
  double curr_spread = PointsToPips(GetMarketSpread(TRUE));
  return curr_spread <= spread_limit;
}

bool CloseOrder(int ticket_no, string reason, bool retry = TRUE) {
  bool result = FALSE;
  if (ticket_no > 0) {
    if (!OrderSelect(ticket_no, SELECT_BY_TICKET)) {
      return (FALSE);
    }
  } else {
    ticket_no = OrderTicket();
  }
  double close_price = NormalizeDouble(GetClosePrice(), Digits);
  result = OrderClose(ticket_no, OrderLots(), close_price, max_order_slippage, GetOrderColor());
  // if (VerboseTrace) Print(__FUNCTION__ + "(): CloseOrder request. Reason: " + reason + "; Result=" + result + " @ " + TimeCurrent() + "(" + TimeToStr(TimeCurrent()) + "), ticket# " + ticket_no);
  if (result) {
    if (SoundAlert) PlaySound(SoundFileAtClose);
    // TaskAddCalcStats(ticket_no); // Already done on CheckHistory().
    if (VerboseDebug) Print(__FUNCTION__, "(): Closed order " + ticket_no + " with profit " + GetOrderProfit() + ", reason: " + reason + "; " + GetOrderTextDetails());
  } else {
    err_code = GetLastError();
    if (VerboseErrors) Print(__FUNCTION__, "(): Error: Ticket: ", ticket_no, "; Error: ", GetErrorText(err_code));
    if (VerboseDebug) PrintFormat("Error: OrderClose(%d, %f, %f, %f, %d);", ticket_no, OrderLots(), close_price, max_order_slippage, GetOrderColor());
    if (VerboseDebug) Print(__FUNCTION__ + "(): " + GetMarketTextDetails());
    OrderPrint();
    if (retry) TaskAddCloseOrder(ticket_no); // Add task to re-try.
    int id = GetIdByMagic();
    if (id != EMPTY) info[id][TOTAL_ERRORS]++;
  } // end-if: !result
  return result;
}

/*
 * Re-calculate statistics based on the order.
 */
bool OrderCalc(int ticket_no = 0) {
  // OrderClosePrice(), OrderCloseTime(), OrderComment(), OrderCommission(), OrderExpiration(), OrderLots(), OrderOpenPrice(), OrderOpenTime(), OrderPrint(), OrderProfit(), OrderStopLoss(), OrderSwap(), OrderSymbol(), OrderTakeProfit(), OrderTicket(), OrderType()
  if (ticket_no == 0) ticket_no = OrderTicket();
  int id = GetIdByMagic();
  if (id == EMPTY) return FALSE;
  datetime close_time = OrderCloseTime();
  double profit = GetOrderProfit();
  info[id][TOTAL_ORDERS]++;
  if (profit > 0) {
    info[id][TOTAL_ORDERS_WON]++;
    stats[id][TOTAL_GROSS_PROFIT] += profit;
    if (profit > daily[MAX_PROFIT])   daily[MAX_PROFIT] = profit;
    if (profit > weekly[MAX_PROFIT])  weekly[MAX_PROFIT] = profit;
    if (profit > monthly[MAX_PROFIT]) monthly[MAX_PROFIT] = profit;
  } else {
    info[id][TOTAL_ORDERS_LOSS]++;
    stats[id][TOTAL_GROSS_LOSS] += profit;
    if (profit < daily[MAX_LOSS])     daily[MAX_LOSS] = profit;
    if (profit < weekly[MAX_LOSS])    weekly[MAX_LOSS] = profit;
    if (profit < monthly[MAX_LOSS])   monthly[MAX_LOSS] = profit;
  }
  stats[id][TOTAL_NET_PROFIT] += profit;

  if (TimeDayOfYear(close_time) == DayOfYear()) {
    stats[id][DAILY_PROFIT] += profit;
  }
  if (TimeDayOfWeek(close_time) <= DayOfWeek()) {
    stats[id][WEEKLY_PROFIT] += profit;
  }
  if (TimeDay(close_time) <= Day()) {
    stats[id][MONTHLY_PROFIT] += profit;
  }
  //TicketRemove(ticket_no);
  return TRUE;
}

/*
 * Close order by type of order and strategy used. See: ENUM_STRATEGY_TYPE.
 *
 * @param
 *   cmd (int) - trade operation command to close (OP_SELL/OP_BUY)
 *   strategy_type (int) - strategy type, see ENUM_STRATEGY_TYPE
 */
int CloseOrdersByType(int cmd, int strategy_id, string reason = "", bool only_profitable = FALSE) {
   int orders_total, order_failed;
   double profit_total;
   RefreshRates();
   for (int order = 0; order < OrdersTotal(); order++) {
      if (OrderSelect(order, SELECT_BY_POS, MODE_TRADES)) {
        if (strategy_id == GetIdByMagic() && OrderSymbol() == Symbol() && OrderType() == cmd) {
          if (only_profitable && GetOrderProfit() < 0) continue;
          if (CloseOrder(0, reason)) {
             orders_total++;
             profit_total += GetOrderProfit();
          } else {
            order_failed++;
          }
        }
      } else {
        if (VerboseDebug)
          Print(__FUNCTION__ + "(" + cmd + ", " + strategy_id + "): Error: Order: " + order + "; Message: ", GetErrorText(err_code));
        // TaskAddCloseOrder(OrderTicket(), reason); // Add task to re-try.
      }
   }
   if (orders_total > 0 && VerboseInfo) {
     // FIXME: EnumToString(order_type) doesn't work here.
     Print(__FUNCTION__ + "():" + "Closed ", orders_total, " orders (", cmd, ", ", strategy_id, ") on market change with total profit of : ", profit_total, " pips (", order_failed, " failed)");
   }
   return (orders_total);
}

// Update statistics.
bool UpdateStats() {
  // Check if bar time has been changed since last check.
  // int bar_time = iTime(NULL, PERIOD_M1, 0);
  CheckStats(last_tick_change, MAX_TICK);
  CheckStats(Low[0],  MAX_LOW);
  CheckStats(High[0], MAX_HIGH);
  CheckStats(AccountBalance(), MAX_BALANCE);
  CheckStats(AccountEquity(), MAX_EQUITY);
  if (last_tick_change > MarketBigDropSize) {
    double diff1 = MathMax(GetPipDiff(Ask, LastAsk), GetPipDiff(Bid, LastBid));
    Message(StringFormat("Market very big drop of %.1f pips detected!", diff1));
    Print(__FUNCTION__ + "(): " + GetLastMessage());
    if (WriteReport) ReportAdd(__FUNCTION__ + "(): " + GetLastMessage());
  }
  else if (VerboseDebug && last_tick_change > MarketSuddenDropSize) {
    double diff2 = MathMax(GetPipDiff(Ask, LastAsk), GetPipDiff(Bid, LastBid));
    Message(StringFormat("Market sudden drop of %.1f pips detected!", diff2));
    Print(__FUNCTION__ + "(): " + GetLastMessage());
    if (WriteReport) ReportAdd(__FUNCTION__ + "(): " + GetLastMessage());
  }
  return (TRUE);
}

/*
 * Check if MA indicator is on buy.
 *
 * @param
 *   period (int) - period to check for
 *   open_method (int) - open method to use by using bitwise AND operation
 *   open_level (double) - open level to consider the signal
 */
bool MA_On_Buy(int period = M1, int open_method = 0, double open_level = 0.0) {
  double gap = open_level * pip_size;
  bool result = ma_fast[period][CURR] > ma_medium[period][CURR] + gap;
  if ((open_method &   1) != 0) result = result && ma_fast[period][CURR] > ma_slow[period][CURR] + gap;
  if ((open_method &   2) != 0) result = result && ma_medium[period][CURR] > ma_slow[period][CURR];
  if ((open_method &   4) != 0) result = result && ma_slow[period][CURR] > ma_slow[period][PREV];
  if ((open_method &   8) != 0) result = result && ma_fast[period][CURR] > ma_fast[period][PREV];
  if ((open_method &  16) != 0) result = result && ma_fast[period][CURR] - ma_medium[period][CURR] > ma_medium[period][CURR] - ma_slow[period][CURR];
  if ((open_method &  32) != 0) result = result && (ma_medium[period][PREV] < ma_slow[period][PREV] || ma_medium[period][FAR] < ma_slow[period][FAR]);
  if ((open_method &  64) != 0) result = result && (ma_fast[period][PREV] < ma_medium[period][PREV] || ma_fast[period][FAR] < ma_medium[period][FAR]);
  return result;
}

/*
 * Check if MA indicator is on buy.
 *
 * @param
 *   period (int) - period to check for
 *   open_method (int) - open method to use by using bitwise AND operation
 *   open_level (double) - open level to consider the signal
 */
bool MA_On_Sell(int period = M1, int open_method = 0, double open_level = 0.0) {
  double gap = open_level * pip_size;
  bool result = ma_fast[period][CURR] < ma_medium[period][CURR] - gap;
  if ((open_method &   1) != 0) result = result && ma_fast[period][CURR] < ma_slow[period][CURR] - gap;
  if ((open_method &   2) != 0) result = result && ma_medium[period][CURR] < ma_slow[period][CURR];
  if ((open_method &   4) != 0) result = result && ma_slow[period][CURR] < ma_slow[period][PREV];
  if ((open_method &   8) != 0) result = result && ma_fast[period][CURR] < ma_fast[period][PREV];
  if ((open_method &  16) != 0) result = result && ma_medium[period][CURR] - ma_fast[period][CURR] > ma_slow[period][CURR] - ma_medium[period][CURR];
  if ((open_method &  32) != 0) result = result && (ma_medium[period][PREV] > ma_slow[period][PREV] || ma_medium[period][FAR] > ma_slow[period][FAR]);
  if ((open_method &  64) != 0) result = result && (ma_fast[period][PREV] > ma_medium[period][PREV] || ma_fast[period][FAR] > ma_medium[period][FAR]);
  return result;
}

/*
 * Check if MACD indicator is on buy.
 *
 * To calculate the maximum open method, check the Least Common Multiple (LCM) for MathMod numbers.
 *
 * @param
 *   period (int) - period to check for
 *   open_method (int) - open method to use by using bitwise AND operation
 *   open_level (double) - open level to consider the signal
 */
bool MACD_On_Buy(int period = M1, int open_method = 0, double open_level = 0.0) {
  double gap = open_level * pip_size;
  bool result = macd[period][CURR] > macd_signal[period][CURR] + gap; // MACD rises above the signal line.
  if ((open_method &   1) != 0) result = result && macd[period][FAR] < macd_signal[period][FAR];
  if ((open_method &   2) != 0) result = result && macd[period][CURR] >= 0;
  if ((open_method &   4) != 0) result = result && macd[period][PREV] < 0;
  if ((open_method &   8) != 0) result = result && ma_fast[period][CURR] > ma_fast[period][PREV];
  if ((open_method &  16) != 0) result = result && ma_fast[period][CURR] > ma_medium[period][CURR];
  return result;
}

/*
 * Check if MACD indicator is on sell.
 *
 * To calculate the maximum open method, check the Least Common Multiple (LCM) for MathMod numbers.
 *
 * @param
 *   period (int) - period to check for
 *   open_method (int) - open method to use by using bitwise AND operation
 *   open_level (double) - open level to consider the signal
 */
bool MACD_On_Sell(int period = M1, int open_method = 0, double open_level = 0.0) {
  double gap = open_level * pip_size;
  bool result = macd[period][CURR] < macd_signal[period][CURR] - gap; // MACD falls below the signal line.
  if ((open_method &   1) != 0) result = result && macd[period][FAR] > macd_signal[period][FAR];
  if ((open_method &   2) != 0) result = result && macd[period][CURR] <= 0;
  if ((open_method &   4) != 0) result = result && macd[period][PREV] > 0;
  if ((open_method &   8) != 0) result = result && ma_fast[period][CURR] < ma_fast[period][PREV];
  if ((open_method &  16) != 0) result = result && ma_fast[period][CURR] < ma_medium[period][CURR];
  return result;
}

/*
 * Check if Alligator indicator is on buy.
 *
 * @param
 *   period (int) - period to check for
 *   open_method (int) - open method to use by using bitwise AND operation
 *   open_level (double) - open level to consider the signal
 */
bool Alligator_On_Buy(int period = M1, int open_method = 0, double open_level = 0) {
  // [x][0] - The Blue line (Alligator's Jaw), [x][1] - The Red Line (Alligator's Teeth), [x][2] - The Green Line (Alligator's Lips)
  double gap = open_level * pip_size;
  bool result = (
    alligator[period][CURR][LIPS] > alligator[period][CURR][TEETH] + gap && // Check if Lips are above Teeth ...
    alligator[period][CURR][LIPS] > alligator[period][CURR][JAW] + gap && // ... Lips are above Jaw ...
    alligator[period][CURR][TEETH] > alligator[period][CURR][JAW] + gap // ... Teeth are above Jaw ...
    );
  if ((open_method &   1) != 0) result = result && alligator[period][PREV][LIPS] > alligator[period][PREV][TEETH]; // Check if previous Lips were above Teeth.
  if ((open_method &   2) != 0) result = result && alligator[period][PREV][LIPS] > alligator[period][PREV][JAW]; // Check if previous Lips were above Jaw.
  if ((open_method &   4) != 0) result = result && alligator[period][PREV][TEETH] > alligator[period][PREV][JAW]; // Check if previous Teeth were above Jaw.
  if ((open_method &   8) != 0) result = result && alligator[period][CURR][LIPS] < alligator[period][PREV][LIPS]; // Check if Lips decreased since last bar.
  if ((open_method &  16) != 0) result = result && alligator[period][CURR][LIPS] - alligator[period][PREV][TEETH] > alligator[period][PREV][TEETH] - alligator[period][PREV][JAW];
  if ((open_method &  32) != 0) result = result && (
    alligator[period][FAR][LIPS] < alligator[period][FAR][TEETH] || // Check if Lips are below Teeth and ...
    alligator[period][FAR][LIPS] < alligator[period][FAR][JAW] || // ... Lips are below Jaw and ...
    alligator[period][FAR][TEETH] < alligator[period][FAR][JAW] // ... Teeth are below Jaw ...
    );
  return result;
}

/*
 * Check if Alligator indicator is on sell.
 *
 * @param
 *   period (int) - period to check for
 *   open_method (int) - open method to use by using bitwise AND operation
 *   open_level (double) - open level to consider the signal
 */
bool Alligator_On_Sell(int period = M1, int open_method = 0, double open_level = 0) {
  // [x][JAW] - The Blue line (Alligator's Jaw), [x][TEETH] - The Red Line (Alligator's [TEETH]), [x][LIPS] - The Green Line (Alligator's [LIPS])
  double gap = open_level * pip_size;
  bool result = (
    alligator[period][CURR][LIPS] + gap < alligator[period][CURR][TEETH] && // Check if Lips are below Teeth and ...
    alligator[period][CURR][LIPS] + gap < alligator[period][CURR][JAW] && // ... Lips are below Jaw and ...
    alligator[period][CURR][TEETH] + gap < alligator[period][CURR][JAW] // ... Teeth are below Jaw ...
    );
  if ((open_method &   1) != 0) result = result && alligator[period][PREV][LIPS] < alligator[period][PREV][TEETH]; // Check if previous Lips were below Teeth.
  if ((open_method &   2) != 0) result = result && alligator[period][PREV][LIPS] < alligator[period][PREV][JAW]; // Previous Lips were below Jaw.
  if ((open_method &   4) != 0) result = result && alligator[period][PREV][TEETH] < alligator[period][PREV][JAW]; // Previous Teeth were below Jaw.
  if ((open_method &   8) != 0) result = result && alligator[period][CURR][LIPS] > alligator[period][PREV][LIPS]; // Check if Lips increased since last bar.
  if ((open_method &  16) != 0) result = result && alligator[period][PREV][TEETH] - alligator[period][CURR][LIPS] > alligator[period][PREV][JAW] - alligator[period][PREV][TEETH];
  if ((open_method &  32) != 0) result = result && (
    alligator[period][FAR][LIPS] > alligator[period][FAR][TEETH] || // Check if Lips are above Teeth ...
    alligator[period][FAR][LIPS] > alligator[period][FAR][JAW] || // ... Lips are above Jaw ...
    alligator[period][FAR][TEETH] > alligator[period][FAR][JAW] // ... Teeth are above Jaw ...
    );
  return result;
}

/*
 * Check if RSI indicator is on buy.
 *
 * @param
 *   period (int) - period to check for
 *   open_method (int) - open method to use by using bitwise AND operation
 *   open_level - open level to consider the signal
 */
bool RSI_On_Buy(int period = M1, int open_method = 0, int open_level = 20) {
  bool result = rsi[period][CURR] <= (50 - open_level);
  if ((open_method &   1) != 0) result = result && rsi[period][CURR] < rsi[period][PREV];
  if ((open_method &   2) != 0) result = result && rsi[period][PREV] < rsi[period][FAR];
  if ((open_method &   4) != 0) result = result && rsi[period][PREV] < (50 - open_level);
  if ((open_method &   8) != 0) result = result && rsi[period][FAR]  < (50 - open_level);
  if ((open_method &  16) != 0) result = result && rsi[period][CURR] - rsi[period][PREV] > rsi[period][PREV] - rsi[period][FAR];
  if ((open_method &  32) != 0) result = result && rsi[period][FAR] > 50;
  //if ((open_method &  32) != 0) result = result && Open[CURR] > Close[PREV];
  //if ((open_method & 128) != 0) result = result && !RSI_On_Sell(M30);
  return result;
}

/*
 * Check if RSI indicator is on sell.
 *
 * @param
 *   period (int) - period to check for
 *   open_method (int) - open method to use by using bitwise AND operation
 *   open_level - open level to consider the signal
 */
bool RSI_On_Sell(int period = M1, int open_method = 0, int open_level = 20) {
  bool result = rsi[period][CURR] >= (50 + open_level);
  if ((open_method &   1) != 0) result = result && rsi[period][CURR] > rsi[period][PREV];
  if ((open_method &   2) != 0) result = result && rsi[period][PREV] > rsi[period][FAR];
  if ((open_method &   4) != 0) result = result && rsi[period][PREV] > (50 + open_level);
  if ((open_method &   8) != 0) result = result && rsi[period][FAR]  > (50 + open_level);
  if ((open_method &  16) != 0) result = result && rsi[period][PREV] - rsi[period][CURR] > rsi[period][FAR] - rsi[period][PREV];
  if ((open_method &  32) != 0) result = result && rsi[period][FAR] < 50;
  //if ((open_method &  32) != 0) result = result && Open[CURR] < Close[PREV];
  //if ((open_method & 128) != 0) result = result && !RSI_On_Buy(M30);
  return result;
}

/*
 * Check if SAR indicator is on buy.
 *
 * @param
 *   period (int) - period to check for
 *   open_method (int) - open method to use by using bitwise AND operation
 *   open_level (double) - open level to consider the signal (in pips)
 */
bool SAR_On_Buy(int period = M1, int open_method = 0, double open_level = 0) {
  double gap = open_level * pip_size;
  bool result = sar[period][CURR] + gap < Open[CURR] || sar[period][PREV] + gap < Open[PREV];
  if ((open_method &   1) != 0) result = result && sar[period][PREV] - gap > Ask;
  if ((open_method &   2) != 0) result = result && sar[period][CURR] < sar[period][PREV];
  if ((open_method &   4) != 0) result = result && sar[period][CURR] - sar[period][PREV] <= sar[period][PREV] - sar[period][FAR];
  if ((open_method &   8) != 0) result = result && sar[period][FAR] > Ask;
  if ((open_method &  16) != 0) result = result && sar[period][CURR] <= Close[CURR];
  if ((open_method &  32) != 0) result = result && sar[period][PREV] > Close[PREV];
  if ((open_method &  64) != 0) result = result && sar[period][PREV] > Open[PREV];

  if (result) {
    // FIXME: Convert into more flexible way.
    signals[DAILY][SAR1][period][OP_BUY]++; signals[WEEKLY][SAR1][period][OP_BUY]++;
    signals[MONTHLY][SAR1][period][OP_BUY]++; signals[YEARLY][SAR1][period][OP_BUY]++;
  }
  return result;
}

/*
 * Check if SAR indicator is on sell.
 *
 * @param
 *   period (int) - period to check for
 *   open_method (int) - open method to use by using bitwise AND operation
 *   open_level (double) - open level to consider the signal (in pips)
 */
bool SAR_On_Sell(int period = M1, int open_method = 0, double open_level = 0) {
  double gap = open_level * pip_size;
  bool result = sar[period][CURR] - gap > Open[CURR] || sar[period][PREV] - gap > Open[PREV];
  if ((open_method &   1) != 0) result = result && sar[period][PREV] + gap < Ask;
  if ((open_method &   2) != 0) result = result && sar[period][CURR] > sar[period][PREV];
  if ((open_method &   4) != 0) result = result && sar[period][PREV] - sar[period][CURR] <= sar[period][FAR] - sar[period][PREV];
  if ((open_method &   8) != 0) result = result && sar[period][FAR] < Ask;
  if ((open_method &  16) != 0) result = result && sar[period][CURR] >= Close[CURR];
  if ((open_method &  32) != 0) result = result && sar[period][PREV] < Close[PREV];
  if ((open_method &  64) != 0) result = result && sar[period][PREV] < Open[PREV];

  if (result) {
    // FIXME: Convert into more flexible way.
    signals[DAILY][SAR1][period][OP_SELL]++; signals[WEEKLY][SAR1][period][OP_SELL]++;
    signals[MONTHLY][SAR1][period][OP_SELL]++; signals[YEARLY][SAR1][period][OP_SELL]++;
  }
  return result;
}

/*
 * Check if Bands indicator is on buy.
 *
 * @param
 *   period (int) - period to check for
 *   open_method (int) - open method to use by using bitwise AND operation
 */
bool Bands_On_Buy(int period = M1, int open_method = 0) {
  bool result = Low[CURR] < bands[period][CURR][MODE_LOWER] || Low[PREV] < bands[period][PREV][MODE_LOWER]; // price value was lower than the lower band
  if ((open_method &   1) != 0) result = result && Close[PREV] < bands[period][CURR][MODE_LOWER];
  if ((open_method &   2) != 0) result = result && Close[CURR] > bands[period][CURR][MODE_LOWER];
  if ((open_method &   4) != 0) result = result && (bands[period][CURR][MODE_MAIN] <= bands[period][PREV][MODE_MAIN] && bands[period][PREV][MODE_MAIN] <= bands[period][FAR][MODE_MAIN]);
  if ((open_method &   8) != 0) result = result && bands[period][CURR][MODE_MAIN] >= bands[period][PREV][MODE_MAIN];
  if ((open_method &  16) != 0) result = result && (bands[period][CURR][MODE_UPPER] >= bands[period][PREV][MODE_UPPER] || bands[period][CURR][MODE_LOWER] <= bands[period][PREV][MODE_LOWER]);
  if ((open_method &  32) != 0) result = result && (bands[period][CURR][MODE_UPPER] <= bands[period][PREV][MODE_UPPER] || bands[period][CURR][MODE_LOWER] >= bands[period][PREV][MODE_LOWER]);
  if ((open_method &  64) != 0) result = result && Ask > bands[period][CURR][MODE_LOWER];
  if ((open_method & 128) != 0) result = result && Ask < bands[period][CURR][MODE_MAIN];
  //if ((open_method & 256) != 0) result = result && !Bands_On_Sell(M30);
  return result;
}

/*
 * Check if Bands indicator is on sell.
 *
 * @param
 *   period (int) - period to check for
 *   open_method (int) - open method to use by using bitwise AND operation
 */
bool Bands_On_Sell(int period = M1, int open_method = 0) {
  bool result = High[CURR]  > bands[period][CURR][MODE_UPPER] || High[PREV] > bands[period][PREV][MODE_UPPER]; // price value was higher than the upper band
  if ((open_method &   1) != 0) result = result && Close[PREV] > bands[period][CURR][MODE_UPPER];
  if ((open_method &   2) != 0) result = result && Close[CURR] < bands[period][CURR][MODE_UPPER];
  if ((open_method &   4) != 0) result = result && (bands[period][CURR][MODE_MAIN] >= bands[period][PREV][MODE_MAIN] && bands[period][PREV][MODE_MAIN] >= bands[period][FAR][MODE_MAIN]);
  if ((open_method &   8) != 0) result = result && bands[period][CURR][MODE_MAIN] <= bands[period][PREV][MODE_MAIN];
  if ((open_method &  16) != 0) result = result && (bands[period][CURR][MODE_UPPER] >= bands[period][PREV][MODE_UPPER] || bands[period][CURR][MODE_LOWER] <= bands[period][PREV][MODE_LOWER]);
  if ((open_method &  32) != 0) result = result && (bands[period][CURR][MODE_UPPER] <= bands[period][PREV][MODE_UPPER] || bands[period][CURR][MODE_LOWER] >= bands[period][PREV][MODE_LOWER]);
  if ((open_method &  64) != 0) result = result && Ask < bands[period][CURR][MODE_UPPER];
  if ((open_method & 128) != 0) result = result && Ask > bands[period][CURR][MODE_MAIN];
  //if ((open_method & 256) != 0) result = result && !Bands_On_Buy(M30);
  return result;
}

/*
 * Check if Envelopes indicator is on buy.
 *
 * @param
 *   period (int) - period to check for
 *   open_method (int) - open method to use by using bitwise AND operation
 */
bool Envelopes_On_Buy(int period = M1, int open_method = 0) {
  bool result = Low[CURR] < envelopes[period][CURR][MODE_LOWER] || Low[PREV] < envelopes[period][CURR][MODE_LOWER]; // price low was below the lower band
  // result = result || (envelopes[period][CURR][MODE_MAIN] > envelopes[period][FAR][MODE_MAIN] && Open[CURR] > envelopes[period][CURR][MODE_UPPER]);
  if ((open_method &   1) != 0) result = result && Open[CURR] > envelopes[period][CURR][MODE_LOWER]; // FIXME
  if ((open_method &   2) != 0) result = result && envelopes[period][CURR][MODE_MAIN] < envelopes[period][PREV][MODE_MAIN];
  if ((open_method &   4) != 0) result = result && envelopes[period][CURR][MODE_LOWER] < envelopes[period][PREV][MODE_LOWER];
  if ((open_method &   8) != 0) result = result && envelopes[period][CURR][MODE_UPPER] < envelopes[period][PREV][MODE_UPPER];
  if ((open_method &  16) != 0) result = result && envelopes[period][CURR][MODE_UPPER] - envelopes[period][CURR][MODE_LOWER] > envelopes[period][PREV][MODE_UPPER] - envelopes[period][PREV][MODE_LOWER];
  if ((open_method &  32) != 0) result = result && Ask < envelopes[period][CURR][MODE_MAIN];
  if ((open_method &  64) != 0) result = result && Close[CURR] < envelopes[period][CURR][MODE_UPPER];
  //if ((open_method & 128) != 0) result = result && Ask > Close[PREV];
  return result;
}

/*
 * Check if Envelopes indicator is on sell.
 *
 * @param
 *   period (int) - period to check for
 *   open_method (int) - open method to use by using bitwise AND operation
 */
bool Envelopes_On_Sell(int period = M1, int open_method = 0) {
  bool result = High[CURR] > envelopes[period][CURR][MODE_UPPER] || High[PREV] > envelopes[period][CURR][MODE_UPPER]; // price high was above the upper band
  // result = result || (envelopes[period][CURR][MODE_MAIN] < envelopes[period][FAR][MODE_MAIN] && Open[CURR] < envelopes[period][CURR][MODE_LOWER]);
  if ((open_method &   1) != 0) result = result && Open[CURR] < envelopes[period][CURR][MODE_UPPER]; // FIXME
  if ((open_method &   2) != 0) result = result && envelopes[period][CURR][MODE_MAIN] > envelopes[period][PREV][MODE_MAIN];
  if ((open_method &   4) != 0) result = result && envelopes[period][CURR][MODE_LOWER] > envelopes[period][PREV][MODE_LOWER];
  if ((open_method &   8) != 0) result = result && envelopes[period][CURR][MODE_UPPER] > envelopes[period][PREV][MODE_UPPER];
  if ((open_method &  16) != 0) result = result && envelopes[period][CURR][MODE_UPPER] - envelopes[period][CURR][MODE_LOWER] > envelopes[period][PREV][MODE_UPPER] - envelopes[period][PREV][MODE_LOWER];
  if ((open_method &  32) != 0) result = result && Ask > envelopes[period][CURR][MODE_MAIN];
  if ((open_method &  64) != 0) result = result && Close[CURR] > envelopes[period][CURR][MODE_UPPER];
  //if ((open_method & 128) != 0) result = result && Ask < Close[PREV];
  return result;
}

/*
 * Check if WPR indicator is on buy.
 *
 * @param
 *   period (int) - period to check for
 *   open_method (int) - open method to use by using bitwise AND operation
 *   open_level (double) - open level to consider the signal
 */
bool WPR_On_Buy(int period = M1, int open_method = 0, int open_level = 30) {
  bool result = wpr[period][CURR] > 50 + open_level;
  if ((open_method &   1) != 0) result = result && wpr[period][CURR] < wpr[period][PREV];
  if ((open_method &   2) != 0) result = result && wpr[period][PREV] < wpr[period][FAR];
  if ((open_method &   4) != 0) result = result && wpr[period][PREV] > 50 + open_level;
  if ((open_method &   8) != 0) result = result && wpr[period][FAR]  > 50 + open_level;
  if ((open_method &  16) != 0) result = result && wpr[period][PREV] - wpr[period][CURR] > wpr[period][FAR] - wpr[period][PREV];
  if ((open_method &  32) != 0) result = result && wpr[period][PREV] > 50 + open_level + open_level / 2;
  return result;
}

/*
 * Check if WPR indicator is on sell.
 *
 * @param
 *   period (int) - period to check for
 *   open_method (int) - open method to use by using bitwise AND operation
 *   open_level (int) - open level to consider the signal
 */
bool WPR_On_Sell(int period = M1, int open_method = 0, int open_level = 30) {
  bool result = wpr[period][CURR] < 50 - open_level;
  if ((open_method &   1) != 0) result = result && wpr[period][CURR] > wpr[period][PREV];
  if ((open_method &   2) != 0) result = result && wpr[period][PREV] > wpr[period][FAR];
  if ((open_method &   4) != 0) result = result && wpr[period][PREV] < 50 - open_level;
  if ((open_method &   8) != 0) result = result && wpr[period][FAR]  < 50 - open_level;
  if ((open_method &  16) != 0) result = result && wpr[period][CURR] - wpr[period][PREV] > wpr[period][PREV] - wpr[period][FAR];
  if ((open_method &  32) != 0) result = result && wpr[period][PREV] > 50 - open_level - open_level / 2;
  return result;
}

/*
 * Check if DeMarker indicator is on buy.
 *
 * @param
 *   period (int) - period to check for
 *   open_method (int) - open method to use by using bitwise AND operation
 *   open_level (double) - open level to consider the signal
 */
bool DeMarker_On_Buy(int period = M1, int open_method = 0, double open_level = 0.0) {
  bool result = demarker[period][CURR] < 0.5 - open_level;
  if ((open_method &   1) != 0) result = result && demarker[period][PREV] < 0.5 - open_level;
  if ((open_method &   2) != 0) result = result && demarker[period][FAR] < 0.5 - open_level;
  if ((open_method &   4) != 0) result = result && demarker[period][CURR] < demarker[period][PREV];
  if ((open_method &   8) != 0) result = result && demarker[period][PREV] < demarker[period][FAR];
  if ((open_method &  16) != 0) result = result && demarker[period][PREV] < 0.5 - open_level - open_level/2;
  return result;
}

/*
 * Check if DeMarker indicator is on sell.
 *
 * @param
 *   period (int) - period to check for
 *   open_method (int) - open method to use by using bitwise AND operation
 *   open_level (double) - open level to consider the signal
 */
bool DeMarker_On_Sell(int period = M1, int open_method = 0, double open_level = 0.0) {
  bool result = demarker[period][CURR] > 0.5 + open_level;
  if ((open_method &   1) != 0) result = result && demarker[period][PREV] > 0.5 + open_level;
  if ((open_method &   2) != 0) result = result && demarker[period][FAR] > 0.5 + open_level;
  if ((open_method &   4) != 0) result = result && demarker[period][CURR] > demarker[period][PREV];
  if ((open_method &   8) != 0) result = result && demarker[period][PREV] > demarker[period][FAR];
  if ((open_method &  16) != 0) result = result && demarker[period][PREV] > 0.5 + open_level + open_level/2;
  return result;
}

/*
 * Check if Fractals indicator is on buy.
 * @param
 *   period (int) - period to check for
 *   open_method (int) - open method to use by using bitwise AND operation
 */
bool Fractals_On_Buy(int period = M1, int open_method = 0) {
  bool result = fractals[period][CURR][MODE_LOWER] != 0.0 || fractals[period][PREV][MODE_LOWER] != 0.0 || fractals[period][FAR][MODE_LOWER] != 0.0;
  if ((open_method &   1) != 0) result = result && Open[CURR] > Close[CURR];
  if ((open_method &   2) != 0) result = result && !Fractals_On_Sell(period);
  if ((open_method &   4) != 0) result = result && Fractals_On_Buy(MathMin(period + 1, M30));
  if ((open_method &   8) != 0) result = result && Fractals_On_Buy(M30);
  if ((open_method &  16) != 0) result = result && fractals[period][FAR][MODE_LOWER] != 0.0;
  if ((open_method &  32) != 0) result = result && !Fractals_On_Sell(M30);
  return result;
}

/*
 * Check if Fractals indicator is on sell.
 * @param
 *   period (int) - period to check for
 *   open_method (int) - open method to use by using bitwise AND operation
 */
bool Fractals_On_Sell(int period = M1, int open_method = 0) {
  bool result = fractals[period][CURR][MODE_UPPER] != 0.0 || fractals[period][PREV][MODE_UPPER] != 0.0 || fractals[period][FAR][MODE_UPPER] != 0.0;
  if ((open_method &   1) != 0) result = result && Open[CURR] < Close[CURR];
  if ((open_method &   2) != 0) result = result && !Fractals_On_Buy(period);
  if ((open_method &   4) != 0) result = result && Fractals_On_Sell(MathMin(period + 1, M30));
  if ((open_method &   8) != 0) result = result && Fractals_On_Sell(M30);
  if ((open_method &  16) != 0) result = result && fractals[period][FAR][MODE_UPPER] != 0.0;
  if ((open_method &  32) != 0) result = result && !Fractals_On_Buy(M30);
  return result;
}

/*
 * Return plain text of array values separated by the delimiter.
 *
 * @param
 *   double arr[] - array to look for the values
 *   string sep - delimiter to separate array values
 */
string GetArrayValues(double& arr[], string sep = ", ") {
  string result = "";
  for (int i = 0; i < ArraySize(arr); i++) {
    result = result + i + ":" + arr[i] + sep;
  }
  return StringSubstr(result, 0, StringLen(result) - StringLen(sep)); // Return text without last separator.
}

/*
 * Check for market condition.
 *
 * @param
 *   cmd (int) - trade command
 *   period (int) - period to use
 *   condition (int) - condition to check by using bitwise AND operation
 *   default_value (bool) - default value to set, if FALSE - return the opposite
 */
bool CheckMarketCondition1(int cmd, int period = M1, int condition = 0, bool default_value = TRUE) {
  bool result = TRUE;
  RefreshRates(); // ?
  if ((condition &   1) != 0) result = result && ((cmd == OP_BUY && Open[CURR] > Close[PREV]) || (cmd == OP_SELL && Open[CURR] < Close[PREV]));
  if ((condition &   2) != 0) result = result && ((cmd == OP_BUY && sar[period][CURR] < Open[0]) || (cmd == OP_SELL && sar[period][CURR] > Open[0]));
  if ((condition &   4) != 0) result = result && ((cmd == OP_BUY && rsi[period][CURR] < 50) || (cmd == OP_SELL && rsi[period][CURR] > 50));
  if ((condition &   8) != 0) result = result && ((cmd == OP_BUY && Ask > ma_slow[period][CURR]) || (cmd == OP_SELL && Ask < ma_slow[period][CURR]));
  //if ((condition &   8) != 0) result = result && ((cmd == OP_BUY && ma_slow[period][CURR] > ma_slow[period][PREV]) || (cmd == OP_SELL && ma_slow[period][CURR] < ma_slow[period][PREV]));
  if ((condition &  16) != 0) result = result && ((cmd == OP_BUY && Ask < Open[CURR]) || (cmd == OP_SELL && Ask > Open[CURR]));
  if ((condition &  32) != 0) result = result && ((cmd == OP_BUY && Open[CURR] < bands[period][CURR][MODE_MAIN]) || (cmd == OP_SELL && Open[CURR] > bands[period][CURR][MODE_MAIN]));
  if ((condition &  64) != 0) result = result && ((cmd == OP_BUY && Open[CURR] < envelopes[period][CURR][MODE_MAIN]) || (cmd == OP_SELL && Open[CURR] > envelopes[period][CURR][MODE_MAIN]));
  if ((condition & 128) != 0) result = result && ((cmd == OP_BUY && demarker[period][CURR] < 0.5) || (cmd == OP_SELL && demarker[period][CURR] > 0.5));
  if ((condition & 256) != 0) result = result && ((cmd == OP_BUY && wpr[period][CURR] > 50) || (cmd == OP_SELL && wpr[period][CURR] < 50));
  if ((condition & 512) != 0) result = result && cmd == CheckTrend(TrendMethod);
  if (!default_value) result = !result;
  return result;
}

/*
 * Check for market event.
 *
 * @param
 *   cmd (int) - trade command
 *   period (int) - period to use
 *   condition (int) - condition to check by using bitwise AND operation
 *   default_value (bool) - default value to set, if FALSE - return the opposite
 */
bool CheckMarketEvent(int cmd, int period = M1, int condition = 0, int open_method = 0) {
  bool result = FALSE;
  switch (condition) {
    case C_MA_BUY_SELL:
      if (cmd == OP_BUY)  result = MA_On_Buy(period, info[MA30][OPEN_METHOD], MA_OpenLevel);
      if (cmd == OP_SELL) result = MA_On_Sell(period, info[MA30][OPEN_METHOD], MA_OpenLevel);
      break;
    case C_MACD_BUY_SELL:
      if (cmd == OP_BUY)  result = MACD_On_Buy(period, info[MACD30][OPEN_METHOD], MACD_OpenLevel);
      if (cmd == OP_SELL) result = MACD_On_Sell(period, info[MACD30][OPEN_METHOD], MACD_OpenLevel);
      break;
    case C_ALLIGATOR_BUY_SELL:
      if (cmd == OP_BUY)  result = Alligator_On_Buy(period, info[ALLIGATOR30][OPEN_METHOD], Alligator_OpenLevel);
      if (cmd == OP_SELL) result = Alligator_On_Sell(period, info[ALLIGATOR30][OPEN_METHOD], Alligator_OpenLevel);
      break;
    case C_RSI_BUY_SELL:
      if (cmd == OP_BUY)  result = RSI_On_Buy(period, info[RSI30][OPEN_METHOD], RSI_OpenLevel);
      if (cmd == OP_SELL) result = RSI_On_Sell(period, info[RSI30][OPEN_METHOD], RSI_OpenLevel);
      break;
    case C_SAR_BUY_SELL:
      if (cmd == OP_BUY)  result = SAR_On_Buy(period, info[SAR30][OPEN_METHOD], SAR_OpenLevel);
      if (cmd == OP_SELL) result = SAR_On_Sell(period, info[SAR30][OPEN_METHOD], SAR_OpenLevel);
      break;
    case C_BANDS_BUY_SELL:
      if (cmd == OP_BUY)  result = Bands_On_Buy(period, info[BANDS30][OPEN_METHOD]);
      if (cmd == OP_SELL) result = Bands_On_Sell(period, info[BANDS30][OPEN_METHOD]);
      break;
    case C_ENVELOPES_BUY_SELL:
      if (cmd == OP_BUY)  result = Envelopes_On_Buy(period, info[ENVELOPES30][OPEN_METHOD]);
      if (cmd == OP_SELL) result = Envelopes_On_Sell(period, info[ENVELOPES30][OPEN_METHOD]);
      break;
    case C_DEMARKER_BUY_SELL:
      if (cmd == OP_BUY)  result = DeMarker_On_Buy(period, info[DEMARKER30][OPEN_METHOD], DeMarker_OpenLevel);
      if (cmd == OP_SELL) result = DeMarker_On_Sell(period, info[DEMARKER30][OPEN_METHOD], DeMarker_OpenLevel);
      break;
    case C_WPR_BUY_SELL:
      if (cmd == OP_BUY)  result = WPR_On_Buy(period, info[WPR30][OPEN_METHOD], WPR_OpenLevel);
      if (cmd == OP_SELL) result = WPR_On_Sell(period, info[WPR30][OPEN_METHOD], WPR_OpenLevel);
      break;
    case C_FRACTALS_BUY_SELL:
      if (cmd == OP_BUY)  result = Fractals_On_Buy(period, info[FRACTALS30][OPEN_METHOD]);
      if (cmd == OP_SELL) result = Fractals_On_Sell(period, info[FRACTALS30][OPEN_METHOD]);
      break;
    case C_CUSTOM1_BUY_SELL:
    case C_CUSTOM2_BUY_SELL:
    case C_CUSTOM3_BUY_SELL:
      if (condition == C_CUSTOM1_BUY_SELL) condition = CloseConditionCustom1Method;
      if (condition == C_CUSTOM2_BUY_SELL) condition = CloseConditionCustom2Method;
      if (condition == C_CUSTOM3_BUY_SELL) condition = CloseConditionCustom3Method;
      result = FALSE;
      if ((condition &   1) != 0) result |= CheckMarketEvent(cmd, period, C_MA_BUY_SELL);
      if ((condition &   2) != 0) result |= CheckMarketEvent(cmd, period, C_MACD_BUY_SELL);
      if ((condition &   4) != 0) result |= CheckMarketEvent(cmd, period, C_ALLIGATOR_BUY_SELL);
      if ((condition &   8) != 0) result |= CheckMarketEvent(cmd, period, C_RSI_BUY_SELL);
      if ((condition &  16) != 0) result |= CheckMarketEvent(cmd, period, C_SAR_BUY_SELL);
      if ((condition &  32) != 0) result |= CheckMarketEvent(cmd, period, C_BANDS_BUY_SELL);
      if ((condition &  64) != 0) result |= CheckMarketEvent(cmd, period, C_ENVELOPES_BUY_SELL);
      if ((condition & 128) != 0) result |= CheckMarketEvent(cmd, period, C_DEMARKER_BUY_SELL);
      if ((condition & 256) != 0) result |= CheckMarketEvent(cmd, period, C_WPR_BUY_SELL);
      if ((condition & 512) != 0) result |= CheckMarketEvent(cmd, period, C_FRACTALS_BUY_SELL);
      Message("Condition: " + condition + ", result: " + result);
      break;
    case C_CUSTOM4_MARKET_COND:
    case C_CUSTOM5_MARKET_COND:
    case C_CUSTOM6_MARKET_COND:
      if (condition == C_CUSTOM4_MARKET_COND) condition = CloseConditionCustom4Method;
      if (condition == C_CUSTOM5_MARKET_COND) condition = CloseConditionCustom5Method;
      if (condition == C_CUSTOM6_MARKET_COND) condition = CloseConditionCustom6Method;
      if (cmd == OP_BUY)  result = CheckMarketCondition1(OP_SELL, period, condition);
      if (cmd == OP_SELL) result = CheckMarketCondition1(OP_BUY, period, condition);
    break;
    case C_EVENT_NONE:
    default:
      result = FALSE;
  }
  return result;
}

/*
 * Check for the trend.
 *
 * @param
 *   method (int) - condition to check by using bitwise AND operation
 * @return
 *   return TRUE if trend is valid for given trade command
 */
bool CheckTrend(int method) {
  // TODO: Validate if works.
  int bull = 0, bear = 0;

  if ((method &   1) != 0)  {
    if (iOpen(NULL, PERIOD_MN1, CURR) > iClose(NULL, PERIOD_MN1, PREV)) bull++;
    if (iOpen(NULL, PERIOD_MN1, CURR) < iClose(NULL, PERIOD_MN1, PREV)) bear++;
  }
  if ((method &   2) != 0)  {
    if (iOpen(NULL, PERIOD_W1, CURR) > iClose(NULL, PERIOD_W1, PREV)) bull++;
    if (iOpen(NULL, PERIOD_W1, CURR) < iClose(NULL, PERIOD_W1, PREV)) bear++;
  }
  if ((method &   4) != 0)  {
    if (iOpen(NULL, PERIOD_D1, CURR) > iClose(NULL, PERIOD_D1, PREV)) bull++;
    if (iOpen(NULL, PERIOD_D1, CURR) < iClose(NULL, PERIOD_D1, PREV)) bear++;
  }
  if ((method &   8) != 0)  {
    if (iOpen(NULL, PERIOD_H4, CURR) > iClose(NULL, PERIOD_H4, PREV)) bull++;
    if (iOpen(NULL, PERIOD_H4, CURR) < iClose(NULL, PERIOD_H4, PREV)) bear++;
  }
  if ((method &   16) != 0)  {
    if (iOpen(NULL, PERIOD_H1, CURR) > iClose(NULL, PERIOD_H1, PREV)) bull++;
    if (iOpen(NULL, PERIOD_H1, CURR) < iClose(NULL, PERIOD_H1, PREV)) bear++;
  }
  if ((method &   32) != 0)  {
    if (iOpen(NULL, PERIOD_M30, CURR) > iClose(NULL, PERIOD_M30, PREV)) bull++;
    if (iOpen(NULL, PERIOD_M30, CURR) < iClose(NULL, PERIOD_M30, PREV)) bear++;
  }
  if ((method &   64) != 0)  {
    if (iOpen(NULL, PERIOD_M15, CURR) > iClose(NULL, PERIOD_M15, PREV)) bull++;
    if (iOpen(NULL, PERIOD_M15, CURR) < iClose(NULL, PERIOD_M15, PREV)) bear++;
  }
  if ((method &  128) != 0)  {
    if (iOpen(NULL, PERIOD_M5, CURR) > iClose(NULL, PERIOD_M5, PREV)) bull++;
    if (iOpen(NULL, PERIOD_M5, CURR) < iClose(NULL, PERIOD_M5, PREV)) bear++;
  }
  //if (iOpen(NULL, PERIOD_H12, CURR) > iClose(NULL, PERIOD_H12, PREV)) bull++;
  //if (iOpen(NULL, PERIOD_H12, CURR) < iClose(NULL, PERIOD_H12, PREV)) bear++;
  //if (iOpen(NULL, PERIOD_H8, CURR) > iClose(NULL, PERIOD_H8, PREV)) bull++;
  //if (iOpen(NULL, PERIOD_H8, CURR) < iClose(NULL, PERIOD_H8, PREV)) bear++;
  //if (iOpen(NULL, PERIOD_H6, CURR) > iClose(NULL, PERIOD_H6, PREV)) bull++;
  //if (iOpen(NULL, PERIOD_H6, CURR) < iClose(NULL, PERIOD_H6, PREV)) bear++;
  //if (iOpen(NULL, PERIOD_H2, CURR) > iClose(NULL, PERIOD_H2, PREV)) bull++;
  //if (iOpen(NULL, PERIOD_H2, CURR) < iClose(NULL, PERIOD_H2, PREV)) bear++;

  if (bull > bear) return OP_BUY;
  else if (bull < bear) return OP_SELL;
  else return EMPTY;
}

/*
 * Check if order match has minimum gap in pips configured by MinPipGap parameter.
 *
 * @param
 *   int strategy_type - type of order strategy to check for (see: ENUM STRATEGY TYPE)
 */
bool CheckMinPipGap(int strategy_type) {
  int diff;
  for (int order = 0; order < OrdersTotal(); order++) {
    if (OrderSelect(order, SELECT_BY_POS, MODE_TRADES)) {
       if (OrderMagicNumber() == MagicNumber + strategy_type && OrderSymbol() == Symbol()) {
         diff = MathAbs((OrderOpenPrice() - GetOpenPrice()) / pip_size);
         // if (VerboseTrace) Print("Ticket: ", OrderTicket(), ", Order: ", OrderType(), ", Gap: ", diff);
         if (diff < MinPipGap) {
           return FALSE;
         }
       }
    } else if (VerboseDebug) {
        Print(__FUNCTION__ + "(): Error: Strategy type = " + strategy_type + ", pos: " + order + ", message: ", GetErrorText(err_code));
    }
  }
  return TRUE;
}

// Validate value for trailing stop.
bool ValidTrailingValue(double value, int cmd, int loss_or_profit = -1, bool existing = FALSE) {
  double delta = GetMarketGap(); // Calculate minimum market gap.
  double price = GetOpenPrice();
  bool valid = (
          (cmd == OP_BUY  && loss_or_profit < 0 && price - value > delta)
       || (cmd == OP_BUY  && loss_or_profit > 0 && value - price > delta)
       || (cmd == OP_SELL && loss_or_profit < 0 && value - price > delta)
       || (cmd == OP_SELL && loss_or_profit > 0 && price - value > delta)
       );
  valid &= (value >= 0); // Also must be zero or above.
  if (!valid && VerboseTrace) Print(__FUNCTION__ + "(): Trailing value not valid: " + value);
  return valid;
}

void UpdateTrailingStops() {
   bool result; // Check result of executed orders.
   double new_trailing_stop, new_profit_take;
   int order_type;

   // Check if bar time has been changed since last time.
   /*
   int bar_time = iTime(NULL, PERIOD_M1, 0);
   if (bar_time == last_trail_update) {
     return;
   } else {
     last_trail_update = bar_time;
   }*/

   for (int i = 0; i < OrdersTotal(); i++) {
     if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if (OrderSymbol() == Symbol() && CheckOurMagicNumber()) {
        order_type = OrderMagicNumber() - MagicNumber;
        // order_stop_loss = NormalizeDouble(If(OpTypeValue(OrderType()) > 0 || OrderStopLoss() != 0.0, OrderStopLoss(), 999999), PipDigits);

        // FIXME
        if (MinimalizeLosses && GetOrderProfit() > GetMinStopLevel()) {
          if ((OrderType() == OP_BUY && OrderStopLoss() < Bid) ||
             (OrderType() == OP_SELL && OrderStopLoss() > Ask)) {
            result = OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - OrderCommission() * Point, OrderTakeProfit(), 0, GetOrderColor());
            if (!result && err_code > 1) {
             if (VerboseErrors) Print(__FUNCTION__, "(): Error: OrderModify(): [MinimalizeLosses] ", ErrorDescription(err_code));
               if (VerboseDebug)
                 Print(__FUNCTION__ + "(): Error: OrderModify(", OrderTicket(), ", ", OrderOpenPrice(), ", ", OrderOpenPrice() - OrderCommission() * Point, ", ", OrderTakeProfit(), ", ", 0, ", ", GetOrderColor(), "); ", "Ask/Bid: ", Ask, "/", Bid);
            } else {
              if (VerboseTrace) Print(__FUNCTION__ + "(): MinimalizeLosses: ", GetOrderTextDetails());
            }
          }
        }

        new_trailing_stop = NormalizeDouble(GetTrailingValue(OrderType(), -1, order_type, OrderStopLoss(), TRUE), Digits);
        new_profit_take   = NormalizeDouble(GetTrailingValue(OrderType(), +1, order_type, OrderTakeProfit(), TRUE), Digits);
        //if (MathAbs(OrderStopLoss() - new_trailing_stop) >= pip_size || MathAbs(OrderTakeProfit() - new_profit_take) >= pip_size) { // Perform update on pip change.
        if (new_trailing_stop != OrderStopLoss() || new_profit_take != OrderTakeProfit()) { // Perform update on change only.
           result = OrderModify(OrderTicket(), OrderOpenPrice(), new_trailing_stop, new_profit_take, 0, GetOrderColor());
           if (!result) {
             err_code = GetLastError();
             if (err_code > 1) {
               if (VerboseErrors) Print(__FUNCTION__, "(): Error: OrderModify(): ", ErrorDescription(err_code));
               if (VerboseDebug)
                 Print(__FUNCTION__ + "(): Error: OrderModify(", OrderTicket(), ", ", OrderOpenPrice(), ", ", new_trailing_stop, ", ", new_profit_take, ", ", 0, ", ", GetOrderColor(), "); ", "Ask/Bid: ", Ask, "/", Bid);
             }
           } else {
             // if (VerboseTrace) Print("UpdateTrailingStops(): OrderModify(): ", GetOrderTextDetails());
           }
        }
     }
  }
}

/*
 * Calculate the new trailing stop. If calculation fails, use the previous one.
 *
 * @params:
 *   cmd (int)
 *    Command for trade operation.
 *   loss_or_profit (int)
 *    Set -1 to calculate trailing stop or +1 for profit take.
 *   order_type (int)
 *    Value of strategy type. See: ENUM_STRATEGY_TYPE
 *   previous (double)
 *    Previous trailing value.
 *   existing (bool)
 *    Set to TRUE if the calculation is for particular existing order, so additional local variables are available.
 */
double GetTrailingValue(int cmd, int loss_or_profit = -1, int order_type = EMPTY, double previous = 0, bool existing = FALSE) {
   double new_value = 0;
   double delta = GetMarketGap(), diff;
   int extra_trail = 0;
   if (existing && TrailingStopAddPerMinute > 0 && OrderOpenTime() > 0) {
     int min_elapsed = (TimeCurrent() - OrderOpenTime()) / 60;
     extra_trail =+ min_elapsed * TrailingStopAddPerMinute;
   }
   int factor = If(OpTypeValue(cmd) == loss_or_profit, +1, -1);
   double trail = (TrailingStop + extra_trail) * pip_size;
   double default_trail = If(cmd == OP_BUY, Bid, Ask) + trail * factor;
   int method = GetTrailingMethod(order_type, loss_or_profit);
   int timeframe = If(order_type >= 0, info[order_type][TIMEFRAME], M1);

/*
  MA1+MA5+MA15+MA30 backtest log (auto,ts:40,tp:30,gap:10) [2015.01.01-2015.06.30 based on MT4 FXCM backtest data, 9,5mln ticks, quality 25%]:

  Stop loss (d: GBP10k, lot size: 0.1, spread: 2, no boosting, no actions):
    5599.51 3952  1.20  1.42  2256.22 13.95% MA_TrailingStopMethod=1
    11218.40  9992  1.52  1.12  1929.00 10.02% MA_TrailingStopMethod=2
    10159.11  8678  1.45  1.17  2093.62 10.66% MA_TrailingStopMethod=3
    9749.82 6400  1.42  1.52  1998.58 12.64% MA_TrailingStopMethod=4
    9439.25 5719  1.38  1.65  2181.95 13.17% MA_TrailingStopMethod=5
    9114.61 4646  1.32  1.96  2668.78 13.98% MA_TrailingStopMethod=6
    10633.63  4069  1.35  2.61  2375.31 15.31% MA_TrailingStopMethod=7
    9842.04 4622  1.35  2.13  2334.60 14.56% MA_TrailingStopMethod=8
    202.80  8027  1.01  0.03  1457.60 12.60% MA_TrailingStopMethod=9
    1225.75 6081  1.06  0.20  1618.59 12.70% MA_TrailingStopMethod=10
    16913.77  3453  1.52  4.90  3688.36 20.00% MA_TrailingStopMethod=11
    10044.82  3781  1.34  2.66  2853.85 13.77% MA_TrailingStopMethod=12
    11821.83  3727  1.39  3.17  2961.41 13.05% MA_TrailingStopMethod=13
    791.21  6933  1.04  0.11  1575.28 12.84% MA_TrailingStopMethod=14
    1974.87 6089  1.09  0.32  1779.42 13.08% MA_TrailingStopMethod=15
    16913.77  3453  1.52  4.90  3688.36 20.00% MA_TrailingStopMethod=16
    12038.54  3726  1.40  3.23  3046.36 13.29% MA_TrailingStopMethod=17
    12932.29  3691  1.43  3.50  3210.92 13.56% MA_TrailingStopMethod=18
    3963.23 6366  1.18  0.62  1926.07 14.04% MA_TrailingStopMethod=19
    4846.24 6165  1.21  0.79  1855.02 11.98% MA_TrailingStopMethod=20
    13348.87  3651  1.44  3.66  3015.02 13.03% MA_TrailingStopMethod=21
    16913.77  3453  1.52  4.90  3688.36 20.00% MA_TrailingStopMethod=22
    2128.81 5515  1.10  0.39  1796.71 13.10% MA_TrailingStopMethod=23
    4391.11 4679  1.17  0.94  1247.45 10.56% MA_TrailingStopMethod=24
    8038.24 5097  1.29  1.58  2556.58 13.94% MA_TrailingStopMethod=25
    8016.87 5029  1.29  1.59  2510.72 13.66% MA_TrailingStopMethod=26
    6787.85 4701  1.24  1.44  2238.46 12.68% MA_TrailingStopMethod=27

  Profit take (d: GBP10k, lot size: 0.1, spread: 25, no boosting, no actions, trailing: T_MA_FMS_PEAK):
    13761.58  2845  1.36  4.84  3960.10 30.33% MA_TrailingProfitMethod=1
    10878.01  3491  1.31  3.12  4519.36 23.97% MA_TrailingProfitMethod=2
    11012.71  3503  1.31  3.14  4738.17 23.04% MA_TrailingProfitMethod=3
    12206.18  2955  1.33  4.13  3956.58 25.66% MA_TrailingProfitMethod=4
    14089.18  2889  1.37  4.88  3901.52 29.04% MA_TrailingProfitMethod=5
    13865.44  2843  1.37  4.88  3892.54 29.82% MA_TrailingProfitMethod=6
    13861.94  2841  1.36  4.88  3924.26 30.06% MA_TrailingProfitMethod=7
    13168.88  2869  1.35  4.59  4004.98 30.68% MA_TrailingProfitMethod=8
    10713.75  2902  1.28  3.69  3846.19 28.34% MA_TrailingProfitMethod=9
    13209.68  2870  1.35  4.60  3733.74 28.61% MA_TrailingProfitMethod=10
    13742.21  2839  1.36  4.84  3825.94 29.31% MA_TrailingProfitMethod=12
    13743.50  2839  1.36  4.84  3825.94 29.31% MA_TrailingProfitMethod=13
    12640.84  2894  1.33  4.37  3736.01 28.59% MA_TrailingProfitMethod=14
    12837.30  2857  1.34  4.49  3847.29 29.48% MA_TrailingProfitMethod=15
    13740.98  2839  1.36  4.84  3825.94 29.31% MA_TrailingProfitMethod=17
    13880.76  2839  1.36  4.89  3825.94 29.31% MA_TrailingProfitMethod=18
    12901.85  2871  1.34  4.49  3914.54 30.00% MA_TrailingProfitMethod=19
    13140.64  2865  1.35  4.59  3911.51 29.98% MA_TrailingProfitMethod=20
    13880.76  2839  1.36  4.89  3825.94 29.31% MA_TrailingProfitMethod=21
    13880.76  2839  1.36  4.89  3825.94 29.31% MA_TrailingProfitMethod=22
    12365.53  3238  1.35  3.82  4348.87 23.32% MA_TrailingProfitMethod=23
    11876.32  3245  1.34  3.66  4514.79 24.00% MA_TrailingProfitMethod=24
    9146.42 3492  1.26  2.62  4847.98 25.24% MA_TrailingProfitMethod=25
    9230.95 3484  1.27  2.65  4835.75 25.13% MA_TrailingProfitMethod=26
    9371.17 3416  1.27  2.74  5098.83 23.51% MA_TrailingProfitMethod=27
*/
   switch (method) {
     case T_NONE: // None
       new_value = previous;
       break;
     case T_FIXED: // Dynamic fixed.
       new_value = default_trail;
       break;
     case T_CLOSE_PREV: // TODO
       diff = MathAbs(Open[CURR] - iClose(_Symbol, timeframe, PREV));
       new_value = Open[CURR] + diff * factor;
       break;
     case T_2_BARS_PEAK: // 3
       double highest2 = GetPeakPrice(timeframe, MODE_HIGH, 2);
       double lowest2  = GetPeakPrice(timeframe, MODE_LOW, 2);
       diff = MathMax(highest2 - Open[CURR], Open[CURR] - lowest2);
       new_value = Open[CURR] + diff * factor;
       break;
     case T_5_BARS_PEAK: // 4
       double highest5 = GetPeakPrice(timeframe, MODE_HIGH, 5);
       double lowest5  = GetPeakPrice(timeframe, MODE_LOW, 5);
       diff = MathMax(highest5 - Open[CURR], Open[CURR] - lowest5);
       new_value = Open[CURR] + diff * factor;
       break;
     case T_10_BARS_PEAK: // 5
       double highest10 = GetPeakPrice(timeframe, MODE_HIGH, 10);
       double lowest10  = GetPeakPrice(timeframe, MODE_LOW, 10);
       diff = MathMax(highest10 - Open[CURR], Open[CURR] - lowest10);
       new_value = Open[CURR] + diff * factor;
       break;
     case T_50_BARS_PEAK:
       double highest50 = GetPeakPrice(timeframe, MODE_HIGH, 50);
       double lowest50  = GetPeakPrice(timeframe, MODE_LOW, 50);
       diff = MathMax(highest50 - Open[CURR], Open[CURR] - lowest50);
       new_value = Open[CURR] + diff * factor;
       break;
     case T_150_BARS_PEAK:
       double highest150 = GetPeakPrice(timeframe, MODE_HIGH, 150);
       double lowest150  = GetPeakPrice(timeframe, MODE_LOW, 150);
       diff = MathMax(highest150 - Open[CURR], Open[CURR] - lowest150);
       new_value = Open[CURR] + diff * factor;
       break;
     case T_HALF_200_BARS:
       double highest200 = GetPeakPrice(timeframe, MODE_HIGH, 200);
       double lowest200  = GetPeakPrice(timeframe, MODE_LOW, 200);
       diff = MathMax(highest200 - Open[CURR], Open[CURR] - lowest200);
       new_value = Open[CURR] + diff/2 * factor;
       break;
     case T_MA_F_PREV: // 9: MA Small (Previous). The worse so far for MA.
       diff = MathAbs(Ask - ma_fast[timeframe][PREV]);
       new_value = Ask + diff * factor;
       break;
     case T_MA_F_FAR: // 10: MA Small (Far) + trailing stop. Optimize together with: MA_Shift_Far.
       diff = MathAbs(Ask - ma_fast[timeframe][FAR]);
       new_value = Ask + diff * factor;
       break;
     /*
     case T_MA_F_LOW: // 11: Lowest/highest value of MA Fast. Optimized (SL pf: 1.39 for MA).
       diff = MathMax(HighestArrValue2(ma_fast, timeframe) - Open[CURR], Open[CURR] - LowestArrValue2(ma_fast, timeframe));
       new_value = Open[CURR] + diff * factor;
       break;
      */
     case T_MA_F_TRAIL: // 12: MA Fast (Current) + trailing stop. Works fine.
       diff = MathAbs(Ask - ma_fast[timeframe][CURR]);
       new_value = Ask + (diff + trail) * factor;
       break;
     case T_MA_F_FAR_TRAIL: // 13: MA Fast (Far) + trailing stop. Works fine (SL pf: 1.26 for MA).
       diff = MathAbs(Open[CURR] - ma_fast[timeframe][FAR]);
       new_value = Open[CURR] + (diff + trail) * factor;
       break;
     case T_MA_M: // 14: MA Medium (Current).
       diff = MathAbs(Ask - ma_medium[timeframe][CURR]);
       new_value = Ask + diff * factor;
       break;
     case T_MA_M_FAR: // 15: MA Medium (Far)
       diff = MathAbs(Ask - ma_medium[timeframe][FAR]);
       new_value = Ask + diff * factor;
       break;
     /*
     case T_MA_M_LOW: // 16: Lowest/highest value of MA Medium. Optimized (SL pf: 1.39 for MA).
       diff = MathMax(HighestArrValue2(ma_medium, timeframe) - Open[CURR], Open[CURR] - LowestArrValue2(ma_medium, timeframe));
       new_value = Open[CURR] + diff * factor;
       break;
      */
     case T_MA_M_TRAIL: // 17: MA Small (Current) + trailing stop. Works fine (SL pf: 1.26 for MA).
       diff = MathAbs(Open[CURR] - ma_medium[timeframe][CURR]);
       new_value = Open[CURR] + (diff + trail) * factor;
       break;
     case T_MA_M_FAR_TRAIL: // 18: MA Small (Far) + trailing stop. Optimized (SL pf: 1.29 for MA).
       diff = MathAbs(Open[CURR] - ma_medium[timeframe][FAR]);
       new_value = Open[CURR] + (diff + trail) * factor;
       break;
     case T_MA_S: // 19: MA Slow (Current).
       diff = MathAbs(Ask - ma_slow[timeframe][CURR]);
       // new_value = ma_slow[timeframe][CURR];
       new_value = Ask + diff * factor;
       break;
     case T_MA_S_FAR: // 20: MA Slow (Far).
       diff = MathAbs(Ask - ma_slow[timeframe][FAR]);
       // new_value = ma_slow[timeframe][FAR];
       new_value = Ask + diff * factor;
       break;
     case T_MA_S_TRAIL: // 21: MA Slow (Current) + trailing stop. Optimized (SL pf: 1.29 for MA, PT pf: 1.23 for MA).
       diff = MathAbs(Open[CURR] - ma_slow[timeframe][CURR]);
       new_value = Open[CURR] + (diff + trail) * factor;
       break;
     case T_MA_FMS_PEAK: // 22: Lowest/highest value of all MAs. Works fine (SL pf: 1.39 for MA, PT pf: 1.23 for MA).
       double highest_ma = MathAbs(MathMax(MathMax(HighestArrValue2(ma_fast, timeframe), HighestArrValue2(ma_medium, timeframe)), HighestArrValue2(ma_slow, timeframe)));
       double lowest_ma = MathAbs(MathMin(MathMin(LowestArrValue2(ma_fast, timeframe), LowestArrValue2(ma_medium, timeframe)), LowestArrValue2(ma_slow, timeframe)));
       diff = MathMax(MathAbs(highest_ma - Open[CURR]), MathAbs(Open[CURR] - lowest_ma));
       new_value = Open[CURR] + diff * factor;
       break;
     case T_SAR: // 23: Current SAR value. Optimized.
       new_value = sar[timeframe][CURR];
       break;
     case T_SAR_PEAK: // 24: Lowest/highest SAR value.
       new_value = If(OpTypeValue(cmd) == loss_or_profit, HighestArrValue2(sar, timeframe), LowestArrValue2(sar, timeframe));
       break;
     case T_BANDS: // 25: Current Bands value.
       new_value = If(OpTypeValue(cmd) == loss_or_profit, bands[timeframe][CURR][MODE_UPPER], bands[timeframe][CURR][MODE_LOWER]);
       break;
     case T_BANDS_PEAK: // 26: Lowest/highest Bands value.
       new_value = If(OpTypeValue(cmd) == loss_or_profit,
         MathMax(MathMax(bands[timeframe][CURR][MODE_UPPER], bands[timeframe][PREV][MODE_UPPER]), bands[timeframe][FAR][MODE_UPPER]),
         MathMin(MathMin(bands[timeframe][CURR][MODE_LOWER], bands[timeframe][PREV][MODE_LOWER]), bands[timeframe][FAR][MODE_LOWER])
         );
       break;
     case T_ENVELOPES: // 27: Current Envelopes value. // FIXME
       new_value = If(OpTypeValue(cmd) == loss_or_profit, envelopes[timeframe][CURR][MODE_UPPER], envelopes[timeframe][CURR][MODE_LOWER]);
       break;
     default:
       if (VerboseDebug) Print(__FUNCTION__ + "(): Error: Unknown trailing stop method: ", method);
   }

   if (new_value > 0) new_value += delta * factor;

   if (!ValidTrailingValue(new_value, cmd, loss_or_profit, existing)) {
     if (existing && previous == 0 && loss_or_profit == -1) previous = default_trail;
     if (VerboseTrace)
       Print(__FUNCTION__ + "(): Error: method = " + method + ", ticket = #" + If(existing, OrderTicket(), 0) + ": Invalid Trailing Value: ", new_value, ", previous: ", previous, "; ", GetOrderTextDetails(), ", delta: ", DoubleToStr(delta, PipDigits));
     // If value is invalid, fallback to the previous one.
     return previous;
   }

   if (TrailingStopOneWay && loss_or_profit < 0 && method > 0) { // If TRUE, move trailing stop only one direction.
     if (previous == 0 && method > 0) previous = default_trail;
     if (OpTypeValue(cmd) == loss_or_profit) new_value = If(new_value < previous, new_value, previous);
     else new_value = If(new_value > previous, new_value, previous);
   }
   if (TrailingProfitOneWay && loss_or_profit > 0 && method > 0) { // If TRUE, move profit take only one direction.
     if (OpTypeValue(cmd) == loss_or_profit) new_value = If(new_value > previous, new_value, previous);
     else new_value = If(new_value < previous, new_value, previous);
   }

   // if (VerboseDebug && IsVisualMode()) ShowLine("trail_stop_" + OrderTicket(), new_value, GetOrderColor());
   return NormalizeDouble(new_value, Digits);
}

// Get trailing method based on the strategy type.
int GetTrailingMethod(int order_type, int stop_or_profit) {
  int stop_method = DefaultTrailingStopMethod, profit_method = DefaultTrailingProfitMethod;
  switch (order_type) {
    case MA1:
    case MA5:
    case MA15:
    case MA30:
      if (MA_TrailingStopMethod > 0)   stop_method   = MA_TrailingStopMethod;
      if (MA_TrailingProfitMethod > 0) profit_method = MA_TrailingProfitMethod;
      break;
    case MACD1:
    case MACD5:
    case MACD15:
    case MACD30:
      if (MACD_TrailingStopMethod > 0)   stop_method   = MACD_TrailingStopMethod;
      if (MACD_TrailingProfitMethod > 0) profit_method = MACD_TrailingProfitMethod;
      break;
    case ALLIGATOR1:
    case ALLIGATOR5:
    case ALLIGATOR15:
    case ALLIGATOR30:
      if (Alligator_TrailingStopMethod > 0)   stop_method   = Alligator_TrailingStopMethod;
      if (Alligator_TrailingProfitMethod > 0) profit_method = Alligator_TrailingProfitMethod;
      break;
    case RSI1:
    case RSI5:
    case RSI15:
    case RSI30:
      if (RSI_TrailingStopMethod > 0)   stop_method   = RSI_TrailingStopMethod;
      if (RSI_TrailingProfitMethod > 0) profit_method = RSI_TrailingProfitMethod;
      break;
    case SAR1:
    case SAR5:
    case SAR15:
    case SAR30:
      if (SAR_TrailingStopMethod > 0)   stop_method   = SAR_TrailingStopMethod;
      if (SAR_TrailingProfitMethod > 0) profit_method = SAR_TrailingProfitMethod;
      break;
    case BANDS1:
    case BANDS5:
    case BANDS15:
    case BANDS30:
      if (Bands_TrailingStopMethod > 0)   stop_method   = Bands_TrailingStopMethod;
      if (Bands_TrailingProfitMethod > 0) profit_method = Bands_TrailingProfitMethod;
      break;
    case ENVELOPES1:
    case ENVELOPES5:
    case ENVELOPES15:
    case ENVELOPES30:
      if (Envelopes_TrailingStopMethod > 0)   stop_method   = Envelopes_TrailingStopMethod;
      if (Envelopes_TrailingProfitMethod > 0) profit_method = Envelopes_TrailingProfitMethod;
      break;
    case DEMARKER1:
    case DEMARKER5:
    case DEMARKER15:
    case DEMARKER30:
      if (DeMarker_TrailingStopMethod > 0)   stop_method   = DeMarker_TrailingStopMethod;
      if (DeMarker_TrailingProfitMethod > 0) profit_method = DeMarker_TrailingProfitMethod;
      break;
    case WPR1:
    case WPR5:
    case WPR15:
    case WPR30:
      if (WPR_TrailingStopMethod > 0)   stop_method   = WPR_TrailingStopMethod;
      if (WPR_TrailingProfitMethod > 0) profit_method = WPR_TrailingProfitMethod;
      break;
    case FRACTALS1:
    case FRACTALS5:
    case FRACTALS15:
    case FRACTALS30:
      if (Fractals_TrailingStopMethod > 0)   stop_method   = Fractals_TrailingStopMethod;
      if (Fractals_TrailingProfitMethod > 0) profit_method = Fractals_TrailingProfitMethod;
      break;
    default:
      if (VerboseTrace) Print(__FUNCTION__ + "(): Unknown order type: " + order_type);
  }
  return If(stop_or_profit > 0, profit_method, stop_method);
}

void ShowLine(string oname, double price, int colour = Yellow) {
    ObjectCreate(ChartID(), oname, OBJ_HLINE, 0, Time[0], price, 0, 0);
    ObjectSet(oname, OBJPROP_COLOR, colour);
    ObjectMove(oname, 0, Time[0], price);
}

/*
 * Get current open price depending on the operation type.
 * @param:
 *   op_type (int)
 */
double GetOpenPrice(int op_type = EMPTY_VALUE) {
   if (op_type == EMPTY_VALUE) op_type = OrderType();
   return If(op_type == OP_BUY, Ask, Bid);
}

/*
 * Get current close price depending on the operation type.
 * @param:
 *   op_type (int)
 */
double GetClosePrice(int op_type = EMPTY_VALUE) {
   if (op_type == EMPTY_VALUE) op_type = OrderType();
   return If(op_type == OP_BUY, Bid, Ask);
}

/*
 * Get peak price at given number of bars.
 */
double GetPeakPrice(int timeframe, int mode, int bars) {
  int ibar = -1;
  double peak_price = Open[0];
  if (mode == MODE_HIGH) ibar = iHighest(_Symbol, timeframe, MODE_HIGH, bars, CURR);
  if (mode == MODE_LOW)  ibar =  iLowest(_Symbol, timeframe, MODE_LOW,  bars, CURR);
  if (ibar == -1 && VerboseTrace) { err_code = GetLastError(); Print(__FUNCTION__ + "(): " + ErrorDescription(err_code)); return FALSE; }
  if (mode == MODE_HIGH) {
    return iHigh(_Symbol, timeframe, ibar);
  } else if (mode == MODE_LOW) {
    return iLow(_Symbol, timeframe, ibar);
  } else {
    return FALSE;
  }
}

int OpTypeValue(int op_type) {
   switch (op_type) {
      case OP_SELL:
      case OP_SELLLIMIT:
      case OP_SELLSTOP:
        return -1;
        break;
      case OP_BUY:
      case OP_BUYLIMIT:
      case OP_BUYSTOP:
        return 1;
        break;
      default:
        return FALSE;
   }
}

// Return double depending on the condition.
double If(bool condition, double on_true, double on_false) {
   // if condition is TRUE, return on_true, otherwise on_false
   if (condition) return (on_true);
   else return (on_false);
}

// Return string depending on the condition.
string IfTxt(bool condition, string on_true, string on_false) {
   // if condition is TRUE, return on_true, otherwise on_false
   if (condition) return (on_true);
   else return (on_false);
}

// Calculate open positions (in volume).
int CalculateCurrentOrders(string symbol) {
   int buys=0, sells=0;

   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if (OrderSymbol() == Symbol() && CheckOurMagicNumber()){
         if (OrderType() == OP_BUY)  buys++;
         if (OrderType() == OP_SELL) sells++;
        }
     }
   if (buys > 0) return(buys); else return(-sells); // Return orders volume
}

// Return total number of orders (based on the EA magic number)
int GetTotalOrders(bool ours = TRUE) {
   int total = 0;
   for (int order = 0; order < OrdersTotal(); order++) {
     if (OrderSelect(order, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol()) {
        if (CheckOurMagicNumber()) {
          if (ours) total++;
        } else {
          if (!ours) total++;
        }
     }
   }
   if (ours) total_orders = total; // Re-calculate global variables.
   return (total);
}

// Return total number of orders per strategy type. See: ENUM_STRATEGY_TYPE.
int GetTotalOrdersByType(int order_type) {
   open_orders[order_type] = 0;
   // ArrayFill(open_orders[order_type], 0, ArraySize(open_orders), 0); // Reset open_orders array.
   for (int order = 0; order < OrdersTotal(); order++) {
     if (OrderSelect(order, SELECT_BY_POS, MODE_TRADES)) {
       if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber + order_type) {
         open_orders[order_type]++;
       }
     }
   }
   return (open_orders[order_type]);
}

/*
 * Get total profit of opened orders by type.
 */
double GetTotalProfitByType(int cmd = EMPTY, int order_type = EMPTY) {
  double total = 0;
  for (int i = 0; i < OrdersTotal(); i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == FALSE) break;
    if (OrderSymbol() == Symbol() && CheckOurMagicNumber()) {
       if (OrderType() == cmd) total += GetOrderProfit();
       else if (OrderMagicNumber() == MagicNumber + order_type) total += GetOrderProfit();
     }
  }
  return total;
}

/*
 * Get profitable side and return trade operation type (OP_BUY/OP_SELL).
 */
bool GetProfitableSide() {
  double buys = GetTotalProfitByType(OP_BUY);
  double sells = GetTotalProfitByType(OP_SELL);
  if (buys > sells) return OP_BUY;
  if (sells > buys) return OP_SELL;
  return (EMPTY);
}

// Calculate open positions.
int CalculateOrdersByCmd(int cmd) {
  int total = 0;
  for (int i = 0; i < OrdersTotal(); i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == FALSE) break;
    if (OrderSymbol() == Symbol() && CheckOurMagicNumber()) {
       if(OrderType() == cmd) total++;
     }
  }
  return total;
}

// Calculate open positions.
double CalculateOpenLots() {
  double total_lots = 0;
   for (int i=0; i<OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == FALSE) break;
      if (OrderSymbol() == Symbol() && CheckOurMagicNumber()) {
        total_lots += OrderLots(); // This gives the total no of lots opened in current orders.
       }
   }
  return total_lots;
}

// For given magic number, check if it is ours.
bool CheckOurMagicNumber(int magic_number = EMPTY) {
  if (magic_number == EMPTY) magic_number = OrderMagicNumber();
  return (magic_number >= MagicNumber && magic_number < MagicNumber + FINAL_STRATEGY_TYPE_ENTRY);
}

// Check if it is possible to trade.
bool TradeAllowed() {
  string err;
  // Don't place multiple orders for the same bar.
  /*
  if (last_order_time == iTime(NULL, PERIOD_M1, 0)) {
    err = StringConcatenate("Not trading at the moment, as we already placed order on: ", TimeToStr(last_order_time));
    if (VerboseTrace && err != last_err) Print(__FUNCTION__ + "(): " + err);
    last_err = err;
    return (FALSE);
  }*/
  if (Bars < 100) {
    err = "Bars less than 100, not trading...";
    if (VerboseTrace && err != last_err) Print(__FUNCTION__ + "(): " + err);
    //if (PrintLogOnChart && err != last_err) Comment(__FUNCTION__ + "(): " + err);
    last_err = err;
    return (FALSE);
  }
  if (!IsTesting() && Volume[0] < MinVolumeToTrade) {
    err = "Volume too low to trade.";
    if (VerboseTrace && err != last_err) Print(__FUNCTION__ + "(): " + err);
    //if (PrintLogOnChart && err != last_err) Comment(__FUNCTION__ + "(): " + err);
    last_err = err;
    return (FALSE);
  }
  if (IsTradeContextBusy()) {
    err = "Error: Trade context is temporary busy.";
    if (VerboseErrors && err != last_err) Print(__FUNCTION__ + "(): " + err);
    //if (PrintLogOnChart && err != last_err) Comment(__FUNCTION__ + "(): " + err);
    last_err = err;
    return (FALSE);
  }
  // Check if the EA is allowed to trade and trading context is not busy, otherwise returns false.
  // OrderSend(), OrderClose(), OrderCloseBy(), OrderModify(), OrderDelete() trading functions
  //   changing the state of a trading account can be called only if trading by Expert Advisors
  //   is allowed (the "Allow live trading" checkbox is enabled in the Expert Advisor or script properties).
  if (!IsTradeAllowed()) {
    err = "Trade is not allowed at the moment, check the settings!";
    if (VerboseErrors && err != last_err) Print(__FUNCTION__ + "(): " + err);
    //if (PrintLogOnChart && err != last_err) Comment(__FUNCTION__ + "(): " + err);
    last_err = err;
    ea_active = FALSE;
    return (FALSE);
  }
  if (!IsConnected()) {
    err = "Error: Terminal is not connected!";
    if (VerboseErrors && err != last_err) Print(__FUNCTION__ + "(): " + err);
    if (PrintLogOnChart && err != last_err) Comment(__FUNCTION__ + "(): " + err);
    last_err = err;
    if (PrintLogOnChart) DisplayInfoOnChart();
    Sleep(10000);
    return (FALSE);
  }
  if (IsStopped()) {
    err = "Error: Terminal is stopping!";
    if (VerboseErrors && err != last_err) Print(__FUNCTION__ + "(): " + err);
    //if (PrintLogOnChart && err != last_err) Comment(__FUNCTION__ + "():" + err);
    last_err = err;
    ea_active = FALSE;
    return (FALSE);
  }
  if (!IsTesting() && !MarketInfo(Symbol(), MODE_TRADEALLOWED)) {
    err = "Trade is not allowed. Market is closed.";
    if (VerboseInfo && err != last_err) Print(__FUNCTION__ + "(): " + err);
    //if (PrintLogOnChart && err != last_err) Comment(__FUNCTION__ + "():" + err);
    last_err = err;
    ea_active = FALSE;
    return (FALSE);
  }
  if (!IsTesting() && !IsExpertEnabled()) {
    err = "Error: You need to enable: 'Enable Expert Advisor'/'AutoTrading'.";
    if (VerboseErrors && err != last_err) Print(__FUNCTION__ + "(): " + err);
    last_err = err;
    ea_active = FALSE;
    return (FALSE);
  }
  if (!session_active) {
    err = "Error: Session is not active!";
    if (VerboseErrors && err != last_err) Print(__FUNCTION__ + "(): " + err);
    last_err = err;
    ea_active = FALSE;
    return (FALSE);
  }

  ea_active = TRUE;
  return (TRUE);
}

// Check if EA parameters are valid.
bool ValidSettings() {
  string err;
   // TODO: IsDllsAllowed(), IsLibrariesAllowed()
  if (LotSize < 0.0) {
    err = "Error: LotSize is less than 0.";
    if (VerboseInfo) Print(__FUNCTION__ + "():" + err);
    if (PrintLogOnChart) Comment(err);
    return (FALSE);
  }
  E_Mail = StringTrimLeft(StringTrimRight(E_Mail));
  License = StringTrimLeft(StringTrimRight(License));
  return !StringCompare(ValidEmail(E_Mail), License);
}

bool CheckFreeMargin(int op_type, double size_of_lot) {
   bool margin_ok = TRUE;
   double margin = AccountFreeMarginCheck(Symbol(), op_type, size_of_lot);
   if (GetLastError() == 134 /* NOT_ENOUGH_MONEY */) margin_ok = FALSE;
   return (margin_ok);
}

void CheckStats(double value, int type, bool max = TRUE) {
  if (max) {
    if (value > daily[type])   daily[type]   = value;
    if (value > weekly[type])  weekly[type]  = value;
    if (value > monthly[type]) monthly[type] = value;
  } else {
    if (value < daily[type])   daily[type]   = value;
    if (value < weekly[type])  weekly[type]  = value;
    if (value < monthly[type]) monthly[type] = value;
  }
}

/*
 * Get order profit.
 */
double GetOrderProfit() {
  return OrderProfit() - OrderCommission() - OrderSwap();
}

/*
 * Get color of the order.
 */
double GetOrderColor(int cmd = -1) {
  if (cmd == -1) cmd = OrderType();
  return If(OpTypeValue(cmd) > 0, ColorBuy, ColorSell);
}

/*
 * This function returns the minimal permissible distance value in points for StopLoss/TakeProfit.
 *
 * This is due that at placing of a pending order, the open price cannot be too close to the market.
 * The minimal distance of the pending price from the current market one in points can be obtained
 * using the MarketInfo() function with the MODE_STOPLEVEL parameter. In case of false open price of a pending order,
 * the error 130 (ERR_INVALID_STOPS) will be generated.
 *
 */
double GetMinStopLevel() {
  return market_stoplevel * Point;
}

/*
 * Calculate pip size.
 */
double GetPipSize() {
  if (Digits < 4) {
    return 0.01;
  } else {
    return 0.0001;
  }
}

/*
 * Calculate pip precision.
 */
double GetPipPrecision() {
  if (Digits < 4) {
    return 2;
  } else {
    return 4;
  }
}

/*
 * Calculate volume precision.
 */
double GetVolumePrecision() {
  if (TradeMicroLots) return 2;
  else return 1;
}

// Calculate number of points per pip.
// To be used to replace Point for trade parameters calculations.
// See: http://forum.mql4.com/30672
double GetPointsPerPip() {
  return MathPow(10, Digits - PipDigits);
}

/*
 * Convert value into pips.
 */
double ValueToPips(double value) {
  return value * MathPow(10, Digits) / PipDigits;
}

/*
 * Convert pips into points.
 */
double PipsToPoints(double pips) {
  return pips * pts_per_pip;
}

/*
 * Convert points into pips.
 */
double PointsToPips(int points) {
  return points / pts_per_pip;
}

/*
 * Get the difference between two price values (in pips).
 */
double GetPipDiff(double price1, double price2, bool abs = FALSE) {
  double diff = If(abs, MathAbs(price1 - price2), price1 - price2);
  return diff * MathPow(10, Digits) / PipDigits;
}

/*
 * Add currency sign to the plain value.
 */
string ValueToCurrency(double value, int digits = 2) {
  ushort sign; bool prefix = TRUE;
  if (AccCurrency == "USD") sign = '$';
  else if (AccCurrency == "GBP") sign = '�';
  else if (AccCurrency == "EUR") sign = '�';
  else { sign = AccCurrency; prefix = FALSE; }
  return IfTxt(prefix, CharToString(sign) + DoubleToStr(value, digits), DoubleToStr(value, digits) + CharToString(sign));
}

/*
 * Current market spread value in pips.
 *
 * Note: Using Mode_SPREAD can return 20 on EURUSD (IBFX), but zero on some other pairs, so using Ask - Bid instead.
 * See: http://forum.mql4.com/42285
 */
double GetMarketSpread(bool in_points = FALSE) {
  // return MarketInfo(Symbol(), MODE_SPREAD) / MathPow(10, Digits - PipDigits);
  double spread = If(in_points, SymbolInfoInteger(Symbol(), SYMBOL_SPREAD), Ask - Bid);
  if (in_points) CheckStats(spread, MAX_SPREAD);
  return spread;
}

// Get current minimum marker gap (in points).
double GetMarketGap(bool in_points = FALSE) {
  return If(in_points, market_stoplevel + GetMarketSpread(TRUE), (market_stoplevel + GetMarketSpread(TRUE)) * Point);
}

/*
 * Normalize lot size.
 */
double NormalizeLots(double lots, bool ceiling = FALSE, string pair = "") {
  // See: http://forum.mql4.com/47988
  double lotsize;
  double precision;
  if (market_lotstep > 0.0) precision = 1 / market_lotstep;
  else precision = 1 / market_minlot;

  if (ceiling) lotsize = MathCeil(lots * precision) / precision;
  else lotsize = MathFloor(lots * precision) / precision;

  if (lotsize < market_minlot) lotsize = market_minlot;
  if (lotsize > market_maxlot) lotsize = market_maxlot;
  return (lotsize);
}

/*
 * Normalize price value.
 */
double NormalizePrice(double p, string pair=""){
   // See: http://forum.mql4.com/47988
   // http://forum.mql4.com/43064#515262 zzuegg reports for non-currency DE30:
   // MarketInfo(chart.symbol,MODE_TICKSIZE) returns 0.5
   // MarketInfo(chart.symbol,MODE_DIGITS) return 1
   // Point = 0.1
   // Prices to open must be a multiple of ticksize
   if (pair == "") pair = Symbol();
   double ts = MarketInfo(pair, MODE_TICKSIZE);
   return( MathRound(p/ts) * ts );
}

/*
 * Return opposite trade command operation.
 *
 * @param
 *   cmd (int) - trade command operation
 */
int CmdOpp(int cmd) {
  if (cmd == OP_BUY) return OP_SELL;
  if (cmd == OP_SELL) return OP_BUY;
  return EMPTY;
}

/*
 * Get account stopout level in range: 0.0 - 1.0 where 1.0 is 100%.
 */
double GetAccountStopoutLevel() {
  if (AccountStopoutMode() == 0) {
    return AccountStopoutLevel() / 100;
  } else { // else it's in account currency.
    // FIXME: Test it.
    return AccountEquity() / AccountStopoutLevel();
  }
}

/*
 * Calculate number of order allowed given risk ratio.
 */
int GetMaxOrdersAuto(bool smooth = TRUE) {
  double avail_margin = MathMin(AccountFreeMargin(), AccountBalance());
  double leverage     = MathMax(AccountLeverage(), 100);
  double one_lot      = MathMin(MarketInfo(Symbol(), MODE_MARGINREQUIRED), 10); // Price of 1 lot (minimum 10, to make sure we won't divide by zero).
  // double margin_risk  = MathMin(0.1, GetAccountStopoutLevel()); // Percent of free margin to risk (e.g. 0.1 = 10%).
  int balance_limit   = MathMax(MathMin(AccountBalance(), AccountEquity()) / 2, 0); // At least 1 order per 2 currency value. This also prevents trading with negative balance.
  double avail_orders = avail_margin / one_lot / lot_size * (100 / leverage);
  int new_max_orders = MathMin(avail_orders * risk_ratio, (balance_limit * risk_ratio) / lot_size);
  if (smooth && new_max_orders > max_orders) {
    max_orders = (max_orders + new_max_orders) / 2; // Increase the limit smoothly.
  } else {
    max_orders = new_max_orders;
  }
  return max_orders;
}

/*
 * Calculate number of maximum of orders allowed to open.
 */
int GetMaxOrders() {
  return If(MaxOrders > 0, MaxOrders, GetMaxOrdersAuto());
}

/*
 * Calculate number of maximum of orders allowed to open per type.
 */
int GetMaxOrdersPerType() {
  return If(MaxOrdersPerType > 0, MaxOrdersPerType, MathMax(MathFloor(max_orders / GetNoOfStrategies() ), 1) * 2);
}

/*
 * Get number of active strategies.
 */
int GetNoOfStrategies() {
  int result = 0;
  for (int i = 0; i < FINAL_STRATEGY_TYPE_ENTRY; i++)
    result += info[i][ACTIVE];
  return result;
}

/*
 * Calculate size of the lot based on the free margin and account leverage automatically.
 */
double GetAutoLotSize() {
  double margin_risk = 0.01; // Percent of free margin to risk per each order (1%).
  double avail_margin = MathMin(AccountFreeMargin(), AccountBalance());
  double leverage     = MathMax(AccountLeverage(), 100);
  double one_lot      = MathMin(MarketInfo(Symbol(), MODE_MARGINREQUIRED), 10); // Price of 1 lot (minimum 10, to make sure we won't divide by zero).
  double avail_orders = avail_margin / one_lot / MathMax(lot_size, 0.01) * (100 / leverage);
  double new_lot_size = avail_orders * market_minlot * margin_risk * risk_ratio / MathMin(max_orders + 1, 100);
  // Old:
  // double free      = AccountFreeMargin();
  // double balance   = AccountBalance();
  // double leverage  = MathMax(AccountLeverage(), 100);
  // double max_avail_lots = MathMin(free, balance) / market_marginrequired * (100 / leverage);
  // int avail_orders = free / one_lot / lot_size * (100 / leverage);
  // double new_lot_size = (max_avail_lots * market_minlot * margin_risk * risk_ratio) / MathMax(GetNoOfStrategies(), 1); // FIXME

  if (lot_size > 0) {
    return (lot_size + new_lot_size) / 2; // Increase only by average of the previous and new (which should prevent sudden increases).
  } else {
    return new_lot_size;
  }
}

/*
 * Return current lot size to trade.
 */
double GetLotSize() {
  double min_lot  = MarketInfo(Symbol(), MODE_MINLOT);
  return NormalizeLots(If(LotSize == 0, GetAutoLotSize(), LotSize));
}

/*
 * Calculate auto risk ratio value.
 */
double GetAutoRiskRatio() {
  double equity  = AccountEquity();
  double balance = AccountBalance();
  double free    = AccountFreeMargin();
  double margin  = AccountMargin();
  double margin_risk = 1 / MathMin(equity, balance) * MathMin(MathMin(free, balance), equity);
  margin_risk *= GetAccountStopoutLevel(); // Decrease by account Stop Out level.

  #ifdef __advanced__
    if ((RiskRatioDecreaseMethod &  1) != 0) if (AccountCondition(C_ACC_IN_LOSS))      margin_risk /= 2; // Half risk if we're in overall loss.
    if ((RiskRatioDecreaseMethod &  2) != 0) if (AccountCondition(C_EQUITY_LOWER))     margin_risk -= 0.1;
    if ((RiskRatioDecreaseMethod &  4) != 0) if (AccountCondition(C_EQUITY_10PC_HIGH)) margin_risk -= 0.1;
    if ((RiskRatioDecreaseMethod &  8) != 0) if (AccountCondition(C_DBAL_GT_WEEKLY))   margin_risk -= 0.1;
    if ((RiskRatioDecreaseMethod & 16) != 0) if (AccountCondition(C_WBAL_LT_MONTHLY))  margin_risk -= 0.1;
    if ((RiskRatioDecreaseMethod & 32) != 0) if (AccountCondition(C_ACC_IN_NON_TREND)) margin_risk -= 0.1;

    if ((RiskRatioIncreaseMethod &  1) != 0) if (AccountCondition(C_ACC_IN_PROFIT))    margin_risk += 0.1;
    if ((RiskRatioIncreaseMethod &  2) != 0) if (AccountCondition(C_EQUITY_HIGHER))    margin_risk += 0.1;
    if ((RiskRatioIncreaseMethod &  4) != 0) if (AccountCondition(C_EQUITY_10PC_LOW))  margin_risk += 0.1;
    if ((RiskRatioIncreaseMethod &  8) != 0) if (AccountCondition(C_DBAL_LT_WEEKLY))   margin_risk += 0.1;
    if ((RiskRatioIncreaseMethod & 16) != 0) if (AccountCondition(C_WBAL_GT_MONTHLY))  margin_risk += 0.1;
    if ((RiskRatioIncreaseMethod & 32) != 0) if (AccountCondition(C_ACC_IN_TREND))     margin_risk += 0.1;
  #else
    if (GetTotalProfit() < 0) margin_risk /= 2; // Half risk if we're in overall loss.
  #endif

  return margin_risk;
}

/*
 * Return risk ratio value.
 */
double GetRiskRatio() {
  return If(RiskRatio == 0, GetAutoRiskRatio(), RiskRatio);
}

/*
 * Validate the e-mail.
 */
string ValidEmail(string text) {
  string output = StringLen(text);
  if (text == "") {
    last_err = "Error: E-mail is empty, please validate the settings.";
    Comment(last_err);
    Print(last_err);
    ea_active = FALSE;
    return FALSE;
  }
  if (StringFind(text, "@") == EMPTY || StringFind(text, ".") == EMPTY) {
    last_err = "Error: E-mail is not in valid format.";
    Comment(last_err);
    Print(last_err);
    ea_active = FALSE;
    return FALSE;
  }
  for (last_bar_time = StringLen(text); last_bar_time >= 0; last_bar_time--)
    output += IntegerToString(StringGetChar(text, last_bar_time), 3, '-');
  StringReplace(output, "9", "1"); StringReplace(output, "8", "7"); StringReplace(output, "--", "-3");
  output = StringSubstr(output, 0, StringLen(ea_name) + StringLen(ea_author) + StringLen(ea_link));
  #ifdef __testing__ #define print_license #endif
  #ifdef print_license
    Print(output);
  #endif
  return output;
}

/* BEGIN: PERIODIC FUNCTIONS */

/*
 * Executed for every hour.
 */
void StartNewHour() {
  hour_of_day = Hour(); // Save the new hour.
  if (VerboseDebug) Print("== New hour: " + hour_of_day);

  // Update variables.
  risk_ratio = GetRiskRatio();
  max_orders = GetMaxOrders();

  if (day_of_week != DayOfWeek()) { // Check if new day has been started.
    StartNewDay();
  }

  CheckHistory(); // Process closed orders.

  // Update strategy factor and lot size.
  if (Boosting_Enabled) UpdateStrategyFactor(DAILY);

  // Check if RSI period needs re-calculation.
  if (RSI_DynamicPeriod) RSI_CheckPeriod();

  #ifdef __advanced__
  // Check for dynamic spread configuration.
  if (DynamicSpreadConf) {
    // TODO: SpreadRatio, MinPipChangeToTrade, MinPipGap
  }
  #endif

  // Reset messages and errors.
  // Message(NULL);
}

/*
 * Queue the message for display.
 */
void Message(string msg = NULL) {
  if (msg == NULL) { last_msg = ""; last_err = ""; }
  else last_msg = msg;
}

/*
 * Get last available message.
 */
string GetLastMessage() {
  return last_msg;
}

/*
 * Get last available error.
 */
string GetLastErrMsg() {
  return last_err;
}

/*
 * Executed for every new day.
 */
void StartNewDay() {
  if (VerboseInfo) Print("== New day (day of month: " + Day() + "; day of year: " + DayOfYear() + ") ==");

  // Print daily report at end of each day.
  if (VerboseInfo) Print(GetDailyReport());

  // Check if day started another week.
  if (DayOfWeek() < day_of_week) {
    StartNewWeek();
  }
  if (Day() < day_of_month) {
    StartNewMonth();
  }
  if (DayOfYear() < day_of_year) {
    StartNewYear();
  }

  // Calculate lot size, orders and risk.
  lot_size = GetLotSize(); // Re-calculate lot size.
  UpdateStrategyLotSize(); // Update strategy lot size.

  // Update boosting values.
  if (Boosting_Enabled) UpdateStrategyFactor(WEEKLY);

  // Store new data.
  day_of_week = DayOfWeek(); // The zero-based day of week (0 means Sunday,1,2,3,4,5,6) of the specified date. At the testing, the last known server time is modelled.
  day_of_month = Day(); // The day of month (1 - 31) of the specified date. At the testing, the last known server time is modelled.
  day_of_year = DayOfYear(); // Day (1 means 1 January,..,365(6) does 31 December) of year. At the testing, the last known server time is modelled.
  // Print and reset variables.
  string sar_stats = "Daily SAR stats: ";
  for (int i = 0; i < FINAL_PERIOD_TYPE_ENTRY; i++) {
    sar_stats += "Period: " + i + ", Buy: " + signals[DAILY][SAR1][i][OP_BUY] + " / " + "Sell: " + signals[DAILY][SAR1][i][OP_SELL] + "; ";
    // sar_stats += "Buy M5: " + signals[DAILY][SAR5][i][OP_BUY] + " / " + "Sell M5: " + signals[DAILY][SAR5][i][OP_SELL] + "; ";
    // sar_stats += "Buy M15: " + signals[DAILY][SAR15][i][OP_BUY] + " / " + "Sell M15: " + signals[DAILY][SAR15][i][OP_SELL] + "; ";
    // sar_stats += "Buy M30: " + signals[DAILY][SAR30][i][OP_BUY] + " / " + "Sell M30: " + signals[DAILY][SAR30][i][OP_SELL] + "; ";
    signals[DAILY][SAR1][i][OP_BUY] = 0;  signals[DAILY][SAR1][i][OP_SELL]  = 0;
    // signals[DAILY][SAR5][i][OP_BUY] = 0;  signals[DAILY][SAR5][i][OP_SELL]  = 0;
    // signals[DAILY][SAR15][i][OP_BUY] = 0; signals[DAILY][SAR15][i][OP_SELL] = 0;
    // signals[DAILY][SAR30][i][OP_BUY] = 0; signals[DAILY][SAR30][i][OP_SELL] = 0;
  }
  if (VerboseInfo) Print(sar_stats);

  // Reset previous data.
  ArrayFill(daily, 0, ArraySize(daily), 0);
  // Print and reset strategy stats.
  string strategy_stats = "Daily strategy stats: ";
  for (int j = 0; j < FINAL_STRATEGY_TYPE_ENTRY; j++) {
    if (stats[j][DAILY_PROFIT] != 0) strategy_stats += name[j] + ": " + stats[j][DAILY_PROFIT] + "pips; ";
    stats[j][DAILY_PROFIT]  = 0;
  }
  if (VerboseInfo) Print(strategy_stats);
}

/*
 * Executed for every new week.
 */
void StartNewWeek() {
  if (VerboseInfo) Print("== New week ==");
  if (VerboseInfo) Print(GetWeeklyReport()); // Print weekly report at end of each week.

  if (Boosting_Enabled) UpdateStrategyFactor(MONTHLY);

  // Reset variables.
  string sar_stats = "Weekly SAR stats: ";
  for (int i = 0; i < FINAL_PERIOD_TYPE_ENTRY; i++) {
    sar_stats += "Period: " + i + ", Buy: " + signals[WEEKLY][SAR1][i][OP_BUY] + " / " + "Sell: " + signals[WEEKLY][SAR1][i][OP_SELL] + "; ";
    //sar_stats += "Buy M1: " + signals[WEEKLY][SAR1][i][OP_BUY] + " / " + "Sell M1: " + signals[WEEKLY][SAR1][i][OP_SELL] + "; ";
    //sar_stats += "Buy M5: " + signals[WEEKLY][SAR5][i][OP_BUY] + " / " + "Sell M5: " + signals[WEEKLY][SAR5][i][OP_SELL] + "; ";
    //sar_stats += "Buy M15: " + signals[WEEKLY][SAR15][i][OP_BUY] + " / " + "Sell M15: " + signals[WEEKLY][SAR15][i][OP_SELL] + "; ";
    //sar_stats += "Buy M30: " + signals[WEEKLY][SAR30][i][OP_BUY] + " / " + "Sell M30: " + signals[WEEKLY][SAR30][i][OP_SELL] + "; ";
    signals[WEEKLY][SAR1][i][OP_BUY]  = 0; signals[WEEKLY][SAR1][i][OP_SELL]  = 0;
    // signals[WEEKLY][SAR5][i][OP_BUY]  = 0; signals[WEEKLY][SAR5][i][OP_SELL]  = 0;
    // signals[WEEKLY][SAR15][i][OP_BUY] = 0; signals[WEEKLY][SAR15][i][OP_SELL] = 0;
    // signals[WEEKLY][SAR30][i][OP_BUY] = 0; signals[WEEKLY][SAR30][i][OP_SELL] = 0;
  }
  if (VerboseInfo) Print(sar_stats);

  ArrayFill(weekly, 0, ArraySize(weekly), 0);
  // Reset strategy stats.
  string strategy_stats = "Weekly strategy stats: ";
  for (int j = 0; j < FINAL_STRATEGY_TYPE_ENTRY; j++) {
    if (stats[j][WEEKLY_PROFIT] != 0) strategy_stats += name[j] + ": " + stats[j][WEEKLY_PROFIT] + "pips; ";
    stats[j][WEEKLY_PROFIT] = 0;
  }
  if (VerboseInfo) Print(strategy_stats);
}

/*
 * Executed for every new month.
 */
void StartNewMonth() {
  if (VerboseInfo) Print("== New month ==");
  if (VerboseInfo) Print(GetMonthlyReport()); // Print monthly report at end of each month.

  // Reset variables.
  string sar_stats = "Monthly SAR stats: ";
  for (int i = 0; i < FINAL_PERIOD_TYPE_ENTRY; i++) {
    sar_stats += "Period: " + i + ", Buy: " + signals[MONTHLY][SAR1][i][OP_BUY] + " / " + "Sell: " + signals[MONTHLY][SAR1][i][OP_SELL] + "; ";
    // sar_stats += "Buy M1: " + signals[MONTHLY][SAR1][i][OP_BUY] + " / " + "Sell M1: " + signals[MONTHLY][SAR1][i][OP_SELL] + "; ";
    // sar_stats += "Buy M5: " + signals[MONTHLY][SAR5][i][OP_BUY] + " / " + "Sell M5: " + signals[MONTHLY][SAR5][i][OP_SELL] + "; ";
    // sar_stats += "Buy M15: " + signals[MONTHLY][SAR15][i][OP_BUY] + " / " + "Sell M15: " + signals[MONTHLY][SAR15][i][OP_SELL] + "; ";
    // sar_stats += "Buy M30: " + signals[MONTHLY][SAR30][i][OP_BUY] + " / " + "Sell M30: " + signals[MONTHLY][SAR30][i][OP_SELL] + "; ";
    signals[MONTHLY][SAR1][i][OP_BUY]  = 0; signals[MONTHLY][SAR1][i][OP_SELL]  = 0;
    // signals[MONTHLY][SAR5][i][OP_BUY]  = 0; signals[MONTHLY][SAR5][i][OP_SELL]  = 0;
    // signals[MONTHLY][SAR15][i][OP_BUY] = 0; signals[MONTHLY][SAR15][i][OP_SELL] = 0;
    // signals[MONTHLY][SAR30][i][OP_BUY] = 0; signals[MONTHLY][SAR30][i][OP_SELL] = 0;
  }
  if (VerboseInfo) Print(sar_stats);

  ArrayFill(monthly, 0, ArraySize(monthly), 0);
  // Reset strategy stats.
  string strategy_stats = "Monthly strategy stats: ";
  for (int j = 0; j < FINAL_STRATEGY_TYPE_ENTRY; j++) {
    if (stats[j][MONTHLY_PROFIT] != 0) strategy_stats += name[j] + ": " + stats[j][MONTHLY_PROFIT] + " pips; ";
    stats[j][MONTHLY_PROFIT] = MathMin(0, stats[j][MONTHLY_PROFIT]);
  }
  if (VerboseInfo) Print(strategy_stats);
}

/*
 * Executed for every new year.
 */
void StartNewYear() {
  if (VerboseInfo) Print("== New year ==");
  // if (VerboseInfo) Print(GetYearlyReport()); // Print monthly report at end of each year.

  // Reset variables.
  for (int i = 0; i < FINAL_PERIOD_TYPE_ENTRY; i++) {
    signals[YEARLY][SAR1][i][OP_BUY] = 0;
    signals[YEARLY][SAR1][i][OP_SELL] = 0;
  }
}

/* END: PERIODIC FUNCTIONS */

/* BEGIN: VARIABLE FUNCTIONS */

/*
 * Initialize startup variables.
 */
bool InitializeVariables() {

  // Get type of account.
  if (IsDemo()) account_type = "Demo"; else account_type = "Live";
  if (IsTesting()) account_type = "Backtest on " + account_type;

  // Check time of the week, month and year based on the trading bars.
  bar_time = iTime(NULL, PERIOD_M1, 0);
  hour_of_day = Hour(); // The hour (0,1,2,..23) of the last known server time by the moment of the program start.
  day_of_week = DayOfWeek(); // The zero-based day of week (0 means Sunday,1,2,3,4,5,6) of the specified date. At the testing, the last known server time is modelled.
  day_of_month = Day(); // The day of month (1 - 31) of the specified date. At the testing, the last known server time is modelled.
  day_of_year = DayOfYear(); // Day (1 means 1 January,..,365(6) does 31 December) of year. At the testing, the last known server time is modelled.

  market_minlot = MarketInfo(Symbol(), MODE_MINLOT);
  if (market_minlot == 0.0) market_minlot = 0.1;
  market_maxlot = MarketInfo(Symbol(), MODE_MAXLOT);
  if (market_maxlot == 0.0) market_maxlot = 100;
  market_lotstep = MarketInfo(Symbol(), MODE_LOTSTEP);
  market_marginrequired = MarketInfo(Symbol(), MODE_MARGINREQUIRED) * market_lotstep;
  if (market_marginrequired == 0) market_marginrequired = 10; // FIX for 'zero divide' bug when MODE_MARGINREQUIRED is zero
  market_stoplevel = MarketInfo(Symbol(), MODE_STOPLEVEL); // Market stop level in points.
  // market_stoplevel=(int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
  LastAsk = Ask; LastBid = Bid;
  AccCurrency = AccountCurrency();

  // Calculate pip/volume/slippage size and precision.
  pip_size = GetPipSize();
  PipDigits = GetPipPrecision();
  pts_per_pip = GetPointsPerPip();
  VolumeDigits = GetVolumePrecision();
  max_order_slippage = PipsToPoints(MaxOrderPriceSlippage); // Maximum price slippage for buy or sell orders (converted into points).

  // Calculate lot size, orders and risk.
  lot_size = GetLotSize();
  risk_ratio = GetRiskRatio();
  max_orders = GetMaxOrders();

  //GMT_Offset = ManualGMToffset;
  ArrayInitialize(todo_queue, 0); // Reset queue list.
  ArrayInitialize(daily,   0); // Reset daily stats.
  ArrayInitialize(weekly,  0); // Reset weekly stats.
  ArrayInitialize(monthly, 0); // Reset monthly stats.
  ArrayInitialize(tickets, 0); // Reset ticket list.
  ArrayInitialize(worse_strategy, EMPTY);
  ArrayInitialize(best_strategy, EMPTY);


  // Initialize strategies.
  ArrayInitialize(info, 0);  // Reset strategy info.
  ArrayInitialize(conf, 0);  // Reset strategy configuration.
  ArrayInitialize(stats, 0); // Reset strategy statistics.

  // name[CUSTOM]              = "Custom";
  // info[CUSTOM][ACTIVE]      = FALSE;

  name[MA1]                  = "MA M1";
  info[MA1][ACTIVE]          = MA1_Active;
  info[MA1][TIMEFRAME]       = M1;
  info[MA1][OPEN_METHOD]     = MA1_OpenMethod;
  #ifdef __advanced__
  info[MA1][OPEN_CONDITION1] = MA1_OpenCondition1;
  info[MA1][OPEN_CONDITION2] = MA1_OpenCondition2;
  info[MA1][CLOSE_CONDITION] = MA1_CloseCondition;
  conf[MA1][SPREAD_LIMIT]    = MA1_MaxSpread;
  #endif

  name[MA5]                  = "MA M5";
  info[MA5][ACTIVE]          = MA5_Active;
  info[MA5][TIMEFRAME]       = M5;
  info[MA5][OPEN_METHOD]     = MA5_OpenMethod;
  #ifdef __advanced__
  info[MA5][OPEN_CONDITION1] = MA5_OpenCondition1;
  info[MA5][OPEN_CONDITION2] = MA5_OpenCondition2;
  info[MA5][CLOSE_CONDITION] = MA5_CloseCondition;
  conf[MA5][SPREAD_LIMIT]    = MA5_MaxSpread;
  #endif

  name[MA15]                  = "MA M15";
  info[MA15][ACTIVE]          = MA15_Active;
  info[MA15][TIMEFRAME]       = M15;
  info[MA15][OPEN_METHOD]     = MA15_OpenMethod;
  #ifdef __advanced__
  info[MA15][OPEN_CONDITION1] = MA15_OpenCondition1;
  info[MA15][OPEN_CONDITION2] = MA15_OpenCondition2;
  info[MA15][CLOSE_CONDITION] = MA15_CloseCondition;
  conf[MA15][SPREAD_LIMIT]    = MA15_MaxSpread;
  #endif

  name[MA30]                  = "MA M30";
  info[MA30][ACTIVE]          = MA30_Active;
  info[MA30][TIMEFRAME]       = M30;
  info[MA30][OPEN_METHOD]     = MA30_OpenMethod;
  #ifdef __advanced__
  info[MA30][OPEN_CONDITION1] = MA30_OpenCondition1;
  info[MA30][OPEN_CONDITION2] = MA30_OpenCondition2;
  info[MA30][CLOSE_CONDITION] = MA30_CloseCondition;
  conf[MA30][SPREAD_LIMIT]    = MA30_MaxSpread;
  #endif

  name[MACD1]                  = "MACD M1";
  info[MACD1][ACTIVE]          = MACD1_Active;
  info[MACD1][TIMEFRAME]       = M1;
  info[MACD1][OPEN_METHOD]     = MACD1_OpenMethod;
  #ifdef __advanced__
  info[MACD1][OPEN_CONDITION1] = MACD1_OpenCondition1;
  info[MACD1][OPEN_CONDITION2] = MACD1_OpenCondition2;
  info[MACD1][CLOSE_CONDITION] = MACD1_CloseCondition;
  conf[MACD1][SPREAD_LIMIT]    = MACD1_MaxSpread;
  #endif

  name[MACD5]                  = "MACD M5";
  info[MACD5][ACTIVE]          = MACD5_Active;
  info[MACD5][TIMEFRAME]       = M5;
  info[MACD5][OPEN_METHOD]     = MACD5_OpenMethod;
  #ifdef __advanced__
  info[MACD5][OPEN_CONDITION1] = MACD5_OpenCondition1;
  info[MACD5][OPEN_CONDITION2] = MACD5_OpenCondition2;
  info[MACD5][CLOSE_CONDITION] = MACD5_CloseCondition;
  conf[MACD5][SPREAD_LIMIT]    = MACD5_MaxSpread;
  #endif

  name[MACD15]                  = "MACD M15";
  info[MACD15][ACTIVE]          = MACD15_Active;
  info[MACD15][TIMEFRAME]       = M15;
  info[MACD15][OPEN_METHOD]     = MACD15_OpenMethod;
  #ifdef __advanced__
  info[MACD15][OPEN_CONDITION1] = MACD15_OpenCondition1;
  info[MACD15][OPEN_CONDITION2] = MACD15_OpenCondition2;
  info[MACD15][CLOSE_CONDITION] = MACD15_CloseCondition;
  conf[MACD15][SPREAD_LIMIT]    = MACD15_MaxSpread;
  #endif

  name[MACD30]                  = "MACD M30";
  info[MACD30][ACTIVE]          = MACD30_Active;
  info[MACD30][TIMEFRAME]       = M30;
  info[MACD30][OPEN_METHOD]     = MACD30_OpenMethod;
  #ifdef __advanced__
  info[MACD30][OPEN_CONDITION1] = MACD30_OpenCondition1;
  info[MACD30][OPEN_CONDITION2] = MACD30_OpenCondition2;
  info[MACD30][CLOSE_CONDITION] = MACD30_CloseCondition;
  conf[MACD30][SPREAD_LIMIT]    = MACD30_MaxSpread;
  #endif

  name[ALLIGATOR1]                  = "Alligator M1";
  info[ALLIGATOR1][ACTIVE]          = Alligator1_Active;
  info[ALLIGATOR1][TIMEFRAME]       = M1;
  info[ALLIGATOR1][OPEN_METHOD]     = Alligator1_OpenMethod;
  #ifdef __advanced__
  info[ALLIGATOR1][OPEN_CONDITION1] = Alligator1_OpenCondition1;
  info[ALLIGATOR1][OPEN_CONDITION2] = Alligator1_OpenCondition2;
  info[ALLIGATOR1][CLOSE_CONDITION] = Alligator1_CloseCondition;
  conf[ALLIGATOR1][SPREAD_LIMIT]    = Alligator1_MaxSpread;
  #endif

  name[ALLIGATOR5]                  = "Alligator M5";
  info[ALLIGATOR5][ACTIVE]          = Alligator5_Active;
  info[ALLIGATOR5][TIMEFRAME]       = M5;
  info[ALLIGATOR5][OPEN_METHOD]     = Alligator5_OpenMethod;
  #ifdef __advanced__
  info[ALLIGATOR5][OPEN_CONDITION1] = Alligator5_OpenCondition1;
  info[ALLIGATOR5][OPEN_CONDITION2] = Alligator5_OpenCondition2;
  info[ALLIGATOR5][CLOSE_CONDITION] = Alligator5_CloseCondition;
  conf[ALLIGATOR5][SPREAD_LIMIT]    = Alligator5_MaxSpread;
  #endif

  name[ALLIGATOR15]                  = "Alligator M15";
  info[ALLIGATOR15][ACTIVE]          = Alligator15_Active;
  info[ALLIGATOR15][TIMEFRAME]       = M15;
  info[ALLIGATOR15][OPEN_METHOD]     = Alligator15_OpenMethod;
  #ifdef __advanced__
  info[ALLIGATOR15][OPEN_CONDITION1] = Alligator15_OpenCondition1;
  info[ALLIGATOR15][OPEN_CONDITION2] = Alligator15_OpenCondition2;
  info[ALLIGATOR15][CLOSE_CONDITION] = Alligator15_CloseCondition;
  conf[ALLIGATOR15][SPREAD_LIMIT]    = Alligator15_MaxSpread;
  #endif

  name[ALLIGATOR30]                  = "Alligator M30";
  info[ALLIGATOR30][ACTIVE]          = Alligator30_Active;
  info[ALLIGATOR30][TIMEFRAME]       = M30;
  info[ALLIGATOR30][OPEN_METHOD]     = Alligator30_OpenMethod;
  #ifdef __advanced__
  info[ALLIGATOR30][OPEN_CONDITION1] = Alligator30_OpenCondition1;
  info[ALLIGATOR30][OPEN_CONDITION2] = Alligator30_OpenCondition2;
  info[ALLIGATOR30][CLOSE_CONDITION] = Alligator30_CloseCondition;
  conf[ALLIGATOR30][SPREAD_LIMIT]    = Alligator30_MaxSpread;
  #endif

  name[RSI1]                  = "RSI M1";
  info[RSI1][ACTIVE]          = RSI1_Active;
  info[RSI1][TIMEFRAME]       = M1;
  info[RSI1][OPEN_METHOD]     = RSI1_OpenMethod;
  #ifdef __advanced__
  info[RSI1][OPEN_CONDITION1] = RSI1_OpenCondition1;
  info[RSI1][OPEN_CONDITION2] = RSI1_OpenCondition2;
  info[RSI1][CLOSE_CONDITION] = RSI1_CloseCondition;
  info[RSI1][CUSTOM_PERIOD]   = RSI_Period;
  conf[RSI1][SPREAD_LIMIT]    = RSI1_MaxSpread;
  #endif

  name[RSI5]                  = "RSI M5";
  info[RSI5][ACTIVE]          = RSI5_Active;
  info[RSI5][TIMEFRAME]       = M5;
  info[RSI5][OPEN_METHOD]     = RSI5_OpenMethod;
  #ifdef __advanced__
  info[RSI5][OPEN_CONDITION1] = RSI5_OpenCondition1;
  info[RSI5][OPEN_CONDITION2] = RSI5_OpenCondition2;
  info[RSI5][CLOSE_CONDITION] = RSI5_CloseCondition;
  info[RSI5][CUSTOM_PERIOD]   = RSI_Period;
  conf[RSI5][SPREAD_LIMIT]    = RSI5_MaxSpread;
  #endif

  name[RSI15]                  = "RSI M15";
  info[RSI15][ACTIVE]          = RSI15_Active;
  info[RSI15][TIMEFRAME]       = M15;
  info[RSI15][OPEN_METHOD]     = RSI15_OpenMethod;
  #ifdef __advanced__
  info[RSI15][OPEN_CONDITION1] = RSI15_OpenCondition1;
  info[RSI15][OPEN_CONDITION2] = RSI15_OpenCondition2;
  info[RSI15][CLOSE_CONDITION] = RSI15_CloseCondition;
  info[RSI15][CUSTOM_PERIOD]   = RSI_Period;
  conf[RSI15][SPREAD_LIMIT]    = RSI15_MaxSpread;
  #endif

  name[RSI30]                  = "RSI M30";
  info[RSI30][ACTIVE]          = RSI30_Active;
  info[RSI30][TIMEFRAME]       = M30;
  info[RSI30][OPEN_METHOD]     = RSI30_OpenMethod;
  #ifdef __advanced__
  info[RSI30][OPEN_CONDITION1] = RSI30_OpenCondition1;
  info[RSI30][OPEN_CONDITION2] = RSI30_OpenCondition2;
  info[RSI30][CLOSE_CONDITION] = RSI30_CloseCondition;
  info[RSI30][CUSTOM_PERIOD]   = RSI_Period;
  conf[RSI30][SPREAD_LIMIT]    = RSI30_MaxSpread;
  #endif

  name[SAR1]                  = "SAR M1";
  info[SAR1][ACTIVE]          = SAR1_Active;
  info[SAR1][TIMEFRAME]       = M1;
  info[SAR1][OPEN_METHOD]     = SAR1_OpenMethod;
  #ifdef __advanced__
  info[SAR1][OPEN_CONDITION1] = SAR1_OpenCondition1;
  info[SAR1][OPEN_CONDITION2] = SAR1_OpenCondition2;
  info[SAR1][CLOSE_CONDITION] = SAR1_CloseCondition;
  conf[SAR1][SPREAD_LIMIT]    = SAR1_MaxSpread;
  #endif

  name[SAR5]                  = "SAR M5";
  info[SAR5][ACTIVE]          = SAR5_Active;
  info[SAR5][TIMEFRAME]       = M5;
  info[SAR5][OPEN_METHOD]     = SAR5_OpenMethod;
  #ifdef __advanced__
  info[SAR5][OPEN_CONDITION1] = SAR5_OpenCondition1;
  info[SAR5][OPEN_CONDITION2] = SAR5_OpenCondition2;
  info[SAR5][CLOSE_CONDITION] = SAR5_CloseCondition;
  conf[SAR5][SPREAD_LIMIT]    = SAR5_MaxSpread;
  #endif

  name[SAR15]                  = "SAR M15";
  info[SAR15][ACTIVE]          = SAR15_Active;
  info[SAR15][TIMEFRAME]       = M15;
  info[SAR15][OPEN_METHOD]     = SAR15_OpenMethod;
  #ifdef __advanced__
  info[SAR15][OPEN_CONDITION1] = SAR15_OpenCondition1;
  info[SAR15][OPEN_CONDITION2] = SAR15_OpenCondition2;
  info[SAR15][CLOSE_CONDITION] = SAR15_CloseCondition;
  conf[SAR15][SPREAD_LIMIT]    = SAR15_MaxSpread;
  #endif

  name[SAR30]                  = "SAR M30";
  info[SAR30][ACTIVE]          = SAR30_Active;
  info[SAR30][TIMEFRAME]       = M30;
  info[SAR30][OPEN_METHOD]     = SAR30_OpenMethod;
  #ifdef __advanced__
  info[SAR30][OPEN_CONDITION1] = SAR30_OpenCondition1;
  info[SAR30][OPEN_CONDITION2] = SAR30_OpenCondition2;
  info[SAR30][CLOSE_CONDITION] = SAR30_CloseCondition;
  conf[SAR30][SPREAD_LIMIT]    = SAR30_MaxSpread;
  #endif

  name[BANDS1]                  = "Bands M1";
  info[BANDS1][ACTIVE]          = Bands1_Active;
  info[BANDS1][TIMEFRAME]       = M1;
  info[BANDS1][OPEN_METHOD]     = Bands1_OpenMethod;
  info[BANDS1][CUSTOM_PERIOD]   = Bands_Period;
  #ifdef __advanced__
  info[BANDS1][OPEN_CONDITION1] = Bands1_OpenCondition1;
  info[BANDS1][OPEN_CONDITION2] = Bands1_OpenCondition2;
  info[BANDS1][CLOSE_CONDITION] = Bands1_CloseCondition;
  conf[BANDS1][SPREAD_LIMIT]    = Bands1_MaxSpread;
  #endif

  name[BANDS5]                  = "Bands M5";
  info[BANDS5][ACTIVE]          = Bands5_Active;
  info[BANDS5][TIMEFRAME]       = M5;
  info[BANDS5][OPEN_METHOD]     = Bands5_OpenMethod;
  info[BANDS5][CUSTOM_PERIOD]   = Bands_Period;
  #ifdef __advanced__
  info[BANDS5][OPEN_CONDITION1] = Bands5_OpenCondition1;
  info[BANDS5][OPEN_CONDITION2] = Bands5_OpenCondition2;
  info[BANDS5][CLOSE_CONDITION] = Bands5_CloseCondition;
  conf[BANDS5][SPREAD_LIMIT]    = Bands5_MaxSpread;
  #endif

  name[BANDS15]                  = "Bands M15";
  info[BANDS15][ACTIVE]          = Bands15_Active;
  info[BANDS15][TIMEFRAME]       = M15;
  info[BANDS15][OPEN_METHOD]     = Bands15_OpenMethod;
  info[BANDS15][CUSTOM_PERIOD]   = Bands_Period;
  #ifdef __advanced__
  info[BANDS15][OPEN_CONDITION1] = Bands15_OpenCondition1;
  info[BANDS15][OPEN_CONDITION2] = Bands15_OpenCondition2;
  info[BANDS15][CLOSE_CONDITION] = Bands15_CloseCondition;
  conf[BANDS15][SPREAD_LIMIT]    = Bands15_MaxSpread;
  #endif

  name[BANDS30]                  = "Bands M30";
  info[BANDS30][ACTIVE]          = Bands30_Active;
  info[BANDS30][TIMEFRAME]       = M30;
  info[BANDS30][OPEN_METHOD]     = Bands30_OpenMethod;
  info[BANDS30][CUSTOM_PERIOD]   = Bands_Period;
  #ifdef __advanced__
  info[BANDS30][OPEN_CONDITION1] = Bands30_OpenCondition1;
  info[BANDS30][OPEN_CONDITION2] = Bands30_OpenCondition2;
  info[BANDS30][CLOSE_CONDITION] = Bands30_CloseCondition;
  conf[BANDS30][SPREAD_LIMIT]    = Bands30_MaxSpread;
  #endif

  name[ENVELOPES1]                  = "Envelopes M1";
  info[ENVELOPES1][ACTIVE]          = Envelopes1_Active;
  info[ENVELOPES1][TIMEFRAME]       = M1;
  info[ENVELOPES1][OPEN_METHOD]     = Envelopes1_OpenMethod;
  #ifdef __advanced__
  info[ENVELOPES1][OPEN_CONDITION1] = Envelopes1_OpenCondition1;
  info[ENVELOPES1][OPEN_CONDITION2] = Envelopes1_OpenCondition2;
  info[ENVELOPES1][CLOSE_CONDITION] = Envelopes1_CloseCondition;
  info[ENVELOPES1][CUSTOM_PERIOD]   = Envelopes_MA_Period;
  conf[ENVELOPES1][SPREAD_LIMIT]    = Envelopes1_MaxSpread;
  #endif

  name[ENVELOPES5]                  = "Envelopes M5";
  info[ENVELOPES5][ACTIVE]          = Envelopes5_Active;
  info[ENVELOPES5][TIMEFRAME]       = M5;
  info[ENVELOPES5][OPEN_METHOD]     = Envelopes5_OpenMethod;
  #ifdef __advanced__
  info[ENVELOPES5][OPEN_CONDITION1] = Envelopes5_OpenCondition1;
  info[ENVELOPES5][OPEN_CONDITION2] = Envelopes5_OpenCondition2;
  info[ENVELOPES5][CLOSE_CONDITION] = Envelopes5_CloseCondition;
  info[ENVELOPES5][CUSTOM_PERIOD]   = Envelopes_MA_Period;
  conf[ENVELOPES5][SPREAD_LIMIT]    = Envelopes5_MaxSpread;
  #endif

  name[ENVELOPES15]                  = "Envelopes M15";
  info[ENVELOPES15][ACTIVE]          = Envelopes15_Active;
  info[ENVELOPES15][TIMEFRAME]       = M15;
  info[ENVELOPES15][OPEN_METHOD]     = Envelopes15_OpenMethod;
  #ifdef __advanced__
  info[ENVELOPES15][OPEN_CONDITION1] = Envelopes15_OpenCondition1;
  info[ENVELOPES15][OPEN_CONDITION2] = Envelopes15_OpenCondition2;
  info[ENVELOPES15][CLOSE_CONDITION] = Envelopes15_CloseCondition;
  info[ENVELOPES15][CUSTOM_PERIOD]   = Envelopes_MA_Period;
  conf[ENVELOPES15][SPREAD_LIMIT]    = Envelopes15_MaxSpread;
  #endif

  name[ENVELOPES30]                  = "Envelopes M30";
  info[ENVELOPES30][ACTIVE]          = Envelopes30_Active;
  info[ENVELOPES30][TIMEFRAME]       = M30;
  info[ENVELOPES30][OPEN_METHOD]     = Envelopes30_OpenMethod;
  #ifdef __advanced__
  info[ENVELOPES30][OPEN_CONDITION1] = Envelopes30_OpenCondition1;
  info[ENVELOPES30][OPEN_CONDITION2] = Envelopes30_OpenCondition2;
  info[ENVELOPES30][CLOSE_CONDITION] = Envelopes30_CloseCondition;
  info[ENVELOPES30][CUSTOM_PERIOD]   = Envelopes_MA_Period;
  conf[ENVELOPES30][SPREAD_LIMIT]    = Envelopes30_MaxSpread;
  #endif

  name[WPR1]                  = "WPR M1";
  info[WPR1][ACTIVE]          = WPR1_Active;
  info[WPR1][TIMEFRAME]       = M1;
  info[WPR1][OPEN_METHOD]     = WPR1_OpenMethod;
  #ifdef __advanced__
  info[WPR1][OPEN_CONDITION1] = WPR1_OpenCondition1;
  info[WPR1][OPEN_CONDITION2] = WPR1_OpenCondition2;
  info[WPR1][CLOSE_CONDITION] = WPR1_CloseCondition;
  conf[WPR1][SPREAD_LIMIT]    = WPR1_MaxSpread;
  #endif

  name[WPR5]                  = "WPR M5";
  info[WPR5][ACTIVE]          = WPR5_Active;
  info[WPR5][TIMEFRAME]       = M5;
  info[WPR5][OPEN_METHOD]     = WPR5_OpenMethod;
  #ifdef __advanced__
  info[WPR5][OPEN_CONDITION1] = WPR5_OpenCondition1;
  info[WPR5][OPEN_CONDITION2] = WPR5_OpenCondition2;
  info[WPR5][CLOSE_CONDITION] = WPR5_CloseCondition;
  conf[WPR5][SPREAD_LIMIT]    = WPR5_MaxSpread;
  #endif

  name[WPR15]                  = "WPR M15";
  info[WPR15][ACTIVE]          = WPR15_Active;
  info[WPR15][TIMEFRAME]       = M15;
  info[WPR15][OPEN_METHOD]     = WPR15_OpenMethod;
  #ifdef __advanced__
  info[WPR15][OPEN_CONDITION1] = WPR15_OpenCondition1;
  info[WPR15][OPEN_CONDITION2] = WPR15_OpenCondition2;
  info[WPR15][CLOSE_CONDITION] = WPR15_CloseCondition;
  conf[WPR15][SPREAD_LIMIT]    = WPR15_MaxSpread;
  #endif

  name[WPR30]                  = "WPR M30";
  info[WPR30][ACTIVE]          = WPR30_Active;
  info[WPR30][TIMEFRAME]       = M30;
  info[WPR30][OPEN_METHOD]     = WPR30_OpenMethod;
  #ifdef __advanced__
  info[WPR30][OPEN_CONDITION1] = WPR30_OpenCondition1;
  info[WPR30][OPEN_CONDITION2] = WPR30_OpenCondition2;
  info[WPR30][CLOSE_CONDITION] = WPR30_CloseCondition;
  conf[WPR30][SPREAD_LIMIT]    = WPR30_MaxSpread;
  #endif

  name[DEMARKER1]                  = "DeMarker M1";
  info[DEMARKER1][ACTIVE]          = DeMarker1_Active;
  info[DEMARKER1][TIMEFRAME]       = M1;
  info[DEMARKER1][OPEN_METHOD]     = DeMarker1_OpenMethod;
  #ifdef __advanced__
  info[DEMARKER1][OPEN_CONDITION1] = DeMarker1_OpenCondition1;
  info[DEMARKER1][OPEN_CONDITION2] = DeMarker1_OpenCondition2;
  info[DEMARKER1][CLOSE_CONDITION] = DeMarker1_CloseCondition;
  conf[DEMARKER1][SPREAD_LIMIT]    = DeMarker1_MaxSpread;
  #endif

  name[DEMARKER5]                  = "DeMarker M5";
  info[DEMARKER5][ACTIVE]          = DeMarker5_Active;
  info[DEMARKER5][TIMEFRAME]       = M5;
  info[DEMARKER5][OPEN_METHOD]     = DeMarker5_OpenMethod;
  #ifdef __advanced__
  info[DEMARKER5][OPEN_CONDITION1] = DeMarker5_OpenCondition1;
  info[DEMARKER5][OPEN_CONDITION2] = DeMarker5_OpenCondition2;
  info[DEMARKER5][CLOSE_CONDITION] = DeMarker5_CloseCondition;
  conf[DEMARKER5][SPREAD_LIMIT]    = DeMarker5_MaxSpread;
  #endif

  name[DEMARKER15]                  = "DeMarker M15";
  info[DEMARKER15][ACTIVE]          = DeMarker15_Active;
  info[DEMARKER15][TIMEFRAME]       = M15;
  info[DEMARKER15][OPEN_METHOD]     = DeMarker15_OpenMethod;
  #ifdef __advanced__
  info[DEMARKER15][OPEN_CONDITION1] = DeMarker15_OpenCondition1;
  info[DEMARKER15][OPEN_CONDITION2] = DeMarker15_OpenCondition2;
  info[DEMARKER15][CLOSE_CONDITION] = DeMarker15_CloseCondition;
  conf[DEMARKER15][SPREAD_LIMIT]    = DeMarker15_MaxSpread;
  #endif

  name[DEMARKER30]                  = "DeMarker M30";
  info[DEMARKER30][ACTIVE]          = DeMarker30_Active;
  info[DEMARKER30][TIMEFRAME]       = M30;
  info[DEMARKER30][OPEN_METHOD]     = DeMarker30_OpenMethod;
  #ifdef __advanced__
  info[DEMARKER30][OPEN_CONDITION1] = DeMarker30_OpenCondition1;
  info[DEMARKER30][OPEN_CONDITION2] = DeMarker30_OpenCondition2;
  info[DEMARKER30][CLOSE_CONDITION] = DeMarker30_CloseCondition;
  conf[DEMARKER30][SPREAD_LIMIT]    = DeMarker30_MaxSpread;
  #endif

  name[FRACTALS1]                  = "Fractals M1";
  info[FRACTALS1][ACTIVE]          = Fractals1_Active;
  info[FRACTALS1][TIMEFRAME]       = M1;
  info[FRACTALS1][OPEN_METHOD]     = Fractals1_OpenMethod;
  #ifdef __advanced__
  info[FRACTALS1][OPEN_CONDITION1] = Fractals1_OpenCondition1;
  info[FRACTALS1][OPEN_CONDITION2] = Fractals1_OpenCondition2;
  info[FRACTALS1][CLOSE_CONDITION] = Fractals1_CloseCondition;
  conf[FRACTALS1][SPREAD_LIMIT]    = Fractals1_MaxSpread;
  #endif

  name[FRACTALS5]                  = "Fractals M5";
  info[FRACTALS5][ACTIVE]          = Fractals5_Active;
  info[FRACTALS5][TIMEFRAME]       = M5;
  info[FRACTALS5][OPEN_METHOD]     = Fractals5_OpenMethod;
  #ifdef __advanced__
  info[FRACTALS5][OPEN_CONDITION1] = Fractals5_OpenCondition1;
  info[FRACTALS5][OPEN_CONDITION2] = Fractals5_OpenCondition2;
  info[FRACTALS5][CLOSE_CONDITION] = Fractals5_CloseCondition;
  conf[FRACTALS5][SPREAD_LIMIT]    = Fractals5_MaxSpread;
  #endif

  name[FRACTALS15]                  = "Fractals M15";
  info[FRACTALS15][ACTIVE]          = Fractals15_Active;
  info[FRACTALS15][TIMEFRAME]       = M15;
  info[FRACTALS15][OPEN_METHOD]     = Fractals15_OpenMethod;
  #ifdef __advanced__
  info[FRACTALS15][OPEN_CONDITION1] = Fractals15_OpenCondition1;
  info[FRACTALS15][OPEN_CONDITION2] = Fractals15_OpenCondition2;
  info[FRACTALS15][CLOSE_CONDITION] = Fractals15_CloseCondition;
  conf[FRACTALS15][SPREAD_LIMIT]    = Fractals15_MaxSpread;
  #endif

  name[FRACTALS30]                  = "Fractals M30";
  info[FRACTALS30][ACTIVE]          = Fractals30_Active;
  info[FRACTALS30][TIMEFRAME]       = M30;
  info[FRACTALS30][OPEN_METHOD]     = Fractals30_OpenMethod;
  #ifdef __advanced__
  info[FRACTALS30][OPEN_CONDITION1] = Fractals30_OpenCondition1;
  info[FRACTALS30][OPEN_CONDITION2] = Fractals30_OpenCondition2;
  info[FRACTALS30][CLOSE_CONDITION] = Fractals30_CloseCondition;
  conf[FRACTALS30][SPREAD_LIMIT]    = Fractals30_MaxSpread;
  #endif

  ArrSetValueD(conf, FACTOR, 1.0);
  ArrSetValueD(conf, LOT_SIZE, lot_size);

  return (TRUE);
}

/*
 * Update global variables.
 */
void UpdateVariables() {
}

/* END: VARIABLE FUNCTIONS */

/* BEGIN: CONDITION FUNCTIONS */

/*
 * Initialize user defined conditions.
 */
void InitializeConditions() {
  acc_conditions[0][0] = Account_Condition_1;
  acc_conditions[0][1] = Market_Condition_1;
  acc_conditions[0][2] = Action_On_Condition_1;
  acc_conditions[1][0] = Account_Condition_2;
  acc_conditions[1][1] = Market_Condition_2;
  acc_conditions[1][2] = Action_On_Condition_2;
  acc_conditions[2][0] = Account_Condition_3;
  acc_conditions[2][1] = Market_Condition_3;
  acc_conditions[2][2] = Action_On_Condition_3;
  acc_conditions[3][0] = Account_Condition_4;
  acc_conditions[3][1] = Market_Condition_4;
  acc_conditions[3][2] = Action_On_Condition_4;
  acc_conditions[4][0] = Account_Condition_5;
  acc_conditions[4][1] = Market_Condition_5;
  acc_conditions[4][2] = Action_On_Condition_5;
  acc_conditions[5][0] = Account_Condition_6;
  acc_conditions[5][1] = Market_Condition_6;
  acc_conditions[5][2] = Action_On_Condition_6;
  acc_conditions[6][0] = Account_Condition_7;
  acc_conditions[6][1] = Market_Condition_7;
  acc_conditions[6][2] = Action_On_Condition_7;
  acc_conditions[7][0] = Account_Condition_8;
  acc_conditions[7][1] = Market_Condition_8;
  acc_conditions[7][2] = Action_On_Condition_8;
  acc_conditions[8][0] = Account_Condition_9;
  acc_conditions[8][1] = Market_Condition_9;
  acc_conditions[8][2] = Action_On_Condition_9;
  acc_conditions[9][0] = Account_Condition_10;
  acc_conditions[9][1] = Market_Condition_10;
  acc_conditions[9][2] = Action_On_Condition_10;
  acc_conditions[10][0] = Account_Condition_11;
  acc_conditions[10][1] = Market_Condition_11;
  acc_conditions[10][2] = Action_On_Condition_11;
  acc_conditions[11][0] = Account_Condition_12;
  acc_conditions[11][1] = Market_Condition_12;
  acc_conditions[11][2] = Action_On_Condition_12;
}

/*
 * Check account condition.
 */
bool AccountCondition(int condition = C_ACC_NONE) {
  switch(condition) {
    case C_ACC_TRUE:
      return TRUE;
    case C_EQUITY_LOWER:
      return AccountEquity() < AccountBalance();
    case C_EQUITY_HIGHER:
      return AccountEquity() > AccountBalance();
    case C_EQUITY_50PC_HIGH: // Equity 50% high
      return AccountEquity() > AccountBalance() * 2;
    case C_EQUITY_20PC_HIGH: // Equity 20% high
      return AccountEquity() > AccountBalance()/100 * 120;
    case C_EQUITY_10PC_HIGH: // Equity 10% high
      return AccountEquity() > AccountBalance()/100 * 110;
    case C_EQUITY_10PC_LOW:  // Equity 10% low
      return AccountEquity() < AccountBalance()/100 * 90;
    case C_EQUITY_20PC_LOW:  // Equity 20% low
      return AccountEquity() < AccountBalance()/100 * 80;
    case C_EQUITY_50PC_LOW:  // Equity 50% low
      return AccountEquity() <= AccountBalance() / 2;
    case C_MARGIN_USED_50PC: // 50% Margin Used
      return AccountMargin() >= AccountEquity() /100 * 50;
    case C_MARGIN_USED_70PC: // 70% Margin Used
      // Note that in some accounts, Stop Out will occur in your account when equity reaches 70% of your used margin resulting in immediate closing of all positions.
      return AccountMargin() >= AccountEquity() /100 * 70;
    case C_MARGIN_USED_80PC: // 80% Margin Used
      return AccountMargin() >= AccountEquity() /100 * 80;
    case C_MARGIN_USED_90PC: // 90% Margin Used
      return AccountMargin() >= AccountEquity() /100 * 90;
    case C_NO_FREE_MARGIN:
      return AccountFreeMargin() <= 10;
    case C_ACC_IN_LOSS:
      return GetTotalProfit() < 0;
    case C_ACC_IN_PROFIT:
      return GetTotalProfit() > 0;
    case C_DBAL_LT_WEEKLY:
      return daily[MAX_BALANCE] < weekly[MAX_BALANCE];
    case C_DBAL_GT_WEEKLY:
      return daily[MAX_BALANCE] > weekly[MAX_BALANCE];
    case C_WBAL_LT_MONTHLY:
      return weekly[MAX_BALANCE] < monthly[MAX_BALANCE];
    case C_WBAL_GT_MONTHLY:
      return weekly[MAX_BALANCE] > monthly[MAX_BALANCE];
    case C_ACC_IN_TREND:
      return (CheckTrend(TrendMethod) == OP_BUY  && CalculateOrdersByCmd(OP_BUY)  > CalculateOrdersByCmd(OP_SELL))
          || (CheckTrend(TrendMethod) == OP_SELL && CalculateOrdersByCmd(OP_SELL) > CalculateOrdersByCmd(OP_BUY));
    case C_ACC_IN_NON_TREND:
      return !AccountCondition(C_ACC_IN_TREND);
    default:
    case C_ACC_NONE:
      return FALSE;
  }
  return FALSE;
}

/*
 * Check market condition.
 */
bool MarketCondition(int condition = C_MARKET_NONE) {
  switch(condition) {
    case C_MARKET_TRUE:
      return TRUE;
    case C_MA1_FAST_SLOW_OPP: // MA Fast and Slow M1 are in opposite directions.
      return
        (ma_fast[M1][CURR] > ma_fast[M1][PREV] && ma_slow[M1][CURR] < ma_slow[M1][PREV]) ||
        (ma_fast[M1][CURR] < ma_fast[M1][PREV] && ma_slow[M1][CURR] > ma_slow[M1][PREV]);
    case C_MA1_MED_SLOW_OPP: // MA Medium and Slow M1 are in opposite directions.
      return
        (ma_medium[M1][CURR] > ma_medium[M1][PREV] && ma_slow[M1][CURR] < ma_slow[M1][PREV]) ||
        (ma_medium[M1][CURR] < ma_medium[M1][PREV] && ma_slow[M1][CURR] > ma_slow[M1][PREV]);
    case C_MA5_FAST_SLOW_OPP: // MA Fast and Slow M5 are in opposite directions.
      return
        (ma_fast[M5][CURR] > ma_fast[M5][PREV] && ma_slow[M5][CURR] < ma_slow[M5][PREV]) ||
        (ma_fast[M5][CURR] < ma_fast[M5][PREV] && ma_slow[M5][CURR] > ma_slow[M5][PREV]);
    case C_MA5_MED_SLOW_OPP: // MA Medium and Slow M5 are in opposite directions.
      return
        (ma_medium[M5][CURR] > ma_medium[M5][PREV] && ma_slow[M5][CURR] < ma_slow[M5][PREV]) ||
        (ma_medium[M5][CURR] < ma_medium[M5][PREV] && ma_slow[M5][CURR] > ma_slow[M5][PREV]);
    case C_MARKET_BIG_DROP:
      return last_tick_change > MarketSuddenDropSize;
    case C_MARKET_VBIG_DROP:
      return last_tick_change > MarketBigDropSize;
    case C_MARKET_NONE:
    default:
      return FALSE;
  }
  return FALSE;
}

// Check our account if certain conditions are met.
void CheckAccountConditions() {

  // if (VerboseTrace) Print("Calling " + __FUNCTION__ + "()");

  if (!Account_Conditions_Active) return;

  if (bar_time == last_action_time) {
    return; // If action was already executed in the same bar, do not check again.
  }

  string reason;
  for (int i = 0; i < ArrayRange(acc_conditions, 0); i++) {
    if (AccountCondition(acc_conditions[i][0]) && MarketCondition(acc_conditions[i][1]) && acc_conditions[i][2] != A_NONE) {
      reason = "Account condition: " + acc_conditions[i][0] + ", Market condition: " + acc_conditions[i][1] + ", Action: " + acc_conditions[i][2] + " [E: " + ValueToCurrency(AccountEquity()) + "/B: " + ValueToCurrency(AccountBalance()) + "]";
      ActionExecute(acc_conditions[i][2], reason);
    }
  } // end: for

}

/*
 * Get default multiplier lot factor.
 */
double GetDefaultLotFactor() {
  return 1.0;
}

/* BEGIN: STRATEGY FUNCTIONS */


/*
 * Get strategy report based on the total orders.
 */
string GetStrategyReport(string sep = "\n") {
  string output = "Strategy stats: " + sep;
  double pc_loss = 0, pc_won = 0;
  for (int id = 0; id < FINAL_STRATEGY_TYPE_ENTRY; id++) {
    if (info[id][TOTAL_ORDERS] > 0) {
      output += StringFormat("Profit factor: %.2f, ",
                GetStrategyProfitFactor(id));
      output += StringFormat("Total net profit: %.2fpips (%+.2f/%-.2f), ",
        stats[id][TOTAL_NET_PROFIT], stats[id][TOTAL_GROSS_PROFIT], stats[id][TOTAL_GROSS_LOSS]);
      pc_loss = (100 / NormalizeDouble(info[id][TOTAL_ORDERS], 2)) * info[id][TOTAL_ORDERS_LOSS];
      pc_won  = (100 / NormalizeDouble(info[id][TOTAL_ORDERS], 2)) * info[id][TOTAL_ORDERS_WON];
      output += StringFormat("Total orders: %d (Won: %.1f%% [%d] / Loss: %.1f%% [%d])",
                info[id][TOTAL_ORDERS], pc_won, info[id][TOTAL_ORDERS_WON], pc_loss, info[id][TOTAL_ORDERS_LOSS]);
      if (info[id][TOTAL_ERRORS] > 0) output += StringFormat(", Errors: %d", info[id][TOTAL_ERRORS]);
      output += StringFormat(" - %s", name[id]);
      // output += "Total orders: " + info[id][TOTAL_ORDERS] + " (Won: " + DoubleToStr(pc_won, 1) + "% [" + info[id][TOTAL_ORDERS_WON] + "] | Loss: " + DoubleToStr(pc_loss, 1) + "% [" + info[id][TOTAL_ORDERS_LOSS] + "]); ";
      output += sep;
    }
  }
  return output;
}

/*
 * Apply strategy boosting.
 */
void UpdateStrategyFactor(int period) {
  switch (period) {
    case DAILY:
      ApplyStrategyMultiplierFactor(DAILY, 1, BestDailyStrategyMultiplierFactor);
      ApplyStrategyMultiplierFactor(DAILY, -1, WorseDailyStrategyDividerFactor);
      break;
    case WEEKLY:
      if (day_of_week > 1) {
        // FIXME: When commented out with 1.0, the profit is different.
        ApplyStrategyMultiplierFactor(WEEKLY, 1, BestWeeklyStrategyMultiplierFactor);
        ApplyStrategyMultiplierFactor(WEEKLY, -1, WorseWeeklyStrategyDividerFactor);
      }
    break;
    case MONTHLY:
      ApplyStrategyMultiplierFactor(MONTHLY, 1, BestMonthlyStrategyMultiplierFactor);
      ApplyStrategyMultiplierFactor(MONTHLY, -1, WorseMonthlyStrategyDividerFactor);
    break;
  }
}

/*
 * Update strategy lot size.
 */
void UpdateStrategyLotSize() {
  for (int i; i < ArrayRange(conf, 0); i++) {
    conf[i][LOT_SIZE] = lot_size * conf[i][FACTOR];
  }
}

/*
 * Calculate strategy profit factor.
 */
double GetStrategyProfitFactor(int id) {
  if (info[id][TOTAL_ORDERS] > 10 && stats[id][TOTAL_GROSS_LOSS] < 0) {
    return stats[id][TOTAL_GROSS_PROFIT] / -stats[id][TOTAL_GROSS_LOSS];
  } else
    return 1.0;
}

/*
 * Calculate total strategy profit.
 */
double GetTotalProfit() {
  double total_profit = 0;
  for (int id; id < ArrayRange(stats, 0); id++) {
    total_profit += stats[id][TOTAL_NET_PROFIT];
  }
  return total_profit;
}

/*
 * Apply strategy multiplier factor based on the strategy profit or loss.
 */
void ApplyStrategyMultiplierFactor(int period = DAILY, int loss_or_profit = 0, double factor = 1.0) {
  if (GetNoOfStrategies() <= 1 || factor == 1.0) return;
  int key = If(period == MONTHLY, MONTHLY_PROFIT, If(period == WEEKLY, WEEKLY_PROFIT, DAILY_PROFIT));
  string period_name = IfTxt(period == MONTHLY, "montly", IfTxt(period == WEEKLY, "weekly", "daily"));
  int new_strategy = If(loss_or_profit > 0, GetArrKey1ByHighestKey2ValueD(stats, key), GetArrKey1ByLowestKey2ValueD(stats, key));
  if (new_strategy == EMPTY) return;
  int previous = If(loss_or_profit > 0, best_strategy[period], worse_strategy[period]);
  double new_factor = 1.0;
  if (loss_or_profit > 0) { // Best strategy.
    if (info[new_strategy][ACTIVE] && stats[new_strategy][key] > 10 && new_strategy != previous) { // Check if it's different than the previous one.
      if (previous != EMPTY) {
        if (!info[previous][ACTIVE]) info[previous][ACTIVE] = TRUE;
        conf[previous][FACTOR] = GetDefaultLotFactor(); // Set previous strategy multiplier factor to default.
        if (VerboseDebug) Print(__FUNCTION__ + "(): Setting multiplier factor to default for strategy: " + previous);
      }
      best_strategy[period] = new_strategy; // Assign the new worse strategy.
      info[new_strategy][ACTIVE] = TRUE;
      new_factor = GetDefaultLotFactor() * factor;
      conf[new_strategy][FACTOR] = new_factor; // Apply multiplier factor for the new strategy.
      if (VerboseDebug) Print(__FUNCTION__ + "(): Setting multiplier factor to " + new_factor + " for strategy: " + new_strategy + " (period: " + period_name + ")");
    }
  } else { // Worse strategy.
    if (info[new_strategy][ACTIVE] && stats[new_strategy][key] < 10 && new_strategy != previous) { // Check if it's different than the previous one.
      if (previous != EMPTY) {
        if (!info[previous][ACTIVE]) info[previous][ACTIVE] = TRUE;
        conf[previous][FACTOR] = GetDefaultLotFactor(); // Set previous strategy multiplier factor to default.
        if (VerboseDebug) Print(__FUNCTION__ + "(): Setting multiplier factor to default for strategy: " + previous + " to default.");
      }
      worse_strategy[period] = new_strategy; // Assign the new worse strategy.
      if (factor > 0) {
        new_factor = NormalizeDouble(GetDefaultLotFactor() / factor, Digits);
        info[new_strategy][ACTIVE] = TRUE;
        conf[new_strategy][FACTOR] = new_factor; // Apply multiplier factor for the new strategy.
        if (VerboseDebug) Print(__FUNCTION__ + "(): Setting multiplier factor to " + new_factor + " for strategy: " + new_strategy + " (period: " + period_name + ")");
      } else {
        info[new_strategy][ACTIVE] = FALSE;
        //conf[new_strategy][FACTOR] = GetDefaultLotFactor();
        if (VerboseDebug) Print(__FUNCTION__ + "(): Disabling strategy: " + new_strategy);
      }
    }
  }
}

/*
 * Check if RSI period needs any change.
 *
 * FIXME: Doesn't improve much.
 */
void RSI_CheckPeriod() {

  int period;
  // 1 minute period.
  period = M1;
  if (rsi_stats[period][MODE_UPPER] - rsi_stats[period][MODE_LOWER] < RSI1_IncreasePeriod_MinDiff) {
    info[RSI1][CUSTOM_PERIOD] = MathMin(info[RSI1][CUSTOM_PERIOD] + 1, RSI_Period * 2);
    if (VerboseDebug) PrintFormat("Increased " + name[RSI1] + " period to %d", info[RSI1][CUSTOM_PERIOD]);
    // Reset stats.
    rsi_stats[period][MODE_UPPER] = 0;
    rsi_stats[period][MODE_LOWER] = 0;
  } else if (rsi_stats[period][MODE_UPPER] - rsi_stats[period][MODE_LOWER] > RSI1_DecreasePeriod_MaxDiff) {
    info[RSI1][CUSTOM_PERIOD] = MathMax(info[RSI1][CUSTOM_PERIOD] - 1, RSI_Period / 2);
    if (VerboseDebug) PrintFormat("Decreased " + name[RSI1] + " period to %d", info[RSI1][CUSTOM_PERIOD]);
    // Reset stats.
    rsi_stats[period][MODE_UPPER] = 0;
    rsi_stats[period][MODE_LOWER] = 0;
  }
  // 5 minute period.
  period = M5;
  if (rsi_stats[period][MODE_UPPER] - rsi_stats[period][MODE_LOWER] < RSI5_IncreasePeriod_MinDiff) {
    info[RSI5][CUSTOM_PERIOD] = MathMin(info[RSI5][CUSTOM_PERIOD] + 1, RSI_Period * 2);
    if (VerboseDebug) PrintFormat("Increased " + name[RSI5] + " period to %d", info[RSI1][CUSTOM_PERIOD]);
    // Reset stats.
    rsi_stats[period][MODE_UPPER] = 0;
    rsi_stats[period][MODE_LOWER] = 0;
  } else if (rsi_stats[period][MODE_UPPER] - rsi_stats[period][MODE_LOWER] > RSI5_DecreasePeriod_MaxDiff) {
    info[RSI5][CUSTOM_PERIOD] = MathMax(info[RSI5][CUSTOM_PERIOD] - 1, RSI_Period / 2);
    if (VerboseDebug) PrintFormat("Decreased " + name[RSI5] + " period to %d", info[RSI1][CUSTOM_PERIOD]);
    // Reset stats.
    rsi_stats[period][MODE_UPPER] = 0;
    rsi_stats[period][MODE_LOWER] = 0;
  }
  // 15 minute period.

  period = M15;
  if (rsi_stats[period][MODE_UPPER] - rsi_stats[period][MODE_LOWER] < RSI15_IncreasePeriod_MinDiff) {
    info[RSI15][CUSTOM_PERIOD] = MathMin(info[RSI15][CUSTOM_PERIOD] + 1, RSI_Period * 2);
    if (VerboseDebug) PrintFormat("Increased " + name[RSI15] + " period to %d", info[RSI15][CUSTOM_PERIOD]);
    // Reset stats.
    rsi_stats[period][MODE_UPPER] = 0;
    rsi_stats[period][MODE_LOWER] = 0;
  } else if (rsi_stats[period][MODE_UPPER] - rsi_stats[period][MODE_LOWER] > RSI15_DecreasePeriod_MaxDiff) {
    info[RSI15][CUSTOM_PERIOD] = MathMax(info[RSI15][CUSTOM_PERIOD] - 1, RSI_Period / 2);
    if (VerboseDebug) PrintFormat("Decreased " + name[RSI15] + " period to %d", info[RSI15][CUSTOM_PERIOD]);
    // Reset stats.
    rsi_stats[period][MODE_UPPER] = 0;
    rsi_stats[period][MODE_LOWER] = 0;
  }
  /*
  Print(__FUNCTION__ + "(): M1: Avg: " + rsi_stats[period][0] + ", Min: " + rsi_stats[period][MODE_LOWER] + ", Max: " + rsi_stats[period][MODE_UPPER] + ", Diff: " + ( rsi_stats[period][MODE_UPPER] - rsi_stats[period][MODE_LOWER] ));
  period = M5;
  Print(__FUNCTION__ + "(): M5: Avg: " + rsi_stats[period][0] + ", Min: " + rsi_stats[period][MODE_LOWER] + ", Max: " + rsi_stats[period][MODE_UPPER] + ", Diff: " + ( rsi_stats[period][MODE_UPPER] - rsi_stats[period][MODE_LOWER] ));
  period = M15;
  Print(__FUNCTION__ + "(): M15: Avg: " + rsi_stats[period][0] + ", Min: " + rsi_stats[period][MODE_LOWER] + ", Max: " + rsi_stats[period][MODE_UPPER] + ", Diff: " + ( rsi_stats[period][MODE_UPPER] - rsi_stats[period][MODE_LOWER] ));
  period = M30;
  Print(__FUNCTION__ + "(): M30: Avg: " + rsi_stats[period][0] + ", Min: " + rsi_stats[period][MODE_LOWER] + ", Max: " + rsi_stats[period][MODE_UPPER] + ", Diff: " + ( rsi_stats[period][MODE_UPPER] - rsi_stats[period][MODE_LOWER] ));
  */
}

// FIXME: Doesn't improve anything.
bool RSI_IncreasePeriod(int period = M1, int condition = 0) {
  bool result = condition > 0;
  if ((condition &   1) != 0) result = result && (rsi_stats[period][MODE_UPPER] > 50 + RSI_OpenLevel + RSI_OpenLevel / 2 && rsi_stats[period][MODE_LOWER] < 50 - RSI_OpenLevel - RSI_OpenLevel / 2);
  if ((condition &   2) != 0) result = result && (rsi_stats[period][MODE_UPPER] > 50 + RSI_OpenLevel + RSI_OpenLevel / 2 || rsi_stats[period][MODE_LOWER] < 50 - RSI_OpenLevel - RSI_OpenLevel / 2);
  if ((condition &   4) != 0) result = result && (rsi_stats[period][0] < 50 + RSI_OpenLevel + RSI_OpenLevel / 3 && rsi_stats[period][0] > 50 - RSI_OpenLevel - RSI_OpenLevel / 3);
  // if ((condition &   4) != 0) result = result || rsi_stats[period][0] < 50 + RSI_OpenLevel;
  if ((condition &   8) != 0) result = result && rsi_stats[period][MODE_UPPER] - rsi_stats[period][MODE_LOWER] < 50;
  // if ((condition &  16) != 0) result = result && rsi[period][CURR] - rsi[period][PREV] > rsi[period][PREV] - rsi[period][FAR];
  // if ((condition &  32) != 0) result = result && Open[CURR] > Close[PREV];
  return result;
}

// FIXME: Doesn't improve anything.
bool RSI_DecreasePeriod(int period = M1, int condition = 0) {
  bool result = condition > 0;
  if ((condition &   1) != 0) result = result && (rsi_stats[period][MODE_UPPER] <= 50 + RSI_OpenLevel && rsi_stats[period][MODE_LOWER] >= 50 - RSI_OpenLevel);
  if ((condition &   2) != 0) result = result && (rsi_stats[period][MODE_UPPER] <= 50 + RSI_OpenLevel || rsi_stats[period][MODE_LOWER] >= 50 - RSI_OpenLevel);
  // if ((condition &   4) != 0) result = result && (rsi_stats[period][0] > 50 + RSI_OpenLevel / 3 || rsi_stats[period][0] < 50 - RSI_OpenLevel / 3);
  // if ((condition &   4) != 0) result = result && rsi_stats[period][MODE_UPPER] > 50 + (RSI_OpenLevel / 3);
  // if ((condition &   8) != 0) result = result && && rsi_stats[period][MODE_UPPER] < 50 - (RSI_OpenLevel / 3);
  // if ((condition &  16) != 0) result = result && rsi[period][CURR] - rsi[period][PREV] > rsi[period][PREV] - rsi[period][FAR];
  // if ((condition &  32) != 0) result = result && Open[CURR] > Close[PREV];
  return result;
}


/*
 * Return strategy id by order magic number.
 */
int GetIdByMagic(int magic = EMPTY) {
  if (magic == EMPTY) magic = OrderMagicNumber();
  int id = magic - MagicNumber;
  return If(CheckOurMagicNumber(magic), id, EMPTY);
}

/* END: STRATEGY FUNCTIONS */

/* BEGIN: DISPLAYING FUNCTIONS */

string GetDailyReport() {
  string output = "Daily max: ";
  int key;
  // output += "Low: "     + daily[MAX_LOW] + "; ";
  // output += "High: "    + daily[MAX_HIGH] + "; ";
  output += "Tick: "    + daily[MAX_TICK] + "; ";
  // output += "Drop: "    + daily[MAX_DROP] + "; ";
  output += "Spread: "  + daily[MAX_SPREAD] + "; ";
  output += "Loss: "    + daily[MAX_LOSS] + "; ";
  output += "Profit: "  + daily[MAX_PROFIT] + "; ";
  output += "Equity: "  + daily[MAX_EQUITY] + "; ";
  output += "Balance: " + daily[MAX_BALANCE] + "; ";
  //output += GetAccountTextDetails() + "; " + GetOrdersStats();

  key = GetArrKey1ByHighestKey2ValueD(stats, DAILY_PROFIT);
  if (key >= 0) output += "Best: " + name[key] + " (" + stats[key][DAILY_PROFIT] + "p); ";
  key = GetArrKey1ByLowestKey2ValueD(stats, DAILY_PROFIT);
  if (key >= 0) output += "Worse: " + name[key] + " (" + stats[key][DAILY_PROFIT] + "p); ";

  return output;
}

string GetWeeklyReport() {
  string output = "Weekly max: ";
  int key;
  // output =+ GetAccountTextDetails() + "; " + GetOrdersStats();
  // output += "Low: "     + weekly[MAX_LOW] + "; ";
  // output += "High: "    + weekly[MAX_HIGH] + "; ";
  output += "Tick: "    + weekly[MAX_TICK] + "; ";
  // output += "Drop: "    + weekly[MAX_DROP] + "; ";
  output += "Spread: "  + weekly[MAX_SPREAD] + "; ";
  output += "Loss: "    + weekly[MAX_LOSS] + "; ";
  output += "Profit: "  + weekly[MAX_PROFIT] + "; ";
  output += "Equity: "  + weekly[MAX_EQUITY] + "; ";
  output += "Balance: " + weekly[MAX_BALANCE] + "; ";

  key = GetArrKey1ByHighestKey2ValueD(stats, WEEKLY_PROFIT);
  if (key >= 0) output += "Best: " + name[key] + " (" + stats[key][WEEKLY_PROFIT] + "p); ";
  key = GetArrKey1ByLowestKey2ValueD(stats, WEEKLY_PROFIT);
  if (key >= 0) output += "Worse: " + name[key] + " (" + stats[key][WEEKLY_PROFIT] + "p); ";

  return output;
}

string GetMonthlyReport() {
  string output = "Monthly max: ";
  int key;
  // output =+ GetAccountTextDetails() + "; " + GetOrdersStats();
  // output += "Low: "     + monthly[MAX_LOW] + "; ";
  // output += "High: "    + monthly[MAX_HIGH] + "; ";
  output += "Tick: "    + monthly[MAX_TICK] + "; ";
  // output += "Drop: "    + monthly[MAX_DROP] + "; ";
  output += "Spread: "  + monthly[MAX_SPREAD] + "; ";
  output += "Loss: "    + monthly[MAX_LOSS] + "; ";
  output += "Profit: "  + monthly[MAX_PROFIT] + "; ";
  output += "Equity: "  + monthly[MAX_EQUITY] + "; ";
  output += "Balance: " + monthly[MAX_BALANCE] + "; ";

  key = GetArrKey1ByHighestKey2ValueD(stats, MONTHLY_PROFIT);
  if (key >= 0) output += "Best: " + name[key] + " (" + stats[key][MONTHLY_PROFIT] + "p); ";
  key = GetArrKey1ByLowestKey2ValueD(stats, MONTHLY_PROFIT);
  if (key >= 0) output += "Worse: " + name[key] + " (" + stats[key][MONTHLY_PROFIT] + "p); ";

  return output;
}

string DisplayInfoOnChart(bool on_chart = TRUE, string sep = "\n") {
  string output;
  // Prepare text for Stop Out.
  string stop_out_level = "Stop Out: " + AccountStopoutLevel();
  if (AccountStopoutMode() == 0) stop_out_level += "%"; else stop_out_level += AccCurrency;
  // Prepare text to display max orders.
  string text_max_orders = "Max orders: " + max_orders + " (Per type: " + GetMaxOrdersPerType() + ")";
  // Prepare text to display spread.
  string text_spread = "Spread: " + ValueToPips(GetMarketSpread());
  // string text_spread = "Spread (pips): " + DoubleToStr(GetMarketSpread(TRUE) / pts_per_pip, Digits - PipDigits) + " / Stop level (pips): " + DoubleToStr(market_stoplevel / pts_per_pip, Digits - PipDigits);
  // Check trend.
  string trend = "Neutral.";
  if (CheckTrend(TrendMethod) == OP_BUY) trend = "Bullish";
  if (CheckTrend(TrendMethod) == OP_SELL) trend = "Bearish";
  // Print actual info.
  string indent = "";
  indent = "                      "; // if (total_orders > 5)?
  output = indent + "------------------------------------------------" + sep
                  + indent + StringFormat("| %s v%s (Status: %s)%s", ea_name, ea_version, IfTxt(ea_active, "ACTIVE", "NOT ACTIVE"), sep)
                  + indent + "| ACCOUNT INFORMATION:" + sep
                  + indent + "| Server Time: " + TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS) + sep
                  + indent + "| Acc Number: " + AccountNumber() + "; Acc Name: " + AccountName() + "; Broker: " + AccountCompany() + " (Type: " + account_type + ")" + sep
                  + indent + "| Equity: " + ValueToCurrency(AccountEquity()) + "; Balance: " + ValueToCurrency(AccountBalance()) + "; Leverage: 1:" + DoubleToStr(AccountLeverage(), 0)  + "" + sep
                  + indent + "| Used Margin: " + ValueToCurrency(AccountMargin()) + "; Free: " + ValueToCurrency(AccountFreeMargin()) + "; " + stop_out_level + "" + sep
                  + indent + "| Lot size: " + DoubleToStr(lot_size, VolumeDigits) + "; " + text_max_orders + "; Risk ratio: " + DoubleToStr(risk_ratio, 1) + " (" + GetRiskRatioText() + ")" + sep
                  + indent + "| " + GetOrdersStats("" + sep + indent + "| ") + "" + sep
                  + indent + "| Last error: " + last_err + "" + sep
                  + indent + "| Last message: " + GetLastMessage() + "" + sep
                  + indent + "| ------------------------------------------------" + sep
                  + indent + "| MARKET INFORMATION:" + sep
                  + indent + "| " + text_spread + "" + sep
                  + indent + "| Trend: " + trend + "" + sep
                  // + indent // + "Mini lot: " + MarketInfo(Symbol(), MODE_MINLOT) + "" + sep
                  + indent + "| ------------------------------------------------" + sep
                  + indent + "| STATISTICS:" + sep
                  + indent + "| " + GetDailyReport() + "" + sep
                  + indent + "| " + GetWeeklyReport() + "" + sep
                  + indent + "| " + GetMonthlyReport() + "" + sep
                  + indent + "------------------------------------------------" + sep
                  ;
  if (on_chart) {
    /* FIXME: Text objects can't contain multi-line text so we need to create a separate object for each line instead.
    ObjectCreate(ea_name, OBJ_LABEL, 0, 0, 0, 0); // Create text object with given name.
    // Set pixel co-ordinates from top left corner (use OBJPROP_CORNER to set a different corner).
    ObjectSet(ea_name, OBJPROP_XDISTANCE, 0);
    ObjectSet(ea_name, OBJPROP_YDISTANCE, 10);
    ObjectSetText(ea_name, output, 10, "Arial", Red); // Set text, font, and colour for object.
    // ObjectDelete(ea_name);
    */
    Comment(output);
    WindowRedraw(); // Redraws the current chart forcedly.
  }
  return output;
}

void SendEmail(string sep = "\n") {
  string mail_title = "Trading Info - " + ea_name;
  string body = "Trade Information" + sep;
  body += sep + StringFormat("Event: %s", "Trade Opened");
  body += sep + StringFormat("Currency Pair: %s", _Symbol);
  body += sep + StringFormat("Time: %s", TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS));
  body += sep + StringFormat("Order Type: %s", _OrderType_str(OrderType()));
  body += sep + StringFormat("Price: %s", DoubleToStr(OrderOpenPrice(), Digits));
  body += sep + StringFormat("Lot size: %s", DoubleToStr(OrderLots(), VolumeDigits));
  body += sep + StringFormat("Current Balance: %s", ValueToCurrency(AccountBalance()));
  body += sep + StringFormat("Current Equity: %s", ValueToCurrency(AccountEquity()));


  SendMail(mail_title, body);
}

string GetOrderTextDetails() {
   return StringConcatenate("Order Details: ",
      "Ticket: ", OrderTicket(), "; ",
      "Time: ", TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS), "; ",
      "Comment: ", OrderComment(), "; ",
      "Commision: ", OrderCommission(), "; ",
      "Symbol: ", StringSubstr(Symbol(), 0, 6), "; ",
      "Type: ", _OrderType_str(OrderType()), "; ",
      "Expiration: ", OrderExpiration(), "; ",
      "Open Price: ", DoubleToStr(OrderOpenPrice(), Digits), "; ",
      "Close Price: ", DoubleToStr(OrderClosePrice(), Digits), "; ",
      "Take Profit: ", OrderProfit(), "; ",
      "Stop Loss: ", OrderStopLoss(), "; ",
      "Swap: ", OrderSwap(), "; ",
      "Lot size: ", OrderLots(), "; "
   );
}

// Get order statistics in percentage for each strategy.
string GetOrdersStats(string sep = "\n") {
  // Prepare text for Total Orders.
  string total_orders_text = "Open Orders: " + total_orders;
  total_orders_text += " +" + CalculateOrdersByCmd(OP_BUY) + "/-" + CalculateOrdersByCmd(OP_SELL);
  total_orders_text += " [" + DoubleToStr(CalculateOpenLots(), 2) + " lots]";
  total_orders_text += " (other: " + GetTotalOrders(FALSE) + ")";
  // Prepare data about open orders per strategy type.
  string orders_per_type = "Stats: "; // Display open orders per type.
  if (total_orders > 0) {
    for (int i = 0; i < FINAL_STRATEGY_TYPE_ENTRY; i++) {
      if (open_orders[i] > 0) {
        orders_per_type += name[i] + ": " + MathFloor(100 / total_orders * open_orders[i]) + "%, ";
      }
    }
  } else {
    orders_per_type += "No orders open yet.";
  }
  return orders_per_type + sep + total_orders_text;
}

/*
 * Get information about account conditions in text format.
 */
string GetAccountTextDetails(string sep = "; ") {
   return StringConcatenate("Account Details: ",
      "Time: ", TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS), sep,
      "Account Balance: ", ValueToCurrency(AccountBalance()), sep,
      "Account Equity: ", ValueToCurrency(AccountEquity()), sep,
      "Used Margin: ", ValueToCurrency(AccountMargin()), sep,
      "Free Margin: ", ValueToCurrency(AccountFreeMargin()), sep,
      "No of Orders: ", total_orders, " (BUY/SELL: ", CalculateOrdersByCmd(OP_BUY), "/", CalculateOrdersByCmd(OP_SELL), ")", sep,
      "Risk Ratio: ", DoubleToStr(risk_ratio, 1)
   );
}

/*
 * Get information about market conditions in text format.
 */
string GetMarketTextDetails() {
   return StringConcatenate("MarketInfo: ",
     "Symbol: ", Symbol(), "; ",
     "Ask: ", DoubleToStr(Ask, Digits), "; ",
     "Bid: ", DoubleToStr(Bid, Digits), "; ",
     "Spread: ", GetMarketSpread(TRUE), " points = ", ValueToPips(GetMarketSpread()), " pips; "
   );
}

/*
 * Get account summary text.
 */
string GetSummaryText() {
  return GetAccountTextDetails();
}

/*
 * Get risk ratio text based on the value.
 */
string GetRiskRatioText() {
  string text = "Normal";
  if (risk_ratio < 0.2) text = "Extremely risky!";
  else if (risk_ratio < 0.3) text = "Very risky!";
  else if (risk_ratio < 0.5) text = "Risky!";
  else if (risk_ratio < 0.9) text = "Below normal, but ok";
  else if (risk_ratio > 2.0) text = "Very high";
  else if (risk_ratio > 1.0) text = "High";
  return text;
}

/*
 * Print multi-line text.
 */
void PrintText(string text) {
  string result[];
  ushort usep = StringGetCharacter("\n", 0);
  for (int i = StringSplit(text, usep, result); i > 0; i--) {
    Print(result[i]);
  }
}

/* END: DISPLAYING FUNCTIONS */

/* BEGIN: CONVERTING FUNCTIONS */

// Returns OrderType as a text.
string _OrderType_str(int _OrderType) {
  switch ( _OrderType ) {
    case OP_BUY:          return("Buy");
    case OP_SELL:         return("Sell");
    case OP_BUYLIMIT:     return("BuyLimit");
    case OP_BUYSTOP:      return("BuyStop");
    case OP_SELLLIMIT:    return("SellLimit");
    case OP_SELLSTOP:     return("SellStop");
    default:              return("UnknownOrderType");
  }
}

/* END: CONVERTING FUNCTIONS */

/* BEGIN: ARRAY FUNCTIONS */

/*
 * Find lower value within the array.
 */
double LowestArrValue(double& arr[]) {
  return (arr[ArrayMinimum(arr)]);
}

/*
 * Find higher value within the array.
 */
double HighestArrValue(double& arr[]) {
   return (arr[ArrayMaximum(arr)]);
}

/*
 * Find lower value within the array.
 */
double LowestArrValue2(double& arr[][], int key1) {
  double lowest = 0;
  for (int i = 0; i < ArrayRange(arr, 1); i++) {
    if (arr[key1][i] < lowest) {
      lowest = arr[key1][i];
    }
  }
  return lowest;
}

/*
 * Find higher value within the array.
 */
double HighestArrValue2(double& arr[][], int key1) {
  double highest = 0;
  for (int i = 0; i < ArrayRange(arr, 1); i++) {
    if (arr[key1][i] > highest) {
      highest = arr[key1][i];
    }
  }
  return highest;
}

int HighestValueByKey(double& arr[][], int key) {
  double highest = 0;
  for (int i = 0; i < ArrayRange(arr, 1); i++) {
    if (arr[key][i] > highest) {
      highest = arr[key][i];
    }
  }
  return highest;
}

int LowestValueByKey(double& arr[][], int key) {
  double lowest = 0;
  for (int i = 0; i < ArrayRange(arr, 1); i++) {
    if (arr[key][i] < lowest) {
      lowest = arr[key][i];
    }
  }
  return lowest;
}

/*
int GetLowestArrDoubleValue(double& arr[][], int key) {
  double lowest = -1;
  for (int i = 0; i < ArrayRange(arr, 0); i++) {
    for (int j = 0; j < ArrayRange(arr, 1); j++) {
      if (arr[i][j] < lowest) {
        lowest = arr[i][j];
      }
    }
  }
  return lowest;
}*/

/*
 * Find key in array of integers with highest value.
 */
int GetArrKey1ByHighestKey2Value(int& arr[][], int key2) {
  int key1 = EMPTY;
  int highest = 0;
  for (int i = 0; i < ArrayRange(arr, 0); i++) {
      if (arr[i][key2] > highest) {
        highest = arr[i][key2];
        key1 = i;
      }
  }
  return key1;
}

/*
 * Find key in array of integers with lowest value.
 */
int GetArrKey1ByLowestKey2Value(int& arr[][], int key2) {
  int key1 = EMPTY;
  int lowest = 0;
  for (int i = 0; i < ArrayRange(arr, 0); i++) {
      if (arr[i][key2] < lowest) {
        lowest = arr[i][key2];
        key1 = i;
      }
  }
  return key1;
}

/*
 * Find key in array of doubles with highest value.
 */
int GetArrKey1ByHighestKey2ValueD(double& arr[][], int key2) {
  int key1 = EMPTY;
  int highest = 0;
  for (int i = 0; i < ArrayRange(arr, 0); i++) {
      if (arr[i][key2] > highest) {
        highest = arr[i][key2];
        key1 = i;
      }
  }
  return key1;
}

/*
 * Find key in array of doubles with lowest value.
 */
int GetArrKey1ByLowestKey2ValueD(double& arr[][], int key2) {
  int key1 = EMPTY;
  int lowest = 0;
  for (int i = 0; i < ArrayRange(arr, 0); i++) {
      if (arr[i][key2] < lowest) {
        lowest = arr[i][key2];
        key1 = i;
      }
  }
  return key1;
}

/*
 * Set array value for items with specific keys.
 */
void ArrSetValueD(double& arr[][], int key, double value) {
  for (int i = 0; i < ArrayRange(info, 0); i++) {
    arr[i][key] = value;
  }
}

/* END: ARRAY FUNCTIONS */

/* BEGIN: ACTION FUNCTIONS */

// Execute action to close most profitable order.
bool ActionCloseMostProfitableOrder(){
  bool result = FALSE;
  int selected_ticket = 0;
  double ticket_profit = 0;
  for (int order = 0; order < OrdersTotal(); order++) {
    if (OrderSelect(order, SELECT_BY_POS, MODE_TRADES))
     if (OrderSymbol() == Symbol() && CheckOurMagicNumber()) {
       if (GetOrderProfit() > ticket_profit) {
         selected_ticket = OrderTicket();
         ticket_profit = GetOrderProfit();
       }
     }
  }

  if (selected_ticket > 0) {
    return TaskAddCloseOrder(selected_ticket, A_CLOSE_ORDER_PROFIT);
  } else if (VerboseDebug) {
    Print(__FUNCTION__ + "(): Can't find any profitable order as requested.");
  }
  return (FALSE);
}

// Execute action to close most unprofitable order.
bool ActionCloseMostUnprofitableOrder(){
  int selected_ticket = 0;
  double ticket_profit = 0;
  for (int order = 0; order < OrdersTotal(); order++) {
    if (OrderSelect(order, SELECT_BY_POS, MODE_TRADES))
     if (OrderSymbol() == Symbol() && CheckOurMagicNumber()) {
       if (GetOrderProfit() < ticket_profit) {
         selected_ticket = OrderTicket();
         ticket_profit = GetOrderProfit();
       }
     }
  }

  if (selected_ticket > 0) {
    return TaskAddCloseOrder(selected_ticket, A_CLOSE_ORDER_LOSS);
  } else if (VerboseDebug) {
    Print(__FUNCTION__ + "(): Can't find any unprofitable order as requested.");
  }
  return (FALSE);
}

// Execute action to close all profitable orders.
bool ActionCloseAllProfitableOrders(){
  bool result = FALSE;
  int selected_orders;
  double ticket_profit = 0, total_profit = 0;
  for (int order = 0; order < OrdersTotal(); order++) {
    if (OrderSelect(order, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol() && CheckOurMagicNumber())
       ticket_profit = GetOrderProfit();
       if (ticket_profit > 0) {
         result = TaskAddCloseOrder(OrderTicket(), A_CLOSE_ALL_IN_PROFIT);
         selected_orders++;
         total_profit += ticket_profit;
     }
  }

  if (selected_orders > 0 && VerboseInfo) {
    Print(__FUNCTION__ + "(): Queued " + selected_orders + " orders to close with expected profit of " + total_profit + " pips.");
  }
  return (result);
}

// Execute action to close all unprofitable orders.
bool ActionCloseAllUnprofitableOrders(){
  bool result = FALSE;
  int selected_orders;
  double ticket_profit = 0, total_profit = 0;
  for (int order = 0; order < OrdersTotal(); order++) {
    if (OrderSelect(order, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol() && CheckOurMagicNumber())
       ticket_profit = GetOrderProfit();
       if (ticket_profit < 0) {
         result = TaskAddCloseOrder(OrderTicket(), A_CLOSE_ALL_IN_LOSS);
         selected_orders++;
         total_profit += ticket_profit;
     }
  }

  if (selected_orders > 0 && VerboseInfo) {
    Print(__FUNCTION__ + "(): Queued " + selected_orders + " orders to close with expected loss of " + total_profit + " pips.");
  }
  return (result);
}

// Execute action to close all orders by specified type.
bool ActionCloseAllOrdersByType(int cmd = EMPTY, int reason = 0){
  int selected_orders;
  double ticket_profit = 0, total_profit = 0;
  if (cmd == EMPTY) return (FALSE);
  for (int order = 0; order < OrdersTotal(); order++) {
    if (OrderSelect(order, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol() && CheckOurMagicNumber())
       if (OrderType() == cmd) {
         TaskAddCloseOrder(OrderTicket(), reason);
         selected_orders++;
         total_profit += ticket_profit;
     }
  }

  if (selected_orders > 0 && VerboseInfo) {
    Print(__FUNCTION__ + "(" + _OrderType_str(cmd) + "): Queued " + selected_orders + " orders to close with expected profit of " + total_profit + " pips.");
  }
  return (FALSE);
}

/*
 * Execute action to close all orders.
 *
 * Notes:
 * - Useful when equity is low or high in order to secure our assets and avoid higher risk.
 * - Executing this action could indicate our poor money management and risk further losses.
 *
 * Parameter: only_ours
 *   When True (default), we should close only ours orders (determined by our magic number).
 *   When False, we should close all orders (including other stragegies if any).
 *     This is due the account equity and balance are shared,
 *     so potentially we don't know which strategy generated this kind of situation,
 *     therefore closing all make the things more predictable and to avoid any suprices.
 */
int ActionCloseAllOrders(bool only_ours = TRUE) {
   int processed = 0;
   int total = OrdersTotal();
   for (int order = 0; order < total; order++) {
      if (OrderSelect(order, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol() && OrderTicket() > 0) {
         if (only_ours && !CheckOurMagicNumber()) continue;
         TaskAddCloseOrder(OrderTicket(), A_CLOSE_ALL_ORDERS); // Add task to re-try.
         processed++;
      } else {
        if (VerboseDebug)
         Print(__FUNCTION__ + "(): Error: Order Pos: " + order + "; Message: ", GetErrorText(GetLastError()));
      }
   }

   if (processed > 0 && VerboseInfo) {
     Print(__FUNCTION__ + "(): Queued " + processed + " orders out of " + total + " for closure.");
   }
   return (processed > 0);
}

// Execute action by id. See: EA_Conditions parameters.
// Note: Executing this can be potentially dangerous for the account if not used wisely.
bool ActionExecute(int action_id, string reason) {
  bool result = FALSE;
  int cmd;
  switch (action_id) {
    case A_NONE:
      result = TRUE;
      if (VerboseTrace) Print(__FUNCTION__ + "(): No action taken. Action call reason: " + reason);
      // Nothing.
      break;
    case A_CLOSE_ORDER_PROFIT: /* 1 */
      result = ActionCloseMostProfitableOrder();
      break;
    case A_CLOSE_ORDER_LOSS: /* 2 */
      result = ActionCloseMostUnprofitableOrder();
      break;
    case A_CLOSE_ALL_IN_PROFIT: /* 3 */
      result = ActionCloseAllProfitableOrders();
      break;
    case A_CLOSE_ALL_IN_LOSS: /* 4 */
      result = ActionCloseAllUnprofitableOrders();
      break;
    case A_CLOSE_ALL_PROFIT_SIDE: /* 5 */
      // TODO
      cmd = GetProfitableSide();
      if (cmd != EMPTY) {
        result = ActionCloseAllOrdersByType(cmd, reason);
      }
      break;
    case A_CLOSE_ALL_LOSS_SIDE: /* 6 */
      cmd = GetProfitableSide();
      if (cmd != EMPTY) {
        result = ActionCloseAllOrdersByType(CmdOpp(cmd), reason);
      }
      break;
    case A_CLOSE_ALL_TREND: /* 7 */
      cmd = CheckTrend(TrendMethodAction);
      if (cmd != EMPTY) {
        result = ActionCloseAllOrdersByType(cmd, reason);
      }
      break;
    case A_CLOSE_ALL_NON_TREND: /* 8 */
      cmd = CheckTrend(TrendMethodAction);
      if (cmd != EMPTY) {
        result = ActionCloseAllOrdersByType(CmdOpp(cmd), reason);
      }
      break;
    case A_CLOSE_ALL_ORDERS: /* 9 */
      result = ActionCloseAllOrders();
      break;
      /*
    case A_RISK_REDUCE:
      result = ActionRiskReduce();
      break;
    case A_RISK_INCREASE:
      result = ActionRiskIncrease();
      break;
      */
      /*
    case A_ORDER_STOPS_DECREASE:
      // result = TightenStops();
      break;
    case A_ORDER_PROFIT_DECREASE:
      // result = TightenProfits();
      break;*/
    default:
      if (VerboseDebug) Print(__FUNCTION__ + "(): Unknown action id: ", action_id);
  }
  TaskProcessList(TRUE); // Process task list immediately after action has been taken.
  if (VerboseInfo) Print(__FUNCTION__ + "(): " + GetAccountTextDetails() + GetOrdersStats());
  if (result) {
    if (VerboseDebug && action_id != A_NONE) Print(__FUNCTION__ + "(): Action id: " + action_id + "; reason: " + reason);
    last_action_time = last_bar_time; // Set last execution bar time.
    Message(__FUNCTION__ + ": " + reason);
  } else {
    if (VerboseDebug) Print(__FUNCTION__ + "(): Failed to execute action id: " + action_id + "; reason: " + reason);
  }
  return result;
}

/* END: ACTION FUNCTIONS */

/* BEGIN: TICKET LIST/HISTORY CHECK FUNCTIONS */

/*
 * Add ticket to list for further processing.
 */
bool TicketAdd(int ticket_no) {
  int i, slot = EMPTY;
  int size = ArraySize(tickets);
  // Check if ticket is already in the list and at the same time find the empty slot.
  for (i = 0; i < size; i++) {
    if (tickets[i] == ticket_no) {
      return (TRUE); // Ticket already in the list.
    } else if (slot < 0 && tickets[i] == 0) {
      slot = i;
    }
  }
  // Resize array if slot has not been allocated.
  if (slot == EMPTY) {
    if (size < 1000) { // Set array hard limit to prevent memory leak.
      ArrayResize(tickets, size + 10);
      // ArrayFill(tickets, size - 1, ArraySize(tickets) - size - 1, 0);
      if (VerboseDebug) Print(__FUNCTION__ + "(): Couldn't allocate Ticket slot, re-sizing the array. New size: ",  (size + 1), ", Old size: ", size);
      slot = size;
    }
    return (FALSE); // Array exceeded hard limit, probably because of some memory leak.
  }

  tickets[slot] = ticket_no;
  return (TRUE);
}

/*
 * Remove ticket from the list after it has been processed.
 */
bool TicketRemove(int ticket_no) {
  for (int i = 0; i < ArraySize(tickets); i++) {
    if (tickets[i] == ticket_no) {
      tickets[i] = 0; // Remove the ticket number from the array slot.
      return (TRUE); // Ticket has been removed successfully.
    }
  }
  return (FALSE);
}

/*
 * Process order history.
 */
void CheckHistory() {
  for(int pos = last_history_check; pos < HistoryTotal(); pos++) {
    if (!OrderSelect(pos, SELECT_BY_POS, MODE_HISTORY)) continue;
    if (OrderCloseTime() > last_history_check && CheckOurMagicNumber()) {
      OrderCalc();
    }
  }
  last_history_check = pos;
}

/* END: TICKET LIST/HISTORY CHECK FUNCTIONS */

/* BEGIN: TASK FUNCTIONS */

// Add new closing order task.
bool TaskAddOrderOpen(int cmd, int volume, int order_type, string order_comment) {
  int key = cmd+volume+order_type;
  int job_id = TaskFindEmptySlot(cmd+volume+order_type);
  if (job_id >= 0) {
    todo_queue[job_id][0] = key;
    todo_queue[job_id][1] = TASK_ORDER_OPEN;
    todo_queue[job_id][2] = MaxTries; // Set number of retries.
    todo_queue[job_id][3] = cmd;
    todo_queue[job_id][4] = volume;
    todo_queue[job_id][5] = order_type;
    todo_queue[job_id][6] = order_comment;
    // Print(__FUNCTION__ + "(): Added task (", job_id, ") for ticket: ", todo_queue[job_id][0], ", type: ", todo_queue[job_id][1], " (", todo_queue[job_id][3], ").");
    return TRUE;
  } else {
    return FALSE; // Job not allocated.
  }
}

// Add new close task by job id.
bool TaskAddCloseOrder(int ticket_no, int reason = 0) {
  int job_id = TaskFindEmptySlot(ticket_no);
  if (job_id >= 0) {
    todo_queue[job_id][0] = ticket_no;
    todo_queue[job_id][1] = TASK_ORDER_CLOSE;
    todo_queue[job_id][2] = MaxTries; // Set number of retries.
    todo_queue[job_id][3] = reason;
    // if (VerboseTrace) Print("TaskAddCloseOrder(): Allocated task (id: ", job_id, ") for ticket: ", todo_queue[job_id][0], ".");
    return TRUE;
  } else {
    if (VerboseTrace) Print(__FUNCTION__ + "(): Failed to allocate close task for ticket: " + ticket_no);
    return FALSE; // Job is not allocated.
  }
}

/*
 * Add new task to recalculate loss/profit.
 */
bool TaskAddCalcStats(int ticket_no, int order_type = EMPTY) {
  int job_id = TaskFindEmptySlot(ticket_no);
  if (job_id >= 0) {
    todo_queue[job_id][0] = ticket_no;
    todo_queue[job_id][1] = TASK_CALC_STATS;
    todo_queue[job_id][2] = MaxTries; // Set number of retries.
    todo_queue[job_id][3] = order_type;
    // if (VerboseTrace) Print(__FUNCTION__ + "(): Allocated task (id: ", job_id, ") for ticket: ", todo_queue[job_id][0], ".");
    return TRUE;
  } else {
    if (VerboseTrace) Print(__FUNCTION__ + "(): Failed to allocate task for ticket: " + ticket_no);
    return FALSE; // Job is not allocated.
  }
}

// Remove specific task.
bool TaskRemove(int job_id) {
  todo_queue[job_id][0] = 0;
  todo_queue[job_id][2] = 0;
  // if (VerboseTrace) Print(__FUNCTION__ + "(): Task removed for id: " + job_id);
  return TRUE;
}

// Check if task for specific ticket already exists.
bool TaskExistByKey(int key) {
  for (int job_id = 0; job_id < ArrayRange(todo_queue, 0); job_id++) {
    if (todo_queue[job_id][0] == key) {
      // if (VerboseTrace) Print(__FUNCTION__ + "(): Task already allocated for key: " + key);
      return (TRUE);
      break;
    }
  }
  return (FALSE);
}

// Find available slot id.
int TaskFindEmptySlot(int key) {
  int taken = 0;
  if (!TaskExistByKey(key)) {
    for (int job_id = 0; job_id < ArrayRange(todo_queue, 0); job_id++) {
      if (VerboseTrace) Print(__FUNCTION__ + "(): job_id = " + job_id + "; key: " + todo_queue[job_id][0]);
      if (todo_queue[job_id][0] <= 0) { // Find empty slot.
        // if (VerboseTrace) Print(__FUNCTION__ + "(): Found empty slot at: " + job_id);
        return job_id;
      } else taken++;
    }
    // If no empty slots, Otherwise increase size of array.
    int size = ArrayRange(todo_queue, 0);
    if (size < 1000) { // Set array hard limit.
      ArrayResize(todo_queue, size + 10);
      if (VerboseDebug) Print(__FUNCTION__ + "(): Couldn't allocate Task slot, re-sizing array. New size: ",  (size + 1), ", Old size: ", size);
      return size;
    } else {
      // Array exceeded hard limit, probably because of some memory leak.
      if (VerboseDebug) Print(__FUNCTION__ + "(): Couldn't allocate task slot, all are taken (" + taken + "). Size: " + size);
    }
  }
  return EMPTY;
}

// Run specific task.
bool TaskRun(int job_id) {
  bool result = FALSE;
  int key = todo_queue[job_id][0];
  int task_type = todo_queue[job_id][1];
  int retries = todo_queue[job_id][2];
  // if (VerboseTrace) Print(__FUNCTION__ + "(): Job id: " + job_id + "; Task type: " + task_type);

  switch (task_type) {
    case TASK_ORDER_OPEN:
       int cmd = todo_queue[job_id][3];
       double volume = todo_queue[job_id][4];
       int order_type = todo_queue[job_id][5];
       string order_comment = todo_queue[job_id][6];
       result = ExecuteOrder(cmd, volume, order_type, order_comment, FALSE);
      break;
    case TASK_ORDER_CLOSE:
        string reason = todo_queue[job_id][3];
        if (OrderSelect(key, SELECT_BY_TICKET)) {
          if (CloseOrder(key, "TaskRun(): " + reason, FALSE))
            result = TaskRemove(job_id);
        }
      break;
    case TASK_CALC_STATS:
        if (OrderSelect(key, SELECT_BY_TICKET, MODE_HISTORY)) {
          OrderCalc(key);
        } else {
          if (VerboseDebug) Print(__FUNCTION__ + "(): Access to history failed with error: (" + GetLastError() + ").");
        }
      break;
    default:
      if (VerboseDebug) Print(__FUNCTION__ + "(): Unknown task: ", task_type);
  };
  return result;
}

// Process task list.
bool TaskProcessList(bool force = FALSE) {
   int total_run, total_failed, total_removed = 0;
   int no_elem = 8;

   // Check if bar time has been changed since last time.
   if (bar_time == last_queue_process && !force) {
     // if (VerboseTrace) Print("TaskProcessList(): Not executed. Bar time: " + bar_time + " == " + last_queue_process);
     return (FALSE); // Do not process job list more often than per each minute bar.
   } else {
     last_queue_process = bar_time; // Set bar time of last queue process.
   }

   RefreshRates();
   for (int job_id = 0; job_id < ArrayRange(todo_queue, 0); job_id++) {
      if (todo_queue[job_id][0] > 0) { // Find valid task.
        if (TaskRun(job_id)) {
          total_run++;
        } else {
          total_failed++;
          if (todo_queue[job_id][2]-- <= 0) { // Remove task if maximum tries reached.
            if (TaskRemove(job_id)) {
              total_removed++;
            }
          }
        }
      }
   } // end: for
   if (VerboseDebug && total_run+total_failed > 0)
     Print(__FUNCTION__, "(): Processed ", total_run+total_failed, " jobs (", total_run, " run, ", total_failed, " failed (", total_removed, " removed)).");
  return TRUE;
}

/* END: TASK FUNCTIONS */

/* BEGIN: DEBUG FUNCTIONS */

void DrawMA(int timeframe) {
   int Counter = 1;
   int shift=iBarShift(Symbol(), timeframe, TimeCurrent());
   while(Counter < Bars) {
      string itime = iTime(NULL, timeframe, Counter);

      // FIXME: The shift parameter (Counter, Counter-1) doesn't use the real values of MA_Fast, MA_Medium and MA_Slow including MA_Shift_Fast, etc.
      double MA_Fast_Curr = iMA(NULL, timeframe, MA_Period_Fast, 0, MA_Method, MA_Applied_Price, Counter); // Current Bar.
      double MA_Fast_Prev = iMA(NULL, timeframe, MA_Period_Fast, 0, MA_Method, MA_Applied_Price, Counter-1); // Previous Bar.
      ObjectCreate("MA_Fast" + itime, OBJ_TREND, 0, iTime(NULL,0,Counter), MA_Fast_Curr, iTime(NULL,0,Counter-1), MA_Fast_Prev);
      ObjectSet("MA_Fast" + itime, OBJPROP_RAY, False);
      ObjectSet("MA_Fast" + itime, OBJPROP_COLOR, Yellow);

      double MA_Medium_Curr = iMA(NULL, timeframe, MA_Period_Medium, 0, MA_Method, MA_Applied_Price, Counter); // Current Bar.
      double MA_Medium_Prev = iMA(NULL, timeframe, MA_Period_Medium, 0, MA_Method, MA_Applied_Price, Counter-1); // Previous Bar.
      ObjectCreate("MA_Medium" + itime, OBJ_TREND, 0, iTime(NULL,0,Counter), MA_Medium_Curr, iTime(NULL,0,Counter-1), MA_Medium_Prev);
      ObjectSet("MA_Medium" + itime, OBJPROP_RAY, False);
      ObjectSet("MA_Medium" + itime, OBJPROP_COLOR, Gold);

      double MA_Slow_Curr = iMA(NULL, timeframe, MA_Period_Slow, 0, MA_Method, MA_Applied_Price, Counter); // Current Bar.
      double MA_Slow_Prev = iMA(NULL, timeframe, MA_Period_Slow, 0, MA_Method, MA_Applied_Price, Counter-1); // Previous Bar.
      ObjectCreate("MA_Slow" + itime, OBJ_TREND, 0, iTime(NULL,0,Counter), MA_Slow_Curr, iTime(NULL,0,Counter-1), MA_Slow_Prev);
      ObjectSet("MA_Slow" + itime, OBJPROP_RAY, False);
      ObjectSet("MA_Slow" + itime, OBJPROP_COLOR, Orange);
      Counter++;
   }
}

/* END: DEBUG FUNCTIONS */

/* BEGIN: ERROR HANDLING FUNCTIONS */

// Error codes  defined in stderror.mqh.
// You can print the error description, you can use the ErrorDescription() function, defined in stdlib.mqh.
// Or use this function instead.
string GetErrorText(int code) {
   string text;

   switch (code) {
      case   0: text = "No error returned."; break;
      case   1: text = "No error returned, but the result is unknown."; break;
      case   2: text = "Common error."; break;
      case   3: text = "Invalid trade parameters."; break;
      case   4: text = "Trade server is busy."; break;
      case   5: text = "Old version of the client terminal,"; break;
      case   6: text = "No connection with trade server."; break;
      case   7: text = "Not enough rights."; break;
      case   8: text = "Too frequent requests."; break;
      case   9: text = "Malfunctional trade operation (never returned error)."; break;
      case   64: text = "Account disabled."; break;
      case   65: text = "Invalid account."; break;
      case  128: text = "Trade timeout."; break;
      case  129: text = "Invalid price."; break;
      case  130: text = "Invalid stops."; break;
      case  131: text = "Invalid trade volume."; break;
      case  132: text = "Market is closed."; break;
      case  133: text = "Trade is disabled."; break;
      case  134: text = "Not enough money."; break;
      case  135: text = "Price changed."; break;
      // --
      // ERR_OFF_QUOTES
      //   1. Off Quotes may be a technical issue.
      //   2. Off Quotes may be due to unsupported orders.
      //      - Trying to partially close a position. For example, attempting to close 0.10 (10k) of a 20k position.
      //      - Placing a micro lot trade. For example, attempting to place a 0.01 (1k) volume trade.
      //      - Placing a trade that is not in increments of 0.10 (10k) volume. For example, attempting to place a 0.77 (77k) trade.
      //      - Adding a stop or limit to a market order before the order executes. For example, setting an EA to place a 0.1 volume (10k) buy market order with a stop loss of 50 pips.
      case  136: text = "Off quotes."; break;
      case  137: text = "Broker is busy (never returned error)."; break;
      case  138: text = "Requote."; break;
      case  139: text = "Order is locked."; break;
      case  140: text = "Long positions only allowed."; break;
      case  141: /* ERR_TOO_MANY_REQUESTS */ text = "Too many requests."; break;
      case  145: text = "Modification denied because order too close to market."; break;
      case  146: text = "Trade context is busy."; break;
      case  147: text = "Expirations are denied by broker."; break;
      // ERR_TRADE_TOO_MANY_ORDERS: On some trade servers, the total amount of open and pending orders can be limited. If this limit has been exceeded, no new position will be opened
      case  148: text = "Amount of open and pending orders has reached the limit set by the broker"; break; // ERR_TRADE_TOO_MANY_ORDERS
      case  149: text = "An attempt to open an order opposite to the existing one when hedging is disabled"; break; // ERR_TRADE_HEDGE_PROHIBITED
      case  150: text = "An attempt to close an order contravening the FIFO rule."; break; // ERR_TRADE_PROHIBITED_BY_FIFO
      case 4000: text = "No error (never generated code)."; break;
      case 4001: text = "Wrong function pointer."; break;
      case 4002: text = "Array index is out of range."; break;
      case 4003: text = "No memory for function call stack."; break;
      case 4004: text = "Recursive stack overflow."; break;
      case 4005: text = "Not enough stack for parameter."; break;
      case 4006: text = "No memory for parameter string."; break;
      case 4007: text = "No memory for temp string."; break;
      case 4008: text = "Not initialized string."; break;
      case 4009: text = "Not initialized string in array."; break;
      case 4010: text = "No memory for array\' string."; break;
      case 4011: text = "Too long string."; break;
      case 4012: text = "Remainder from zero divide."; break;
      case 4013: text = "Zero divide."; break;
      case 4014: text = "Unknown command."; break;
      case 4015: text = "Wrong jump (never generated error)."; break;
      case 4016: text = "Not initialized array."; break;
      case 4017: text = "Dll calls are not allowed."; break;
      case 4018: text = "Cannot load library."; break;
      case 4019: text = "Cannot call function."; break;
      case 4020: text = "Expert function calls are not allowed."; break;
      case 4021: text = "Not enough memory for temp string returned from function."; break;
      case 4022: text = "System is busy (never generated error)."; break;
      case 4050: text = "Invalid function parameters count."; break;
      case 4051: text = "Invalid function parameter value."; break;
      case 4052: text = "String function internal error."; break;
      case 4053: text = "Some array error."; break;
      case 4054: text = "Incorrect series array using."; break;
      case 4055: text = "Custom indicator error."; break;
      case 4056: text = "Arrays are incompatible."; break;
      case 4057: text = "Global variables processing error."; break;
      case 4058: text = "Global variable not found."; break;
      case 4059: text = "Function is not allowed in testing mode."; break;
      case 4060: text = "Function is not confirmed."; break;
      case 4061: text = "Send mail error."; break;
      case 4062: text = "String parameter expected."; break;
      case 4063: text = "Integer parameter expected."; break;
      case 4064: text = "Double parameter expected."; break;
      case 4065: text = "Array as parameter expected."; break;
      case 4066: text = "Requested history data in update state."; break;
      case 4074: /* ERR_NO_MEMORY_FOR_HISTORY */ text = "No memory for history data."; break;
      case 4099: text = "End of file."; break;
      case 4100: text = "Some file error."; break;
      case 4101: text = "Wrong file name."; break;
      case 4102: text = "Too many opened files."; break;
      case 4103: text = "Cannot open file."; break;
      case 4104: text = "Incompatible access to a file."; break;
      case 4105: text = "No order selected."; break;
      case 4106: text = "Unknown symbol."; break;
      case 4107: text = "Invalid stoploss parameter for trade (OrderSend) function."; break;
      case 4108: text = "Invalid ticket."; break;
      case 4109: text = "Trade is not allowed in the expert properties."; break;
      case 4110: text = "Longs are not allowed in the expert properties."; break;
      case 4111: text = "Shorts are not allowed in the expert properties."; break;
      case 4200: text = "Object is already exist."; break;
      case 4201: text = "Unknown object property."; break;
      case 4202: text = "Object is not exist."; break;
      case 4203: text = "Unknown object type."; break;
      case 4204: text = "No object name."; break;
      case 4205: text = "Object coordinates error."; break;
      case 4206: text = "No specified subwindow."; break;
      default:  text = "Unknown error.";
   }
   return (text);
}

// Get text description based on the uninitialization reason code.
string getUninitReasonText(int reasonCode) {
   string text="";
   switch(reasonCode) {
      case REASON_PROGRAM:
         text="EA terminated its operation by calling the ExpertRemove() function."; break;
      case REASON_ACCOUNT:
         text="Account was changed."; break;
      case REASON_CHARTCHANGE:
         text="Symbol or timeframe was changed."; break;
      case REASON_CHARTCLOSE:
         text="Chart was closed."; break;
      case REASON_PARAMETERS:
         text="Input-parameter was changed."; break;
      case REASON_RECOMPILE:
         text="Program " + __FILE__ + " was recompiled."; break;
      case REASON_REMOVE:
         text="Program " + __FILE__ + " was removed from the chart."; break;
      case REASON_TEMPLATE:
         text="New template was applied to chart."; break;
      default:text="Unknown reason.";
     }
   return text;
}

/* END: ERROR HANDLING FUNCTIONS */

/* BEGIN: SUMMARY REPORT */

#define OP_BALANCE 6
#define OP_CREDIT  7

double InitialDeposit;
double SummaryProfit;
double GrossProfit;
double GrossLoss;
double MaxProfit;
double MinProfit;
double ConProfit1;
double ConProfit2;
double ConLoss1;
double ConLoss2;
double MaxLoss;
double MaxDrawdown;
double MaxDrawdownPercent;
double RelDrawdownPercent;
double RelDrawdown;
double ExpectedPayoff;
double ProfitFactor;
double AbsoluteDrawdown;
int    SummaryTrades;
int    ProfitTrades;
int    LossTrades;
int    ShortTrades;
int    LongTrades;
int    WinShortTrades;
int    WinLongTrades;
int    ConProfitTrades1;
int    ConProfitTrades2;
int    ConLossTrades1;
int    ConLossTrades2;
int    AvgConWinners;
int    AvgConLosers;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateSummary(double initial_deposit)
  {
   int    sequence=0, profitseqs=0, lossseqs=0;
   double sequential=0.0, prevprofit=EMPTY_VALUE, drawdownpercent, drawdown;
   double maxpeak=initial_deposit, minpeak=initial_deposit, balance=initial_deposit;
   int    trades_total = HistoryTotal();
//---- initialize summaries
   InitializeSummaries(initial_deposit);
//----
   for (int i = 0; i < trades_total; i++) {
      if (!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
      int type=OrderType();
      //---- initial balance not considered
      if (i == 0 && type == OP_BALANCE) continue;
      //---- calculate profit
      double profit = OrderProfit() + OrderCommission() + OrderSwap();
      balance += profit;
      //---- drawdown check
      if(maxpeak<balance) {
         drawdown=maxpeak-minpeak;
         if(maxpeak!=0.0) {
            drawdownpercent=drawdown/maxpeak*100.0;
            if(RelDrawdownPercent<drawdownpercent) {
               RelDrawdownPercent=drawdownpercent;
               RelDrawdown=drawdown;
              }
           }
         if(MaxDrawdown < drawdown) {
            MaxDrawdown = drawdown;
            if (maxpeak != 0.0) MaxDrawdownPercent = MaxDrawdown / maxpeak * 100.0;
            else MaxDrawdownPercent=100.0;
         }
         maxpeak = balance;
         minpeak = balance;
      }
      if (minpeak > balance) minpeak = balance;
      if (MaxLoss > balance) MaxLoss = balance;
      //---- market orders only
      if (type != OP_BUY && type != OP_SELL) continue;
      //---- calculate profit in points
      // profit=(OrderClosePrice()-OrderOpenPrice())/MarketInfo(OrderSymbol(),MODE_POINT);
      SummaryProfit += profit;
      SummaryTrades++;
      if (type == OP_BUY) LongTrades++;
      else             ShortTrades++;
      if(profit<0) { //---- loss trades
         LossTrades++;
         GrossLoss+=profit;
         if(MinProfit>profit) MinProfit=profit;
         //---- fortune changed
         if(prevprofit!=EMPTY_VALUE && prevprofit>=0)
           {
            if(ConProfitTrades1<sequence ||
               (ConProfitTrades1==sequence && ConProfit2<sequential))
              {
               ConProfitTrades1=sequence;
               ConProfit1=sequential;
              }
            if(ConProfit2<sequential ||
               (ConProfit2==sequential && ConProfitTrades1<sequence))
              {
               ConProfit2=sequential;
               ConProfitTrades2=sequence;
              }
            profitseqs++;
            AvgConWinners+=sequence;
            sequence=0;
            sequential=0.0;
           }
        } else { //---- profit trades (profit>=0)
         ProfitTrades++;
         if(type==OP_BUY)  WinLongTrades++;
         if(type==OP_SELL) WinShortTrades++;
         GrossProfit+=profit;
         if(MaxProfit<profit) MaxProfit=profit;
         //---- fortune changed
         if(prevprofit!=EMPTY_VALUE && prevprofit<0)
           {
            if(ConLossTrades1<sequence ||
               (ConLossTrades1==sequence && ConLoss2>sequential))
              {
               ConLossTrades1=sequence;
               ConLoss1=sequential;
              }
            if(ConLoss2>sequential ||
               (ConLoss2==sequential && ConLossTrades1<sequence))
              {
               ConLoss2=sequential;
               ConLossTrades2=sequence;
              }
            lossseqs++;
            AvgConLosers+=sequence;
            sequence=0;
            sequential=0.0;
           }
        }
      sequence++;
      sequential+=profit;
      prevprofit=profit;
     }
//---- final drawdown check
   drawdown = maxpeak - minpeak;
   if (maxpeak != 0.0) {
      drawdownpercent = drawdown / maxpeak * 100.0;
      if (RelDrawdownPercent < drawdownpercent) {
         RelDrawdownPercent = drawdownpercent;
         RelDrawdown = drawdown;
      }
   }
   if (MaxDrawdown < drawdown) {
    MaxDrawdown = drawdown;
    if (maxpeak != 0) MaxDrawdownPercent = MaxDrawdown / maxpeak * 100.0;
    else MaxDrawdownPercent = 100.0;
   }
//---- consider last trade
   if(prevprofit!=EMPTY_VALUE)
     {
      profit=prevprofit;
      if(profit<0)
        {
         if(ConLossTrades1<sequence ||
            (ConLossTrades1==sequence && ConLoss2>sequential))
           {
            ConLossTrades1=sequence;
            ConLoss1=sequential;
           }
         if(ConLoss2>sequential ||
            (ConLoss2==sequential && ConLossTrades1<sequence))
           {
            ConLoss2=sequential;
            ConLossTrades2=sequence;
           }
         lossseqs++;
         AvgConLosers+=sequence;
        }
      else
        {
         if(ConProfitTrades1<sequence ||
            (ConProfitTrades1==sequence && ConProfit2<sequential))
           {
            ConProfitTrades1=sequence;
            ConProfit1=sequential;
           }
         if(ConProfit2<sequential ||
            (ConProfit2==sequential && ConProfitTrades1<sequence))
           {
            ConProfit2=sequential;
            ConProfitTrades2=sequence;
           }
         profitseqs++;
         AvgConWinners+=sequence;
        }
     }
//---- collecting done
   double dnum, profitkoef=0.0, losskoef=0.0, avgprofit=0.0, avgloss=0.0;
//---- average consecutive wins and losses
   dnum=AvgConWinners;
   if(profitseqs>0) AvgConWinners=dnum/profitseqs+0.5;
   dnum=AvgConLosers;
   if(lossseqs>0)   AvgConLosers=dnum/lossseqs+0.5;
//---- absolute values
   if(GrossLoss<0.0) GrossLoss*=-1.0;
   if(MinProfit<0.0) MinProfit*=-1.0;
   if(ConLoss1<0.0)  ConLoss1*=-1.0;
   if(ConLoss2<0.0)  ConLoss2*=-1.0;
//---- profit factor
   if (GrossLoss > 0.0) ProfitFactor = GrossProfit / GrossLoss;
//---- expected payoff
   if (ProfitTrades > 0) avgprofit = GrossProfit / ProfitTrades;
   if (LossTrades > 0)   avgloss   = GrossLoss   / LossTrades;
   if (SummaryTrades > 0) {
    profitkoef = 1.0 * ProfitTrades / SummaryTrades;
    losskoef = 1.0 * LossTrades / SummaryTrades;
    ExpectedPayoff = profitkoef * avgprofit - losskoef * avgloss;
   }
//---- absolute drawdown
   AbsoluteDrawdown = initial_deposit - MaxLoss;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitializeSummaries(double initial_deposit)
  {
   InitialDeposit=initial_deposit;
   MaxLoss=initial_deposit;
   SummaryProfit=0.0;
   GrossProfit=0.0;
   GrossLoss=0.0;
   MaxProfit=0.0;
   MinProfit=0.0;
   ConProfit1=0.0;
   ConProfit2=0.0;
   ConLoss1=0.0;
   ConLoss2=0.0;
   MaxDrawdown=0.0;
   MaxDrawdownPercent=0.0;
   RelDrawdownPercent=0.0;
   RelDrawdown=0.0;
   ExpectedPayoff=0.0;
   ProfitFactor=0.0;
   AbsoluteDrawdown=0.0;
   SummaryTrades=0;
   ProfitTrades=0;
   LossTrades=0;
   ShortTrades=0;
   LongTrades=0;
   WinShortTrades=0;
   WinLongTrades=0;
   ConProfitTrades1=0;
   ConProfitTrades2=0;
   ConLossTrades1=0;
   ConLossTrades2=0;
   AvgConWinners=0;
   AvgConLosers=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateInitialDeposit()
  {
   double initial_deposit=AccountBalance();
//----
   for(int i=HistoryTotal()-1; i>=0; i--)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
      int type=OrderType();
      //---- initial balance not considered
      if(i==0 && type==OP_BALANCE) break;
      if(type==OP_BUY || type==OP_SELL)
        {
         //---- calculate profit
         double profit=OrderProfit()+OrderCommission()+OrderSwap();
         //---- and decrease balance
         initial_deposit-=profit;
        }
      if(type==OP_BALANCE || type==OP_CREDIT)
         initial_deposit-=OrderProfit();
     }
//----
   return(initial_deposit);
}

/*
 * Add message into the report file.
 */
void ReportAdd(string msg) {
  int last = ArraySize(log);
  ArrayResize(log, last + 1);
  log[last] = TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS) + ": " + msg;
}

/*
 * Write report into file.
 */
string GenerateReport(string sep = "\n") {
  string output = "";
  int i;
  if (InitialDeposit > 0)
  output += StringFormat("Initial deposit:                            %s%.2f", InitialDeposit) + sep;
  output += StringFormat("Total net profit:                           %.2f", ValueToCurrency(SummaryProfit)) + sep;
  output += StringFormat("Gross profit:                               %.2f", ValueToCurrency(GrossProfit)) + sep;
  output += StringFormat("Gross loss:                                 %.2f", ValueToCurrency(GrossLoss))  + sep;
  if (GrossLoss > 0.0)
  output += StringFormat("Profit factor:                              %.2f", ProfitFactor) + sep;
  output += StringFormat("Expected payoff:                            %.2f", ExpectedPayoff) + sep;
  output += StringFormat("Absolute drawdown:                          %.2f", AbsoluteDrawdown) + sep;
  output += StringFormat("Maximal drawdown:                           %.1f (%.1f%%)", ValueToCurrency(MaxDrawdown), MaxDrawdownPercent) + sep;
  output += StringFormat("Relative drawdown:                          (%.1f%%) %.1f", RelDrawdownPercent, ValueToCurrency(RelDrawdown)) + sep;
  output += StringFormat("Trades total                                %d", SummaryTrades) + sep;
  if(ShortTrades>0)
  output += StringFormat("Short positions (won %):                    %d (%.1f%%)", ShortTrades, 100.0*WinShortTrades/ShortTrades) + sep;
  if(LongTrades>0)
  output += "Long positions(won %):                      " + LongTrades + StringConcatenate(" (",100.0*WinLongTrades/LongTrades,"%)") + sep;
  if(ProfitTrades>0)
  output += "Profit trades (% of total):                 " + ProfitTrades + StringConcatenate(" (",100.0*ProfitTrades/SummaryTrades,"%)") + sep;
  if(LossTrades>0)
  output += "Loss trades (% of total):                   " + LossTrades + StringConcatenate(" (",100.0*LossTrades/SummaryTrades,"%)") + sep;
  output += "Largest profit trade:                       " + MaxProfit + sep;
  output += "Largest loss trade:                         " + -MinProfit + sep;
  if(ProfitTrades>0)
  output += "Average profit trade:                       " + GrossProfit/ProfitTrades + sep;
  if(LossTrades>0)
  output += StringFormat("Average loss trade:                         %.2f%s", -GrossLoss/LossTrades, sep);
  output += "Average consecutive wins:                   " + AvgConWinners + sep;
  output += "Average consecutive losses:                 " + AvgConLosers + sep;
  output += "Maximum consecutive wins (profit in money): " + ConProfitTrades1 + StringConcatenate(" (", ConProfit1, ")") + sep;
  output += "Maximum consecutive losses (loss in money): " + ConLossTrades1 + StringConcatenate(" (", -ConLoss1, ")") + sep;
  output += "Maximal consecutive profit (count of wins): " + ConProfit2 + StringConcatenate(" (", ConProfitTrades2, ")") + sep;
  output += "Maximal consecutive loss (count of losses): " + -ConLoss2 + StringConcatenate(" (", ConLossTrades2, ")") + sep;
  output += GetStrategyReport();

  // Write report log.
  if (ArraySize(log) > 0) output += "Report log:\n";
  for (i = 0; i < ArraySize(log); i++)
   output += log[i] + sep;

  return output;
}

/*
 * Write report into file.
 */
void WriteReport(string report_name) {
  int handle = FileOpen(report_name, FILE_CSV|FILE_WRITE, '\t');
  if (handle < 1) return;

  string report = GenerateReport();
  FileWrite(handle, report);
  FileClose(handle);

  if (VerboseDebug) {
    PrintText(report);
  }
}

/* END: SUMMARY REPORT */

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_MA3_EURUSD_M1_Params : Stg_MA3_Params {
  Stg_MA3_EURUSD_M1_Params() {
    symbol = "EURUSD";
    tf = PERIOD_M1;
    MA3_Period_Fast = 32;
    MA3_Period_Medium = 32;
    MA3_Period_Slow = 32;
    MA3_MA_Shift = 0;
    MA3_Method = 1;
    MA3_Applied_Price = 3;
    MA3_Shift = 0;
    MA3_SignalOpenMethod = 0;
    MA3_SignalOpenLevel = 36;
    MA3_SignalCloseMethod = 0;
    MA3_SignalCloseLevel = 36;
    MA3_PriceLimitMethod = 0;
    MA3_PriceLimitLevel = 0;
    MA3_MaxSpread = 2;
  }
} stg_ma3_m1;

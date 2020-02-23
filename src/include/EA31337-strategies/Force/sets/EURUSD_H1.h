//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_Force_EURUSD_H1_Params : Stg_Force_Params {
  Stg_Force_EURUSD_H1_Params() {
    symbol = "EURUSD";
    tf = PERIOD_H1;
    Force_Period = 2;
    Force_MA_Method = 0;
    Force_Applied_Price = 3;
    Force_Shift = 0;
    Force_SignalOpenMethod = 0;
    Force_SignalOpenLevel = 36;
    Force_SignalCloseMethod = 1;
    Force_SignalCloseLevel = 36;
    Force_PriceLimitMethod = 0;
    Force_PriceLimitLevel = 0;
    Force_MaxSpread = 6;
  }
} stg_force_h1;

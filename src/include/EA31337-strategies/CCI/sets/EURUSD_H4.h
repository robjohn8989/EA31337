//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_CCI_EURUSD_H4_Params : Stg_CCI_Params {
  Stg_CCI_EURUSD_H4_Params() {
    symbol = "EURUSD";
    tf = PERIOD_H4;
    CCI_Period = 2;
    CCI_Applied_Price = 3;
    CCI_Shift = 0;
    CCI_SignalOpenMethod = 0;
    CCI_SignalOpenLevel = 36;
    CCI_SignalCloseMethod = 1;
    CCI_SignalCloseLevel = 36;
    CCI_PriceLimitMethod = 0;
    CCI_PriceLimitLevel = 0;
    CCI_MaxSpread = 10;
  }
} stg_cci_h4;

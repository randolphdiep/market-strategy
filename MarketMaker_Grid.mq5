//+------------------------------------------------------------------+
//|                                            MarketMaker_Grid.mq5 |
//|                                         Grid-Based Market Maker |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Grid Market Maker EA"
#property version   "1.00"
#property strict

//--- Input Parameters
input group "=== Grid Settings ==="
input int      GridLevels = 5;                    // Number of grid levels (each side)
input int      GridStep = 100;                    // Grid step in points
input double   LotSize = 0.01;                    // Lot size per order
input int      TakeProfitPoints = 50;             // Take profit in points
input int      MagicNumber = 123456;              // Magic number

input group "=== Risk Management ==="
input double   MaxSpreadPoints = 30;              // Maximum allowed spread (points)
input double   MaxPositionSize = 1.0;             // Maximum total position size (lots)
input double   DailyLossLimit = 100.0;            // Daily loss limit in account currency
input bool     UseVolatilityFilter = true;        // Enable volatility filter
input int      VolatilityPeriod = 20;             // Period for ATR calculation
input double   MaxVolatilityMultiplier = 2.0;     // Max ATR multiplier vs average

input group "=== Trading Hours ==="
input bool     UseTradingHours = false;           // Enable trading hours filter
input int      StartHour = 8;                     // Trading start hour
input int      EndHour = 18;                      // Trading end hour

input group "=== Advanced ==="
input int      Slippage = 10;                     // Maximum slippage in points
input bool     CloseOnDailyLimit = true;          // Close all on daily limit
input int      OrderDistanceMin = 10;             // Minimum distance from price (points)

//--- Global Variables
datetime lastBarTime;
double dailyStartBalance;
double dailyProfit;
int currentDay;
double averageVolatility;
int volatilityHandle;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Initialize volatility indicator
   if(UseVolatilityFilter)
   {
      volatilityHandle = iATR(_Symbol, PERIOD_CURRENT, VolatilityPeriod);
      if(volatilityHandle == INVALID_HANDLE)
      {
         Print("Error creating ATR indicator");
         return INIT_FAILED;
      }
   }

   //--- Initialize daily tracking
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   currentDay = dt.day;
   dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   dailyProfit = 0;

   //--- Validate inputs
   if(GridLevels <= 0 || GridStep <= 0 || LotSize <= 0)
   {
      Print("Invalid input parameters");
      return INIT_PARAMETERS_INCORRECT;
   }

   Print("Market Maker EA initialized successfully");
   Print("Grid Levels: ", GridLevels, " | Step: ", GridStep, " points");
   Print("Lot Size: ", LotSize, " | Magic: ", MagicNumber);

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(volatilityHandle != INVALID_HANDLE)
      IndicatorRelease(volatilityHandle);

   Print("Market Maker EA stopped. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Check if new bar
   datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);
   bool isNewBar = (currentBarTime != lastBarTime);
   if(isNewBar)
      lastBarTime = currentBarTime;

   //--- Update daily tracking
   UpdateDailyTracking();

   //--- Check daily loss limit
   if(CheckDailyLossLimit())
   {
      if(CloseOnDailyLimit)
         CloseAllOrders();
      return;
   }

   //--- Check trading conditions
   if(!CheckTradingConditions())
      return;

   //--- Manage existing orders
   ManageOrders();

   //--- Place grid orders (only on new bar or if grid is incomplete)
   if(isNewBar || CountGridOrders() < GridLevels * 2)
      PlaceGridOrders();
}

//+------------------------------------------------------------------+
//| Update daily profit tracking                                     |
//+------------------------------------------------------------------+
void UpdateDailyTracking()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);

   //--- Check if new day
   if(dt.day != currentDay)
   {
      currentDay = dt.day;
      dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      dailyProfit = 0;
      Print("New trading day started. Balance: ", dailyStartBalance);
   }

   //--- Calculate daily profit
   dailyProfit = AccountInfoDouble(ACCOUNT_BALANCE) - dailyStartBalance;
}

//+------------------------------------------------------------------+
//| Check daily loss limit                                           |
//+------------------------------------------------------------------+
bool CheckDailyLossLimit()
{
   if(dailyProfit <= -DailyLossLimit)
   {
      Comment("DAILY LOSS LIMIT REACHED: ", DoubleToString(dailyProfit, 2));
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Check all trading conditions                                     |
//+------------------------------------------------------------------+
bool CheckTradingConditions()
{
   //--- Check spread
   double spread = (SymbolInfoDouble(_Symbol, SYMBOL_ASK) -
                    SymbolInfoDouble(_Symbol, SYMBOL_BID)) / _Point;

   if(spread > MaxSpreadPoints)
   {
      Comment("Spread too high: ", DoubleToString(spread, 1), " points");
      return false;
   }

   //--- Check volatility
   if(UseVolatilityFilter && !CheckVolatility())
   {
      Comment("Volatility too high");
      return false;
   }

   //--- Check trading hours
   if(UseTradingHours && !CheckTradingHours())
   {
      Comment("Outside trading hours");
      return false;
   }

   //--- Check position size limit
   if(GetTotalPositionSize() >= MaxPositionSize)
   {
      Comment("Maximum position size reached");
      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| Check volatility filter                                          |
//+------------------------------------------------------------------+
bool CheckVolatility()
{
   double atr[];
   ArraySetAsSeries(atr, true);

   if(CopyBuffer(volatilityHandle, 0, 0, VolatilityPeriod * 2, atr) <= 0)
      return true; // Allow trading if can't get volatility

   //--- Calculate average ATR
   double sumATR = 0;
   for(int i = VolatilityPeriod; i < VolatilityPeriod * 2; i++)
      sumATR += atr[i];
   averageVolatility = sumATR / VolatilityPeriod;

   //--- Compare current ATR to average
   double currentATR = atr[0];
   if(currentATR > averageVolatility * MaxVolatilityMultiplier)
      return false;

   return true;
}

//+------------------------------------------------------------------+
//| Check trading hours                                              |
//+------------------------------------------------------------------+
bool CheckTradingHours()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);

   if(dt.hour >= StartHour && dt.hour < EndHour)
      return true;

   return false;
}

//+------------------------------------------------------------------+
//| Get total position size                                          |
//+------------------------------------------------------------------+
double GetTotalPositionSize()
{
   double totalLots = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(PositionGetSymbol(i) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber)
      {
         totalLots += PositionGetDouble(POSITION_VOLUME);
      }
   }

   return totalLots;
}

//+------------------------------------------------------------------+
//| Count grid orders                                                |
//+------------------------------------------------------------------+
int CountGridOrders()
{
   int count = 0;

   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == MagicNumber)
         count++;
   }

   return count;
}

//+------------------------------------------------------------------+
//| Place grid orders                                                |
//+------------------------------------------------------------------+
void PlaceGridOrders()
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   //--- Remove all pending orders first
   DeleteAllPendingOrders();

   //--- Place buy limit orders below current price
   for(int i = 1; i <= GridLevels; i++)
   {
      double price = NormalizeDouble(bid - GridStep * i * point, digits);
      double tp = NormalizeDouble(price + TakeProfitPoints * point, digits);

      if(price > 0 && !OrderExists(price, ORDER_TYPE_BUY_LIMIT))
         PlacePendingOrder(ORDER_TYPE_BUY_LIMIT, price, tp, 0);
   }

   //--- Place sell limit orders above current price
   for(int i = 1; i <= GridLevels; i++)
   {
      double price = NormalizeDouble(ask + GridStep * i * point, digits);
      double tp = NormalizeDouble(price - TakeProfitPoints * point, digits);

      if(price > 0 && !OrderExists(price, ORDER_TYPE_SELL_LIMIT))
         PlacePendingOrder(ORDER_TYPE_SELL_LIMIT, price, tp, 0);
   }

   //--- Update comment
   UpdateComment();
}

//+------------------------------------------------------------------+
//| Check if order exists at price                                   |
//+------------------------------------------------------------------+
bool OrderExists(double price, ENUM_ORDER_TYPE orderType)
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(OrderGetString(ORDER_SYMBOL) == _Symbol &&
         OrderGetInteger(ORDER_MAGIC) == MagicNumber &&
         OrderGetInteger(ORDER_TYPE) == orderType)
      {
         double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
         if(MathAbs(orderPrice - price) < SymbolInfoDouble(_Symbol, SYMBOL_POINT))
            return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Place pending order                                              |
//+------------------------------------------------------------------+
bool PlacePendingOrder(ENUM_ORDER_TYPE orderType, double price, double tp, double sl)
{
   MqlTradeRequest request = {};
   MqlTradeResult result = {};

   request.action = TRADE_ACTION_PENDING;
   request.symbol = _Symbol;
   request.volume = LotSize;
   request.type = orderType;
   request.price = price;
   request.tp = tp;
   request.sl = sl;
   request.deviation = Slippage;
   request.magic = MagicNumber;
   request.comment = "Grid MM";

   if(!OrderSend(request, result))
   {
      Print("Order failed: ", result.retcode, " - ", result.comment);
      return false;
   }

   return true;
}

//+------------------------------------------------------------------+
//| Manage existing orders and positions                             |
//+------------------------------------------------------------------+
void ManageOrders()
{
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   //--- Check if pending orders are too close to current price
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == MagicNumber)
      {
         double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
         double distance = MathAbs(orderPrice - currentPrice) / point;

         //--- Delete order if too close to price
         if(distance < OrderDistanceMin)
         {
            MqlTradeRequest request = {};
            MqlTradeResult result = {};
            request.action = TRADE_ACTION_REMOVE;
            request.order = ticket;
            OrderSend(request, result);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Delete all pending orders                                        |
//+------------------------------------------------------------------+
void DeleteAllPendingOrders()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == MagicNumber)
      {
         MqlTradeRequest request = {};
         MqlTradeResult result = {};
         request.action = TRADE_ACTION_REMOVE;
         request.order = ticket;
         OrderSend(request, result);
      }
   }
}

//+------------------------------------------------------------------+
//| Close all positions and orders                                   |
//+------------------------------------------------------------------+
void CloseAllOrders()
{
   //--- Close all positions
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(PositionGetSymbol(i) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber)
      {
         ulong ticket = PositionGetInteger(POSITION_TICKET);
         MqlTradeRequest request = {};
         MqlTradeResult result = {};

         request.action = TRADE_ACTION_DEAL;
         request.position = ticket;
         request.symbol = _Symbol;
         request.volume = PositionGetDouble(POSITION_VOLUME);
         request.type = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ?
                        ORDER_TYPE_SELL : ORDER_TYPE_BUY;
         request.price = (request.type == ORDER_TYPE_SELL) ?
                         SymbolInfoDouble(_Symbol, SYMBOL_BID) :
                         SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         request.deviation = Slippage;
         request.magic = MagicNumber;

         OrderSend(request, result);
      }
   }

   //--- Delete all pending orders
   DeleteAllPendingOrders();

   Print("All positions and orders closed");
}

//+------------------------------------------------------------------+
//| Update chart comment                                             |
//+------------------------------------------------------------------+
void UpdateComment()
{
   string comment = "\n=== GRID MARKET MAKER ===\n";
   comment += "Daily P/L: " + DoubleToString(dailyProfit, 2) + " / " +
              DoubleToString(-DailyLossLimit, 2) + "\n";
   comment += "Total Position: " + DoubleToString(GetTotalPositionSize(), 2) +
              " / " + DoubleToString(MaxPositionSize, 2) + " lots\n";
   comment += "Pending Orders: " + IntegerToString(CountGridOrders()) + "\n";
   comment += "Active Positions: " + IntegerToString(CountPositions()) + "\n";

   double spread = (SymbolInfoDouble(_Symbol, SYMBOL_ASK) -
                    SymbolInfoDouble(_Symbol, SYMBOL_BID)) / _Point;
   comment += "Spread: " + DoubleToString(spread, 1) + " / " +
              DoubleToString(MaxSpreadPoints, 1) + " points\n";

   if(UseVolatilityFilter)
      comment += "Volatility: OK\n";

   Comment(comment);
}

//+------------------------------------------------------------------+
//| Count open positions                                             |
//+------------------------------------------------------------------+
int CountPositions()
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(PositionGetSymbol(i) == _Symbol && PositionGetInteger(POSITION_MAGIC) == MagicNumber)
         count++;
   }
   return count;
}
//+------------------------------------------------------------------+

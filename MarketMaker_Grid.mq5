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
input double   DailyLossLimit = 100.0;            // Daily loss limit in account currency

input group "=== Trading Hours ==="
input bool     UseTradingHours = false;           // Enable trading hours filter
input int      StartHour = 8;                     // Trading start hour
input int      EndHour = 18;                      // Trading end hour

input group "=== Advanced ==="
input bool     CloseOnDailyLimit = true;          // Close all on daily limit
input int      OrderDistanceMin = 10;             // Minimum distance from price (points)
input int      MaxPositionHours = 48;             // Close position after N hours (0=disabled)

input group "=== Grid Recreation Settings ==="
input int      RecreateEveryNBars = 0;            // Recreate grid every N bars (0=disabled)
input bool     UseBarBasedRecreation = false;     // Enable bar-based grid recreation

//--- Global Variables
datetime lastBarTime;
double dailyStartBalance;
double dailyProfit;
int currentDay;
int barsSinceGridRecreation = 0;  // Track bars since last grid recreation

//--- Cached symbol properties
double symbolPoint;
int symbolDigits;
string symbolName;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Cache symbol properties
   symbolName = _Symbol;
   symbolPoint = SymbolInfoDouble(symbolName, SYMBOL_POINT);
   symbolDigits = (int)SymbolInfoInteger(symbolName, SYMBOL_DIGITS);

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
   {
      lastBarTime = currentBarTime;
      barsSinceGridRecreation++;  // Increment bar counter
   }

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

   //--- Determine if grid should be recreated
   bool shouldRecreateGrid = false;

   // Standard trigger: new bar or incomplete grid
   if(isNewBar || CountGridOrders() < GridLevels * 2)
      shouldRecreateGrid = true;

   // Bar-based trigger: recreate every N bars
   if(UseBarBasedRecreation && RecreateEveryNBars > 0)
   {
      if(barsSinceGridRecreation >= RecreateEveryNBars)
         shouldRecreateGrid = true;
      else
         shouldRecreateGrid = false;  // Override standard trigger if bar-based is active
   }

   //--- Place grid orders if needed
   if(shouldRecreateGrid)
   {
      PlaceGridOrders();
      barsSinceGridRecreation = 0;  // Reset counter
   }
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
   //--- Check trading hours
   if(UseTradingHours && !CheckTradingHours())
   {
      Comment("Outside trading hours");
      DeleteAllPendingOrders();
      return false;
   }

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
//| Count grid orders                                                |
//+------------------------------------------------------------------+
int CountGridOrders()
{
   int count = 0;
   int total = OrdersTotal();

   for(int i = 0; i < total; i++)
   {
      if(OrderGetTicket(i) &&
         OrderGetString(ORDER_SYMBOL) == symbolName &&
         OrderGetInteger(ORDER_MAGIC) == MagicNumber)
         count++;
   }

   return count;
}

//+------------------------------------------------------------------+
//| Place grid orders                                                |
//+------------------------------------------------------------------+
void PlaceGridOrders()
{
   double ask = SymbolInfoDouble(symbolName, SYMBOL_ASK);
   double bid = SymbolInfoDouble(symbolName, SYMBOL_BID);

   //--- Remove all pending orders first
   DeleteAllPendingOrders();

   //--- Pre-calculate step values
   double gridStepPrice = GridStep * symbolPoint;
   double tpPrice = TakeProfitPoints * symbolPoint;

   //--- Place buy limit orders below current price
   for(int i = 1; i <= GridLevels; i++)
   {
      double price = NormalizeDouble(bid - gridStepPrice * i, symbolDigits);
      double tp = NormalizeDouble(price + tpPrice, symbolDigits);

      if(price > 0)
         PlacePendingOrder(ORDER_TYPE_BUY_LIMIT, price, tp, 0);
   }

   //--- Place sell limit orders above current price
   for(int i = 1; i <= GridLevels; i++)
   {
      double price = NormalizeDouble(ask + gridStepPrice * i, symbolDigits);
      double tp = NormalizeDouble(price - tpPrice, symbolDigits);

      if(price > 0)
         PlacePendingOrder(ORDER_TYPE_SELL_LIMIT, price, tp, 0);
   }

   //--- Update comment
   UpdateComment();
}


//+------------------------------------------------------------------+
//| Place pending order                                              |
//+------------------------------------------------------------------+
bool PlacePendingOrder(ENUM_ORDER_TYPE orderType, double price, double tp, double sl)
{
   MqlTradeRequest request = {};
   MqlTradeResult result = {};

   request.action = TRADE_ACTION_PENDING;
   request.symbol = symbolName;
   request.volume = LotSize;
   request.type = orderType;
   request.price = price;
   request.tp = tp;
   request.sl = sl;
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
   double bid = SymbolInfoDouble(symbolName, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbolName, SYMBOL_ASK);

   MqlTradeRequest request = {};
   MqlTradeResult result = {};

   //--- Check and close positions that exceeded max hours
   if(MaxPositionHours > 0)
   {
      datetime currentTime = TimeCurrent();
      int totalPos = PositionsTotal();

      for(int i = totalPos - 1; i >= 0; i--)
      {
         if(PositionGetSymbol(i) == symbolName && PositionGetInteger(POSITION_MAGIC) == MagicNumber)
         {
            int hoursOpen = (int)((currentTime - (datetime)PositionGetInteger(POSITION_TIME)) / 3600);

            if(hoursOpen >= MaxPositionHours)
            {
               ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

               ZeroMemory(request);
               request.action = TRADE_ACTION_DEAL;
               request.position = PositionGetInteger(POSITION_TICKET);
               request.symbol = symbolName;
               request.volume = PositionGetDouble(POSITION_VOLUME);
               request.type = (posType == POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
               request.price = (posType == POSITION_TYPE_BUY) ? bid : ask;
               request.magic = MagicNumber;
               request.comment = "Max hours exceeded";

               if(OrderSend(request, result))
                  Print("Position #", request.position, " closed after ", hoursOpen, " hours");
               else
                  Print("Failed to close position #", request.position, ": ", result.retcode);
            }
         }
      }
   }

   //--- Check if pending orders are too close to current price
   if(OrderDistanceMin > 0)
   {
      double minDistancePrice = OrderDistanceMin * symbolPoint;
      int totalOrders = OrdersTotal();

      for(int i = totalOrders - 1; i >= 0; i--)
      {
         if(OrderGetTicket(i) &&
            OrderGetString(ORDER_SYMBOL) == symbolName &&
            OrderGetInteger(ORDER_MAGIC) == MagicNumber)
         {
            double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);

            if(MathAbs(orderPrice - bid) < minDistancePrice)
            {
               ZeroMemory(request);
               request.action = TRADE_ACTION_REMOVE;
               request.order = OrderGetInteger(ORDER_TICKET);
               OrderSend(request, result);
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Delete all pending orders                                        |
//+------------------------------------------------------------------+
void DeleteAllPendingOrders()
{
   MqlTradeRequest request = {};
   MqlTradeResult result = {};
   int total = OrdersTotal();

   for(int i = total - 1; i >= 0; i--)
   {
      if(OrderGetTicket(i) &&
         OrderGetString(ORDER_SYMBOL) == symbolName &&
         OrderGetInteger(ORDER_MAGIC) == MagicNumber)
      {
         ZeroMemory(request);
         request.action = TRADE_ACTION_REMOVE;
         request.order = OrderGetInteger(ORDER_TICKET);
         OrderSend(request, result);
      }
   }
}

//+------------------------------------------------------------------+
//| Close all positions and orders                                   |
//+------------------------------------------------------------------+
void CloseAllOrders()
{
   double bid = SymbolInfoDouble(symbolName, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbolName, SYMBOL_ASK);

   MqlTradeRequest request = {};
   MqlTradeResult result = {};

   //--- Close all positions
   int total = PositionsTotal();
   for(int i = total - 1; i >= 0; i--)
   {
      if(PositionGetSymbol(i) == symbolName && PositionGetInteger(POSITION_MAGIC) == MagicNumber)
      {
         ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

         ZeroMemory(request);
         request.action = TRADE_ACTION_DEAL;
         request.position = PositionGetInteger(POSITION_TICKET);
         request.symbol = symbolName;
         request.volume = PositionGetDouble(POSITION_VOLUME);
         request.type = (posType == POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
         request.price = (posType == POSITION_TYPE_BUY) ? bid : ask;
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
   comment += "Pending Orders: " + IntegerToString(CountGridOrders()) + "\n";
   comment += "Active Positions: " + IntegerToString(CountPositions()) + "\n";

   Comment(comment);
}

//+------------------------------------------------------------------+
//| Count open positions                                             |
//+------------------------------------------------------------------+
int CountPositions()
{
   int count = 0;
   int total = PositionsTotal();

   for(int i = 0; i < total; i++)
   {
      if(PositionGetSymbol(i) == symbolName && PositionGetInteger(POSITION_MAGIC) == MagicNumber)
         count++;
   }
   return count;
}
//+------------------------------------------------------------------+

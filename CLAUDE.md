This repo is for create **simple** EA mq5 bots.
Strategy is systematic trading approaches that don't require price prediction:
- Market-Making Strategies: Liquidity provision, Quote stuffing arbitrage
- Statistical Arbitrage: Pairs trading, Triangular arbitrage, Latency arbitrage
- Volatility-Based Approaches: Gamma scalping, Range-bound grid trading
- Order Flow Strategies: Volume profile trading, Liquidity hunting, Imbalance trading


-  Price action (higher highs/lows) in H4 to define trend

Grid Placement Strategies
Approach 1: Dynamic Grid (Recommended)

Set first grid order at current support/resistance on M15
Space additional orders every X pips in trend direction
As price moves up in uptrend, close profitable grids and add new ones higher
Creates a "moving grid" that follows the trend

Approach 2: Fixed Zone Grid

Identify a H4 consolidation zone within the trend
Place grid only in that zone (e.g., 100-pip range)
Wait for price to retrace into zone, then grids activate
Exit all if H4 trend reverses

Approach 3: Pyramid Grid

Smaller position sizes at better prices (deeper retracements)
Larger positions at worse prices (smaller retracements)
Takes advantage of probability - shallow pullbacks are more common


Risk Management Rules

Maximum grid levels: 5-8 orders max to avoid overexposure
Total exposure: Never exceed 2-3% account risk across all grid orders
Trend invalidation: Close ALL grids if H4 structure breaks (e.g., lower low in uptrend)
Time filter: Close grids before major news events
Drawdown limit: If floating loss exceeds X%, reduce grid size or pause

Entry Timing
Best entry points for grids:

After H4 candle close confirms trend continuation
During retracements to H4 moving average or pivot points
At round numbers (psychological levels) within the trend
After M15/M30 shows momentum exhaustion (RSI oversold in uptrend)
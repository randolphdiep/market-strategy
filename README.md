# Grid-Based Market Maker EA for MT5

A professional MQL5 Expert Advisor that implements a grid-based market making strategy with comprehensive risk management.

## Strategy Overview

This EA places buy and sell limit orders at regular intervals (grid levels) around the current market price. When price moves and triggers orders, the EA profits from the spread and price oscillations while maintaining a balanced position.

### How It Works

1. **Grid Placement**: Places buy limit orders below current price and sell limit orders above
2. **Order Execution**: When price reaches a grid level, the order is executed
3. **Profit Taking**: Each order has a take profit target
4. **Grid Maintenance**: Continuously maintains the grid structure as price moves
5. **Risk Management**: Multiple safety filters protect your account

## Features

### Core Strategy
- Configurable grid levels (number of orders on each side)
- Adjustable grid step (distance between orders)
- Take profit targets for each order
- Automatic grid reconstruction as price moves

### Risk Management
- **Spread Control**: Only trades when spread is below maximum threshold
- **Position Limits**: Caps total exposure to prevent overtrading
- **Daily Loss Limits**: Stops trading and optionally closes positions when daily loss reached
- **Volatility Filter**: Pauses during abnormal volatility using ATR indicator
- **Trading Hours**: Optional time-based trading restrictions

### Safety Features
- Minimum distance from current price to prevent immediate execution
- Automatic removal of orders too close to price
- Daily profit/loss tracking and display
- Real-time monitoring via chart comments

## Installation

1. Copy `MarketMaker_Grid.mq5` to your MT5 `Experts` folder:
   ```
   C:\Users\[YourName]\AppData\Roaming\MetaQuotes\Terminal\[TerminalID]\MQL5\Experts\
   ```

2. Compile the EA in MetaEditor (F7) or it will auto-compile when you drag it to a chart

3. Attach to any chart (works on all timeframes, but M5 or M15 recommended)

## Configuration

### Grid Settings

| Parameter | Default | Description |
|-----------|---------|-------------|
| GridLevels | 5 | Number of buy/sell orders on each side |
| GridStep | 100 | Distance between grid levels in points |
| LotSize | 0.01 | Volume for each order |
| TakeProfitPoints | 50 | Take profit distance in points |
| MagicNumber | 123456 | Unique identifier for EA's orders |

### Risk Management

| Parameter | Default | Description |
|-----------|---------|-------------|
| MaxSpreadPoints | 30 | Maximum allowed spread to place orders |
| MaxPositionSize | 1.0 | Maximum total exposure in lots |
| DailyLossLimit | 100.0 | Daily loss limit in account currency |
| UseVolatilityFilter | true | Enable/disable volatility checking |
| VolatilityPeriod | 20 | ATR period for volatility calculation |
| MaxVolatilityMultiplier | 2.0 | Max current ATR vs average ATR |

### Trading Hours

| Parameter | Default | Description |
|-----------|---------|-------------|
| UseTradingHours | false | Enable time-based filtering |
| StartHour | 8 | Start trading at this hour |
| EndHour | 18 | Stop trading at this hour |

### Advanced Settings

| Parameter | Default | Description |
|-----------|---------|-------------|
| Slippage | 10 | Maximum slippage in points |
| CloseOnDailyLimit | true | Close all positions when daily limit hit |
| OrderDistanceMin | 10 | Minimum points from price to keep order |

## Recommended Settings

### Conservative (Low Risk)
```
GridLevels = 3
GridStep = 150
LotSize = 0.01
MaxPositionSize = 0.3
DailyLossLimit = 50
```

### Moderate (Medium Risk)
```
GridLevels = 5
GridStep = 100
LotSize = 0.01
MaxPositionSize = 1.0
DailyLossLimit = 100
```

### Aggressive (High Risk)
```
GridLevels = 7
GridStep = 75
LotSize = 0.02
MaxPositionSize = 2.0
DailyLossLimit = 200
```

## Best Practices

### Symbol Selection
- **Best**: Major forex pairs with tight spreads (EUR/USD, GBP/USD, USD/JPY)
- **Good**: Minor pairs with decent liquidity (EUR/GBP, AUD/USD)
- **Avoid**: Exotic pairs with wide spreads or low liquidity

### Timeframe
- Chart timeframe doesn't significantly affect performance
- M5 or M15 recommended for visual monitoring
- EA updates on every tick

### Account Requirements
- **Minimum**: $100 for micro lots (0.01)
- **Recommended**: $500+ for proper risk management
- Use ECN/STP accounts with low spreads

### Risk Management Tips
1. Start with conservative settings and small lot sizes
2. Monitor daily loss limits closely in first week
3. Adjust grid step based on symbol's average daily range
4. Enable volatility filter during news events
5. Use trading hours filter to avoid overnight risk

## Monitoring

The EA displays real-time information on the chart:

```
=== GRID MARKET MAKER ===
Daily P/L: 15.50 / 100.00
Total Position: 0.05 / 1.00 lots
Pending Orders: 10
Active Positions: 2
Spread: 12.0 / 30.0 points
Volatility: OK
```

### What to Watch
- **Daily P/L**: Current profit/loss vs daily limit
- **Total Position**: Current exposure vs maximum allowed
- **Pending Orders**: Should equal GridLevels × 2 when no positions
- **Spread**: Current spread vs maximum threshold
- **Active Positions**: Number of filled orders

## Troubleshooting

### No Orders Placed
- Check if spread is too high
- Verify volatility filter isn't blocking
- Ensure within trading hours (if enabled)
- Check if daily loss limit reached

### Orders Keep Getting Deleted
- Increase `OrderDistanceMin` parameter
- Price is moving too fast, increase `GridStep`

### Too Many Positions
- Reduce `GridLevels`
- Increase `GridStep`
- Lower `MaxPositionSize`

### Daily Limit Hit Too Often
- Increase `DailyLossLimit`
- Reduce `LotSize`
- Decrease `GridLevels`
- Increase `GridStep`

## Important Warnings

1. **Trending Markets**: Grid strategies can accumulate losses in strong trends. Monitor positions during major trends.

2. **News Events**: High volatility during news can trigger multiple orders. Consider disabling EA before major announcements.

3. **Leverage**: Market making can use significant margin. Ensure adequate account balance.

4. **Spread Widening**: During low liquidity (nights, weekends), spreads can widen significantly.

5. **Backtesting Limitations**: Grid strategies are hard to backtest accurately. Use forward testing on demo account first.

## Strategy Optimization

### Finding Optimal Grid Step
1. Check symbol's Average True Range (ATR)
2. Set GridStep to 30-50% of daily ATR
3. Monitor for 1 week and adjust

### Position Sizing
- Use 1-2% risk per grid level
- Total exposure should not exceed 10% of account
- Formula: `LotSize = (AccountBalance × 0.01) / (GridLevels × GridStep in currency)`

## License

This EA is provided as-is for educational and trading purposes.

## Disclaimer

Trading forex carries a high level of risk and may not be suitable for all investors. Past performance is not indicative of future results. Always test on a demo account before live trading.

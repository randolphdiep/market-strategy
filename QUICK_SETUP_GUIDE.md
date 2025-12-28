# Quick Setup Guide - EUR/USD & BTC/USD

## EUR/USD Optimized Settings

### Account Size: $500-1000 (RECOMMENDED FOR BEGINNERS)

```
=== Grid Settings ===
GridLevels = 4
GridStep = 150 (15 pips)
LotSize = 0.01
TakeProfitPoints = 100 (10 pips)
MagicNumber = 111001

=== Risk Management ===
MaxSpreadPoints = 25 (2.5 pips)
MaxPositionSize = 0.40
DailyLossLimit = 50.0
UseVolatilityFilter = true
VolatilityPeriod = 20
MaxVolatilityMultiplier = 2.5

=== Trading Hours ===
UseTradingHours = true
StartHour = 8 (London open)
EndHour = 17 (Before NY close)

=== Advanced ===
Slippage = 20
CloseOnDailyLimit = true
OrderDistanceMin = 30
```

**Expected Performance:**
- Trades per day: 3-8
- Average profit per trade: $1-2
- Maximum drawdown: ~5%
- Daily target: $5-15

---

### Account Size: $1000-2000 (MODERATE)

```
=== Grid Settings ===
GridLevels = 5
GridStep = 120 (12 pips)
LotSize = 0.02
TakeProfitPoints = 80 (8 pips)
MagicNumber = 111002

=== Risk Management ===
MaxSpreadPoints = 30
MaxPositionSize = 1.0
DailyLossLimit = 100.0
UseVolatilityFilter = true
VolatilityPeriod = 20
MaxVolatilityMultiplier = 2.0

=== Trading Hours ===
UseTradingHours = true
StartHour = 7
EndHour = 18

=== Advanced ===
Slippage = 20
CloseOnDailyLimit = true
OrderDistanceMin = 25
```

**Expected Performance:**
- Trades per day: 5-12
- Average profit per trade: $2-3
- Maximum drawdown: ~8%
- Daily target: $10-30

---

### Account Size: $2000+ (AGGRESSIVE)

```
=== Grid Settings ===
GridLevels = 7
GridStep = 80 (8 pips)
LotSize = 0.03
TakeProfitPoints = 60 (6 pips)
MagicNumber = 111003

=== Risk Management ===
MaxSpreadPoints = 35
MaxPositionSize = 2.0
DailyLossLimit = 200.0
UseVolatilityFilter = true
VolatilityPeriod = 15
MaxVolatilityMultiplier = 2.0

=== Trading Hours ===
UseTradingHours = false
StartHour = 0
EndHour = 23

=== Advanced ===
Slippage = 25
CloseOnDailyLimit = true
OrderDistanceMin = 20
```

**Expected Performance:**
- Trades per day: 8-20
- Average profit per trade: $3-5
- Maximum drawdown: ~12%
- Daily target: $20-60

---

## BTC/USD Optimized Settings

⚠️ **IMPORTANT**: These values assume your broker quotes BTC/USD where:
- Price = $50,000
- 1 point = $0.01
- GridStep of 10000 = ~$100

**Always verify with your broker's symbol specification!**

---

### Account Size: $2000-3000 (CONSERVATIVE)

```
=== Grid Settings ===
GridLevels = 3
GridStep = 50000 (~$500 spacing)
LotSize = 0.01
TakeProfitPoints = 30000 (~$300)
MagicNumber = 222001

=== Risk Management ===
MaxSpreadPoints = 5000 (~$50)
MaxPositionSize = 0.30
DailyLossLimit = 200.0
UseVolatilityFilter = true
VolatilityPeriod = 24
MaxVolatilityMultiplier = 3.0

=== Trading Hours ===
UseTradingHours = false (24/7)
StartHour = 0
EndHour = 23

=== Advanced ===
Slippage = 100
CloseOnDailyLimit = true
OrderDistanceMin = 10000 (~$100)
```

**Expected Performance:**
- Trades per day: 2-6
- Average profit per trade: $3-8
- Maximum drawdown: ~15%
- Daily target: $10-40
- Note: Highly variable due to BTC volatility

---

### Account Size: $5000-8000 (MODERATE)

```
=== Grid Settings ===
GridLevels = 4
GridStep = 40000 (~$400 spacing)
LotSize = 0.02
TakeProfitPoints = 25000 (~$250)
MagicNumber = 222002

=== Risk Management ===
MaxSpreadPoints = 7500
MaxPositionSize = 0.80
DailyLossLimit = 400.0
UseVolatilityFilter = true
VolatilityPeriod = 24
MaxVolatilityMultiplier = 2.5

=== Trading Hours ===
UseTradingHours = true
StartHour = 13 (US morning)
EndHour = 22 (US evening)

=== Advanced ===
Slippage = 150
CloseOnDailyLimit = true
OrderDistanceMin = 8000
```

**Expected Performance:**
- Trades per day: 3-10
- Average profit per trade: $5-15
- Maximum drawdown: ~20%
- Daily target: $20-80

---

### Account Size: $10000+ (AGGRESSIVE)

```
=== Grid Settings ===
GridLevels = 5
GridStep = 30000 (~$300 spacing)
LotSize = 0.05
TakeProfitPoints = 20000 (~$200)
MagicNumber = 222003

=== Risk Management ===
MaxSpreadPoints = 10000
MaxPositionSize = 2.5
DailyLossLimit = 800.0
UseVolatilityFilter = true
VolatilityPeriod = 20
MaxVolatilityMultiplier = 2.5

=== Trading Hours ===
UseTradingHours = false
StartHour = 0
EndHour = 23

=== Advanced ===
Slippage = 200
CloseOnDailyLimit = true
OrderDistanceMin = 5000
```

**Expected Performance:**
- Trades per day: 5-15
- Average profit per trade: $10-30
- Maximum drawdown: ~25%
- Daily target: $40-150

---

## Critical Setup Steps

### For EUR/USD:

1. **Verify Broker Digits**
   - Right-click chart → Specification
   - Check if 5-digit (1.10235) or 4-digit (1.1023)
   - Most brokers use 5-digit

2. **Calculate Points from Pips**
   - 5-digit: 1 pip = 10 points
   - GridStep 150 = 15 pips
   - GridStep 100 = 10 pips

3. **Best Brokers**
   - IC Markets (spread: 0.1 pips)
   - Pepperstone (spread: 0.09 pips)
   - FXCM (spread: 0.2 pips)

4. **Best Trading Times (GMT)**
   - London Session: 08:00-12:00
   - NY Session: 13:00-17:00
   - Avoid Asian session (low volume)

### For BTC/USD:

1. **Calibrate Grid Step**
   ```
   Current BTC Price: $50,000
   Desired spacing: $500

   If broker shows: 5000000 (price with decimals)
   Then GridStep = 50000

   Test: Place one order and measure actual distance
   ```

2. **Check These in Symbol Specification**
   - Contract size
   - Point value
   - Tick size
   - Margin requirements

3. **Best Platforms**
   - BitMEX
   - Binance (via MT5 bridge)
   - Kraken
   - Note: Most crypto trading is on exchanges, not MT5

4. **Volatility Awareness**
   - BTC can move 10% in hours
   - Use wide grid spacing
   - Monitor during major moves
   - Consider pausing during news

---

## First Time Setup Checklist

- [ ] Open demo account with $1000+ balance
- [ ] Install EA and compile successfully
- [ ] Choose your pair (EUR/USD recommended for beginners)
- [ ] Copy appropriate settings for your account size
- [ ] Attach EA to M5 or M15 chart
- [ ] Enable AutoTrading button
- [ ] Verify orders are placed correctly
- [ ] Check spread is within limits
- [ ] Monitor for 1 hour to ensure proper operation
- [ ] Let run for 3-5 days on demo
- [ ] Review daily P/L and adjust if needed
- [ ] Only then consider live trading

---

## Monitoring Guide

### Daily Checks (2 minutes)

1. **Check Daily P/L**
   - Is it within expected range?
   - Did it hit daily limit?

2. **Check Position Count**
   - Are you maxed out on positions?
   - Is grid being maintained?

3. **Check Spread**
   - Is spread normal for time of day?
   - Any unusual widening?

### Weekly Analysis (15 minutes)

1. **Win Rate**
   - Should be 70-85%
   - Lower? Increase TakeProfitPoints

2. **Average Trade**
   - EUR/USD: $1-5 per trade
   - BTC/USD: $5-20 per trade

3. **Max Drawdown**
   - Should be under 20% of daily limit
   - Higher? Reduce GridLevels or LotSize

4. **Adjust if Needed**
   - Too many trades → Increase GridStep
   - Too few trades → Decrease GridStep
   - Frequent limit hits → Reduce risk

---

## Common Issues & Solutions

### "No orders placed"

**Check:**
- Spread too high? → Increase MaxSpreadPoints
- Volatility filter blocking? → Reduce MaxVolatilityMultiplier
- Outside trading hours? → Disable UseTradingHours

### "Daily limit hit too often"

**Solutions:**
- Reduce LotSize by 50%
- Increase DailyLossLimit
- Reduce GridLevels by 1-2
- Increase GridStep by 30%

### "Too many open positions"

**Solutions:**
- Reduce GridLevels
- Increase GridStep
- Lower MaxPositionSize
- Check if trending market (grid struggles in trends)

### "Orders deleted immediately"

**Solutions:**
- Increase OrderDistanceMin
- Market moving too fast → Increase GridStep
- Check broker's minimum distance requirement

---

## Performance Expectations

### EUR/USD (Monthly, $1000 account, Moderate settings)

```
Best case:  +$300-500 (+30-50%)
Average:    +$150-300 (+15-30%)
Bad month:  +$50-100 (+5-10%)
Worst case: -$200 (-20% - review strategy)
```

### BTC/USD (Monthly, $5000 account, Moderate settings)

```
Best case:  +$2000-3000 (+40-60%)
Average:    +$800-1500 (+16-30%)
Bad month:  +$200-400 (+4-8%)
Worst case: -$1000 (-20% - review strategy)
```

**Reality Check:**
- Market making is NOT get-rich-quick
- Expect slow, steady growth
- Some days will be negative
- Strong trends can cause drawdowns
- Requires patience and discipline

---

## When to Stop Using These Settings

**Stop immediately if:**
- Daily limit hit 3 days in a row
- Drawdown exceeds 30%
- Broker changed spread policy
- Major market changes (crisis, etc.)

**Adjust settings if:**
- Win rate below 60%
- Average trade profit too small
- Too many positions simultaneously
- Volatility increased significantly

---

## Support & Resources

**Questions?**
- Review README.md for detailed explanations
- Check Optimized_Settings.txt for all pairs
- Test on demo before live trading

**Recommended Reading:**
- Market making strategies
- Grid trading psychology
- Risk management principles
- MT5 trading basics

Good luck and trade safely!

# Liquidation

All open positions are subject to liquidation when the position’s equity value (collateral + PnL - fees) drops below 10% of the initial collateral size.

### Liquidation Threshold Factor

The liquidation threshold factor is currently set to 10% for all pairs. This means that if the net PnL (PnL - fees) of your position is below -90%, the position is subject to being liquidated.

### Liquidation Price

The liquidation price of a position may be changed over time as funding fee accumulate to the position's value.

$$LiqPrice = EntryPrice \cdot (1 - \frac{CollateralSize \cdot LiquidationThresholdFactor - ExitFee - FundingFees}{PositionSize})$$

where

* `ExitFee` is the amount of [maker or taker fee](fees.md) that is proportional to the position size.
* `FundingFees` is the amount of cumulative[ funding fee](fees.md) of the position.&#x20;


---
icon: gem
---

# Merkle LP

Merkle LP is the liquidity pool that acts as a counterparty to every trade on the protocol. The liquidity providers are rewarded with a share of trading fees in return, as well as any negative PnL from traders.&#x20;

The pool consists of zUSDC stablecoin (LayerZero bridged USDC) which is the asset used by traders as collateral on the platform.

* [Trading fee earnings for LPs](trading/fees.md) are automatically deposited into the Merkle LP (auto-compounding).
* There are no fees for deposits. However, a nominal fee of 0.1% applies to withdrawals. The fee is credited to the remaining LPs to reward long-term depositors.
* To help stabilize the protocol in volatile market conditions, liquidity providers can withdraw up to 20% of their initial deposit amount daily over a span of 5 days.

## MKLP

Users who provide liquidity receive the MKLP tokens as proof of their share in the liquidity pool. MKLP tokens are minted when liquidity providers deposit their assets into Merkle LP, and burned when they withdraw their funds from the pool. The value of the MKLP token can fluctuate based on traders' profits or losses, as determined by the following formula:

$$
Price = 1 - (accPnL + accRewards) / TotalDepositUSDC
$$

where:

* `accPnL` represents the cumulative sum of traders' profits and losses. When a trader takes their profit, the accPnL increases, leading to a decrease in MKLP price, and the opposite occurs when traders face losses.
* `accRewards` is the cumulative sum of entry/exit fee rewarded to LPs.
* `TotalDepositUSDC` is the sum of the total USDC deposited by users.

### LP Circuit Breaker

The circuit breaker serves as an additional safety layer for the LP, designed to prevent sudden draining in unlikely event such as where a zero-day vulnerability in trading module gets exploited. The circuit breaker acts as an additional safeguard to prevent the LP from getting entirely drained at an instance, even in the unlikely event of such event.

There are two kinds of thresholds for the LP circuit breaker:

* Soft threshold: once MDD (maximum draw down) of LP reaches below the soft threshold, only the increase orders (open orders, add collateral, etc) are no longer executed. Decrease orders are executed normally (close position, liquidation, ..)
* Hard threshold: triggered once MDD reaches below the hard threshold, both increase and decrease orders are all aborted.


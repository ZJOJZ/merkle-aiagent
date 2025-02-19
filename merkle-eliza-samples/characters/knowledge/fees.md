# Fees

## **Entry/Exit Fee**

Entry/Exit Fees are charged proportionally to the position size when a position is opened or closed. The maker fee rate is applied when a trade reduces the Market Ske&#x77;_,_ whereas the taker fee rate is applied when it increases the Market Skew.

* Crypto
  * BTC, ETH: maker fee 0.03%, taker fee 0.06%
  * All other crypto pairs: maker fee: 0.04%, taker fee 0.08%
* Forex: maker fee 0.0075%, taker fee 0.0125%
* Commodities : maker fee 0.04%, taker fee 0.06%

Market Skew is defined as `Long OI - Short OI` for each pair. For example, if the Long OI is 34k and Short OI is 14k on a pair, then the Market Skew is +20k.

#### Example

Let's say the Long OI is $1,500,000 and Short OI is $1,000,000 for a crypto pair. The Market Skew for the pair is +$500,000.

When a trader opens a new $500,000 long position, the taker fee rate will be applied as it increases the Market Skew (+$500,000 -> +$1,000,000), thus the charged amount is $500 (=$500,000 \* 0.1% taker fee) as the entry fee.

When a trader opens a new $500,000 short position, then the entry fee of $250 (=$500,000 \* 0.05% maker fee) is charged as it decreases the Market Skew (+$500,000 -> $0).

#### Distribution of Entry/Exit Fees

Entry and exit fees are collected and distributed as follows: 50% to the MKLP, 30% to the Protocol Fund, and 20% to the Dev Fund. Specific ratios may change temporarily for risk management purposes.

* **MKLP (50%)**: The fees distributed to liquidity providers help offset their risk and incentivize additional liquidity. A higher liquidity pool enhances the liquidity and stability of the protocol.
* **Protocol Fund (30%)**: The portion allocated to the Governance Fund is used to reward $MKL staking participants (details in the [MKL Staking](../mkl-tokenomics/mkl-staking.md) section). The remaining funds are held in the protocol treasury to support future development and provide insurance.
* **Dev Fund (20%)**: The share directed to the Dev Fund is used for operational expenses, protocol development and growth.

## **Price Impact**

To balance the total open interests of long and short positions on the protocol, price impact is applied to the index price:

$$
\begin{aligned}
\text{Price Impact} &= 0.5 \cdot \frac{2 \cdot \text{Market Skew}+\text{Size Delta}}{\text{Skew Factor}} \\[1em]
\text{Market Price} &= \text{Index Price} + \text{Price Impact}
\end{aligned}
$$

* **Market Price**: The current price at which the asset is being traded.
* **Index Price**: The reference price of the asset, provided by [Pyth Network](price-feed.md), a decentralized oracle network.

Note that price impact can work in the trader's favor, as illustrated in the Example #2 below.

<details>

<summary>Example #1</summary>

* Current BTC/USD price: $25,000
* Long open interest in BTC/USD: $1,500,000
* Short open interest in BTC/USD: $1,000,000
* Market skew: +$500,000
* BTC/USD skewFactor: 2\*10^9
* If trader opens a new $500,000 long position of BTC/USD, then the price impact would be 0.000375 (=`0.5 * {500,000/ (2*10^9) + 1,000,000 / (2*10^9)}`).
* The trader would enter at $25,009.375 (+0.0375%).

</details>

<details>

<summary>Example #2</summary>

* Current BTC/USD price: $25,000
* Long open interest in BTC/USD: $1,000,000
* Short open interest in BTC/USD: $1,800,000
* Market skew: -$800,000
* BTC/USD skewFactor: 2\*10^9
* If trader opens a new $200,000 long position of BTC/USD, then the price impact would be -0.00035 (=`0.5 * {-800,000/ (2*10^9) -600,000 / (2*10&9)}`)
* The trader would enter at $24,991.25 (-0.035%).

</details>

<details>

<summary>Derivation</summary>

$$\begin{aligned} \text{Price Impact} &= \frac{\text{Price Impact}_{before} + \text{Price Impact}_{after}}{2} \\[1em] \text{Price Impact}_{before} &= \frac{\text{Market Skew}}{\text{Skew Factor}} \\[1em] \text{Price Impact}_{after} &= \frac{\text{Market Skew} + \Delta \text{Position Size}}{\text{Skew Factor}} \end{aligned}$$

</details>

## **Funding Fee**

Funding fee serves to balance the total open interests of long and short positions on the protocol. If there are more users opening Long positions (longing) than the Short ones (shorting), the users who long pay a certain portion of the fees to the users who short. The cost corresponding to these fees is paid in the form of a Funding Fee.

When the funding rate is positive (+), there are more long trades on the protocol and the users who long effectively cover the funding fees for the users who short. When the funding fee is negative (-), it works in reverse to the above situation.

#### Velocity-based Funding Rate

As opposed to the traditional model where the funding rate is determined by the market skew, in our velocity-based funding rate model, the market skew determines the _velocity_ at which the funding rate changes. The goal of the velocity-based funding rate mechanism is to make the funding rate more predictable for those who are interested in arbitraging the funding fee.

Here's the formula used to calculate the funding rate on position updates:

$$
\text{Funding Rate} = \text{Funding Rate}_{prev} + \frac{\text{Market Skew}}{\text{Skew Factor}} \cdot \text{Max Funding Velocity} \cdot \frac{\text{Time Delta (s)}}{\text{86400}}
$$


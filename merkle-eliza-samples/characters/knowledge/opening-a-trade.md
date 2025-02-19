# Opening a Trade

Opening a position on Merkle Trade gives you the ability to gain leveraged exposure to the price of an asset without having to acquire the underlying asset.

<figure><img src="../.gitbook/assets/UI general1.png" alt=""><figcaption></figcaption></figure>

You can either open a 'Buy' (aka Long) or 'Sell' (aka Short) position, where a buy position yields profit if the asset price increases and incurs a loss if the price decreases. On the other hand, a sell position yields profit when the asset price drops.

## **Market/Limit Order**

Merkle Trade offers two types of orders:

* **Market Order:** Order in which you immediately enter a position at the current market price.
* **Limit Order:** Order to enter a position when the price moves to a desired price or better than the specified price. Note that there is still a possibility the order will not be executed if the price moves quickly. You can cancel a limit order in the Order tab if it hasn't been executed after some time.

<figure><img src="../.gitbook/assets/UI marketlimit.png" alt="" width="348"><figcaption></figcaption></figure>

## Collateral & Leverage

* **Collateral (#1)** is the amount of funds you use to open a trading position.
* **Leverage (#2)** determines the multiplier for the exposure to the underlying asset. With leverage, you can open a larger position with a smaller amount of initial capital. This means that any profits or losses on the position are magnified by the leverage used.
* **Position Size (#3)** refers to the extent of a position's exposure, which is determined by multiplying collateral by leverage.
* **Position details (#4)** specifies the entry price (if it's market order) and the liquidation price

<div align="center" data-full-width="false"><figure><img src="../.gitbook/assets/UI collateralleverage.png" alt="" width="182"><figcaption></figcaption></figure></div>

<div align="center"><figure><img src="../.gitbook/assets/UI trade details.png" alt="" width="170"><figcaption></figcaption></figure></div>

## **Take Profit / Stop Loss**

Take Profit and Stop Loss are features that allow you to set a target price for the automatic closure of your position.

<figure><img src="../.gitbook/assets/UI SLTP.png" alt="" width="375"><figcaption></figcaption></figure>

* **Take Profit (TP)** is a pre-determined price level at which you might intend to close your position to lock in profits. For risk management purposes, the maximum Take Profit is currently limited to 900%.
* **Stop Loss (SL)** is a pre-determined price level at which you might intend to close the position to limit the losses in case the market moves against your position.

{% hint style="danger" %}
For forex & commodity pairs, Take Profit and Stop Loss may be executed at prices significantly different from the specified price, due to a price gap between the market's closing price and the next market's opening price.
{% endhint %}

## **Price Impact**

Price impact is applied to the index price to balance the total open interests of long and short positions on the protocol. On the frontend, the "Mark price" reflects the execution price of the order, taking the price impact into account.

Please refer to [fees.md](fees.md "mention") for more details.

## Trading Limitations

To maintain the security and reliability of the protocol, certain limitations are in place:

* **Profit Cap**: The maximum profit a trader can realize in a single trade is capped at 900%.
* **Collateral Limit**: The maximum collateral allowed per position is 5,000 USDC.
* **Maximum Open Interest**: Each trading pair has a maximum open interest, dynamically adjusted based on the current market condition.
* **Minimum Position Size**: Trades have minimum position requirements:
  * Crypto: 300 USDC
  * Commodities: 600 USDC
  * Forex: 1,500 USDC
* **Minimum Collateral Requirement**: The minimum collateral size for any position is 2 USDC.
* **Trade Cooldown Period**: For the first 60 seconds after opening a trade, you won’t be able to close it for a profit (you can still close the position at a loss). Note that Take Profit orders are also activated after this period.

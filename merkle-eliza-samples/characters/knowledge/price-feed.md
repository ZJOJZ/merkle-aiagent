# Price Feed

Merkle Trade utilizes [Pyth Network](https://pyth.network/), a decentralized oracle network with the lowest latency as the primary source for order execution pricing.

### Order Execution Flow

In order to prevent any front-running, orders are executed through a process involving two separate transactions:

1. Trader submits an order with a price with slippage applied, which then awaits the execution within the contract.
2. Keeper submits a transaction for execution with the real-time index price, then the order is executed with the mark price.

Keepers are initially run by the core team. However, we plan to decentralize the keepers by establishing the decentralized keeper network in the near future.

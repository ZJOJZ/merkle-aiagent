import { type Account, Aptos, type CommittedTransactionResponse } from "@aptos-labs/ts-sdk";
import { elizaLogger } from "@elizaos/core";
import {
	MerkleClient,
  AptosHelpers,
	calcEntryByPaySize,
	fromNumber,
	Decimals,
  raise,
  type SummaryPair,
	type Summary,
	type MerkleClientConfig,
  type Position,
  type Hex,
  type Order,
  type WSAPISession,
} from "@merkletrade/ts-sdk";
import NodeCache from "node-cache";
import { firstAsync, sendTransaction, withTimeout } from "./utils";

export class MerkleService {
	private client: MerkleClient;
  private aptos: Aptos;
  private aptosHelper: AptosHelpers;
  private cache: NodeCache;
  private cacheKey = "merkle/provider";

  private account: Account;
  private summary: Summary;

	constructor(config: MerkleClientConfig, account: Account) {
		this.client = new MerkleClient(config);
		this.aptosHelper = new AptosHelpers(config);
		this.cache = new NodeCache({ stdTTL: 300 });
    this.account = account;
    this.summary = config.summary;
    this.aptos = new Aptos(config.aptosConfig);
	}

  /**
   * Trading operations
   */

  /**
   * Place a market order
   * @param pair string
   * @param pay number
   * @param leverage number
   * @param isLong boolean
   * @returns Transaction
   */
	async placeMarketOrder({
		pair,
		pay,
		leverage,
		isLong,
	}: {
		pair: string;
		pay: number;
		leverage: number;
		isLong: boolean;
	}) {
		const pairInfo = await this.client.getPairInfo({pairId: pair});
		const pairState = await this.client.getPairState({pairId: pair});
		const payWithDecimals = fromNumber(pay, Decimals.COLLATERAL);

		const { collateral, size } = calcEntryByPaySize(
			payWithDecimals,
			leverage,
			isLong,
			pairInfo,
			pairState,
		);

    const payload = this.client.payloads.placeMarketOrder({
      pair: pairInfo.pairType,
      userAddress: this.getAccountAddress(),
      sizeDelta: size,
      collateralDelta: collateral,
      isLong,
      isIncrease: true,
    })

    return await sendTransaction(this.aptos, this.account, payload);
	}

  /**
   * Place a limit order
   * @param pair string
   * @param pay number
   * @param leverage number
   * @param isLong boolean
   * @param limitOrderPrice number
   * @returns Transaction
   */
  async placeLimitOrder({
    pair,
    pay,
    leverage,
    isLong,
    limitOrderPrice,
  }: {
    pair: string;
    pay: number;
    leverage: number;
    isLong: boolean;
    limitOrderPrice: number;
  }) {
    const pairInfo = await this.client.getPairInfo({pairId: pair});
    const pairState = await this.client.getPairState({pairId: pair});
    const payWithDecimals = fromNumber(pay, Decimals.COLLATERAL);

    const { collateral, size } = calcEntryByPaySize(
      payWithDecimals,
      leverage,
      isLong,
      pairInfo,
      pairState,
    );

    const payload = this.client.payloads.placeLimitOrder({
      pair: pairInfo.pairType,
      userAddress: this.getAccountAddress(),
      sizeDelta: size,
      collateralDelta: collateral,
      price: fromNumber(limitOrderPrice, Decimals.PRICE),
      isLong,
      isIncrease: true,
    })

    return await sendTransaction(this.aptos, this.account, payload);
  }

  /**
   * Close all positions
   * @returns Transaction[]
   */
  async closeAllPositions() {
    const positions = await this.getPositions();
    const txs: CommittedTransactionResponse[] = [];
    for (const position of positions) { 
      const tx = await this.closePosition(position);
      txs.push(tx);
    }
    return txs;
  }

  /**
   * Close a position
   * @param position Position
   * @returns Transaction
   */
  async closePosition(position: Position) {
    try {
      const payload = this.client.payloads.placeMarketOrder({
        pair: position.pairType,
        userAddress: this.getAccountAddress(),
        sizeDelta: position.size,
        collateralDelta: position.collateral,
        isLong: position.isLong,
        isIncrease: false,
      });
      const tx = await sendTransaction(this.aptos, this.account, payload)
      return tx;
    } catch (error) {
      throw this.handleError(error, "closePosition");
    }
  }

  /**
   * Account-related operations
   */
	getAccount(): Account {
		return this.account;
	}

  /**
   * Get account address
   * @returns Hex
   */
	getAccountAddress(): Hex {
		return this.account.accountAddress.toStringLong();
	}

  /**
   * Get positions of the account
   * @returns Position[]
   */
	async getPositions(): Promise<Position[]> {
    const address = this.getAccountAddress();
    try {
      return await this.client.getPositions({address});
    } catch (error) {
      throw this.handleError(error, `getPositions: ${address}`);
    }
	}

  /**
   * Get orders of the account
   * @returns Order[]
   */
	async getOrders(): Promise<Order[]> {
    const address = this.getAccountAddress();
    try {
      return await this.client.getOrders({address});
    } catch (error) {
      throw this.handleError(error, `getOrders: ${address}`);
    }
	}

  /**
   * Get balance of the account
   * @returns AccountBalance
   */
	async getBalance(): Promise<AccountBalance> {
    try{
      const usdcBalance = await this.aptosHelper.getUsdcBalance(this.account);
      return { usdc: usdcBalance } satisfies AccountBalance;
    } catch (error) {
      throw this.handleError(error, "getBalance");
    }
	}

  /**
   * Market-related operations
   */
  async getLatestPrice(pair: string) {
    let session: WSAPISession | undefined;
    try {
      const pairInfo = this.getPair(pair);
      session = await this.client.connectWsApi();
      await session.connect();
      const priceFeed = session.subscribePriceFeed(pairInfo.id);
      const price = await withTimeout(firstAsync(priceFeed), 5000);
      return price;
    } catch (error) {
      throw this.handleError(error, "getLatestPrice");
    } finally {
      session?.disconnect();
    }
  }

  /**
   * Get summary of the account
   * @returns SummaryResponse
   */
	async getSummary() {
    try {
      const cachedSummary = this.cache.get<Summary>(`${this.cacheKey}/summary`);
      if (cachedSummary) {
        return cachedSummary;
      }
      const summary = await this.client.getSummary();
      this.cache.set(`${this.cacheKey}/summary`, summary);
      return summary;
    } catch (error) {
      throw this.handleError(error, "getSummary");
    }
	}

  private getPair(rawPair: string): SummaryPair {
    return this.summary.pairs.find((pair) => pair.id.toUpperCase().includes(rawPair.toUpperCase())) ?? raise("Pair not found");
  }

  private handleError(error: unknown, context?: string): never {
		elizaLogger.error("Unexpected error: ", { context, error });
		throw error;
	}
}

export type AccountBalance = {
	usdc: Decimals.Collateral;
};

export default MerkleService;
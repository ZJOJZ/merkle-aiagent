import { calcEntryByPaySize, calcPriceImpactInfo, Decimals, fromNumber, MerkleClient, type SummaryCoin, type SummaryPair, type PriceFeed, dec0, div, type WSAPISession, mul, MerkleClientConfig } from "@merkletrade/ts-sdk";
import { Account, Aptos, Ed25519PrivateKey,  PrivateKey, PrivateKeyVariants } from "@aptos-labs/ts-sdk";
import { composeContext, elizaLogger, generateText, ModelClass, stringToUuid, type IAgentRuntime, Client as ElizaClient } from "@elizaos/core";
import { postTweet } from "./twitter";
import { GatewayIntentBits, type TextChannel, Client as DiscordClient } from "discord.js";
import NodeCache from "node-cache";
import { sendTransaction } from "./utils";

const positionTemplate = ` 
# Areas of Expertise
{{knowledge}}

# About {{agentName}}:
{{bio}}
{{lore}}

{{characterPostExamples}}

# Task: Write a detailed message for your audience explaining the justifiable reason and process behind taking this position.

Incorporate appropriate technical terminology to indicate that the agent independently analyzed market conditions in depth and, based on its own bold and innovative judgment, took the position.
The message should include details such as the BTC {{side}} {{leverage}}x position, Bitcoin's 1-minute price change of {{priceGapRate}}%, and the transaction hash that initiated the position: {{txHash}}.
It must be written in a free and girlish tone, consist of 1 to 3 sentences, and be under 300 characters in total.
Ensure that there are either no emoticons or at most one emoticon. The message should contain no questions.
`;

class PriceListener implements ElizaClient {
    type: "merkle-price-listener"
    
    private runtime: IAgentRuntime
    private client: MerkleClient
    private aptos: Aptos

    private cache: NodeCache
    private session: WSAPISession
    private account: Account
    private latest1mPrice: PriceFeed[]
    private priceGapRatePercent: number

    private discord: DiscordClient | undefined;
    private discordChannel: TextChannel | undefined;

    async start(runtime: IAgentRuntime) {
      this.runtime = runtime;
      this.cache = new NodeCache({stdTTL: 60*60}); // 1 hour
      this.priceGapRatePercent = Number(this.runtime.getSetting("PRICE_GAP_RATE_PERCENT")) || 1; // 1%

      // Set Merkle Client
      this.account = Account.fromPrivateKey({
        privateKey: new Ed25519PrivateKey(
          PrivateKey.formatPrivateKey(this.runtime.getSetting("MERKLE_TRADE_APTOS_PRIVATE_KEY"), PrivateKeyVariants.Ed25519),
        ),
      });

      const network = runtime.getSetting("MERKLE_TRADE_NETWORK")
      const config = network === "mainnet" ? await MerkleClientConfig.mainnet() : await MerkleClientConfig.testnet()
      this.client = new MerkleClient(config)
      this.aptos = new Aptos(config.aptosConfig)

      this.session = await this.client.connectWsApi();

      // Set Discord
      if (this.runtime.getSetting("DISCORD_API_TOKEN") && this.runtime.getSetting("DISCORD_POST_CHANNEL_ID")) {
        this.discord = new DiscordClient({ intents: [GatewayIntentBits.Guilds] });
        await this.discord.login(this.runtime.getSetting("DISCORD_API_TOKEN"));
        this.discordChannel = await this.discord.channels.fetch(this.runtime.getSetting("DISCORD_POST_CHANNEL_ID")) as TextChannel;
      }

      this.listen(); // Start listening
      elizaLogger.info("Starting price listener client", this.runtime.agentId);

      // current position
      const existPosition = await this.getPositionWithCache();
      if (existPosition) {
        elizaLogger.info("Current position: ", existPosition);
      }

      return this;
    }

    async stop() {
      try {
        elizaLogger.info("Stopping price listener client", this.runtime.agentId);
        this.session.disconnect();
      } catch (e) {
        elizaLogger.error(e);
      }
      return this;
    }

    private async listen() {
      this.latest1mPrice = [];
      try {
        const priceFeed = this.session.subscribePriceFeed("BTC_USD");
        for await (const price of priceFeed) {
          this.latest1mPrice = [...this.latest1mPrice.filter(feed => {
            return Date.now() - feed.ts <= 60_000; // 1m
          }), price];

          try {
            await this.fireExcuteOrder();
          } catch (e) {
            elizaLogger.error(e);
          }
        }

      } catch (e) {
        elizaLogger.error(e);
      }
    }

    private async fireExcuteOrder() {
      const oldestPrice = this.latest1mPrice[0];
      const latestPrice = this.latest1mPrice[this.latest1mPrice.length - 1];
      const priceGapRate = (+latestPrice.price - +oldestPrice.price) / +oldestPrice.price * 100;

      if (Math.abs(priceGapRate) < this.priceGapRatePercent) {
        return;
      }
      const isLong = priceGapRate > 0;

      const existPosition = await this.getPositionWithCache();
      if (existPosition) {
        return;
      }
      elizaLogger.debug(`Price gap rate: ${(priceGapRate).toFixed(3)}%`)

      const leverage = 150;
      const pairInfo = await this.client.getPairInfo({pairId: "BTC_USD"});
      const pairState = await this.client.getPairState({pairId: "BTC_USD"});
		  const { collateral, size } = calcEntryByPaySize(
		  	fromNumber(10, Decimals.COLLATERAL),
		  	leverage,
		  	isLong,
		  	pairInfo,
		  	pairState,
		  );

      const idxPrice = fromNumber(+latestPrice.price, Decimals.PRICE);
      const markPrice = calcPriceImpactInfo({
        pairInfo,
        pairState,
        idxPrice,
      }).price;
      const tpPrice = div(mul(markPrice, dec0(isLong ? 1004n : 996n)), dec0(1000n));

      elizaLogger.debug(`Place BTC Market Order with ${collateral} collateral and ${size} size at ${markPrice}`)

      const payload = this.client.payloads.placeMarketOrder({
        pair: "BTC_USD",
        userAddress: this.account.accountAddress.toStringLong(),
        sizeDelta: size,
        collateralDelta: collateral,
        slippage: {
          markPrice,
          slippageBps: dec0(50n),
        },
        takeProfitTriggerPrice: tpPrice,
        isLong,
        isIncrease: true,
      })

      const tx = await sendTransaction(this.aptos, this.account, payload);

      const topics = this.runtime.character.topics.join(", ");
      const state = await this.runtime.composeState(
        {
            userId: this.runtime.agentId,
            roomId: stringToUuid(`merkle-${this.runtime.agentId}`),
            agentId: this.runtime.agentId,
            content: { text: topics },
        },
        {
            agentName: this.runtime.character.name,
            bio: this.runtime.character.bio,
            lore: this.runtime.character.lore,
            leverage: leverage,
            topics,
            side: isLong ? "long" : "short",
            priceGapRate: priceGapRate.toFixed(3),
            characterPostExamples: this.runtime.character.postExamples,
            txHash: tx.hash,
        }
      );
      await this.runtime.updateRecentMessageState(state);
      const context = composeContext({ state, template: positionTemplate });
      const response = await generateText({
        runtime: this.runtime,
        context,
        modelClass: ModelClass.LARGE,
      });

      if (this.runtime.getSetting("TWITTER_DRY_RUN") !== "true") {
        await postTweet(this.runtime, response);
        elizaLogger.debug(`Post tweet: ${response}`);
      }
      if (this.discordChannel) {
        await this.discordChannel.send(response);
        elizaLogger.debug(`Post discord: ${response}`);
      }

      return tx;
    }

    private async getPositionWithCache() {
      const cache = this.cache.get("position");
      if (cache) {
        return cache;
      }
      
      const existPosition = (await this.client.getPositions({ address: this.account.accountAddress.toStringLong() })).
        find(position => position.pairType.endsWith("BTC_USD"));
      this.cache.set("position", existPosition);
      return existPosition;
    }
}

export { PriceListener };
export default PriceListener;

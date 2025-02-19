import { Account, Ed25519PrivateKey, PrivateKey, PrivateKeyVariants } from "@aptos-labs/ts-sdk";
import { composeContext, elizaLogger, generateText, ModelClass, stringToUuid, type IAgentRuntime } from "@elizaos/core";
import { AptosHelpers, calcPnlWithoutFee, div, fromNumber, MerkleClient, MerkleClientConfig, toNumber } from "@merkletrade/ts-sdk";
import { postTweet } from "./twitter";
import { type TextChannel, Client as DiscordClient, GatewayIntentBits } from "discord.js";

const announceTemplate = `
# About {{agentName}}:
{{bio}}
{{lore}}

# Trading Update:
Positions:
{{currentPositions}}

Balance: {{currentBalance}}

# Task: Write a cute and girlish message that explains your current trading positions and balance.
Incorporate subtle technical details where necessary, and maintain a confident yet playful tone.
It must be written in a free and girlish tone, consist of 1 to 3 sentences, and be under 300 characters in total.
Ensure that there are either no emoticons or at most one emoticon. The message should contain no questions.
`;

class AgentObserver {
  type: "merkle-agent-observer"

  private runtime: IAgentRuntime
  private client: MerkleClient
  private aptosHelper: AptosHelpers

  private account: Account
  private interval: NodeJS.Timeout | undefined;

  private discord: DiscordClient | undefined;
  private discordChannel: TextChannel | undefined;
  
  async start(runtime: IAgentRuntime) {
    this.runtime = runtime;
    this.account = Account.fromPrivateKey({
      privateKey: new Ed25519PrivateKey(
        PrivateKey.formatPrivateKey(this.runtime.getSetting("MERKLE_TRADE_APTOS_PRIVATE_KEY"), PrivateKeyVariants.Ed25519),
      ),
    });

    const network = runtime.getSetting("MERKLE_TRADE_NETWORK")
    const config = network === "mainnet" ? await MerkleClientConfig.mainnet() : await MerkleClientConfig.testnet()
    this.client = new MerkleClient(config)
    this.aptosHelper = new AptosHelpers(config)

    if (this.runtime.getSetting("DISCORD_API_TOKEN") && this.runtime.getSetting("DISCORD_POST_CHANNEL_ID")) {
      this.discord = new DiscordClient({ intents: [GatewayIntentBits.Guilds] });
      await this.discord.login(this.runtime.getSetting("DISCORD_API_TOKEN"));
      this.discordChannel = await this.discord.channels.fetch(this.runtime.getSetting("DISCORD_POST_CHANNEL_ID")) as TextChannel;
    }

    // announce every 30 minutes
    this.interval = setInterval(() => this.announce(), 30 * 60 * 1000);
    await this.announce();

    elizaLogger.info("Starting agent observer", this.runtime.agentId);
    return this;
  }

  async stop() {
    if (this.interval) {
      clearInterval(this.interval);
    }
    elizaLogger.info("Stopping agent observer", this.runtime.agentId);
    return this;
  }

  // Broadcast the agent's current position and balance.
  private async announce() {
    const currentPositions = await this.client.getPositions({ address: this.account.accountAddress.toStringLong() })
    const currentBalance = await this.aptosHelper.getUsdcBalance({ accountAddress: this.account.accountAddress.toStringLong() })
    const currentPrice = (await this.client.getSummary()).prices.find((price) => price.id === "BTC_USD")?.price

    const currnetPositionInfos = currentPositions.map((position) => {
      const p = {
        pair: `$${position.pairType.split("::")[2].split("_")[0]}/${position.pairType.split("::")[2].split("_")[1]}`,
        size: toNumber(position.size, 6).toFixed(2),
        collateral: toNumber(position.collateral, 6).toFixed(2),
        leverage: toNumber(div(position.size, position.collateral), 0),
        isLong: position.isLong,
        pnl: calcPnlWithoutFee({position, executePrice: fromNumber(currentPrice, 10), decreaseOrder: {sizeDelta: position.size}})
      }
      return `Pair: ${p.pair}, Side: ${p.isLong ? "long" : "short"}, Leverage: ${p.leverage}, Size: ${p.size}, Collateral: ${p.collateral}, PNL: ${p.pnl}`
    }).join("\n")
    

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
          topics,
          currentPositions: currnetPositionInfos,
          currentBalance: toNumber(currentBalance, 6),
      }
    );
    await this.runtime.updateRecentMessageState(state);
    const context = composeContext({ state, template: announceTemplate })
    const response = await generateText({
      runtime: this.runtime,
      context,
      modelClass: ModelClass.LARGE,
    })
    
    if (this.runtime.getSetting("TWITTER_DRY_RUN") !== "true") {
      await postTweet(this.runtime, response);
      elizaLogger.debug(`Post tweet: ${response}`);
    }
    if (this.discordChannel) {
      await this.discordChannel.send(response);
      elizaLogger.debug(`Post discord: ${response}`);
    }
  }
}

export { AgentObserver };
export default AgentObserver;

import { elizaLogger, generateObjectDeprecated } from "@elizaos/core";
import {
	type ActionExample,
	type HandlerCallback,
	type IAgentRuntime,
	type Memory,
	ModelClass,
	type State,
	type Action,
} from "@elizaos/core";
import { composeContext } from "@elizaos/core";
import type {
	CommittedTransactionResponse,
	PendingTransactionResponse,
} from "@aptos-labs/ts-sdk";
import { OpenOrderSchema } from "../types";
import { checkEnv, newMerkleService } from "../utils";

const openOrderTemplate = `Respond with a JSON markdown block containing only the extracted values. Use null for any values that cannot be determined.

Example response:
\`\`\`json
{
    "coinSymbol": "BTC",
    "pay": 1000,
    "leverage": 10,
    "side": "LONG",
    "type": "MARKET"
}
\`\`\`

\`\`\`json
{
    "coinSymbol": "BTC",
    "pay": 1000,
    "leverage": 10,
    "side": "SHORT",
    "type": "LIMIT",
    "limitOrderPrice": 98000
}
\`\`\`

{{recentMessages}}

Given the recent messages, extract the following information about the requested futures position order:
- coinSymbol : Coin symbol (Must be a valid coin symbol, Must be provided by the user)
- pay : Pay amount (Must be a number, Must be provided by the user)
- leverage : Leverage (Must be 3 to 1000, Must be provided by the user)
- type : Type of order (Must be "MARKET" or "LIMIT")
- side : Side of the position (Must be "LONG" or "SHORT", Must be provided by the user)
- limitOrderPrice : Limit order price (Must be a number, optional)

Respond with a JSON markdown block containing only the extracted values.`;

export default {
	name: "OPEN_ORDER",
	similes: [
    "FUTURES_TRADE",
    "OPEN_MARKET_ORDER",
		"OPEN_LIMIT_ORDER",
		"BUY_LONG",
		"BUY_SHORT",
		"OPEN_POSITION",
		"PLACE_ORDER",
	],
	description: "Open a futures position on the Merkle Trade platform",
	examples: [
		[
			{
				user: "{{user}}",
				content: {
					text: "Open a BTC Long position on the Merkle Trade platform with 1000 pay and 10 leverage",
				},
			},
			{
				user: "{{agent}}",
				content: {
					text: "Successfully market order BTC with 1000 pay and 10 leverage, Transaction: 0x104af5d1a786a2e1a4721a721b2cfccc7e15fa41eec15a489ba1768790adb523",
					action: "OPEN_ORDER",
				},
			},
		],
    [
			{
				user: "{{user}}",
				content: {
					text: "Buy a BTC on the Merkle Trade platform with 100 pay and 100 leverage",
				},
			},
      {
        user: "{{agent}}",
        content: {
          text: "Is it a long position or a short position?"
        },
      },
      {
        user: "{{user}}",
        content: {
          text: "Short Position"
        },
      },
			{
				user: "{{agent}}",
				content: {
					text: "Successfully open short position BTC with 1000 pay and 10 leverage, Transaction: 0x104af5d1a786a2e1a4721a721b2cfccc7e15fa41eec15a489ba1768790adb523",
					action: "OPEN_ORDER",
				},
			},
    ],
    [
      {
        user: "{{user}}",
        content: {
          text: "Open a BTC Long position on the Merkle Trade platform with 1000 pay and 10 leverage at 98000",
        },
      },
      {
        user: "{{agent}}",
        content: {
          text: "Successfully limit order BTC at 98000 with 1000 pay and 10 leverage, Transaction: 0x104af5d1a786a2e1a4721a721b2cfccc7e15fa41eec15a489ba1768790adb523",
          action: "OPEN_ORDER",
        },
      },
    ],
    [
      {
        user: "{{user}}",
        content: {
          text: "Execute a ETH limit order on the Merkle Trade platform with 1000 pay and 10 leverage at 98000",
        },
      },
      {
        user: "{{agent}}",
        content: {
          text: "Is it a long position or a short position?"
        },
      },
      {
        user: "{{user}}",
        content: {
          text: "Long Position"
        },
      },
      {
        user: "{{agent}}",
        content: {
          text: "Successfully limit long order ETH at 98000 with 1000 pay, 10 leverage, Transaction: 0x104af5d1a786a2e1a4721a721b2cfccc7e15fa41eec15a489ba1768790adb523",
          action: "OPEN_ORDER",
        },
      },
    ]
	] as ActionExample[][],
	validate: async (runtime: IAgentRuntime) => {
		return checkEnv(runtime);
	},
	handler: async (
		runtime: IAgentRuntime,
		message: Memory,
		state: State,
		_options: { [key: string]: unknown },
		callback?: HandlerCallback,
	): Promise<boolean> => {
    // biome-ignore lint/suspicious/noExplicitAny: <explanation>
    let content: any;
    try {
      let currentState = state;
      if (!currentState) {
        currentState = (await runtime.composeState(message)) as State;
      } else {
        currentState = await runtime.updateRecentMessageState(currentState);
      }

      const context = composeContext({
        state: currentState,
        template: openOrderTemplate,
      });

      content = await generateObjectDeprecated({
        runtime,
        context: context,
        modelClass: ModelClass.LARGE,
      });

      if (content && typeof content.pay === "string") {
        content.pay = Number.parseFloat(content.pay);
      }
      if (content && typeof content.leverage === "string") {
        content.leverage = Number.parseFloat(content.leverage);
      }
      if (content && typeof content.side === "string") {
        switch (content.side.toUpperCase()) {
          case "LONG":
            content.side = "LONG";
            break;
          case "SHORT":
            content.side = "SHORT";
            break;
          default:
            throw new Error("Must be provide a valid side. Long or Short");
        }
      }
      if (content && typeof content.type === "string") {
        switch (content.type.toUpperCase()) {
          case "MARKET":
            content.type = "MARKET";
            break;
          case "LIMIT":
            content.type = "LIMIT";
            break;
          default:
            throw new Error("Invalid type");
        }
      }
      if (content && typeof content.limitOrderPrice === "string") {
        content.limitOrderPrice = content.limitOrderPrice === "null" ? null : Number.parseFloat(content.limitOrderPrice);
      }

      const parseResult = OpenOrderSchema.safeParse(content);
      if (!parseResult.success) {
        throw new Error(
          `Invalid open order content:\n${JSON.stringify(content, null, 2)}\n${JSON.stringify(parseResult.error.errors, null, 2)}`
        );
      }

      const merkleService = await newMerkleService(runtime)

      let tx: PendingTransactionResponse | CommittedTransactionResponse;
      if (content && typeof content.type === "string" && content.type === "LIMIT") {
        tx = await merkleService.placeLimitOrder({
          pair: content.coinSymbol,
          pay: content.pay,
          leverage: content.leverage,
          isLong: content.side === "LONG",
          limitOrderPrice: content.limitOrderPrice,
        })
        if (callback) {
          callback({
            text: `Successfully limit order ${content.coinSymbol} at ${content.limitOrderPrice} with ${content.pay} pay, ${content.leverage} leverage, and ${content.side} position, Transaction: ${tx.hash}`,
            content: tx,
          });
        }
      } else {
        tx = await merkleService.placeMarketOrder({
          pair: content.coinSymbol,
          pay: content.pay,
          leverage: content.leverage,
          isLong: content.side === "LONG",
        })

        if (callback) {
          callback({
            text: `Successfully market order ${content.coinSymbol} with ${content.pay} pay, ${content.leverage} leverage, and ${content.side} position, Transaction: ${tx.hash}`,
            content: tx,
          });
        }
      }

      elizaLogger.log("Open order successful:", tx.hash);
      return true;
    } catch (error) {
      elizaLogger.error("Error during open order:", {
        content,
        message: error.message,
      });
      if (callback) {
        callback({
          text: `Error during open order: ${error.message}`,
          content: { error: error.message },
        });
      }
      return false;
    }
	},
} as Action;

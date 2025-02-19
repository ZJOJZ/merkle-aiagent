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
import { GetPriceSchema } from "../types";
import { checkEnv, newMerkleService } from "../utils";

const getPriceTemplate = `Respond with a JSON markdown block containing only the extracted values. Use null for any values that cannot be determined.

Example response:
\`\`\`json
{
    "coinSymbol": "BTC"
}
\`\`\`

{{recentMessages}}

Given the recent messages, extract the following information about the requested futures position order:
- coinSymbol : Coin symbol (Must be a valid coin symbol, Must be provided by the user)

Respond with a JSON markdown block containing only the extracted values.`;

export default {
	name: "GET_PRICE",
	similes: ["PRICE"],
	description: "Get the price of the coin on the Merkle Trade platform",
	examples: [
    [
      {
        user: "{{user}}",
        content: {
          text: "What is the price of BTC?",
        },
      },
      {
        user: "{{agent}}",
        content: {
          text: "The price of BTC is 98000",
          action: "GET_PRICE",
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
        template: getPriceTemplate,
      });

      content = await generateObjectDeprecated({
        runtime,
        context: context,
        modelClass: ModelClass.SMALL,
      });

      const parseResult = GetPriceSchema.safeParse(content);
      if (!parseResult.success) {
        throw new Error(
          `Invalid get price content:\n${JSON.stringify(content, null, 2)}\n${JSON.stringify(parseResult.error.errors, null, 2)}`
        );
      }

      const merkleService = await newMerkleService(runtime)
      const summary = await merkleService.getSummary()
      if (!summary) {
        throw new Error("Summary not found")
      }

      const price = summary.prices.find(price => price.id.includes(content.coinSymbol))
      if (!price) {
        throw new Error("Price not found")
      }

      if (callback) {
        callback({
          text: `The price of ${content.coinSymbol} is ${price.price}`,
          content: price,
        });
      }
      elizaLogger.info("Successfully get price");
      return true;
    } catch (error) {
      elizaLogger.error("Error during get price:", {
        message: error.message,
      });
      if (callback) {
        callback({
          text: `Error during get price: ${error.message}`,
          content: { error: error.message },
        });
      }
      return false;
    }
	},
} as Action;

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
import { FullyClosePositionSchema } from "../types";
import { checkEnv, newMerkleService } from "../utils";

const fullyCloseOrderTemplate = `Respond with a JSON markdown block containing only the extracted values. Use null for any values that cannot be determined.

Example response:
\`\`\`json
{
    "coinSymbol": "BTC",
    "side": "LONG",
}
\`\`\`

{{recentMessages}}

Given the recent messages, extract the following information about the requested futures position order:
- coinSymbol : Coin symbol (Must be a valid coin symbol, Must be provided by the user)
- side : Side of the position (Must be "LONG" or "SHORT", Must be provided by the user)

Respond with a JSON markdown block containing only the extracted values.`;

export default {
  name: "FULLY_CLOSE_POSITION",
  similes: ["CLOSE_POSITION"],
  description: "Fully close all positions on the Merkle Trade platform",
  examples: [
    [
      {
        user: "{{user}}",
        content: {
          text: "Close BTC Long position on the Merkle Trade platform",
        },
      },
      {
        user: "{{agent}}",
        content: {
          text: "Successfully close position BTC with LONG position, Transaction: 0x104af5d1a786a2e1a4721a721b2cfccc7e15fa41eec15a489ba1768790adb523",
          action: "FULLY_CLOSE_POSITION",
        },
      }
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
        template: fullyCloseOrderTemplate,
      });

      content = await generateObjectDeprecated({
        runtime,
        context: context,
        modelClass: ModelClass.LARGE,
      });

      if (content && typeof content.side === "string") {
        switch (content.side.toUpperCase()) {
          case "LONG":
            content.side = "LONG";
            break;
          case "SHORT":
            content.side = "SHORT";
            break;
          default:
            throw new Error("Invalid side");
        }
      }

      const parseResult = FullyClosePositionSchema.safeParse(content);
      if (!parseResult.success) {
        throw new Error(
          `Invalid open order content: ${JSON.stringify(parseResult.error.errors, null, 2)}`
        );
      }
      const { coinSymbol, side } = parseResult.data

      const merkleService = await newMerkleService(runtime)

      const positions = await merkleService.getPositions()
      const position = positions.find(p => p.pairType.split("::")[2].includes(coinSymbol.toUpperCase()) && p.isLong === (side === "LONG"))
      if (!position) {
        throw new Error(`Position not found for ${coinSymbol} with ${side} position`)
      }
      const tx = await merkleService.closePosition(position)
      if (callback) {
        callback({
          text: `Successfully close position ${coinSymbol} with ${side} position, Transaction: ${tx.hash}`,
          content: tx,
        });
      }
      elizaLogger.info("Successfully close position", tx.hash);

      return true
    } catch (error) {
      elizaLogger.error("Error during fully close position:", {
        content,
        message: error.message,
      });
      if (callback) {
        callback({
          text: `Error during fully close position: ${error.message}`,
          content: { error: error.message },
        });
      }
      return false
    }
  },
} as Action;

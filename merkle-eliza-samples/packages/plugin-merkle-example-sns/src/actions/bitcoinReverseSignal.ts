import { elizaLogger, generateObjectDeprecated, getEmbeddingZeroVector, stringToUuid } from "@elizaos/core";
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
import { z } from "zod";

const bitCoinTemplate = `Respond with a JSON markdown block containing only the extracted values.

Example response:
\`\`\`json
{
    "side": "LONG"
}
\`\`\`

{{recentMessages}}

Given the recent messages, extract the following information about bitcoin:
- side : Side of the position (Must be "LONG" if the message suggests Bitcoin price will decrease, "SHORT" if the message suggests Bitcoin price will increase. 
  If the message is unclear but contains a directional sentiment about Bitcoin, infer the most likely side based on context. 
  If the message does not mention Bitcoin or gives no clear indication of direction, return "NONE").

Respond with a JSON markdown block containing only the extracted values.`;
;

const bitcoinReverseSignalSchema = z.object({
	side: z.enum(["LONG", "SHORT", "NONE"]),
});

export default {
	name: "BITCOIN_REVERSE_SIGNAL",
	similes: [],
	description: "Analyzes conversations about Bitcoin to leverage market sentiment in a contrarian manner. When a positive signal is detected, it takes a Short position, and when a negative signal is detected, it takes a Long position. This strategy aims to capitalize on the market's overreactions.",
	examples: [
		[
			{
				user: "{{user}}",
				content: {
					text: "Bitcoin is going to the moon",
				},
			},
			{
				user: "{{agent}}",
				content: {
					text: "Bitcoin must be down, because you said it's going to the moon",
					action: "BITCOIN_REVERSE_SIGNAL",
          side: "SHORT",
				},
			},
		],
    [
			{
				user: "{{user}}",
				content: {
					text: "Bitcoin's spot market is seeing increased buying pressure, suggesting a potential for continued price appreciation.",
				},
			},
      {
        user: "{{agent}}",
        content: {
          text: "Bitcoin must be down, because you said it's seeing increased buying pressure",
					action: "BITCOIN_REVERSE_SIGNAL",
          side: "SHORT",
        },
      },
    ],
    [
      {
        user: "{{user}}",
        content: {
          text: "Major financial experts predict Bitcoin could reach up to $700,000 by 2025."
        },
      },
			{
				user: "{{agent}}",
				content: {
					text: "Bitcoin must be down, because you said it could reach up to $700,000 by 2025",
					action: "BITCOIN_REVERSE_SIGNAL",
          side: "SHORT",
				},
			},
		],
    [
      {
        user: "{{user}}",
        content: {
          text: "Bitcoin showing bearish signals as we enter the mid-week trading session. Our AI sees a potential -1.13% move with moderate risk (4/10)."
        },
      },
			{
				user: "{{agent}}",
				content: {
					text: "Bitcoin must be up, because you said it's showing bearish signals",
					action: "BITCOIN_REVERSE_SIGNAL",
          side: "LONG",
				},
			},
		],
    [
      {
        user: "{{user}}",
        content: {
          text: "Bitcoin struggles to gain momentum, trading between $95,850 and $96,234 with bearish pressure lingering. Will key support hold?",
        },
      },
			{
				user: "{{agent}}",
				content: {
					text: "Bitcoin must be up, because you said it's showing bearish signals",
					action: "BITCOIN_REVERSE_SIGNAL",
          side: "LONG",
				},
			},
		],
    [
      {
        user: "{{user}}",
        content: {
          text: "Bitcoin showing bearish signals with -5.13% drop in 24h! Short opportunity spotted at $93,057 with 4x leverage. Risk level: Moderate (20%)."
        },
      },
			{
				user: "{{agent}}",
				content: {
					text: "Bitcoin must be up, because you said it's showing bearish signals",
					action: "BITCOIN_REVERSE_SIGNAL",
          side: "LONG",
				},
			},
		],
    [
      {
        user: "{{user}}",
        content: {
          text: "What is the price of Bitcoin?"
        },
      },
			{
				user: "{{agent}}",
				content: {
					text: "Bitcoin is $100,000",
					action: "BITCOIN_REVERSE_SIGNAL",
          side: "NONE",
				},
			},
		],
	] as ActionExample[][],
	validate: async (_runtime: IAgentRuntime) => {
		return true;
	},
	handler: async (
		runtime: IAgentRuntime,
		memory: Memory,
		state: State,
		_options: { [key: string]: unknown },
		callback?: HandlerCallback,
	): Promise<boolean> => {
    // biome-ignore lint/suspicious/noExplicitAny: <explanation>
    let content: any;
    try {
      let currentState = state;
      if (!currentState) {
        currentState = (await runtime.composeState(memory)) as State;
      } else {
        currentState = await runtime.updateRecentMessageState(currentState);
      }

      const context = composeContext({
        state: currentState,
        template: bitCoinTemplate,
      });

      content = await generateObjectDeprecated({
        runtime,
        context: context,
        modelClass: ModelClass.SMALL,
      });

      if (content && typeof content.side === "string") {
        switch (content.side.toUpperCase()) {
          case "LONG":
            content.side = "LONG";
            break;
          case "SHORT":
            content.side = "SHORT";
            break;
          case "NONE":
            content.side = "NONE";
            break;
          default:
            throw new Error("Must be provide a valid side. Long or Short or None");
        }
      }

      const parseResult = bitcoinReverseSignalSchema.safeParse(content);
      if (!parseResult.success) {
        throw new Error(
          `Invalid content:\n${JSON.stringify(content, null, 2)}\n${JSON.stringify(parseResult.error.errors, null, 2)}`
        );
      }

      const side = parseResult.data.side;
      if (side === "NONE") {
        return true;
      }
      const orderMemory: Memory = {
        id: stringToUuid(`${memory.id}-${runtime.agentId}`),
        userId: memory.userId,
        agentId: memory.agentId,
        content: {
          text: `Open BTC ${side} Position, with 20x leverage, 20$ pay`,
          action: "OPEN_ORDER",
        },
        roomId: memory.roomId,
        embedding: getEmbeddingZeroVector(),
        createdAt: new Date().getTime(),
      }
      await runtime.messageManager.createMemory(orderMemory);

      await runtime.processActions(orderMemory, [orderMemory], state, callback);
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
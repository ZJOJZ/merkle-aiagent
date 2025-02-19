import { elizaLogger } from "@elizaos/core";
import type {
	ActionExample,
	HandlerCallback,
	IAgentRuntime,
	Memory,
	State,
	Action,
} from "@elizaos/core";
import { checkEnv, newMerkleService } from "../utils";
import { toNumber } from "@merkletrade/ts-sdk";

export default {
  name: "GET_BALANCE",
  similes: ["BALANCE"],
  description: "Get the balance of the user on the Merkle Trade platform",
  examples: [
    [
      {
        user: "{{user}}",
        content: {
          text: "What is my balance?",
        },
      },
      {
        user: "{{agent}}",
        content: {
          text: "Balance:\nUSDC\t|\t1000000",
          action: "GET_BALANCE",
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
    try {
      let currentState = state;
      if (!currentState) {
        currentState = (await runtime.composeState(message)) as State;
      } else {
        currentState = await runtime.updateRecentMessageState(currentState);
      }

      const merkleService = await newMerkleService(runtime)

      const balance = await merkleService.getBalance()
      if (!balance) {
        throw new Error("Balance not found")
      }
      const usdc = toNumber(balance.usdc, 6)
      if (callback) {
        callback({ text: `Balance:\nUSDC\t|\t${usdc}` });
      }
      elizaLogger.info("Successfully get balance");
      return true
    } catch (error) {
      elizaLogger.error("Error during get balance:", {
        message: error.message,
      });
      if (callback) {
        callback({
          text: `Error during get balance: ${error.message}`,
          content: { error: error.message },
        });
      }
      return false
    }
  },
} as Action;

import { elizaLogger } from "@elizaos/core";
import type{
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
  name: "GET_ORDER",
  similes: ["ORDER"],
  description: "Get the order of the user on the Merkle Trade platform",
  examples: [
    [
      {
        user: "{{user}}",
        content: {
          text: "Get the order of the user on the Merkle Trade platform",
        },
      },
      {
        user: "{{agent}}",
        content: {
          text: "Orders\n----------------------------\nETH (Long, increase) order: 9940.36$ at 2600$\nBTC (Long, increase) order: 970.87$ at 80000$",
          action: "GET_ORDER",
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

      const orders = await merkleService.getOrders()
      if (!orders) {
        throw new Error("Orders not found")
      }

      const tableData = orders.map(order => [
        order.pairType.split("::")[2].split("_")[0],
        order.isLong ? "Long" : "Short",
        order.isIncrease ? "Increase" : "Decrease",
        toNumber(order.sizeDelta, 6).toFixed(2),
        toNumber(order.price, 10),
      ])

      const logs = tableData.map(row => {
        const [pair, side, type, size, price] = row
        return `${pair} (${side}, ${String(type).toLowerCase()}) order: ${size}$ at ${price}$`
      })

      if (callback) {
        callback({ text: `Orders\n----------------------------\n${logs.join("\n")}` });
      }
      elizaLogger.info("Successfully get orders");
      return true
    } catch (error) {
      elizaLogger.error("Error during get orders:", { message: error.message });
      if (callback) {
        callback({ text: `Error during get orders: ${error.message}` });
      }
      return false
    }
  },
} as Action;

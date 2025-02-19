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
import { calcPnlWithoutFee, dec, div, fromNumber, toNumber } from "@merkletrade/ts-sdk";

export default {
  name: "GET_POSITION",
  similes: ["POSITION"],
  description: "Get the position of the user on the Merkle Trade platform",
  examples: [
    [
      {
        user: "{{user}}",
        content: {
          text: "Get the position of the user on the Merkle Trade platform",
        },
      },
      {
        user: "{{agent}}",
        content: {
          text: "Positions\n----------------------------\nETH (50x Long)\nAvg Price: 2783.714542352$\nCollateral: 19.417476$\nPnL: -37.36% (-7.26$)",
          action: "GET_POSITION",
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

      const positions = await merkleService.getPositions()
      if (!positions) {
        throw new Error("Positions not found")
      }

      const summary = await merkleService.getSummary()
      if (!summary) {
        throw new Error("Summary not found")
      }

      const logs = [
        "Positions",
        ...positions.map(position => {
        const pair = position.pairType.split("::")[2].split("_")[0]
        const side = position.isLong ? "Long" : "Short"
        const collateral = toNumber(position.collateral, 6)
        const leverage = Math.round(toNumber(position.size, 6) / collateral)
        const currentPrice = fromNumber(summary.prices.find(price => price.id.includes(pair))?.price, 10)
        const avgPrice = toNumber(position.avgPrice, 10).toFixed(2)
        const pnl = toNumber(calcPnlWithoutFee({
          position: position,
          executePrice: currentPrice,
          decreaseOrder: { sizeDelta: position.size}
        }), 6)
        const pnlRate = ((pnl / collateral) * 100).toFixed(2)
        return `${pair} (${leverage}x ${side})\nAvg Price: ${avgPrice}$\nCollateral: ${collateral.toFixed(2)}$\nPnL: ${pnlRate}% (${pnl.toFixed(2)}$)`
      })
      ].join("\n----------------------------\n")

      if (callback) {
        callback({ text: logs });
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

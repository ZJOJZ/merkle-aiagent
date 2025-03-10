import type { AccountAddress } from "@aptos-labs/ts-sdk"
import type { AgentRuntime } from "../../agent"
import { removeLastInterestRateIndex } from "../../utils/clean-joule-all-positions-list"

/**
 * Get details about a user's all positions
 * @param agent MoveAgentKit instance
 * @param userAddress The address of the user
 * @returns List of user positions
 */
export async function getUserAllPositions(agent: AgentRuntime, userAddress: AccountAddress | string): Promise<any> {
	try {
		const transaction = await agent.aptos.view({
			payload: {
				function: "0xddb87c0d0ce27cf4a205c2f5e65d6897936d468df8d1611c50b4eb72ed4c9468::pool::user_positions_map",
				functionArguments: [userAddress.toString()],
			},
		})

		if (!transaction) {
			throw new Error("Failed to fetch user all positions")
		}

		// TODO : make the amounts human readable // sync with shivam for all view function

		const cleanedTransaction = removeLastInterestRateIndex(transaction)

		return cleanedTransaction
	} catch (error: any) {
		throw new Error(`Failed to get user all positions: ${error.message}`)
	}
}

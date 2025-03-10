import type { AccountAddress } from "@aptos-labs/ts-sdk"
import type { AgentRuntime } from "../../agent"

/**
 * Get details about a user's position
 * @param agent MoveAgentKit instance
 * @param userAddress The address of the user
 * @param positionId The ID of the position to query
 * @returns Position details
 * @example
 * ```ts
 * const positionDetails = await getUserPosition(agent, userAddress, positionId);
 * ```
 */
export async function getUserPosition(
	agent: AgentRuntime,
	userAddress: AccountAddress | string,
	positionId: string
): Promise<any> {
	try {
		const transaction = await agent.aptos.view({
			payload: {
				function: "0xddb87c0d0ce27cf4a205c2f5e65d6897936d468df8d1611c50b4eb72ed4c9468::pool::user_position_details",
				functionArguments: [userAddress.toString(), positionId],
			},
		})

		if (!transaction) {
			throw new Error("Failed to fetch user position")
		}

		return transaction
	} catch (error: any) {
		throw new Error(`Failed to get user position: ${error.message}`)
	}
}

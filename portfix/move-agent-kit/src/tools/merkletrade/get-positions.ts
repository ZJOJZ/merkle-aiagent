import { MerkleClient, MerkleClientConfig, toNumber } from "@merkletrade/ts-sdk"
import type { AgentRuntime } from "../../agent"

/**
 * Get positions from MerkleTrade
 * @param agent MoveAgentKit instance
 * @returns Positions
 */
export async function getPositionsWithMerkleTrade(agent: AgentRuntime) {
	try {
		const merkle = new MerkleClient(await MerkleClientConfig.mainnet())

		const positions = await merkle.getPositions({
			address: agent.account.getAddress().toString(),
		})

		const humanReadablePositions = positions.map((position) => ({
			...position,
			size: toNumber(position.size, 6),
			collateral: toNumber(position.collateral, 6),
			avgPrice: toNumber(position.avgPrice, 10),
			stopLossTriggerPrice: toNumber(position.stopLossTriggerPrice, 10),
			takeProfitTriggerPrice: toNumber(position.takeProfitTriggerPrice, 10),
		}))

		return humanReadablePositions
	} catch (error: any) {
		throw new Error(`Get positions failed: ${error.message}`)
	}
}

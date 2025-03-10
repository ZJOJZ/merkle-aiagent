import type { TransactionResponse } from "@aptos-labs/ts-sdk"
import type { AgentRuntime } from "../../agent"

/**
 * Fetches transaction from aptos
 * @param agent MoveAgentKit instance
 * @param hash Transaction Hash
 * @returns Transaction signature
 * @example
 * ```ts
 * const transaction = await getTransaction(agent, "HASH")
 * ```
 */
export async function getTransaction(agent: AgentRuntime, hash: string): Promise<TransactionResponse> {
	try {
		const transaction = await agent.aptos.getTransactionByHash({
			transactionHash: hash,
		})

		return transaction
	} catch (error: any) {
		throw new Error(`Token transfer failed: ${error.message}`)
	}
}

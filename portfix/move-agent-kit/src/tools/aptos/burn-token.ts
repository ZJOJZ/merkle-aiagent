import type { AgentRuntime } from "../../agent"

/**
 * Burn fungible asset token
 * @param agent MoveAgentKit instance
 * @param amount Amount to burn
 * @param mint Fungible asset address to burn
 * @returns Transaction signature
 */
export async function burnToken(agent: AgentRuntime, amount: number, mint: string): Promise<string> {
	try {
		const transaction = await agent.aptos.transaction.build.simple({
			sender: agent.account.getAddress(),
			data: {
				function: "0x67c8564aee3799e9ac669553fdef3a3828d4626f24786b6a5642152fa09469dd::launchpad::burn_fa",
				functionArguments: [mint, amount],
			},
		})

		const committedTransactionHash = await agent.account.sendTransaction(transaction)

		const signedTransaction = await agent.aptos.waitForTransaction({
			transactionHash: committedTransactionHash,
		})

		if (!signedTransaction.success) {
			console.error(signedTransaction, "Token burn failed")
			throw new Error("Token burn failed")
		}

		return signedTransaction.hash
	} catch (error: any) {
		throw new Error(`Token burn failed: ${error.message}`)
	}
}

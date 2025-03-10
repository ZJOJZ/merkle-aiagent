import type { MoveStructId } from "@aptos-labs/ts-sdk"
import type { AgentRuntime } from "../../agent"

/**
 * Claim rewards from Joule pool
 * @param agent MoveAgentKit instance
 * @param rewardCoinType The coin type of the reward
 * @returns Transaction signature
 */
export async function claimReward(agent: AgentRuntime, rewardCoinType: MoveStructId | string): Promise<string> {
	try {
		const coinReward = `${rewardCoinType}1111`.replace("0x", "@")

		const isCoinTypeSTApt =
			rewardCoinType === "0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::stapt_token::StakedApt"

		console.log({
			sender: agent.account.getAddress(),
			data: {
				function: "0xddb87c0d0ce27cf4a205c2f5e65d6897936d468df8d1611c50b4eb72ed4c9468::pool::claim_rewards",
				typeArguments: [
					isCoinTypeSTApt
						? "0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::amapt_token::AmnisApt"
						: "0x1::aptos_coin::AptosCoin",
				],
				functionArguments: [coinReward, isCoinTypeSTApt ? "amAPTIncentives" : "APTIncentives"],
			},
		})
		const transaction = await agent.aptos.transaction.build.simple({
			sender: agent.account.getAddress(),
			data: {
				function: "0xddb87c0d0ce27cf4a205c2f5e65d6897936d468df8d1611c50b4eb72ed4c9468::pool::claim_rewards",
				typeArguments: [
					isCoinTypeSTApt
						? "0x111ae3e5bc816a5e63c2da97d0aa3886519e0cd5e4b046659fa35796bd11542a::amapt_token::AmnisApt"
						: "0x1::aptos_coin::AptosCoin",
				],
				functionArguments: [coinReward, isCoinTypeSTApt ? "amAPTIncentives" : "APTIncentives"],
			},
		})

		const committedTransactionHash = await agent.account.sendTransaction(transaction)

		const signedTransaction = await agent.aptos.waitForTransaction({
			transactionHash: committedTransactionHash,
		})

		if (!signedTransaction.success) {
			console.error(signedTransaction, "Claim rewards failed")
			throw new Error("Claim rewards failed")
		}

		return signedTransaction.hash
	} catch (error: any) {
		throw new Error(`Claim rewards failed: ${error.message}`)
	}
}

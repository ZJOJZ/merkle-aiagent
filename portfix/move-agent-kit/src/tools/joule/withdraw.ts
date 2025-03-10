import { AccountAddress, type InputGenerateTransactionPayloadData, type MoveStructId } from "@aptos-labs/ts-sdk"
import type { AgentRuntime } from "../../agent"

/**
 * Withdraw APT, tokens or fungible asset from a position
 * @param agent MoveAgentKit instance
 * @param amount Amount to mint
 * @param mint The Move struct ID of the token to withdraw
 * @param positionId The position ID to withdraw from
 * @param fungibleAssetAddress The address of the fungible asset if the token is fungible (optional)
 * @returns Transaction signature and position ID
 * @example
 * ```ts
 * const transactionHash = await withdrawToken(agent, amount, APTOS_COIN, positionId); // For APT
 * const otherTransactionHash = await withdrawToken(agent, amount, OTHER_TOKEN, positionId); // For another token
 * const fungibleAssetTransactionHash = await withdrawToken(agent, amount, APTOS_COIN, positionId, fungibleAssetAddress); // For fungible asset
 */
export async function withdrawToken(
	agent: AgentRuntime,
	amount: number,
	mint: MoveStructId,
	positionId: string,
	fungibleAsset: boolean
): Promise<{
	hash: string
	positionId: string
}> {
	const pyth_update_data = await agent.getPythData()
	console.log(pyth_update_data)
	const DEFAULT_FUNCTIONAL_ARGS = [positionId, amount, pyth_update_data]

	const COIN_STANDARD_DATA: InputGenerateTransactionPayloadData = {
		function: "0xddb87c0d0ce27cf4a205c2f5e65d6897936d468df8d1611c50b4eb72ed4c9468::pool::withdraw",
		typeArguments: [mint.toString()],
		functionArguments: DEFAULT_FUNCTIONAL_ARGS,
	}

	const FUNGIBLE_ASSET_DATA: InputGenerateTransactionPayloadData = {
		function: "0xddb87c0d0ce27cf4a205c2f5e65d6897936d468df8d1611c50b4eb72ed4c9468::pool::withdraw_fa",
		functionArguments: [positionId, mint.toString(), amount, pyth_update_data],
	}

	try {
		const transaction = await agent.aptos.transaction.build.simple({
			sender: agent.account.getAddress(),
			data: fungibleAsset ? FUNGIBLE_ASSET_DATA : COIN_STANDARD_DATA,
		})

		const committedTransactionHash = await agent.account.sendTransaction(transaction)

		const signedTransaction = await agent.aptos.waitForTransaction({
			transactionHash: committedTransactionHash,
		})

		if (!signedTransaction.success) {
			console.error(signedTransaction, "Token withdraw failed")
			throw new Error("Token withdraw failed")
		}

		return {
			hash: signedTransaction.hash,
			positionId,
		}
	} catch (error: any) {
		throw new Error(`Token withdraw failed: ${error.message}`)
	}
}

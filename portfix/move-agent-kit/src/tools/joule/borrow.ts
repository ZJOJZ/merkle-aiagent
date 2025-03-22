import { AccountAddress, type InputGenerateTransactionPayloadData, type MoveStructId } from "@aptos-labs/ts-sdk"
import type { AgentRuntime } from "../../agent"
import type { InputTransactionData } from "@aptos-labs/wallet-adapter-react"

/**
 * Borrow APT, tokens or fungible asset from a position
 * @param agent MoveAgentKit instance
 * @param amount Amount to mint
 * @param mint The Move struct ID of the token to borrow
 * @param positionId The position ID to borrow from
 * @param fungibleAsset boolean value for fungible asset
 * @returns Transaction signature and position ID
 * @example
 * ```ts
 * const transactionHash = await borrowToken(agent, amount, APTOS_COIN, positionId); // For APT
 * const otherTransactionHash = await borrowToken(agent, amount, OTHER_TOKEN, positionId); // For another token
 * const fungibleAssetTransactionHash = await borrowToken(agent, amount, APTOS_COIN, positionId, fungibleAssetAddress); // For fungible asset
 */
export async function borrowToken(
	agent: AgentRuntime,
	amount: number,
	mint: MoveStructId | string,
	positionId: string,
	fungibleAsset: boolean
): Promise<{
	hash: string
	positionId: string
}> {
	const pyth_update_data = await agent.getPythData()
	console.log(pyth_update_data)
	console.log(mint.toString())
	const DEFAULT_FUNCTIONAL_ARGS = [positionId, amount, pyth_update_data]

	const COIN_STANDARD_DATA: InputGenerateTransactionPayloadData = {
		function: "0x2fe576faa841347a9b1b32c869685deb75a15e3f62dfe37cbd6d52cc403a16f6::pool::borrow",
		typeArguments: [mint.toString()],
		functionArguments: DEFAULT_FUNCTIONAL_ARGS,
	}

	const FUNGIBLE_ASSET_DATA: InputGenerateTransactionPayloadData = {
		function: "0x2fe576faa841347a9b1b32c869685deb75a15e3f62dfe37cbd6d52cc403a16f6::pool::borrow_fa",
		functionArguments: [positionId, mint.toString(), amount, pyth_update_data],
	}

	try {
		// const transaction = await agent.aptos.transaction.build.simple({
		// 	sender: agent.account.getAddress(),
		// 	data: fungibleAsset ? FUNGIBLE_ASSET_DATA : COIN_STANDARD_DATA,
		// })

		// const committedTransactionHash = await agent.account.sendTransaction(transaction)

		// const signedTransaction = await agent.aptos.waitForTransaction({
		// 	transactionHash: committedTransactionHash,
		// })
		const transaction : InputTransactionData = {
				data:{
					function: fungibleAsset ? FUNGIBLE_ASSET_DATA.function : COIN_STANDARD_DATA.function,
					functionArguments: fungibleAsset ? FUNGIBLE_ASSET_DATA.functionArguments : COIN_STANDARD_DATA.functionArguments,
					typeArguments: fungibleAsset ? FUNGIBLE_ASSET_DATA.typeArguments : COIN_STANDARD_DATA.typeArguments
				}
			}
						
		const committedTransactionHash = await agent.account.sendTransaction(transaction)
		const signedTransaction = await agent.aptos.waitForTransaction({
			transactionHash: committedTransactionHash,
		})

		if (!signedTransaction.success) {
			console.error(signedTransaction, "Token borrow failed")
			throw new Error("Token borrow failed")
		}

		return {
			hash: signedTransaction.hash,
			positionId,
		}
	} catch (error: any) {
		throw new Error(`Token borrow failed: ${error.message}`)
	}
}

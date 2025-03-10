import { Tool } from "langchain/tools"
import { type AgentRuntime, parseJson } from "../.."

export class AptosTransactionTool extends Tool {
	name = "aptos_get_transaction"
	description = `Fetches a transaction from aptos blockchain

  Inputs ( input is a JSON string ):
  transactionHash: string, eg "0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa" (required)`

	constructor(private agent: AgentRuntime) {
		super()
	}

	protected async _call(input: string): Promise<string> {
		try {
			const parsedInput = parseJson(input)

			const aptosTransaction = await this.agent.getTransaction(parsedInput.transactionHash)

			return JSON.stringify({
				status: "success",
				aptosTransaction,
			})
		} catch (error: any) {
			return JSON.stringify({
				status: "error",
				message: error.message,
				code: error.code || "UNKNOWN_ERROR",
			})
		}
	}
}

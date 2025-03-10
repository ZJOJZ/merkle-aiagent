import { Tool } from "langchain/tools"
import { type AgentRuntime, parseJson } from "../.."

export class AptosGetTokenDetailTool extends Tool {
	name = "aptos_token_details"
	description = `Get the detail of any aptos tokens

  details also include decimals which you can use to make onchain values readable to a human user

  Inputs ( input is a JSON string ):
  token: string, eg "0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa::asset::USDT" (optional)`

	constructor(private agent: AgentRuntime) {
		super()
	}

	protected async _call(input: string): Promise<string> {
		try {
			const parsedInput = parseJson(input)
			const mint = parsedInput.token || ""

			const tokenData = await this.agent.getTokenDetails(mint)

			return JSON.stringify({
				status: "success",
				tokenData,
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

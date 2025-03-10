import { Tool } from "langchain/tools"
import { type AgentRuntime, parseJson } from "../.."

export class JouleGetPoolDetails extends Tool {
	name = "joule_get_pool_details"
	description = `the tool can be used to get a token / fungible asset pool details

  Inputs ( input is a JSON string ):
     mint: string, eg "0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa::asset::USDT" (required)

  Example: '{"mint": "0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa::asset::USDT"}'
  `

	constructor(private agent: AgentRuntime) {
		super()
	}

	protected async _call(input: string): Promise<string> {
		try {
			const parsedInput = parseJson(input)

			const pool = await this.agent.getPoolDetails(parsedInput.mint)

			return JSON.stringify({
				status: "success",
				pool,
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

import { Tool } from "langchain/tools"
import type { AgentRuntime } from "../.."

export class AriesCreateProfileTool extends Tool {
	name = "aries_create_profile"
	description = `this tool can be used to create a profile in Aries
    `

	constructor(private agent: AgentRuntime) {
		super()
	}

	protected async _call(): Promise<string> {
		try {
			const createProfileTransactionHash = await this.agent.createAriesProfile()

			return JSON.stringify({
				status: "success",
				createProfileTransactionHash,
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

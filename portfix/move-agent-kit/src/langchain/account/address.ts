import { Tool } from "langchain/tools"
import type { AgentRuntime } from "../.."

export class AptosAccountAddressTool extends Tool {
	name = "aptos_get_wallet_address"
	description = "Get the wallet address of the agent"

	constructor(private agent: AgentRuntime) {
		super()
	}

	async _call(_input: string): Promise<string> {
		return this.agent.account.getAddress().toString()
	}
}

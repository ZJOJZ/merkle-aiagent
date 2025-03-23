import { Tool } from "langchain/tools"
import { type AgentRuntime, parseJson } from "../.."

export class AptosBurnNFTTool extends Tool {
	name = "aptos_burn_nft"
	description = `this tool can be used to burn any NFT on aptos

  Inputs ( input is a JSON string ):
  mint: string, eg "0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa::asset::USDT" (required)`

	constructor(private agent: AgentRuntime) {
		super()
	}

	protected async _call(input: string): Promise<string> {
		try {
			const parsedInput = parseJson(input)

			const transfer = await this.agent.burnNFT(parsedInput.mint)

			return JSON.stringify({
				status: "success",
				transfer,
				nft: parsedInput.mint,
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

import { Tool } from "langchain/tools"
import { type AgentRuntime, parseJson } from "../.."

export class AptosCreateTokenTool extends Tool {
	name = "aptos_create_token"
	description = `this tool can be used to create fungible asset to a recipient

  Inputs ( input is a JSON string ):
  name: string, eg "USDT" (required)
  symbol: string, eg "USDT" (required)
  iconURI: string, eg "https://example.com/icon.png" (required)
  projectURI: string, eg "https://example.com/project" (required)
  `

	constructor(private agent: AgentRuntime) {
		super()
	}

	protected async _call(input: string): Promise<string> {
		try {
			const parsedInput = parseJson(input)

			const createTokenTransactionHash = await this.agent.createToken(
				parsedInput.name,
				parsedInput.symbol,
				parsedInput.iconURI,
				parsedInput.projectURI
			)

			return JSON.stringify({
				status: "success",
				createTokenTransactionHash,
				token: {
					name: parsedInput.name,
					decimals: 8,
				},
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

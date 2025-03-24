import { Tool } from "langchain/tools"
import { type AgentRuntime, parseJson } from "../.."

export class PanoraSwapTool extends Tool {
	name = "panora_aggregator_swap"
	description = `this tool can be used to swap tokens in panora - liquidity aggregator on aptos

	if you want to swap APT and one of the token, fromToken will be "0x1::aptos_coin::AptosCoin"

	Inputs ( input is a JSON string ):
	fromToken: string, eg "0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa::asset::USDT" (required)
	toToken: string, eg "0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa::asset::USDT" (required)
	swapAmount: number, eg 1 or 0.01 (required)
	toWalletAddress: string, eg "0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa" (optional)
	`

	constructor(private agent: AgentRuntime) {
		super()
	}

	protected async _call(input: string): Promise<string> {
		try {
			const parsedInput = parseJson(input)

			const mintXDetail = await this.agent.getTokenDetails(parsedInput.fromToken)

			const mintYDetail = await this.agent.getTokenDetails(parsedInput.toToken)

			const swapTransactionHash = await this.agent.swapWithPanora(
				parsedInput.fromToken,
				parsedInput.toToken,
				parsedInput.swapAmount,
				parsedInput.toWalletAddress
			)

			return JSON.stringify({
				status: "success",
				swapTransactionHash,
				token: [
					{
						mintX: mintXDetail.name,
						decimals: mintXDetail.decimals,
					},
					{
						mintY: mintYDetail.name,
						decimals: mintYDetail.decimals,
					},
				],
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

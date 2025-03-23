import { Tool } from "langchain/tools"
import { type AgentRuntime, parseJson } from "../.."

export class OpenAICreateImageTool extends Tool {
	name = "openai_create_image"
	description = `
    Generate an image using OpenAI's DALL-E

    Inputs ( input is a JSON string ):
    prompt: string, Text description of the image to generate (required)
    size: string, Image size ('256x256', '512x512', or '1024x1024') (default: '1024x1024')
    n: number, Number of images to generate (default: 1)`

	constructor(private agent: AgentRuntime) {
		super()
	}

	protected async _call(input: string): Promise<string> {
		try {
			const parsedInput = parseJson(input)

			const response = await this.agent.createImageWithOpenAI(parsedInput.prompt, parsedInput.size, parsedInput.n)

			return JSON.stringify({
				status: "success",
				response,
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

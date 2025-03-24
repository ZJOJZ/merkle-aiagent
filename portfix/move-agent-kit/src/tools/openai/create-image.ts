import OpenAI from "openai"
import type { AgentRuntime } from "../../agent"

/**
 * Generate an image using OpenAI's DALL-E
 * @param agent MoveAgentKit instance
 * @param prompt Text description of the image to generate
 * @param size Image size ('256x256', '512x512', or '1024x1024') (default: '1024x1024')
 * @param n Number of images to generate (default: 1)
 * @returns Object containing the generated image URLs
 */
export async function createImage(
	agent: AgentRuntime,
	prompt: string,
	size: "256x256" | "512x512" | "1024x1024" = "1024x1024",
	n = 1
) {
	try {
		const apiKey = agent.config.OPENAI_API_KEY
		if (!apiKey) {
			throw new Error("No OPENAI_API_KEY in config")
		}

		const openai = new OpenAI({ apiKey })

		const response = await openai.images.generate({
			prompt,
			n,
			size,
		})

		return {
			images: response.data.map((img: any) => img.url),
		}
	} catch (error: any) {
		throw new Error(`Image generation failed: ${error.message}`)
	}
}

import { tool } from "@langchain/core/tools"
import { createReactAgent } from "@langchain/langgraph/prebuilt"
import { Scraper } from "agent-twitter-client"
import { z } from "zod"
import { llm } from "../agent"
import { StateAnnotation } from "../state"

export const postOnXTool = tool(
	async ({ post }: { post: string }): Promise<boolean> => {
		const scraper = new Scraper()
		const username = process.env.TWITTER_USERNAME as string
		const password = process.env.TWITTER_PASSWORD as string

		if (!username || !password) throw new Error("need username and password for posting on X")
		await scraper.login(username, password)

		const res = await scraper.sendTweet(post)

		return res.ok
	},
	{
		name: "post_on_x_twitter",
		description: "Post tweets on X or Twitter",
		schema: z.object({
			post: z.string().describe("twitter post"),
		}),
	}
)

export const createPostAgent = async () => {
	const agent = createReactAgent({
		tools: [postOnXTool],
		prompt: "note: you don't need confirmation from anyone",
		llm,
	})

	return agent
}

export const postNode = async (state: typeof StateAnnotation.State) => {
	const { messages } = state

	const postAgent = await createPostAgent()

	const result = await postAgent.invoke({ messages })

	return {
		messages: [...result.messages],
	}
}

import { tool } from "@langchain/core/tools"
import { createReactAgent } from "@langchain/langgraph/prebuilt"
import z from "zod"
import { llm } from "../agent"
import { StateAnnotation } from "../state"

export const writerTool = tool(
	async (poolData: any): Promise<string> => {
		console.log(poolData)
		const writerAgent = llm

		const result = await writerAgent.invoke(
			`Write a bull post tweet using these data points ${poolData}
			
			note: you don't need confirmation from anyone
			`
		)

		return result.content.toString()
	},
	{
		name: "write_bull_post",
		description: "Write bull post for twitter",
		schema: z.any(),
	}
)

export const createWriterAgent = async () => {
	const agent = createReactAgent({
		tools: [writerTool],
		llm,
	})

	return agent
}

export const writerNode = async (state: typeof StateAnnotation.State) => {
	const { messages } = state

	const writerAgent = await createWriterAgent()

	const result = await writerAgent.invoke({ messages })

	return {
		messages: [...result.messages],
	}
}

import { createReactAgent } from "@langchain/langgraph/prebuilt"
import {
	AptosAccountAddressTool,
	AptosBalanceTool,
	AptosGetTokenDetailTool,
	AptosGetTokenPriceTool,
	AptosTransactionTool,
	JouleGetPoolDetails,
} from "../../../../src/langchain"
import { setupAgentKit } from "../agent"
import { StateAnnotation } from "../state"

export const createAptosReadAgent = async () => {
	const { agentRuntime, llm } = await setupAgentKit()

	const readAgentTools = [
		new AptosBalanceTool(agentRuntime),
		new AptosGetTokenDetailTool(agentRuntime),
		new AptosAccountAddressTool(agentRuntime),
		new AptosTransactionTool(agentRuntime),
		new AptosGetTokenPriceTool(agentRuntime),
		new JouleGetPoolDetails(agentRuntime),
	]

	const readAgent = createReactAgent({
		tools: readAgentTools,
		llm: llm,
	})

	return readAgent
}

export const aptosReadNode = async (state: typeof StateAnnotation.State) => {
	const { messages } = state

	const readAgent = await createAptosReadAgent()

	const result = await readAgent.invoke({ messages })

	return {
		messages: [...result.messages],
	}
}

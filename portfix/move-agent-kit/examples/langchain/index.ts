import {
	Aptos,
	AptosConfig,
	Ed25519PrivateKey,
	HexInput,
	Network,
	PrivateKey,
	PrivateKeyVariants,
} from "@aptos-labs/ts-sdk"
import { ChatAnthropic } from "@langchain/anthropic"
import { HumanMessage } from "@langchain/core/messages"
import { MemorySaver } from "@langchain/langgraph"
import { createReactAgent } from "@langchain/langgraph/prebuilt"
import { AgentRuntime, LocalSigner, createAptosTools } from "../../src"

export const main = async () => {
	const aptosConfig = new AptosConfig({
		network: Network.MAINNET,
	})
	const aptos = new Aptos(aptosConfig)
	const account = await aptos.deriveAccountFromPrivateKey({
		privateKey: new Ed25519PrivateKey(
			PrivateKey.formatPrivateKey(process.env.PRIVATE_KEY as HexInput, PrivateKeyVariants.Ed25519)
		),
	})

	const signer = new LocalSigner(account, Network.MAINNET)
	const agentRuntime = new AgentRuntime(signer, aptos, {
		PANORA_API_KEY: process.env.PANORA_API_KEY,
	})
	const tools = createAptosTools(agentRuntime)

	const llm = new ChatAnthropic({
		model: "claude-3-sonnet-20240229",
	})
	const memory5 = new MemorySaver()

	const agent = createReactAgent({
		llm,
		tools,
		checkpointSaver: memory5,
		messageModifier: `
            You are a helpful agent that can interact onchain using the Aptos Agent Kit. You are
            empowered to interact onchain using your tools. If you ever need funds, you can request them from the
            faucet. If not, you can provide your wallet details and request funds from the user. If there is a 5XX
            (internal) HTTP error code, ask the user to try again later. If someone asks you to do something you
            can't do with your currently available tools, you must say so, and encourage them to implement it
            themselves using the Aptos Agent Kit, recommend they go to https://www.aptosagentkit.xyz for more information. Be
            concise and helpful with your responses. Refrain from restating your tools' descriptions unless it is explicitly requested.
			The input json should be string (IMPORTANT)
        `,
	})

	const config = { configurable: { thread_id: "Aptos Agent Kit!" } }
	const stream = await agent.stream(
		{
			messages: [new HumanMessage("get my balance")],
		},
		config
	)

	for await (const chunk of stream) {
		if ("agent" in chunk) {
			console.log(chunk.agent.messages[0].content)
		} else if ("tools" in chunk) {
			console.log(chunk.tools.messages[0].content)
		}
		console.log("-------------------")
	}
}

process.on("unhandledRejection", (error) => {
	console.error("An error occurred:", error)
	process.exit(1)
})

main().catch((e) => console.log("error", e))

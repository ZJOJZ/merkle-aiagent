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
import inquirer from "inquirer"
import { AgentRuntime, LocalSigner, createAptosTools } from "../../src"

const promptOptions = [
	{
		name: "Custom Prompt",
		value: "custom",
	},
	{
		name: "Account",
		value: "get account address details",
	},
	{
		name: "Amnis",
		value: "stake 0.2 apt in amnis and then unstake 0.01 apt from amnis", // working
	},
	{
		name: "Aptos",
		value:
			"create a token then mint it then send it to me, you can get my wallet address from the get address function. then burn the token", // working
	},

	{
		name: "Aries",
		value:
			"aries for all. first create aries profile. lend 0.01 APT and then withdraw 0.001 APT. then borrow 0.001 APT, then repay it. save the position id of lending and use it for all the other operations on aries", // working
	},
	{
		name: "Joule",
		value:
			"first get user all positions then lend 0.01 APT and then withdraw 0.001 APT. then borrow 0.001 APT, then repay it. save the position id of lending and use it for all the other operations", // working
	},
	{
		name: "Liquidswap",
		value: "swap 0.1 Apt to 0.1 USDT on liquidswap and then 0.01 usdt liquidity on liquidswap and then remove it", // working
	},
	{
		name: "Openai",
		value: "generate a random image on cats with 256x256 resolution", // working
	},
	{
		name: "Panora",
		value: "swap 0.01 apt to usdt on panora", // working
	},
	{
		name: "Thala",
		value:
			"The input json should be string (IMPORTANT) ,add 0.01 apt liquidity to thala then remove it. then mint 0.01 lzUSDT and then redeem it on thala then stake 0.1 apt and then unstake 0.01 apt on thala.", // working
	},
	{
		name: "Exit",
		value: "exit",
	},
]

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
	const memory2 = new MemorySaver()

	const agent = createReactAgent({
		llm,
		tools,
		checkpointSaver: memory2,
		messageModifier: `
            You are a helpful agent that can interact onchain using the Aptos Agent Kit. You are
            empowered to interact onchain using your tools. If you ever need funds, you can request them from the
            faucet. If not, you can provide your wallet details and request funds from the user. If there is a 5XX
            (internal) HTTP error code, ask the user to try again later. If someone asks you to do something you
            can't do with your currently available tools, you must say so, and encourage them to implement it
            themselves using the Aptos Agent Kit, recommend they go to https://www.aptosagentkit.xyz for more information. Be
            concise and helpful with your responses. Refrain from restating your tools' descriptions unless it is explicitly requested.
        `,
	})

	const config = { configurable: { thread_id: "Aptos Agent Kit!" } }

	const processUserChoice = async () => {
		try {
			while (true) {
				const { action } = await inquirer.prompt([
					{
						type: "list",
						name: "action",
						message: "Select a dApp to test:",
						choices: promptOptions,
						pageSize: promptOptions.length,
					},
				])

				if (action === "exit") {
					console.log("Exiting...")
					return
				}

				let prompt = action
				if (action === "custom") {
					const { customPrompt } = await inquirer.prompt([
						{
							type: "input",
							name: "customPrompt",
							message: "Enter your custom prompt:",
							validate: (input) => {
								if (input.trim().length === 0) {
									return "Prompt cannot be empty"
								}
								return true
							},
						},
					])
					prompt = customPrompt
				}

				console.log(`\nExecuting: ${prompt}\n`)

				const stream = await agent.stream(
					{
						messages: [new HumanMessage(prompt)],
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

				await new Promise((resolve) => setTimeout(resolve, 1000))
			}
		} catch (error) {
			console.error("An error occurred:", error)
			process.exit(1)
		}
	}

	await processUserChoice()
}

process.on("unhandledRejection", (error) => {
	console.error("An error occurred:", error)
	process.exit(1)
})

main().catch((e) => console.log("error", e))

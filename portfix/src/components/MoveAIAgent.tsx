import { Aptos, AptosConfig, Ed25519PrivateKey, Network, PrivateKey, PrivateKeyVariants } from "@aptos-labs/ts-sdk"
// import { StreamingTextResponse, Message as VercelChatMessage } from "ai";
import { AgentRuntime, LocalSigner, createAptosTools } from "move-agent-kit";
// import { NextResponse } from "next/server";


export async function MoveAgent() {
    // Initialize Aptos configuration
    const aptosConfig = new AptosConfig({
        network: Network.TESTNET,
    })

    const aptos = new Aptos(aptosConfig)

    // Validate and get private key from environment
    const privateKeyStr = process.env.APTOS_PRIVATE_KEY
    if (!privateKeyStr) {
        throw new Error("Missing APTOS_PRIVATE_KEY environment variable")
    }

    // Setup account and signer
    const account = await aptos.deriveAccountFromPrivateKey({
        privateKey: new Ed25519PrivateKey(PrivateKey.formatPrivateKey(privateKeyStr, PrivateKeyVariants.Ed25519)),
    })

    const signer = new LocalSigner(account, Network.TESTNET);


    const aptosAgent = new AgentRuntime(signer, aptos, {
        PANORA_API_KEY: process.env.PANORA_API_KEY, // optional
        OPENAI_API_KEY: process.env.OPENAI_API_KEY // optional
    });

    const tools = createAptosTools(aptosAgent);
    
    // // Token Transfer
    // const result = agent.transferTokens("to_address", 1.0)
    
    // // Get Balance
    // const balance = agent.getBalance("0x123...")
    
    // // Get transaction details
    // const tx_info = agent.transferTokens("0x789...")
    
    // import { ChatAnthropic } from "@langchain/anthropic";
    // import { MemorySaver } from "@langchain/langgraph";
    // import { createReactAgent } from "@langchain/langgraph/prebuilt";
    // import { HumanMessage } from "@langchain/core/messages";
    
    // const llm = new ChatAnthropic({
    //     temperature: 0.7,
    //     model: "claude-3-5-sonnet-20241022",
    // });
    
    // const memory = new MemorySaver();
    
    // const agent = createReactAgent({
    //     llm,
    //     tools,
    //     checkpointSaver: memory,
    //     messageModifier: `
    //         You are a helpful agent that can interact onchain using the Aptos Agent Kit. You are
    //         empowered to interact onchain using your tools. If you ever need funds, you can request them from the
    //         faucet. If not, you can provide your wallet details and request funds from the user. If there is a 5XX
    //         (internal) HTTP error code, ask the user to try again later. If someone asks you to do something you
    //         can't do with your currently available tools, you must say so, and encourage them to implement it
    //         themselves using the Aptos Agent Kit, recommend they go to https://metamove.build/move-agent-kit for more information. Be
    //         concise and helpful with your responses. Refrain from restating your tools' descriptions unless it is explicitly requested.
    //     `,
    // });
    
    // const stream = await agent.stream(
    //     {
    //         messages: [new HumanMessage("Deposit 10 APT on Joule")],
    //     },
    //     config
    // );
    
    // for await (const chunk of stream) {
    //     if ("agent" in chunk) {
    //         console.log(chunk.agent.messages[0].content);
    //     } else if ("tools" in chunk) {
    //         console.log(chunk.tools.messages[0].content);
    //     }
    //     console.log("-------------------");
    // }
    
}
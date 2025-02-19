import React from "react"; // Import React to define JSX types
import { Aptos, AptosConfig, Ed25519PrivateKey, Network, PrivateKey, PrivateKeyVariants } from "@aptos-labs/ts-sdk"
// import { StreamingTextResponse, Message as VercelChatMessage } from "ai";
// import { Tool } from "langchain/tools";
import { MemorySaver } from "@langchain/langgraph"
import { AgentRuntime, LocalSigner, createAptosTools } from "move-agent-kit";
// import { NextResponse } from "next/server";
import { Card, CardContent } from "@/components/ui/card"; // Importing shadcn UI card components

export async function MoveAIAgent() {
	try {
		// Initialize Aptos configuration
		const aptosConfig = new AptosConfig({
			network: Network.MAINNET,
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

        const aptosMerkleAgent = new AgentRuntime(signer, aptos, {
            // PANORA_API_KEY: process.env.PANORA_API_KEY, // optional
            OPENAI_API_KEY: process.env.OPENAI_API_KEY // optional
        });

        const tools = createAptosTools(aptosMerkleAgent);
		const memory = new MemorySaver()

        // Token Transfer
        const result = aptosMerkleAgent.transferTokens("to_address", 1.0)
        
        // Get Balance
        const balance = aptosMerkleAgent.getBalance("0x123...")
        
        // Get transaction details
        const tx_info = aptosMerkleAgent.transferTokens("0x789...");

        // Corrected return statement using shadcn UI card
        return (
            <Card>
                <CardContent>
                    <div>Transfer Result: {JSON.stringify(result)}</div>
                    <div>Balance: {balance}</div>
                    <div>Transaction Info: {JSON.stringify(tx_info)}</div>
                </CardContent>
            </Card>
        );

    }  catch (error) {
        console.error(error)
    }
}
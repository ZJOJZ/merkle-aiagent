// 移除"use client"以避免在客户端组件中使用async/await
import React, { useEffect, useState } from "react"; // Import React to define JSX types
import { Aptos, AptosConfig, Ed25519PrivateKey, Network, PrivateKey, PrivateKeyVariants } from "@aptos-labs/ts-sdk"
import { AgentRuntime, LocalSigner, createAptosTools } from "move-agent-kit";
import { Card, CardContent } from "@/components/ui/card"; // Importing shadcn UI card components

export function MoveAIAgent() {
    const [result, setResult] = useState(null);
    const [balance, setBalance] = useState(null);
    const [txInfo, setTxInfo] = useState(null);
    const [userPositions, setUserPositions] = useState(null);

    useEffect(() => {
        async function fetchData() {
            try {
                // Initialize Aptos configuration
                const aptosConfig = new AptosConfig({
                    network: Network.TESTNET,
                });

                const aptos = new Aptos(aptosConfig);

                // Validate and get private key from environment
                const privateKeyStr = process.env.APTOS_PRIVATE_KEY;
                if (!privateKeyStr) {
                    throw new Error("Missing APTOS_PRIVATE_KEY environment variable");
                }

                // Setup account and signer
                const account = await aptos.deriveAccountFromPrivateKey({
                    privateKey: new Ed25519PrivateKey(PrivateKey.formatPrivateKey(privateKeyStr, PrivateKeyVariants.Ed25519)),
                });

                const signer = new LocalSigner(account, Network.TESTNET);

                const aptosMerkleAgent = new AgentRuntime(signer, aptos, {
                    OPENAI_API_KEY: process.env.OPENAI_API_KEY // optional
                });
                

                const tools = createAptosTools(aptosMerkleAgent);

                const userPositions = await aptosMerkleAgent.getUserAllPositions(account);
                setUserPositions(userPositions);

                // Token Transfer
                const transferResult = await aptosMerkleAgent.transferTokens("to_address", 1.0);
                setResult(transferResult);

                // Get Balance
                const accountBalance = await aptosMerkleAgent.getBalance("0x123...");
                setBalance(accountBalance);

                // Get transaction details
                const transactionInfo = await aptosMerkleAgent.transferTokens("0x789...");
                setTxInfo(transactionInfo);

            } catch (error) {
                console.error(error);
            }
        }

        fetchData();
    }, []);

    // Corrected return statement using shadcn UI card
    return (
        <Card>
            <CardContent>
                <div>Transfer Result: {JSON.stringify(result)}</div>
                <div>{account}</div>
                <div>User Position: {JSON.stringify(userPositions)}</div>
                <div>Balance: {balance}</div>
                <div>Transaction Info: {JSON.stringify(txInfo)}</div>
            </CardContent>
        </Card>
    );
}
"use client"

import React, { useEffect, useState } from "react"; // Import React to define JSX types
import { Card, CardContent } from "@/components/ui/card"; // Importing shadcn UI card components
import { aptosAgent, signer } from "@/components/Main";


interface AgentUIProps {
    isaptosAgentReady: boolean;
}

export function MoveAIAgent({ isaptosAgentReady }: AgentUIProps) {
    const [result, setResult] = useState(null);
    const [balance, setBalance] = useState(Number);
    const [txInfo, setTxInfo] = useState(null);
    const [userPositions, setUserPositions] = useState();

    useEffect(() => {
        if(!isaptosAgentReady) return
        async function fetchData() {
            try {
                // const userPositions = await aptosAgent.getUserAllPositions(signer.getAddress());
                // console.log(userPositions)
                // setUserPositions(userPositions);

                // Get Balance
                const accountBalance = await aptosAgent.getBalance();
                setBalance(accountBalance);
            } catch (error) {
                console.error(error);
            }
        }
        fetchData();
        const intervalId = setInterval(fetchData, 5000);
        return () => clearInterval(intervalId);
    }, [isaptosAgentReady]);

    // Corrected return statement using shadcn UI card
    return (
        <Card>
            <CardContent>
                {/* <div>Transfer Result: {JSON.stringify(result)}</div> */}
                {/* <div>{account}</div> */}
                {/* <div>User Position: {JSON.stringify(userPositions)}</div> */}
                <div>Balance: {balance}</div>
                {/* <div>Transaction Info: {JSON.stringify(txInfo)}</div> */}
            </CardContent>
        </Card>
    );
}
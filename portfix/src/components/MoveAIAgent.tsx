"use client"
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

import {APTOS_COIN} from "@aptos-labs/ts-sdk" 
import React, { useEffect, useState } from "react"; // Import React to define JSX types
import { Card, CardContent } from "@/components/ui/card"; // Importing shadcn UI card components
import { aptosAgent, signer } from "@/components/Main";
import {createAptosTools} from "../../move-agent-kit/src"

interface AgentUIProps {
    isaptosAgentReady: boolean;
}

export function MoveAIAgent({ isaptosAgentReady }: AgentUIProps) {
    const [result, setResult] = useState(null);
    const [balance, setBalance] = useState(Number);
    const [txInfo, setTxInfo] = useState(null);
    const [userPositions, setUserPositions] = useState();
    //const Agenttools = createAptosTools(aptosAgent);
    const [totalborrow, settotalborrow] = useState<number>(0);
    const TESTUSDT = "0xddb87c0d0ce27cf4a205c2f5e65d6897936d468df8d1611c50b4eb72ed4c9468::test_tokens::USDT"
    const TESTAPT = "0xddb87c0d0ce27cf4a205c2f5e65d6897936d468df8d1611c50b4eb72ed4c9468::test_tokens::APT"
    const TESTUSDC = "0xddb87c0d0ce27cf4a205c2f5e65d6897936d468df8d1611c50b4eb72ed4c9468::test_tokens::USDC"
    const TESTWETH = "0xddb87c0d0ce27cf4a205c2f5e65d6897936d468df8d1611c50b4eb72ed4c9468::test_tokens::WETH"
    
    useEffect(() => {
        if(!isaptosAgentReady) return
        async function fetchData() {
            try {
                //get now positions in joule
                const userPositions = await aptosAgent.getUserAllPositions(signer.getAddress());
                console.log(userPositions)
                setUserPositions(userPositions);
                
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

    const onClickButton1 = async () => {
        if (!isaptosAgentReady) {
          return;
        }
    
        try {
            await aptosAgent.borrowToken(totalborrow, TESTUSDT, "1", false)
            //await aptosAgent.lendToken(totalborrow, TESTAPT, "2", true, false)
            //await aptosAgent.withdrawToken(totalborrow, TESTUSDT, "1", false)
            //await aptosAgent.repayToken(totalborrow, TESTUSDT, "1", false)
        } catch (error) {
          console.error(error);
        }
      };
    // Corrected return statement using shadcn UI card
    return (
        <Card>
            <CardContent>
                {/* <div>Transfer Result: {JSON.stringify(result)}</div> */}
                {/* <div>{account}</div> */}
                <div>User Position: {JSON.stringify(userPositions)}</div>
                <div>Balance: {balance}</div>
                {/* <div>Transaction Info: {JSON.stringify(txInfo)}</div> */}
            <div className="flex items-center gap-2">
            <span className="text-gray-400 text-xl">Total Borrow:</span>
            <Input
              type="number"
              value={totalborrow}
              onChange={(e) => settotalborrow(Number(e.target.value))}
              className="w-32 bg-black/20"
            />
          </div>
            <Button onClick={onClickButton1} className="bg-blue-600 hover:bg-blue-700">
                Execute
            </Button>

            </CardContent>
        </Card>
    );
}
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
    const [totallend, settotallend] = useState<number>(0);
    const [plend, setplend] = useState<string>("");
    const [totalwithdraw, settotalwithdraw] = useState<number>(0);
    const [pwithdraw, setpwithdraw] = useState<string>("");
    const [totalrepay, settotalrepay] = useState<number>(0);
    
    //const TESTUSDT = "0x2fe576faa841347a9b1b32c869685deb75a15e3f62dfe37cbd6d52cc403a16f6::test_tokens::USDT"
    const MAINUSDC = "0xbae207659db88bea0cbead6da0ed00aac12edcdda169e591cd41c94180b46f3b"
    //const TESTWETH = "0x2fe576faa841347a9b1b32c869685deb75a15e3f62dfe37cbd6d52cc403a16f6::test_tokens::WETH"
    
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

    const onClickButton_lend = async () => {
        if (!isaptosAgentReady) {
          return;
        }
    
        try {
            //await aptosAgent.borrowToken(totalborrow, TESTUSDT, "1", false)
            await aptosAgent.lendToken(totallend * 1000000, MAINUSDC, plend, false, true)
            //await aptosAgent.repayToken(totalborrow, TESTUSDT, "1", false)
        } catch (error) {
          console.error(error);
        }
      };
    const onClickButton_withdraw = async () => {
        if (!isaptosAgentReady) {
          return;
        }
        try {
            await aptosAgent.withdrawToken(totalwithdraw * 1000000, MAINUSDC, plend, true)
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
            <span className="text-gray-400 text-xl">Total Lend:</span>
            <Input
              type="number"
              value={totallend}
              onChange={(e) => settotallend(Number(e.target.value))}
              className="w-32 bg-black/20"
            />
            <span className="text-gray-400 text-xl ml-4">Position:</span>
            <Input
              type="text"
              value={plend}
              onChange={(e) => setplend(e.target.value)}
              className="w-32 bg-black/20"
            />
            </div>
            <Button onClick={onClickButton_lend} className="bg-blue-600 hover:bg-blue-700">
                Execute
            </Button>

            <div className="flex items-center gap-2">
            <span className="text-gray-400 text-xl">Total Withdraw:</span>
            <Input
              type="number"
              value={totalwithdraw}
              onChange={(e) => settotalwithdraw(Number(e.target.value))}
              className="w-32 bg-black/20"
            />
            <span className="text-gray-400 text-xl ml-4">Position:</span>
            <Input
              type="text"
              value={pwithdraw}
              onChange={(e) => setpwithdraw(e.target.value)}
              className="w-32 bg-black/20"
            />
            </div>
            <Button onClick={onClickButton_withdraw} className="bg-blue-600 hover:bg-blue-700">
                Execute
            </Button>

            </CardContent>
        </Card>
    );
}
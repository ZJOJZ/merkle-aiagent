"use client"
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

import {APTOS_COIN} from "@aptos-labs/ts-sdk" 

import React, { useEffect, useState } from "react"; // Import React to define JSX types
import { Card, CardContent } from "@/components/ui/card"; // Importing shadcn UI card components
import { aptosAgent, signer, aptos} from "@/components/Main";
import {createAptosTools} from "../../move-agent-kit/src"
import type { InputTransactionData } from "@aptos-labs/wallet-adapter-react"

interface AgentUIProps {
    isaptosAgentReady: boolean;
}

// transit amount to the shares
async function Amount2Shares(amount: number, token: string) {
  try {
    const transaction = await aptos.view({
          payload:{
            function: '0x2fe576faa841347a9b1b32c869685deb75a15e3f62dfe37cbd6d52cc403a16f6::pool::coins_to_shares',
            functionArguments: ['@bae207659db88bea0cbead6da0ed00aac12edcdda169e591cd41c94180b46f3b', amount],
          }
    })
    //console.log("check1:", transaction)
    return Number(transaction[0])

  } catch (error: any) {
    throw new Error(`transform to shares failed: ${error.message}`)
  }
}

export function MoveAIAgent({ isaptosAgentReady }: AgentUIProps) {
    const [result, setResult] = useState(null);
    const [balance, setBalance] = useState(Number);
    const [txInfo, setTxInfo] = useState(null);
    const [userPositions, setUserPositions] = useState();
    //const Agenttools = createAptosTools(aptosAgent);
    const [totalborrow, settotalborrow] = useState<number>(0);
    const [pborrow, setpborrow] = useState<string>("");
    const [totallend, settotallend] = useState<number>(0);
    const [plend, setplend] = useState<string>("");
    const [totalwithdraw, settotalwithdraw] = useState<number>(0);
    const [pwithdraw, setpwithdraw] = useState<string>("");
    const [totalrepay, settotalrepay] = useState<number>(0);
    const [prepay, setprepay] = useState<string>("");

    
    //const TESTUSDT = "0x2fe576faa841347a9b1b32c869685deb75a15e3f62dfe37cbd6d52cc403a16f6::test_tokens::USDT"
    const MAINUSDC = "0xbae207659db88bea0cbead6da0ed00aac12edcdda169e591cd41c94180b46f3b"
    const FAUSDC = "@bae207659db88bea0cbead6da0ed00aac12edcdda169e591cd41c94180b46f3b"
    const MAINUSDT = "0x357b0b74bc833e95a115ad22604854d6b0fca151cecd94111770e5d6ffc9dc2b"
    const FAUSDT = "@bae207659db88bea0cbead6da0ed00aac12edcdda169e591cd41c94180b46f3b"
    
    //const TESTWETH = "0x2fe576faa841347a9b1b32c869685deb75a15e3f62dfe37cbd6d52cc403a16f6::test_tokens::WETH"
    
    useEffect(() => {
        if(!isaptosAgentReady) return
        async function fetchData() {
            try {
                //get now positions in joule
                const userPositions = await aptosAgent.getUserAllPositions(signer.getAddress());
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
            const shares = await Amount2Shares(totalwithdraw * 1000000, FAUSDC)
            await aptosAgent.withdrawToken(shares, MAINUSDC, pwithdraw, true)
        } catch (error) {
          console.error(error);
        }
      };
    const onClickButton_borrow = async () => {
        if (!isaptosAgentReady) {
          return;
        }
        try {
            await aptosAgent.borrowToken(totalborrow * 1000000, MAINUSDC, pborrow, true)
        } catch (error) {
          console.error(error);
        }
      };
    const onClickButton_repay = async () => {
        if (!isaptosAgentReady) {
          return;
        }
        try {
            //const shares = await Amount2Shares(totalwithdraw * 1000000, FAUSDC)
            await aptosAgent.repayToken(totalrepay * 1000000, MAINUSDC, prepay, true)
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


            <div className="flex items-center gap-2">
            <span className="text-gray-400 text-xl">Total Borrow:</span>
            <Input
              type="number"
              value={totalborrow}
              onChange={(e) => settotalborrow(Number(e.target.value))}
              className="w-32 bg-black/20"
            />
            <span className="text-gray-400 text-xl ml-4">Position:</span>
            <Input
              type="text"
              value={pborrow}
              onChange={(e) => setpborrow(e.target.value)}
              className="w-32 bg-black/20"
            />
            </div>
            <Button onClick={onClickButton_borrow} className="bg-blue-600 hover:bg-blue-700">
                Execute
            </Button>

            <div className="flex items-center gap-2">
            <span className="text-gray-400 text-xl">Total Repay:</span>
            <Input
              type="number"
              value={totalrepay}
              onChange={(e) => settotalrepay(Number(e.target.value))}
              className="w-32 bg-black/20"
            />
            <span className="text-gray-400 text-xl ml-4">Position:</span>
            <Input
              type="text"
              value={prepay}
              onChange={(e) => setprepay(e.target.value)}
              className="w-32 bg-black/20"
            />
            </div>
            <Button onClick={onClickButton_repay} className="bg-blue-600 hover:bg-blue-700">
                Execute
            </Button>

            </CardContent>
        </Card>
    );
}
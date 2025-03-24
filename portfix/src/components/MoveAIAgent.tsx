"use client"
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";



import React, { useEffect, useState } from "react"; // Import React to define JSX types

import { aptosAgent, signer, aptos} from "@/components/Main";
import { TokenContractAddress } from "@/components/JouleTokenPair";

import {APTOS_COIN} from "@aptos-labs/ts-sdk" 
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

    const FAUSDT = "@bae207659db88bea0cbead6da0ed00aac12edcdda169e591cd41c94180b46f3b"
    const MAINUSDT = "0x357b0b74bc833e95a115ad22604854d6b0fca151cecd94111770e5d6ffc9dc2b"

    // 地址到代币名称的映射
    const tokenAddressToName: { [key: string]: string } = {
        [FAUSDC]: "Faucet-USDC",
        [MAINUSDC]: "Mainnet-USDC",
        [FAUSDT]: "Faucet-USDT",
        [MAINUSDT]: "Mainnet-USDT"
    }

    // 将地址转换为可读的代币名称
    const getTokenName = (address: string): string => {
        return tokenAddressToName[address] || address
    }
    
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
    console.log(userPositions)
    return (
          <div className="space-y-2">
                {/* <div>Transfer Result: {JSON.stringify(result)}</div> */}
                {/* <div>Balance: {balance}</div> */}
                {/* <div>Transaction Info: {JSON.stringify(txInfo)}</div> */}
            <div className="flex items-center gap-2">
            <span>Lend</span>
            <Input
              type="number"
              value={totallend}
              onChange={(e) => settotallend(Number(e.target.value))}
              className="w-36"
            />
            <Select value={plend} onValueChange={setplend} defaultValue={userPositions?.[0]?.positions_map?.data?.[0]?.key}>
              <SelectTrigger >
                <SelectValue placeholder="Select position" />
              </SelectTrigger>
              <SelectContent>
                {userPositions?.[0]?.positions_map?.data?.map((position) => (
                  <SelectItem key={position.key} value={position.key}>
                    {position.value.position_name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Button onClick={onClickButton_lend}>
                Execute
            </Button>
            </div>
            

            <div className="flex items-center gap-2">
            <span>Withdraw</span>
            <Input
              type="number"
              value={totalwithdraw}
              onChange={(e) => settotalwithdraw(Number(e.target.value))}
              className="w-36"
            />
            <Select value={pwithdraw} onValueChange={setpwithdraw} defaultValue={userPositions?.[0]?.positions_map?.data?.[0]?.key}>
              <SelectTrigger >
                <SelectValue placeholder="Select position" />
              </SelectTrigger>
              <SelectContent>
                {userPositions?.[0]?.positions_map?.data?.map((position) => (
                  <SelectItem key={position.key} value={position.key}>
                    {position.value.position_name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Button onClick={onClickButton_withdraw}>
                Execute
            </Button>
            </div>


            <div className="flex items-center gap-2">
            <span>Borrow</span>
            <Input
              type="number"
              value={totalborrow}
              onChange={(e) => settotalborrow(Number(e.target.value))}
              className="w-36"
            />
            <Select value={pborrow} onValueChange={setpborrow} defaultValue={userPositions?.[0]?.positions_map?.data?.[0]?.key}>
              <SelectTrigger >
                <SelectValue placeholder="Select position" />
              </SelectTrigger>
              <SelectContent>
                {userPositions?.[0]?.positions_map?.data?.map((position) => (
                  <SelectItem key={position.key} value={position.key}>
                    {position.value.position_name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Button onClick={onClickButton_borrow}>
                Execute
            </Button>
            </div>
            

            <div className="flex items-center gap-2">
            <span>Repay</span>
            <Input
              type="number"
              value={totalrepay}
              onChange={(e) => settotalrepay(Number(e.target.value))}
              className="w-36"
            />
            <Select value={prepay} onValueChange={setprepay} defaultValue={userPositions?.[0]?.positions_map?.data?.[0]?.key}>
              <SelectTrigger >
                <SelectValue placeholder="Select position" />
              </SelectTrigger>
              <SelectContent>
                {userPositions?.[0]?.positions_map?.data?.map((position) => (
                  <SelectItem key={position.key} value={position.key}>
                    {position.value.position_name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            
            <Button onClick={onClickButton_repay}>
                Execute
            </Button>
            </div>
</div>
    );
}
"use client"
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Table, TableBody, TableCaption, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";



import React, { useEffect, useState } from "react"; // Import React to define JSX types

import { aptosAgent, signer, aptos} from "@/components/Main";
import { TokenContractAddress } from "@/components/JouleTokenPair";

import {APTOS_COIN} from "@aptos-labs/ts-sdk" 
import {createAptosTools} from "../../move-agent-kit/src"
import type { InputTransactionData } from "@aptos-labs/wallet-adapter-react"

interface AgentUIProps {
    isaptosAgentReady: boolean;
    onBalanceChange?: (balance: number) => void;
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

export function JoulePositions({ isaptosAgentReady, onBalanceChange }: AgentUIProps) {
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
                onBalanceChange?.(accountBalance);
                
                
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
                <Table>
                    <TableHeader>
                        <TableRow>
                            <TableHead>Position</TableHead>
                            <TableHead>Type</TableHead>
                            <TableHead>Coin</TableHead>
                            <TableHead>Amount</TableHead>
                            <TableHead>Interest</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {userPositions?.[0]?.positions_map?.data?.map((position) => (
                            <>
                                {/* Lending Positions */}
                                {position.value.lend_positions.data.map((lendPosition) => (
                                    <TableRow key={`${position.key}-lend-${lendPosition.key}`}>
                                        <TableCell>{position.value.position_name}</TableCell>
                                        <TableCell>Lending</TableCell>
                                        <TableCell>{getTokenName(lendPosition.key.replace("@","0x"))}</TableCell>
                                        <TableCell>{lendPosition.value}</TableCell>
                                        <TableCell>-</TableCell>
                                    </TableRow>
                                ))}
                                {/* Borrowing Positions */}
                                {position.value.borrow_positions.data.map((borrowPosition) => (
                                    <TableRow key={`${position.key}-borrow-${borrowPosition.key}`}>
                                        <TableCell>{position.value.position_name}</TableCell>
                                        <TableCell>Borrowing</TableCell>
                                        <TableCell>{getTokenName(borrowPosition.value.coin_name.replace("@","0x"))}</TableCell>
                                        <TableCell>{borrowPosition.value.borrow_amount}</TableCell>
                                        <TableCell>{borrowPosition.value.interest_accumulated}</TableCell>
                                    </TableRow>
                                ))}
                            </>
                        ))}
                    </TableBody>
                </Table>
    );
}
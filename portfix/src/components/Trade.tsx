import { ChevronDown, ChevronUp } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
// import { TokenIcon } from '@web3icons/react'
import { Input } from "@/components/ui/input"
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { MerkleClient, MerkleClientConfig} from "@merkletrade/ts-sdk";
import { OpenPosition } from "@/entry-functions/merkleTrade";
import { aptosClient } from "@/utils/aptosClient";
import { useQueryClient } from "@tanstack/react-query";

import { useEffect, useState } from "react";


interface TradeCardProps {
    symbol: string;
    amount: number;
    totalAmount: number;
    leverageDefault: number;
    position: string;
    isExpanded: boolean;
    onToggle: () => void;
}

const TradeCard = ({ symbol, amount, totalAmount, leverageDefault, position, isExpanded, onToggle }: TradeCardProps) => {
    // 计算百分比
    const percent = totalAmount > 0 ? amount / totalAmount : 0;

    return (
        <div
            className="border-2 border-white/20 rounded-lg bg-card/50 overflow-hidden cursor-pointer"
            onClick={onToggle}
        >
            <div className="relative h-16">
                {/* 背景方块 */}
                <div
                    className={`absolute left-0 top-0 h-full bg-opacity-20 ${position === 'long' ? 'bg-green-500' :
                        position === 'short' ? 'bg-red-500' :
                            symbol.startsWith('ETH') ? 'bg-blue-500' : 'bg-orange-500'
                        }`}
                    style={{ width: `${percent * 100}%` }}
                />

                {/* 内容 */}
                <div className="relative flex items-center justify-between h-full px-4">
                    <div className="flex items-center gap-3">
                        <span className={
                            position === 'long' ? 'text-green-500' :
                                position === 'short' ? 'text-red-500' :
                                    symbol.startsWith('ETH') ? 'text-blue-500' : 'text-orange-500'
                        }>
                        </span>
                        <span className="font-medium">{symbol}</span>
                        {position && (
                            <>
                                <span className={`text-sm ${position === 'long' ? 'text-green-500' : 'text-red-500'
                                    }`}>
                                    {position.toUpperCase()}
                                </span>
                                <span className="text-sm text-blue-500">
                                    {Math.round(leverageDefault)}x
                                </span>
                            </>
                        )}
                    </div>
                    <div className="flex items-center gap-3">
                        <span className="text-gray-400">{(percent * 100).toFixed(1)}%</span>
                        {isExpanded ? <ChevronUp size={20} /> : <ChevronDown size={20} />}
                    </div>
                </div>
            </div>

            <AnimatePresence initial={false}>
                {isExpanded && (
                    <motion.div
                        initial={{ height: 0 }}
                        animate={{ height: "auto" }}
                        exit={{ height: 0 }}
                        transition={{ duration: 0.3, ease: "easeInOut" }}
                        style={{ overflow: "hidden" }}
                    >
                        <div className="p-4 space-y-4 border-t border-white/20">
                            <div className="flex gap-2">
                                <button
                                    disabled
                                    className={`flex-1 ${position === 'long'
                                        ? 'bg-green-600 text-white'
                                        : 'bg-green-600/20 text-green-500'
                                        } py-2 rounded-lg cursor-default`}
                                >
                                    Long
                                </button>
                                <button
                                    disabled
                                    className={`flex-1 ${position === 'short'
                                        ? 'bg-red-600 text-white'
                                        : 'bg-red-600/20 text-red-500'
                                        } py-2 rounded-lg cursor-default`}
                                >
                                    Short
                                </button>
                            </div>

                            <div className="flex items-center justify-between gap-4">
                                <div className="flex items-center gap-2 flex-1">
                                    <input
                                        type="text"
                                        value={amount}
                                        readOnly
                                        className="flex-1 bg-black/20 rounded-lg p-2 border border-white/20"
                                    />
                                    <span>=</span>
                                    <div className="bg-black/20 rounded-lg p-2 w-24 text-center border border-white/20">
                                        USDC
                                    </div>
                                </div>

                                <div className="flex items-center gap-2">
                                    <span>Leverage</span>
                                    <div className="bg-black/20 px-3 py-1 rounded border border-white/20">
                                        <span className="text-blue-500">{Math.round(leverageDefault)}x</span>
                                    </div>
                                </div>
                            </div>


                        </div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
};

let merkle: MerkleClient;

export const Trade = () => {
    const [expandedCard, setExpandedCard] = useState<string | null>(null);
    const queryClient = useQueryClient();
    const [isClientReady, setIsClientReady] = useState<boolean>(false);

    useEffect(() => {
        const initMerkle = async () => {
            merkle = new MerkleClient(await MerkleClientConfig.testnet());
            setIsClientReady(true);
        };
        
        initMerkle();
    }, []);
    
    const handleToggle = (symbol: string) => {
        setExpandedCard(expandedCard === symbol ? null : symbol);
    };

    const [totalinput, settotalinput] = useState<number>(0);
    const [islong1, setLong1] = useState<boolean>(true);
  const [islong2, setLong2] = useState<boolean>(true);
  const [islong3, setLong3] = useState<boolean>(true);
  const [islong4, setLong4] = useState<boolean>(true);
  const [islong5, setLong5] = useState<boolean>(true);
  const [islong6, setLong6] = useState<boolean>(true);
  
  const [amount1, setTransferAmount1] = useState<number>(0);
  const [amount2, setTransferAmount2] = useState<number>(0);
  const [amount3, setTransferAmount3] = useState<number>(0);
  const [amount4, setTransferAmount4] = useState<number>(0);
  const [amount5, setTransferAmount5] = useState<number>(0);
  const [amount6, setTransferAmount6] = useState<number>(0);

  const [lever1, setlever1] = useState<number>(0);
  const [lever2, setlever2] = useState<number>(0);
  const [lever3, setlever3] = useState<number>(0);
  const [lever4, setlever4] = useState<number>(0);
  const [lever5, setlever5] = useState<number>(0);
  const [lever6, setlever6] = useState<number>(0);
  
    
    // 定义卡片数据
    let cards = [
        {
            symbol: "BTC",
            amount: amount1,
            leverageDefault: lever1,
            position: islong1 ? 'long' : 'short',
        },
        {
            symbol: "ETH",
            amount: amount2,
            leverageDefault: lever2,
            position: islong2 ? 'long' : 'short',
        },
        {
            symbol: "APT",
            amount: amount3,
            leverageDefault: lever3,
            position: islong3 ? 'long' : 'short',
        },
        {
            symbol: "SUI",
            amount: amount4,
            leverageDefault: lever4,
            position: islong4 ? 'long' : 'short',
        },
        {
            symbol: "TRUMP",
            amount: amount5,
            leverageDefault: lever5,
            position: islong5 ? 'long' : 'short',
        },
        {
            symbol: "DOGE",
            amount: amount6,
            leverageDefault: lever6,
            position: islong6 ? 'long' : 'short',
        },
    ];
    const { account, signAndSubmitTransaction } = useWallet();    
    // 计算总金额
    const totalAmount = cards.reduce((sum, card) => sum + card.amount, 0);
    
    // 按金额排序
    const sortedCards = [...cards].sort((a, b) => b.amount - a.amount);
    
    const onClickButton = async () => {
        console.log(totalAmount)
        if (!account || !isClientReady) {
            return;
        }
    
        try {
          const n1 = BigInt(Math.floor(amount1) * totalinput) * 10_000n;
          if(n1 > 10_000_000n){
          const transaction = await OpenPosition("BTC_USD", n1, islong1, lever1, account.address, merkle);
          const committedTransaction = await signAndSubmitTransaction(transaction);
          const executedTransaction = await aptosClient().waitForTransaction({transactionHash: committedTransaction.hash,});
            }
          
            const n2 = BigInt(Math.floor(amount2) * totalinput) * 10_000n;
          if(n2 > 10_000_000n){
          const transaction = await OpenPosition("ETH_USD", n2, islong2, lever2, account.address, merkle);
          const committedTransaction = await signAndSubmitTransaction(transaction);
          const executedTransaction = await aptosClient().waitForTransaction({transactionHash: committedTransaction.hash,});
            }
            const n3 = BigInt(Math.floor(amount3) * totalinput) * 10_000n;
          if(n3 > 10_000_000n){
          const transaction = await OpenPosition("APT_USD", n3, islong3, lever3, account.address, merkle);
          const committedTransaction = await signAndSubmitTransaction(transaction);
          const executedTransaction = await aptosClient().waitForTransaction({transactionHash: committedTransaction.hash,});
            }
            const n4 = BigInt(Math.floor(amount4) * totalinput) * 10_000n;
            if(n4 > 10_000_000n){
                const transaction = await OpenPosition("SUI_USD", n4, islong4, lever4, account.address, merkle);
                const committedTransaction = await signAndSubmitTransaction(transaction);
                const executedTransaction = await aptosClient().waitForTransaction({transactionHash: committedTransaction.hash,});
            }
            const n5 = BigInt(Math.floor(amount5) * totalinput) * 10_000n;
            if(n5 > 10_000_000n){
                const transaction = await OpenPosition("TRUMP_USD", n5, islong5, lever5, account.address, merkle);
                const committedTransaction = await signAndSubmitTransaction(transaction);
                const executedTransaction = await aptosClient().waitForTransaction({transactionHash: committedTransaction.hash,});
            }
            const n6 = BigInt(Math.floor(amount6) * totalinput) * 10_000n;
            if(n6 > 10_000_000n){
                const transaction = await OpenPosition("DOGE_USD", n6, islong6, lever6, account.address, merkle);
                const committedTransaction = await signAndSubmitTransaction(transaction);
                const executedTransaction = await aptosClient().waitForTransaction({transactionHash: committedTransaction.hash,});
            }
            queryClient.invalidateQueries({
            queryKey: ["apt-balance", account?.address],
          });
    
        //   toast({
        //     title: "Success",
        //     description: `Transaction succeeded, hash: ${executedTransaction.hash}`,
        //   });
        } catch (error) {
          console.error(error);
        }
      };

        useEffect(() => {
        // 定义需要定期执行的函数
            const myFunction = () => {
                const randomNumbers = Array.from({ length: 5 }, () => Math.random() * 100);
                randomNumbers.sort((a, b) => a - b);
                randomNumbers.unshift(0);
                randomNumbers.push(100);
                const portion_result = [];
                for (let i = 1; i < randomNumbers.length; i++) {
                    portion_result.push(parseFloat((randomNumbers[i] - randomNumbers[i - 1]).toFixed(2)));
                }
                const randomIntegers: number[] = [];
                for (let i = 0; i < 6; i++) {
                    const randomInt = Math.floor(Math.random() * (120 - 30 + 1)) + 30;
                    randomIntegers.push(randomInt);
                }
                console.log(portion_result);
                setTransferAmount1(portion_result[0]);
                setTransferAmount2(portion_result[1]);
                setTransferAmount3(portion_result[2]);
                setTransferAmount4(portion_result[3]);
                setTransferAmount5(portion_result[4]);
                setTransferAmount6(portion_result[5]);
    
                setlever1(randomIntegers[0]);
                setlever2(randomIntegers[1]);
                setlever3(randomIntegers[2]);
                setlever4(randomIntegers[3]);
                setlever5(randomIntegers[4]);
                setlever6(randomIntegers[5]);
                
                setLong1(Math.random() < 0.5);
                setLong2(Math.random() < 0.5);
                setLong3(Math.random() < 0.5);
                setLong4(Math.random() < 0.5);
                setLong5(Math.random() < 0.5);
                setLong6(Math.random() < 0.5);
                
                
            // 在此处添加您需要执行的逻辑
            };
            const intervalId = setInterval(myFunction, 30000);
    
            return () => clearInterval(intervalId);
        }, []); // 空数组作为依赖，确保只在组件挂载和卸载时执行
    


    return (
        <div className="mt-4 mr-4 flex flex-col gap-4 p-4 md:p-8 rounded-lg bg-card w-full max-w-[600px] border-2 border-white/50">
            <div className="flex items-center justify-between">
                <h2 className="text-2xl font-bold">Trade</h2>
                <span className="text-blue-500">→</span>
            </div>
            <div className="space-y-2">
                {sortedCards.map(card => (
                    <TradeCard
                        key={card.symbol}
                        symbol={card.symbol}
                        amount={card.amount}
                        totalAmount={totalAmount}
                        leverageDefault={card.leverageDefault}
                        position={card.position}
                        isExpanded={expandedCard === card.symbol}
                        onToggle={() => handleToggle(card.symbol)}
                    />
                ))}
            </div>
            {/* 添加底部栏 */}
            <div className="mt-4 pt-4 border-t border-white/20">
                <div className="flex items-center justify-between mb-4">
                    <div className="flex items-center gap-2">
                        <span className="text-gray-400 text-xl">Total Amount:</span>
                        <Input
                            type="text"
                            placeholder="1000"
                            onChange={(e) => 
                                settotalinput(parseInt(e.target.value))
                            }
                            className="w-[100px] text-xl font-bold bg-transparent"
                        />
                        <span className="text-gray-400 text-xl">USDC</span>

                    </div>
                    <button
                        className="px-8 py-2 bg-blue-500 hover:bg-blue-600 text-white rounded-lg font-medium text-xl"
                        onClick={
                            onClickButton
                            }
                    >
                        Confirm
                    </button>
                </div>
            </div>
        </div>
    );
};
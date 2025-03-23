import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

import { ChevronDown, ChevronUp, ChartCandlestick } from 'lucide-react';
import { TokenIcon } from '@web3icons/react';
import { motion, AnimatePresence } from 'framer-motion';

import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { aptosClient } from "@/utils/aptosClient";
import { OpenPosition, CloseAllPosition } from "@/entry-functions/merkleTrade";

import { useQueryClient } from "@tanstack/react-query";
import { useEffect, useState } from "react";

import { merkle, tokenList } from "@/components/Main";

/**
 * TradeCard组件属性接口定义
 */
interface TradeCardProps {
  symbol: string;        // token符号
  amount: number;        // 交易金额
  totalAmount: number;   // 总交易金额
  leverageDefault: number; // 默认杠杆倍数
  position: string;      // 交易方向(long/short)
  isExpanded: boolean;   // 是否展开详情
  onToggle: () => void;  // 展开/收起回调函数
}

interface TradeUIProps {
  isClientReady: boolean;
}

/**
 * TradeCard组件 - 展示单个交易对的卡片
 * 包含交易对信息、仓位方向、金额占比和详细信息
 */
const TradeCard = ({ symbol, amount, totalAmount, leverageDefault, position, isExpanded, onToggle }: TradeCardProps) => {
  // 计算当前交易金额占总金额的百分比
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
            <TokenIcon symbol={symbol.toLowerCase()} size={32} variant="mono" />
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
                <Button
                  disabled
                  className={`flex-1 ${position === 'long'
                    ? 'bg-green-600 text-white'
                    : 'bg-green-600/20 text-green-500'
                    } py-2 rounded-lg cursor-default`}
                >
                  Long
                </Button>
                <Button
                  disabled
                  className={`flex-1 ${position === 'short'
                    ? 'bg-red-600 text-white'
                    : 'bg-red-600/20 text-red-500'
                    } py-2 rounded-lg cursor-default`}
                >
                  Short
                </Button>
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
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};

/**
 * TradeUI组件 - 主要交易界面
 * 功能：
 * 1. 展示多个交易对的卡片列表
 * 2. 管理交易状态和用户输入
 * 3. 执行交易操作
 */
export function TradeUI({ isClientReady }: TradeUIProps) {
  // 控制展开的卡片
  const [expandedCard, setExpandedCard] = useState<string | null>(null);
  const queryClient = useQueryClient();
  
  // 处理卡片展开/收起
  const handleToggle = (symbol: string) => {
    setExpandedCard(expandedCard === symbol ? null : symbol);
  };

  // 用户输入的总金额
  const [totalinput, settotalinput] = useState<number>(0);
  
  // 各交易对的仓位方向状态(long/short)
  const [islong, setLong] = useState<boolean[]>(Array(tokenList.length).fill(true));
  
  // 各交易对的金额状态
  const [amount, setTransferAmount] = useState<number[]>(Array(tokenList.length).fill(0));
  
  // 各交易对的杠杆倍数状态
  const [lever, setLever] = useState<number[]>(Array(tokenList.length).fill(0));
  
  // 交易卡片数据配置
  let cards = tokenList.map((token, index) => ({
    symbol: token.symbol,
    amount: amount[index],
    leverageDefault: lever[index],
    position: islong[index] ? 'long' : 'short',
  }));
  
  const { account, signAndSubmitTransaction } = useWallet();    
  // 计算所有交易的总金额
  const totalAmount = cards.reduce((sum, card) => sum + card.amount, 0);
  
  // 按金额大小对卡片进行排序
  const sortedCards = [...cards].sort((a, b) => b.amount - a.amount);
  
  /**
   * 处理交易确认按钮点击
   * 执行多个交易对的开仓操作
   */
  const onClickButton = async () => {
    //console.log(totalAmount);
    if (!account || !isClientReady) {
      return;
    }

    try {
        let CoinId: Map<string, number> = new Map([
            ['BTC_USD', 0], ['ETH_USD', 1], ['APT_USD', 2], ['SUI_USD', 3], ['TRUMP_USD', 4], ['DOGE_USD', 5]
        ]);
        let ordernum: bigint = 0n;
        let ordertype: number[] = [];
        let ordersizedelta: bigint[] = [];
        let orderamount: bigint[] = [];
        let orderside: boolean[] = [];
        
        for (let i = 0; i < tokenList.length; i++) { // move to batch tx; construct the argument of batchtx contract
            const n = BigInt(Math.floor(amount[i] * totalinput)) * 10_000n;
            if (n > 10_000_000n) {
                console.log("111",i,`${tokenList[i].symbol}_USD`, n, islong[i], lever[i], account.address, merkle);
                ordernum += 1n;
                if (CoinId.has(`${tokenList[i].symbol}_USD`)) {
                    ordertype.push(CoinId.get(`${tokenList[i].symbol}_USD`)!);
                } else {
                    throw new Error(`${tokenList[i].symbol}_USD not found in Coinmap`);
                }
                ordersizedelta.push(n * BigInt(lever[i]));
                orderamount.push(n);
                orderside.push(islong[i]);
                //const transaction = await OpenPosition(`${tokenList[i].symbol}_USD`, n, islong[i], lever[i], account.address, merkle);
                //const committedTransaction = await signAndSubmitTransaction(transaction);
                //await aptosClient().waitForTransaction({transactionHash: committedTransaction.hash});
            }
        }
        console.log("The number of txs", ordernum);
        const committedTransaction = await signAndSubmitTransaction({ // submit the batch tx
            data: {
              function: `0x827b56914a808d9f638252cd9b3c1229a2c2bc606eb4f70f53c741350f1dea0e::BatchCaller::batch_execute_merkle_market_v1`,
              functionArguments: [ordernum, ordertype, ordersizedelta, orderamount, orderside],
            }
            }
          );
        await aptosClient().waitForTransaction({transactionHash: committedTransaction.hash,});

           

      
        queryClient.invalidateQueries({
            queryKey: ["apt-balance", account?.address],
        });
    } catch (error) {
      console.error(error);
    }
  };

  const onClickButton_close = async() => {
    if (!account || !isClientReady) {
        return;
      }
    try{
        
      for (let i = 0; i < tokenList.length; i++) {
            const tx = await CloseAllPosition(`${tokenList[i].symbol}_USD`, account.address, merkle);
            if(tx != undefined) {
                const committedTransaction = await signAndSubmitTransaction(tx);
                await aptosClient().waitForTransaction({transactionHash: committedTransaction.hash});
            }
        }
    } catch (error) {
        console.error(error);
    }
  };

  useEffect(() => {
    // Define the function to fetch and process data
    const fetchTradeData = async () => {
      try {
        const response = await fetch('/result.jsonl.pretty.json');
        const tradeData = await response.json();
        // Extract position percentages and leverage values from actions
        const portion_result = tradeData.actions.map((action: { position_percentage: number }) => action.position_percentage);
        const leverageValues = tradeData.actions.map((action: { leverage: number }) => action.leverage);
        
        // Set the state with actual data
        setTransferAmount(portion_result);
        setLever(leverageValues.map((leverage: number) => Math.abs(leverage)));
        // Determine long/short based on leverage sign (positive = long, negative = short)
        setLong(leverageValues.map((leverage: number) => leverage > 0));
      } catch (error) {
        console.error('Error fetching trade data:', error);
        // Fallback to random values if fetch fails
        // ... existing random generation code ...
      }
    };

    // Initial fetch
    fetchTradeData();

    // Set up polling interval (e.g., every 10 seconds)
    const intervalId = setInterval(fetchTradeData, 10000);

    // Cleanup interval on component unmount
    return () => clearInterval(intervalId);
  }, []); // Empty dependency array means this runs once on component mount

  return (
    <div className="relative group mt-4 ml-4">
    {/* div外发光效果 */}
    <div className="glow-effect" />
    
    {/* 主容器：上下左右边距、弹性布局、圆角、半透明背景、最大宽高限制、滚动条、边框 */}
    <div className="relative flex flex-col gap-4 p-4 md:p-8 rounded-lg bg-card w-full max-w-[600px] overflow-auto border">
    {/* <div className="mt-4 mr-4 flex flex-col gap-4 p-4 md:p-8 rounded-lg bg-card w-full max-w-[600px] border-2 border-white/50"> */}
      {/* 标题栏：两端对齐布局 */}
      <div className="flex items-center justify-between space-y-0 pb-2">
        <h2 className="text-2xl font-bold">Trade</h2>
        <ChartCandlestick />
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
              type="number"
              value={totalinput}
              onChange={(e) => settotalinput(Number(e.target.value))}
              className="w-32 bg-black/20"
            />
          </div>
          <Button onClick={onClickButton} className="bg-blue-600 hover:bg-blue-700">
            Execute
          </Button>
          <Button onClick={onClickButton_close} className="bg-blue-600 hover:bg-blue-700">
            Close all position
          </Button>
          
        </div>
      </div>
    </div>
    </div>
  );
}
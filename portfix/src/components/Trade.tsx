import { useState } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
// import { TokenIcon } from '@web3icons/react'
import { Input } from "@/components/ui/input"


interface TradeCardProps {
    symbol: string;
    amount: number;
    totalAmount: number;
    leverageDefault: number;
    position: 'long' | 'short' | null;
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
                                <button className="flex-1 bg-green-600/80 hover:bg-green-600 text-white py-2 rounded-lg">
                                    Long
                                </button>
                                <button className="flex-1 bg-red-600/80 hover:bg-red-600 text-white py-2 rounded-lg">
                                    Short
                                </button>
                            </div>

                            <div className="flex items-center justify-between gap-4">
                                <div className="flex items-center gap-2 flex-1">
                                    <input
                                        type="text"
                                        placeholder="Amount"
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

export const Trade = () => {
    const [expandedCard, setExpandedCard] = useState<string | null>(null);

    const handleToggle = (symbol: string) => {
        setExpandedCard(expandedCard === symbol ? null : symbol);
    };

    // 定义卡片数据
    const cards = [
        {
            symbol: "ETH",
            amount: 4725,
            leverageDefault: 2,
            position: 'long' as const,
        },
        {
            symbol: "BTC",
            amount: 6150,
            leverageDefault: 1,
            position: 'short' as const,
        },
        {
            symbol: "APT",
            amount: 250,
            leverageDefault: 2,
            position: 'long' as const,
        },
        {
            symbol: "SUI",
            amount: 250,
            leverageDefault: 2,
            position: 'long' as const,
        },
        {
            symbol: "TRUMP",
            amount: 250,
            leverageDefault: 2,
            position: 'long' as const,
        },
        {
            symbol: "DOGE",
            amount: 250,
            leverageDefault: 2,
            position: 'long' as const,
        },
    ];

    // 计算总金额
    const totalAmount = cards.reduce((sum, card) => sum + card.amount, 0);
    const [inputAmount, setInputAmount] = useState(totalAmount.toString())

    // 按金额排序
    const sortedCards = [...cards].sort((a, b) => b.amount - a.amount);

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
                            value={inputAmount}
                            onChange={(e) => {
                                // 只允许输入数字和小数点
                                const value = e.target.value.replace(/[^\d.]/g, '')
                                setInputAmount(value)
                            }}
                            className="w-[100px] text-xl font-bold bg-transparent"
                        />
                        <span className="text-gray-400 text-xl">USDC</span>

                    </div>
                    <button
                        className="px-8 py-2 bg-blue-500 hover:bg-blue-600 text-white rounded-lg font-medium text-xl"
                        onClick={() => {
                            console.log('Confirmed with amount:', inputAmount)
                        }}
                    >
                        Confirm
                    </button>
                </div>
            </div>
        </div>
    );
};
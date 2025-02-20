import { useState } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

interface TradeCardProps {
    symbol: string;
    percent: number;
    leverageDefault: number;
    position: 'long' | 'short' | null;  // 新增 position 属性
    isExpanded: boolean;
    onToggle: () => void;
}

const TradeCard = ({ symbol, percent, leverageDefault, position, isExpanded, onToggle }: TradeCardProps) => {
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
                            {symbol.startsWith('ETH') ? '◆' : '₿'}
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

    // 定义卡片数据并按百分比排序
    const cards = [
        {
            symbol: "ETH",
            percent: 0.56,
            leverageDefault: 2.5,
            position: 'long',
        },
        {
            symbol: "BTC",
            percent: 0.44,
            leverageDefault: 1.5,
            position: 'short',
        },
        {
            symbol: "APT",
            percent: 0.01,
            leverageDefault: 1.5,
            position: 'long',
        },
        {
            symbol: "SUI",
            percent: 0.01,
            leverageDefault: 1.5,
            position: 'long',
        },
        {
            symbol: "TRUMP",
            percent: 0.01,
            leverageDefault: 1.5,
            position: 'long',
        },
        {
            symbol: "DOGE",
            percent: 0.01,
            leverageDefault: 1.5,
            position: 'long',
        },
    ].sort((a, b) => b.percent - a.percent); // 按百分比降序排序

    return (
        <div className="mt-4 mr-4 flex flex-col gap-4 p-4 md:p-8 rounded-lg bg-card w-full max-w-[600px] border-2 border-white/50">
            <div className="flex items-center justify-between">
                <h2 className="text-2xl font-bold">Trade</h2>
                <span className="text-blue-500">→</span>
            </div>
            <div className="space-y-2">
                {cards.map(card => (
                    <TradeCard
                        key={card.symbol}
                        symbol={card.symbol}
                        percent={card.percent}
                        leverageDefault={card.leverageDefault}
                        position={card.position as 'long' | 'short' | null}
                        isExpanded={expandedCard === card.symbol}
                        onToggle={() => handleToggle(card.symbol)}
                    />
                ))}
            </div>
        </div>
    );
};
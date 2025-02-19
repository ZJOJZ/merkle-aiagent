import { useState } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

interface TradeCardProps {
    symbol: string;
    contract: string;
    change24h: string;
    leverageDefault: number;
    aiAnalysis: string;
    isExpanded: boolean;
    onToggle: () => void;
}

const TradeCard = ({
    symbol,
    contract,
    change24h,
    leverageDefault,
    aiAnalysis,
    isExpanded,
    onToggle
}: TradeCardProps) => {
    return (
        <div className="border-4 border-white/50 rounded-lg bg-card overflow-hidden">
            <div
                className="flex items-center justify-between cursor-pointer p-4"
                onClick={onToggle}
            >
                <div className="flex items-center gap-2">
                    <span className={symbol.startsWith('ETH') ? 'text-blue-500' : 'text-orange-500'}>
                        {symbol.startsWith('ETH') ? '◆' : '₿'}
                    </span>
                    <span>{symbol}</span>
                    <span className="text-gray-400 text-sm">Contract: {contract}</span>
                </div>
                <div className="flex items-center gap-2">
                    <span className={change24h.startsWith('+') ? 'text-green-500' : 'text-red-500'}>
                        {change24h} (24h)
                    </span>
                    {isExpanded ? <ChevronUp size={20} /> : <ChevronDown size={20} />}
                </div>
            </div>

            <AnimatePresence initial={false}>
                {isExpanded && (
                    <motion.div
                        initial={{ height: 0 }}
                        animate={{ height: "auto" }}
                        exit={{ height: 0 }}
                        transition={{ duration: 0.3, ease: "easeInOut" }}
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

                            <div className="flex items-center gap-2">
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

                            <div className="space-y-2">
                                <div className="flex justify-between">
                                    <span>Leverage</span>
                                    <span>{leverageDefault}x</span>
                                </div>
                                <input
                                    type="range"
                                    min="1"
                                    max="5"
                                    defaultValue={leverageDefault}
                                    step="0.1"
                                    className="w-full accent-blue-500"
                                />
                            </div>

                            <div className="bg-black/20 p-3 rounded-lg border border-white/20">
                                <div className="flex items-center gap-2 mb-2">
                                    <span className="text-blue-500">AI Analysis</span>
                                </div>
                                <p className="text-sm text-gray-300">{aiAnalysis}</p>
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

    return (
        <div className="mt-4 mr-4 flex flex-col gap-4 p-4 md:p-8 rounded-lg bg-card w-full max-w-[600px] max-h-[800px] overflow-auto border-2 border-white/50">
            <div className="flex items-center justify-between">
                <h2 className="text-2xl font-bold">Trade</h2>
                <span className="text-blue-500">→</span>
            </div>
            <TradeCard
                symbol="ETH/USDC"
                contract="0x1234...5678"
                change24h="+2.4%"
                leverageDefault={2.5}
                aiAnalysis="Bullish momentum detected. Consider long position with 2x leverage based on recent price action and volume analysis."
                isExpanded={expandedCard === "ETH/USDC"}
                onToggle={() => handleToggle("ETH/USDC")}
            />
            <TradeCard
                symbol="BTC/USDC"
                contract="0xabcd...efgh"
                change24h="-1.2%"
                leverageDefault={1.5}
                aiAnalysis="Market showing consolidation. Recommended to wait for clear breakout before taking position."
                isExpanded={expandedCard === "BTC/USDC"}
                onToggle={() => handleToggle("BTC/USDC")}
            />
        </div>
    );
};
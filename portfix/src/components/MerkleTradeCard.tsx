import { Button } from "@/components/ui/button";
import { ChevronDown, ChevronUp } from 'lucide-react';
import { TokenIcon } from '@web3icons/react';
import { motion, AnimatePresence } from 'framer-motion';

/**
 * TradeCard组件属性接口定义
 */
export interface TradeCardProps {
  symbol: string;        // token符号
  amount: number;        // 交易金额
  totalAmount: number;   // 总交易金额
  leverageDefault: number; // 默认杠杆倍数
  position: string;      // 交易方向(long/short)
  isExpanded: boolean;   // 是否展开详情
  onToggle: () => void;  // 展开/收起回调函数
}

/**
 * TradeCard组件 - 展示单个交易对的卡片
 * 包含交易对信息、仓位方向、金额占比和详细信息
 */
export const MerkleTradeCard = ({ symbol, amount, totalAmount, leverageDefault, position, isExpanded, onToggle }: TradeCardProps) => {
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
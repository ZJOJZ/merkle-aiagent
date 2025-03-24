import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Slider } from "@/components/ui/slider";
import { ChevronDown, ChevronUp } from 'lucide-react';
import * as AntIcons from '@ant-design/web3-icons';
import { motion, AnimatePresence } from "motion/react";


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
  onAmountChange?: (amount: number) => void; // 金额修改回调函数
}

/**
 * TradeCard组件 - 展示单个交易对的卡片
 * 包含交易对信息、仓位方向、金额占比和详细信息
 */
export const MerkleTradeCard = ({ symbol, amount, totalAmount, leverageDefault, position, isExpanded, onToggle, onAmountChange }: TradeCardProps) => {
  // 计算当前交易金额占总金额的百分比
  const percent = totalAmount > 0 ? amount / totalAmount : 0;

  // 将symbol转换为AntDesign组件名称的映射函数
  const getIconComponentName = (symbol: string): string => {
    // 如果是eth，特殊处理为ethereum
    if (symbol.toLowerCase() === 'eth') {
      return 'EthereumCircleColorful';
    }
    const capitalizedSymbol = symbol.charAt(0).toUpperCase() + symbol.slice(1).toLowerCase();
    return `${capitalizedSymbol}CircleColorful`;
  };

  return (
    <Card className="overflow-hidden">
      <div className="relative">
        {/* 背景方块 */}
        <div
          className={`absolute h-full bg-opacity-20 ${position === 'long' ? 'bg-green-400' : 'bg-red-400' 
            }`}
          style={{ width: `${percent * 100}%` }}
        />

      <CardHeader className="relative py-4">
        <div className="flex items-center justify-between">
          {/* 交易对信息和图标 */}
          <div className="flex items-center gap-4">
            {(() => {
              const IconComponent = AntIcons[getIconComponentName(symbol) as keyof typeof AntIcons];
              return IconComponent ? <IconComponent style={{ fontSize: '32px' }} /> : null;
            })()}
            <div>
                <CardTitle className="text-lg">{symbol}</CardTitle>
                <CardDescription>
                  {position.toUpperCase()} · {Math.round(leverageDefault)}x
                </CardDescription>
            </div>
          </div>

          {/* 金额占比和展开/收起按钮 */}
          <div className="flex items-center gap-4">
            <span>{(percent * 100).toFixed(1)}%</span>
            <Button variant="ghost" size="icon" onClick={onToggle}>
              {isExpanded ? <ChevronUp size={20} /> : <ChevronDown size={20} />}
            </Button>
          </div>
        </div>
      </CardHeader>
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
          <CardContent className="space-y-6 pt-6">
            {/* Leverage Slider */}
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <span>Leverage</span>
                <span>{Math.round(leverageDefault)}x</span>
              </div>
              <Slider
                defaultValue={[leverageDefault]}
                max={150}
                min={3}
                step={1}
              />
            </div>

            {/* Amount */}
            <div className="space-y-2">
              <span>Amount</span>
              <div className="relative">
                <Input
                  type="number"
                  value={amount}
                  onChange={(e) => onAmountChange?.(Number(e.target.value))}
                  className="pr-16"
                />
                <div className="absolute inset-y-0 right-3 flex items-center pointer-events-none">
                  <span className="text-muted-foreground">USDC</span>
                </div>
              </div>
            </div>

            {/* Long & Short */}
            <div className="space-y-2">
              <div className="flex gap-3">
                <Button
                  className={`flex-1 ${position === 'long'
                    ? 'bg-green-600 hover:bg-green-700 text-white'
                    : 'bg-green-600/20 hover:bg-green-600/30 text-green-500'
                    } py-2`}
                >
                  Long
                </Button>
                <Button
                  className={`flex-1 ${position === 'short'
                  ? 'bg-red-600 hover:bg-red-700 text-white'
                  : 'bg-red-600/20 hover:bg-red-600/30 text-red-500'
                  } py-2`}
                >
                  Short
                </Button>
              </div>
            </div>
          </CardContent>
        </motion.div>
      )}
    </AnimatePresence>
  </Card>
  );
};
import { useState } from "react";
import { Button } from "./ui/button";
import { analyzeMarketChat } from "@/entry-functions/analyzeMarketChat";

// 定义支持的模型列表
const SUPPORTED_MODELS = [
  "Pro/deepseek-ai/DeepSeek-V3",
  "deepseek-ai/DeepSeek-V3",
  "Pro/deepseek-ai/DeepSeek-R1",
] as const;

type ModelType = (typeof SUPPORTED_MODELS)[number];

interface MarketAnalysisButtonProps {
  marketData: string;
  onAnalysisComplete?: (analysis: string) => void;
  className?: string;
}

export function MarketAnalysisButton({ marketData, onAnalysisComplete, className = "" }: MarketAnalysisButtonProps) {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const analyzeMarket = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const analysis = await analyzeMarketChat(marketData);
      if (analysis && onAnalysisComplete) {
        onAnalysisComplete(analysis);
      }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : "分析过程中发生错误";
      setError(errorMessage);
      console.error("市场分析错误:", err);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex flex-col gap-2">
      <Button onClick={analyzeMarket} disabled={isLoading} className={className}>
        {isLoading ? "分析中..." : "分析市场"}
      </Button>
      {error && <div className="text-red-500 text-sm mt-2">错误: {error}</div>}
    </div>
  );
}

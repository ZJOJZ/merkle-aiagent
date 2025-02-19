import OpenAI from "openai";

const getClient = () => {
  const apiKey = process.env.NEXT_PUBLIC_SILICONFLOW_API_KEY;
  if (!apiKey) {
    throw new Error("API Key 未配置");
  }
  return new OpenAI({
    baseURL: "https://api.siliconflow.cn/v1/",
    apiKey: apiKey,
    dangerouslyAllowBrowser: true,
  });
};

const SUPPORTED_MODELS = [
  "Pro/deepseek-ai/DeepSeek-V3",
  "deepseek-ai/DeepSeek-V3",
  "Pro/deepseek-ai/DeepSeek-R1",
  "deepseek-ai/DeepSeek-R1-Distill-Qwen-32B"
] as const;

type ModelType = (typeof SUPPORTED_MODELS)[number];

export async function analyzeMarketChat(marketData: string): Promise<string> {
  const client = getClient();
  const messages = [
    {
      role: "user" as const,
      content: `请作为一个专业的市场分析师，分析以下市场数据并提供见解：
      ${marketData}
      
      请从以下几个方面进行分析：
      1. 市场总体趋势
      2. 主要风险点
      3. 投资机会
      4. 建议操作策略
      
      请确保分析简洁明了，重点突出。`,
    },
  ];

  const response = await client.chat.completions.create({
    model: "deepseek-ai/DeepSeek-R1-Distill-Qwen-32B" as ModelType,
    messages: messages,
    stream: false,
    max_tokens: 4096,
  });

  return response.choices[0].message.content || "无分析结果";
}

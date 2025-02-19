import OpenAI from "openai";
import { NextResponse } from "next/server";
import { StreamingTextResponse } from "ai";

interface Position {
  symbol: string; // 币种符号
  size: number; // 当前仓位大小
  leverage: number; // 当前杠杆倍数
  direction: "long" | "short" | "none"; // 当前持仓方向
  entryPrice?: number; // 入场价格
}

interface MarketData {
  symbol: string; // 币种符号
  price: number; // 当前价格
  volume24h: number; // 24小时成交量
  priceChange24h: number; // 24小时价格变化百分比
  additionalInfo?: string; // 其他市场信息
}

// 定义支持的模型列表
const SUPPORTED_MODELS = [
  "Pro/deepseek-ai/DeepSeek-V3", // Pro V3 作为默认
  "deepseek-ai/DeepSeek-V3",
  "Pro/deepseek-ai/DeepSeek-R1",
  "deepseek-ai/DeepSeek-R1",
  "Pro/deepseek-ai/DeepSeek-R1-Distill-Llama-8B",
  "Pro/deepseek-ai/DeepSeek-R1-Distill-Qwen-7B",
  "Pro/deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B",
  "deepseek-ai/DeepSeek-R1-Distill-Llama-70B",
  "deepseek-ai/DeepSeek-R1-Distill-Qwen-32B",
  "deepseek-ai/DeepSeek-R1-Distill-Qwen-14B",
] as const;

type ModelType = (typeof SUPPORTED_MODELS)[number];

interface PortfolioRequest {
  positions: Position[]; // 当前持仓情况
  marketData: MarketData[]; // 市场数据
  totalEquity: number; // 总资金
  riskTolerance: "low" | "medium" | "high"; // 风险承受能力
  stream?: boolean; // 是否流式输出
  model?: ModelType; // 添加模型选择
}

interface TradeAction {
  symbol: string;
  action: "open" | "close" | "adjust";
  direction: "long" | "short";
  leverage: number;
  size: number;
  reason: string;
  priority: number; // 1-5，1最高
}

const client = new OpenAI({
  baseURL: "https://api.siliconflow.cn/v1/",
  apiKey: process.env.SILICONFLOW_API_KEY,
});

// 添加一个解析函数来处理响应
function parseModelResponse(content: string): string {
  // 移除 markdown 代码块标记
  const jsonMatch = content.match(/```json\n([\s\S]*?)\n```/);
  if (jsonMatch) {
    return jsonMatch[1].trim();
  }

  // 如果没有 markdown 标记，尝试直接解析
  const possibleJson = content.trim();
  if (possibleJson.startsWith("{") && possibleJson.endsWith("}")) {
    return possibleJson;
  }

  throw new Error("无法从响应中提取有效的 JSON");
}

export async function POST(request: Request) {
  try {
    const {
      positions,
      marketData,
      totalEquity,
      riskTolerance,
      stream = false,
      model = "Pro/deepseek-ai/DeepSeek-V3", // 默认使用 Pro V3
    } = (await request.json()) as PortfolioRequest;

    if (!positions || !marketData || !totalEquity || !riskTolerance) {
      return NextResponse.json({ error: "缺少必要参数" }, { status: 400 });
    }

    // 验证模型是否支持
    if (!SUPPORTED_MODELS.includes(model as ModelType)) {
      return NextResponse.json(
        {
          error: "不支持的模型",
          supportedModels: SUPPORTED_MODELS,
        },
        { status: 400 }
      );
    }

    const prompt = `
      作为一个专业的加密货币投资组合管理专家，请分析以下信息并提供详细的投资组合优化建议：

      当前总资金: ${totalEquity} USDT
      风险承受能力: ${riskTolerance}

      当前持仓情况:
      ${positions
        .map(
          (p) => `
        币种: ${p.symbol}
        方向: ${p.direction}
        仓位大小: ${p.size} USDT
        杠杆倍数: ${p.leverage}x
        ${p.entryPrice ? `入场价格: ${p.entryPrice}` : ""}
      `
        )
        .join("\n")}

      市场数据:
      ${marketData
        .map(
          (m) => `
        币种: ${m.symbol}
        当前价格: ${m.price}
        24h成交量: ${m.volume24h}
        24h价格变化: ${m.priceChange24h}%
        附加信息: ${m.additionalInfo || "无"}
      `
        )
        .join("\n")}

      请提供以下分析并严格按照JSON格式输出，不要包含任何其他文字说明：
      {
        "actions": [
          {
            "symbol": "币种符号",
            "action": "操作类型(open/close/adjust)",
            "direction": "long/short",
            "leverage": 数字格式的建议杠杆倍数,
            "size": 数字格式的仓位大小,
            "expectedReturn": "预期收益",
            "stopLoss": 数字格式的止损价格
          }
        ]
      }

      请确保：
      1. 输出必须是有效的JSON格式
      2. 所有数值必须是数字而不是字符串
      3. 不要添加任何额外的markdown或文字说明
      4. 确保JSON格式的正确性，包括正确的引号和逗号使用
    `;

    if (stream) {
      const response = await client.chat.completions.create({
        model: model as ModelType, // 使用选择的模型
        messages: [{ role: "user", content: prompt }],
        stream: true,
        max_tokens: 4096,
      });

      const stream = new ReadableStream({
        async start(controller) {
          for await (const chunk of response) {
            const content = chunk.choices[0]?.delta?.content || "";
            if (content) {
              controller.enqueue(new TextEncoder().encode(content));
            }
          }
          controller.close();
        },
      });

      return new StreamingTextResponse(stream);
    } else {
      const response = await client.chat.completions.create({
        model: model as ModelType,
        messages: [{ role: "user", content: prompt }],
        stream: false,
        max_tokens: 4096,
      });

      try {
        const content = response.choices[0].message.content;
        // 使用解析器处理响应
        const jsonString = parseModelResponse(content);
        const result = JSON.parse(jsonString);

        // 验证返回的 JSON 结构
        if (!result.actions && !result.marketAnalysis) {
          throw new Error("Invalid JSON structure");
        }

        // 处理可能的不同响应结构
        let processedActions = [];
        if (result.actions && Array.isArray(result.actions)) {
          processedActions = result.actions.map((action) => ({
            ...action,
            leverage: Number(action.leverage),
            size: Number(action.size),
            priority: Number(action.priority),
            stopLoss: Number(action.stopLoss),
          }));
        } else if (result.marketAnalysis) {
          // 处理单个分析结果
          processedActions = [
            {
              ...result.marketAnalysis,
              leverage: Number(result.marketAnalysis.leverage),
              size: Number(result.marketAnalysis.size),
              priority: Number(result.marketAnalysis.priority),
              stopLoss: Number(result.marketAnalysis.stopLoss),
            },
          ];
        }

        return NextResponse.json({
          riskAssessment: result.riskAssessment,
          marketAnalysis: result.marketAnalysis,
          summary: result.summary,
          actions: processedActions,
          model: model,
          timestamp: new Date().toISOString(),
        });
      } catch (e) {
        return NextResponse.json(
          {
            error: "解析响应失败，无法生成有效的 JSON",
            rawContent: response.choices[0].message.content,
            parsedContent: content ? parseModelResponse(content) : null,
            model: model,
            timestamp: new Date().toISOString(),
          },
          { status: 422 }
        );
      }
    }
  } catch (error: any) {
    console.error("投资组合分析错误:", error);
    return NextResponse.json(
      {
        error: error instanceof Error ? error.message : "发生错误",
        status: "error",
      },
      { status: 500 }
    );
  }
}

import OpenAI from "openai";
import { NextResponse } from "next/server";
import { StreamingTextResponse } from "ai";

// 定义支持的模型列表
const SUPPORTED_MODELS = [
  "Pro/deepseek-ai/DeepSeek-V3",
  "deepseek-ai/DeepSeek-V3",
  "Pro/deepseek-ai/DeepSeek-R1",
  "deepseek-ai/DeepSeek-R1",
  "deepseek-ai/DeepSeek-R1-Distill-Llama-70B",
  "deepseek-ai/DeepSeek-R1-Distill-Qwen-32B",
  "deepseek-ai/DeepSeek-R1-Distill-Qwen-14B",
  "deepseek-ai/DeepSeek-R1-Distill-Llama-8B",
  "deepseek-ai/DeepSeek-R1-Distill-Qwen-7B",
  "deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B",
  "Pro/deepseek-ai/DeepSeek-R1-Distill-Llama-8B",
  "Pro/deepseek-ai/DeepSeek-R1-Distill-Qwen-7B",
  "Pro/deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B",
] as const;

type ModelType = (typeof SUPPORTED_MODELS)[number];

// 初始化 OpenAI 客户端
const client = new OpenAI({
  baseURL: "https://api.siliconflow.cn/v1/",
  apiKey: process.env.SILICONFLOW_API_KEY,
});

export async function POST(request: Request) {
  try {
    const {
      marketData,
      model = "Pro/deepseek-ai/DeepSeek-V3",
      stream = false,
    } = await request.json();

    if (!marketData) {
      return NextResponse.json({ error: "需要提供市场数据" }, { status: 400 });
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

    const messages = [
      {
        role: "user",
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

    if (stream) {
      // 流式响应
      const response = await client.chat.completions.create({
        model: model as ModelType,
        messages: messages,
        stream: true,
        max_tokens: 4096,
      });

      // 创建一个 ReadableStream
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
      // 非流式响应
      const response = await client.chat.completions.create({
        model: model as ModelType,
        messages: messages,
        stream: false,
        max_tokens: 4096,
      });

      return NextResponse.json({
        analysis: response.choices[0].message.content,
        model: model,
      });
    }
  } catch (error: any) {
    console.error("分析请求错误:", error);
    return NextResponse.json(
      {
        error: error instanceof Error ? error.message : "发生错误",
        status: "error",
      },
      { status: 500 }
    );
  }
}

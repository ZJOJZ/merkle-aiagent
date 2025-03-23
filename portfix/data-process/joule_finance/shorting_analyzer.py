import json
import os
import time
from datetime import datetime
from typing import Dict, List, Any, Callable, Optional
import logging
from openai import OpenAI
from Joule_Finance_MarketAnalyzer import (
    Joule_Finance_MarketAnalyzer,
    Binance_MarketAnalyzer,
)

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


class ShortingAnalyzer:
    def __init__(
        self,
        output_file: str = "output/shorting_actions.jsonl",
        api_key: Optional[str] = None,
        model: str = "deepseek-chat",
        base_url: str = "https://api.deepseek.com",
        investment_hours: int = 24,  # Default investment period: 24 hours
    ):
        """
        Initialize the shorting analyzer

        Args:
            output_file: Path to output JSONL file
            api_key: API key
            model: Model name
            base_url: API base URL
            investment_hours: Investment period in hours
        """
        self.output_file = output_file
        self.investment_hours = investment_hours

        # Initialize OpenAI client
        if not api_key:
            api_key = os.environ.get("DEEPSEEK_API_KEY")
            if not api_key:
                raise ValueError(
                    "API key must be provided directly or via DEEPSEEK_API_KEY environment variable"
                )

        self.client = OpenAI(api_key=api_key, base_url=base_url)
        self.model = model
        self.joule_analyzer = Joule_Finance_MarketAnalyzer()

        # Create output directory
        os.makedirs(os.path.dirname(os.path.abspath(output_file)), exist_ok=True)

        logger.info(
            f"Shorting analyzer initialized. Output will be saved to {output_file}"
        )

    def calculate_expected_profit(
        self,
        current_price: float,
        target_price: float,
        funding_rate: float,
        borrow_rate: float,
        investment_hours: int,
    ) -> float:
        """
        计算预期收益

        Args:
            current_price: 当前价格
            target_price: 目标价格
            funding_rate: 资金费率（年化）
            borrow_rate: 借贷利率（年化）
            investment_hours: 投资时间（小时）

        Returns:
            预期收益百分比
        """
        # 计算价格下跌收益
        price_change_percentage = (current_price - target_price) / current_price * 100

        # 计算资金费率收益（年化转小时）
        funding_rate_hourly = funding_rate / (365 * 24)
        funding_profit = funding_rate_hourly * investment_hours

        # 计算借贷成本（年化转小时）
        borrow_rate_hourly = borrow_rate / (365 * 24)
        borrow_cost = borrow_rate_hourly * investment_hours

        # 总收益 = 价格下跌收益 + 资金费率收益 - 借贷成本
        total_profit = price_change_percentage + funding_profit - borrow_cost

        return round(total_profit, 2)

    def analyze_shorting_opportunities(
        self, market_data: List[Dict[str, Any]]
    ) -> Dict[str, Any]:
        """
        分析做空机会并生成交易建议

        Args:
            market_data: 市场数据列表

        Returns:
            包含交易建议的字典
        """
        # 准备提示词
        prompt = self._prepare_prompt(market_data)

        try:
            # 调用大模型生成交易建议
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "system",
                        "content": "你是一个专业的做空交易分析专家。分析市场数据并提供做空建议，包括目标价格和仓位分配。",
                    },
                    {"role": "user", "content": prompt},
                ],
                response_format={"type": "json_object"},
                max_tokens=2048,
                temperature=0.2,
            )

            # 解析响应
            content = response.choices[0].message.content
            if not content:
                logger.warning("从LLM收到空响应")
                return {"actions": [], "timestamp": datetime.now().isoformat()}

            result = json.loads(content)

            # 确保包含时间戳
            if "timestamp" not in result:
                result["timestamp"] = datetime.now().isoformat()

            # 验证仓位百分比
            if "actions" in result:
                total_percentage = sum(
                    action.get("position_percentage", 0) for action in result["actions"]
                )
                if total_percentage != 100 and result["actions"]:
                    logger.warning(
                        f"总仓位百分比为 {total_percentage}%，正在调整为100%"
                    )
                    # 归一化百分比
                    for action in result["actions"]:
                        if "position_percentage" in action and total_percentage > 0:
                            action["position_percentage"] = round(
                                action["position_percentage"] / total_percentage * 100,
                                2,
                            )

            return result

        except Exception as e:
            logger.error(f"生成做空建议时出错: {str(e)}")
            return {
                "actions": [],
                "error": str(e),
                "timestamp": datetime.now().isoformat(),
            }

    def _prepare_prompt(self, market_data: List[Dict[str, Any]]) -> str:
        """
        Prepare the prompt for analysis

        Args:
            market_data: List of market data

        Returns:
            Prompt string
        """
        market_data_str = json.dumps(market_data, indent=2)
        current_time = datetime.now().isoformat()

        prompt = f"""
Analyze the following market data and select 1-3 most valuable cryptocurrencies for shorting:

Market Data:
{market_data_str}

Based on this market data, select 1-3 cryptocurrencies with the highest shorting potential.
Your response must be a valid JSON object with the following structure:

```json
{{
  "actions": [
    {{
      "symbol": "BTC",
      "current_price": 50000,
      "target_price": 45000,  // Target price after {self.investment_hours} hours
      "position_percentage": 60,  // Position percentage (0-100)
      "reason": "Technical indicators show downward trend, negative funding rate, bearish market sentiment",
      "risk_level": "medium",  // low, medium, high
      "funding_rate": 5.2,  // Annual funding rate
      "borrow_rate": 3.1,  // Annual borrowing rate
      "price_change_percentage": 10,  // Expected price drop percentage
      "funding_profit": 0.5,  // Funding rate profit
      "borrow_cost": 0.3,  // Borrowing cost
      "expected_profit_percentage": 10.2  // Total expected profit percentage
    }},
    // Add up to 2 more cryptocurrencies
  ],
  "timestamp": "{current_time}"
}}
```

Important requirements:
1. Select only 1-3 cryptocurrencies with the highest shorting potential
2. Analyze technical indicators, funding rates, and market trends for each
3. Predict target price after {self.investment_hours} hours
4. Allocate position percentages, must sum to 100%
5. Provide detailed reasoning for shorting recommendations
6. Assess risk level
7. Calculate and include:
   - Annual funding rate
   - Annual borrowing rate
   - Expected price drop percentage
   - Funding rate profit
   - Borrowing cost
   - Total expected profit percentage
8. Include current timestamp

Return only the JSON object without any additional text.
"""
        return prompt

    def process_market_data(self, get_market_data: Callable[[], List[Dict[str, Any]]]):
        """
        持续处理市场数据并生成做空建议

        Args:
            get_market_data: 获取市场数据的回调函数
        """
        while True:
            try:
                # 获取市场数据
                market_data = get_market_data()

                if not market_data:
                    logger.warning("收到空的市场数据")
                    time.sleep(5)
                    continue

                # 生成做空建议
                actions_data = self.analyze_shorting_opportunities(market_data)

                # 添加时间戳
                if "timestamp" not in actions_data:
                    actions_data["timestamp"] = datetime.now().isoformat()

                # 保存到JSONL文件
                self._save_to_jsonl(actions_data)

                logger.info(
                    f"已生成{len(actions_data.get('actions', []))}个交易对的做空建议"
                )

            except Exception as e:
                logger.error(f"处理循环中出错: {str(e)}")

            time.sleep(300)  # 每5分钟检查一次

    def _save_to_jsonl(self, data: Dict[str, Any]):
        """
        Save data to JSONL file

        Args:
            data: Data to save
        """
        try:
            if "timestamp" not in data:
                data["timestamp"] = datetime.now().isoformat()

            if "actions" in data:
                # Only process actions with positions
                active_actions = [
                    action
                    for action in data["actions"]
                    if action.get("position_percentage", 0) > 0
                ]

                for action in active_actions:
                    # Calculate expected profit
                    expected_profit = self.calculate_expected_profit(
                        current_price=action.get("current_price", 0),
                        target_price=action.get("target_price", 0),
                        funding_rate=action.get("funding_rate", 0),
                        borrow_rate=action.get("borrow_rate", 0),
                        investment_hours=self.investment_hours,
                    )

                    # Update expected profit
                    action["expected_profit_percentage"] = expected_profit

                    logger.info(
                        f"Symbol: {action.get('symbol')}, "
                        f"Current Price: {action.get('current_price')}, "
                        f"Target Price: {action.get('target_price')}, "
                        f"Position: {action.get('position_percentage')}%, "
                        f"Funding Rate: {action.get('funding_rate')}%, "
                        f"Borrow Rate: {action.get('borrow_rate')}%, "
                        f"Expected Profit: {expected_profit}%"
                    )

            with open(self.output_file, "a") as f:
                f.write(json.dumps(data) + "\n")

            logger.info(
                f"Shorting recommendations saved to {self.output_file} at {data['timestamp']}"
            )
        except Exception as e:
            logger.error(f"Error saving to JSONL file: {str(e)}")


def get_joule_market_data():
    """获取Joule Finance市场数据的示例函数"""
    joule_analyzer = Joule_Finance_MarketAnalyzer()
    binance_analyzer = Binance_MarketAnalyzer()

    # 获取Joule Finance数据
    joule_data = joule_analyzer.fetch_market_data()
    # 获取币安数据
    binance_data = binance_analyzer.analyze_market("BTC")  # 获取BTC的数据作为示例

    # 合并数据
    merged_data = []
    for symbol in joule_data["symbol"].unique():
        joule_info = (
            joule_data[joule_data["symbol"] == symbol].iloc[0]
            if not joule_data[joule_data["symbol"] == symbol].empty
            else None
        )

        if joule_info is not None:
            # 获取对应币种的币安数据
            binance_info = (
                binance_analyzer.analyze_market(symbol)
                if symbol in ["BTC", "ETH", "APT"]
                else None
            )

            merged_data.append(
                {
                    "symbol": symbol,
                    "price": float(joule_info["price"]),
                    "ltv": float(joule_info["ltv"]),
                    "marketSize": float(joule_info["marketSize"]),
                    "totalBorrowed": float(joule_info["totalBorrowed"]),
                    "borrowApy": float(joule_info["borrowApy"]),
                    "depositApy": float(joule_info["depositApy"]),
                    "liquidationFactor": float(joule_info["liquidationFactor"]),
                    "technical_analysis": (
                        binance_info.get("summary", "") if binance_info else ""
                    ),
                    "binance_price": (
                        binance_info.get("current_price", 0) if binance_info else 0
                    ),
                    **{
                        k: v
                        for k, v in (binance_info or {}).items()
                        if k not in ["summary", "current_price"]
                    },
                }
            )

    return merged_data


if __name__ == "__main__":
    # Initialize analyzer
    analyzer = ShortingAnalyzer(
        output_file="output/shorting_actions.jsonl",
        api_key=os.environ.get("DEEPSEEK_API_KEY"),
        investment_hours=24,  # Set 24-hour investment period
    )

    # Process market data
    analyzer.process_market_data(get_joule_market_data)

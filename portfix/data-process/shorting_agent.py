import json
import os
import time
from datetime import datetime
from typing import Dict, List, Any, Callable, Optional, Tuple
import logging
from openai import OpenAI

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


class ShortingAgent:
    """
    Shorting agent that processes market data and funding rates to automatically
    identify cryptocurrencies that are likely to decrease in value.

    This agent supports two main operations:
    1. borrow - Borrow assets to short (paying funding rate)
    2. repay_borrow - Repay borrowed assets (buying back at lower price)

    The agent makes decisions based on:
    - Current market data (price, volatility, trends, technical indicators)
    - Current funding rates
    - Risk tolerance settings
    - Price prediction models
    - Current active short positions

    Usage:
        agent = ShortingAgent(
            output_file="path/to/output.jsonl",
            api_key="your_api_key",
            risk_tolerance="medium",  # low, medium, high
            max_short_percentage=50.0,
            min_expected_decline=5.0  # Minimum expected price decline (%)
        )

        # Get shorting actions based on current market conditions
        actions = agent.generate_shorting_actions(
            market_data,
            funding_rates,
            portfolio_value
        )

        # Find the best shorting opportunities
        opportunities = agent.get_shorting_opportunities(
            market_data,
            funding_rates
        )

        # Continuous processing
        agent.process_market_data(
            get_market_data_function,
            get_funding_rates_function,
            get_portfolio_value_function,
            interval=3600  # Check hourly
        )
    """

    def __init__(
        self,
        output_file: str = "portfolio_generator/output/shorting_actions.jsonl",
        api_key: Optional[str] = None,
        model: str = "deepseek-chat",
        base_url: str = "https://api.deepseek.com",
        risk_tolerance: str = "medium",  # low, medium, high
        max_short_percentage: float = 50.0,  # Maximum percentage of portfolio to short
        min_expected_decline: float = 5.0,  # Minimum expected price decline (%)
    ):
        """
        Initialize the shorting agent.

        Args:
            output_file: Path to the output JSONL file
            api_key: API key for the LLM service
            model: Model name to use
            base_url: Base URL for the API
            risk_tolerance: Risk tolerance level (low, medium, high)
            max_short_percentage: Maximum percentage of portfolio value to use for shorting
            min_expected_decline: Minimum expected price decline to consider shorting (%)
        """
        self.output_file = output_file
        self.risk_tolerance = risk_tolerance
        self.max_short_percentage = max_short_percentage
        self.min_expected_decline = min_expected_decline

        # Track current short positions
        self.active_positions = {
            "shorts": {},  # {symbol: {"amount": float, "entry_price": float, "target_price": float, "funding_rate": float, "timestamp": str}}
        }

        # Initialize OpenAI client
        if not api_key:
            # Try to get API key from environment variable
            api_key = os.environ.get("DEEPSEEK_API_KEY")
            if not api_key:
                raise ValueError(
                    "API key must be provided either directly or via DEEPSEEK_API_KEY environment variable"
                )

        self.client = OpenAI(api_key=api_key, base_url=base_url)
        self.model = model

        # Create output directory if it doesn't exist
        os.makedirs(os.path.dirname(os.path.abspath(output_file)), exist_ok=True)

        logger.info(
            f"Shorting agent initialized. Output will be saved to {output_file}"
        )

    def generate_shorting_actions(
        self,
        market_data: List[Dict[str, Any]],
        funding_rates: Dict[str, float],
        portfolio_value: float,
        current_positions: Optional[Dict[str, Dict[str, Any]]] = None,
    ) -> Dict[str, Any]:
        """
        Generate shorting actions based on market data and funding rates.

        Args:
            market_data: List of market data for different symbols
            funding_rates: Dictionary mapping symbols to their funding rates
            portfolio_value: Total portfolio value in USD
            current_positions: Current shorting positions

        Returns:
            Dict containing shorting actions with timestamp
        """
        if current_positions is not None:
            self.active_positions = current_positions

        # Prepare the prompt for the LLM
        prompt = self._prepare_prompt(market_data, funding_rates, portfolio_value)

        try:
            # Call the LLM to generate shorting actions
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "system",
                        "content": "You are a professional crypto shorting agent. Analyze the market data and funding rates to identify coins likely to decline in value. Provide optimal shorting actions in JSON format.",
                    },
                    {"role": "user", "content": prompt},
                ],
                response_format={"type": "json_object"},
                max_tokens=2048,
                temperature=0.2,
            )

            # Extract and parse the response
            content = response.choices[0].message.content
            if not content:
                logger.warning("Received empty content from LLM")
                return {"actions": [], "timestamp": datetime.now().isoformat()}

            result = json.loads(content)

            # Ensure timestamp is included
            if "timestamp" not in result:
                result["timestamp"] = datetime.now().isoformat()

            # Validate actions and add any post-processing logic
            if "actions" in result:
                for action in result["actions"]:
                    # Ensure action has all required fields
                    required_fields = [
                        "symbol",
                        "action_type",
                        "amount",
                        "current_price",
                        "target_price",
                        "reason",
                    ]
                    for field in required_fields:
                        if field not in action:
                            logger.warning(f"Action missing required field: {field}")
                            action[field] = (
                                ""
                                if field == "reason"
                                else "unknown" if field == "symbol" else 0
                            )

                    # Validate action type
                    valid_actions = ["borrow", "repay_borrow"]
                    if action["action_type"] not in valid_actions:
                        logger.warning(
                            f"Invalid action type: {action['action_type']}, defaulting to 'borrow'"
                        )
                        action["action_type"] = "borrow"

            # Update active positions based on actions
            self._update_positions(result.get("actions", []), portfolio_value)

            return result

        except Exception as e:
            logger.error(f"Error generating shorting actions: {str(e)}")
            return {
                "actions": [],
                "error": str(e),
                "timestamp": datetime.now().isoformat(),
            }

    def _update_positions(self, actions: List[Dict[str, Any]], portfolio_value: float):
        """
        Update active positions based on new actions.

        Args:
            actions: List of shorting actions
            portfolio_value: Total portfolio value for validation
        """
        for action in actions:
            symbol = action["symbol"]
            action_type = action["action_type"]
            amount = action["amount"]
            current_price = action.get("current_price", 0)
            target_price = action.get("target_price", 0)
            funding_rate = action.get("funding_rate", 0)

            # Handle different action types
            if action_type == "borrow":
                if symbol not in self.active_positions["shorts"]:
                    self.active_positions["shorts"][symbol] = {
                        "amount": amount,
                        "entry_price": current_price,
                        "target_price": target_price,
                        "funding_rate": funding_rate,
                        "timestamp": datetime.now().isoformat(),
                    }
                else:
                    # Update existing position with weighted average
                    existing = self.active_positions["shorts"][symbol]
                    total_amount = existing["amount"] + amount
                    existing["entry_price"] = (
                        (existing["entry_price"] * existing["amount"])
                        + (current_price * amount)
                    ) / total_amount
                    existing["amount"] = total_amount
                    # Update target price if lower
                    if target_price < existing["target_price"]:
                        existing["target_price"] = target_price
                    existing["funding_rate"] = funding_rate  # Use latest funding rate

            elif action_type == "repay_borrow":
                if symbol in self.active_positions["shorts"]:
                    current_amount = self.active_positions["shorts"][symbol]["amount"]
                    new_amount = max(0, current_amount - amount)

                    # Calculate profit/loss
                    entry_price = self.active_positions["shorts"][symbol]["entry_price"]
                    profit = (entry_price - current_price) * amount

                    logger.info(
                        f"Closed short position for {symbol}: {amount} units. Profit: ${profit:.2f}"
                    )

                    if new_amount == 0:
                        del self.active_positions["shorts"][symbol]
                    else:
                        self.active_positions["shorts"][symbol]["amount"] = new_amount
                else:
                    logger.warning(
                        f"Attempted to repay borrowing for {symbol} but no active position exists"
                    )

        # Validate total shorting doesn't exceed max percentage
        total_short_value = sum(
            pos["amount"] * pos["entry_price"]
            for pos in self.active_positions["shorts"].values()
        )
        if total_short_value > portfolio_value * (self.max_short_percentage / 100):
            logger.warning(
                f"Total shorting exceeds maximum allowed percentage of portfolio value"
            )

    def _prepare_prompt(
        self,
        market_data: List[Dict[str, Any]],
        funding_rates: Dict[str, float],
        portfolio_value: float,
    ) -> str:
        """
        Prepare the prompt for the LLM.

        Args:
            market_data: List of market data for different symbols
            funding_rates: Dictionary mapping symbols to their funding rates
            portfolio_value: Total portfolio value in USD

        Returns:
            Prompt string
        """
        market_data_str = json.dumps(market_data, indent=2)
        funding_rates_str = json.dumps(funding_rates, indent=2)
        active_positions_str = json.dumps(self.active_positions, indent=2)
        current_time = datetime.now().isoformat()

        prompt = f"""
分析以下加密货币市场数据、资金费率和当前空头头寸，选择最适合做空的币种：

市场数据:
{market_data_str}

资金费率:
{funding_rates_str}

当前头寸:
{active_positions_str}

投资组合价值: ${portfolio_value}
风险容忍度: {self.risk_tolerance}

根据这些信息，生成做空操作建议。 
你的响应必须是包含以下结构的有效JSON对象：

```json
{{
  "actions": [
    {{
      "symbol": "BTC",
      "action_type": "borrow",  // borrow（借出做空）或 repay_borrow（平仓）
      "amount": 0.5,  // 资产数量
      "current_price": 50000,  // 当前价格
      "target_price": 45000,  // 目标买回价格
      "funding_rate": 0.01,  // 资金费率
      "expected_decline": 10.0,  // 预期价格下跌百分比
      "reason": "技术指标显示超买状态，高阻力位附近，预期回调"
    }},
    // 更多币种的操作
  ],
  "market_analysis": "整体市场分析，解释做空策略",
  "risk_assessment": "当前做空风险评估",
  "timestamp": "{current_time}"
}}
```

重要要求:
1. 重点关注有低资金费率和预期价格下跌的币种
2. 考虑市场波动性和趋势进行做空决策
3. 对于高波动性资产，做空策略应更加保守
4. 均衡投资组合，避免过度暴露于单一资产
5. 总做空额度不应超过投资组合价值的{self.max_short_percentage}%
6. 对每个操作都要有简要的理由说明
7. 提供整体市场分析和风险评估
8. 在响应中包含当前时间戳

做空决策建议:
- 寻找资金费率低且技术指标显示可能下跌的资产
- 考虑做空处于上涨通道末端的资产
- 注意识别超买状态、看跌背离等做空信号
- 为每个建议的做空操作提供合理的目标价格（买回价格）
- 避免做空处于强势上涨趋势中的资产
- 对于每个做空建议，要预估可能的最低价格点

只返回JSON对象，不要添加任何额外文本。
"""
        return prompt

    def process_market_data(
        self,
        get_market_data: Callable[[], List[Dict[str, Any]]],
        get_funding_rates: Callable[[], Dict[str, float]],
        get_portfolio_value: Callable[[], float],
        interval: int = 3600,  # Default to checking hourly
    ):
        """
        Continuously process market data and generate shorting actions.

        Args:
            get_market_data: Callback function that returns market data
            get_funding_rates: Callback function that returns funding rates
            get_portfolio_value: Callback function that returns total portfolio value
            interval: Time interval between checks in seconds
        """
        while True:
            try:
                # Get market data and rates from callbacks
                market_data = get_market_data()
                funding_rates = get_funding_rates()
                portfolio_value = get_portfolio_value()

                if not market_data or not funding_rates:
                    logger.warning("Received empty data")
                    time.sleep(5)  # Wait before retrying
                    continue

                # Generate shorting actions
                actions_data = self.generate_shorting_actions(
                    market_data, funding_rates, portfolio_value
                )

                # Add timestamp if not present
                if "timestamp" not in actions_data:
                    actions_data["timestamp"] = datetime.now().isoformat()

                # Save to JSONL file
                self._save_to_jsonl(actions_data)

                logger.info(
                    f"Generated shorting actions for {len(actions_data.get('actions', []))} symbols"
                )

            except Exception as e:
                logger.error(f"Error in processing loop: {str(e)}")

            # Wait before next iteration
            time.sleep(interval)

    def _save_to_jsonl(self, data: Dict[str, Any]):
        """
        Save data to JSONL file.

        Args:
            data: Data to save
        """
        try:
            # Ensure timestamp is included before saving
            if "timestamp" not in data:
                data["timestamp"] = datetime.now().isoformat()

            # Log the actions
            if "actions" in data:
                for action in data["actions"]:
                    if action.get("action_type") == "borrow":
                        logger.info(
                            f"币种: {action.get('symbol')}, 目标赎回价格: ${action.get('target_price', 0):.2f}, "
                            f"当前价格: ${action.get('current_price', 0):.2f}, 预期下跌: {action.get('expected_decline', 0):.1f}%"
                        )
                    else:
                        logger.info(
                            f"币种: {action.get('symbol')}, 操作: 平仓, 数量: {action.get('amount')}, 当前价格: ${action.get('current_price', 0):.2f}"
                        )

            with open(self.output_file, "a") as f:
                f.write(json.dumps(data) + "\n")

            logger.info(
                f"做空策略已保存到 {self.output_file}, 时间: {data['timestamp']}"
            )
        except Exception as e:
            logger.error(f"保存到JSONL文件时出错: {str(e)}")

    def get_shorting_opportunities(
        self,
        market_data: List[Dict[str, Any]],
        funding_rates: Dict[str, float],
    ) -> List[Dict[str, Any]]:
        """
        Identify the best shorting opportunities.

        Args:
            market_data: List of market data for different symbols
            funding_rates: Dictionary mapping symbols to their funding rates

        Returns:
            List of shorting opportunities
        """
        opportunities = []

        # Analyze each asset and assign a shorting score
        for item in market_data:
            symbol = item.get("symbol")
            if not symbol or symbol not in funding_rates:
                continue

            price = item.get("price", 0)
            volatility = item.get("volatility", 0)
            price_change_24h = item.get("priceChange24h", 0)
            funding_rate = funding_rates.get(symbol, 0)

            # Skip stablecoins or assets with very low volatility
            if "USD" in symbol or volatility < 0.5:
                continue

            # Simple scoring model:
            # - Lower funding rates are better for shorting (less cost)
            # - Higher volatility can mean more opportunity (but also more risk)
            # - Recent price gains might indicate overvalued assets due for correction

            funding_score = max(0, 5 - funding_rate * 100)  # Lower is better
            volatility_score = min(
                5, volatility
            )  # Higher volatility gives higher score (capped)
            momentum_score = 0

            # Recently rising assets might be due for correction
            if price_change_24h > 5:  # Strong recent rise
                momentum_score = 4
            elif price_change_24h > 2:  # Moderate rise
                momentum_score = 3
            elif price_change_24h > 0:  # Slight rise
                momentum_score = 2

            # Calculate total score
            total_score = funding_score + volatility_score + momentum_score

            # Estimate target price (simplified)
            expected_decline = (
                min(price_change_24h * 0.8, 20) if price_change_24h > 0 else volatility
            )
            target_price = price * (1 - expected_decline / 100)

            opportunities.append(
                {
                    "symbol": symbol,
                    "current_price": price,
                    "target_price": target_price,
                    "funding_rate": funding_rate,
                    "volatility": volatility,
                    "price_change_24h": price_change_24h,
                    "expected_decline": expected_decline,
                    "shorting_score": total_score,
                    "potential": (
                        "high"
                        if total_score > 10
                        else "medium" if total_score > 7 else "low"
                    ),
                }
            )

        # Sort by shorting score in descending order
        return sorted(opportunities, key=lambda x: x["shorting_score"], reverse=True)


def get_sample_market_data():
    """Sample function to get market data"""
    return [
        {
            "symbol": "BTC",
            "price": 50000,
            "volume24h": 1000000000,
            "priceChange24h": 2.5,
            "volatility": 4.2,
            "rsi14": 72.5,
            "macd": 1.2,
            "bollingerBandWidth": 5.3,
            "additionalInfo": "High volatility expected",
        },
        {
            "symbol": "ETH",
            "price": 3000,
            "volume24h": 500000000,
            "priceChange24h": -1.2,
            "volatility": 5.1,
            "rsi14": 45.2,
            "macd": -0.5,
            "bollingerBandWidth": 4.8,
            "additionalInfo": "Recent network upgrade",
        },
        {
            "symbol": "SOL",
            "price": 120,
            "volume24h": 150000000,
            "priceChange24h": 8.7,
            "volatility": 7.2,
            "rsi14": 82.1,
            "macd": 2.4,
            "bollingerBandWidth": 6.5,
            "additionalInfo": "Overbought condition",
        },
        {
            "symbol": "DOGE",
            "price": 0.15,
            "volume24h": 80000000,
            "priceChange24h": 12.3,
            "volatility": 9.8,
            "rsi14": 88.5,
            "macd": 0.012,
            "bollingerBandWidth": 15.2,
            "additionalInfo": "Social media driven rally",
        },
        {
            "symbol": "AVAX",
            "price": 35,
            "volume24h": 70000000,
            "priceChange24h": 4.5,
            "volatility": 6.1,
            "rsi14": 65.5,
            "macd": 0.8,
            "bollingerBandWidth": 5.0,
            "additionalInfo": "Recent resistance at $36",
        },
        {
            "symbol": "USDT",
            "price": 1.0,
            "volume24h": 50000000000,
            "priceChange24h": 0.01,
            "volatility": 0.2,
            "rsi14": 50.1,
            "macd": 0.001,
            "bollingerBandWidth": 0.2,
            "additionalInfo": "Stable coin with high liquidity",
        },
        {
            "symbol": "USDC",
            "price": 1.0,
            "volume24h": 30000000000,
            "priceChange24h": 0.02,
            "volatility": 0.15,
            "rsi14": 50.2,
            "macd": 0.001,
            "bollingerBandWidth": 0.15,
            "additionalInfo": "Regulated stable coin",
        },
    ]


def get_sample_funding_rates():
    """Sample function to get funding rates"""
    return {
        "BTC": 0.01,  # 0.01% funding rate
        "ETH": 0.008,
        "SOL": 0.015,
        "DOGE": 0.025,
        "AVAX": 0.012,
        "USDT": 0.001,
        "USDC": 0.001,
    }


def get_sample_portfolio_value():
    """Sample function to get portfolio value"""
    return 100000  # $100,000 USD


# Example usage
if __name__ == "__main__":
    # Initialize the agent
    agent = ShortingAgent(
        output_file="portfolio_generator/output/shorting_actions.jsonl",
        api_key=os.environ.get("DEEPSEEK_API_KEY"),
        risk_tolerance="medium",
        max_short_percentage=50.0,
        min_expected_decline=5.0,
    )

    # Find shorting opportunities
    opportunities = agent.get_shorting_opportunities(
        get_sample_market_data(), get_sample_funding_rates()
    )

    print("推荐做空的币种及目标赎回价格:")
    for i, opp in enumerate(opportunities[:5]):  # Top 5 opportunities
        print(
            f"{i+1}. {opp['symbol']}: 目标赎回价格 ${opp['target_price']:.2f} (当前价格: ${opp['current_price']:.2f}, 预期下跌: {opp['expected_decline']:.1f}%)"
        )

    # Optional: process market data continuously
    # agent.process_market_data(
    #     get_sample_market_data,
    #     get_sample_funding_rates,
    #     get_sample_portfolio_value,
    #     interval=3600,  # Check hourly
    # )

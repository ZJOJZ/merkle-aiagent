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


class LendingAgent:
    """
    Lending agent that processes market data and interest rates to automatically
    manage lending and borrowing activities to earn interest and hedge against risks.

    This agent supports four types of actions:
    1. lend - Lend assets to earn interest
    2. repay_lend - Withdraw lent assets
    3. borrow - Borrow assets (paying interest)
    4. repay_borrow - Repay borrowed assets

    The agent makes decisions based on:
    - Current market data (price, volatility, trends)
    - Current lending and borrowing interest rates
    - Risk tolerance settings
    - Interest rate arbitrage opportunities
    - Current active positions

    Usage:
        agent = LendingAgent(
            output_file="path/to/output.jsonl",
            api_key="your_api_key",
            risk_tolerance="medium",  # low, medium, high
            max_borrow_percentage=50.0,
            min_interest_differential=0.5
        )

        # Get lending actions based on current market conditions
        actions = agent.generate_lending_actions(
            market_data,
            lending_rates,
            borrowing_rates,
            portfolio_value
        )

        # Find arbitrage opportunities
        opportunities = agent.get_interest_arbitrage_opportunities(
            lending_rates,
            borrowing_rates
        )

        # Continuous processing
        agent.process_market_data(
            get_market_data_function,
            get_lending_rates_function,
            get_borrowing_rates_function,
            get_portfolio_value_function,
            interval=3600  # Check hourly
        )
    """

    def __init__(
        self,
        output_file: str = "portfolio_generator/output/lending_actions.jsonl",
        api_key: Optional[str] = None,
        model: str = "deepseek-chat",
        base_url: str = "https://api.deepseek.com",
        risk_tolerance: str = "medium",  # low, medium, high
        max_borrow_percentage: float = 50.0,  # Maximum percentage of portfolio to borrow
        min_interest_differential: float = 0.5,  # Minimum interest rate differential to consider arbitrage
    ):
        """
        Initialize the lending agent.

        Args:
            output_file: Path to the output JSONL file
            api_key: API key for the LLM service
            model: Model name to use
            base_url: Base URL for the API
            risk_tolerance: Risk tolerance level (low, medium, high)
            max_borrow_percentage: Maximum percentage of portfolio value to borrow
            min_interest_differential: Minimum interest rate differential to consider for arbitrage
        """
        self.output_file = output_file
        self.risk_tolerance = risk_tolerance
        self.max_borrow_percentage = max_borrow_percentage
        self.min_interest_differential = min_interest_differential

        # Track current lending and borrowing positions
        self.active_positions = {
            "lending": {},  # {symbol: {"amount": float, "rate": float, "timestamp": str}}
            "borrowing": {},  # {symbol: {"amount": float, "rate": float, "timestamp": str}}
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

        logger.info(f"Lending agent initialized. Output will be saved to {output_file}")

    def generate_lending_actions(
        self,
        market_data: List[Dict[str, Any]],
        lending_rates: Dict[str, float],
        borrowing_rates: Dict[str, float],
        portfolio_value: float,
        current_positions: Optional[Dict[str, Dict[str, Any]]] = None,
    ) -> Dict[str, Any]:
        """
        Generate lending and borrowing actions based on market data and interest rates.

        Args:
            market_data: List of market data for different symbols
            lending_rates: Dictionary mapping symbols to their lending interest rates
            borrowing_rates: Dictionary mapping symbols to their borrowing interest rates
            portfolio_value: Total portfolio value in USD
            current_positions: Current lending and borrowing positions

        Returns:
            Dict containing lending actions with timestamp
        """
        if current_positions is not None:
            self.active_positions = current_positions

        # Prepare the prompt for the LLM
        prompt = self._prepare_prompt(
            market_data, lending_rates, borrowing_rates, portfolio_value
        )

        try:
            # Call the LLM to generate lending actions
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "system",
                        "content": "You are a professional lending and borrowing agent. Analyze the market data and interest rates to provide optimal lending and borrowing actions in JSON format.",
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
                    required_fields = ["symbol", "action_type", "amount", "reason"]
                    for field in required_fields:
                        if field not in action:
                            logger.warning(f"Action missing required field: {field}")
                            action[field] = (
                                ""
                                if field == "reason"
                                else "unknown" if field == "symbol" else 0
                            )

                    # Validate action type
                    valid_actions = ["lend", "repay_lend", "borrow", "repay_borrow"]
                    if action["action_type"] not in valid_actions:
                        logger.warning(
                            f"Invalid action type: {action['action_type']}, defaulting to 'lend'"
                        )
                        action["action_type"] = "lend"

            # Update active positions based on actions
            self._update_positions(result.get("actions", []), portfolio_value)

            return result

        except Exception as e:
            logger.error(f"Error generating lending actions: {str(e)}")
            return {
                "actions": [],
                "error": str(e),
                "timestamp": datetime.now().isoformat(),
            }

    def _update_positions(self, actions: List[Dict[str, Any]], portfolio_value: float):
        """
        Update active positions based on new actions.

        Args:
            actions: List of lending/borrowing actions
            portfolio_value: Total portfolio value for validation
        """
        for action in actions:
            symbol = action["symbol"]
            action_type = action["action_type"]
            amount = action["amount"]

            # Handle different action types
            if action_type == "lend":
                if symbol not in self.active_positions["lending"]:
                    self.active_positions["lending"][symbol] = {
                        "amount": amount,
                        "timestamp": datetime.now().isoformat(),
                    }
                else:
                    self.active_positions["lending"][symbol]["amount"] += amount

            elif action_type == "repay_lend":
                if symbol in self.active_positions["lending"]:
                    current_amount = self.active_positions["lending"][symbol]["amount"]
                    new_amount = max(0, current_amount - amount)

                    if new_amount == 0:
                        del self.active_positions["lending"][symbol]
                    else:
                        self.active_positions["lending"][symbol]["amount"] = new_amount
                else:
                    logger.warning(
                        f"Attempted to repay lending for {symbol} but no active position exists"
                    )

            elif action_type == "borrow":
                if symbol not in self.active_positions["borrowing"]:
                    self.active_positions["borrowing"][symbol] = {
                        "amount": amount,
                        "timestamp": datetime.now().isoformat(),
                    }
                else:
                    self.active_positions["borrowing"][symbol]["amount"] += amount

            elif action_type == "repay_borrow":
                if symbol in self.active_positions["borrowing"]:
                    current_amount = self.active_positions["borrowing"][symbol][
                        "amount"
                    ]
                    new_amount = max(0, current_amount - amount)

                    if new_amount == 0:
                        del self.active_positions["borrowing"][symbol]
                    else:
                        self.active_positions["borrowing"][symbol][
                            "amount"
                        ] = new_amount
                else:
                    logger.warning(
                        f"Attempted to repay borrowing for {symbol} but no active position exists"
                    )

        # Validate total borrowing doesn't exceed max percentage
        total_borrowed = sum(
            pos["amount"] for pos in self.active_positions["borrowing"].values()
        )
        if total_borrowed > portfolio_value * (self.max_borrow_percentage / 100):
            logger.warning(
                f"Total borrowing exceeds maximum allowed percentage of portfolio value"
            )

    def _prepare_prompt(
        self,
        market_data: List[Dict[str, Any]],
        lending_rates: Dict[str, float],
        borrowing_rates: Dict[str, float],
        portfolio_value: float,
    ) -> str:
        """
        Prepare the prompt for the LLM.

        Args:
            market_data: List of market data for different symbols
            lending_rates: Dictionary mapping symbols to their lending interest rates
            borrowing_rates: Dictionary mapping symbols to their borrowing interest rates
            portfolio_value: Total portfolio value in USD

        Returns:
            Prompt string
        """
        market_data_str = json.dumps(market_data, indent=2)
        lending_rates_str = json.dumps(lending_rates, indent=2)
        borrowing_rates_str = json.dumps(borrowing_rates, indent=2)
        active_positions_str = json.dumps(self.active_positions, indent=2)
        current_time = datetime.now().isoformat()

        prompt = f"""
Analyze the following market data, interest rates, and current lending/borrowing positions:

Market Data:
{market_data_str}

Lending Interest Rates (Annual):
{lending_rates_str}

Borrowing Interest Rates (Annual):
{borrowing_rates_str}

Current Positions:
{active_positions_str}

Portfolio Value: ${portfolio_value}
Risk Tolerance: {self.risk_tolerance}

Based on this information, generate lending and borrowing actions. 
Your response must be a valid JSON object with the following structure:

```json
{{
  "actions": [
    {{
      "symbol": "BTC",
      "action_type": "lend",  // One of: lend, repay_lend, borrow, repay_borrow
      "amount": 0.5,  // Amount in the asset's units
      "rate": 5.2,  // Expected interest rate (APY)
      "reason": "High lending rates available with low market volatility"
    }},
    // More actions for other symbols
  ],
  "market_analysis": "Brief market analysis explaining the overall strategy",
  "risk_assessment": "Assessment of current lending/borrowing risks",
  "timestamp": "{current_time}"
}}
```

Important requirements:
1. Consider interest rate arbitrage opportunities (borrowing at lower rates and lending at higher rates)
2. Consider market volatility and trends when making lending/borrowing decisions
3. For high-volatility assets, be more conservative with borrowing
4. Balance the portfolio to avoid over-exposure to any single asset
5. Total borrowing should not exceed {self.max_borrow_percentage}% of portfolio value
6. Include a brief reason for each action
7. Provide overall market analysis and risk assessment
8. Include the current timestamp in the response

For lending decisions:
- Look for assets with high lending rates and low volatility
- Consider lending more stable assets in volatile markets
- Be cautious with lending assets that show strong directional trends

For borrowing decisions:
- Borrow assets with low borrowing rates
- Consider borrowing assets expected to decrease in value
- Avoid borrowing volatile assets unless for specific arbitrage opportunities

Return only the JSON object without any additional text.
"""
        return prompt

    def process_market_data(
        self,
        get_market_data: Callable[[], List[Dict[str, Any]]],
        get_lending_rates: Callable[[], Dict[str, float]],
        get_borrowing_rates: Callable[[], Dict[str, float]],
        get_portfolio_value: Callable[[], float],
        interval: int = 3600,  # Default to checking hourly
    ):
        """
        Continuously process market data and generate lending actions.

        Args:
            get_market_data: Callback function that returns market data
            get_lending_rates: Callback function that returns lending interest rates
            get_borrowing_rates: Callback function that returns borrowing interest rates
            get_portfolio_value: Callback function that returns total portfolio value
            interval: Time interval between checks in seconds
        """
        while True:
            try:
                # Get market data and rates from callbacks
                market_data = get_market_data()
                lending_rates = get_lending_rates()
                borrowing_rates = get_borrowing_rates()
                portfolio_value = get_portfolio_value()

                if not market_data or not lending_rates or not borrowing_rates:
                    logger.warning("Received empty data")
                    time.sleep(5)  # Wait before retrying
                    continue

                # Generate lending actions
                actions_data = self.generate_lending_actions(
                    market_data, lending_rates, borrowing_rates, portfolio_value
                )

                # Add timestamp if not present
                if "timestamp" not in actions_data:
                    actions_data["timestamp"] = datetime.now().isoformat()

                # Save to JSONL file
                self._save_to_jsonl(actions_data)

                logger.info(
                    f"Generated lending actions for {len(actions_data.get('actions', []))} symbols"
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
                    logger.info(
                        f"Symbol: {action.get('symbol')}, Action: {action.get('action_type')}, "
                        f"Amount: {action.get('amount')}, Rate: {action.get('rate', 0)}%"
                    )

            with open(self.output_file, "a") as f:
                f.write(json.dumps(data) + "\n")

            logger.info(
                f"Lending actions saved to {self.output_file} at {data['timestamp']}"
            )
        except Exception as e:
            logger.error(f"Error saving to JSONL file: {str(e)}")

    def get_interest_arbitrage_opportunities(
        self,
        lending_rates: Dict[str, float],
        borrowing_rates: Dict[str, float],
    ) -> List[Dict[str, Any]]:
        """
        Identify interest rate arbitrage opportunities.

        Args:
            lending_rates: Dictionary mapping symbols to their lending interest rates
            borrowing_rates: Dictionary mapping symbols to their borrowing interest rates

        Returns:
            List of arbitrage opportunities
        """
        opportunities = []

        # Find assets where lending rate > borrowing rate + minimum differential
        for symbol in set(lending_rates.keys()).intersection(borrowing_rates.keys()):
            lending_rate = lending_rates[symbol]
            borrowing_rate = borrowing_rates[symbol]

            differential = lending_rate - borrowing_rate

            if differential > self.min_interest_differential:
                opportunities.append(
                    {
                        "symbol": symbol,
                        "lending_rate": lending_rate,
                        "borrowing_rate": borrowing_rate,
                        "differential": differential,
                        "potential": (
                            "high"
                            if differential > 2 * self.min_interest_differential
                            else "medium"
                        ),
                    }
                )

        # Sort by differential in descending order
        return sorted(opportunities, key=lambda x: x["differential"], reverse=True)


def get_sample_market_data():
    """Sample function to get market data"""
    return [
        {
            "symbol": "BTC",
            "price": 50000,
            "volume24h": 1000000000,
            "priceChange24h": 2.5,
            "volatility": 4.2,
            "additionalInfo": "High volatility expected",
        },
        {
            "symbol": "ETH",
            "price": 3000,
            "volume24h": 500000000,
            "priceChange24h": -1.2,
            "volatility": 5.1,
            "additionalInfo": "Recent network upgrade",
        },
        {
            "symbol": "USDT",
            "price": 1.0,
            "volume24h": 50000000000,
            "priceChange24h": 0.01,
            "volatility": 0.2,
            "additionalInfo": "Stable coin with high liquidity",
        },
        {
            "symbol": "USDC",
            "price": 1.0,
            "volume24h": 30000000000,
            "priceChange24h": 0.02,
            "volatility": 0.15,
            "additionalInfo": "Regulated stable coin",
        },
    ]


def get_sample_lending_rates():
    """Sample function to get lending interest rates"""
    return {
        "BTC": 2.1,  # 2.1% APY
        "ETH": 3.5,
        "USDT": 8.2,
        "USDC": 7.5,
    }


def get_sample_borrowing_rates():
    """Sample function to get borrowing interest rates"""
    return {
        "BTC": 3.8,  # 3.8% APY
        "ETH": 4.7,
        "USDT": 6.3,
        "USDC": 5.9,
    }


def get_sample_portfolio_value():
    """Sample function to get portfolio value"""
    return 100000  # $100,000 USD


# Example usage
if __name__ == "__main__":
    # Initialize the agent
    agent = LendingAgent(
        output_file="portfolio_generator/output/lending_actions.jsonl",
        api_key=os.environ.get("DEEPSEEK_API_KEY"),
        risk_tolerance="medium",
        max_borrow_percentage=50.0,
    )

    # Find arbitrage opportunities
    opportunities = agent.get_interest_arbitrage_opportunities(
        get_sample_lending_rates(), get_sample_borrowing_rates()
    )

    print("Arbitrage opportunities:")
    for opp in opportunities:
        print(
            f"{opp['symbol']}: {opp['differential']}% differential (Lending: {opp['lending_rate']}%, Borrowing: {opp['borrowing_rate']}%)"
        )

    # Process market data
    agent.process_market_data(
        get_sample_market_data,
        get_sample_lending_rates,
        get_sample_borrowing_rates,
        get_sample_portfolio_value,
        interval=3600,  # Check hourly
    )

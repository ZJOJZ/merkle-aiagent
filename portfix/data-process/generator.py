import json
import os
import time
from datetime import datetime
from typing import Dict, List, Any, Callable, Optional
import logging
from openai import OpenAI

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


class TradingAgent:
    """
    Trading agent that processes market data and generates trading actions.
    """

    def __init__(
        self,
        output_file: str = "portfolio_generator/output/trading_actions.jsonl",
        api_key: Optional[str] = None,
        model: str = "deepseek-chat",
        base_url: str = "https://api.deepseek.com",
    ):
        """
        Initialize the trading agent.

        Args:
            output_file: Path to the output JSONL file
            api_key: API key for the LLM service
            model: Model name to use
            base_url: Base URL for the API
        """
        self.output_file = output_file

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

        logger.info(f"Trading agent initialized. Output will be saved to {output_file}")

    def generate_trading_actions(
        self, market_data: List[Dict[str, Any]]
    ) -> Dict[str, Any]:
        """
        Generate trading actions based on market data.

        Args:
            market_data: List of market data for different symbols

        Returns:
            Dict containing trading actions with timestamp and position percentages
        """
        # Prepare the prompt for the LLM
        prompt = self._prepare_prompt(market_data)

        try:
            # Call the LLM to generate trading actions
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "system",
                        "content": "You are a professional trading agent. Analyze the market data and provide trading actions in JSON format.",
                    },
                    {"role": "user", "content": prompt},
                ],
                response_format={"type": "json_object"},
                max_tokens=2048,  # Adjust as needed to prevent truncation
                temperature=0.2,  # Lower temperature for more deterministic outputs
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

            # Validate position percentages
            if "actions" in result:
                total_percentage = sum(
                    action.get("position_percentage", 0) for action in result["actions"]
                )
                if total_percentage != 100 and result["actions"]:
                    logger.warning(
                        f"Total position percentage is {total_percentage}%, adjusting to 100%"
                    )
                    # Normalize percentages to sum to 100%
                    for action in result["actions"]:
                        if "position_percentage" in action and total_percentage > 0:
                            action["position_percentage"] = round(
                                action["position_percentage"] / total_percentage * 100,
                                2,
                            )

            return result

        except Exception as e:
            logger.error(f"Error generating trading actions: {str(e)}")
            return {
                "actions": [],
                "error": str(e),
                "timestamp": datetime.now().isoformat(),
            }

    def _prepare_prompt(self, market_data: List[Dict[str, Any]]) -> str:
        """
        Prepare the prompt for the LLM.

        Args:
            market_data: List of market data for different symbols

        Returns:
            Prompt string
        """
        market_data_str = json.dumps(market_data, indent=2)
        current_time = datetime.now().isoformat()

        prompt = f"""
Analyze the following market data and generate trading actions:

Market Data:
{market_data_str}

Based on this market data, generate trading actions for each symbol. 
Your response must be a valid JSON object with the following structure:

```json
{{
  "actions": [
    {{
      "symbol": "BTC",
      "leverage": 5,  // Positive for long, negative for short, range from -150 to 150
      "position_percentage": 60,  // Percentage of total portfolio allocated to this symbol (0-100)
      "reason": "Strong upward trend with increasing volume"
    }},
    // More actions for other symbols
  ],
  "timestamp": "{current_time}"
}}
```

Important requirements:
1. Determine whether to go long (positive leverage) or short (negative leverage)
2. Set the leverage value between -150 and 150 (absolute value between 3 and 150)
3. Assign a position_percentage to each symbol representing what percentage of the total portfolio should be allocated to it
4. The sum of all position_percentage values MUST equal exactly 100%
5. Provide a brief reason for each action
6. Include the current timestamp in the response

Return only the JSON object without any additional text.
"""
        return prompt

    def process_market_data(self, get_market_data: Callable[[], List[Dict[str, Any]]]):
        """
        Continuously process market data and generate trading actions.

        Args:
            get_market_data: Callback function that returns market data
        """
        while True:
            try:
                # Get market data from callback
                market_data = get_market_data()

                if not market_data:
                    logger.warning("Received empty market data")
                    time.sleep(5)  # Wait before retrying
                    continue

                # Generate trading actions
                actions_data = self.generate_trading_actions(market_data)

                # Add timestamp if not present
                if "timestamp" not in actions_data:
                    actions_data["timestamp"] = datetime.now().isoformat()

                # Save to JSONL file
                self._save_to_jsonl(actions_data)

                logger.info(
                    f"Generated trading actions for {len(actions_data.get('actions', []))} symbols"
                )

            except Exception as e:
                logger.error(f"Error in processing loop: {str(e)}")

            # Wait before next iteration (can be adjusted based on requirements)
            time.sleep(1)

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

            # Log the actions with their position percentages
            if "actions" in data:
                for action in data["actions"]:
                    logger.info(
                        f"Symbol: {action.get('symbol')}, Position: {action.get('position_percentage')}%, Leverage: {action.get('leverage')}"
                    )

            with open(self.output_file, "a") as f:
                f.write(json.dumps(data) + "\n")

            logger.info(
                f"Trading actions saved to {self.output_file} at {data['timestamp']}"
            )
        except Exception as e:
            logger.error(f"Error saving to JSONL file: {str(e)}")


def get_sample_market_data():
    """Sample function to get market data"""
    return [
        {
            "symbol": "BTC",
            "price": 50000,
            "volume24h": 1000000000,
            "priceChange24h": 2.5,
            "additionalInfo": "High volatility expected",
        },
        {
            "symbol": "ETH",
            "price": 3000,
            "volume24h": 500000000,
            "priceChange24h": -1.2,
            "additionalInfo": "Recent network upgrade",
        },
    ]


# Example usage
if __name__ == "__main__":
    # Initialize the agent
    agent = TradingAgent(
        output_file="portfolio_generator/output/trading_actions.jsonl",
        api_key=os.environ.get("DEEPSEEK_API_KEY"),
    )

    # Process market data
    agent.process_market_data(get_sample_market_data)

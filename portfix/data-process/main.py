#!/usr/bin/env python3
import os
import json
import time
from datetime import datetime
from dotenv import load_dotenv
import logging
import sys
from MarketAnalyzer import get_market_indicators

os.makedirs("./data-process/output", exist_ok=True)
# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler("./data-process/output/main.log", mode="w"),
    ],
)
logger = logging.getLogger("main")

# Import the TradingAgent and sample market data function
from generator import TradingAgent, get_sample_market_data


def load_env_variables():
    """Load environment variables from .env file"""
    # Try to load from the current directory first
    if os.path.exists(".env"):
        load_dotenv()
        logger.info("Loaded environment variables from .env in current directory")
    else:
        logger.warning(
            "No .env file found. Make sure to set DEEPSEEK_API_KEY environment variable."
        )


def get_extended_market_data():
    """Get extended market data for testing"""
    # Start with the sample market data
    market_data = get_sample_market_data()

    # Add more test symbols to make the test more comprehensive
    market_data.extend(
        [
            {
                "symbol": "SOL",
                "price": 120,
                "volume24h": 300000000,
                "priceChange24h": 5.8,
                "additionalInfo": "Strong ecosystem growth",
            },
            {
                "symbol": "AVAX",
                "price": 35,
                "volume24h": 150000000,
                "priceChange24h": -2.3,
                "additionalInfo": "Recent network congestion",
            },
        ]
    )

    return market_data


def start_trading_actions_generation(agent: TradingAgent, output_file: str):
    """Start the generation of trading actions with actual API calls"""

    market_data = get_market_indicators()
    logger.info(market_data)
    
    # Generate trading actions
    logger.info("Generating trading actions...")
    start_time = time.time()

    try:
        actions_data = agent.generate_trading_actions(market_data)
        end_time = time.time()
        logger.info(f"Trading actions generated in {end_time - start_time:.2f} seconds")
    except Exception as e:
        logger.error(f"Failed to generate trading actions: {str(e)}")
        return False

    # Verify the results
    if not actions_data:
        logger.error("No actions data returned")
        return False

    # Check for timestamp
    if "timestamp" not in actions_data:
        logger.error("Timestamp missing from actions data")
        return False
    else:
        logger.info(f"Timestamp present: {actions_data['timestamp']}")

    # Check for actions
    if "actions" not in actions_data or not actions_data["actions"]:
        logger.error("No actions found in the response")
        return False

    # Verify each action has the required fields
    total_percentage = 0
    for i, action in enumerate(actions_data["actions"]):
        logger.info(f"Action {i+1}:")

        # Check symbol
        if "symbol" not in action:
            logger.error(f"Action {i+1} missing symbol")
            return False
        logger.info(f"  Symbol: {action['symbol']}")

        # Check leverage
        if "leverage" not in action:
            logger.error(f"Action {i+1} missing leverage")
            return False
        logger.info(f"  Leverage: {action['leverage']}")

        # Check position percentage
        if "position_percentage" not in action:
            logger.error(f"Action {i+1} missing position_percentage")
            return False
        logger.info(f"  Position Percentage: {action['position_percentage']}%")
        total_percentage += action.get("position_percentage", 0)

        # Check reason
        if "reason" not in action:
            logger.error(f"Action {i+1} missing reason")
            return False
        logger.info(f"  Reason: {action['reason']}")

    # Verify total position percentage is 100%
    logger.info(f"Total position percentage: {total_percentage}%")
    if abs(total_percentage - 100) > 0.01:  # Allow for small floating point errors
        logger.warning(
            f"Total position percentage is not 100% (actual: {total_percentage}%)"
        )

    # Save the results to file
    try:
        with open(output_file, "w") as f:
            f.write(json.dumps(actions_data) + "\n")
        logger.info(f"Results saved to {output_file}")
    except Exception as e:
        logger.error(f"Failed to save results: {str(e)}")

    # Also save a pretty-printed version for easier reading
    try:
        with open(f"{output_file}.pretty.json", "w") as f:
            json.dump(actions_data, f, indent=2)
        logger.info(f"Pretty-printed results saved to {output_file}.pretty.json")
    except Exception as e:
        logger.error(f"Failed to save pretty-printed results: {str(e)}")

    return True


def main():
    """Main function to run the test"""
    logger.info("Starting TradingAgent")

    # Load environment variables
    load_env_variables()

    # Get API key from environment
    api_key = os.environ.get("DEEPSEEK_API_KEY")
    if not api_key:
        logger.error("DEEPSEEK_API_KEY not found in environment variables")
        return False


    # Initialize the trading agent
    output_file = "./public/result.jsonl"
    logger.info(f"Initializing TradingAgent with output file: {output_file}")

    try:
        agent = TradingAgent(output_file=output_file, api_key=api_key)
        logger.info("TradingAgent initialized successfully")
    except Exception as e:
        logger.error(f"Failed to initialize TradingAgent: {str(e)}")
        return False
    while True:
        success = start_trading_actions_generation(agent, output_file)
        if success:
            break
        else:
            logger.info("Failed to generate trading actions, retrying...")
            time.sleep(10)
        time.sleep(60)


if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)

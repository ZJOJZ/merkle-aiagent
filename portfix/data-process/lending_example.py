import os
import time
import json
from typing import Dict, List, Any
from datetime import datetime, timedelta

from lending_agent import (
    LendingAgent,
    get_sample_market_data,
    get_sample_lending_rates,
    get_sample_borrowing_rates,
    get_sample_portfolio_value,
)

# Configure simulation parameters
SIMULATION_DAYS = 30
CHECKS_PER_DAY = 4  # Check every 6 hours
TIME_STEP = 24 / CHECKS_PER_DAY  # Hours per step

# Market volatility simulation
MARKET_TREND = {
    "BTC": [0.5, -0.3, 1.2, -0.8, 0.4],  # Daily price change percentages
    "ETH": [0.7, -0.5, 1.5, -1.0, 0.3],
    "USDT": [0.001, -0.001, 0.002, -0.002, 0.001],
    "USDC": [0.001, -0.001, 0.001, -0.001, 0.0],
}

# Interest rate trends (small daily changes)
INTEREST_RATE_TRENDS = {
    "lending": {
        "BTC": [-0.02, 0.01, 0.03, -0.01, 0.02],
        "ETH": [-0.03, 0.02, 0.05, -0.02, 0.01],
        "USDT": [-0.05, 0.03, 0.08, -0.04, 0.03],
        "USDC": [-0.04, 0.02, 0.06, -0.03, 0.02],
    },
    "borrowing": {
        "BTC": [-0.01, 0.02, 0.04, -0.02, 0.01],
        "ETH": [-0.02, 0.03, 0.06, -0.03, 0.02],
        "USDT": [-0.03, 0.04, 0.07, -0.05, 0.02],
        "USDC": [-0.02, 0.03, 0.05, -0.04, 0.01],
    },
}


class MarketSimulator:
    """Simple market simulator for testing the lending agent"""

    def __init__(self):
        self.day = 0
        self.step_in_day = 0
        self.market_data = get_sample_market_data()
        self.lending_rates = get_sample_lending_rates()
        self.borrowing_rates = get_sample_borrowing_rates()
        self.portfolio_value = get_sample_portfolio_value()
        self.portfolio_history = []

    def step(self):
        """Advance market simulation by one time step"""
        self.step_in_day += 1
        if self.step_in_day >= CHECKS_PER_DAY:
            self.step_in_day = 0
            self.day += 1

        # Update market prices
        trend_idx = self.day % len(next(iter(MARKET_TREND.values())))
        for market_item in self.market_data:
            symbol = market_item["symbol"]
            if symbol in MARKET_TREND:
                # Daily price change divided by checks per day
                daily_change = MARKET_TREND[symbol][trend_idx] / CHECKS_PER_DAY
                market_item["price"] *= 1 + daily_change / 100

                # Update 24h metrics
                market_item["priceChange24h"] = MARKET_TREND[symbol][trend_idx]

        # Update interest rates
        for symbol in self.lending_rates:
            if symbol in INTEREST_RATE_TRENDS["lending"]:
                daily_change = (
                    INTEREST_RATE_TRENDS["lending"][symbol][trend_idx] / CHECKS_PER_DAY
                )
                self.lending_rates[symbol] += daily_change
                # Ensure rates stay positive
                self.lending_rates[symbol] = max(0.1, self.lending_rates[symbol])

        for symbol in self.borrowing_rates:
            if symbol in INTEREST_RATE_TRENDS["borrowing"]:
                daily_change = (
                    INTEREST_RATE_TRENDS["borrowing"][symbol][trend_idx]
                    / CHECKS_PER_DAY
                )
                self.borrowing_rates[symbol] += daily_change
                # Ensure rates stay positive and above lending rates
                self.borrowing_rates[symbol] = max(
                    self.lending_rates.get(symbol, 0) + 0.1,
                    self.borrowing_rates[symbol],
                )

    def get_market_data(self):
        """Get current market data"""
        return self.market_data

    def get_lending_rates(self):
        """Get current lending rates"""
        return self.lending_rates

    def get_borrowing_rates(self):
        """Get current borrowing rates"""
        return self.borrowing_rates

    def get_portfolio_value(self):
        """Get current portfolio value"""
        return self.portfolio_value

    def update_portfolio_value(self, actions):
        """Update portfolio value based on lending/borrowing actions"""
        if not actions:
            return

        # Simple model: each successful lending gives small interest, each borrowing costs interest
        lending_gain = 0
        borrowing_cost = 0

        for action in actions:
            symbol = action.get("symbol")
            action_type = action.get("action_type")
            amount = action.get("amount", 0)

            if action_type == "lend":
                # Add interest earned for time step (APY / time periods per year)
                rate = self.lending_rates.get(symbol, 0)
                time_fraction = TIME_STEP / (24 * 365)  # Fraction of a year
                interest = amount * rate / 100 * time_fraction
                lending_gain += interest

            elif action_type == "borrow":
                rate = self.borrowing_rates.get(symbol, 0)
                time_fraction = TIME_STEP / (24 * 365)
                interest = amount * rate / 100 * time_fraction
                borrowing_cost += interest

        # Update portfolio value
        self.portfolio_value = self.portfolio_value + lending_gain - borrowing_cost

        # Record history
        self.portfolio_history.append(
            {
                "day": self.day,
                "step": self.step_in_day,
                "timestamp": datetime.now().isoformat(),
                "portfolio_value": self.portfolio_value,
                "lending_gain": lending_gain,
                "borrowing_cost": borrowing_cost,
            }
        )

        return {
            "lending_gain": lending_gain,
            "borrowing_cost": borrowing_cost,
            "net_gain": lending_gain - borrowing_cost,
            "new_portfolio_value": self.portfolio_value,
        }


def run_simulation():
    """Run a simulation of automated lending and borrowing"""
    print("Starting lending agent simulation...")

    # Initialize agent and simulator
    agent = LendingAgent(
        output_file="portfolio_generator/output/lending_simulation.jsonl",
        api_key=os.environ.get("DEEPSEEK_API_KEY"),
        risk_tolerance="medium",
        max_borrow_percentage=60.0,
        min_interest_differential=0.3,
    )

    simulator = MarketSimulator()

    # Track simulation results
    results = []

    total_steps = SIMULATION_DAYS * CHECKS_PER_DAY
    for step in range(total_steps):
        current_day = step // CHECKS_PER_DAY
        current_hour = (step % CHECKS_PER_DAY) * TIME_STEP

        print(
            f"\nDay {current_day + 1}, Hour {current_hour:.1f} (Step {step + 1}/{total_steps})"
        )
        print("-" * 50)

        # Get market data from simulator
        market_data = simulator.get_market_data()
        lending_rates = simulator.get_lending_rates()
        borrowing_rates = simulator.get_borrowing_rates()
        portfolio_value = simulator.get_portfolio_value()

        # Display current state
        print(f"Portfolio Value: ${portfolio_value:.2f}")
        print("\nLending Rates:")
        for symbol, rate in lending_rates.items():
            print(f"  {symbol}: {rate:.2f}%")

        print("\nBorrowing Rates:")
        for symbol, rate in borrowing_rates.items():
            print(f"  {symbol}: {rate:.2f}%")

        # Find arbitrage opportunities
        opportunities = agent.get_interest_arbitrage_opportunities(
            lending_rates, borrowing_rates
        )
        if opportunities:
            print("\nArbitrage Opportunities:")
            for opp in opportunities:
                print(f"  {opp['symbol']}: {opp['differential']:.2f}% differential")

        # Generate lending/borrowing actions
        actions_data = agent.generate_lending_actions(
            market_data, lending_rates, borrowing_rates, portfolio_value
        )

        # Display actions
        actions = actions_data.get("actions", [])
        if actions:
            print("\nActions:")
            for action in actions:
                print(
                    f"  {action.get('symbol')}: {action.get('action_type')} {action.get('amount')} units"
                )
                print(f"    Reason: {action.get('reason', 'N/A')}")
        else:
            print("\nNo actions taken.")

        # Update portfolio based on actions
        update_result = simulator.update_portfolio_value(actions)
        if update_result:
            print(f"\nPortfolio Update:")
            print(f"  Lending Gain: ${update_result['lending_gain']:.4f}")
            print(f"  Borrowing Cost: ${update_result['borrowing_cost']:.4f}")
            print(f"  Net Gain: ${update_result['net_gain']:.4f}")
            print(f"  New Portfolio Value: ${update_result['new_portfolio_value']:.2f}")

        # Store step results
        results.append(
            {
                "day": current_day,
                "hour": current_hour,
                "portfolio_value": portfolio_value,
                "actions": actions,
                "update_result": update_result,
                "timestamp": datetime.now().isoformat(),
            }
        )

        # Advance market simulation
        simulator.step()

        # Artificial delay for readability
        time.sleep(0.1)

    # Save final simulation results
    os.makedirs("portfolio_generator/output", exist_ok=True)
    with open("portfolio_generator/output/lending_simulation_results.json", "w") as f:
        json.dump(
            {
                "simulation_parameters": {
                    "days": SIMULATION_DAYS,
                    "checks_per_day": CHECKS_PER_DAY,
                    "time_step_hours": TIME_STEP,
                    "initial_portfolio_value": get_sample_portfolio_value(),
                    "final_portfolio_value": simulator.portfolio_value,
                },
                "portfolio_history": simulator.portfolio_history,
                "steps": results,
            },
            f,
            indent=2,
        )

    # Display summary
    initial_value = get_sample_portfolio_value()
    final_value = simulator.portfolio_value
    total_gain = final_value - initial_value
    percent_gain = (total_gain / initial_value) * 100

    print("\n" + "=" * 50)
    print("SIMULATION COMPLETE")
    print("=" * 50)
    print(f"Initial Portfolio Value: ${initial_value:.2f}")
    print(f"Final Portfolio Value: ${final_value:.2f}")
    print(f"Total Gain/Loss: ${total_gain:.2f} ({percent_gain:.2f}%)")
    print(f"Annualized Return: {(percent_gain / SIMULATION_DAYS) * 365:.2f}%")
    print(
        f"Results saved to: portfolio_generator/output/lending_simulation_results.json"
    )
    print("=" * 50)


if __name__ == "__main__":
    run_simulation()

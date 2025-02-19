# PortfiX: Smart On-Chain Portfolio & Trading Assistant
## Project Overview
ProfitX is an intelligent, AI-powered portfolio manager and trading assistant, seamlessly integrated with Merkle Trade, a decentralized perpetual DEX built on the Aptos blockchain. ProfitX automates portfolio analysis, strategy recommendations, and execution of high-leverage trades using USDC on the Merkle platform. With support for up to 150X leverage, users can maximize their yield potential while maintaining risk management practices, all in a seamless, secure environment.

## Core Features
### Portfolio Analysis
- Total Value & 24H Change: Upon connecting their wallet, users get a quick overview of their portfolio's total value and the 24-hour change in percentage, helping them understand the performance at a glance.

- Asset Breakdown: PortfiX displays detailed information about each token in the portfolio, including the amount held, contract addresses, and USD value for easy tracking. For example, users can view their ETH/USDC and BTC/USDC holdings, complete with current USD values.

### AI-Powered Trade Strategy Recommendations
For each asset in the portfolio (e.g., ETH/USDC or BTC/USDC), PortfiX’s AI engine analyzes the current market trend and provides a strategy recommendation.

### One-Click: Seamless Trade Execution
With the recommendation in hand, users can quickly select whether to Long or Short each token directly within the platform. After approval, the platform executes trades on Merkle Finance in real-time. The integration with Merkle Finance ensures that trades are executed at lightning speed with minimal slippage.


## Create Aptos Dapp Boilerplate Template

The Boilerplate template provides a starter dapp with all necessary dapp infrastructure and a simple wallet info implementation, transfer APT and a simple message board functionality to send and read a message on chain.

## Read the Boilerplate template docs
To get started with the Boilerplate template and learn more about the template functionality and usage, head over to the [Boilerplate template docs](https://learn.aptoslabs.com/en/dapp-templates/boilerplate-template) 


## The Boilerplate template provides:

- **Folder structure** - A pre-made dapp folder structure with a `src` (frontend) and `contract` folders.
- **Dapp infrastructure** - All required dependencies a dapp needs to start building on the Aptos network.
- **Wallet Info implementation** - Pre-made `WalletInfo` components to demonstrate how one can use to read a connected Wallet info.
- **Transfer APT implementation** - Pre-made `transfer` components to send APT to an address.
- **Message board functionality implementation** - Pre-made `message` components to send and read a message on chain


## What tools the template uses?

- React framework
- shadcn/ui + tailwind for styling
- Aptos TS SDK
- Aptos Wallet Adapter
- Node based Move commands
- [Next-pwa](https://ducanh-next-pwa.vercel.app/)

## Config
- rename `example.env` to `.env` and add your API key

## What Move commands are available?

The tool utilizes [aptos-cli npm package](https://github.com/aptos-labs/aptos-cli) that lets us run Aptos CLI in a Node environment.

Some commands are built-in the template and can be ran as a npm script, for example:

- `npm run move:publish` - a command to publish the Move contract
- `npm run move:test` - a command to run Move unit tests
- `npm run move:compile` - a command to compile the Move contract
- `npm run move:upgrade` - a command to upgrade the Move contract
- `npm run dev` - a command to run the frontend locally
- `npm run deploy` - a command to deploy the dapp to Vercel

For all other available CLI commands, can run `npx aptos` and see a list of all available commands.
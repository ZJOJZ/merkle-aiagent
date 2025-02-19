# Merkle Trade ElizaOS Plugin & Sample AI Agents

This repository contains Merkle Eliza OS Plugin (Beta) and two sample trading AI agents that runs on ElizaOS.

<img src="./sample-agent.png" width="600">

## Features

- **Merkle ElizaOS Plugin** ([packages/plugin-merkle](packages/plugin-merkle)): The plugin integrates with popular messaging platforms, enabling trade execution, alerts, and multi-channel notifications (Discord, X, etc.).
- **Sample Eliza Agent based on latest price info** ([packages/plugin-merkle-example-price](packages/plugin-merkle-example-price))
- **Sample Eliza Agent based on real-time updates from socials** ([packages/plugin-merkle-example-sns](packages/plugin-merkle-example-sns))

**Join our Telegram Group:** [@merkle_trade_dev](https://t.me/merkle_trade_dev) for latest updates and Q&A.

## Quick Start

### 1. Checkout the latest release

```bash
git clone https://github.com/merkle-trade/merkle-agent-sample
```

### 2. Set the environment variables

Merkle Configuration

```env
MERKLE_TRADE_LOG_LEVEL=debug
MERKLE_TRADE_NETWORK=               # Must be one of mainnet, testnet
MERKLE_TRADE_APTOS_PRIVATE_KEY=     # Aptos private key
PRICE_GAP_RATE_PERCENT=1            # Price gap rate percent, for price sample plugin
```

(Optional) Discord Configuration ([Discord Developers](https://discord.com/developers/applications))

```env
DISCORD_APPLICATION_ID=               # Your Discord Bot Application ID
DISCORD_API_TOKEN=                    # Bot token
DISCORD_VOICE_CHANNEL_ID=             # The ID of the voice channel the bot should join (optional)
DISCORD_POST_CHANNEL_ID=              # Post Merkle Plugin channel
```

(Optional) X Configuration

```env
TWITTER_DRY_RUN=false
TWITTER_USERNAME=
TWITTER_PASSWORD=
TWITTER_EMAIL=
TWITTER_2FA_SECRET=
TWITTER_POLL_INTERVAL=300 # How often (in seconds) the bot should check for interactions
TWITTER_SEARCH_ENABLE=FALSE # Enable timeline search, `WARNING` this greatly increases your chance of getting banned
TWITTER_TARGET_USERS= # Comma separated list of Twitter user names to interact with
TWITTER_RETRY_LIMIT= # Maximum retry attempts for Twitter login
TWITTER_SPACES_ENABLE=false # Enable or disable Twitter Spaces logic
```

- Post Interval Settings (in minutes)

```env
POST_INTERVAL_MIN=90 # Default: 90
POST_INTERVAL_MAX=180 # Default: 180
POST_IMMEDIATELY=true # Default: false
```

- Twitter action processing configuration

```env
ACTION_INTERVAL= # Interval in minutes between action processing runs (default: 5 minutes)
ENABLE_ACTION_PROCESSING=true # Set to true to enable the action processing loop
MAX_ACTIONS_PROCESSING=1 # Maximum number of actions (e.g., retweets, likes) to process in a single cycle. Helps prevent excessive or uncontrolled actions.
ACTION_TIMELINE_TYPE= # Type of timeline to interact with. Options: "foryou" or "following". Default: "foryou"
```

- CONFIGURATION FOR APPROVING TWEETS BEFORE IT GETS POSTED (optional)

```env
TWITTER_APPROVAL_DISCORD_CHANNEL_ID= # Channel ID for the Discord bot to listen and send approval messages
TWITTER_APPROVAL_DISCORD_BOT_TOKEN= # Discord bot token
TWITTER_APPROVAL_ENABLED=true # Enable or disable Twitter approval logic #Default is false
TWITTER_APPROVAL_CHECK_INTERVAL=60000 # Default: 60 seconds
```

### 3. Start Merkle AI Agent

```bash
pnpm install && pnpm build
pnpm start --character="characters/merkle-price.character.json"

// or

pnpm start --character="characters/merkle-sns.character.json"
```

## Advanced Usage

Implement and Run a custom plugin like plugin-merkle in the [elizaOS repository](https://github.com/elizaOS).

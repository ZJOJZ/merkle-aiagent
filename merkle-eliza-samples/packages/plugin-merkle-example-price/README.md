# @elizaos/plugin-merkle-example-price

This plugin is a sample plugin for interacting with bitcoin price data and MerkleTrade within the elizaOS ecosystem.

## Configuration

The plugin requires the following environment variables to be set:

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

## Usage

### Agent Trigger Example

```bash
// The plugin responds to natural language like:

Hey there, lovely! 🌸 I've got my eyes on $BTC/USD with a fab short at 1376.06 size and a sassy long at 1432.91 size,both dancing on 150x leverage.
My balance is a sparkly 11957.88, and I'm feeling oh-so-confident in this crypto ballet!
```

## Triggers

#### PRICE_SIGNAL

The trigger activates if the price volatility exceeds the threshold specified in the environment variables within one minute. When triggered, it opens a position on Merkle Trade and posts the position details to SNS.

#### AGENT_CURRENT_INFO

Every 30 minutes, the agent posts its position and current balance to SNS.

## Development Guide

### Setting Up Development Environment

1. Clone the repository
2. Install dependencies:

```bash
cd packages/plugin-merkle-example-price

pnpm install
```

3. Build the plugin:

```bash
pnpm build
```

## Dependencies

- @elizaos/core: v0.1.9
- @merkletrade/ts-sdk: ^v1.0.0
- @aptos-labs/ts-sdk: ^v1.26.0
- agent-twitter-client: 0.0.18
- discord.js: "14.16.3"
- node-cache: 5.1.2

For more information:

- [Merkle Documentation](https://docs.merkle.trade/)
- [Aptos Documentation](https://aptos.dev/)
- [Move Language Guide](https://move-language.github.io/move/)

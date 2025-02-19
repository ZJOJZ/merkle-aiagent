# @elizaos/plugin-merkle-example-sns

This plugin is a sample plugin for interacting with SNS data and MerkleTrade within the elizaOS ecosystem.

## Configuration

The plugin requires the following environment variables to be set:

Merkle Configuration

```env
MERKLE_TRADE_LOG_LEVEL=debug
MERKLE_TRADE_NETWORK=               # Must be one of mainnet, testnet
MERKLE_TRADE_APTOS_PRIVATE_KEY=     # Aptos private key
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

You: "Bitcoin's spot market is seeing increased buying pressure, suggesting a potential for continued price appreciation."
Agent: "Bitcoin must be down, because you said it's seeing increased buying pressure."
```

## Actions

#### BITCOIN_REVERSE_SIGNAL

This action allows the agent to analyze signals from SNS indicating whether Bitcoin may rise or fall and take the opposite position accordingly.

## Development Guide

### Setting Up Development Environment

1. Clone the repository
2. Install dependencies:

```bash
cd packages/plugin-merkle-example-sns

pnpm install
```

3. Build the plugin:

```bash
pnpm build
```

## Dependencies

- @elizaos/core: v0.1.9

For more information:

- [Merkle Documentation](https://docs.merkle.trade/)
- [Aptos Documentation](https://aptos.dev/)
- [Move Language Guide](https://move-language.github.io/move/)

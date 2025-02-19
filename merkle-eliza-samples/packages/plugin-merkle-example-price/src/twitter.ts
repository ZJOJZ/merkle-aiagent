import { elizaLogger, type IAgentRuntime } from "@elizaos/core";
import { Scraper } from "agent-twitter-client";

async function sendTweet(twitterClient: Scraper, content: string) {
  const result = await twitterClient.sendTweet(content);

  const body = await result.json();
  elizaLogger.log("Tweet response:", body);

  // Check for Twitter API errors
  if (body.errors) {
      const error = body.errors[0];
      elizaLogger.error(
          `Twitter API error (${error.code}): ${error.message}`
      );
      return false;
  }

  // Check for successful tweet creation
  if (!body?.data?.create_tweet?.tweet_results?.result) {
      elizaLogger.error("Failed to post tweet: No tweet result in response");
      return false;
  }

  return true;
}

export async function postTweet(
  runtime: IAgentRuntime,
  content: string
): Promise<boolean> {
  try {
      const twitterClient = runtime.clients?.twitter?.client?.twitterClient;
      const scraper = twitterClient || new Scraper();

      if (!twitterClient) {
          const username = runtime.getSetting("TWITTER_USERNAME");
          const password = runtime.getSetting("TWITTER_PASSWORD");
          const email = runtime.getSetting("TWITTER_EMAIL");
          const twitter2faSecret = runtime.getSetting("TWITTER_2FA_SECRET");

          if (!username || !password) {
              elizaLogger.error(
                  "Twitter credentials not configured in environment"
              );
              return false;
          }
          // Login with credentials
          await scraper.login(username, password, email, twitter2faSecret);
          if (!(await scraper.isLoggedIn())) {
              elizaLogger.error("Failed to login to Twitter");
              return false;
          }
      }

      // Send the tweet
      elizaLogger.log("Attempting to send tweet:", content);

      try {
          if (content.length > 300) {
              const noteTweetResult = await scraper.sendNoteTweet(content);
              if (noteTweetResult.errors && noteTweetResult.errors.length > 0) {
                  // Note Tweet failed due to authorization. Falling back to standard Tweet.
                  return await sendTweet(scraper, content);
              }
              return true;
          }
          return await sendTweet(scraper, content);
      } catch (error) {
          throw new Error(`Note Tweet failed: ${error}`);
      }
  } catch (error) {
      // Log the full error details
      elizaLogger.error("Error posting tweet:", {
          message: error.message,
          stack: error.stack,
          name: error.name,
          cause: error.cause,
      });
      return false;
  }
}
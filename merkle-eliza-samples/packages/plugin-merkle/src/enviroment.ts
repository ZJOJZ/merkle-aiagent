import type { IAgentRuntime } from "@elizaos/core";
import { z } from "zod";

export const merkleTradeEnvSchema = z.object({
	MERKLE_TRADE_NETWORK: z
		.string()
		.min(1, "Merkle Aptos network is required"),
    MERKLE_TRADE_APTOS_PRIVATE_KEY: z
		.string()
		.min(1, "Merkle Aptos private key is required"),
});

export type MerkleTradeConfig = z.infer<typeof merkleTradeEnvSchema>;

export async function validateConfig(
	runtime: IAgentRuntime,
): Promise<MerkleTradeConfig> {
	try {
		const config = {
			MERKLE_TRADE_NETWORK:
				runtime.getSetting("MERKLE_TRADE_NETWORK") ||
				process.env.MERKLE_TRADE_NETWORK,
			MERKLE_TRADE_APTOS_PRIVATE_KEY:
				runtime.getSetting("MERKLE_TRADE_APTOS_PRIVATE_KEY") ||
				process.env.MERKLE_TRADE_APTOS_PRIVATE_KEY,
		};

		return merkleTradeEnvSchema.parse(config);
	} catch (error) {
		if (error instanceof z.ZodError) {
			const errorMessages = error.errors
				.map((err) => `${err.path.join(".")}: ${err.message}`)
				.join("\n");
			throw new Error(
				`Merkle Trade configuration validation failed:\n${errorMessages}`,
			);
		}
		throw error;
	}
}

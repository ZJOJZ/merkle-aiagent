import { type AccountAddress, Aptos, AptosConfig } from "@aptos-labs/ts-sdk"
import type { AgentRuntime } from "../../agent"

/**
 * Burn NFT
 * @param agent MoveAgentKit instance
 * @param mint NFT mint address
 * @returns Transaction signature
 */
export async function burnNFT(agent: AgentRuntime, mint: AccountAddress): Promise<string> {
	return ""
	//  try {
	//    const transaction = await agent.aptos.burnDigitalAssetTransaction({
	//      creator: agent.account.getAccount(),
	//      digitalAssetAddress: mint,
	//    });

	//    const committedTransactionHash = await agent.account.sendTransaction(transaction);

	//    const signedTransaction = await agent.aptos.waitForTransaction({
	//      transactionHash: committedTransactionHash,
	//    });

	//    if (!signedTransaction.success) {
	//      console.error(signedTransaction, "NFT burn failed");
	//      throw new Error("NFT burn failed");
	//    }

	//    return signedTransaction.hash;
	//  } catch (error: any) {
	//    throw new Error(`NFT burn failed: ${error.message}`);
	//  }
}

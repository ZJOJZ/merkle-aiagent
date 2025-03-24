import { type AccountAddress, Aptos, AptosConfig } from "@aptos-labs/ts-sdk"
import type { AgentRuntime } from "../../agent"

/**
 * Transfer NFT
 * @param agent MoveAgentKit instance
 * @param to Recipient's public key
 * @param mint NFT mint address
 * @returns Transaction signature
 */
export async function transferNFT(
	agent: AgentRuntime, // Replace with the actual type of the move-agent
	to: AccountAddress,
	mint: AccountAddress
): Promise<string> {
	return ""
	//  try {
	//    const transaction = await agent.aptos.transferDigitalAssetTransaction({
	//      sender: agent.account.getAccount(),
	//      digitalAssetAddress: mint,
	//      recipient: to,
	//    });

	//    const committedTransaction = await agent.aptos.signAndSubmitTransaction({
	//      signer: agent.account.getAccount(),
	//      transaction,
	//    });

	//    const signedTransaction = await agent.aptos.waitForTransaction({
	//      transactionHash: committedTransaction.hash,
	//    });

	//    if (!signedTransaction.success) {
	//      console.error(signedTransaction, "NFT transfer failed");
	//      throw new Error("NFT transfer failed");
	//    }

	//    return signedTransaction.hash;
	//  } catch (error: any) {
	//    throw new Error(`NFT transfer failed: ${error.message}`);
	//  }
}

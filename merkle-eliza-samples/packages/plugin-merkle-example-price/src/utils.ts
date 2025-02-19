import type { Account, Aptos, InputEntryFunctionData } from "@aptos-labs/ts-sdk";
import type { IAgentRuntime } from "@elizaos/core";

export const sendTransaction = async (aptos: Aptos, account: Account, payload: InputEntryFunctionData) => {
  const transaction = await aptos.transaction.build.simple({
    sender: account.accountAddress,
    data: payload,
  });
  const { hash } = await aptos.signAndSubmitTransaction({
    signer: account,
    transaction,
  });
  return await aptos.waitForTransaction({ transactionHash: hash });
}

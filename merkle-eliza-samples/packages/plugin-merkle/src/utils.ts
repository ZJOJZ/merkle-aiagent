import type { IAgentRuntime } from "@elizaos/core";
import { MerkleService } from "./services";
import { Account, type Aptos, Ed25519PrivateKey, type InputEntryFunctionData, PrivateKey, PrivateKeyVariants } from "@aptos-labs/ts-sdk";
import { MerkleClientConfig } from "@merkletrade/ts-sdk";

export const checkEnv = (runtime: IAgentRuntime) => {
  return !!(
    runtime.getSetting("MERKLE_TRADE_LOG_LEVEL") &&
    runtime.getSetting("MERKLE_TRADE_APTOS_PRIVATE_KEY") &&
    runtime.getSetting("MERKLE_TRADE_NETWORK")
  );
};

export const newMerkleService = async (runtime: IAgentRuntime) => {
  const network = runtime.getSetting("MERKLE_TRADE_NETWORK")
  const config = network === "mainnet" ? await MerkleClientConfig.mainnet() : await MerkleClientConfig.testnet()
  const merkleAccount = Account.fromPrivateKey({
    privateKey: new Ed25519PrivateKey(
      PrivateKey.formatPrivateKey(runtime.getSetting("MERKLE_TRADE_APTOS_PRIVATE_KEY"), PrivateKeyVariants.Ed25519),
    ),
  });
  const merkleService = new MerkleService(config, merkleAccount)
  return merkleService
}

export const firstAsync = async <T>(iterable: AsyncIterable<T>): Promise<T> => {
  for await (const value of iterable) {
    return value;
  }
  throw new Error("Failed to get value from async iterable");
}

export const withTimeout = <T>(promise: Promise<T>, ms: number): Promise<T> => {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error(`Timeout: ${ms}ms exceeded`)), ms);
    promise
      .then(resolve, reject)
      .finally(() => clearTimeout(timer));
  });
}

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

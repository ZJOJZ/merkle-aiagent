"use client";

import { useState, useEffect } from "react";
import { MerkleClient, MerkleClientConfig } from "@merkletrade/ts-sdk";
import { Portfolio } from "@/components/Portfolio";
import { TradeUI } from "@/components/Trade";
import { MerkleTokenPair } from "@/components/MerklePair";

import { AgentRuntime, WalletSigner} from "../../move-agent-kit/src";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { Aptos, AptosConfig, Network, Account} from "@aptos-labs/ts-sdk"
import { MoveAIAgent } from "@/components/MoveAIAgent";

// 全局共享的 Merkle 客户端实例
export let merkle: MerkleClient;

export let aptos: Aptos;
export let signer: WalletSigner;
export let aptosAgent: AgentRuntime;

// Export 前6个交易对
export const tokenList = MerkleTokenPair.slice(0, 6);

export function Platform() {
  // Merkle客户端就绪状态
  const [isClientReady, setIsClientReady] = useState<boolean>(false);
  const [isaptosAgentReady, setIsaptosAgentReady] = useState<boolean>(false);
  
  const account = Account.generate(); //the account is useless, so create a random account for the argument
  const walletstate = useWallet();
      
  // 初始化Merkle客户端
  useEffect(() => {
    const initMerkle = async () => {
      merkle = new MerkleClient(await MerkleClientConfig.mainnet());
      setIsClientReady(true);
    };
    const initAptosAgent = async() => {
      const aptosConfig = new AptosConfig({
        network: Network.MAINNET,
      });
      aptos = new Aptos(aptosConfig);
      signer = new WalletSigner(account, walletstate, Network.MAINNET); //use walletsigner
      aptosAgent = new AgentRuntime(signer, aptos);
      setIsaptosAgentReady(true);
    };
    initMerkle();
    initAptosAgent();
  }, []);

  return (
    <div className="w-full max-w-7xl p-6">
      <div className="flex flex-row gap-10">
        <div className="flex-1">
          <Portfolio isClientReady={isClientReady} />
        </div>
        <div className="flex-1">
          <TradeUI isClientReady={isClientReady} />
        </div>
        <div className="flex-1">
          <MoveAIAgent isaptosAgentReady={isaptosAgentReady} />
        </div>
      </div>
    </div>
  );
}
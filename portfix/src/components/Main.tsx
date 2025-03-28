"use client";

import { useState, useEffect } from "react";
import { MerkleClient, MerkleClientConfig, PriceFeed } from "@merkletrade/ts-sdk";
import { Portfolio } from "@/components/Portfolio";
import { TradeUI } from "@/components/Trade";
import { MerkleTokenPair } from "@/components/MerkleTokenPair";

import { AgentRuntime, WalletSigner} from "../../move-agent-kit/src";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { Aptos, AptosConfig, Network, Account} from "@aptos-labs/ts-sdk"
import { MoveAIAgent } from "@/components/MoveAIAgent";

// 全局共享的 Merkle 客户端实例
export let merkle: MerkleClient;

export let aptos: Aptos;
export let signer: WalletSigner;
export let aptosAgent: AgentRuntime;
export const priceFeedMap: Map<string, PriceFeed> = new Map();

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
      merkle = new MerkleClient(await MerkleClientConfig.testnet());
      const session = await merkle.connectWsApi();
      tokenList.forEach(token => {
        (async () => {
          try {
            for await (const priceFeed of session.subscribePriceFeed(token.pair)) {
              priceFeedMap.set(token.pair, priceFeed);
              //console.log(`[Price Updated] ${token.pair}:`, priceFeed);
            }
          } catch (error) {
            console.error(`Subscription error for ${token.pair}:`, error);
          }
        })();
      });
      setIsClientReady(true);
    };
    const initAptosAgent = async() => {
      const aptosConfig = new AptosConfig({
        network: Network.MAINNET,
        fullnode: "https://fullnode.mainnet.aptoslabs.com/v1",
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
    <div className="w-full max-w-7xl p-10">
      <div className="flex flex-row gap-10">
        <div className="flex-1">
          <Portfolio isClientReady={isClientReady} isaptosAgentReady={isaptosAgentReady}/>
        </div>
        <div className="flex-1">
          <TradeUI isClientReady={isClientReady} isaptosAgentReady={isaptosAgentReady}/>
        </div>
      </div>
    </div>
  );
}
"use client";

import { useState, useEffect } from "react";
import { MerkleClient, MerkleClientConfig, PriceFeed } from "@merkletrade/ts-sdk";
import { Portfolio } from "@/components/Portfolio";
import { TradeUI } from "@/components/Trade";
import { MerkleTokenPair } from "@/components/MerklePair";

// 全局共享的 Merkle 客户端实例
export let merkle: MerkleClient;

export const priceFeedMap: Map<string, PriceFeed> = new Map();

// Export 前6个交易对
export const tokenList = MerkleTokenPair.slice(0, 6);


export function Platform() {
  // Merkle客户端就绪状态
  const [isClientReady, setIsClientReady] = useState<boolean>(false);

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
    
    initMerkle();
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
      </div>
    </div>
  );
}
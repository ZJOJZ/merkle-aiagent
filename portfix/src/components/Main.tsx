"use client";

import { useState, useEffect } from "react";
import { MerkleClient, MerkleClientConfig } from "@merkletrade/ts-sdk";
import { Portfolio } from "@/components/Portfolio";
import { TradeUI } from "@/components/Trade";
import { MerkleTokenPair } from "@/components/MerklePair";

// 全局共享的 Merkle 客户端实例
export let merkle: MerkleClient;

// Export 前6个交易对
export const tokenList = MerkleTokenPair.slice(0, 6);

export function Platform() {
  // Merkle客户端就绪状态
  const [isClientReady, setIsClientReady] = useState<boolean>(false);

  // 初始化Merkle客户端
  useEffect(() => {
    const initMerkle = async () => {
      merkle = new MerkleClient(await MerkleClientConfig.testnet());
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
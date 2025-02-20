"use client";

import { useState } from 'react';
import { AccountInfo } from "@/components/AccountInfo";
import { Header } from "@/components/Header";
import { MessageBoard } from "@/components/MessageBoard";
import { NetworkInfo } from "@/components/NetworkInfo";
import { TopBanner } from "@/components/TopBanner";
import { TransferAPT } from "@/components/TransferAPT";
import { WalletDetails } from "@/components/WalletDetails";

// Main Components
import { Dashboard } from "@/components/Dashboard";
import { Trade } from "@/components/Trade";

// Internal Components
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

import { MerkleTrade } from "@/components/MerkleTrade";
// Internal Components
import { useWallet } from "@aptos-labs/wallet-adapter-react";

function App() {
  const { connected } = useWallet();
  const [showDetails, setShowDetails] = useState(false);

  return (
    <>
      {/* <TopBanner /> */}
      <Header connected={connected} />
      <div className="flex items-center justify-center flex-col min-h-[calc(100vh-4rem)]">
        {connected ? (
          <div className="w-full max-w-7xl p-6">
            <div className="flex flex-row gap-10">
              <div className="flex-1">
                <Dashboard />
              </div>
              <div className="flex-1">
                <Trade />
              </div>
            </div>
          </div>
        ) : (
          <div className="w-full max-w-4xl p-8 relative">
            {/* 背景动画效果 */}
            <div className="absolute inset-0 bg-gradient-to-r from-indigo-500/10 to-cyan-500/10 rounded-lg backdrop-blur-sm">
              <div className="absolute inset-0 bg-grid-white/[0.02] bg-grid-pattern" />
            </div>

            {/* 主要内容 */}
            <div className="relative space-y-8 text-center p-8">
              <div className="space-y-4">
                <img src="/logo-line-white.svg" alt="Logo SVG" className="h-[120px] w-[120px] mx-auto" />
                <h1 className="text-5xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-indigo-500 to-cyan-500 animate-gradient">
                  Welcome to Portfix
                </h1>
                <p className="text-xl text-gray-600 dark:text-gray-300 max-w-2xl mx-auto leading-relaxed">
                  Your gateway to next-generation decentralized trading and portfolio management
                </p>
              </div>

              <div className="relative group">
                {/* 外发光效果 */}
                <div className="absolute -inset-1 bg-gradient-to-r from-indigo-500 to-cyan-500 rounded-lg blur opacity-25 group-hover:opacity-75 transition duration-1000" />

                {/* 主内容区 */}
                <div className="relative p-8 bg-gradient-to-b from-gray-900/90 to-gray-950/90 backdrop-blur-sm rounded-lg leading-none">
                  <div className="space-y-6">
                    <div className="space-y-2">
                      <h2 className="text-2xl font-semibold text-transparent bg-clip-text bg-gradient-to-r from-indigo-300 to-cyan-300">
                        Connect Your Wallet
                      </h2>
                      <p className="text-gray-400">
                        Click the "Connect Wallet" button in the top right corner to begin your journey
                      </p>
                    </div>

                    {/* 特性列表 */}
                    <div className="grid grid-cols-2 gap-4 pt-4">
                      {[
                        'Secure Trading',
                        'Portfolio Analytics',
                        'Real-time Updates',
                        'Cross-chain Support'
                      ].map((feature) => (
                        <div
                          key={feature}
                          className="flex items-center space-x-3 p-3 rounded-lg
                                   bg-gradient-to-r from-gray-800/50 to-gray-900/50
                                   border border-gray-700/30
                                   hover:border-indigo-500/30 hover:bg-gray-800/60
                                   transition-all duration-300"
                        >
                          <div className="w-1.5 h-1.5 rounded-full bg-gradient-to-r from-indigo-400 to-cyan-400 animate-pulse" />
                          <span className="text-gray-300">{feature}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {connected && (
          <Card>
            <CardContent className="flex flex-row gap-10 pt-6">
              <div className="flex-1">
                <Button onClick={() => setShowDetails(!showDetails)}>
                  {showDetails ? "Hide Account Details" : "Show Account Details"}
                </Button>
                {showDetails && (
                  <>
                    <MerkleTrade />
                    <WalletDetails />
                    <NetworkInfo />
                    <AccountInfo />
                    <TransferAPT />
                    <MessageBoard />
                  </>
                )}</div>

            </CardContent>
          </Card>
        )}
      </div>
    </>
  );
}

export default App;

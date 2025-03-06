"use client";

import { useState } from 'react';
import { AccountInfo } from "@/components/AccountInfo";
import { Header } from "@/components/Header";
import { MessageBoard } from "@/components/MessageBoard";
import { NetworkInfo } from "@/components/NetworkInfo";
import { TopBanner } from "@/components/TopBanner";
import { TransferAPT } from "@/components/TransferAPT";
import { WalletDetails } from "@/components/WalletDetails";


// Internal UI Components
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

import { Welcome } from '@/components/Welcome';



// Main Components
import { Dashboard } from "@/components/Dashboard";
import { Trade } from "@/components/Trade";
import { MerkleTrade } from "@/components/MerkleTrade";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { MoveAIAgent } from '@/components/MoveAIAgent';

function App() {
  const { connected } = useWallet();
  const [showDetails, setShowDetails] = useState(false);
  const [callAIAgent, setcallAIAgent] = useState(false);

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
          
            <Welcome />
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
                    {/* <MerkleTrade /> */}
                    <WalletDetails />
                    <NetworkInfo />
                    <AccountInfo />
                    {/* <TransferAPT /> */}
                    {/* <MessageBoard /> */}
                  </>
                )}</div>

            </CardContent>
          </Card>
        )}
      {/* 背景动画效果 */}
      <div className="fixed inset-0 -z-10 w-screen h-screen bg-gradient-to-r from-indigo-500/10 to-cyan-500/10 backdrop-blur-sm">
        <div className="absolute inset-0 w-full h-full bg-grid-white/[0.02] bg-grid-pattern" />
      </div>
      </div>
    </>
  );
}

export default App;

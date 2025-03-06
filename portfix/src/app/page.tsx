"use client";

import { useState } from 'react';

// Internal UI Components
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";



// Main Components
import { Header } from "@/components/Header";
import { Welcome } from '@/components/Welcome';
import { Dashboard } from "@/components/Dashboard";
import { Trade } from "@/components/Trade";
import { MerkleTrade } from "@/components/MerkleTrade";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { MoveAIAgent } from '@/components/MoveAIAgent';
import { AccountDetails } from '@/components/AccountDetails';

function App() {
  const { connected } = useWallet();

  return (
    <>
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
          // Welcome Page to guide connect wallet - @Runze
            <Welcome />
        )}

        {connected && (
          // After connect shows: 
          <AccountDetails />
        )}
      </div>

      {/* 背景动画效果 */}
      <div className="fixed inset-0 -z-10 w-screen h-screen bg-gradient-to-r from-indigo-500/10 to-cyan-500/10 backdrop-blur-sm">
        <div className="absolute inset-0 -z-10 w-full h-full bg-grid-white/[0.02] bg-grid-pattern" />
      </div>
    </>
  );
}

export default App;

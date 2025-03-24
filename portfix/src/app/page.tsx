"use client";

// Internal UI Components
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

// Main Components
import { Header } from "@/components/Header";
import { Welcome } from '@/components/Welcome';
import { Platform } from "@/components/Main";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { MoveAIAgent } from '@/components/MoveAIAgent';
import { AccountDetails } from '@/components/AccountDetails';

function App() {
  const { connected } = useWallet();

  return (
    <>
      <Header connected={connected} />
      
      <div className="flex items-center flex-col">
        {connected ? (
          <Platform />
        ) : (
          // Welcome Page to guide connect wallet - @Runze
          <Welcome />
        )}

        {/* {connected && (
          // After connect shows: 
          <AccountDetails />
        )} */}
      </div>

      {/* 背景动画效果 */}
      <div className="fixed inset-0 -z-10 w-screen h-screen bg-gradient-to-r from-indigo-500/10 to-cyan-500/10 backdrop-blur-sm">
        <div className="absolute inset-0 -z-10 w-full h-full bg-grid-white/[0.02] bg-grid-pattern" />
      </div>
    </>
  );
}

export default App;

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

import { useWallet } from "@aptos-labs/wallet-adapter-react";

function App() {
  const { connected } = useWallet();
  const [showDetails, setShowDetails] = useState(false);

  return (
    <>
      {/* <TopBanner /> */}
      <Header />
      <div className="flex items-center justify-center flex-col">
        {connected ? (
          <Card>
            <CardContent className="flex flex-row gap-10 pt-6">
              <div className="flex-1">
                <Dashboard />
              </div>
              <div className="flex-1">
                <Trade />
              </div>
            </CardContent>
          </Card>
          
        ) : (
          <CardHeader>
            <CardTitle>To get started Connect a wallet</CardTitle>
          </CardHeader>
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

import { useState } from 'react';
// Internal UI Components
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

// Aptos Components
import { AccountInfo } from "@/components/AccountInfo";
import { MessageBoard } from "@/components/MessageBoard";
import { NetworkInfo } from "@/components/NetworkInfo";
import { TopBanner } from "@/components/TopBanner";
import { TransferAPT } from "@/components/TransferAPT";
import { WalletDetails } from "@/components/WalletDetails";


export function AccountDetails() {

  const [showDetails, setShowDetails] = useState(false);
//   const [callAIAgent, setcallAIAgent] = useState(false);

    return (
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
    )};
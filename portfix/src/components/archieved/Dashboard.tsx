import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Landmark, TrendingUp, ChartPie , WalletMinimal} from "lucide-react"

import { useState, useEffect } from 'react'
import { getTokenPosition, getBalance } from "@/entry-functions/merkleTrade"
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { MerkleClient, MerkleClientConfig} from "@merkletrade/ts-sdk";

interface Asset {
    symbol: string
    token: string
    address: string
    amount: bigint
    avg_price: number
}

let merkle: MerkleClient;

export function Dashboard() {
    const { account, signAndSubmitTransaction } = useWallet(); 
    const [isClientReady, setIsClientReady] = useState<boolean>(false);
    const [price, setPrice] = useState<number>(0);
    const [assets, setAssets] = useState<Asset[]>([
        { symbol: 'BTC/USDC', token:'BTC_USD', address: '0x1234...5678', amount: 0n, avg_price: 0 },
        { symbol: 'ETH/USDC', token:'ETH_USD', address: '0xabcd...efgh', amount: 0n, avg_price: 0 },
        { symbol: 'SUI/USDC', token:'SUI_USD', address: '0x2345...6789', amount: 0n, avg_price: 0 },
        { symbol: 'DOGE/USDC', token:'DOGE_USD', address: '0x3456...7890', amount: 0n, avg_price: 0 },
        { symbol: 'APT/USDC', token:'APT_USD', address: '0x4567...8901', amount: 0n, avg_price: 0 },
        { symbol: 'TRUMP/USDC', token:'TRUMP_USD', address: '0x5678...9012', amount: 0n, avg_price: 0 }
    ]);

    useEffect(() => {
        const initMerkle = async () => {
            merkle = new MerkleClient(await MerkleClientConfig.testnet());
            setIsClientReady(true);
        };
        
        initMerkle();
    }, []);

    const updateAsset = async (token: string) => {
        if (!account || !isClientReady) return;
        
        const [size, price] = await getTokenPosition(token, account.address, merkle)
        //console.log(size,price);
        const newprice = Number(price) / Number(10000000000);
        //console.log(newprice, token);
        setAssets(prevAssets =>
          prevAssets.map(asset =>
            asset.token === token
              ? { ...asset, amount: BigInt(size) / 1_000_000n , avg_price: newprice}
              : asset
          )
        );
    };

    useEffect(() => {
        if (!account || !isClientReady) return;

        const myFunction = async () => {
            const nowbalance = await getBalance(account.address, merkle)
            setPrice(nowbalance)
            await updateAsset("BTC_USD")
            await updateAsset("ETH_USD")
            await updateAsset("SUI_USD")
            await updateAsset("APT_USD")
            await updateAsset("DOGE_USD")
            await updateAsset("TRUMP_USD")
        }
        
        myFunction(); // 立即执行一次
        const intervalId = setInterval(myFunction, 5000);
    
        return () => clearInterval(intervalId);
    }, [account, isClientReady]); // 添加依赖项

    if (!account || !isClientReady) {
        return null;
    }

    return (
        <div className=" mt-4 ml-4 flex flex-col gap-4 p-4 md:p-8 rounded-lg bg-card w-full max-w-[600px] max-h-[800px] overflow-auto border-2 border-white/50">
            <div className="flex items-center justify-between">
                <h2 className="text-2xl font-bold">Portfolio</h2>
                <WalletMinimal />
            </div>

            <div className="grid gap-4 md:grid-cols-2">
                <Card className="border-4 border-white/50">
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-xl font-medium">Total Value</CardTitle>
                        <Landmark />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">
                            ${price.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 3 })}
                        </div>
                    </CardContent>
                </Card>

                <Card className="border-4 border-white/50">
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-xl font-medium">24h Change</CardTitle>
                        <TrendingUp />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold text-green-500">+5.2%</div>
                    </CardContent>
                </Card>
            </div>

            <Card className="border-4 border-white/50">
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                    <CardTitle className="text-xl">Asset Breakdown</CardTitle>
                    <ChartPie />
                    {/* <div className="space-y-4"> */}
                    {/* 表头 */}
                </CardHeader>
                
                <CardContent>
                    <div className="grid grid-cols-3 items-center font-bold text-gray-400 pb-2 border-b border-gray-800">
                        <div>Type</div>
                        <div>Position</div>
                        <div>Value</div>
                    </div>
                    <div className="space-y-4">
                        {assets.map((asset: Asset, index: number) => (
                            <div key={index} className="grid grid-cols-4 items-center">
                                <div>{asset.symbol}</div>
                                {/* <div className="font-mono">{asset.address}</div> */}
                                <div>position: {asset.amount.toLocaleString('en-US')}</div>
                                <div style={{ marginLeft: 'auto', whiteSpace: 'nowrap' }}>
                                    avg_price: ${asset.avg_price.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2})}
                                </div>
                            </div>
                        ))}
                    </div>
                </CardContent>
            </Card>
        </div>
    )
}
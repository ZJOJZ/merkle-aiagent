import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { useState, useEffect } from 'react'

interface Asset {
    symbol: string
    address: string
    amount: number
    value: number
}
export function Dashboard() {
    useEffect(() => {
        const interval = setInterval(() => {
            // 生成一个随机波动值（比如在 -50 到 50 之间）
            const fluctuation = (Math.random() - 0.5) * 100
            setPrice((prev: number) => +(prev + fluctuation).toFixed(2))
        }, 500)  // 每500毫秒执行一次

        // 清理函数
        return () => clearInterval(interval)
    }, [])

    const [price, setPrice] = useState(11875.00)
    const [assets, setAssets] = useState<Asset[]>([
        { symbol: 'BTC/USDC', address: '0x1234...5678', amount: 0.15, value: 6150 },
        { symbol: 'ETH/USDC', address: '0xabcd...efgh', amount: 2.5, value: 4725 },
        { symbol: 'SUI/USDC', address: '0x2345...6789', amount: 100, value: 1500 },
        { symbol: 'DOGE/USDC', address: '0x3456...7890', amount: 1000, value: 800 },
        { symbol: 'APT/USDC', address: '0x4567...8901', amount: 50, value: 2000 },
        { symbol: 'TRUMP/USDC', address: '0x5678...9012', amount: 200, value: 1200 }
    ])

    useEffect(() => {
        const interval = setInterval(() => {
            setAssets(prevAssets => prevAssets.map(asset => ({
                ...asset,
                value: +(asset.value + (Math.random() - 0.5) * 100).toFixed(2)
            })))
        }, 500)

        return () => clearInterval(interval)
    }, [])

    return (
        <div className=" mt-4 ml-4 flex flex-col gap-4 p-4 md:p-8 rounded-lg bg-card w-full max-w-[600px] max-h-[800px] overflow-auto border-2 border-white/50">
            <div className="flex items-center justify-between">
                <h2 className="text-2xl font-bold">Portfolio Analysis</h2>
                <span className="text-blue-500">→</span>
            </div>

            <div className="grid gap-4 md:grid-cols-2">
                <Card className="border-4 border-white/50">
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Total Value</CardTitle>
                        <svg
                            xmlns="http://www.w3.org/2000/svg"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth="2"
                            className="h-4 w-4 text-green-500"
                        >
                            <path d="M7 17l9.2-9.2M17 17V7H7" />
                        </svg>
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">
                            ${price.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 3 })}
                        </div>
                    </CardContent>
                </Card>

                <Card className="border-4 border-white/50">
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">24h Change</CardTitle>
                        <div className="h-4 w-4 text-blue-500">🕒</div>
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold text-green-500">+5.2%</div>
                    </CardContent>
                </Card>
            </div>

            <Card className="border-4 border-white/50">
                <CardHeader>
                    <CardTitle>Asset Breakdown</CardTitle>
                </CardHeader>
                <CardContent>
                    <div className="space-y-4">
                        {assets.map((asset: Asset, index: number) => (
                            <div key={index} className="grid grid-cols-4 items-center">
                                <div>{asset.symbol}</div>
                                {/* <div className="font-mono">{asset.address}</div> */}
                                <div>position: {asset.amount}</div>
                                <div>value: ${asset.value.toLocaleString('en-US', { minimumFractionDigits: 2 })}</div>
                            </div>
                        ))}
                    </div>
                </CardContent>
            </Card>
        </div>
    )
}
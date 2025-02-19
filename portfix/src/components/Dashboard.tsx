'use client'

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"

export function Dashboard() {
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
                        <div className="text-2xl font-bold">$11,875.00</div>
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
                        <div className="grid grid-cols-4 items-center">
                            <div className="flex items-center gap-2">
                                <span className="text-blue-500">◆</span>
                                ETH/USDC
                            </div>
                            <div className="font-mono">0x1234...5678</div>
                            <div>2.5</div>
                            <div>$4,725.00</div>
                        </div>
                        <div className="grid grid-cols-4 items-center">
                            <div className="flex items-center gap-2">
                                <span className="text-orange-500">₿</span>
                                BTC/USDC
                            </div>
                            <div className="font-mono">0xabcd...efgh</div>
                            <div>0.15</div>
                            <div>$6,150.00</div>
                        </div>
                    </div>
                </CardContent>
            </Card>
        </div>
    )
}
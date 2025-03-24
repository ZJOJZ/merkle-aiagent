import { Landmark, TrendingUp, ChartPie, WalletMinimal } from "lucide-react";
import { Table, TableBody, TableCaption, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import * as AntIcons from '@ant-design/web3-icons';

import { useState, useEffect } from 'react';

import { getTokenPosition, getBalance } from "@/entry-functions/merkleTrade";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { merkle, tokenList } from "@/components/Main";


interface Asset {
  symbol: string;
  pair: string;
  amount: bigint;
  avg_price: number;
  pnl: number;
}

interface PortfolioProps {
  isClientReady: boolean;
}

export function Portfolio({ isClientReady }: PortfolioProps) {
  // 将symbol转换为AntDesign组件名称的映射函数
  const getIconComponentName = (symbol: string): string => {
    if (symbol.toLowerCase() === 'eth') {
      return 'EthereumCircleColorful';
    }
    const capitalizedSymbol = symbol.charAt(0).toUpperCase() + symbol.slice(1).toLowerCase();
    return `${capitalizedSymbol}CircleColorful`;
  };
  const { account } = useWallet();
  const [price, setPrice] = useState<number>(0);
  const [assets, setAssets] = useState<Asset[]>(tokenList.map(token => ({
    symbol: `${token.symbol}`,
    pair: token.pair,
    amount: 0n,
    avg_price: 0,
    pnl: 0,
  })));

  const updateAsset = async (pair: string) => {
    if (!account || !isClientReady) return;
    

  const [size, price, pnl] = await getTokenPosition(pair, account.address, merkle);
  //console.log(size, price);
  const newprice = Number(price) / Number(10000000000);
  const pnl_usd = Number(pnl) / Number(1000000);
  //console.log(newprice, pair, pnl_usd);
    
    setAssets(prevAssets =>
      prevAssets.map(asset =>
        asset.pair === pair
          ? { ...asset, amount: BigInt(size) / 1_000_000n, avg_price: newprice, pnl: Number(pnl_usd),}
          : asset
      )
    );
  };

  useEffect(() => {
    if (!account || !isClientReady) return;

    const myFunction = async () => {
      const nowbalance = await getBalance(account.address, merkle);
      setPrice(nowbalance);
      for (const token of tokenList) {
        await updateAsset(token.pair);
      }
    };
    
    myFunction();
    const intervalId = setInterval(myFunction, 5000);

    return () => clearInterval(intervalId);
  }, [account, isClientReady]);

  if (!account || !isClientReady) {
    return null;
  }

  return (
    <div className="relative group mt-4 ml-4">
      {/* div外发光效果 */}
      <div className="glow-effect" />
      
      {/* 主容器：上下左右边距、弹性布局、圆角、半透明背景、最大宽高限制、滚动条、边框 */}
      <div className="relative flex flex-col gap-4 p-4 md:p-8 rounded-lg bg-card w-full max-w-[600px] overflow-auto border">
        {/* 标题栏：两端对齐布局 */}
        <div className="flex items-center justify-between space-y-0 pb-2">
          <div className="text-2xl font-bold">Portfolio</div>
          <WalletMinimal />
        </div>

        {/* 数据卡片网格布局 */}
        <div className="grid gap-4 md:grid-cols-2">
          {/* 总价值卡片 */}
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-xl font-medium">Total Value</CardTitle>
              <Landmark />
            </CardHeader>
            <CardContent className="pt-2">
              <div className="text-2xl font-bold">
                ${price.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 3 })}
              </div>
            </CardContent>
          </Card>

          {/* 24小时变化卡片 */}
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-xl font-medium">24h Change</CardTitle>
              <TrendingUp />
            </CardHeader>
            <CardContent className="pt-2">
              <div className="text-2xl font-bold">
                +5.2%
              </div>
            </CardContent>
          </Card>
        </div>

        {/* 资产明细卡片 */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-xl font-medium">Asset Breakdown</CardTitle>
            <ChartPie />
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Asset</TableHead>
                  <TableHead>Position</TableHead>
                  <TableHead>Price</TableHead>
                  <TableHead>Pnl</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {assets.map((asset: Asset, index: number) => (
                  <TableRow key={index}>
                    <TableCell className="font-medium">
                      <div className="flex items-center gap-2">
                        {(() => {
                          const IconComponent = AntIcons[getIconComponentName(asset.symbol) as keyof typeof AntIcons];
                          return IconComponent ? <IconComponent style={{ fontSize: '24px' }} /> : null;
                        })()}
                        {asset.symbol}
                      </div>
                    </TableCell>
                    <TableCell>{asset.amount.toLocaleString('en-US')}</TableCell>
                    <TableCell>
                      ${asset.avg_price.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</TableCell>
                    <TableCell>
                      ${asset.pnl.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                    
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
import { useEffect, useState } from "react";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
// Internal components
import { toast } from "@/components/ui/use-toast";
import { aptosClient } from "@/utils/aptosClient";
import { MerkleClient, MerkleClientConfig} from "@merkletrade/ts-sdk";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { getAccountAPTBalance } from "@/view-functions/getAccountBalance";
import { OpenPosition } from "@/entry-functions/merkleTrade";

const merkle = new MerkleClient(await MerkleClientConfig.mainnet());

export function MerkleTrade() {
  const { account, signAndSubmitTransaction } = useWallet();
  const queryClient = useQueryClient();

  const [aptBalance, setAptBalance] = useState<number>(0);
  
  const [totalinput, settotalinput] = useState<bigint>(0n);

  const [islong1, setLong1] = useState<boolean>(true);
  const [islong2, setLong2] = useState<boolean>(true);
  const [islong3, setLong3] = useState<boolean>(true);
  const [islong4, setLong4] = useState<boolean>(true);
  const [islong5, setLong5] = useState<boolean>(true);
  const [islong6, setLong6] = useState<boolean>(true);
  
  const [amount1, setTransferAmount1] = useState<number>(0);
  const [amount2, setTransferAmount2] = useState<number>(0);
  const [amount3, setTransferAmount3] = useState<number>(0);
  const [amount4, setTransferAmount4] = useState<number>(0);
  const [amount5, setTransferAmount5] = useState<number>(0);
  const [amount6, setTransferAmount6] = useState<number>(0);

  const [lever1, setlever1] = useState<number>(0);
  const [lever2, setlever2] = useState<number>(0);
  const [lever3, setlever3] = useState<number>(0);
  const [lever4, setlever4] = useState<number>(0);
  const [lever5, setlever5] = useState<number>(0);
  const [lever6, setlever6] = useState<number>(0);
  
  const onClickButton = async () => {
    //console.log(amount)
    if (!account) {
      return;
    }

    try {
      const n1 = BigInt(Math.floor(amount1)) * totalinput / 100n;
      if(n1 > 10_000_000n){
      const transaction = await OpenPosition("BTC_USD", n1, islong1, lever1, account.address, merkle);
      const committedTransaction = await signAndSubmitTransaction(transaction);
      const executedTransaction = await aptosClient().waitForTransaction({transactionHash: committedTransaction.hash,});
        }
      
        const n2 = BigInt(Math.floor(amount2)) * totalinput / 100n;
      if(n2 > 10_000_000n){
      const transaction = await OpenPosition("ETH_USD", n2, islong2, lever2, account.address, merkle);
      const committedTransaction = await signAndSubmitTransaction(transaction);
      const executedTransaction = await aptosClient().waitForTransaction({transactionHash: committedTransaction.hash,});
        }
        const n3 = BigInt(Math.floor(amount3)) * totalinput / 100n;
      if(n3 > 10_000_000n){
      const transaction = await OpenPosition("APT_USD", n3, islong3, lever3, account.address, merkle);
      const committedTransaction = await signAndSubmitTransaction(transaction);
      const executedTransaction = await aptosClient().waitForTransaction({transactionHash: committedTransaction.hash,});
        }
        const n4 = BigInt(Math.floor(amount4)) * totalinput / 100n;
        if(n4 > 10_000_000n){
            const transaction = await OpenPosition("SUI_USD", n4, islong4, lever4, account.address, merkle);
            const committedTransaction = await signAndSubmitTransaction(transaction);
            const executedTransaction = await aptosClient().waitForTransaction({transactionHash: committedTransaction.hash,});
        }
        const n5 = BigInt(Math.floor(amount5)) * totalinput / 100n;
        if(n5 > 10_000_000n){
            const transaction = await OpenPosition("TRUMP_USD", n5, islong5, lever5, account.address, merkle);
            const committedTransaction = await signAndSubmitTransaction(transaction);
            const executedTransaction = await aptosClient().waitForTransaction({transactionHash: committedTransaction.hash,});
        }
        const n6 = BigInt(Math.floor(amount6)) * totalinput / 100n;
        if(n6 > 10_000_000n){
            const transaction = await OpenPosition("DOGE_USD", n6, islong6, lever6, account.address, merkle);
            const committedTransaction = await signAndSubmitTransaction(transaction);
            const executedTransaction = await aptosClient().waitForTransaction({transactionHash: committedTransaction.hash,});
        }
        queryClient.invalidateQueries({
        queryKey: ["apt-balance", account?.address],
      });

    //   toast({
    //     title: "Success",
    //     description: `Transaction succeeded, hash: ${executedTransaction.hash}`,
    //   });
    } catch (error) {
      console.error(error);
    }
  };

    useEffect(() => {
    // 定义需要定期执行的函数
        const myFunction = () => {
            const randomNumbers = Array.from({ length: 5 }, () => Math.random() * 100);
            randomNumbers.sort((a, b) => a - b);
            randomNumbers.unshift(0);
            randomNumbers.push(100);
            const portion_result = [];
            for (let i = 1; i < randomNumbers.length; i++) {
                portion_result.push(parseFloat((randomNumbers[i] - randomNumbers[i - 1]).toFixed(2)));
            }
            const randomIntegers: number[] = [];
            for (let i = 0; i < 6; i++) {
                const randomInt = Math.floor(Math.random() * (120 - 30 + 1)) + 30;
                randomIntegers.push(randomInt);
            }
            console.log(portion_result);
            setTransferAmount1(portion_result[0]);
            setTransferAmount2(portion_result[1]);
            setTransferAmount3(portion_result[2]);
            setTransferAmount4(portion_result[3]);
            setTransferAmount5(portion_result[4]);
            setTransferAmount6(portion_result[5]);

            setlever1(randomIntegers[0]);
            setlever2(randomIntegers[1]);
            setlever3(randomIntegers[2]);
            setlever4(randomIntegers[3]);
            setlever5(randomIntegers[4]);
            setlever6(randomIntegers[5]);
            
            setLong1(randomIntegers[0] > 75);
            setLong2(randomIntegers[1] > 75);
            setLong3(randomIntegers[2] > 75);
            setLong4(randomIntegers[3] > 75);
            setLong5(randomIntegers[4] > 75);
            setLong6(randomIntegers[5] > 75);
            
            
        // 在此处添加您需要执行的逻辑
        };
        const intervalId = setInterval(myFunction, 10000);

        return () => clearInterval(intervalId);
    }, []); // 空数组作为依赖，确保只在组件挂载和卸载时执行

  return (
    <div className="flex flex-col gap-6">
      Amount{" "}
      <Input disabled={!account} placeholder="1000000" onChange={(e) => settotalinput(BigInt(parseInt(e.target.value)) * 1_000_000n)} />
      <Button
        disabled={!account }
        onClick={onClickButton}
      >
        Transfer
      </Button>
    </div>
  );
}

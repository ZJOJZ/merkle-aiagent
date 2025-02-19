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

const merkle = new MerkleClient(await MerkleClientConfig.testnet());

export function MerkleTrade() {
  const { account, signAndSubmitTransaction } = useWallet();
  const queryClient = useQueryClient();

  const [aptBalance, setAptBalance] = useState<number>(0);
  const [islong, setRecipient] = useState<boolean>(true);
  const [amount, setTransferAmount] = useState<bigint>();
  const { data } = useQuery({
    queryKey: ["apt-balance", account?.address],
    refetchInterval: 10_000,
    queryFn: async () => {
      try {
        if (account === null) {
          console.error("Account not available");
        }

        const balance = await getAccountAPTBalance({ accountAddress: account!.address });

        return {
          balance,
        };
      } catch (error: any) {
        toast({
          variant: "destructive",
          title: "Error",
          description: error,
        });
        return {
          balance: 0,
        };
      }
    },
  });
  const onClickButton = async () => {
    console.log(amount)
    if (!account || !amount) {
      return;
    }

    try {
      const transaction = await OpenPosition("BTC_USD", amount, islong, 50, account.address, merkle);
      const committedTransaction = await signAndSubmitTransaction(transaction);
      const executedTransaction = await aptosClient().waitForTransaction({
        transactionHash: committedTransaction.hash,
      });
      queryClient.invalidateQueries({
        queryKey: ["apt-balance", account?.address],
      });
      toast({
        title: "Success",
        description: `Transaction succeeded, hash: ${executedTransaction.hash}`,
      });
    } catch (error) {
      console.error(error);
    }
  };

  useEffect(() => {
    if (data) {
      setAptBalance(data.balance);
    }
  }, [data]);

  return (
    <div className="flex flex-col gap-6">
      <h4 className="text-lg font-medium">APT balance: {aptBalance / Math.pow(10, 8)}</h4>
      Amount{" "}
      <Input disabled={!account} placeholder="1000000" onChange={(e) => setTransferAmount(BigInt(parseInt(e.target.value)))} />
      <Button
        disabled={!account || !amount || amount > aptBalance || amount <= 0}
        onClick={onClickButton}
      >
        Transfer
      </Button>
    </div>
  );
}

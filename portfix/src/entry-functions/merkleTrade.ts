import { MerkleClient, Position} from "@merkletrade/ts-sdk";
import { Aptos, type InputEntryFunctionData, SimpleTransaction} from "@aptos-labs/ts-sdk";
import {AccountAddressInput} from "@aptos-labs/ts-sdk";
//import type { InputTransactionData } from "@aptos-labs/wallet-adapter-react";


export async function sendTransaction(payload: InputEntryFunctionData, address: AccountAddressInput, aptos: Aptos) {
    const transaction = await aptos.transaction.build.simple({
      sender: address,
      data: payload,
    });
    return transaction;
    // const { hash } = await aptos.signAndSubmitTransaction({
    //   signer: account,
    //   transaction,
    // });
    // return await aptos.waitForTransaction({ transactionHash: hash });
  }


export async function OpenPosition(token: string, amount: bigint, side: boolean, lever: number, address: AccountAddressInput, merkle: MerkleClient) {
    const sizeDelta = amount * BigInt(lever);
    const Payload = merkle.payloads.placeMarketOrder({
        pair: token,
        userAddress: address,
        sizeDelta: sizeDelta,
        collateralDelta: amount,
        isLong: side,
        isIncrease: true,
    });
    //const aptos = new Aptos(merkle.config.aptosConfig);
    // const transaction = await aptos.transaction.build.simple({
    //     sender: address,
    //     data: Payload,
    //   });
      
    return {
        data: {
            function: Payload.function,
            functionArguments: Payload.functionArguments,
            typeArguments: Payload.typeArguments
        }
    }
    //return sendTransaction(Payload, address, aptos);
    // return {
    //     data: {
    //       function: "0x1::coin::transfer",
    //       functionArguments: [to, amount],
    //       typeArguments: ["0x1::aptos_coin::AptosCoin"],
    //     },
    //   };
};


export async function getTokenPosition(token: string, address: AccountAddressInput, merkle: MerkleClient) {
    const positions = await merkle.getPositions({
        address: `${address}` as `0x${string}`,
    });
    const position = positions.find((position) =>
       position.pairType.endsWith(token),
    );
    if(!position)
        return[0,0]
    if(position.isLong)
        return [position.size, position.avgPrice];
    else 
        return [-position.size, position.avgPrice];
}

export async function getBalance(address: AccountAddressInput, merkle: MerkleClient) {
    const usdcBalance = await merkle.getUsdcBalance({
        accountAddress: address,
    });
    return Number(usdcBalance) / 1e6
}

// export async function CloseAllPosition(token: string, account: Account, merkle: MerkleClient) {
//     const positions = await merkle.getPositions({
//         address: account.accountAddress.toString(),
//     });
//     const position = positions.find((position) =>
//         position.pairType.endsWith(token),
//     );
//     if (!position) {
//         console.log(`No positions of ${token}`);
//         //return position;
//         throw new Error(`${token} position not found`);
//     }
//     const Payload = merkle.payloads.placeMarketOrder({
//         pair: token,
//         userAddress: account.accountAddress,
//         sizeDelta: position.size,
//         collateralDelta: position.collateral,
//         isLong: position.isLong,
//         isIncrease: false,
//     });
//     const aptos = new Aptos(merkle.config.aptosConfig);
//     return await sendTransaction(Payload, account, aptos);
// };


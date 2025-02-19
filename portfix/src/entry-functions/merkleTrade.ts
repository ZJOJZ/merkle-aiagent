import { MerkleClient, MerkleClientConfig, sleep } from "@merkletrade/ts-sdk";
import { Account, Ed25519PrivateKey, PrivateKey, SimpleTransaction, 
    PrivateKeyVariants,Aptos, type InputEntryFunctionData
} from "@aptos-labs/ts-sdk";
import {AccountAddressInput} from "@aptos-labs/ts-sdk";
import type { InputTransactionData } from "@aptos-labs/wallet-adapter-react";


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
    const aptos = new Aptos(merkle.config.aptosConfig);
    const transaction = await aptos.transaction.build.simple({
        sender: address,
        data: Payload,
      });
    return {
        data: {
            function: transaction.rawTransaction.
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


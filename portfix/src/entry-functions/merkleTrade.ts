import { MerkleClient, Position, calcPnlWithoutFee} from "@merkletrade/ts-sdk";
import { Aptos, type InputEntryFunctionData, SimpleTransaction} from "@aptos-labs/ts-sdk";
import {AccountAddressInput} from "@aptos-labs/ts-sdk";
import {priceFeedMap} from "@/components/Main";
//import type { InputTransactionData } from "@aptos-labs/wallet-adapter-react";


export async function sendTransaction(payload: InputEntryFunctionData, address: AccountAddressInput, aptos: Aptos) {
    const transaction = await aptos.transaction.build.simple({
      sender: address,
      data: payload,
    });
    return transaction;
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

    //console.log(address, sizeDelta, amount, side);
    //console.log(Payload.functionArguments);
    //console.log(Payload.typeArguments);
    return {
        data: {
            function: Payload.function,
            functionArguments: Payload.functionArguments,
            typeArguments: Payload.typeArguments
        }
    }
};


export async function getTokenPosition(token: string, address: AccountAddressInput, merkle: MerkleClient) {
    const positions = await merkle.getPositions({
        address: `${address}` as `0x${string}`,
    });
    const position = positions.find((position) =>
       position.pairType.endsWith(token),
    );
    if(!position)
        return[0,0,0]
    const avgPrice = position.avgPrice;
    const isLong = position.isLong;
    const nowprice = BigInt(Math.floor(priceFeedMap.get(token).price * 10_000_000_000));
    const size = position.size;
    //console.log(token, nowprice, avgPrice)
    
    const pnl = calcPnlWithoutFee({
        position: {avgPrice, isLong},
        executePrice: nowprice as typeof position.avgPrice,
        decreaseOrder: {sizeDelta: size},
    });
    console.log("rawpnl:", pnl)
    if(isLong)
        return [size, avgPrice, pnl];
    else
        return [-size, avgPrice, pnl];
}

export async function getBalance(address: AccountAddressInput, merkle: MerkleClient) {
    const usdcBalance = await merkle.getUsdcBalance({
        accountAddress: address,
    });
    return Number(usdcBalance) / 1e6
}

export async function CloseAllPosition(token: string, address: AccountAddressInput, merkle: MerkleClient) {
    const positions = await merkle.getPositions({
        address: `${address}` as `0x${string}`,
    });
    const position = positions.find((position) =>
        position.pairType.endsWith(token),
    );
    if (!position) {
        console.log(`No positions of ${token}`);
        return
    }
    const Payload = merkle.payloads.placeMarketOrder({
        pair: token,
        userAddress: address,
        sizeDelta: position.size,
        collateralDelta: position.collateral,
        isLong: position.isLong,
        isIncrease: false,
    });
    return {
        data: {
            function: Payload.function,
            functionArguments: Payload.functionArguments,
            typeArguments: Payload.typeArguments
        }
    }

};


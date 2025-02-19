import { AptosWalletAdapterProvider } from "@aptos-labs/wallet-adapter-react";
import { BitgetWallet } from "@bitget-wallet/aptos-wallet-adapter";
// import { MartianWallet } from "@martianwallet/aptos-wallet-adapter";
// import { MSafeWalletAdapter } from "@msafe/aptos-wallet-adapter";
// import { OKXWallet } from "@okwallet/aptos-wallet-adapter";
// import { TrustWallet } from "@trustwallet/aptos-wallet-adapter";
// import { FewchaWallet } from "fewcha-plugin-wallet-adapter";
// import { PontemWallet } from "@pontem/wallet-adapter-plugin";
import { PropsWithChildren } from "react";
import { Network } from "@aptos-labs/ts-sdk";

export const WalletProvider = ({ children }: PropsWithChildren) => {
    const wallets = [
        new BitgetWallet(),
        // new FewchaWallet(),
        // new MartianWallet(),
        // new MSafeWalletAdapter(),
        // new PontemWallet(),
        // new TrustWallet(),
        // new OKXWallet(),
    ];

    return (
        <AptosWalletAdapterProvider
            plugins={wallets}
            autoConnect={true}
            dappConfig={{ network: Network.MAINNET, aptosApiKey: "aptoslabs_PEsC8tXUoL1_32YfX4ZzykP6qc5Vdfd37KuyqYMvwEKaN" }}
            onError={(error) => {
                console.log("error", error);
            }}
        >
            {children}
        </AptosWalletAdapterProvider >
    );
};
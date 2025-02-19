---
icon: play
---

# Getting Started

## Sign In

<figure><img src=".gitbook/assets/Walletless Sign-in.gif" alt="" width="563"><figcaption></figcaption></figure>

Sign in with Google or connect your web3 wallet.

For most users, signing in with Google is the easiest way to get started.

## Deposit Funds

To deposit funds, follow these simple steps:

<figure><img src=".gitbook/assets/Direct Deposit Final Final.gif" alt="" width="375"><figcaption></figcaption></figure>

1. **Select Token and Blockchain**: Once selected, a deposit address and QR code will be displayed.
2. **Transfer Funds**: Send your tokens to the provided deposit address. Make sure the chain and the address are correct, and the token is supported for deposit.
3. **Wait for Confirmation**: Most deposits complete within minutes. Ethereum and Polygon transfers may take up to 20 minutes.

### Supported Chains & Tokens

USDC, USDT, and DAI are supported for deposits. Note that USDT and DAI deposits are automatically converted to USDC. USDC is the primary token used on Merkle Trade.

|        | ETH     | ARB     | OP      | POL     | AVAX    | BSC     |
| ------ | ------- | ------- | ------- | ------- | ------- | ------- |
| USDC   | **✓**   | **✓\*** | **✓\*** | **✓\*** | **✓**   | **✓**   |
| USDC.e |         | **✓**   | **✓**   | **✓**   | **✓\*** |         |
| USDT   | **✓\*** | **✓\*** | **✓\*** | **✓\*** | **✓\*** | **✓\*** |
| DAI    | **✓\*** | **✓\*** | **✓\*** | **✓\*** |         |         |

_**✓\*** = swapped to USDC equivalent, minus fees. Large deposits may incur sizable fees._

## Withdrawals

You can withdraw funds to Ethereum, Arbitrum, Optimism, Polygon, Avalanche, BSC, and Aptos. USDC withdrawals are processed in native USDC on each respective chain.

For Arbitrum, Optimism, and Polygon, withdrawals go through a swap from USDC.e to USDC once they reach the destination chain due to bridge limitations. Note that for large withdrawals, swap fees and price impacts may be sizable (these are displayed in the withdrawal UI).

## FAQs

<details>

<summary>How does account sign-in work?</summary>

Merkle Trade is a decentralized protocol on Aptos blockchain. This means that trading on Merkle Trade is you are interacting with the protocol on the blockchain while retaining full custody of your account and balance.

_How Google sign-in works_

When you sign in with Google, your unique blockchain account is derived from your Google account credentials. Each time you trade on Merkle Trade, you sign transactions with your blockchain credentials stored in your browser. These credentials do not leave your browser and you retain full custody.

This account setup is enabled by Zero-knowledge proofs. For more information, refer to the [Aptos Keyless documentation](https://aptos.dev/en/build/guides/aptos-keyless/how-keyless-works).

</details>

<details>

<summary>Can I add Google sign-in to account created with wallet?</summary>

<img src=".gitbook/assets/Walletless-Link-Google.gif" alt="" data-size="original">

If you have an account created with a web3 wallet, you can add Google sign-in to it. Once linked, you'll be able to sign in with either Google or your web3 wallet.

We recommend **linking Google to your Aptos wallet account ONLY IF your Aptos account is used solely for Merkle Trade**. Adding Google Sign-In introduces a new authentication method, affecting the overall security of your account beyond Merkle Trade. After linking, the security of your Aptos account will be tied to the security of your Google account. Only proceed if you fully understand these security implications.

</details>

<details>

<summary>How do deposits/withdrawals work?</summary>

Direct Deposit is a decentralized solution to simplify asset onboarding from other blockchains to Aptos. Here's how it works:

* A unique EVM deposit address is deterministically derived from a given destination Aptos account address.
* Once funds are sent to the derived deposit address, a DirectDeposit contract is deployed at that address by DirectDepositFactory.
* Keeper triggers either `sendToAptos` or `swapAndSendToAptos` to swap and transfer the asset to the Aptos Bridge (via LayerZero), with the final destination being the Aptos address.
* Withdrawals go through a similar process in reverse. For ARB/OP/POL, the bridged token (USDC.e) is swapped to native USDC upon bridging before sent to destination address.

The DirectDeposit smart contract, developed by the Merkle Trade team, has been fully [audited by OtterSec](https://osec.io) for security and the code is [publicly available on GitHub](https://github.com/merkle-trade/merkle-evm).

</details>

<details>

<summary>Why haven’t I received my deposit/withdrawal?</summary>

Deposit processing times by blockchain (average):

* Arbitrum: < 1 minute
* Optimism: < 1 minute
* BSC: 3 minutes
* Avalanche: 5 minutes
* Ethereum: < 20 minutes
* Polygon: < 20 minutes

Withdrawal processing time (average): < 3 minutes

If your deposit/withdrawal has not arrived within the above estimate, please reach out to community support by creating a ticket on Discord.

</details>

<details>

<summary>What are the minimum/maximum deposit limits?</summary>

Deposit limits vary by blockchain, with a typical minimum deposit of around $3. However, this amount may fluctuate based on current gas fees and LayerZero bridge fees.

For the most up-to-date information, please refer to the Direct Deposit page on the Merkle Trade platform.

</details>

<details>

<summary>Are there any deposit fees?</summary>

Yes, a small deposit fee (usually less than $1) is applied to cover bridge and gas fees.

Fees may vary by blockchain and can change based on current network congestion. For the latest fee details, please refer to the fees displayed on the Direct Deposit page.

</details>

<details>

<summary>Why did my funds get deposited as USDC?</summary>

Merkle Trade currently supports USDC only. Transferred assets are converted to USDC and credited to your account in USDC.

</details>

<details>

<summary>Are there any withdrawal fees?</summary>

Yes, withdrawals incur fees to cover bridging and token swaps when necessary:

* Bridge Fees: he underlying bridge (Aptos Bridge) charges 7bps fee to the withdrawal amount, and a base bridge fee which varies by destination chain and current gas price.
* Native USDC Swap Fee: For Arbitrum, Optimism, and Polygon, withdrawals go through a swap from USDC.e to USDC once they reach the destination chain.

In normal conditions, withdrawing $1000 to Arbitrum costs less than $1.

Note that for large withdrawals, these fees may become sizable (these are displayed in the withdrawal UI).

</details>

<details>

<summary>I can no longer enable 1-click trading feature (Aptos wallet)</summary>

The 1-Click Trading feature has been sunset.

If you primarily use your Aptos account exclusively for Merkle Trade, we recommend [linking your Google account](getting-started.md#can-i-add-google-sign-in-to-account-created-with-wallet) for easier sign-in and a smoother trading experience moving forward.

If you’d like to continue using the Aptos wallet with the 1-Click Trading experience (without Google sign-in), we plan to offer a more secure solution in the future. For now, if you really want to use 1-Click Trading with your Aptos wallet, please reach out to the devs on Discord.

</details>

<details>

<summary>Can sign in with EVM wallet?</summary>

We have temporarily paused support for EVM wallets for sign-in while we work on a better solution for onboarding EVM wallet users.

Users who previously signed in with an EVM wallet can still do so. However, we recommend linking a Google account for easier access, as we plan to phase out EVM wallet support in the long run.

</details>


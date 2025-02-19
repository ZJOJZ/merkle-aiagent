# Contract Addresses

### Deployer Account

```
0x5ae6789dd2fec1a9ec9cccfb3acaf12e93d432f0a3a42c92fe1a9d490b7bbc06
```

All move modules (smart contracts) related to Merkle Trade protocol are deployed under the deployer account.

### Token Addresses

{% hint style="info" %}
**Fungible Asset vs Coin**: On the Aptos blockchain, there are two standards for fungible tokens: [Fungible Asset](https://aptos.dev/en/build/smart-contracts/fungible-asset) (the new standard) and [Coin](https://aptos.dev/en/build/smart-contracts/aptos-coin) (the legacy standard).

For the MKL token, there are two addresses—one for the Fungible Asset and one for the Coin—but they both represent the same token. Please refer to the [Aptos docs](https://aptos.dev/en/build/smart-contracts/fungible-asset#migration-from-coin-to-the-fungible-asset-standard) for more info about the migration.
{% endhint %}

#### MKL

Fungible Asset\
`0x878370592f9129e14b76558689a4b570ad22678111df775befbfcbc9fb3d90ab`

Coin (legacy)\
`0x5ae6789dd2fec1a9ec9cccfb3acaf12e93d432f0a3a42c92fe1a9d490b7bbc06::mkl_token::MKL`

#### MKLP Token

Coin (legacy)\
`0x5ae6789dd2fec1a9ec9cccfb3acaf12e93d432f0a3a42c92fe1a9d490b7bbc06::house_lp::MKLP<0xf22bede237a07e121b56d91a491eb7bcdfd1f5907926a9e58338f964a01b17fa::asset::USDC>`

#### esMKL

Fungible Asset\
`0x3b5200e090d188c274e06b0d64b3f66638fb996fb0b350499975ff36b1f4595`


// 交易对定义
export const MerkleTokenPair = [
    {
      symbol: "BTC",
      pair: "BTC_USD",
      fee: "0.03% / 0.06%",
      minimumPay: 300,
      leverage: "3 - 150",
      maxOI: 500000,
      skewFactor: 333333333.333333,
      category: "Crypto"
    },
    {
      symbol: "ETH",
      pair: "ETH_USD",
      fee: "0.03% / 0.06%",
      minimumPay: 300,
      leverage: "3 - 150",
      maxOI: 500000,
      skewFactor: 333333333.333333,
      category: "Crypto"
    },
    {
      symbol: "APT",
      pair: "APT_USD",
      fee: "0.04% / 0.08%",
      minimumPay: 300,
      leverage: "3 - 150",
      maxOI: 150000,
      skewFactor: 60000000,
      category: "Crypto"
    },
    {
      symbol: "SUI",
      pair: "SUI_USD",
      fee: "0.04% / 0.08%",
      minimumPay: 300,
      leverage: "3 - 150",
      maxOI: 150000,
      skewFactor: 60000000,
      category: "Crypto"
    },
    // {
    //   symbol: "MELANIA",
    //   pair: "MELANIA_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 100000,
    //   skewFactor: 30000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "TRUMP",
    //   pair: "TRUMP_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 100000,
    //   skewFactor: 30000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "AI16Z",
    //   pair: "AI16Z_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 100000,
    //   skewFactor: 30000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "VIRTUAL",
    //   pair: "VIRTUAL_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 100000,
    //   skewFactor: 30000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "ADA",
    //   pair: "ADA_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 200000,
    //   skewFactor: 100000000,
    //   category: "Crypto"
    // },
    {
      symbol: "XRP",
      pair: "XRP_USD",
      fee: "0.04% / 0.08%",
      minimumPay: 300,
      leverage: "3 - 150",
      maxOI: 200000,
      skewFactor: 100000000,
      category: "Crypto"
    },
    // {
    //   symbol: "NEIRO",
    //   pair: "NEIRO_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 100000,
    //   skewFactor: 30000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "DOGS",
    //   pair: "DOGS_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 100000,
    //   skewFactor: 30000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "PNUT",
    //   pair: "PNUT_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 100000,
    //   skewFactor: 30000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "FLOKI",
    //   pair: "FLOKI_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 100000,
    //   skewFactor: 30000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "BOME",
    //   pair: "BOME_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 100000,
    //   skewFactor: 30000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "LTC",
    //   pair: "LTC_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 150000,
    //   skewFactor: 45000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "DOGE",
    //   pair: "DOGE_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 200000,
    //   skewFactor: 100000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "EIGEN",
    //   pair: "EIGEN_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 150000,
    //   skewFactor: 45000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "TAO",
    //   pair: "TAO_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 150000,
    //   skewFactor: 30000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "ZRO",
    //   pair: "ZRO_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 100000,
    //   skewFactor: 45000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "OP",
    //   pair: "OP_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 150000,
    //   skewFactor: 60000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "SHIB",
    //   pair: "SHIB_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 100000,
    //   skewFactor: 20000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "TON",
    //   pair: "TON_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 150000,
    //   skewFactor: 30000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "BONK",
    //   pair: "BONK_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 150000,
    //   skewFactor: 30000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "HBAR",
    //   pair: "HBAR_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 150000,
    //   skewFactor: 60000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "ENA",
    //   pair: "ENA_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 150000,
    //   skewFactor: 30000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "W",
    //   pair: "W_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 150000,
    //   skewFactor: 45000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "PEPE",
    //   pair: "PEPE_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 100000,
    //   skewFactor: 20000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "LINK",
    //   pair: "LINK_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 200000,
    //   skewFactor: 100000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "WIF",
    //   pair: "WIF_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 100000,
    //   skewFactor: 20000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "WLD",
    //   pair: "WLD_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 100000,
    //   skewFactor: 30000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "STARK",
    //   pair: "STARK_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 100000,
    //   skewFactor: 30000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "INJ",
    //   pair: "INJ_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 150000,
    //   skewFactor: 45000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "JUP",
    //   pair: "JUP_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 100000,
    //   skewFactor: 30000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "MANTA",
    //   pair: "MANTA_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 150000,
    //   skewFactor: 60000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "SEI",
    //   pair: "SEI_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 150000,
    //   skewFactor: 60000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "AVAX",
    //   pair: "AVAX_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 200000,
    //   skewFactor: 100000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "BLUR",
    //   pair: "BLUR_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 100000,
    //   skewFactor: 30000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "PYTH",
    //   pair: "PYTH_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 100000,
    //   skewFactor: 30000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "MEME",
    //   pair: "MEME_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 100000,
    //   skewFactor: 15000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "TIA",
    //   pair: "TIA_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 150000,
    //   skewFactor: 60000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "BNB",
    //   pair: "BNB_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 200000,
    //   skewFactor: 100000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "MATIC",
    //   pair: "MATIC_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 200000,
    //   skewFactor: 100000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "SOL",
    //   pair: "SOL_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 200000,
    //   skewFactor: 100000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "ARB",
    //   pair: "ARB_USD",
    //   fee: "0.04% / 0.08%",
    //   minimumPay: 300,
    //   leverage: "3 - 150",
    //   maxOI: 150000,
    //   skewFactor: 60000000,
    //   category: "Crypto"
    // },
    // {
    //   symbol: "EUR",
    //   pair: "EUR_USD",
    //   fee: "0.0075% / 0.0125%",
    //   minimumPay: 1500,
    //   leverage: "10 - 1000",
    //   maxOI: 1000000,
    //   skewFactor: 5000000000,
    //   category: "Forex"
    // },
    // {
    //   symbol: "JPY",
    //   pair: "USD_JPY",
    //   fee: "0.0075% / 0.0125%",
    //   minimumPay: 1500,
    //   leverage: "10 - 1000",
    //   maxOI: 1000000,
    //   skewFactor: 5000000000,
    //   category: "Forex"
    // },
    // {
    //   symbol: "GBP",
    //   pair: "GBP_USD",
    //   fee: "0.0075% / 0.0125%",
    //   minimumPay: 1500,
    //   leverage: "10 - 1000",
    //   maxOI: 1000000,
    //   skewFactor: 5000000000,
    //   category: "Forex"
    // },
    // {
    //   symbol: "AUD",
    //   pair: "AUD_USD",
    //   fee: "0.0075% / 0.0125%",
    //   minimumPay: 1500,
    //   leverage: "10 - 1000",
    //   maxOI: 500000,
    //   skewFactor: 2000000000,
    //   category: "Forex"
    // },
    // {
    //   symbol: "NZD",
    //   pair: "NZD_USD",
    //   fee: "0.0075% / 0.0125%",
    //   minimumPay: 1500,
    //   leverage: "10 - 1000",
    //   maxOI: 500000,
    //   skewFactor: 2000000000,
    //   category: "Forex"
    // },
    // {
    //   symbol: "CAD",
    //   pair: "USD_CAD",
    //   fee: "0.0075% / 0.0125%",
    //   minimumPay: 1500,
    //   leverage: "10 - 1000",
    //   maxOI: 500000,
    //   skewFactor: 2000000000,
    //   category: "Forex"
    // },
    // {
    //   symbol: "CHF",
    //   pair: "USD_CHF",
    //   fee: "0.0075% / 0.0125%",
    //   minimumPay: 1500,
    //   leverage: "10 - 1000",
    //   maxOI: 500000,
    //   skewFactor: 2000000000,
    //   category: "Forex"
    // },
    // {
    //   symbol: "XAU",
    //   pair: "XAU_USD",
    //   fee: "0.04% / 0.06%",
    //   minimumPay: 600,
    //   leverage: "5 - 250",
    //   maxOI: 800000,
    //   skewFactor: 800000000,
    //   category: "Commodities"
    // },
    // {
    //   symbol: "XAG",
    //   pair: "XAG_USD",
    //   fee: "0.04% / 0.06%",
    //   minimumPay: 600,
    //   leverage: "5 - 150",
    //   maxOI: 400000,
    //   skewFactor: 320000000,
    //   category: "Commodities"
    // }
  ];
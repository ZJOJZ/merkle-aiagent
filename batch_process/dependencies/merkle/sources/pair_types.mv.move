module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pair_types {
    struct ADA_USD {
        dummy_field: bool,
    }
    
    struct AI16Z_USD {
        dummy_field: bool,
    }
    
    struct APT_USD {
        dummy_field: bool,
    }
    
    struct ARB_USD {
        dummy_field: bool,
    }
    
    struct AUD_USD {
        dummy_field: bool,
    }
    
    struct AVAX_USD {
        dummy_field: bool,
    }
    
    struct BCH_USD {
        dummy_field: bool,
    }
    
    struct BLUR_USD {
        dummy_field: bool,
    }
    
    struct BNB_USD {
        dummy_field: bool,
    }
    
    struct BOME_USD {
        dummy_field: bool,
    }
    
    struct BONK_USD {
        dummy_field: bool,
    }
    
    struct BTC_USD {
        dummy_field: bool,
    }
    
    struct DOGE_USD {
        dummy_field: bool,
    }
    
    struct DOGS_USD {
        dummy_field: bool,
    }
    
    struct EIGEN_USD {
        dummy_field: bool,
    }
    
    struct ENA_USD {
        dummy_field: bool,
    }
    
    struct ETH_USD {
        dummy_field: bool,
    }
    
    struct EUR_USD {
        dummy_field: bool,
    }
    
    struct FLOKI_USD {
        dummy_field: bool,
    }
    
    struct GBP_USD {
        dummy_field: bool,
    }
    
    struct HBAR_USD {
        dummy_field: bool,
    }
    
    struct INJ_USD {
        dummy_field: bool,
    }
    
    struct IP_USD {
        dummy_field: bool,
    }
    
    struct JUP_USD {
        dummy_field: bool,
    }
    
    struct KAITO_USD {
        dummy_field: bool,
    }
    
    struct LINK_USD {
        dummy_field: bool,
    }
    
    struct LTC_USD {
        dummy_field: bool,
    }
    
    struct MANTA_USD {
        dummy_field: bool,
    }
    
    struct MATIC_USD {
        dummy_field: bool,
    }
    
    struct MELANIA_USD {
        dummy_field: bool,
    }
    
    struct MEME_USD {
        dummy_field: bool,
    }
    
    struct NEIRO_USD {
        dummy_field: bool,
    }
    
    struct NZD_USD {
        dummy_field: bool,
    }
    
    struct OP_USD {
        dummy_field: bool,
    }
    
    struct PEPE_USD {
        dummy_field: bool,
    }
    
    struct PNUT_USD {
        dummy_field: bool,
    }
    
    struct PYTH_USD {
        dummy_field: bool,
    }
    
    struct REZ_USD {
        dummy_field: bool,
    }
    
    struct SEI_USD {
        dummy_field: bool,
    }
    
    struct SHIB_USD {
        dummy_field: bool,
    }
    
    struct SOL_USD {
        dummy_field: bool,
    }
    
    struct STRK_USD {
        dummy_field: bool,
    }
    
    struct SUI_USD {
        dummy_field: bool,
    }
    
    struct TAO_USD {
        dummy_field: bool,
    }
    
    struct TIA_USD {
        dummy_field: bool,
    }
    
    struct TON_USD {
        dummy_field: bool,
    }
    
    struct TRUMP_USD {
        dummy_field: bool,
    }
    
    struct USD_CAD {
        dummy_field: bool,
    }
    
    struct USD_CHF {
        dummy_field: bool,
    }
    
    struct USD_JPY {
        dummy_field: bool,
    }
    
    struct VIRTUAL_USD {
        dummy_field: bool,
    }
    
    struct WIF_USD {
        dummy_field: bool,
    }
    
    struct WLD_USD {
        dummy_field: bool,
    }
    
    struct W_USD {
        dummy_field: bool,
    }
    
    struct XAG_USD {
        dummy_field: bool,
    }
    
    struct XAU_USD {
        dummy_field: bool,
    }
    
    struct XRP_USD {
        dummy_field: bool,
    }
    
    struct ZRO_USD {
        dummy_field: bool,
    }
    
    public fun check_target<T0>(arg0: 0x1::string::String) : bool {
        let v0 = vector[b"CRYPTO", b"FOREX", b"COMMODITY"];
        let (v1, v2) = 0x1::vector::index_of<vector<u8>>(&v0, 0x1::string::bytes(&arg0));
        if (v1) {
            if (v2 == 0) {
                let v3 = vector[b"BTC_USD", b"ETH_USD", b"APT_USD", b"BNB_USD", b"DOGE_USD", b"MATIC_USD", b"SOL_USD", b"ARB_USD", b"SUI_USD", b"TIA_USD", b"MEME_USD", b"PYTH_USD", b"BLUR_USD", b"AVAX_USD", b"SEI_USD", b"MANTA_USD", b"JUP_USD", b"INJ_USD", b"STRK_USD", b"WLD_USD", b"WIF_USD", b"PEPE_USD", b"LINK_USD", b"W_USD", b"ENA_USD", b"HBAR_USD", b"BONK_USD", b"TON_USD", b"SHIB_USD", b"OP_USD", b"ZRO_USD", b"TAO_USD", b"EIGEN_USD", b"PNUT_USD", b"FLOKI_USD", b"BOME_USD", b"LTC_USD", b"NEIRO_USD", b"DOGS_USD", b"XRP_USD", b"ADA_USD", b"AI16Z_USD", b"VIRTUAL_USD", b"TRUMP_USD", b"MELANIA_USD", b"KAITO_USD"];
                let v4 = 0x1::type_info::type_of<T0>();
                let v5 = 0x1::type_info::struct_name(&v4);
                return 0x1::vector::contains<vector<u8>>(&v3, &v5)
            };
            if (v2 == 1) {
                let v6 = vector[b"USD_JPY", b"EUR_USD", b"GBP_USD", b"AUD_USD", b"NZD_USD", b"USD_CAD", b"USD_CHF"];
                let v7 = 0x1::type_info::type_of<T0>();
                let v8 = 0x1::type_info::struct_name(&v7);
                return 0x1::vector::contains<vector<u8>>(&v6, &v8)
            };
            let v9 = vector[b"XAU_USD", b"XAG_USD"];
            let v10 = 0x1::type_info::type_of<T0>();
            let v11 = 0x1::type_info::struct_name(&v10);
            return 0x1::vector::contains<vector<u8>>(&v9, &v11)
        };
        let v12 = 0x1::type_info::type_of<T0>();
        0x1::type_info::struct_name(&v12) == *0x1::string::bytes(&arg0)
    }
    
    public fun get_class_name(arg0: u64) : vector<u8> {
        let v0 = vector[b"CRYPTO", b"FOREX", b"COMMODITY"];
        *0x1::vector::borrow<vector<u8>>(&v0, arg0)
    }
    
    public fun get_pair_name(arg0: u64) : vector<u8> {
        let v0 = vector[b"BTC_USD", b"ETH_USD", b"APT_USD", b"BNB_USD", b"DOGE_USD", b"MATIC_USD", b"SOL_USD", b"ARB_USD", b"SUI_USD", b"USD_JPY", b"EUR_USD", b"GBP_USD", b"AUD_USD", b"NZD_USD", b"USD_CAD", b"USD_CHF", b"XAU_USD", b"XAG_USD", b"TIA_USD", b"MEME_USD", b"PYTH_USD", b"BLUR_USD", b"AVAX_USD", b"SEI_USD", b"MANTA_USD", b"JUP_USD", b"INJ_USD", b"STRK_USD", b"WLD_USD", b"WIF_USD", b"PEPE_USD", b"LINK_USD", b"W_USD", b"ENA_USD", b"HBAR_USD", b"BONK_USD", b"TON_USD", b"SHIB_USD", b"OP_USD", b"ZRO_USD", b"TAO_USD", b"EIGEN_USD", b"PNUT_USD", b"FLOKI_USD", b"BOME_USD", b"LTC_USD", b"NEIRO_USD", b"DOGS_USD", b"XRP_USD", b"ADA_USD", b"AI16Z_USD", b"VIRTUAL_USD", b"TRUMP_USD", b"MELANIA_USD", b"KAITO_USD"];
        *0x1::vector::borrow<vector<u8>>(&v0, arg0)
    }
    
    public fun len_pair() : u64 {
        let v0 = vector[b"BTC_USD", b"ETH_USD", b"APT_USD", b"BNB_USD", b"DOGE_USD", b"MATIC_USD", b"SOL_USD", b"ARB_USD", b"SUI_USD", b"USD_JPY", b"EUR_USD", b"GBP_USD", b"AUD_USD", b"NZD_USD", b"USD_CAD", b"USD_CHF", b"XAU_USD", b"XAG_USD", b"TIA_USD", b"MEME_USD", b"PYTH_USD", b"BLUR_USD", b"AVAX_USD", b"SEI_USD", b"MANTA_USD", b"JUP_USD", b"INJ_USD", b"STRK_USD", b"WLD_USD", b"WIF_USD", b"PEPE_USD", b"LINK_USD", b"W_USD", b"ENA_USD", b"HBAR_USD", b"BONK_USD", b"TON_USD", b"SHIB_USD", b"OP_USD", b"ZRO_USD", b"TAO_USD", b"EIGEN_USD", b"PNUT_USD", b"FLOKI_USD", b"BOME_USD", b"LTC_USD", b"NEIRO_USD", b"DOGS_USD", b"XRP_USD", b"ADA_USD", b"AI16Z_USD", b"VIRTUAL_USD", b"TRUMP_USD", b"MELANIA_USD", b"KAITO_USD"];
        0x1::vector::length<vector<u8>>(&v0)
    }
    
    public fun len_pair_class() : u64 {
        let v0 = vector[b"CRYPTO", b"FOREX", b"COMMODITY"];
        0x1::vector::length<vector<u8>>(&v0)
    }
    
    // decompiled from Move bytecode v6
}


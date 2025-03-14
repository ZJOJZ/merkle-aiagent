module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::test_trading {
    struct FaucetEvent has copy, drop, store {
        amount: u64,
    }
    
    struct FaucetEvents has key {
        faucet_events: 0x1::event::EventHandle<FaucetEvent>,
    }
    
    struct TEST_USDC has drop, store {
        dummy_field: bool,
    }
    
    struct TEST_USDC2 has drop, store {
        dummy_field: bool,
    }
    
    struct TEST_USDC_INFO<phantom T0> has store, key {
        mint_cap: 0x1::coin::MintCapability<T0>,
        limit_faucet: bool,
        limit_faucet_amount: u64,
        last_faucet: 0x1::table::Table<address, u64>,
        faucet_amount: 0x1::table::Table<address, u64>,
    }
    
    struct TestNativeUsdcRefs has key {
        mint_ref: 0x1::fungible_asset::MintRef,
        burn_ref: 0x1::fungible_asset::BurnRef,
        transfer_ref: 0x1::fungible_asset::TransferRef,
    }
    
    public entry fun faucet_coin<T0>(arg0: &signer, arg1: u64) acquires TEST_USDC_INFO {
        0x1::aptos_account::deposit_coins<T0>(0x1::signer::address_of(arg0), 0x1::coin::mint<T0>(arg1, &borrow_global<TEST_USDC_INFO<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).mint_cap));
    }
    
    public entry fun faucet_native_coin(arg0: &signer, arg1: u64) {
        abort 0
    }
    
    public entry fun faucet_native_usdc(arg0: &signer, arg1: u64) acquires TestNativeUsdcRefs {
        0x1::primary_fungible_store::deposit(0x1::signer::address_of(arg0), 0x1::fungible_asset::mint(&borrow_global<TestNativeUsdcRefs>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).mint_ref, arg1));
    }
    
    fun init_module(arg0: &signer) {
        let (v0, v1, v2) = 0x1::coin::initialize<TEST_USDC>(arg0, 0x1::string::utf8(b"tUSDC"), 0x1::string::utf8(b"tUSDC"), 6, false);
        0x1::coin::destroy_burn_cap<TEST_USDC>(v0);
        0x1::coin::destroy_freeze_cap<TEST_USDC>(v1);
        0x1::coin::register<TEST_USDC>(arg0);
        let v3 = TEST_USDC_INFO<TEST_USDC>{
            mint_cap            : v2, 
            limit_faucet        : false, 
            limit_faucet_amount : 1000 * 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::exp(10, 6), 
            last_faucet         : 0x1::table::new<address, u64>(), 
            faucet_amount       : 0x1::table::new<address, u64>(),
        };
        move_to<TEST_USDC_INFO<TEST_USDC>>(arg0, v3);
        0x1::coin::destroy_mint_cap<TEST_USDC>(v2);
        let (v4, v5, v6) = 0x1::coin::initialize<TEST_USDC2>(arg0, 0x1::string::utf8(b"pUSDC"), 0x1::string::utf8(b"pUSDC"), 6, false);
        0x1::coin::destroy_burn_cap<TEST_USDC2>(v4);
        0x1::coin::destroy_freeze_cap<TEST_USDC2>(v5);
        0x1::coin::register<TEST_USDC2>(arg0);
        let v7 = TEST_USDC_INFO<TEST_USDC2>{
            mint_cap            : v6, 
            limit_faucet        : false, 
            limit_faucet_amount : 1000 * 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::exp(10, 6), 
            last_faucet         : 0x1::table::new<address, u64>(), 
            faucet_amount       : 0x1::table::new<address, u64>(),
        };
        move_to<TEST_USDC_INFO<TEST_USDC2>>(arg0, v7);
        0x1::coin::destroy_mint_cap<TEST_USDC2>(v6);
        initialize_fa_usdc_refs(arg0);
    }
    
    public entry fun initialize_fa_usdc_refs(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        if (exists<TestNativeUsdcRefs>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = 0x1::object::create_named_object(arg0, b"nUSDC");
            let v1 = &v0;
            0x1::primary_fungible_store::create_primary_store_enabled_fungible_asset(v1, 0x1::option::none<u128>(), 0x1::string::utf8(b"nUSDC"), 0x1::string::utf8(b"nUSDC"), 6, 0x1::string::utf8(b""), 0x1::string::utf8(b""));
            let v2 = TestNativeUsdcRefs{
                mint_ref     : 0x1::fungible_asset::generate_mint_ref(v1), 
                burn_ref     : 0x1::fungible_asset::generate_burn_ref(v1), 
                transfer_ref : 0x1::fungible_asset::generate_transfer_ref(v1),
            };
            move_to<TestNativeUsdcRefs>(arg0, v2);
        };
    }
    
    public entry fun set_limit_faucet<T0>(arg0: &signer, arg1: bool) acquires TEST_USDC_INFO {
        let v0 = 0x1::signer::address_of(arg0);
        assert!(v0 == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        borrow_global_mut<TEST_USDC_INFO<T0>>(v0).limit_faucet = arg1;
    }
    
    public entry fun set_limit_faucet_amount<T0>(arg0: &signer, arg1: u64) acquires TEST_USDC_INFO {
        let v0 = 0x1::signer::address_of(arg0);
        assert!(v0 == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        borrow_global_mut<TEST_USDC_INFO<T0>>(v0).limit_faucet_amount = arg1;
    }
    
    // decompiled from Move bytecode v6
}


module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token {
    struct ClaimCapability has drop, store {
        dummy_field: bool,
    }
    
    struct PoolStore has key {
        pre_mkl: 0x1::object::Object<0x1::fungible_asset::FungibleStore>,
    }
    
    struct GrowthFundRecipt has drop, store {
        initial_amount: u64,
        swapped_amount: u64,
    }
    
    struct GrowthFundResource has key {
        user: 0x1::table::Table<address, GrowthFundRecipt>,
        mkl_cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::ClaimCapability<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::GROWTH_POOL>,
    }
    
    struct PreMKL {
        dummy_field: bool,
    }
    
    struct PreMklConfig has key {
        mint_ref: 0x1::fungible_asset::MintRef,
        transfer_ref: 0x1::fungible_asset::TransferRef,
        burn_ref: 0x1::fungible_asset::BurnRef,
        mkl_cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::ClaimCapability<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::COMMUNITY_POOL>,
    }
    
    public fun get_metadata() : 0x1::object::Object<0x1::fungible_asset::Metadata> {
        let v0 = @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d;
        0x1::object::address_to_object<0x1::fungible_asset::Metadata>(0x1::object::create_object_address(&v0, b"PreMKL"))
    }
    
    public fun mint_claim_capability(arg0: &signer) : ClaimCapability {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        ClaimCapability{dummy_field: false}
    }
    
    public fun admin_swap_premkl_to_mkl(arg0: &signer, arg1: address) acquires GrowthFundResource, PreMklConfig {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        swap_premkl_to_mkl_internal(arg1);
    }
    
    public(friend) fun burn_pre_mkl_claim_mkl(arg0: 0x1::fungible_asset::FungibleAsset) : 0x1::fungible_asset::FungibleAsset acquires PreMklConfig {
        assert!(0x1::timestamp::now_seconds() >= 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::mkl_tge_at(), 1);
        assert!(0x1::fungible_asset::metadata_from_asset(&arg0) == get_metadata(), 1);
        let v0 = 0x1::fungible_asset::amount(&arg0);
        let v1 = borrow_global<PreMklConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (v0 > 0) {
            0x1::fungible_asset::burn(&v1.burn_ref, arg0);
        } else {
            0x1::fungible_asset::destroy_zero(arg0);
        };
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::claim_mkl_with_cap<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::COMMUNITY_POOL>(&v1.mkl_cap, v0)
    }
    
    public(friend) fun burn_pre_mkl_claim_mkl_with_ref_cap<T0>(arg0: 0x1::fungible_asset::FungibleAsset, arg1: &0x1::fungible_asset::BurnRef, arg2: &0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::ClaimCapability<T0>) : 0x1::fungible_asset::FungibleAsset {
        assert!(0x1::timestamp::now_seconds() >= 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::mkl_tge_at(), 1);
        assert!(0x1::fungible_asset::metadata_from_asset(&arg0) == get_metadata(), 1);
        let v0 = 0x1::fungible_asset::amount(&arg0);
        if (v0 > 0) {
            0x1::fungible_asset::burn(arg1, arg0);
        } else {
            0x1::fungible_asset::destroy_zero(arg0);
        };
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::claim_mkl_with_cap<T0>(arg2, v0)
    }
    
    public fun claim_pre_mkl_with_cap(arg0: &ClaimCapability, arg1: u64) : 0x1::fungible_asset::FungibleAsset acquires PoolStore, PreMklConfig {
        assert!(0x1::timestamp::now_seconds() >= pre_mkl_tge_at() && 0x1::timestamp::now_seconds() < 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::mkl_tge_at() + 2419200, 2);
        0x1::fungible_asset::withdraw_with_ref<0x1::fungible_asset::FungibleStore>(&borrow_global<PreMklConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).transfer_ref, borrow_global<PoolStore>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).pre_mkl, arg1)
    }
    
    public fun claim_user_pre_mkl(arg0: &ClaimCapability, arg1: address, arg2: u64) acquires PoolStore, PreMklConfig {
        let v0 = claim_pre_mkl_with_cap(arg0, arg2);
        let v1 = borrow_global<PreMklConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::primary_fungible_store::is_frozen<0x1::fungible_asset::Metadata>(arg1, get_metadata())) {
        } else {
            0x1::primary_fungible_store::set_frozen_flag(&v1.transfer_ref, arg1, true);
        };
        0x1::primary_fungible_store::deposit_with_ref(&v1.transfer_ref, arg1, v0);
    }
    
    public fun deploy_pre_mkl_from_growth_fund(arg0: &signer, arg1: address, arg2: u64) acquires GrowthFundResource, PreMklConfig {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        if (exists<GrowthFundResource>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = GrowthFundResource{
                user    : 0x1::table::new<address, GrowthFundRecipt>(), 
                mkl_cap : 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::mint_claim_capability<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::GROWTH_POOL>(arg0),
            };
            move_to<GrowthFundResource>(arg0, v0);
        };
        let v1 = GrowthFundRecipt{
            initial_amount : 0, 
            swapped_amount : 0,
        };
        let v2 = 0x1::table::borrow_mut_with_default<address, GrowthFundRecipt>(&mut borrow_global_mut<GrowthFundResource>(0x1::signer::address_of(arg0)).user, arg1, v1);
        v2.initial_amount = v2.initial_amount + arg2;
        let v3 = borrow_global<PreMklConfig>(0x1::signer::address_of(arg0));
        if (0x1::primary_fungible_store::is_frozen<0x1::fungible_asset::Metadata>(arg1, get_metadata())) {
        } else {
            0x1::primary_fungible_store::set_frozen_flag(&v3.transfer_ref, arg1, true);
        };
        0x1::primary_fungible_store::deposit_with_ref(&v3.transfer_ref, arg1, 0x1::fungible_asset::mint(&v3.mint_ref, arg2));
    }
    
    public(friend) fun deposit_to_freezed_pre_mkl_store(arg0: &0x1::object::Object<0x1::fungible_asset::FungibleStore>, arg1: 0x1::fungible_asset::FungibleAsset) acquires PreMklConfig {
        0x1::fungible_asset::deposit_with_ref<0x1::fungible_asset::FungibleStore>(&borrow_global<PreMklConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).transfer_ref, *arg0, arg1);
    }
    
    public(friend) fun deposit_user_pre_mkl(arg0: &signer, arg1: 0x1::fungible_asset::FungibleAsset) acquires PreMklConfig {
        assert!(0x1::fungible_asset::metadata_from_asset(&arg1) == get_metadata(), 3);
        let v0 = 0x1::signer::address_of(arg0);
        let v1 = borrow_global<PreMklConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::primary_fungible_store::is_frozen<0x1::fungible_asset::Metadata>(v0, get_metadata())) {
        } else {
            0x1::primary_fungible_store::set_frozen_flag(&v1.transfer_ref, v0, true);
        };
        0x1::primary_fungible_store::deposit_with_ref(&v1.transfer_ref, v0, arg1);
    }
    
    public(friend) fun freeze_pre_mkl_store(arg0: &0x1::object::Object<0x1::fungible_asset::FungibleStore>, arg1: bool) acquires PreMklConfig {
        0x1::fungible_asset::set_frozen_flag<0x1::fungible_asset::FungibleStore>(&borrow_global<PreMklConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).transfer_ref, *arg0, arg1);
    }
    
    fun get_leftover_growth_fund_amount(arg0: address) : u64 acquires GrowthFundResource {
        if (exists<GrowthFundResource>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)) {
            let v0 = borrow_global<GrowthFundResource>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
            if (0x1::table::contains<address, GrowthFundRecipt>(&v0.user, arg0)) {
                let v1 = 0x1::table::borrow<address, GrowthFundRecipt>(&v0.user, arg0);
                return v1.initial_amount - v1.swapped_amount
            };
            return 0
        };
        0
    }
    
    public fun initialize_module(arg0: &signer) {
        assert!(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d == 0x1::signer::address_of(arg0), 0);
        if (exists<PreMklConfig>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = 0x1::object::create_named_object(arg0, b"PreMKL");
            let v1 = &v0;
            0x1::primary_fungible_store::create_primary_store_enabled_fungible_asset(v1, 0x1::option::none<u128>(), 0x1::string::utf8(b"PreMKL"), 0x1::string::utf8(b"PreMKL"), 6, 0x1::string::utf8(b""), 0x1::string::utf8(b""));
            let v2 = PreMklConfig{
                mint_ref     : 0x1::fungible_asset::generate_mint_ref(v1), 
                transfer_ref : 0x1::fungible_asset::generate_transfer_ref(v1), 
                burn_ref     : 0x1::fungible_asset::generate_burn_ref(v1), 
                mkl_cap      : 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::mint_claim_capability<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::COMMUNITY_POOL>(arg0),
            };
            move_to<PreMklConfig>(arg0, v2);
        };
    }
    
    public entry fun mint_pre_mkl(arg0: &signer) acquires PreMklConfig {
        deposit_user_pre_mkl(arg0, 0x1::fungible_asset::mint(&borrow_global<PreMklConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).mint_ref, 10000000000));
    }
    
    public fun pre_mkl_tge_at() : u64 {
        1721908800
    }
    
    public fun run_token_generation_event(arg0: &signer) acquires PreMklConfig {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        let v0 = 0x1::object::create_object(0x1::signer::address_of(arg0));
        let v1 = 0x1::fungible_asset::create_store<0x1::fungible_asset::Metadata>(&v0, get_metadata());
        0x1::fungible_asset::deposit<0x1::fungible_asset::FungibleStore>(v1, 0x1::fungible_asset::mint(&borrow_global<PreMklConfig>(0x1::signer::address_of(arg0)).mint_ref, 9500000000000));
        let v2 = PoolStore{pre_mkl: v1};
        move_to<PoolStore>(arg0, v2);
    }
    
    public fun swap_pre_mkl_to_mkl(arg0: &signer) : 0x1::fungible_asset::FungibleAsset acquires GrowthFundResource, PreMklConfig {
        let v0 = 0x1::signer::address_of(arg0);
        let v1 = 0x1::primary_fungible_store::balance<0x1::fungible_asset::Metadata>(v0, get_metadata());
        if (v1 == 0) {
            return 0x1::fungible_asset::zero<0x1::fungible_asset::Metadata>(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::get_metadata())
        };
        let v2 = withdraw_from_user(v0, v1);
        swap_pre_mkl_to_mkl_with_fa_v2(0x1::signer::address_of(arg0), v2)
    }
    
    public(friend) fun swap_pre_mkl_to_mkl_with_fa(arg0: &signer, arg1: 0x1::fungible_asset::FungibleAsset) : 0x1::fungible_asset::FungibleAsset acquires GrowthFundResource, PreMklConfig {
        swap_pre_mkl_to_mkl_with_fa_v2(0x1::signer::address_of(arg0), arg1)
    }
    
    public(friend) fun swap_pre_mkl_to_mkl_with_fa_v2(arg0: address, arg1: 0x1::fungible_asset::FungibleAsset) : 0x1::fungible_asset::FungibleAsset acquires GrowthFundResource, PreMklConfig {
        let v0 = get_leftover_growth_fund_amount(arg0);
        let v1 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::min(v0, 0x1::fungible_asset::amount(&arg1));
        let v2 = 0x1::fungible_asset::zero<0x1::fungible_asset::Metadata>(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::get_metadata());
        let v3 = borrow_global<PreMklConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (v1 > 0) {
            let v4 = borrow_global_mut<GrowthFundResource>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
            0x1::fungible_asset::merge(&mut v2, burn_pre_mkl_claim_mkl_with_ref_cap<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::GROWTH_POOL>(0x1::fungible_asset::extract(&mut arg1, v1), &v3.burn_ref, &v4.mkl_cap));
            let v5 = 0x1::table::borrow_mut<address, GrowthFundRecipt>(&mut v4.user, arg0);
            v5.swapped_amount = v5.swapped_amount + v1;
        };
        0x1::fungible_asset::merge(&mut v2, burn_pre_mkl_claim_mkl_with_ref_cap<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::COMMUNITY_POOL>(arg1, &v3.burn_ref, &v3.mkl_cap));
        v2
    }
    
    fun swap_premkl_to_mkl_internal(arg0: address) acquires GrowthFundResource, PreMklConfig {
        let v0 = 0x1::primary_fungible_store::balance<0x1::fungible_asset::Metadata>(arg0, get_metadata());
        if (v0 == 0) {
            return
        };
        let v1 = withdraw_from_user(arg0, v0);
        let v2 = swap_pre_mkl_to_mkl_with_fa_v2(arg0, v1);
        0x1::primary_fungible_store::deposit(arg0, v2);
    }
    
    public fun user_swap_premkl_to_mkl(arg0: &signer) acquires GrowthFundResource, PreMklConfig {
        swap_premkl_to_mkl_internal(0x1::signer::address_of(arg0));
    }
    
    public(friend) fun withdraw_from_freezed_pre_mkl_store(arg0: &0x1::object::Object<0x1::fungible_asset::FungibleStore>, arg1: u64) : 0x1::fungible_asset::FungibleAsset acquires PreMklConfig {
        0x1::fungible_asset::withdraw_with_ref<0x1::fungible_asset::FungibleStore>(&borrow_global<PreMklConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).transfer_ref, *arg0, arg1)
    }
    
    public(friend) fun withdraw_from_user(arg0: address, arg1: u64) : 0x1::fungible_asset::FungibleAsset acquires PreMklConfig {
        if (arg1 == 0) {
            return 0x1::fungible_asset::zero<0x1::fungible_asset::Metadata>(get_metadata())
        };
        0x1::primary_fungible_store::withdraw_with_ref(&borrow_global<PreMklConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).transfer_ref, arg0, arg1)
    }
    
    // decompiled from Move bytecode v6
}


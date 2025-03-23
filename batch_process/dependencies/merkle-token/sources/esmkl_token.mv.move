module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token {
    struct MintCapability has drop, store {
        dummy_field: bool,
    }
    
    struct VestingConfig has key {
        vesting_duration: u64,
        esmkl_minimum_amount: u64,
        cfa_store_admin_cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::claimable_fa_store::AdminCapability,
    }
    
    struct ESMKL {
        dummy_field: bool,
    }
    
    struct EsmklConfig has key {
        mint_ref: 0x1::fungible_asset::MintRef,
        transfer_ref: 0x1::fungible_asset::TransferRef,
        burn_ref: 0x1::fungible_asset::BurnRef,
    }
    
    struct EsmklVestingPlan has drop, key {
        vesting_plan: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vesting::VestingPlan,
        claim_cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vesting::ClaimCapability,
        admin_cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vesting::AdminCapability,
        object_delete_ref: 0x1::object::DeleteRef,
    }
    
    struct MklClaimCapability has key {
        cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::ClaimCapability<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::COMMUNITY_POOL>,
    }
    
    public fun get_metadata() : 0x1::object::Object<0x1::fungible_asset::Metadata> {
        let v0 = @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d;
        0x1::object::address_to_object<0x1::fungible_asset::Metadata>(0x1::object::create_object_address(&v0, b"esMKL"))
    }
    
    public fun cancel(arg0: &signer, arg1: address) acquires VestingConfig, EsmklConfig, EsmklVestingPlan, MklClaimCapability {
        assert!(0x1::object::is_owner<EsmklVestingPlan>(0x1::object::address_to_object<EsmklVestingPlan>(arg1), 0x1::signer::address_of(arg0)), 0);
        let EsmklVestingPlan {
            vesting_plan      : v0,
            claim_cap         : v1,
            admin_cap         : v2,
            object_delete_ref : v3,
        } = move_from<EsmklVestingPlan>(arg1);
        let v4 = v0;
        claim_mkl_deposit_pool(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vesting::get_claimable(&v4));
        let (v5, v6) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vesting::cancel(v4, v1, v2);
        let v7 = mint_esmkl_internal(v6);
        0x1::primary_fungible_store::deposit(0x1::signer::address_of(arg0), v5);
        deposit_user_esmkl(arg0, v7);
        0x1::object::delete(v3);
    }
    
    public fun claim(arg0: &signer, arg1: address) acquires VestingConfig, EsmklVestingPlan, MklClaimCapability {
        assert!(0x1::object::is_owner<EsmklVestingPlan>(0x1::object::address_to_object<EsmklVestingPlan>(arg1), 0x1::signer::address_of(arg0)), 0);
        let v0 = borrow_global_mut<EsmklVestingPlan>(arg1);
        claim_mkl_deposit_pool(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vesting::get_claimable(&v0.vesting_plan));
        0x1::primary_fungible_store::deposit(0x1::signer::address_of(arg0), 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vesting::claim(&mut v0.vesting_plan, &v0.claim_cap));
        let (_, _, _, _, _, v6, v7, _) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vesting::get_vesting_plan_data(&v0.vesting_plan);
        if (v6 == v7) {
            let EsmklVestingPlan {
                vesting_plan      : _,
                claim_cap         : _,
                admin_cap         : _,
                object_delete_ref : v12,
            } = move_from<EsmklVestingPlan>(arg1);
            0x1::object::delete(v12);
        };
    }
    
    public fun burn_esmkl(arg0: 0x1::fungible_asset::FungibleAsset) acquires EsmklConfig {
        0x1::fungible_asset::burn(&borrow_global<EsmklConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).burn_ref, arg0);
    }
    
    fun claim_mkl_deposit_pool(arg0: u64) acquires VestingConfig, MklClaimCapability {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::claimable_fa_store::deposit_funding_store_fa(&borrow_global<VestingConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).cfa_store_admin_cap, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::claim_mkl_with_cap<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::COMMUNITY_POOL>(&borrow_global<MklClaimCapability>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).cap, arg0));
    }
    
    public(friend) fun deposit_to_freezed_esmkl_store(arg0: &0x1::object::Object<0x1::fungible_asset::FungibleStore>, arg1: 0x1::fungible_asset::FungibleAsset) acquires EsmklConfig {
        assert!(0x1::fungible_asset::store_metadata<0x1::fungible_asset::FungibleStore>(*arg0) == get_metadata(), 3);
        0x1::fungible_asset::deposit_with_ref<0x1::fungible_asset::FungibleStore>(&borrow_global<EsmklConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).transfer_ref, *arg0, arg1);
    }
    
    public fun deposit_user_esmkl(arg0: &signer, arg1: 0x1::fungible_asset::FungibleAsset) acquires EsmklConfig {
        assert!(0x1::fungible_asset::metadata_from_asset(&arg1) == get_metadata(), 3);
        let v0 = borrow_global<EsmklConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = 0x1::signer::address_of(arg0);
        if (0x1::primary_fungible_store::is_frozen<0x1::fungible_asset::Metadata>(v1, get_metadata())) {
        } else {
            0x1::primary_fungible_store::set_frozen_flag(&v0.transfer_ref, v1, true);
        };
        0x1::primary_fungible_store::deposit_with_ref(&v0.transfer_ref, v1, arg1);
    }
    
    public(friend) fun freeze_esmkl_store(arg0: &0x1::object::Object<0x1::fungible_asset::FungibleStore>, arg1: bool) acquires EsmklConfig {
        assert!(0x1::fungible_asset::store_metadata<0x1::fungible_asset::FungibleStore>(*arg0) == get_metadata(), 3);
        0x1::fungible_asset::set_frozen_flag<0x1::fungible_asset::FungibleStore>(&borrow_global<EsmklConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).transfer_ref, *arg0, arg1);
    }
    
    public fun initialize_module(arg0: &signer) {
        assert!(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d == 0x1::signer::address_of(arg0), 0);
        if (exists<EsmklConfig>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = 0x1::object::create_named_object(arg0, b"esMKL");
            let v1 = &v0;
            0x1::primary_fungible_store::create_primary_store_enabled_fungible_asset(v1, 0x1::option::none<u128>(), 0x1::string::utf8(b"esMKL"), 0x1::string::utf8(b"esMKL"), 6, 0x1::string::utf8(b""), 0x1::string::utf8(b""));
            let v2 = EsmklConfig{
                mint_ref     : 0x1::fungible_asset::generate_mint_ref(v1), 
                transfer_ref : 0x1::fungible_asset::generate_transfer_ref(v1), 
                burn_ref     : 0x1::fungible_asset::generate_burn_ref(v1),
            };
            move_to<EsmklConfig>(arg0, v2);
        };
        if (exists<VestingConfig>(0x1::signer::address_of(arg0))) {
        } else {
            let v3 = VestingConfig{
                vesting_duration     : 7776000, 
                esmkl_minimum_amount : 1000000, 
                cfa_store_admin_cap  : 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::claimable_fa_store::add_claimable_fa_store(arg0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::get_metadata()),
            };
            move_to<VestingConfig>(arg0, v3);
        };
        if (exists<MklClaimCapability>(0x1::signer::address_of(arg0))) {
        } else {
            let v4 = MklClaimCapability{cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::mint_claim_capability<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::COMMUNITY_POOL>(arg0)};
            move_to<MklClaimCapability>(arg0, v4);
        };
    }
    
    public entry fun mint_esmkl(arg0: &signer) acquires EsmklConfig {
        let v0 = mint_esmkl_internal(10000000000);
        deposit_user_esmkl(arg0, v0);
    }
    
    fun mint_esmkl_internal(arg0: u64) : 0x1::fungible_asset::FungibleAsset acquires EsmklConfig {
        assert!(0x1::timestamp::now_seconds() >= 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::mkl_tge_at(), 2);
        0x1::fungible_asset::mint(&borrow_global<EsmklConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).mint_ref, arg0)
    }
    
    public fun mint_esmkl_with_cap(arg0: &MintCapability, arg1: u64) : 0x1::fungible_asset::FungibleAsset acquires EsmklConfig {
        mint_esmkl_internal(arg1)
    }
    
    public fun mint_mint_capability(arg0: &signer) : MintCapability {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        MintCapability{dummy_field: false}
    }
    
    public fun restore_cfa_store_admin_cap(arg0: &signer) acquires VestingConfig {
        assert!(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d == 0x1::signer::address_of(arg0), 0);
        borrow_global_mut<VestingConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).cfa_store_admin_cap = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::claimable_fa_store::add_claimable_fa_store(arg0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::get_metadata());
    }
    
    public fun restore_cfa_store_claim_cap(arg0: &signer, arg1: address) acquires VestingConfig, EsmklVestingPlan {
        assert!(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d == 0x1::signer::address_of(arg0), 0);
        let v0 = borrow_global_mut<EsmklVestingPlan>(arg1);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vesting::change_claim_cap(&mut v0.vesting_plan, &v0.admin_cap, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::claimable_fa_store::mint_claim_capability(&borrow_global_mut<VestingConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).cfa_store_admin_cap));
    }
    
    public fun vest(arg0: &signer, arg1: u64) : address acquires VestingConfig, EsmklConfig {
        let v0 = borrow_global<VestingConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        assert!(arg1 >= v0.esmkl_minimum_amount, 1);
        let v1 = withdraw_user_esmkl(arg0, arg1);
        burn_esmkl(v1);
        let v2 = 0x1::timestamp::now_seconds();
        let (v3, v4, v5) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vesting::create(0x1::signer::address_of(arg0), v2, v2 + v0.vesting_duration, 0, arg1, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::claimable_fa_store::mint_claim_capability(&v0.cfa_store_admin_cap));
        let v6 = 0x1::object::create_object(0x1::signer::address_of(arg0));
        let v7 = 0x1::object::generate_signer(&v6);
        let v8 = 0x1::object::generate_transfer_ref(&v6);
        0x1::object::disable_ungated_transfer(&v8);
        let v9 = EsmklVestingPlan{
            vesting_plan      : v3, 
            claim_cap         : v4, 
            admin_cap         : v5, 
            object_delete_ref : 0x1::object::generate_delete_ref(&v6),
        };
        move_to<EsmklVestingPlan>(&v7, v9);
        0x1::signer::address_of(&v7)
    }
    
    public(friend) fun withdraw_from_freezed_esmkl_store(arg0: &0x1::object::Object<0x1::fungible_asset::FungibleStore>, arg1: u64) : 0x1::fungible_asset::FungibleAsset acquires EsmklConfig {
        if (arg1 == 0) {
            return 0x1::fungible_asset::zero<0x1::fungible_asset::Metadata>(get_metadata())
        };
        assert!(0x1::fungible_asset::store_metadata<0x1::fungible_asset::FungibleStore>(*arg0) == get_metadata(), 3);
        0x1::fungible_asset::withdraw_with_ref<0x1::fungible_asset::FungibleStore>(&borrow_global<EsmklConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).transfer_ref, *arg0, arg1)
    }
    
    public(friend) fun withdraw_user_esmkl(arg0: &signer, arg1: u64) : 0x1::fungible_asset::FungibleAsset acquires EsmklConfig {
        let v0 = 0x1::primary_fungible_store::primary_store<0x1::fungible_asset::Metadata>(0x1::signer::address_of(arg0), get_metadata());
        withdraw_from_freezed_esmkl_store(&v0, arg1)
    }
    
    // decompiled from Move bytecode v6
}


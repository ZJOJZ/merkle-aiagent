module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::custom_vesting {
    struct AdminPoolCap<phantom T0> has key {
        claimable_fa_store_admin_cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::claimable_fa_store::AdminCapability,
        mkl_token_claim_cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::ClaimCapability<T0>,
    }
    
    struct CustomVestingPlan has drop, key {
        vesting_plan: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vesting::VestingPlan,
        claim_cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vesting::ClaimCapability,
        admin_cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vesting::AdminCapability,
        pool_info: 0x1::type_info::TypeInfo,
        object_delete_ref: 0x1::object::DeleteRef,
    }
    
    public fun claim(arg0: &signer, arg1: address) acquires AdminPoolCap, CustomVestingPlan {
        let v0 = 0x1::signer::address_of(arg0);
        assert!(0x1::object::is_owner<CustomVestingPlan>(0x1::object::address_to_object<CustomVestingPlan>(arg1), v0), 0);
        let v1 = borrow_global_mut<CustomVestingPlan>(arg1);
        let v2 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vesting::get_claimable(&v1.vesting_plan);
        assert!(v2 > 0, 1);
        claim_mkl_deposit_type_info(v1.pool_info, v2);
        0x1::primary_fungible_store::deposit(v0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vesting::claim(&mut v1.vesting_plan, &v1.claim_cap));
    }
    
    public fun pause(arg0: &signer, arg1: address) acquires CustomVestingPlan {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        let v0 = borrow_global_mut<CustomVestingPlan>(arg1);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vesting::pause(&mut v0.vesting_plan, &v0.admin_cap);
    }
    
    public fun unpause(arg0: &signer, arg1: address) acquires CustomVestingPlan {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        let v0 = borrow_global_mut<CustomVestingPlan>(arg1);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vesting::unpause(&mut v0.vesting_plan, &v0.admin_cap);
    }
    
    public fun cancel(arg0: &signer, arg1: address) acquires CustomVestingPlan {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        let CustomVestingPlan {
            vesting_plan      : _,
            claim_cap         : _,
            admin_cap         : _,
            pool_info         : _,
            object_delete_ref : v4,
        } = move_from<CustomVestingPlan>(arg1);
        0x1::object::delete(v4);
    }
    
    fun claim_mkl_deposit_pool<T0>(arg0: u64) acquires AdminPoolCap {
        let v0 = borrow_global<AdminPoolCap<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::claimable_fa_store::deposit_funding_store_fa(&v0.claimable_fa_store_admin_cap, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::claim_mkl_with_cap<T0>(&v0.mkl_token_claim_cap, arg0));
    }
    
    fun claim_mkl_deposit_type_info(arg0: 0x1::type_info::TypeInfo, arg1: u64) acquires AdminPoolCap {
        if (arg0 == 0x1::type_info::type_of<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::GROWTH_POOL>()) {
            claim_mkl_deposit_pool<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::GROWTH_POOL>(arg1);
        } else {
            if (arg0 == 0x1::type_info::type_of<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::CORE_TEAM_POOL>()) {
                claim_mkl_deposit_pool<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::CORE_TEAM_POOL>(arg1);
            } else {
                if (arg0 == 0x1::type_info::type_of<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::INVESTOR_POOL>()) {
                    claim_mkl_deposit_pool<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::INVESTOR_POOL>(arg1);
                } else {
                    if (arg0 == 0x1::type_info::type_of<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::ADVISOR_POOL>()) {
                        claim_mkl_deposit_pool<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::ADVISOR_POOL>(arg1);
                    };
                };
            };
        };
    }
    
    public fun create_custom_vesting<T0>(arg0: &signer, arg1: address, arg2: u64, arg3: u64, arg4: u64, arg5: u64) : address acquires AdminPoolCap {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        if (exists<AdminPoolCap<T0>>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = AdminPoolCap<T0>{
                claimable_fa_store_admin_cap : 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::claimable_fa_store::add_claimable_fa_store(arg0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::get_metadata()), 
                mkl_token_claim_cap          : 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::mint_claim_capability<T0>(arg0),
            };
            move_to<AdminPoolCap<T0>>(arg0, v0);
        };
        let (v1, v2, v3) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vesting::create(arg1, arg2, arg3, arg4, arg5, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::claimable_fa_store::mint_claim_capability(&borrow_global<AdminPoolCap<T0>>(0x1::signer::address_of(arg0)).claimable_fa_store_admin_cap));
        let v4 = 0x1::object::create_object(arg1);
        let v5 = 0x1::object::generate_signer(&v4);
        let v6 = 0x1::object::generate_transfer_ref(&v4);
        0x1::object::disable_ungated_transfer(&v6);
        let v7 = CustomVestingPlan{
            vesting_plan      : v1, 
            claim_cap         : v2, 
            admin_cap         : v3, 
            pool_info         : 0x1::type_info::type_of<T0>(), 
            object_delete_ref : 0x1::object::generate_delete_ref(&v4),
        };
        move_to<CustomVestingPlan>(&v5, v7);
        0x1::signer::address_of(&v5)
    }
    
    // decompiled from Move bytecode v6
}


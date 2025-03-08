module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vesting {
    struct AdminCapability has drop, store {
        uid: u64,
    }
    
    struct ClaimCapability has drop, store {
        uid: u64,
    }
    
    struct VestingConfig has key {
        next_uid: u64,
    }
    
    struct VestingPlan has drop, store {
        uid: u64,
        user: address,
        start_at_sec: u64,
        end_at_sec: u64,
        initial_amount: u64,
        total_amount: u64,
        claimed_amount: u64,
        paused: bool,
        claimable_fa_store_claim_cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::claimable_fa_store::ClaimCapability,
    }
    
    public fun cancel(arg0: VestingPlan, arg1: ClaimCapability, arg2: AdminCapability) : (0x1::fungible_asset::FungibleAsset, u64) {
        if (arg0.paused) {
            abort 3
        };
        assert!(arg0.uid == arg1.uid && arg0.uid == arg2.uid, 0);
        let v0 = get_claimable(&arg0);
        let v1 = 0x1::fungible_asset::zero<0x1::fungible_asset::Metadata>(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::claimable_fa_store::get_metadata_by_uid(&arg0.claimable_fa_store_claim_cap));
        if (v0 > 0) {
            0x1::fungible_asset::merge(&mut v1, claim_internal(&mut arg0, v0));
        };
        let v2 = arg0.total_amount - arg0.claimed_amount;
        assert!(v2 > 0, 6);
        (v1, v2)
    }
    
    public fun change_claim_cap(arg0: &mut VestingPlan, arg1: &AdminCapability, arg2: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::claimable_fa_store::ClaimCapability) {
        assert!(arg0.uid == arg1.uid, 0);
        arg0.claimable_fa_store_claim_cap = arg2;
    }
    
    public fun claim(arg0: &mut VestingPlan, arg1: &ClaimCapability) : 0x1::fungible_asset::FungibleAsset {
        if (arg0.paused) {
            abort 3
        };
        assert!(arg0.uid == arg1.uid, 0);
        let v0 = get_claimable(arg0);
        assert!(v0 > 0, 2);
        claim_internal(arg0, v0)
    }
    
    fun claim_internal(arg0: &mut VestingPlan, arg1: u64) : 0x1::fungible_asset::FungibleAsset {
        arg0.claimed_amount = arg0.claimed_amount + arg1;
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::claimable_fa_store::claim_funding_store(&arg0.claimable_fa_store_claim_cap, arg1)
    }
    
    public fun create(arg0: address, arg1: u64, arg2: u64, arg3: u64, arg4: u64, arg5: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::claimable_fa_store::ClaimCapability) : (VestingPlan, ClaimCapability, AdminCapability) acquires VestingConfig {
        assert!(0x1::timestamp::now_seconds() < arg2 && arg1 < arg2, 4);
        assert!(arg3 <= arg4, 5);
        let v0 = borrow_global_mut<VestingConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = v0.next_uid;
        let v2 = VestingPlan{
            uid                          : v1, 
            user                         : arg0, 
            start_at_sec                 : arg1, 
            end_at_sec                   : arg2, 
            initial_amount               : arg3, 
            total_amount                 : arg4, 
            claimed_amount               : 0, 
            paused                       : false, 
            claimable_fa_store_claim_cap : arg5,
        };
        v0.next_uid = v0.next_uid + 1;
        let v3 = ClaimCapability{uid: v1};
        let v4 = AdminCapability{uid: v1};
        (v2, v3, v4)
    }
    
    public fun get_claimable(arg0: &VestingPlan) : u64 {
        let v0 = 0x1::timestamp::now_seconds();
        if (arg0.paused || v0 < arg0.start_at_sec) {
            return 0
        };
        arg0.initial_amount + 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(arg0.total_amount - arg0.initial_amount, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::min(v0, arg0.end_at_sec) - 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::min(v0, arg0.start_at_sec), arg0.end_at_sec - arg0.start_at_sec) - arg0.claimed_amount
    }
    
    public fun get_vesting_plan_data(arg0: &VestingPlan) : (u64, address, u64, u64, u64, u64, u64, bool) {
        (arg0.uid, arg0.user, arg0.start_at_sec, arg0.end_at_sec, arg0.initial_amount, arg0.total_amount, arg0.claimed_amount, arg0.paused)
    }
    
    public fun initialize_module(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        if (exists<VestingConfig>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = VestingConfig{next_uid: 1};
            move_to<VestingConfig>(arg0, v0);
        };
    }
    
    public fun pause(arg0: &mut VestingPlan, arg1: &AdminCapability) {
        assert!(arg0.uid == arg1.uid, 0);
        arg0.paused = true;
    }
    
    public fun unpause(arg0: &mut VestingPlan, arg1: &AdminCapability) {
        assert!(arg0.uid == arg1.uid, 0);
        arg0.paused = false;
    }
    
    // decompiled from Move bytecode v6
}


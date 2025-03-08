module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_tge_reward {
    struct ClaimEvent has drop, store {
        user: address,
        amount: u64,
    }
    
    struct MklClaimCapacityStore has key {
        pre_mkl_cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::ClaimCapability,
        mkl_cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::ClaimCapability<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::COMMUNITY_POOL>,
    }
    
    struct PreTgeRewardEvents has key {
        point_claim_events: 0x1::event::EventHandle<ClaimEvent>,
        lp_claim_events: 0x1::event::EventHandle<ClaimEvent>,
    }
    
    struct PreTgeRewardInfo has drop, store {
        point_reward: u64,
        point_reward_claimed: bool,
        lp_reward: u64,
        lp_reward_claimed: bool,
    }
    
    struct PreTgeRewards has key {
        user_pre_tge_reward: 0x1::table::Table<address, PreTgeRewardInfo>,
    }
    
    fun check_season_expire() {
        let v0 = 0x1::timestamp::now_seconds();
        assert!(v0 >= 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::pre_mkl_tge_at(), 2);
        assert!(v0 <= 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::mkl_tge_at() + 7257600, 3);
    }
    
    fun claim_internal(arg0: address, arg1: u64) acquires MklClaimCapacityStore {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::blocked_user::is_blocked(arg0);
        if (0x1::timestamp::now_seconds() < 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::mkl_tge_at()) {
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::claim_user_pre_mkl(&borrow_global<MklClaimCapacityStore>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).pre_mkl_cap, arg0, arg1);
        } else {
            0x1::primary_fungible_store::deposit(arg0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::claim_mkl_with_cap<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::COMMUNITY_POOL>(&borrow_global<MklClaimCapacityStore>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).mkl_cap, arg1));
        };
    }
    
    public fun claim_lp_reward(arg0: &signer) acquires MklClaimCapacityStore, PreTgeRewardEvents, PreTgeRewards {
        check_season_expire();
        let v0 = 0x1::signer::address_of(arg0);
        let v1 = 0x1::table::borrow_mut<address, PreTgeRewardInfo>(&mut borrow_global_mut<PreTgeRewards>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).user_pre_tge_reward, v0);
        if (v1.lp_reward_claimed) {
            abort 2
        };
        claim_internal(v0, v1.lp_reward);
        v1.lp_reward_claimed = true;
        let v2 = ClaimEvent{
            user   : v0, 
            amount : v1.lp_reward,
        };
        0x1::event::emit_event<ClaimEvent>(&mut borrow_global_mut<PreTgeRewardEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).lp_claim_events, v2);
    }
    
    public fun claim_point_reward(arg0: &signer) acquires MklClaimCapacityStore, PreTgeRewardEvents, PreTgeRewards {
        check_season_expire();
        let v0 = 0x1::signer::address_of(arg0);
        let v1 = 0x1::table::borrow_mut<address, PreTgeRewardInfo>(&mut borrow_global_mut<PreTgeRewards>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).user_pre_tge_reward, v0);
        if (v1.point_reward_claimed) {
            abort 2
        };
        claim_internal(v0, v1.point_reward);
        v1.point_reward_claimed = true;
        let v2 = ClaimEvent{
            user   : v0, 
            amount : v1.point_reward,
        };
        0x1::event::emit_event<ClaimEvent>(&mut borrow_global_mut<PreTgeRewardEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).point_claim_events, v2);
    }
    
    public fun initialize_module(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        if (exists<PreTgeRewards>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = PreTgeRewards{user_pre_tge_reward: 0x1::table::new<address, PreTgeRewardInfo>()};
            move_to<PreTgeRewards>(arg0, v0);
        };
        if (exists<PreTgeRewardEvents>(0x1::signer::address_of(arg0))) {
        } else {
            let v1 = PreTgeRewardEvents{
                point_claim_events : 0x1::account::new_event_handle<ClaimEvent>(arg0), 
                lp_claim_events    : 0x1::account::new_event_handle<ClaimEvent>(arg0),
            };
            move_to<PreTgeRewardEvents>(arg0, v1);
        };
        if (exists<MklClaimCapacityStore>(0x1::signer::address_of(arg0))) {
        } else {
            let v2 = MklClaimCapacityStore{
                pre_mkl_cap : 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::mint_claim_capability(arg0), 
                mkl_cap     : 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::mint_claim_capability<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::COMMUNITY_POOL>(arg0),
            };
            move_to<MklClaimCapacityStore>(arg0, v2);
        };
    }
    
    public fun set_bulk_point_reward(arg0: &signer, arg1: vector<address>, arg2: vector<u64>) acquires PreTgeRewards {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v0 = 0;
        while (v0 < 0x1::vector::length<address>(&arg1)) {
            let v1 = PreTgeRewardInfo{
                point_reward         : 0, 
                point_reward_claimed : false, 
                lp_reward            : 0, 
                lp_reward_claimed    : false,
            };
            0x1::table::borrow_mut_with_default<address, PreTgeRewardInfo>(&mut borrow_global_mut<PreTgeRewards>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).user_pre_tge_reward, *0x1::vector::borrow<address>(&arg1, v0), v1).point_reward = *0x1::vector::borrow<u64>(&arg2, v0);
            v0 = v0 + 1;
        };
    }
    
    public fun set_lp_reward(arg0: &signer, arg1: address, arg2: u64) acquires PreTgeRewards {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v0 = PreTgeRewardInfo{
            point_reward         : 0, 
            point_reward_claimed : false, 
            lp_reward            : 0, 
            lp_reward_claimed    : false,
        };
        0x1::table::borrow_mut_with_default<address, PreTgeRewardInfo>(&mut borrow_global_mut<PreTgeRewards>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).user_pre_tge_reward, arg1, v0).lp_reward = arg2;
    }
    
    public fun set_point_reward(arg0: &signer, arg1: address, arg2: u64) acquires PreTgeRewards {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v0 = PreTgeRewardInfo{
            point_reward         : 0, 
            point_reward_claimed : false, 
            lp_reward            : 0, 
            lp_reward_claimed    : false,
        };
        0x1::table::borrow_mut_with_default<address, PreTgeRewardInfo>(&mut borrow_global_mut<PreTgeRewards>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).user_pre_tge_reward, arg1, v0).point_reward = arg2;
    }
    
    // decompiled from Move bytecode v6
}


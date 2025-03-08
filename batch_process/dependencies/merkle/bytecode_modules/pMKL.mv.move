module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pMKL {
    struct MintEvent has drop, store {
        season_number: u64,
        user: address,
        amount: u64,
    }
    
    struct ClaimEvent has drop, store {
        season_number: u64,
        user: address,
        amount: u64,
    }
    
    struct CapabilityStore has key {
        esmkl_cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::MintCapability,
        pre_mkl_cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::ClaimCapability,
    }
    
    struct PMKLEvents has key {
        mint_events: 0x1::event::EventHandle<MintEvent>,
        claim_events: 0x1::event::EventHandle<ClaimEvent>,
    }
    
    struct PMKLInfo has key {
        season_pmkl: 0x1::table::Table<u64, SeasonPMKLInfo>,
    }
    
    struct RewardInfo has key {
        season_reward: 0x1::table::Table<u64, u64>,
    }
    
    struct SeasonPMKLInfo has store {
        supply: u64,
        user_balance: 0x1::table::Table<address, u64>,
        user_claimed: 0x1::table::Table<address, u64>,
    }
    
    struct SeasonPMKLSupplyView has drop {
        season_number: u64,
        total_supply: u64,
    }
    
    struct SeasonUserPMKLInfoView has drop {
        season_number: u64,
        total_supply: u64,
        user_balance: u64,
    }
    
    public fun claim_season_esmkl(arg0: &signer, arg1: u64) acquires CapabilityStore, PMKLEvents, PMKLInfo, RewardInfo {
        assert!(arg1 < 31, 3);
        let v0 = 0x1::signer::address_of(arg0);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::blocked_user::is_blocked(v0);
        let v1 = 0x1::timestamp::now_seconds();
        assert!(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number() > 15, 2);
        assert!(v1 - 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_season_end_sec(arg1) <= 2419200, 3);
        let v2 = 0x1::table::borrow_mut<u64, SeasonPMKLInfo>(&mut borrow_global_mut<PMKLInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).season_pmkl, arg1);
        let (v3, v4, v5) = get_user_season_pmkl_info(v2, borrow_global<RewardInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d), v0, arg1);
        let v6 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v3, v4 - v5, v2.supply);
        assert!(v6 > 0, 2);
        0x1::table::upsert<address, u64>(&mut v2.user_claimed, v0, v4);
        if (v1 < 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::mkl_tge_at()) {
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::claim_user_pre_mkl(&borrow_global<CapabilityStore>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).pre_mkl_cap, 0x1::signer::address_of(arg0), v6);
        } else {
            if (arg1 <= 18) {
                0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::claim_user_pre_mkl(&borrow_global<CapabilityStore>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).pre_mkl_cap, 0x1::signer::address_of(arg0), v6);
                0x1::primary_fungible_store::deposit(v0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::swap_pre_mkl_to_mkl(arg0));
            } else {
                0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::deposit_user_esmkl(arg0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::mint_esmkl_with_cap(&borrow_global<CapabilityStore>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).esmkl_cap, v6));
            };
        };
        let v7 = ClaimEvent{
            season_number : arg1, 
            user          : v0, 
            amount        : v6,
        };
        0x1::event::emit_event<ClaimEvent>(&mut borrow_global_mut<PMKLEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).claim_events, v7);
    }
    
    public fun get_current_season_info() : SeasonPMKLSupplyView acquires PMKLInfo {
        get_season_info(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number())
    }
    
    public fun get_season_info(arg0: u64) : SeasonPMKLSupplyView acquires PMKLInfo {
        let v0 = borrow_global<PMKLInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::table::contains<u64, SeasonPMKLInfo>(&v0.season_pmkl, arg0)) {
            return SeasonPMKLSupplyView{
                season_number : arg0, 
                total_supply  : 0x1::table::borrow<u64, SeasonPMKLInfo>(&v0.season_pmkl, arg0).supply,
            }
        };
        SeasonPMKLSupplyView{
            season_number : arg0, 
            total_supply  : 0,
        }
    }
    
    public fun get_season_user_pmkl(arg0: address, arg1: u64) : SeasonUserPMKLInfoView acquires PMKLInfo {
        let v0 = borrow_global<PMKLInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::table::contains<u64, SeasonPMKLInfo>(&v0.season_pmkl, arg1)) {
            let v1 = 0x1::table::borrow<u64, SeasonPMKLInfo>(&v0.season_pmkl, arg1);
            if (0x1::table::contains<address, u64>(&v1.user_balance, arg0)) {
                return SeasonUserPMKLInfoView{
                    season_number : arg1, 
                    total_supply  : v1.supply, 
                    user_balance  : *0x1::table::borrow<address, u64>(&v1.user_balance, arg0),
                }
            };
            return SeasonUserPMKLInfoView{
                season_number : arg1, 
                total_supply  : v1.supply, 
                user_balance  : 0,
            }
        };
        SeasonUserPMKLInfoView{
            season_number : arg1, 
            total_supply  : 0, 
            user_balance  : 0,
        }
    }
    
    public fun get_user_season_claimable(arg0: address, arg1: u64) : u64 acquires PMKLInfo, RewardInfo {
        if (arg1 < 15 || arg1 >= 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number() || 0x1::timestamp::now_seconds() - 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_season_end_sec(arg1) > 2419200) {
            return 0
        };
        let v0 = borrow_global<PMKLInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::table::contains<u64, SeasonPMKLInfo>(&v0.season_pmkl, arg1)) {
            let v1 = 0x1::table::borrow<u64, SeasonPMKLInfo>(&v0.season_pmkl, arg1);
            let (v2, v3, v4) = get_user_season_pmkl_info(v1, borrow_global<RewardInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d), arg0, arg1);
            return 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v2, v3 - v4, v1.supply)
        };
        0
    }
    
    fun get_user_season_pmkl_info(arg0: &SeasonPMKLInfo, arg1: &RewardInfo, arg2: address, arg3: u64) : (u64, u64, u64) {
        let v0 = 0;
        let v1 = 0;
        let v2 = 0;
        (*0x1::table::borrow_with_default<u64, u64>(&arg1.season_reward, arg3, &v0), *0x1::table::borrow_with_default<address, u64>(&arg0.user_balance, arg2, &v1), *0x1::table::borrow_with_default<address, u64>(&arg0.user_claimed, arg2, &v2))
    }
    
    public fun initialize_module(arg0: &signer) acquires RewardInfo {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        if (exists<PMKLInfo>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = PMKLInfo{season_pmkl: 0x1::table::new<u64, SeasonPMKLInfo>()};
            move_to<PMKLInfo>(arg0, v0);
        };
        if (exists<PMKLEvents>(0x1::signer::address_of(arg0))) {
        } else {
            let v1 = PMKLEvents{
                mint_events  : 0x1::account::new_event_handle<MintEvent>(arg0), 
                claim_events : 0x1::account::new_event_handle<ClaimEvent>(arg0),
            };
            move_to<PMKLEvents>(arg0, v1);
        };
        if (exists<RewardInfo>(0x1::signer::address_of(arg0))) {
        } else {
            let v2 = RewardInfo{season_reward: 0x1::table::new<u64, u64>()};
            move_to<RewardInfo>(arg0, v2);
            let v3 = 1;
            let v4 = vector[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 423000000000, 412000000000, 401000000000, 390000000000, 390000000000];
            0x1::vector::reverse<u64>(&mut v4);
            let v5 = v4;
            let v6 = 0x1::vector::length<u64>(&v5);
            while (v6 > 0) {
                0x1::table::upsert<u64, u64>(&mut borrow_global_mut<RewardInfo>(0x1::signer::address_of(arg0)).season_reward, v3, 0x1::vector::pop_back<u64>(&mut v5));
                v3 = v3 + 1;
                v6 = v6 - 1;
            };
            0x1::vector::destroy_empty<u64>(v5);
        };
        if (exists<CapabilityStore>(0x1::signer::address_of(arg0))) {
        } else {
            let v7 = CapabilityStore{
                esmkl_cap   : 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::mint_mint_capability(arg0), 
                pre_mkl_cap : 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::mint_claim_capability(arg0),
            };
            move_to<CapabilityStore>(arg0, v7);
        };
    }
    
    public(friend) fun mint_pmkl(arg0: address, arg1: u64) acquires PMKLEvents, PMKLInfo {
        let v0 = borrow_global_mut<PMKLInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number();
        if (0x1::table::contains<u64, SeasonPMKLInfo>(&v0.season_pmkl, v1)) {
        } else {
            let v2 = SeasonPMKLInfo{
                supply       : 0, 
                user_balance : 0x1::table::new<address, u64>(), 
                user_claimed : 0x1::table::new<address, u64>(),
            };
            0x1::table::add<u64, SeasonPMKLInfo>(&mut v0.season_pmkl, v1, v2);
        };
        let v3 = 0x1::table::borrow_mut<u64, SeasonPMKLInfo>(&mut v0.season_pmkl, v1);
        v3.supply = v3.supply + arg1;
        if (0x1::table::contains<address, u64>(&v3.user_balance, arg0)) {
        } else {
            0x1::table::add<address, u64>(&mut v3.user_balance, arg0, 0);
        };
        let v4 = 0x1::table::borrow_mut<address, u64>(&mut v3.user_balance, arg0);
        *v4 = *v4 + arg1;
        let v5 = MintEvent{
            season_number : v1, 
            user          : arg0, 
            amount        : arg1,
        };
        0x1::event::emit_event<MintEvent>(&mut borrow_global_mut<PMKLEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).mint_events, v5);
    }
    
    public fun set_season_reward(arg0: &signer, arg1: u64, arg2: u64) acquires RewardInfo {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        0x1::table::upsert<u64, u64>(&mut borrow_global_mut<RewardInfo>(0x1::signer::address_of(arg0)).season_reward, arg1, arg2);
    }
    
    // decompiled from Move bytecode v6
}


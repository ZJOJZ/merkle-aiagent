module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::lock_earn {
    struct MklClaimCapability has key {
        cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::ClaimCapability<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::COMMUNITY_POOL>,
    }
    
    struct RoundInfo<phantom T0> has store {
        user_points: 0x1::table::Table<address, u64>,
        user_claimed: 0x1::table::Table<address, bool>,
        total_points: u64,
        initial_reward_amount: u64,
        vault: 0x1::coin::Coin<T0>,
    }
    
    struct Rounds<phantom T0> has key {
        round_infos: 0x1::table::Table<u64, RoundInfo<T0>>,
    }
    
    struct ClaimRewardEvent has drop, store {
        round: u64,
        user: address,
        amount: u64,
        asset: 0x1::string::String,
    }
    
    struct LockPointEvent has drop, store {
        current_round: u64,
        user: address,
        lock_points: u64,
        total_lock_points: u64,
        asset: 0x1::string::String,
    }
    
    public entry fun claim_reward<T0>(arg0: &signer, arg1: u64) acquires Rounds {
        assert!(0x1::timestamp::now_seconds() < 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::point::get_round_finish_at_sec(arg1) + 2419200 && 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::point::is_round_ended(arg1), 2);
        let v0 = borrow_global_mut<Rounds<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        assert!(0x1::table::contains<u64, RoundInfo<T0>>(&v0.round_infos, arg1), 2);
        let v1 = 0x1::signer::address_of(arg0);
        let v2 = 0x1::table::borrow_mut<u64, RoundInfo<T0>>(&mut v0.round_infos, arg1);
        assert!(0x1::table::contains<address, u64>(&v2.user_points, v1), 2);
        assert!(0x1::table::contains<address, bool>(&v2.user_claimed, v1) && *0x1::table::borrow<address, bool>(&v2.user_claimed, v1) == false || true, 2);
        let v3 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v2.initial_reward_amount, *0x1::table::borrow<address, u64>(&v2.user_points, v1), v2.total_points);
        0x1::aptos_account::deposit_coins<T0>(0x1::signer::address_of(arg0), 0x1::coin::extract<T0>(&mut v2.vault, v3));
        0x1::table::upsert<address, bool>(&mut v2.user_claimed, v1, true);
        let v4 = ClaimRewardEvent{
            round  : arg1, 
            user   : v1, 
            amount : v3, 
            asset  : 0x1::type_info::type_name<T0>(),
        };
        0x1::event::emit<ClaimRewardEvent>(v4);
    }
    
    public entry fun initialize_module<T0>(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        if (exists<Rounds<T0>>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = Rounds<T0>{round_infos: 0x1::table::new<u64, RoundInfo<T0>>()};
            move_to<Rounds<T0>>(arg0, v0);
        };
        if (exists<MklClaimCapability>(0x1::signer::address_of(arg0))) {
        } else {
            let v1 = MklClaimCapability{cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::mint_claim_capability<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::COMMUNITY_POOL>(arg0)};
            move_to<MklClaimCapability>(arg0, v1);
        };
    }
    
    public entry fun lock_point<T0>(arg0: &signer, arg1: u64) acquires Rounds {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::blocked_user::is_blocked(0x1::signer::address_of(arg0));
        let v0 = borrow_global_mut<Rounds<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = 0x1::signer::address_of(arg0);
        let v2 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::point::get_current_round();
        assert!(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::point::is_current_round_started() && !0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::point::is_round_ended(v2), 3);
        if (0x1::table::contains<u64, RoundInfo<T0>>(&v0.round_infos, v2)) {
        } else {
            let v3 = RoundInfo<T0>{
                user_points           : 0x1::table::new<address, u64>(), 
                user_claimed          : 0x1::table::new<address, bool>(), 
                total_points          : 0, 
                initial_reward_amount : 0, 
                vault                 : 0x1::coin::zero<T0>(),
            };
            0x1::table::add<u64, RoundInfo<T0>>(&mut v0.round_infos, v2, v3);
        };
        let v4 = 0x1::table::borrow_mut<u64, RoundInfo<T0>>(&mut v0.round_infos, v2);
        let v5 = 0x1::table::borrow_mut_with_default<address, u64>(&mut v4.user_points, v1, 0);
        *v5 = *v5 + arg1;
        let v6 = &mut v4.total_points;
        *v6 = *v6 + arg1;
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::point::spend_point(v1, arg1);
        let v7 = LockPointEvent{
            current_round     : v2, 
            user              : v1, 
            lock_points       : arg1, 
            total_lock_points : *v5, 
            asset             : 0x1::type_info::type_name<T0>(),
        };
        0x1::event::emit<LockPointEvent>(v7);
    }
    
    public entry fun set_reward<T0>(arg0: &signer, arg1: u64, arg2: u64) acquires MklClaimCapability, Rounds {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v0 = borrow_global_mut<Rounds<T0>>(0x1::signer::address_of(arg0));
        if (0x1::table::contains<u64, RoundInfo<T0>>(&v0.round_infos, arg1)) {
        } else {
            let v1 = RoundInfo<T0>{
                user_points           : 0x1::table::new<address, u64>(), 
                user_claimed          : 0x1::table::new<address, bool>(), 
                total_points          : 0, 
                initial_reward_amount : 0, 
                vault                 : 0x1::coin::zero<T0>(),
            };
            0x1::table::add<u64, RoundInfo<T0>>(&mut v0.round_infos, arg1, v1);
        };
        let v2 = 0x1::table::borrow_mut<u64, RoundInfo<T0>>(&mut v0.round_infos, arg1);
        v2.initial_reward_amount = arg2;
        let v3 = 0x1::coin::value<T0>(&v2.vault);
        if (v3 >= arg2) {
            return
        };
        let v4 = arg2 - v3;
        if (0x1::type_info::type_of<T0>() == 0x1::type_info::type_of<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::MKL>()) {
            0x1::primary_fungible_store::deposit(0x1::signer::address_of(arg0), 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::claim_mkl_with_cap<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::COMMUNITY_POOL>(&borrow_global<MklClaimCapability>(0x1::signer::address_of(arg0)).cap, v4));
        };
        0x1::coin::merge<T0>(&mut v2.vault, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fa_box::get_fa_coin_if_needed<T0>(arg0, v4));
    }
    
    public entry fun withdraw_reward<T0>(arg0: &signer, arg1: u64) acquires Rounds {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        0x1::aptos_account::deposit_coins<T0>(0x1::signer::address_of(arg0), 0x1::coin::extract_all<T0>(&mut 0x1::table::borrow_mut<u64, RoundInfo<T0>>(&mut borrow_global_mut<Rounds<T0>>(0x1::signer::address_of(arg0)).round_infos, arg1).vault));
    }
    
    // decompiled from Move bytecode v6
}


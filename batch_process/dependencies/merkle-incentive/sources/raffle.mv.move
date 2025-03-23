module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::raffle {
    struct MklClaimCapability has key {
        cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::ClaimCapability<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::COMMUNITY_POOL>,
    }
    
    struct RoundInfo has store {
        points_per_draw: u64,
        max_leverage: u64,
        start_at_sec: u64,
        finish_at_sec: u64,
    }
    
    struct Rounds has key {
        round_infos: 0x1::table::Table<u64, RoundInfo>,
    }
    
    struct DrawEvent has drop, store {
        current_round: u64,
        user: address,
        reward_idx: u64,
        leverage: u64,
        point_amount: u64,
        drawed_amount: u64,
        reward_amount: u64,
        from_asset: 0x1::string::String,
        to_asset: 0x1::string::String,
    }
    
    struct RewardInfo<phantom T0, phantom T1> has store, key {
        vault: 0x1::coin::Coin<T0>,
        reward_info: vector<u64>,
        prob_info: vector<u64>,
        prob_sum: u64,
        initial_reward_amount: u64,
    }
    
    struct Rewards<phantom T0, phantom T1> has key {
        reward_info: 0x1::table::Table<u64, RewardInfo<T0, T1>>,
    }
    
    public entry fun add_reward<T0, T1>(arg0: &signer, arg1: vector<u64>, arg2: vector<u64>, arg3: u64) {
        abort 0
    }
    
    public entry fun add_reward_v2<T0, T1>(arg0: &signer, arg1: u64, arg2: vector<u64>, arg3: vector<u64>, arg4: u64) acquires Rewards {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        if (exists<Rewards<T0, T1>>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = Rewards<T0, T1>{reward_info: 0x1::table::new<u64, RewardInfo<T0, T1>>()};
            move_to<Rewards<T0, T1>>(arg0, v0);
        };
        let v1 = 0;
        let v2 = arg2;
        0x1::vector::reverse<u64>(&mut v2);
        let v3 = v2;
        let v4 = 0x1::vector::length<u64>(&v3);
        while (v4 > 0) {
            v1 = v1 + 0x1::vector::pop_back<u64>(&mut v3);
            v4 = v4 - 1;
        };
        0x1::vector::destroy_empty<u64>(v3);
        let v5 = RewardInfo<T0, T1>{
            vault                 : 0x1::coin::zero<T0>(), 
            reward_info           : arg3, 
            prob_info             : arg2, 
            prob_sum              : v1, 
            initial_reward_amount : arg4,
        };
        0x1::table::add<u64, RewardInfo<T0, T1>>(&mut borrow_global_mut<Rewards<T0, T1>>(0x1::signer::address_of(arg0)).reward_info, arg1, v5);
    }
    
    public entry fun deposit_reward<T0, T1>(arg0: &signer, arg1: u64) {
        abort 0
    }
    
    public entry fun deposit_reward_v2<T0, T1>(arg0: &signer, arg1: u64, arg2: u64) acquires MklClaimCapability, Rewards {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        if (0x1::type_info::type_of<T0>() == 0x1::type_info::type_of<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::MKL>()) {
            0x1::primary_fungible_store::deposit(0x1::signer::address_of(arg0), 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::claim_mkl_with_cap<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::COMMUNITY_POOL>(&borrow_global<MklClaimCapability>(0x1::signer::address_of(arg0)).cap, arg2));
        };
        0x1::coin::merge<T0>(&mut 0x1::table::borrow_mut<u64, RewardInfo<T0, T1>>(&mut borrow_global_mut<Rewards<T0, T1>>(0x1::signer::address_of(arg0)).reward_info, arg1).vault, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fa_box::get_fa_coin_if_needed<T0>(arg0, arg2));
    }
    
    fun draw_reward_idx<T0, T1>(arg0: &RewardInfo<T0, T1>) : u64 {
        let v0 = 0;
        let v1 = 0;
        while (v1 < 0x1::vector::length<u64>(&arg0.prob_info)) {
            let v2 = v0 + *0x1::vector::borrow<u64>(&arg0.prob_info, v1);
            v0 = v2;
            if (0x1::randomness::u64_range(0, arg0.prob_sum) < v2) {
                break
            };
            v1 = v1 + 1;
        };
        v1
    }
    
    entry fun draw_with_coin_store<T0, T1>(arg0: &signer, arg1: u64) acquires Rounds, Rewards {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::blocked_user::is_blocked(0x1::signer::address_of(arg0));
        assert!(is_raffle_open(), 1);
        let v0 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::point::get_current_round();
        let v1 = 0x1::table::borrow_mut<u64, RewardInfo<T0, T1>>(&mut borrow_global_mut<Rewards<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).reward_info, v0);
        let v2 = 0x1::table::borrow_mut<u64, RoundInfo>(&mut borrow_global_mut<Rounds>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).round_infos, v0);
        let v3 = 0x1::coin::value<T0>(&mut v1.vault);
        assert!(0 < arg1 && arg1 <= v2.max_leverage, 2);
        assert!(v3 > 0, 3);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::point::spend_point(0x1::signer::address_of(arg0), v2.points_per_draw * arg1);
        let v4 = draw_reward_idx<T0, T1>(v1);
        let v5 = *0x1::vector::borrow<u64>(&v1.reward_info, v4) * arg1;
        let v6 = if (v3 > v5) {
            v5
        } else {
            v3
        };
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fa_box::deposit_asset_to_user<T0>(0x1::signer::address_of(arg0), 0x1::coin::extract<T0>(&mut v1.vault, v6));
        let v7 = DrawEvent{
            current_round : v0, 
            user          : 0x1::signer::address_of(arg0), 
            reward_idx    : v4, 
            leverage      : arg1, 
            point_amount  : v2.points_per_draw * arg1, 
            drawed_amount : v5, 
            reward_amount : v6, 
            from_asset    : 0x1::type_info::type_name<T0>(), 
            to_asset      : 0x1::type_info::type_name<T1>(),
        };
        0x1::event::emit<DrawEvent>(v7);
    }
    
    public entry fun initialize_module(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        if (exists<Rounds>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = Rounds{round_infos: 0x1::table::new<u64, RoundInfo>()};
            move_to<Rounds>(arg0, v0);
        };
        if (exists<MklClaimCapability>(0x1::signer::address_of(arg0))) {
        } else {
            let v1 = MklClaimCapability{cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::mint_claim_capability<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::COMMUNITY_POOL>(arg0)};
            move_to<MklClaimCapability>(arg0, v1);
        };
    }
    
    public fun is_raffle_open() : bool acquires Rounds {
        if (exists<Rounds>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)) {
            let v0 = borrow_global_mut<Rounds>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
            let v1 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::point::get_current_round();
            if (0x1::table::contains<u64, RoundInfo>(&v0.round_infos, v1)) {
                let v2 = 0x1::table::borrow_mut<u64, RoundInfo>(&mut v0.round_infos, v1);
                let v3 = 0x1::timestamp::now_seconds();
                return v2.start_at_sec < v3 && v3 < v2.finish_at_sec
            };
            return false
        };
        false
    }
    
    public entry fun set_initial_reward_amount<T0, T1>(arg0: &signer, arg1: u64) {
        abort 0
    }
    
    public entry fun set_initial_reward_amount_v2<T0, T1>(arg0: &signer, arg1: u64, arg2: u64) acquires Rewards {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        0x1::table::borrow_mut<u64, RewardInfo<T0, T1>>(&mut borrow_global_mut<Rewards<T0, T1>>(0x1::signer::address_of(arg0)).reward_info, arg1).initial_reward_amount = arg2;
    }
    
    public entry fun set_max_leverage(arg0: &signer, arg1: u64, arg2: u64) acquires Rounds {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        0x1::table::borrow_mut<u64, RoundInfo>(&mut borrow_global_mut<Rounds>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).round_infos, arg1).max_leverage = arg2;
    }
    
    public entry fun set_points_per_draw(arg0: &signer, arg1: u64, arg2: u64) acquires Rounds {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        0x1::table::borrow_mut<u64, RoundInfo>(&mut borrow_global_mut<Rounds>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).round_infos, arg1).points_per_draw = arg2;
    }
    
    public entry fun set_prob_info<T0, T1>(arg0: &signer, arg1: vector<u64>, arg2: vector<u64>) {
        abort 0
    }
    
    public entry fun set_prob_info_v2<T0, T1>(arg0: &signer, arg1: u64, arg2: vector<u64>, arg3: vector<u64>) acquires Rewards {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        let v0 = 0;
        let v1 = arg2;
        0x1::vector::reverse<u64>(&mut v1);
        let v2 = v1;
        let v3 = 0x1::vector::length<u64>(&v2);
        while (v3 > 0) {
            v0 = v0 + 0x1::vector::pop_back<u64>(&mut v2);
            v3 = v3 - 1;
        };
        0x1::vector::destroy_empty<u64>(v2);
        let v4 = 0x1::table::borrow_mut<u64, RewardInfo<T0, T1>>(&mut borrow_global_mut<Rewards<T0, T1>>(0x1::signer::address_of(arg0)).reward_info, arg1);
        v4.reward_info = arg3;
        v4.prob_info = arg2;
        v4.prob_sum = v0;
    }
    
    public entry fun set_round(arg0: &signer, arg1: u64, arg2: u64, arg3: u64, arg4: u64, arg5: u64) acquires Rounds {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        let v0 = RoundInfo{
            points_per_draw : arg2, 
            max_leverage    : arg3, 
            start_at_sec    : arg4, 
            finish_at_sec   : arg5,
        };
        0x1::table::add<u64, RoundInfo>(&mut borrow_global_mut<Rounds>(0x1::signer::address_of(arg0)).round_infos, arg1, v0);
    }
    
    public entry fun set_start_finish_at_sec(arg0: &signer, arg1: u64, arg2: u64, arg3: u64) acquires Rounds {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        let v0 = 0x1::table::borrow_mut<u64, RoundInfo>(&mut borrow_global_mut<Rounds>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).round_infos, arg1);
        v0.start_at_sec = arg2;
        v0.finish_at_sec = arg3;
    }
    
    public entry fun withdraw_reward<T0, T1>(arg0: &signer, arg1: u64) {
        abort 0
    }
    
    public entry fun withdraw_reward_v2<T0, T1>(arg0: &signer, arg1: u64, arg2: u64) acquires Rewards {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fa_box::deposit_asset_to_user<T0>(0x1::signer::address_of(arg0), 0x1::coin::extract<T0>(&mut 0x1::table::borrow_mut<u64, RewardInfo<T0, T1>>(&mut borrow_global_mut<Rewards<T0, T1>>(0x1::signer::address_of(arg0)).reward_info, arg1).vault, arg2));
    }
    
    // decompiled from Move bytecode v6
}


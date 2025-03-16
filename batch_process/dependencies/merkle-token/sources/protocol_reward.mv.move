module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::protocol_reward {
    struct EpochReward<phantom T0> has key {
        reward: 0x1::table::Table<u64, Reward<T0>>,
    }
    
    struct ProtocolRevenueEvent has drop, store {
        user: address,
        asset_type: 0x1::type_info::TypeInfo,
        amount: u64,
    }
    
    struct ProtocolRewardConfig<phantom T0> has key {
        params: 0x1::simple_map::SimpleMap<0x1::string::String, vector<u8>>,
    }
    
    struct ProtocolRewardEvents has key {
        protocol_revenue_events: 0x1::event::EventHandle<ProtocolRevenueEvent>,
    }
    
    struct Reward<phantom T0> has store {
        registered_at: u64,
        registered_reward_amount: u64,
        coin: 0x1::coin::Coin<T0>,
    }
    
    struct UserRewardInfo<phantom T0> has key {
        claimed_epoch: vector<u64>,
    }
    
    public fun claim_rewards<T0>(arg0: &signer, arg1: u64) acquires EpochReward, ProtocolRewardConfig, ProtocolRewardEvents, UserRewardInfo {
        assert!(arg1 < 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::staking::get_current_epoch_start_time(), 3);
        let v0 = borrow_global_mut<EpochReward<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (exists<UserRewardInfo<T0>>(0x1::signer::address_of(arg0))) {
        } else {
            let v1 = UserRewardInfo<T0>{claimed_epoch: 0x1::vector::empty<u64>()};
            move_to<UserRewardInfo<T0>>(arg0, v1);
        };
        let v2 = borrow_global_mut<UserRewardInfo<T0>>(0x1::signer::address_of(arg0));
        assert!(arg1 % 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::staking::get_epoch_duration() == 0 && !0x1::vector::contains<u64>(&v2.claimed_epoch, &arg1) && 0x1::table::contains<u64, Reward<T0>>(&v0.reward, arg1), 1);
        let v3 = 0x1::table::borrow_mut<u64, Reward<T0>>(&mut v0.reward, arg1);
        let v4 = get_params_u64_value<T0>(b"CLAIMABLE_DURATION", 1209600);
        assert!(0x1::timestamp::now_seconds() - v3.registered_at <= v4, 2);
        let v5 = user_reward_amount_internal<T0>(v3, 0x1::signer::address_of(arg0), arg1);
        0x1::aptos_account::deposit_coins<T0>(0x1::signer::address_of(arg0), 0x1::coin::extract<T0>(&mut v3.coin, v5));
        0x1::vector::push_back<u64>(&mut v2.claimed_epoch, arg1);
        if (0x1::vector::length<u64>(&v2.claimed_epoch) > 52) {
            0x1::vector::swap_remove<u64>(&mut v2.claimed_epoch, 0);
        };
        let v6 = ProtocolRevenueEvent{
            user       : 0x1::signer::address_of(arg0), 
            asset_type : 0x1::type_info::type_of<T0>(), 
            amount     : v5,
        };
        0x1::event::emit_event<ProtocolRevenueEvent>(&mut borrow_global_mut<ProtocolRewardEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).protocol_revenue_events, v6);
    }
    
    public fun get_params_u64_value<T0>(arg0: vector<u8>, arg1: u64) : u64 acquires ProtocolRewardConfig {
        if (exists<ProtocolRewardConfig<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)) {
            let v0 = borrow_global_mut<ProtocolRewardConfig<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
            let v1 = 0x1::string::utf8(arg0);
            if (0x1::simple_map::contains_key<0x1::string::String, vector<u8>>(&v0.params, &v1)) {
                let v2 = 0x1::string::utf8(arg0);
                return 0x1::from_bcs::to_u64(*0x1::simple_map::borrow<0x1::string::String, vector<u8>>(&v0.params, &v2))
            };
            return arg1
        };
        arg1
    }
    
    public fun initialize_module<T0>(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        if (exists<ProtocolRewardEvents>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = ProtocolRewardEvents{protocol_revenue_events: 0x1::account::new_event_handle<ProtocolRevenueEvent>(arg0)};
            move_to<ProtocolRewardEvents>(arg0, v0);
        };
        if (exists<EpochReward<T0>>(0x1::signer::address_of(arg0))) {
        } else {
            let v1 = EpochReward<T0>{reward: 0x1::table::new<u64, Reward<T0>>()};
            move_to<EpochReward<T0>>(arg0, v1);
        };
        if (exists<ProtocolRewardConfig<T0>>(0x1::signer::address_of(arg0))) {
        } else {
            let v2 = ProtocolRewardConfig<T0>{params: 0x1::simple_map::new<0x1::string::String, vector<u8>>()};
            move_to<ProtocolRewardConfig<T0>>(arg0, v2);
        };
    }
    
    public fun register_vemkl_protocol_rewards<T0>(arg0: &signer, arg1: u64, arg2: u64) acquires EpochReward {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        assert!(arg1 % 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::staking::get_epoch_duration() == 0, 3);
        let v0 = borrow_global_mut<EpochReward<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::table::contains<u64, Reward<T0>>(&v0.reward, arg1)) {
            let v1 = 0x1::table::borrow_mut<u64, Reward<T0>>(&mut v0.reward, arg1);
            v1.registered_reward_amount = arg2;
            v1.registered_at = 0x1::timestamp::now_seconds();
            0x1::aptos_account::deposit_coins<T0>(0x1::signer::address_of(arg0), 0x1::coin::extract_all<T0>(&mut v1.coin));
            0x1::coin::merge<T0>(&mut v1.coin, 0x1::coin::withdraw<T0>(arg0, arg2));
        } else {
            let v2 = Reward<T0>{
                registered_at            : 0x1::timestamp::now_seconds(), 
                registered_reward_amount : arg2, 
                coin                     : 0x1::coin::withdraw<T0>(arg0, arg2),
            };
            0x1::table::add<u64, Reward<T0>>(&mut v0.reward, arg1, v2);
        };
    }
    
    public fun set_param<T0>(arg0: &signer, arg1: 0x1::string::String, arg2: vector<u8>) acquires ProtocolRewardConfig {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        let (_, _) = 0x1::simple_map::upsert<0x1::string::String, vector<u8>>(&mut borrow_global_mut<ProtocolRewardConfig<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).params, arg1, arg2);
    }
    
    public fun user_reward_amount<T0>(arg0: address, arg1: u64) : u64 acquires EpochReward, ProtocolRewardConfig, UserRewardInfo {
        if (exists<UserRewardInfo<T0>>(arg0)) {
            if (0x1::vector::contains<u64>(&borrow_global<UserRewardInfo<T0>>(arg0).claimed_epoch, &arg1)) {
                return 0
            };
        };
        let v0 = borrow_global_mut<EpochReward<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::table::contains<u64, Reward<T0>>(&v0.reward, arg1)) {
            let v1 = 0x1::table::borrow_mut<u64, Reward<T0>>(&mut v0.reward, arg1);
            let v2 = get_params_u64_value<T0>(b"CLAIMABLE_DURATION", 1209600);
            if (0x1::timestamp::now_seconds() - v1.registered_at > v2) {
                return 0
            };
            return user_reward_amount_internal<T0>(v1, arg0, arg1)
        };
        0
    }
    
    fun user_reward_amount_internal<T0>(arg0: &Reward<T0>, arg1: address, arg2: u64) : u64 {
        let (v0, v1) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::staking::get_epoch_user_vote_power(arg1, arg2);
        if (v1 == 0) {
            return 0
        };
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(arg0.registered_reward_amount, v0, v1)
    }
    
    public fun withdraw_expired_protocol_reward<T0>(arg0: &signer, arg1: u64) acquires EpochReward {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        let v0 = 0x1::table::borrow_mut<u64, Reward<T0>>(&mut borrow_global_mut<EpochReward<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).reward, arg1);
        assert!(0x1::timestamp::now_seconds() - v0.registered_at > 1209600, 4);
        0x1::aptos_account::deposit_coins<T0>(0x1::signer::address_of(arg0), 0x1::coin::extract_all<T0>(&mut v0.coin));
    }
    
    // decompiled from Move bytecode v6
}


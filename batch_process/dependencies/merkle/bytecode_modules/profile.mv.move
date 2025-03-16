module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::profile {
    struct BoostEvent has key {
        increase_boost_events: 0x1::event::EventHandle<IncreaseBoostEvent>,
    }
    
    struct ClassInfo has key {
        required_xp: vector<u64>,
        required_level: vector<u64>,
    }
    
    struct IncreaseBoostEvent has drop, store {
        user: address,
        boosted: vector<u64>,
    }
    
    struct IncreaseXPEvent has drop, store {
        user: address,
        boosted: u64,
        gained_xp: u64,
        xp_from: u64,
        level_from: u64,
        class_from: u64,
        required_xp_from: u64,
        xp_to: u64,
        level_to: u64,
        class_to: u64,
        required_xp_to: u64,
    }
    
    struct LevelInfo has store {
        level: u64,
        xp: u64,
    }
    
    struct ProfileEvent has key {
        increase_xp_events: 0x1::event::EventHandle<IncreaseXPEvent>,
    }
    
    struct SoftResetConfig has key {
        soft_reset_rate: u64,
        user_soft_reset: 0x1::table::Table<address, u64>,
    }
    
    struct SoftResetEvent has drop, store {
        user: address,
        season_number: u64,
        previous_tier: u64,
        previous_level: u64,
        soft_reset_tier: u64,
        soft_reset_level: u64,
        reward_lootboxes: vector<u64>,
    }
    
    struct SoftResetEvents has key {
        profile_soft_reset_events: 0x1::event::EventHandle<SoftResetEvent>,
    }
    
    struct UserInfo has key {
        level_info: 0x1::table::Table<address, LevelInfo>,
        daily_boost_info: 0x1::table::Table<address, vector<u64>>,
    }
    
    public(friend) fun add_daily_boost(arg0: address) acquires BoostEvent, UserInfo {
        let v0 = borrow_global_mut<UserInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::table::contains<address, vector<u64>>(&v0.daily_boost_info, arg0)) {
        } else {
            0x1::table::add<address, vector<u64>>(&mut v0.daily_boost_info, arg0, 0x1::vector::empty<u64>());
        };
        let v1 = 0x1::table::borrow_mut<address, vector<u64>>(&mut v0.daily_boost_info, arg0);
        let v2 = 0x1::timestamp::now_seconds() / 86400;
        loop {
            if (0x1::vector::length<u64>(v1) == 0) {
                break
            };
            if (v2 - *0x1::vector::borrow<u64>(v1, 0) < 7) {
                break
            };
            0x1::vector::remove<u64>(v1, 0);
        };
        if (0x1::vector::contains<u64>(v1, &v2)) {
        } else {
            0x1::vector::push_back<u64>(v1, v2);
            let v3 = IncreaseBoostEvent{
                user    : arg0, 
                boosted : *v1,
            };
            0x1::event::emit_event<IncreaseBoostEvent>(&mut borrow_global_mut<BoostEvent>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).increase_boost_events, v3);
        };
    }
    
    public fun add_new_class(arg0: &signer, arg1: u64, arg2: u64) acquires ClassInfo {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v0 = borrow_global_mut<ClassInfo>(0x1::signer::address_of(arg0));
        0x1::vector::push_back<u64>(&mut v0.required_level, arg1);
        0x1::vector::push_back<u64>(&mut v0.required_xp, arg2);
    }
    
    public fun apply_soft_reset_level(arg0: &signer, arg1: vector<address>, arg2: vector<vector<u64>>) acquires ClassInfo, SoftResetConfig, SoftResetEvents, UserInfo {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        assert!(0x1::vector::length<address>(&arg1) == 0x1::vector::length<vector<u64>>(&arg2), 2);
        let v0 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number() - 1;
        let v1 = borrow_global_mut<SoftResetConfig>(0x1::signer::address_of(arg0));
        let v2 = 0;
        while (v2 < 0x1::vector::length<address>(&arg1)) {
            let v3 = true;
            let v4 = *0x1::vector::borrow<address>(&arg1, v2);
            if (0x1::table::contains<address, u64>(&v1.user_soft_reset, v4)) {
                v3 = *0x1::table::borrow<address, u64>(&v1.user_soft_reset, v4) < v0;
            };
            let v5 = borrow_global_mut<UserInfo>(0x1::signer::address_of(arg0));
            if (v3 && 0x1::table::contains<address, LevelInfo>(&v5.level_info, v4)) {
                let v6 = 0x1::table::borrow_mut<address, LevelInfo>(&mut v5.level_info, v4);
                let v7 = (v6.level * v1.soft_reset_rate + 999999) / 1000000;
                let v8 = v7;
                if (v7 == 0) {
                    v8 = 1;
                };
                let (v9, _) = get_level_class(v6.level);
                let (v11, _) = get_level_class(v8);
                let v13 = *0x1::vector::borrow<vector<u64>>(&arg2, v2);
                let v14 = SoftResetEvent{
                    user             : v4, 
                    season_number    : v0, 
                    previous_tier    : v9, 
                    previous_level   : v6.level, 
                    soft_reset_tier  : v11, 
                    soft_reset_level : v8, 
                    reward_lootboxes : v13,
                };
                0x1::event::emit_event<SoftResetEvent>(&mut borrow_global_mut<SoftResetEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).profile_soft_reset_events, v14);
                0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::lootbox_v2::mint_soft_reset_lootboxes(arg0, v4, v13);
                0x1::table::upsert<address, u64>(&mut v1.user_soft_reset, v4, v0);
                v6.level = v8;
                v6.xp = 0;
                v2 = v2 + 1;
                continue
            };
            v2 = v2 + 1;
        };
    }
    
    public fun boost_event_initialized(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        if (exists<BoostEvent>(0x1::signer::address_of(arg0))) {
            return
        };
        let v0 = BoostEvent{increase_boost_events: 0x1::account::new_event_handle<IncreaseBoostEvent>(arg0)};
        move_to<BoostEvent>(arg0, v0);
    }
    
    public fun get_boost(arg0: address) : u64 acquires UserInfo {
        let v0 = borrow_global_mut<UserInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::table::contains<address, vector<u64>>(&v0.daily_boost_info, arg0)) {
        } else {
            0x1::table::add<address, vector<u64>>(&mut v0.daily_boost_info, arg0, 0x1::vector::empty<u64>());
        };
        let v1 = 0x1::table::borrow_mut<address, vector<u64>>(&mut v0.daily_boost_info, arg0);
        let v2 = 0;
        let v3 = 0;
        loop {
            if (0x1::vector::length<u64>(v1) == v3) {
                break
            };
            if (0x1::timestamp::now_seconds() / 86400 - *0x1::vector::borrow<u64>(v1, v3) < 7) {
                v2 = v2 + 1;
            };
            v3 = v3 + 1;
        };
        v2
    }
    
    fun get_level_class(arg0: u64) : (u64, u64) acquires ClassInfo {
        let v0 = borrow_global<ClassInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = 1;
        let v2;
        loop {
            if (v1 == 0x1::vector::length<u64>(&v0.required_level)) {
                v2 = *0x1::vector::borrow<u64>(&v0.required_xp, v1 - 1);
                /* label 7 */
                return (v1 - 1, v2)
            };
            if (arg0 < *0x1::vector::borrow<u64>(&v0.required_level, v1)) {
                break
            };
            v1 = v1 + 1;
        };
        v2 = *0x1::vector::borrow<u64>(&v0.required_xp, v1 - 1);
        /* goto 7 */
    }
    
    public fun get_level_info(arg0: address) : (u64, u64, u64, u64) acquires ClassInfo, UserInfo {
        let v0 = borrow_global_mut<UserInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::table::contains<address, vector<u64>>(&v0.daily_boost_info, arg0)) {
            let v1 = 0x1::table::borrow_mut<address, LevelInfo>(&mut v0.level_info, arg0);
            let (v2, v3) = get_level_class(v1.level);
            return (v1.xp, v1.level, v2, v3)
        };
        let (v4, v5) = get_level_class(1);
        (0, 1, v4, v5)
    }
    
    public(friend) fun increase_xp<T0>(arg0: address, arg1: u64) acquires ClassInfo, ProfileEvent, UserInfo {
        let v0 = get_boost(arg0);
        let v1 = 1000000 + v0 * 1000000 / 100 + 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::get_xp_boost_effect<T0>(arg0, true);
        let v2 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(arg1, v1, 1000000);
        let v3 = borrow_global_mut<UserInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::table::contains<address, LevelInfo>(&v3.level_info, arg0)) {
        } else {
            let v4 = LevelInfo{
                level : 1, 
                xp    : 0,
            };
            0x1::table::add<address, LevelInfo>(&mut v3.level_info, arg0, v4);
        };
        let v5 = 0x1::table::borrow_mut<address, LevelInfo>(&mut v3.level_info, arg0);
        let (v6, v7) = get_level_class(v5.level);
        v5.xp = v5.xp + v2;
        let (v8, v9) = get_level_class(v5.level);
        while (v9 <= v5.xp) {
            v5.level = v5.level + 1;
            v5.xp = v5.xp - v9;
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::lootbox_v2::mint_lootbox(arg0, v8, 1);
        };
        let (v10, v11) = get_level_class(v5.level);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::lootbox_v2::emit_lootbox_events(arg0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::lootbox_v2::get_user_current_season_lootboxes(arg0), 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::lootbox_v2::get_user_current_season_lootboxes(arg0));
        let v12 = IncreaseXPEvent{
            user             : arg0, 
            boosted          : v1, 
            gained_xp        : v2, 
            xp_from          : v5.xp, 
            level_from       : v5.level, 
            class_from       : v6, 
            required_xp_from : v7, 
            xp_to            : v5.xp, 
            level_to         : v5.level, 
            class_to         : v10, 
            required_xp_to   : v11,
        };
        0x1::event::emit_event<IncreaseXPEvent>(&mut borrow_global_mut<ProfileEvent>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).increase_xp_events, v12);
    }
    
    fun init_module(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v0 = ClassInfo{
            required_xp    : vector[300000000, 600000000, 1200000000, 2400000000, 4800000000], 
            required_level : vector[1, 6, 16, 51, 81],
        };
        move_to<ClassInfo>(arg0, v0);
        let v1 = UserInfo{
            level_info       : 0x1::table::new<address, LevelInfo>(), 
            daily_boost_info : 0x1::table::new<address, vector<u64>>(),
        };
        move_to<UserInfo>(arg0, v1);
        let v2 = ProfileEvent{increase_xp_events: 0x1::account::new_event_handle<IncreaseXPEvent>(arg0)};
        move_to<ProfileEvent>(arg0, v2);
        let v3 = BoostEvent{increase_boost_events: 0x1::account::new_event_handle<IncreaseBoostEvent>(arg0)};
        move_to<BoostEvent>(arg0, v3);
    }
    
    public fun initialize_module(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        if (exists<SoftResetEvents>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = SoftResetEvents{profile_soft_reset_events: 0x1::account::new_event_handle<SoftResetEvent>(arg0)};
            move_to<SoftResetEvents>(arg0, v0);
        };
        if (exists<SoftResetConfig>(0x1::signer::address_of(arg0))) {
        } else {
            let v1 = SoftResetConfig{
                soft_reset_rate : 800000, 
                user_soft_reset : 0x1::table::new<address, u64>(),
            };
            move_to<SoftResetConfig>(arg0, v1);
        };
    }
    
    public fun set_soft_reset_rate(arg0: &signer, arg1: u64) acquires SoftResetConfig {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        borrow_global_mut<SoftResetConfig>(0x1::signer::address_of(arg0)).soft_reset_rate = arg1;
    }
    
    public fun set_user_soft_reset_level(arg0: &signer, arg1: address, arg2: u64) acquires SoftResetConfig {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        0x1::table::upsert<address, u64>(&mut borrow_global_mut<SoftResetConfig>(0x1::signer::address_of(arg0)).user_soft_reset, arg1, arg2);
    }
    
    public fun update_class(arg0: &signer, arg1: u64, arg2: u64, arg3: u64) acquires ClassInfo {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v0 = borrow_global_mut<ClassInfo>(0x1::signer::address_of(arg0));
        *0x1::vector::borrow_mut<u64>(&mut v0.required_level, arg1) = arg2;
        *0x1::vector::borrow_mut<u64>(&mut v0.required_xp, arg1) = arg3;
    }
    
    // decompiled from Move bytecode v6
}


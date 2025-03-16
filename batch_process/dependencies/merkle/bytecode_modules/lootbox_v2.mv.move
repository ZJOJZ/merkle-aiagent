module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::lootbox_v2 {
    struct AdminCapability has copy, drop, store {
        dummy_field: bool,
    }
    
    struct FtuLootBoxEvent has drop, store {
        user: address,
        reward_tier: u64,
        referrer: address,
    }
    
    struct FtuLootBoxInfo has key {
        user_ftu_lootbox: 0x1::table::Table<address, u64>,
    }
    
    struct LootBoxEvent has drop, store {
        season: u64,
        user: address,
        lootbox: vector<u64>,
    }
    
    struct LootBoxInfo has key {
        season_lootbox: 0x1::table::Table<u64, UsersLootBox>,
    }
    
    struct LootBoxOpenEvent has drop, store {
        season: u64,
        user: address,
        tier: u64,
    }
    
    struct UserFtuLootBoxEvents has key {
        ftu_lootbox_events: 0x1::event::EventHandle<FtuLootBoxEvent>,
    }
    
    struct UserLootBoxEvent has key {
        lootbox_events: 0x1::event::EventHandle<LootBoxEvent>,
        lootbox_open_events: 0x1::event::EventHandle<LootBoxOpenEvent>,
    }
    
    struct UsersLootBox has store {
        users: 0x1::table::Table<address, vector<u64>>,
    }
    
    public(friend) fun emit_lootbox_events(arg0: address, arg1: vector<u64>, arg2: vector<u64>) acquires UserLootBoxEvent {
        let v0 = 0x1::vector::empty<u64>();
        let v1 = 0;
        let v2 = 0;
        while (v2 <= 4) {
            let v3 = 0;
            if (v2 < 0x1::vector::length<u64>(&arg2)) {
                let v4 = 0;
                if (v2 < 0x1::vector::length<u64>(&arg1)) {
                    let v5 = 0x1::vector::borrow<u64>(&arg1, v2);
                    v4 = *v5;
                };
                let v6 = 0x1::vector::borrow<u64>(&arg2, v2);
                v3 = *v6 - v4;
            };
            0x1::vector::push_back<u64>(&mut v0, v3);
            v2 = v2 + 1;
            v1 = v1 + v3;
        };
        if (v1 > 0) {
            let v7 = LootBoxEvent{
                season  : 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number(), 
                user    : arg0, 
                lootbox : v0,
            };
            0x1::event::emit_event<LootBoxEvent>(&mut borrow_global_mut<UserLootBoxEvent>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).lootbox_events, v7);
        };
    }
    
    public fun generate_admin_cap(arg0: &signer) : AdminCapability {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        AdminCapability{dummy_field: false}
    }
    
    public fun get_user_all_lootboxes(arg0: address) : vector<LootBoxEvent> acquires LootBoxInfo {
        let v0 = borrow_global_mut<LootBoxInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = 0x1::vector::empty<LootBoxEvent>();
        let v2 = 0;
        while (v2 <= 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number()) {
            if (0x1::table::contains<u64, UsersLootBox>(&v0.season_lootbox, v2)) {
                let v3 = 0x1::table::borrow<u64, UsersLootBox>(&v0.season_lootbox, v2);
                if (0x1::table::contains<address, vector<u64>>(&v3.users, arg0)) {
                    let v4 = *0x1::table::borrow<address, vector<u64>>(&v3.users, arg0);
                    let v5 = 0x1::vector::length<u64>(&v4);
                    while (v5 <= 4) {
                        0x1::vector::push_back<u64>(&mut v4, 0);
                        v5 = v5 + 1;
                    };
                    let v6 = LootBoxEvent{
                        season  : v2, 
                        user    : arg0, 
                        lootbox : v4,
                    };
                    0x1::vector::push_back<LootBoxEvent>(&mut v1, v6);
                    v2 = v2 + 1;
                    continue
                };
                v2 = v2 + 1;
                continue
            };
            v2 = v2 + 1;
        };
        v1
    }
    
    public fun get_user_current_season_lootboxes(arg0: address) : vector<u64> acquires LootBoxInfo {
        get_user_lootboxes(arg0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number())
    }
    
    public fun get_user_lootboxes(arg0: address, arg1: u64) : vector<u64> acquires LootBoxInfo {
        let v0 = borrow_global_mut<LootBoxInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::table::contains<u64, UsersLootBox>(&v0.season_lootbox, arg1)) {
            let v1 = 0x1::table::borrow<u64, UsersLootBox>(&v0.season_lootbox, arg1);
            let v2 = 0x1::vector::empty<u64>();
            if (0x1::table::contains<address, vector<u64>>(&v1.users, arg0)) {
                v2 = *0x1::table::borrow<address, vector<u64>>(&v1.users, arg0);
            };
            arg1 = 0x1::vector::length<u64>(&v2);
            while (arg1 <= 4) {
                0x1::vector::push_back<u64>(&mut v2, 0);
                arg1 = arg1 + 1;
            };
            return v2
        };
        let v3 = 0x1::vector::empty<u64>();
        let v4 = 0;
        while (v4 <= 4) {
            0x1::vector::push_back<u64>(&mut v3, 0);
            v4 = v4 + 1;
        };
        v3
    }
    
    public fun initialize_module(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        if (exists<LootBoxInfo>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = LootBoxInfo{season_lootbox: 0x1::table::new<u64, UsersLootBox>()};
            move_to<LootBoxInfo>(arg0, v0);
        };
        if (exists<UserLootBoxEvent>(0x1::signer::address_of(arg0))) {
        } else {
            let v1 = UserLootBoxEvent{
                lootbox_events      : 0x1::account::new_event_handle<LootBoxEvent>(arg0), 
                lootbox_open_events : 0x1::account::new_event_handle<LootBoxOpenEvent>(arg0),
            };
            move_to<UserLootBoxEvent>(arg0, v1);
        };
        if (exists<FtuLootBoxInfo>(0x1::signer::address_of(arg0))) {
        } else {
            let v2 = FtuLootBoxInfo{user_ftu_lootbox: 0x1::table::new<address, u64>()};
            move_to<FtuLootBoxInfo>(arg0, v2);
        };
        if (exists<UserFtuLootBoxEvents>(0x1::signer::address_of(arg0))) {
        } else {
            let v3 = UserFtuLootBoxEvents{ftu_lootbox_events: 0x1::account::new_event_handle<FtuLootBoxEvent>(arg0)};
            move_to<UserFtuLootBoxEvents>(arg0, v3);
        };
    }
    
    fun mint_gear_rand(arg0: &signer, arg1: u64, arg2: u64) {
        if (0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::random::get_random_between(1, 100) <= 40) {
            let v0 = 0;
            let v1 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::random::get_random_between(1, 100);
            if (arg1 == 0) {
                let v2 = if (v1 <= 90) {
                    0
                } else {
                    1
                };
                v0 = v2;
            } else {
                if (arg1 == 1) {
                    let v2 = if (v1 <= 30) {
                        0
                    } else {
                        1
                    };
                    v0 = v2;
                } else {
                    if (arg1 == 2) {
                        let v2 = if (v1 <= 10) {
                            0
                        } else {
                            if (v1 <= 70) {
                                1
                            } else {
                                2
                            }
                        };
                        v0 = v2;
                    } else {
                        if (arg1 == 3) {
                            let v2 = if (v1 <= 40) {
                                1
                            } else {
                                if (v1 <= 86) {
                                    2
                                } else {
                                    3
                                }
                            };
                            v0 = v2;
                        } else {
                            if (arg1 == 4) {
                                if (v1 <= 65) {
                                    arg1 = 2;
                                } else {
                                    if (v1 <= 95) {
                                        arg1 = 3;
                                    } else {
                                        arg1 = 4;
                                    };
                                };
                                v0 = arg1;
                            };
                        };
                    };
                };
            };
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::mint_v2_rand(arg0, v0, arg2);
            return
        };
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::random::add_random_padding();
    }
    
    public(friend) fun mint_lootbox(arg0: address, arg1: u64, arg2: u64) acquires LootBoxInfo {
        assert!(arg1 <= 4, 2);
        let v0 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number();
        let v1 = borrow_global_mut<LootBoxInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::table::contains<u64, UsersLootBox>(&v1.season_lootbox, v0)) {
        } else {
            let v2 = UsersLootBox{users: 0x1::table::new<address, vector<u64>>()};
            0x1::table::add<u64, UsersLootBox>(&mut v1.season_lootbox, v0, v2);
        };
        let v3 = 0x1::table::borrow_mut<u64, UsersLootBox>(&mut v1.season_lootbox, v0);
        if (0x1::table::contains<address, vector<u64>>(&v3.users, arg0)) {
        } else {
            0x1::table::add<address, vector<u64>>(&mut v3.users, arg0, 0x1::vector::empty<u64>());
        };
        let v4 = 0x1::table::borrow_mut<address, vector<u64>>(&mut v3.users, arg0);
        while (arg1 >= 0x1::vector::length<u64>(v4)) {
            0x1::vector::push_back<u64>(v4, 0);
        };
        let v5 = 0x1::vector::borrow_mut<u64>(v4, arg1);
        *v5 = *v5 + arg2;
    }
    
    public fun mint_mission_lootboxes_admin(arg0: &AdminCapability, arg1: address, arg2: u64, arg3: u64) acquires LootBoxInfo, UserLootBoxEvent {
        let v0 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number();
        let v1 = get_user_lootboxes(arg1, v0);
        mint_lootbox(arg1, arg2, arg3);
        let v2 = get_user_lootboxes(arg1, v0);
        emit_lootbox_events(arg1, v1, v2);
    }
    
    fun mint_shard_rand(arg0: address, arg1: u64) {
        let (v0, v1) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear_calc::calc_lootbox_shard_range(arg1);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::shard_token::mint(arg0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::random::get_random_between(v0, v1));
    }
    
    public(friend) fun mint_soft_reset_lootboxes(arg0: &signer, arg1: address, arg2: vector<u64>) acquires LootBoxInfo, UserLootBoxEvent {
        let v0 = 0;
        while (v0 < 5) {
            let v1 = 0x1::vector::borrow<u64>(&arg2, v0);
            if (*v1 > 0) {
                mint_lootbox(arg1, v0, *v1);
            };
            v0 = v0 + 1;
        };
        let v2 = LootBoxEvent{
            season  : 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number(), 
            user    : arg1, 
            lootbox : arg2,
        };
        0x1::event::emit_event<LootBoxEvent>(&mut borrow_global_mut<UserLootBoxEvent>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).lootbox_events, v2);
    }
    
    public fun open_ftu_lootbox(arg0: &signer, arg1: address) acquires FtuLootBoxInfo, UserFtuLootBoxEvents {
        let v0 = borrow_global_mut<FtuLootBoxInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::table::contains<address, u64>(&v0.user_ftu_lootbox, 0x1::signer::address_of(arg0))) {
            abort 5
        };
        let v1 = 0;
        if (arg1 != @0x0) {
            v1 = 1;
            if (0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::referral::check_affiliates_address(arg1)) {
                v1 = 2;
            };
        };
        if (v1 == 0) {
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::mint_basic(0x1::signer::address_of(arg0), 0, 0);
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::mint_basic(0x1::signer::address_of(arg0), 0, 2);
        } else {
            if (v1 == 1) {
                0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::mint_basic(0x1::signer::address_of(arg0), 0, 0);
                0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::mint_basic(0x1::signer::address_of(arg0), 0, 1);
                0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::mint_basic(0x1::signer::address_of(arg0), 0, 2);
            } else {
                if (v1 == 2) {
                    0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::mint_basic(0x1::signer::address_of(arg0), 1, 0);
                    0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::mint_basic(0x1::signer::address_of(arg0), 1, 1);
                    0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::mint_basic(0x1::signer::address_of(arg0), 2, 2);
                };
            };
        };
        0x1::table::upsert<address, u64>(&mut v0.user_ftu_lootbox, 0x1::signer::address_of(arg0), v1);
        let v2 = FtuLootBoxEvent{
            user        : 0x1::signer::address_of(arg0), 
            reward_tier : v1, 
            referrer    : arg1,
        };
        0x1::event::emit_event<FtuLootBoxEvent>(&mut borrow_global_mut<UserFtuLootBoxEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).ftu_lootbox_events, v2);
    }
    
    public(friend) fun open_lootbox_rand(arg0: &signer, arg1: u64, arg2: u64) acquires LootBoxInfo, UserLootBoxEvent {
        assert!(arg1 <= 4, 2);
        let v0 = 0x1::signer::address_of(arg0);
        let v1 = borrow_global_mut<LootBoxInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        assert!(0x1::table::contains<u64, UsersLootBox>(&v1.season_lootbox, arg2), 4);
        let v2 = 0x1::table::borrow_mut<u64, UsersLootBox>(&mut v1.season_lootbox, arg2);
        assert!(0x1::table::contains<address, vector<u64>>(&v2.users, v0), 3);
        let v3 = 0x1::vector::borrow_mut<u64>(0x1::table::borrow_mut<address, vector<u64>>(&mut v2.users, v0), arg1);
        assert!(*v3 > 0, 3);
        *v3 = *v3 - 1;
        mint_shard_rand(v0, arg1);
        mint_gear_rand(arg0, arg1, arg2);
        let v4 = LootBoxOpenEvent{
            season : arg2, 
            user   : 0x1::signer::address_of(arg0), 
            tier   : arg1,
        };
        0x1::event::emit_event<LootBoxOpenEvent>(&mut borrow_global_mut<UserLootBoxEvent>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).lootbox_open_events, v4);
    }
    
    // decompiled from Move bytecode v6
}


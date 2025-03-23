module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::lootbox {
    struct AdminCapability has copy, drop, store {
        dummy_field: bool,
    }
    
    struct LootBoxEvent has drop, store {
        user: address,
        lootbox: vector<u64>,
    }
    
    struct LootBoxOpenEvent has drop, store {
        user: address,
        tier: u64,
    }
    
    struct UserLootBoxEvent has key {
        loot_box_events: 0x1::event::EventHandle<LootBoxEvent>,
    }
    
    struct UsersLootBox has key {
        users: 0x1::table::Table<address, vector<u64>>,
    }
    
    struct LootBoxConfig has key {
        max_tier: u64,
    }
    
    struct UserLootBoxOpenEvent has key {
        loot_box_open_events: 0x1::event::EventHandle<LootBoxOpenEvent>,
    }
    
    public fun dummy() {
    }
    
    public(friend) fun emit_loot_box_events(arg0: address, arg1: vector<u64>, arg2: vector<u64>) acquires UserLootBoxEvent, LootBoxConfig {
        let v0 = 0x1::vector::empty<u64>();
        let v1 = 0;
        let v2 = 0;
        loop {
            if (v2 > borrow_global<LootBoxConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).max_tier) {
                break
            };
            let v3 = 0;
            if (v2 < 0x1::vector::length<u64>(&arg2)) {
                let v4 = 0;
                if (v2 < 0x1::vector::length<u64>(&arg1)) {
                    let v5 = 0x1::vector::borrow<u64>(&arg1, v2);
                    v4 = *v5;
                };
                let v6 = *0x1::vector::borrow<u64>(&arg2, v2) - v4;
                v3 = v6;
                v1 = v1 + v6;
            };
            0x1::vector::push_back<u64>(&mut v0, v3);
            v2 = v2 + 1;
        };
        if (v1 > 0) {
            let v7 = LootBoxEvent{
                user    : arg0, 
                lootbox : v0,
            };
            0x1::event::emit_event<LootBoxEvent>(&mut borrow_global_mut<UserLootBoxEvent>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).loot_box_events, v7);
        };
    }
    
    public fun generate_admin_cap(arg0: &signer) : AdminCapability {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        AdminCapability{dummy_field: false}
    }
    
    public fun get_max_tier() : u64 acquires LootBoxConfig {
        borrow_global_mut<LootBoxConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).max_tier
    }
    
    public fun get_user_loot_boxes(arg0: address) : vector<u64> acquires UsersLootBox, LootBoxConfig {
        let v0 = borrow_global_mut<UsersLootBox>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = 0x1::vector::empty<u64>();
        if (0x1::table::contains<address, vector<u64>>(&v0.users, arg0)) {
            v1 = *0x1::table::borrow<address, vector<u64>>(&mut v0.users, arg0);
        };
        let v2 = 0x1::vector::length<u64>(&v1);
        loop {
            if (v2 > borrow_global<LootBoxConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).max_tier) {
                break
            };
            0x1::vector::push_back<u64>(&mut v1, 0);
            v2 = v2 + 1;
        };
        v1
    }
    
    public fun increase_max_tier(arg0: &signer, arg1: u64) acquires LootBoxConfig {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v0 = borrow_global_mut<LootBoxConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        v0.max_tier = v0.max_tier + arg1;
    }
    
    fun init_module(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v0 = LootBoxConfig{max_tier: 4};
        move_to<LootBoxConfig>(arg0, v0);
        let v1 = UsersLootBox{users: 0x1::table::new<address, vector<u64>>()};
        move_to<UsersLootBox>(arg0, v1);
        let v2 = UserLootBoxEvent{loot_box_events: 0x1::account::new_event_handle<LootBoxEvent>(arg0)};
        move_to<UserLootBoxEvent>(arg0, v2);
    }
    
    public fun initialize_module(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v0 = UserLootBoxOpenEvent{loot_box_open_events: 0x1::account::new_event_handle<LootBoxOpenEvent>(arg0)};
        move_to<UserLootBoxOpenEvent>(arg0, v0);
    }
    
    fun mint_gear_rand(arg0: &signer, arg1: u64) {
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
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::mint_rand(arg0, v0);
            return
        };
    }
    
    public(friend) fun mint_lootbox(arg0: address, arg1: u64, arg2: u64) acquires UsersLootBox, LootBoxConfig {
        assert!(arg1 <= borrow_global<LootBoxConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).max_tier, 2);
        let v0 = borrow_global_mut<UsersLootBox>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::table::contains<address, vector<u64>>(&v0.users, arg0)) {
        } else {
            0x1::table::add<address, vector<u64>>(&mut v0.users, arg0, 0x1::vector::empty<u64>());
        };
        let v1 = 0x1::table::borrow_mut<address, vector<u64>>(&mut v0.users, arg0);
        loop {
            if (arg1 < 0x1::vector::length<u64>(v1)) {
                break
            };
            0x1::vector::push_back<u64>(v1, 0);
        };
        let v2 = 0x1::vector::borrow_mut<u64>(v1, arg1);
        *v2 = *v2 + arg2;
    }
    
    public fun mint_mission_lootboxes(arg0: &signer, arg1: address, arg2: u64, arg3: u64) acquires UserLootBoxEvent, UsersLootBox, LootBoxConfig {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v0 = get_user_loot_boxes(arg1);
        mint_lootbox(arg1, arg2, arg3);
        let v1 = get_user_loot_boxes(arg1);
        emit_loot_box_events(arg1, v0, v1);
    }
    
    public fun mint_mission_lootboxes_admin_cap(arg0: &AdminCapability, arg1: address, arg2: u64, arg3: u64) acquires UserLootBoxEvent, UsersLootBox, LootBoxConfig {
        let v0 = get_user_loot_boxes(arg1);
        mint_lootbox(arg1, arg2, arg3);
        let v1 = get_user_loot_boxes(arg1);
        emit_loot_box_events(arg1, v0, v1);
    }
    
    fun mint_pMKL_rand(arg0: address, arg1: u64) {
        let v0 = vector[10000000, 21000000, 48000000, 122000000, 320000000];
        let v1 = vector[20000000, 43000000, 100000000, 242000000, 640000000];
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pMKL::mint_pmkl(arg0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::random::get_random_between(*0x1::vector::borrow<u64>(&v0, arg1), *0x1::vector::borrow<u64>(&v1, arg1)));
    }
    
    fun mint_shard_rand(arg0: address, arg1: u64) {
        let (v0, v1) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear_calc::calc_lootbox_shard_range(arg1);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::shard_token::mint(arg0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::random::get_random_between(v0, v1));
    }
    
    public fun open_lootbox_admin_cap_rand(arg0: &AdminCapability, arg1: address, arg2: u64) acquires UsersLootBox, UserLootBoxOpenEvent {
        let v0 = borrow_global_mut<UsersLootBox>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        assert!(0x1::table::contains<address, vector<u64>>(&v0.users, arg1), 3);
        let v1 = 0x1::vector::borrow_mut<u64>(0x1::table::borrow_mut<address, vector<u64>>(&mut v0.users, arg1), arg2);
        assert!(*v1 > 0, 3);
        *v1 = *v1 - 1;
        mint_pMKL_rand(arg1, arg2);
        mint_shard_rand(arg1, arg2);
        let v2 = LootBoxOpenEvent{
            user : arg1, 
            tier : arg2,
        };
        0x1::event::emit_event<LootBoxOpenEvent>(&mut borrow_global_mut<UserLootBoxOpenEvent>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).loot_box_open_events, v2);
    }
    
    public(friend) fun open_lootbox_rand(arg0: &signer, arg1: u64) acquires UsersLootBox, LootBoxConfig, UserLootBoxOpenEvent {
        assert!(0x1::timestamp::now_seconds() <= 1706184000, 4);
        assert!(arg1 <= borrow_global<LootBoxConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).max_tier, 2);
        let v0 = 0x1::signer::address_of(arg0);
        let v1 = borrow_global_mut<UsersLootBox>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        assert!(0x1::table::contains<address, vector<u64>>(&v1.users, v0), 3);
        let v2 = 0x1::vector::borrow_mut<u64>(0x1::table::borrow_mut<address, vector<u64>>(&mut v1.users, v0), arg1);
        assert!(*v2 > 0, 3);
        *v2 = *v2 - 1;
        mint_pMKL_rand(v0, arg1);
        mint_shard_rand(v0, arg1);
        mint_gear_rand(arg0, arg1);
        let v3 = LootBoxOpenEvent{
            user : 0x1::signer::address_of(arg0), 
            tier : arg1,
        };
        0x1::event::emit_event<LootBoxOpenEvent>(&mut borrow_global_mut<UserLootBoxOpenEvent>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).loot_box_open_events, v3);
    }
    
    // decompiled from Move bytecode v6
}


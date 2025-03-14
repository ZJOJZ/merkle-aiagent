module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_lootbox {
    struct AdminCapabilityCandidate has copy, drop, key {
        admin_cap_candidate: vector<address>,
        admin_caps: vector<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::lootbox::AdminCapability>,
    }
    
    struct AdminCapabilityStore has drop, key {
        admin_cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::lootbox::AdminCapability,
    }
    
    public fun get_user_loot_boxes(arg0: address) : vector<u64> {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::lootbox::get_user_loot_boxes(arg0)
    }
    
    public entry fun increase_max_tier(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::lootbox::increase_max_tier(arg0, arg1);
    }
    
    public entry fun initialize_module(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::lootbox::initialize_module(arg0);
    }
    
    public entry fun mint_mission_lootboxes(arg0: &signer, arg1: address, arg2: u64, arg3: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::lootbox::mint_mission_lootboxes(arg0, arg1, arg2, arg3);
    }
    
    public entry fun mint_mission_lootboxes_admin_cap(arg0: &signer, arg1: address, arg2: u64, arg3: u64) acquires AdminCapabilityStore {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::lootbox::mint_mission_lootboxes_admin_cap(&borrow_global<AdminCapabilityStore>(0x1::signer::address_of(arg0)).admin_cap, arg1, arg2, arg3);
    }
    
    public entry fun burn_admin_cap(arg0: &signer, arg1: address) acquires AdminCapabilityStore {
        let v0 = if (arg1 != @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d) {
            if (arg1 == 0x1::signer::address_of(arg0)) {
                true
            } else {
                0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d
            }
        } else {
            false
        };
        assert!(v0, 1);
        move_from<AdminCapabilityStore>(arg1);
    }
    
    public entry fun claim_admin_cap(arg0: &signer) acquires AdminCapabilityCandidate {
        let v0 = borrow_global_mut<AdminCapabilityCandidate>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = 0x1::signer::address_of(arg0);
        let (v2, v3) = 0x1::vector::index_of<address>(&v0.admin_cap_candidate, &v1);
        if (v2) {
            0x1::vector::remove<address>(&mut v0.admin_cap_candidate, v3);
            if (exists<AdminCapabilityStore>(0x1::signer::address_of(arg0))) {
            } else {
                let v4 = AdminCapabilityStore{admin_cap: 0x1::vector::pop_back<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::lootbox::AdminCapability>(&mut v0.admin_caps)};
                move_to<AdminCapabilityStore>(arg0, v4);
            };
        };
    }
    
    entry fun open_lootbox(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::lootbox::open_lootbox_rand(arg0, arg1);
    }
    
    public entry fun open_lootbox_admin_cap(arg0: &signer, arg1: address, arg2: u64) acquires AdminCapabilityStore {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::lootbox::open_lootbox_admin_cap_rand(&borrow_global<AdminCapabilityStore>(0x1::signer::address_of(arg0)).admin_cap, arg1, arg2);
    }
    
    public entry fun set_address_admin_candidate(arg0: &signer, arg1: address) acquires AdminCapabilityCandidate {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        if (exists<AdminCapabilityStore>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = AdminCapabilityStore{admin_cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::lootbox::generate_admin_cap(arg0)};
            move_to<AdminCapabilityStore>(arg0, v0);
        };
        if (exists<AdminCapabilityCandidate>(0x1::signer::address_of(arg0))) {
        } else {
            let v1 = AdminCapabilityCandidate{
                admin_cap_candidate : 0x1::vector::empty<address>(), 
                admin_caps          : 0x1::vector::empty<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::lootbox::AdminCapability>(),
            };
            move_to<AdminCapabilityCandidate>(arg0, v1);
        };
        let v2 = borrow_global_mut<AdminCapabilityCandidate>(0x1::signer::address_of(arg0));
        0x1::vector::push_back<address>(&mut v2.admin_cap_candidate, arg1);
        0x1::vector::push_back<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::lootbox::AdminCapability>(&mut v2.admin_caps, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::lootbox::generate_admin_cap(arg0));
    }
    
    // decompiled from Move bytecode v6
}


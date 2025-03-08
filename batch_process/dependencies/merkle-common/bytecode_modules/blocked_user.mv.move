module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::blocked_user {
    struct BlockedUsers has drop, key {
        users: vector<address>,
    }
    
    struct BlockedUsersV2 has key {
        users: 0x1::table::Table<address, bool>,
    }
    
    public fun check_blocked(arg0: address) : bool acquires BlockedUsers, BlockedUsersV2 {
        let v0 = false;
        let v1 = v0;
        if (exists<BlockedUsersV2>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)) {
            let v2 = v0 || 0x1::table::contains<address, bool>(&borrow_global<BlockedUsersV2>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).users, arg0);
            v1 = v2;
        };
        if (exists<BlockedUsers>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)) {
            let v3 = v1 || 0x1::vector::contains<address>(&borrow_global<BlockedUsers>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).users, &arg0);
            v1 = v3;
        };
        v1
    }
    
    public fun is_blocked(arg0: address) acquires BlockedUsers, BlockedUsersV2 {
        if (check_blocked(arg0)) {
            abort 2
        };
    }
    
    public entry fun register_blocked_user(arg0: &signer, arg1: address) acquires BlockedUsers, BlockedUsersV2 {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        if (exists<BlockedUsersV2>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = BlockedUsersV2{users: 0x1::table::new<address, bool>()};
            move_to<BlockedUsersV2>(arg0, v0);
            if (exists<BlockedUsers>(0x1::signer::address_of(arg0))) {
                let v1 = borrow_global<BlockedUsers>(0x1::signer::address_of(arg0)).users;
                0x1::vector::reverse<address>(&mut v1);
                let v2 = v1;
                let v3 = 0x1::vector::length<address>(&v2);
                while (v3 > 0) {
                    0x1::table::add<address, bool>(&mut borrow_global_mut<BlockedUsersV2>(0x1::signer::address_of(arg0)).users, 0x1::vector::pop_back<address>(&mut v2), true);
                    v3 = v3 - 1;
                };
                0x1::vector::destroy_empty<address>(v2);
                move_from<BlockedUsers>(0x1::signer::address_of(arg0));
            };
        };
        0x1::table::upsert<address, bool>(&mut borrow_global_mut<BlockedUsersV2>(0x1::signer::address_of(arg0)).users, arg1, true);
    }
    
    public entry fun remove_blocked_user(arg0: &signer, arg1: address) acquires BlockedUsersV2 {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v0 = borrow_global_mut<BlockedUsersV2>(0x1::signer::address_of(arg0));
        if (0x1::table::contains<address, bool>(&v0.users, arg1)) {
            0x1::table::remove<address, bool>(&mut v0.users, arg1);
        };
    }
    
    // decompiled from Move bytecode v6
}


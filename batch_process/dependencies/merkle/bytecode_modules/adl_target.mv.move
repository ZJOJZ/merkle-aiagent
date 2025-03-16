module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::adl_target {
    struct AdlTargetCapability has drop {
        dummy_field: bool,
    }
    
    struct TargetInfo has key {
        targets: 0x1::table::Table<0x1::string::String, 0x1::table::Table<address, u64>>,
    }
    
    public(friend) fun add_target<T0>(arg0: address, arg1: bool) acquires TargetInfo {
        let v0 = borrow_global_mut<TargetInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = 0x1::type_info::type_name<T0>();
        if (0x1::table::contains<0x1::string::String, 0x1::table::Table<address, u64>>(&v0.targets, v1)) {
        } else {
            0x1::table::add<0x1::string::String, 0x1::table::Table<address, u64>>(&mut v0.targets, v1, 0x1::table::new<address, u64>());
        };
        let v2 = 0x1::table::borrow_mut_with_default<address, u64>(0x1::table::borrow_mut<0x1::string::String, 0x1::table::Table<address, u64>>(&mut v0.targets, v1), arg0, 0);
        let v3 = if (arg1) {
            1
        } else {
            2
        };
        *v2 = *v2 | v3;
    }
    
    public entry fun initialize_module(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v0 = TargetInfo{targets: 0x1::table::new<0x1::string::String, 0x1::table::Table<address, u64>>()};
        move_to<TargetInfo>(arg0, v0);
    }
    
    public fun is_target<T0>(arg0: address, arg1: bool) : bool acquires TargetInfo {
        if (exists<TargetInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)) {
            let v0 = borrow_global<TargetInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
            let v1 = 0x1::type_info::type_name<T0>();
            if (0x1::table::contains<0x1::string::String, 0x1::table::Table<address, u64>>(&v0.targets, v1)) {
                let v2 = 0x1::table::borrow<0x1::string::String, 0x1::table::Table<address, u64>>(&v0.targets, v1);
                if (0x1::table::contains<address, u64>(v2, arg0)) {
                    let v3 = if (arg1) {
                        1
                    } else {
                        2
                    };
                    return *0x1::table::borrow<address, u64>(v2, arg0) & v3 > 0
                };
                return false
            };
            return false
        };
        false
    }
    
    public(friend) fun remove_target<T0>(arg0: address, arg1: bool) acquires TargetInfo {
        if (is_target<T0>(arg0, arg1)) {
            if (exists<TargetInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)) {
                let v0 = borrow_global_mut<TargetInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
                let v1 = 0x1::type_info::type_name<T0>();
                if (0x1::table::contains<0x1::string::String, 0x1::table::Table<address, u64>>(&v0.targets, v1)) {
                    let v2 = 0x1::table::borrow_mut<address, u64>(0x1::table::borrow_mut<0x1::string::String, 0x1::table::Table<address, u64>>(&mut v0.targets, v1), arg0);
                    let v3 = if (arg1) {
                        1
                    } else {
                        2
                    };
                    *v2 = *v2 ^ v3;
                    return
                };
                return
            };
            return
        };
    }
    
    // decompiled from Move bytecode v6
}


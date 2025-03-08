module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear_factory {
    struct GearAffixSpec has store {
        gear_affix_type: u64,
        gear_affix_code: u64,
        min_affix_effect: u64,
        max_affix_effect: u64,
    }
    
    struct GearInfo has key {
        gear_datas: 0x1::simple_map::SimpleMap<u64, vector<GearSpec>>,
    }
    
    struct GearSpec has store {
        tier: u64,
        name: 0x1::string::String,
        uri: 0x1::string::String,
        gear_type: u64,
        gear_code: u64,
        min_primary_effect: u64,
        max_primary_effect: u64,
        gear_affixes: vector<GearAffixSpec>,
    }
    
    public fun generate_gear_affix_rand(arg0: u64, arg1: u64, arg2: u64, arg3: vector<0x1::string::String>) : (vector<u64>, vector<u64>, vector<0x1::string::String>, vector<u64>) acquires GearInfo {
        let v0 = 0x1::simple_map::borrow<u64, vector<GearSpec>>(&mut borrow_global_mut<GearInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).gear_datas, &arg0);
        let v1 = 0;
        while (v1 < 0x1::vector::length<GearSpec>(v0)) {
            let v2 = 0x1::vector::borrow<GearSpec>(v0, v1);
            if (v2.gear_type == arg1 && v2.gear_code == arg2) {
                return generate_gear_affixes_internal_rand(v2, arg3)
            };
            v1 = v1 + 1;
        };
        abort 3
    }
    
    fun generate_gear_affixes_internal_rand(arg0: &GearSpec, arg1: vector<0x1::string::String>) : (vector<u64>, vector<u64>, vector<0x1::string::String>, vector<u64>) {
        let v0 = 0;
        let v1 = 0x1::vector::empty<u64>();
        let v2 = 0x1::vector::empty<u64>();
        let v3 = 0x1::vector::empty<0x1::string::String>();
        let v4 = 0x1::vector::empty<u64>();
        let v5 = 0;
        while (v0 < 0x1::vector::length<GearAffixSpec>(&arg0.gear_affixes)) {
            let v6 = 0x1::vector::borrow<GearAffixSpec>(&arg0.gear_affixes, v0);
            let v7 = b"";
            if (v6.gear_affix_code == 1) {
                v7 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pair_types::get_pair_name(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::random::get_random_between(0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pair_types::len_pair() - 1));
            } else {
                if (v6.gear_affix_code == 2) {
                    v7 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pair_types::get_class_name(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::random::get_random_between(0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pair_types::len_pair_class() - 1));
                };
            };
            let v8 = v5 + 1;
            v5 = v8;
            let v9 = 0x1::string::utf8(v7);
            let v10 = if (0x1::vector::contains<0x1::string::String>(&v3, &v9)) {
                true
            } else {
                let v11 = 0x1::string::utf8(v7);
                0x1::vector::contains<0x1::string::String>(&arg1, &v11)
            };
            if (v10) {
                assert!(v8 < 10, 3);
                continue
            };
            0x1::vector::push_back<u64>(&mut v1, v6.gear_affix_type);
            0x1::vector::push_back<u64>(&mut v2, v6.gear_affix_code);
            0x1::vector::push_back<0x1::string::String>(&mut v3, 0x1::string::utf8(v7));
            0x1::vector::push_back<u64>(&mut v4, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::random::get_random_between(v6.min_affix_effect, v6.max_affix_effect));
            v0 = v0 + 1;
        };
        (v1, v2, v3, v4)
    }
    
    public fun generate_gear_property_rand(arg0: u64) : (0x1::string::String, 0x1::string::String, u64, u64, u64, vector<u64>, vector<u64>, vector<0x1::string::String>, vector<u64>) acquires GearInfo {
        let v0 = 0x1::simple_map::borrow<u64, vector<GearSpec>>(&mut borrow_global_mut<GearInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).gear_datas, &arg0);
        let v1 = 0x1::vector::borrow<GearSpec>(v0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::random::get_random_between(0, 0x1::vector::length<GearSpec>(v0) - 1));
        let (v2, v3, v4, v5) = generate_gear_affixes_internal_rand(v1, 0x1::vector::empty<0x1::string::String>());
        (v1.name, v1.uri, v1.gear_type, v1.gear_code, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::random::get_random_between(v1.min_primary_effect, v1.max_primary_effect), v2, v3, v4, v5)
    }
    
    public fun generate_specific_gear_property_without_affixes_rand(arg0: u64, arg1: u64, arg2: u64) : (0x1::string::String, 0x1::string::String, u64, u64, u64, vector<u64>, vector<u64>, vector<0x1::string::String>, vector<u64>) acquires GearInfo {
        let v0 = 0x1::simple_map::borrow<u64, vector<GearSpec>>(&mut borrow_global_mut<GearInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).gear_datas, &arg0);
        let v1 = 0;
        while (v1 < 0x1::vector::length<GearSpec>(v0)) {
            let v2 = 0x1::vector::borrow<GearSpec>(v0, v1);
            if (v2.gear_type == arg1 && v2.gear_code == arg2) {
                break
            };
            v1 = v1 + 1;
        };
        assert!(v1 < 0x1::vector::length<GearSpec>(v0), 3);
        let v3 = 0x1::vector::borrow<GearSpec>(v0, v1);
        (v3.name, v3.uri, v3.gear_type, v3.gear_code, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::random::get_random_between(v3.min_primary_effect, v3.max_primary_effect), 0x1::vector::empty<u64>(), 0x1::vector::empty<u64>(), 0x1::vector::empty<0x1::string::String>(), 0x1::vector::empty<u64>())
    }
    
    public fun get_basic_gear_property(arg0: u64, arg1: u64) : (0x1::string::String, 0x1::string::String, u64, u64, u64, vector<u64>, vector<u64>, vector<0x1::string::String>, vector<u64>) acquires GearInfo {
        let v0 = 0x1::vector::borrow<GearSpec>(0x1::simple_map::borrow<u64, vector<GearSpec>>(&mut borrow_global_mut<GearInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).gear_datas, &arg0), arg1);
        let v1 = v0.min_primary_effect;
        if (v0.tier == 0 && arg1 == 2) {
            v1 = v0.max_primary_effect;
        };
        (v0.name, v0.uri, v0.gear_type, v0.gear_code, v1, 0x1::vector::empty<u64>(), 0x1::vector::empty<u64>(), 0x1::vector::empty<0x1::string::String>(), 0x1::vector::empty<u64>())
    }
    
    public fun initialize_module(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        if (exists<GearInfo>(0x1::signer::address_of(arg0))) {
            return
        };
        let v0 = GearInfo{gear_datas: 0x1::simple_map::create<u64, vector<GearSpec>>()};
        move_to<GearInfo>(arg0, v0);
    }
    
    public fun register_affix(arg0: &signer, arg1: u64, arg2: u64, arg3: u64, arg4: u64, arg5: u64, arg6: u64, arg7: u64) acquires GearInfo {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v0 = 0x1::simple_map::borrow_mut<u64, vector<GearSpec>>(&mut borrow_global_mut<GearInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).gear_datas, &arg1);
        let v1 = 0;
        while (v1 < 0x1::vector::length<GearSpec>(v0)) {
            let v2 = 0x1::vector::borrow_mut<GearSpec>(v0, v1);
            if (v2.gear_type == arg2 && v2.gear_code == arg3) {
                break
            };
            v1 = v1 + 1;
        };
        assert!(v1 < 0x1::vector::length<GearSpec>(v0), 2);
        let v3 = GearAffixSpec{
            gear_affix_type  : arg4, 
            gear_affix_code  : arg5, 
            min_affix_effect : arg6, 
            max_affix_effect : arg7,
        };
        0x1::vector::push_back<GearAffixSpec>(&mut 0x1::vector::borrow_mut<GearSpec>(v0, v1).gear_affixes, v3);
    }
    
    public fun register_gear(arg0: &signer, arg1: u64, arg2: vector<u8>, arg3: vector<u8>, arg4: u64, arg5: u64, arg6: u64, arg7: u64) acquires GearInfo {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v0 = borrow_global_mut<GearInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::simple_map::contains_key<u64, vector<GearSpec>>(&v0.gear_datas, &arg1)) {
        } else {
            0x1::simple_map::add<u64, vector<GearSpec>>(&mut v0.gear_datas, arg1, 0x1::vector::empty<GearSpec>());
        };
        let v1 = 0x1::simple_map::borrow_mut<u64, vector<GearSpec>>(&mut v0.gear_datas, &arg1);
        let v2 = false;
        let v3 = 0;
        while (v3 < 0x1::vector::length<GearSpec>(v1)) {
            let v4 = 0x1::vector::borrow<GearSpec>(v1, v3);
            if (v4.gear_type == arg4 && v4.gear_code == arg5) {
                v2 = true;
                break
            };
            v3 = v3 + 1;
        };
        if (v2) {
            abort 4
        };
        let v5 = GearSpec{
            tier               : arg1, 
            name               : 0x1::string::utf8(arg2), 
            uri                : 0x1::string::utf8(arg3), 
            gear_type          : arg4, 
            gear_code          : arg5, 
            min_primary_effect : arg6, 
            max_primary_effect : arg7, 
            gear_affixes       : 0x1::vector::empty<GearAffixSpec>(),
        };
        0x1::vector::push_back<GearSpec>(v1, v5);
    }
    
    // decompiled from Move bytecode v6
}


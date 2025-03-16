module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_gear {
    struct AdminCapabilityCandidate has key {
        candidates: vector<address>,
        admin_capabilities: vector<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::AdminCapability>,
    }
    
    struct AdminCapabilityStore has key {
        admin_cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::AdminCapability,
    }
    
    public fun get_equipped_gears(arg0: address) : vector<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::EquippedGearView> {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::get_equipped_gears(arg0)
    }
    
    public fun get_gear_detail(arg0: address) : 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::GearDetail {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::get_gear_detail(arg0)
    }
    
    public fun get_repair_shards(arg0: address, arg1: u64) : u64 {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::get_repair_shards(arg0, arg1)
    }
    
    public fun get_salvage_shard_range(arg0: address) : (u64, u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::get_salvage_shard_range(arg0)
    }
    
    public entry fun initialize_module(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::initialize_module(arg0);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear_factory::initialize_module(arg0);
    }
    
    public entry fun initialize_module_v2(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::initialize_module_v2(arg0);
        if (exists<AdminCapabilityCandidate>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = AdminCapabilityCandidate{
                candidates         : 0x1::vector::empty<address>(), 
                admin_capabilities : 0x1::vector::empty<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::AdminCapability>(),
            };
            move_to<AdminCapabilityCandidate>(arg0, v0);
        };
    }
    
    public entry fun repair(arg0: &signer, arg1: address, arg2: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::repair(arg0, arg1, arg2);
    }
    
    public entry fun register_affix(arg0: &signer, arg1: u64, arg2: u64, arg3: u64, arg4: u64, arg5: u64, arg6: u64, arg7: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear_factory::register_affix(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
    }
    
    public entry fun register_gear(arg0: &signer, arg1: u64, arg2: vector<u8>, arg3: vector<u8>, arg4: u64, arg5: u64, arg6: u64, arg7: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear_factory::register_gear(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
    }
    
    public entry fun claim_admin_capability(arg0: &signer) acquires AdminCapabilityCandidate {
        let v0 = 0x1::signer::address_of(arg0);
        let v1 = borrow_global_mut<AdminCapabilityCandidate>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let (v2, v3) = 0x1::vector::index_of<address>(&v1.candidates, &v0);
        assert!(v2, 1);
        0x1::vector::remove<address>(&mut v1.candidates, v3);
        let v4 = AdminCapabilityStore{admin_cap: 0x1::vector::pop_back<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::AdminCapability>(&mut v1.admin_capabilities)};
        move_to<AdminCapabilityStore>(arg0, v4);
    }
    
    entry fun forge(arg0: &signer, arg1: address, arg2: address) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::forge_rand(arg0, arg1, arg2);
    }
    
    public entry fun gear_equip(arg0: &signer, arg1: address) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::equip(arg0, arg1);
    }
    
    public entry fun gear_unequip(arg0: &signer, arg1: address) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::unequip(arg0, arg1);
    }
    
    entry fun mint_event_with_admin_cap_rand(arg0: &signer, arg1: address, arg2: u64, arg3: u64, arg4: u64) acquires AdminCapabilityStore {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::mint_event_rand(&borrow_global<AdminCapabilityStore>(0x1::signer::address_of(arg0)).admin_cap, arg1, arg2, arg3, arg4);
    }
    
    public entry fun register_admin_capabilty_candidate(arg0: &signer, arg1: address) acquires AdminCapabilityCandidate {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v0 = borrow_global_mut<AdminCapabilityCandidate>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        0x1::vector::push_back<address>(&mut v0.candidates, arg1);
        0x1::vector::push_back<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::AdminCapability>(&mut v0.admin_capabilities, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::generate_admin_cap(arg0));
    }
    
    entry fun salvage(arg0: &signer, arg1: address) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::salvage_rand(arg0, arg1);
    }
    
    // decompiled from Move bytecode v6
}


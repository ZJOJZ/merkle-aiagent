module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::external_capability_store {
    struct CapabilityStore<T0: copy + drop + store> has copy, drop, key {
        cap: T0,
    }
    
    public(friend) fun capability_exists<T0: copy + drop + store>() : bool {
        exists<CapabilityStore<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)
    }
    
    public entry fun claim_capability<T0: copy + drop + store>(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        assert!(0x1::type_info::type_of<T0>() == 0x1::type_info::type_of<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::point::PointCapability>(), 1);
        let v0 = CapabilityStore<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::point::PointCapability>{cap: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::point::claim_point_capability_candidate(arg0)};
        move_to<CapabilityStore<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::point::PointCapability>>(arg0, v0);
    }
    
    public entry fun drop_capability<T0: copy + drop + store>(arg0: &signer) acquires CapabilityStore {
        move_from<CapabilityStore<T0>>(0x1::signer::address_of(arg0));
    }
    
    public(friend) fun get_capability<T0: copy + drop + store>() : T0 acquires CapabilityStore {
        borrow_global<CapabilityStore<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).cap
    }
    
    // decompiled from Move bytecode v6
}


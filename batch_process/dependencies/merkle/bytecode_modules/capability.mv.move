module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::capability {
    struct CapabilityProviderCandidate has key {
        candidates: vector<address>,
        trading_capability_providers: vector<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading::CapabilityProvider>,
        price_oracle_capability_providers: vector<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::CapabilityProvider>,
    }
    
    struct CapabilityProviderStore has key {
        trading_capability_provider: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading::CapabilityProvider,
        price_oracle_capability_provider: 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::CapabilityProvider,
    }
    
    public fun claim_admin_cap_v2(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_trading::claim_admin_cap_v2(arg0);
    }
    
    public fun claim_executor_cap_v3(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_trading::claim_executor_cap_v3(arg0);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::claim_allowed_update(arg0);
    }
    
    public fun set_address_admin_candidate_v2(arg0: &signer, arg1: address) acquires CapabilityProviderStore {
        assert!(exists<CapabilityProviderStore>(0x1::signer::address_of(arg0)), 1);
        if (0x1::account::exists_at(arg1)) {
        } else {
            0x1::aptos_account::create_account(arg1);
        };
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_trading::set_address_admin_candidate_v2(arg0, arg1, &borrow_global<CapabilityProviderStore>(0x1::signer::address_of(arg0)).trading_capability_provider);
    }
    
    public fun claim_capability_provider(arg0: &signer) acquires CapabilityProviderCandidate {
        let v0 = 0x1::signer::address_of(arg0);
        if (exists<CapabilityProviderStore>(v0)) {
            return
        };
        let v1 = borrow_global_mut<CapabilityProviderCandidate>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let (v2, v3) = 0x1::vector::index_of<address>(&v1.candidates, &v0);
        assert!(v2, 1);
        0x1::vector::remove<address>(&mut v1.candidates, v3);
        let v4 = CapabilityProviderStore{
            trading_capability_provider      : 0x1::vector::pop_back<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading::CapabilityProvider>(&mut v1.trading_capability_providers), 
            price_oracle_capability_provider : 0x1::vector::pop_back<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::CapabilityProvider>(&mut v1.price_oracle_capability_providers),
        };
        move_to<CapabilityProviderStore>(arg0, v4);
    }
    
    public fun claim_executor_cap<T0>(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_trading::claim_executor_cap_v2<T0>(arg0);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::claim_allowed_update(arg0);
    }
    
    public fun initialize_module(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        if (exists<CapabilityProviderCandidate>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = CapabilityProviderCandidate{
                candidates                        : 0x1::vector::empty<address>(), 
                trading_capability_providers      : 0x1::vector::empty<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading::CapabilityProvider>(), 
                price_oracle_capability_providers : 0x1::vector::empty<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::CapabilityProvider>(),
            };
            move_to<CapabilityProviderCandidate>(arg0, v0);
        };
    }
    
    public fun register_capability_provider_candidate(arg0: &signer, arg1: address) acquires CapabilityProviderCandidate {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v0 = borrow_global_mut<CapabilityProviderCandidate>(0x1::signer::address_of(arg0));
        if (exists<CapabilityProviderStore>(arg1)) {
            return
        };
        if (0x1::vector::contains<address>(&v0.candidates, &arg1)) {
        } else {
            0x1::vector::push_back<address>(&mut v0.candidates, arg1);
            0x1::vector::push_back<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading::CapabilityProvider>(&mut v0.trading_capability_providers, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading::generate_capability_provider(arg0));
            0x1::vector::push_back<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::CapabilityProvider>(&mut v0.price_oracle_capability_providers, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::generate_capability_provider(arg0));
        };
    }
    
    public fun set_addresses_executor_candidate<T0>(arg0: &signer, arg1: vector<address>) {
        abort 0
    }
    
    public fun set_addresses_executor_candidate_v3(arg0: &signer, arg1: vector<address>) acquires CapabilityProviderStore {
        assert!(exists<CapabilityProviderStore>(0x1::signer::address_of(arg0)), 1);
        let v0 = borrow_global<CapabilityProviderStore>(0x1::signer::address_of(arg0));
        let v1 = arg1;
        0x1::vector::reverse<address>(&mut v1);
        let v2 = v1;
        let v3 = 0x1::vector::length<address>(&v2);
        while (v3 > 0) {
            let v4 = 0x1::vector::pop_back<address>(&mut v2);
            if (0x1::account::exists_at(v4)) {
            } else {
                0x1::aptos_account::create_account(v4);
            };
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_trading::set_address_executor_candidate_v3(arg0, v4, &v0.trading_capability_provider);
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::register_allowed_update_v2(arg0, v4, &v0.price_oracle_capability_provider);
            v3 = v3 - 1;
        };
        0x1::vector::destroy_empty<address>(v2);
    }
    
    // decompiled from Move bytecode v6
}


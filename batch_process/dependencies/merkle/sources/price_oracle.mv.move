module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle {
    struct AptVault has key {
        coin_store: 0x1::coin::Coin<0x1::aptos_coin::AptosCoin>,
    }
    
    struct CapabilityProvider has copy, drop, store {
        dummy_field: bool,
    }
    
    struct DataRecord<phantom T0> has drop, key {
        value: u64,
        updated_at: u64,
        pyth_vaa: vector<u8>,
    }
    
    struct PriceOracleConfig<phantom T0> has drop, key {
        max_price_update_delay: u64,
        spread_basis_points_if_update_delay: u64,
        max_deviation_basis_points: u64,
        switchboard_oracle_address: address,
        is_spread_enabled: bool,
        update_pyth_enabled: bool,
        pyth_price_identifier: vector<u8>,
        allowed_update: vector<address>,
    }
    
    struct UpdateCapability has drop, key {
        dummy_field: bool,
    }
    
    struct UpdateCapabilityCandidate has drop, key {
        candidates: vector<address>,
    }
    
    public fun update<T0>(arg0: &signer, arg1: u64, arg2: vector<u8>) acquires AptVault, DataRecord, PriceOracleConfig {
        let v0 = 0x1::signer::address_of(arg0);
        let v1 = borrow_global_mut<PriceOracleConfig<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        assert!(v0 == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d || exists<UpdateCapability>(v0) || 0x1::vector::contains<address>(&v1.allowed_update, &v0), 0);
        if (v1.update_pyth_enabled) {
            if (exists<AptVault>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)) {
                let v2 = borrow_global_mut<AptVault>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
                if (0x1::coin::value<0x1::aptos_coin::AptosCoin>(&v2.coin_store) > 0) {
                    0x1::coin::deposit<0x1::aptos_coin::AptosCoin>(v0, 0x1::coin::extract<0x1::aptos_coin::AptosCoin>(&mut v2.coin_store, 1));
                };
            };
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pyth_scripts::update_pyth(arg0, arg2);
        };
        let v3 = borrow_global_mut<DataRecord<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        v3.value = arg1;
        v3.updated_at = 0x1::timestamp::now_seconds();
        v3.pyth_vaa = arg2;
    }
    
    public fun get_price_for_random() : u64 acquires PriceOracleConfig {
        if (exists<PriceOracleConfig<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pair_types::ETH_USD>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)) {
            let v0 = borrow_global<PriceOracleConfig<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pair_types::ETH_USD>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
            if (0x1::vector::is_empty<u8>(&v0.pyth_price_identifier)) {
                abort 2
            };
            return 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pyth_scripts::get_price_for_random(v0.pyth_price_identifier)
        };
        0
    }
    
    public fun claim_allowed_update(arg0: &signer) acquires UpdateCapabilityCandidate {
        let v0 = 0x1::signer::address_of(arg0);
        let v1 = borrow_global_mut<UpdateCapabilityCandidate>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let (v2, v3) = 0x1::vector::index_of<address>(&v1.candidates, &v0);
        assert!(v2, 0);
        0x1::vector::remove<address>(&mut v1.candidates, v3);
        if (exists<UpdateCapability>(v0)) {
            return
        };
        let v4 = UpdateCapability{dummy_field: false};
        move_to<UpdateCapability>(arg0, v4);
    }
    
    public fun deposit_apt(arg0: &signer, arg1: u64) acquires AptVault {
        0x1::coin::merge<0x1::aptos_coin::AptosCoin>(&mut borrow_global_mut<AptVault>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).coin_store, 0x1::coin::withdraw<0x1::aptos_coin::AptosCoin>(arg0, arg1));
    }
    
    public fun generate_capability_provider(arg0: &signer) : CapabilityProvider {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        CapabilityProvider{dummy_field: false}
    }
    
    public fun initialize_module(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        if (exists<UpdateCapabilityCandidate>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = UpdateCapabilityCandidate{candidates: 0x1::vector::empty<address>()};
            move_to<UpdateCapabilityCandidate>(arg0, v0);
        };
        if (exists<AptVault>(0x1::signer::address_of(arg0))) {
        } else {
            let v1 = AptVault{coin_store: 0x1::coin::zero<0x1::aptos_coin::AptosCoin>()};
            move_to<AptVault>(arg0, v1);
        };
    }
    
    public fun read<T0>(arg0: bool) : u64 acquires DataRecord, PriceOracleConfig {
        let v0 = borrow_global<DataRecord<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).value;
        let v1 = borrow_global_mut<PriceOracleConfig<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (v1.update_pyth_enabled) {
            let (v2, v3, _) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pyth_scripts::get_price_from_vaa_no_older_than(v1.pyth_price_identifier, 10);
            v0 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v2, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::exp(10, 10), 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::exp(10, v3));
        };
        if (v1.is_spread_enabled && v1.spread_basis_points_if_update_delay > 0) {
            if (arg0) {
                let v5 = v0 * (1000000 + v1.spread_basis_points_if_update_delay);
                v0 = v5 / 1000000;
            } else {
                let v6 = v0 * (1000000 - v1.spread_basis_points_if_update_delay);
                v0 = v6 / 1000000;
            };
        };
        if (v0 == 0) {
            abort 1
        };
        v0
    }
    
    public fun register_allowed_update<T0>(arg0: &signer, arg1: address) acquires PriceOracleConfig {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        let v0 = borrow_global_mut<PriceOracleConfig<T0>>(0x1::signer::address_of(arg0));
        if (0x1::vector::contains<address>(&v0.allowed_update, &arg1)) {
        } else {
            0x1::vector::push_back<address>(&mut v0.allowed_update, arg1);
        };
    }
    
    public fun register_allowed_update_v2(arg0: &signer, arg1: address, arg2: &CapabilityProvider) acquires UpdateCapabilityCandidate {
        let v0 = borrow_global_mut<UpdateCapabilityCandidate>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::vector::contains<address>(&v0.candidates, &arg1)) {
        } else {
            0x1::vector::push_back<address>(&mut v0.candidates, arg1);
        };
    }
    
    public fun register_oracle<T0>(arg0: &signer) {
        let v0 = 0x1::signer::address_of(arg0);
        assert!(v0 == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        if (exists<PriceOracleConfig<T0>>(v0)) {
        } else {
            let v1 = PriceOracleConfig<T0>{
                max_price_update_delay              : 3600, 
                spread_basis_points_if_update_delay : 0, 
                max_deviation_basis_points          : 150, 
                switchboard_oracle_address          : @0x0, 
                is_spread_enabled                   : true, 
                update_pyth_enabled                 : false, 
                pyth_price_identifier               : 0x1::vector::empty<u8>(), 
                allowed_update                      : 0x1::vector::empty<address>(),
            };
            move_to<PriceOracleConfig<T0>>(arg0, v1);
        };
        if (exists<DataRecord<T0>>(v0)) {
        } else {
            let v2 = DataRecord<T0>{
                value      : 0, 
                updated_at : 0, 
                pyth_vaa   : 0x1::vector::empty<u8>(),
            };
            move_to<DataRecord<T0>>(arg0, v2);
        };
    }
    
    public fun remove_allowed_update<T0>(arg0: &signer, arg1: address) acquires PriceOracleConfig {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        let v0 = borrow_global_mut<PriceOracleConfig<T0>>(0x1::signer::address_of(arg0));
        let (v1, v2) = 0x1::vector::index_of<address>(&v0.allowed_update, &arg1);
        if (v1) {
            0x1::vector::remove<address>(&mut v0.allowed_update, v2);
        };
    }
    
    public fun set_is_spread_enabled<T0>(arg0: &signer, arg1: bool) acquires PriceOracleConfig {
        borrow_global_mut<PriceOracleConfig<T0>>(0x1::signer::address_of(arg0)).is_spread_enabled = arg1;
    }
    
    public fun set_max_deviation_basis_points<T0>(arg0: &signer, arg1: u64) acquires PriceOracleConfig {
        borrow_global_mut<PriceOracleConfig<T0>>(0x1::signer::address_of(arg0)).max_deviation_basis_points = arg1;
    }
    
    public fun set_max_price_update_delay<T0>(arg0: &signer, arg1: u64) acquires PriceOracleConfig {
        borrow_global_mut<PriceOracleConfig<T0>>(0x1::signer::address_of(arg0)).max_price_update_delay = arg1;
    }
    
    public fun set_pyth_price_identifier<T0>(arg0: &signer, arg1: vector<u8>) acquires PriceOracleConfig {
        borrow_global_mut<PriceOracleConfig<T0>>(0x1::signer::address_of(arg0)).pyth_price_identifier = arg1;
    }
    
    public fun set_spread_basis_points_if_update_delay<T0>(arg0: &signer, arg1: u64) acquires PriceOracleConfig {
        borrow_global_mut<PriceOracleConfig<T0>>(0x1::signer::address_of(arg0)).spread_basis_points_if_update_delay = arg1;
    }
    
    public fun set_switchboard_oracle_address<T0>(arg0: &signer, arg1: address) acquires PriceOracleConfig {
        borrow_global_mut<PriceOracleConfig<T0>>(0x1::signer::address_of(arg0)).switchboard_oracle_address = arg1;
    }
    
    public fun set_update_pyth_enabled<T0>(arg0: &signer, arg1: bool) acquires PriceOracleConfig {
        borrow_global_mut<PriceOracleConfig<T0>>(0x1::signer::address_of(arg0)).update_pyth_enabled = arg1;
    }
    
    // decompiled from Move bytecode v6
}


module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault {
    struct Vault<phantom T0, phantom T1> has key {
        coin_store: 0x1::coin::Coin<T1>,
    }
    
    public(friend) fun deposit_vault<T0, T1>(arg0: 0x1::coin::Coin<T1>) acquires Vault {
        0x1::coin::merge<T1>(&mut borrow_global_mut<Vault<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).coin_store, arg0);
    }
    
    public fun register_vault<T0, T1>(arg0: &signer) {
        let v0 = 0x1::signer::address_of(arg0);
        assert!(v0 == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        if (exists<Vault<T0, T1>>(v0)) {
        } else {
            let v1 = Vault<T0, T1>{coin_store: 0x1::coin::zero<T1>()};
            move_to<Vault<T0, T1>>(arg0, v1);
        };
    }
    
    public fun vault_balance<T0, T1>() : u64 acquires Vault {
        0x1::coin::value<T1>(&borrow_global_mut<Vault<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).coin_store)
    }
    
    public(friend) fun withdraw_vault<T0, T1>(arg0: u64) : 0x1::coin::Coin<T1> acquires Vault {
        if (arg0 == 0) {
            return 0x1::coin::zero<T1>()
        };
        0x1::coin::extract<T1>(&mut borrow_global_mut<Vault<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).coin_store, arg0)
    }
    
    // decompiled from Move bytecode v6
}


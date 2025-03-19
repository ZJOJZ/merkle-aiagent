module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::delegate_account {
    struct DelegateAccount<phantom T0> has key {
        addresses: vector<address>,
        vault: 0x1::coin::Coin<T0>,
    }
    
    struct DelegateAccountVaultEvent has drop, store {
        user: address,
        amount: u64,
        event_type: u64,
    }
    
    struct DelegateAccountVaultEvents has key {
        delegate_account_vault_events: 0x1::event::EventHandle<DelegateAccountVaultEvent>,
    }
    
    public fun deposit<T0>(arg0: &signer, arg1: address, arg2: u64) acquires DelegateAccount, DelegateAccountVaultEvents {
        let v0 = 0x1::signer::address_of(arg0);
        register<T0>(arg0, arg1);
        0x1::coin::merge<T0>(&mut borrow_global_mut<DelegateAccount<T0>>(v0).vault, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fa_box::get_fa_coin_if_needed<T0>(arg0, arg2));
        let v1 = DelegateAccountVaultEvent{
            user       : v0, 
            amount     : arg2, 
            event_type : 1,
        };
        0x1::event::emit_event<DelegateAccountVaultEvent>(&mut borrow_global_mut<DelegateAccountVaultEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).delegate_account_vault_events, v1);
    }
    
    public(friend) fun deposit_from_trading<T0>(arg0: address, arg1: 0x1::coin::Coin<T0>) acquires DelegateAccount {
        0x1::coin::merge<T0>(&mut borrow_global_mut<DelegateAccount<T0>>(arg0).vault, arg1);
    }
    
    public fun initialize_module(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        if (exists<DelegateAccountVaultEvents>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = DelegateAccountVaultEvents{delegate_account_vault_events: 0x1::account::new_event_handle<DelegateAccountVaultEvent>(arg0)};
            move_to<DelegateAccountVaultEvents>(arg0, v0);
        };
    }
    
    public fun is_active<T0>(arg0: address) : bool acquires DelegateAccount {
        if (exists<DelegateAccount<T0>>(arg0)) {
            return 0x1::vector::length<address>(&borrow_global<DelegateAccount<T0>>(arg0).addresses) > 0
        };
        false
    }
    
    public fun is_registered<T0>(arg0: address, arg1: address) : bool acquires DelegateAccount {
        if (is_active<T0>(arg0)) {
            return 0x1::vector::contains<address>(&borrow_global<DelegateAccount<T0>>(arg0).addresses, &arg1)
        };
        false
    }
    
    public fun register<T0>(arg0: &signer, arg1: address) acquires DelegateAccount {
        let v0 = 0x1::signer::address_of(arg0);
        if (exists<DelegateAccount<T0>>(v0)) {
        } else {
            let v1 = DelegateAccount<T0>{
                addresses : 0x1::vector::empty<address>(), 
                vault     : 0x1::coin::zero<T0>(),
            };
            move_to<DelegateAccount<T0>>(arg0, v1);
        };
        let v2 = borrow_global_mut<DelegateAccount<T0>>(v0);
        if (0x1::vector::contains<address>(&v2.addresses, &arg1)) {
        } else {
            assert!(0x1::vector::length<address>(&v2.addresses) < 10, 2);
            0x1::vector::push_back<address>(&mut v2.addresses, arg1);
        };
        if (0x1::account::exists_at(arg1)) {
        } else {
            0x1::aptos_account::create_account(arg1);
        };
    }
    
    public fun unregister<T0>(arg0: &signer) acquires DelegateAccount, DelegateAccountVaultEvents {
        let v0 = borrow_global_mut<DelegateAccount<T0>>(0x1::signer::address_of(arg0));
        v0.addresses = 0x1::vector::empty<address>();
        withdraw<T0>(arg0, 0x1::coin::value<T0>(&v0.vault));
    }
    
    public fun withdraw<T0>(arg0: &signer, arg1: u64) acquires DelegateAccount, DelegateAccountVaultEvents {
        let v0 = 0x1::signer::address_of(arg0);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fa_box::deposit_asset_to_user<T0>(0x1::signer::address_of(arg0), 0x1::coin::extract<T0>(&mut borrow_global_mut<DelegateAccount<T0>>(v0).vault, arg1));
        let v1 = DelegateAccountVaultEvent{
            user       : v0, 
            amount     : arg1, 
            event_type : 2,
        };
        0x1::event::emit_event<DelegateAccountVaultEvent>(&mut borrow_global_mut<DelegateAccountVaultEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).delegate_account_vault_events, v1);
    }
    
    public(friend) fun withdraw_to_trading<T0>(arg0: address, arg1: u64) : 0x1::coin::Coin<T0> acquires DelegateAccount {
        0x1::coin::extract<T0>(&mut borrow_global_mut<DelegateAccount<T0>>(arg0).vault, arg1)
    }
    
    // decompiled from Move bytecode v6
}


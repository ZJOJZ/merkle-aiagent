module 0xcf93155bab72399a4f9e9b673621e22ca300f54ebea2a98febc55d17f04aac57::redemption_tools {
    struct DepositNative has drop, store {
        coin: 0x1::string::String,
        redemption_fa: 0x1::object::Object<0x1::fungible_asset::Metadata>,
        operator: address,
        amount: u64,
    }
    
    struct RedemptionPool<phantom T0> has key {
        redemption_fa: 0x1::object::Object<0x1::fungible_asset::Metadata>,
        native_store: 0x1::object::ExtendRef,
    }
    
    public entry fun deposit_native<T0>(arg0: &signer, arg1: u64) acquires RedemptionPool {
        let v0 = borrow_global<RedemptionPool<T0>>(@0xcf93155bab72399a4f9e9b673621e22ca300f54ebea2a98febc55d17f04aac57);
        let v1 = v0.redemption_fa;
        0x1::dispatchable_fungible_asset::transfer<0x1::fungible_asset::FungibleStore>(arg0, 0x1::object::address_to_object<0x1::fungible_asset::FungibleStore>(0x1::object::create_user_derived_object_address(0x1::signer::address_of(arg0), 0x1::object::object_address<0x1::fungible_asset::Metadata>(&v1))), 0x1::object::address_to_object<0x1::fungible_asset::FungibleStore>(0x1::object::address_from_extend_ref(&v0.native_store)), arg1);
        let v2 = DepositNative{
            coin          : 0x1::type_info::type_name<T0>(), 
            redemption_fa : v0.redemption_fa, 
            operator      : 0x1::signer::address_of(arg0), 
            amount        : arg1,
        };
        0x1::event::emit<DepositNative>(v2);
    }
    
    public fun native_balance<T0>() : u64 acquires RedemptionPool {
        0x834d9657e774f8ef2a6b4a5352937f34baa85a3c50a5ff93808fdc3723e4a202::redemption::native_balance<T0>() + 0x1::fungible_asset::balance<0x1::fungible_asset::FungibleStore>(0x1::object::address_to_object<0x1::fungible_asset::FungibleStore>(0x1::object::address_from_extend_ref(&borrow_global<RedemptionPool<T0>>(@0xcf93155bab72399a4f9e9b673621e22ca300f54ebea2a98febc55d17f04aac57).native_store)))
    }
    
    public entry fun redeem<T0>(arg0: &signer, arg1: u64) acquires RedemptionPool {
        let v0 = 0x1::transaction_context::entry_function_payload();
        if (0x1::option::is_none<0x1::transaction_context::EntryFunctionPayload>(&v0)) {
            abort 1
        };
        let v1 = 0x1::option::extract<0x1::transaction_context::EntryFunctionPayload>(&mut v0);
        assert!(0x1::transaction_context::account_address(&v1) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v2 = 0x834d9657e774f8ef2a6b4a5352937f34baa85a3c50a5ff93808fdc3723e4a202::redemption::native_balance<T0>();
        if (v2 >= arg1) {
            0x834d9657e774f8ef2a6b4a5352937f34baa85a3c50a5ff93808fdc3723e4a202::redemption::redeem<T0>(arg0, arg1);
            return
        };
        let v3 = arg1 - v2;
        let v4 = borrow_global<RedemptionPool<T0>>(@0xcf93155bab72399a4f9e9b673621e22ca300f54ebea2a98febc55d17f04aac57);
        let v5 = 0x1::object::generate_signer_for_extending(&v4.native_store);
        0x1::primary_fungible_store::ensure_primary_store_exists<0x1::fungible_asset::Metadata>(0x1::signer::address_of(arg0), v4.redemption_fa);
        let v6 = v4.redemption_fa;
        0x1::dispatchable_fungible_asset::transfer<0x1::fungible_asset::FungibleStore>(&v5, 0x1::object::address_to_object<0x1::fungible_asset::FungibleStore>(0x1::object::address_from_extend_ref(&v4.native_store)), 0x1::object::address_to_object<0x1::fungible_asset::FungibleStore>(0x1::object::create_user_derived_object_address(0x1::signer::address_of(arg0), 0x1::object::object_address<0x1::fungible_asset::Metadata>(&v6))), v3);
        0x834d9657e774f8ef2a6b4a5352937f34baa85a3c50a5ff93808fdc3723e4a202::redemption::deposit_native<T0>(arg0, v3);
        0x834d9657e774f8ef2a6b4a5352937f34baa85a3c50a5ff93808fdc3723e4a202::redemption::redeem<T0>(arg0, arg1);
        0x834d9657e774f8ef2a6b4a5352937f34baa85a3c50a5ff93808fdc3723e4a202::redemption::withdraw_wrapped<T0>(arg0, v3);
        0x1::aptos_account::transfer_coins<T0>(arg0, @0xcf93155bab72399a4f9e9b673621e22ca300f54ebea2a98febc55d17f04aac57, v3);
    }
    
    public entry fun initialize_module<T0>(arg0: &signer, arg1: 0x1::object::Object<0x1::fungible_asset::Metadata>) {
        assert!(0x1::signer::address_of(arg0) == @0xcf93155bab72399a4f9e9b673621e22ca300f54ebea2a98febc55d17f04aac57, 0);
        let v0 = 0x1::object::create_object(@0x0);
        let v1 = &v0;
        0x1::fungible_asset::create_store<0x1::fungible_asset::Metadata>(v1, arg1);
        let v2 = RedemptionPool<T0>{
            redemption_fa : arg1, 
            native_store  : 0x1::object::generate_extend_ref(v1),
        };
        move_to<RedemptionPool<T0>>(arg0, v2);
    }
    
    public entry fun withdraw_native<T0>(arg0: &signer, arg1: u64) acquires RedemptionPool {
        assert!(0x1::signer::address_of(arg0) == @0xcf93155bab72399a4f9e9b673621e22ca300f54ebea2a98febc55d17f04aac57, 0);
        let v0 = borrow_global<RedemptionPool<T0>>(@0xcf93155bab72399a4f9e9b673621e22ca300f54ebea2a98febc55d17f04aac57);
        let v1 = 0x1::object::generate_signer_for_extending(&v0.native_store);
        0x1::primary_fungible_store::ensure_primary_store_exists<0x1::fungible_asset::Metadata>(0x1::signer::address_of(arg0), v0.redemption_fa);
        let v2 = v0.redemption_fa;
        0x1::dispatchable_fungible_asset::transfer<0x1::fungible_asset::FungibleStore>(&v1, 0x1::object::address_to_object<0x1::fungible_asset::FungibleStore>(0x1::object::address_from_extend_ref(&v0.native_store)), 0x1::object::address_to_object<0x1::fungible_asset::FungibleStore>(0x1::object::create_user_derived_object_address(0x1::signer::address_of(arg0), 0x1::object::object_address<0x1::fungible_asset::Metadata>(&v2))), arg1);
        let v3 = DepositNative{
            coin          : 0x1::type_info::type_name<T0>(), 
            redemption_fa : v0.redemption_fa, 
            operator      : 0x1::signer::address_of(arg0), 
            amount        : arg1,
        };
        0x1::event::emit<DepositNative>(v3);
    }
    
    // decompiled from Move bytecode v6
}


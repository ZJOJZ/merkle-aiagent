module 0x834d9657e774f8ef2a6b4a5352937f34baa85a3c50a5ff93808fdc3723e4a202::redemption {
    struct CreatePool has drop, store {
        coin: 0x1::string::String,
        redemption_fa: 0x1::object::Object<0x1::fungible_asset::Metadata>,
    }
    
    struct DepositNative has drop, store {
        coin: 0x1::string::String,
        redemption_fa: 0x1::object::Object<0x1::fungible_asset::Metadata>,
        operator: address,
        amount: u64,
    }
    
    struct Redeem has drop, store {
        coin: 0x1::string::String,
        redemption_fa: 0x1::object::Object<0x1::fungible_asset::Metadata>,
        user: address,
        amount: u64,
    }
    
    struct RedemptionPool<phantom T0> has key {
        wrapped_coins: 0x1::coin::Coin<T0>,
        redemption_fa: 0x1::object::Object<0x1::fungible_asset::Metadata>,
        native_store: 0x1::object::ExtendRef,
        operator_balances: 0x1::table::Table<address, u64>,
    }
    
    struct WithdrawWrapped has drop, store {
        coin: 0x1::string::String,
        redemption_fa: 0x1::object::Object<0x1::fungible_asset::Metadata>,
        operator: address,
        amount: u64,
    }
    
    public entry fun create_pool<T0>(arg0: &signer, arg1: 0x1::object::Object<0x1::fungible_asset::Metadata>) {
        assert!(0x1::signer::address_of(arg0) == @0x834d9657e774f8ef2a6b4a5352937f34baa85a3c50a5ff93808fdc3723e4a202, 1);
        let v0 = 0x1::object::create_object(@0x0);
        let v1 = &v0;
        0x1::fungible_asset::create_store<0x1::fungible_asset::Metadata>(v1, arg1);
        let v2 = RedemptionPool<T0>{
            wrapped_coins     : 0x1::coin::zero<T0>(), 
            redemption_fa     : arg1, 
            native_store      : 0x1::object::generate_extend_ref(v1), 
            operator_balances : 0x1::table::new<address, u64>(),
        };
        move_to<RedemptionPool<T0>>(arg0, v2);
        let v3 = CreatePool{
            coin          : 0x1::type_info::type_name<T0>(), 
            redemption_fa : arg1,
        };
        0x1::event::emit<CreatePool>(v3);
    }
    
    public entry fun deposit_native<T0>(arg0: &signer, arg1: u64) acquires RedemptionPool {
        let v0 = 0x1::signer::address_of(arg0);
        let v1 = borrow_global_mut<RedemptionPool<T0>>(@0x834d9657e774f8ef2a6b4a5352937f34baa85a3c50a5ff93808fdc3723e4a202);
        let v2 = v1.redemption_fa;
        0x1::dispatchable_fungible_asset::transfer<0x1::fungible_asset::FungibleStore>(arg0, 0x1::object::address_to_object<0x1::fungible_asset::FungibleStore>(0x1::object::create_user_derived_object_address(v0, 0x1::object::object_address<0x1::fungible_asset::Metadata>(&v2))), 0x1::object::address_to_object<0x1::fungible_asset::FungibleStore>(0x1::object::address_from_extend_ref(&v1.native_store)), arg1);
        let v3 = 0x1::table::borrow_mut_with_default<address, u64>(&mut v1.operator_balances, v0, 0);
        *v3 = *v3 + arg1;
        let v4 = DepositNative{
            coin          : 0x1::type_info::type_name<T0>(), 
            redemption_fa : v1.redemption_fa, 
            operator      : v0, 
            amount        : arg1,
        };
        0x1::event::emit<DepositNative>(v4);
    }
    
    public fun native_balance<T0>() : u64 acquires RedemptionPool {
        0x1::fungible_asset::balance<0x1::fungible_asset::FungibleStore>(0x1::object::address_to_object<0x1::fungible_asset::FungibleStore>(0x1::object::address_from_extend_ref(&borrow_global<RedemptionPool<T0>>(@0x834d9657e774f8ef2a6b4a5352937f34baa85a3c50a5ff93808fdc3723e4a202).native_store)))
    }
    
    public entry fun redeem<T0>(arg0: &signer, arg1: u64) acquires RedemptionPool {
        let v0 = borrow_global_mut<RedemptionPool<T0>>(@0x834d9657e774f8ef2a6b4a5352937f34baa85a3c50a5ff93808fdc3723e4a202);
        0x1::coin::merge<T0>(&mut v0.wrapped_coins, 0x1::coin::withdraw<T0>(arg0, arg1));
        let v1 = 0x1::object::generate_signer_for_extending(&v0.native_store);
        let v2 = 0x1::signer::address_of(arg0);
        0x1::primary_fungible_store::ensure_primary_store_exists<0x1::fungible_asset::Metadata>(v2, v0.redemption_fa);
        let v3 = v0.redemption_fa;
        0x1::dispatchable_fungible_asset::transfer<0x1::fungible_asset::FungibleStore>(&v1, 0x1::object::address_to_object<0x1::fungible_asset::FungibleStore>(0x1::object::address_from_extend_ref(&v0.native_store)), 0x1::object::address_to_object<0x1::fungible_asset::FungibleStore>(0x1::object::create_user_derived_object_address(v2, 0x1::object::object_address<0x1::fungible_asset::Metadata>(&v3))), arg1);
        let v4 = Redeem{
            coin          : 0x1::type_info::type_name<T0>(), 
            redemption_fa : v0.redemption_fa, 
            user          : 0x1::signer::address_of(arg0), 
            amount        : arg1,
        };
        0x1::event::emit<Redeem>(v4);
    }
    
    public entry fun withdraw_wrapped<T0>(arg0: &signer, arg1: u64) acquires RedemptionPool {
        let v0 = 0x1::signer::address_of(arg0);
        let v1 = borrow_global_mut<RedemptionPool<T0>>(@0x834d9657e774f8ef2a6b4a5352937f34baa85a3c50a5ff93808fdc3723e4a202);
        let v2 = 0x1::table::borrow_mut<address, u64>(&mut v1.operator_balances, v0);
        assert!(*v2 >= arg1, 2);
        *v2 = *v2 - arg1;
        if (*v2 == 0) {
            0x1::table::remove<address, u64>(&mut v1.operator_balances, v0);
        };
        0x1::aptos_account::deposit_coins<T0>(v0, 0x1::coin::extract<T0>(&mut v1.wrapped_coins, arg1));
        let v3 = WithdrawWrapped{
            coin          : 0x1::type_info::type_name<T0>(), 
            redemption_fa : v1.redemption_fa, 
            operator      : v0, 
            amount        : arg1,
        };
        0x1::event::emit<WithdrawWrapped>(v3);
    }
    
    public fun wrapped_balance<T0>() : u64 acquires RedemptionPool {
        0x1::coin::value<T0>(&borrow_global<RedemptionPool<T0>>(@0x834d9657e774f8ef2a6b4a5352937f34baa85a3c50a5ff93808fdc3723e4a202).wrapped_coins)
    }
    
    // decompiled from Move bytecode v6
}


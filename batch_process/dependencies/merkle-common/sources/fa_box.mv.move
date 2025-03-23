module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fa_box {
    struct FABox<phantom T0> has key {
        store: 0x1::object::Object<0x1::fungible_asset::FungibleStore>,
        mint_capability: 0x1::coin::MintCapability<T0>,
        burn_capability: 0x1::coin::BurnCapability<T0>,
        freeze_capability: 0x1::coin::FreezeCapability<T0>,
    }

    struct FABoxSigner has key {
        cap: 0x1::account::SignerCapability,
    }

    struct W_USDC {
        dummy_field: bool,
    }

    public fun deposit_asset_to_user<T0>(arg0: address, arg1: 0x1::coin::Coin<T0>) acquires FABox, FABoxSigner {
        if (is_fa_box<T0>()) {
            let v0 = 0x1::account::create_signer_with_capability(&borrow_global<FABoxSigner>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).cap);
            let v1 = borrow_global_mut<FABox<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
            let v2 = 0x1::dispatchable_fungible_asset::withdraw<0x1::fungible_asset::FungibleStore>(&v0, v1.store, 0x1::coin::value<T0>(&arg1));
            0x1::coin::burn<T0>(arg1, &v1.burn_capability);
            0x1::primary_fungible_store::deposit(arg0, v2);
        } else {
            0x1::aptos_account::deposit_coins<T0>(arg0, arg1);
        };
    }

    public fun get_fa_coin_if_needed<T0>(arg0: &signer, arg1: u64) : 0x1::coin::Coin<T0> acquires FABox {
        if (is_fa_box<T0>()) {
            let v0 = borrow_global<FABox<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
            0x1::dispatchable_fungible_asset::deposit<0x1::fungible_asset::FungibleStore>(v0.store, 0x1::primary_fungible_store::withdraw<0x1::fungible_asset::Metadata>(arg0, 0x1::fungible_asset::store_metadata<0x1::fungible_asset::FungibleStore>(v0.store), arg1));
            if (0x1::coin::is_account_registered<T0>(0x1::signer::address_of(arg0))) {
            } else {
                0x1::coin::register<T0>(arg0);
            };
            return 0x1::coin::mint<T0>(arg1, &v0.mint_capability)
        };
        0x1::coin::withdraw<T0>(arg0, arg1)
    }

    public fun get_paired_metadata<T0>() : 0x1::object::Object<0x1::fungible_asset::Metadata> acquires FABox {
        0x1::fungible_asset::store_metadata<0x1::fungible_asset::FungibleStore>(borrow_global<FABox<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).store)
    }

    public entry fun initialize_paired_fa<T0>(arg0: &signer, arg1: 0x1::object::Object<0x1::fungible_asset::Metadata>) acquires FABoxSigner {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        if (exists<FABoxSigner>(0x1::signer::address_of(arg0))) {
        } else {
            let (_, v1) = 0x1::account::create_resource_account(arg0, b"FABoxSigner");
            let v2 = FABoxSigner{cap: v1};
            move_to<FABoxSigner>(arg0, v2);
        };
        let v3 = if (0x1::coin::is_coin_initialized<T0>()) {
            false
        } else {
            let v4 = 0x1::coin::paired_coin(arg1);
            !0x1::option::is_some<0x1::type_info::TypeInfo>(&v4)
        };
        assert!(v3, 1);
        let v5 = 0x1::account::create_signer_with_capability(&borrow_global<FABoxSigner>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).cap);
        let v6 = 0x1::object::create_object(0x1::signer::address_of(&v5));
        let v7 = 0x1::type_info::type_of<T0>();
        let v8 = 0x1::type_info::type_of<T0>();
        let (v9, v10, v11) = 0x1::coin::initialize<T0>(arg0, 0x1::string::utf8(0x1::type_info::struct_name(&v7)), 0x1::string::utf8(0x1::type_info::struct_name(&v8)), 0x1::fungible_asset::decimals<0x1::fungible_asset::Metadata>(arg1), true);
        let v12 = FABox<T0>{
            store             : 0x1::fungible_asset::create_store<0x1::fungible_asset::Metadata>(&v6, arg1),
            mint_capability   : v11,
            burn_capability   : v9,
            freeze_capability : v10,
        };
        move_to<FABox<T0>>(arg0, v12);
    }

    fun is_fa_box<T0>() : bool {
        let v0 = 0x1::type_info::type_of<T0>();
        0x1::type_info::module_name(&v0) == b"fa_box" && exists<FABox<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)
    }

    // decompiled from Move bytecode v7
}


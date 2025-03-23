module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::coin_utils {
    public fun convert_all_coin_to_fungible_asset<T0>(arg0: &signer) {
        0x1::primary_fungible_store::deposit(0x1::signer::address_of(arg0), 0x1::coin::coin_to_fungible_asset<T0>(0x1::coin::withdraw<T0>(arg0, 0x1::coin::balance<T0>(0x1::signer::address_of(arg0)))));
    }
    
    // decompiled from Move bytecode v6
}


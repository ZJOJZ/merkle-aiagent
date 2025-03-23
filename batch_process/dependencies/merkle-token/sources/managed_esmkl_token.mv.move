module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_esmkl_token {
    public entry fun cancel(arg0: &signer, arg1: address) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::cancel(arg0, arg1);
    }
    
    public entry fun claim(arg0: &signer, arg1: address) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::claim(arg0, arg1);
    }
    
    public entry fun initialize_module(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::initialize_module(arg0);
    }
    
    public entry fun restore_cfa_store_admin_cap(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::restore_cfa_store_admin_cap(arg0);
    }
    
    public entry fun restore_cfa_store_claim_cap(arg0: &signer, arg1: address) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::restore_cfa_store_claim_cap(arg0, arg1);
    }
    
    public entry fun vest(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::vest(arg0, arg1);
    }
    
    public fun esmkl_object_balance(arg0: address) : u64 {
        0x1::fungible_asset::balance<0x1::fungible_asset::FungibleStore>(0x1::object::address_to_object<0x1::fungible_asset::FungibleStore>(arg0))
    }
    
    public fun esmkl_user_balance(arg0: address) : u64 {
        0x1::primary_fungible_store::balance<0x1::fungible_asset::Metadata>(arg0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::get_metadata())
    }
    
    // decompiled from Move bytecode v6
}


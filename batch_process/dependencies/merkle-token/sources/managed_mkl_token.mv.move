module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_mkl_token {
    public entry fun initialize_module(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::initialize_module(arg0);
    }
    
    public entry fun run_token_generation_event(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::run_token_generation_event(arg0);
    }
    
    public fun get_circulating_supply() : u64 {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::get_unlock_amount<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::COMMUNITY_POOL>() + 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::get_unlock_amount<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::GROWTH_POOL>() + 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::get_unlock_amount<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::CORE_TEAM_POOL>() + 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::get_unlock_amount<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::INVESTOR_POOL>() + 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::get_unlock_amount<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::ADVISOR_POOL>()
    }
    
    public fun mkl_object_balance(arg0: address) : u64 {
        0x1::fungible_asset::balance<0x1::fungible_asset::FungibleStore>(0x1::object::address_to_object<0x1::fungible_asset::FungibleStore>(arg0))
    }
    
    public fun mkl_user_balance(arg0: address) : u64 {
        0x1::primary_fungible_store::balance<0x1::fungible_asset::Metadata>(arg0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::get_metadata())
    }
    
    // decompiled from Move bytecode v6
}


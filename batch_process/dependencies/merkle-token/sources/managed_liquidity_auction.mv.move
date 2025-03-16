module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_liquidity_auction {
    public entry fun claim_mkl_reward<T0>(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::liquidity_auction::claim_mkl_reward<T0>(arg0);
    }
    
    public entry fun deposit_asset<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::liquidity_auction::deposit_asset<T0>(arg0, arg1);
    }
    
    public entry fun deposit_pre_mkl<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::liquidity_auction::deposit_pre_mkl<T0>(arg0, arg1);
    }
    
    public fun get_claimable_mkl_reward<T0>(arg0: address) : u64 {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::liquidity_auction::get_claimable_mkl_reward<T0>(arg0)
    }
    
    public fun get_lba_schedule() : (u64, u64, u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::liquidity_auction::get_lba_schedule()
    }
    
    public entry fun initialize_module<T0>(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::liquidity_auction::initialize_module<T0>(arg0);
    }
    
    public entry fun run_tge_sequence<T0>(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::liquidity_auction::run_tge_sequence<T0>(arg0);
    }
    
    public entry fun withdraw_asset<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::liquidity_auction::withdraw_asset<T0>(arg0, arg1);
    }
    
    public entry fun withdraw_lp<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::liquidity_auction::withdraw_lp<T0>(arg0, arg1);
    }
    
    public entry fun withdraw_remaining_reward<T0>(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::liquidity_auction::withdraw_remaining_reward<T0>(arg0);
    }
    
    // decompiled from Move bytecode v6
}


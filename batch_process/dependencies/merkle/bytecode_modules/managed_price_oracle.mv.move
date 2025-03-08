module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_price_oracle {
    public entry fun update<T0>(arg0: &signer, arg1: u64, arg2: vector<u8>) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::update<T0>(arg0, arg1, arg2);
    }
    
    public entry fun claim_allowed_update(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::claim_allowed_update(arg0);
    }
    
    public entry fun deposit_apt(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::deposit_apt(arg0, arg1);
    }
    
    public entry fun initialize_module(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::initialize_module(arg0);
    }
    
    public entry fun register_allowed_update<T0>(arg0: &signer, arg1: address) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::register_allowed_update<T0>(arg0, arg1);
    }
    
    public entry fun register_oracle<T0>(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::register_oracle<T0>(arg0);
    }
    
    public entry fun remove_allowed_update<T0>(arg0: &signer, arg1: address) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::remove_allowed_update<T0>(arg0, arg1);
    }
    
    public entry fun set_is_spread_enabled<T0>(arg0: &signer, arg1: bool) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::set_is_spread_enabled<T0>(arg0, arg1);
    }
    
    public entry fun set_max_deviation_basis_points<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::set_max_deviation_basis_points<T0>(arg0, arg1);
    }
    
    public entry fun set_max_price_update_delay<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::set_max_price_update_delay<T0>(arg0, arg1);
    }
    
    public entry fun set_pyth_price_identifier<T0>(arg0: &signer, arg1: vector<u8>) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::set_pyth_price_identifier<T0>(arg0, arg1);
    }
    
    public entry fun set_spread_basis_points_if_update_delay<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::set_spread_basis_points_if_update_delay<T0>(arg0, arg1);
    }
    
    public entry fun set_switchboard_oracle_address<T0>(arg0: &signer, arg1: address) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::set_switchboard_oracle_address<T0>(arg0, arg1);
    }
    
    public entry fun set_update_pyth_enabled<T0>(arg0: &signer, arg1: bool) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::set_update_pyth_enabled<T0>(arg0, arg1);
    }
    
    // decompiled from Move bytecode v6
}


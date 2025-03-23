module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_profile {
    public entry fun add_new_class(arg0: &signer, arg1: u64, arg2: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::profile::add_new_class(arg0, arg1, arg2);
    }
    
    public entry fun apply_soft_reset_level(arg0: &signer, arg1: vector<address>, arg2: vector<vector<u64>>) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::profile::apply_soft_reset_level(arg0, arg1, arg2);
    }
    
    public entry fun boost_event_initialized(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::profile::boost_event_initialized(arg0);
    }
    
    public entry fun initialize_module(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::profile::initialize_module(arg0);
    }
    
    public entry fun set_soft_reset_rate(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::profile::set_soft_reset_rate(arg0, arg1);
    }
    
    public entry fun set_user_soft_reset_level(arg0: &signer, arg1: address, arg2: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::profile::set_user_soft_reset_level(arg0, arg1, arg2);
    }
    
    public entry fun update_class(arg0: &signer, arg1: u64, arg2: u64, arg3: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::profile::update_class(arg0, arg1, arg2, arg3);
    }
    
    public fun get_user_profile(arg0: address) : (u64, u64, u64, u64, u64) {
        let (v0, v1, v2, v3) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::profile::get_level_info(arg0);
        (v0, v1, v2, v3, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::profile::get_boost(arg0))
    }
    
    // decompiled from Move bytecode v6
}


module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_pre_tge_reward {
    public entry fun claim_lp_reward(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_tge_reward::claim_lp_reward(arg0);
    }
    
    public entry fun claim_point_reward(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_tge_reward::claim_point_reward(arg0);
    }
    
    public entry fun initialize_module(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_tge_reward::initialize_module(arg0);
    }
    
    public entry fun set_bulk_point_reward(arg0: &signer, arg1: vector<address>, arg2: vector<u64>) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_tge_reward::set_bulk_point_reward(arg0, arg1, arg2);
    }
    
    public entry fun set_lp_reward(arg0: &signer, arg1: address, arg2: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_tge_reward::set_lp_reward(arg0, arg1, arg2);
    }
    
    public entry fun set_point_reward(arg0: &signer, arg1: address, arg2: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_tge_reward::set_point_reward(arg0, arg1, arg2);
    }
    
    // decompiled from Move bytecode v6
}


module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_protocol_reward {
    public entry fun claim_rewards<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::protocol_reward::claim_rewards<T0>(arg0, arg1);
    }
    
    public entry fun initialize_module<T0>(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::protocol_reward::initialize_module<T0>(arg0);
    }
    
    public entry fun register_vemkl_protocol_rewards<T0>(arg0: &signer, arg1: u64, arg2: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::protocol_reward::register_vemkl_protocol_rewards<T0>(arg0, arg1, arg2);
    }
    
    public fun user_reward_amount<T0>(arg0: address, arg1: u64) : u64 {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::protocol_reward::user_reward_amount<T0>(arg0, arg1)
    }
    
    // decompiled from Move bytecode v6
}


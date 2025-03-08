module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_capability {
    public entry fun claim_admin_cap_v2(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::capability::claim_admin_cap_v2(arg0);
    }
    
    public entry fun claim_capability_provider(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::capability::claim_capability_provider(arg0);
    }
    
    public entry fun claim_executor_cap<T0>(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::capability::claim_executor_cap<T0>(arg0);
    }
    
    public entry fun claim_executor_cap_v3(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::capability::claim_executor_cap_v3(arg0);
    }
    
    public entry fun initialize_module(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::capability::initialize_module(arg0);
    }
    
    public entry fun register_capability_provider_candidate(arg0: &signer, arg1: address) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::capability::register_capability_provider_candidate(arg0, arg1);
    }
    
    public entry fun set_address_admin_candidate_v2(arg0: &signer, arg1: address) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::capability::set_address_admin_candidate_v2(arg0, arg1);
    }
    
    public entry fun set_addresses_executor_candidate<T0>(arg0: &signer, arg1: vector<address>) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::capability::set_addresses_executor_candidate<T0>(arg0, arg1);
    }
    
    public entry fun set_addresses_executor_candidate_v3(arg0: &signer, arg1: vector<address>) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::capability::set_addresses_executor_candidate_v3(arg0, arg1);
    }
    
    // decompiled from Move bytecode v6
}


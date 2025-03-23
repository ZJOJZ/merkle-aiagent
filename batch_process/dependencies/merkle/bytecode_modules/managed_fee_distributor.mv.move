module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_fee_distributor {
    public entry fun initialize<T0>(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fee_distributor::initialize<T0>(arg0);
    }
    
    public entry fun set_dev_weight<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fee_distributor::set_dev_weight<T0>(arg0, arg1);
    }
    
    public entry fun set_lp_weight<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fee_distributor::set_lp_weight<T0>(arg0, arg1);
    }
    
    public entry fun set_stake_weight<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fee_distributor::set_stake_weight<T0>(arg0, arg1);
    }
    
    public entry fun withdraw_fee_dev<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fee_distributor::withdraw_fee_dev<T0>(arg0, arg1);
    }
    
    public entry fun withdraw_fee_stake<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fee_distributor::withdraw_fee_stake<T0>(arg0, arg1);
    }
    
    // decompiled from Move bytecode v6
}


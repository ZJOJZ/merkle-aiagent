module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_house_lp {
    public entry fun cancel_redeem_plan<T0>(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::cancel_redeem_plan<T0>(arg0);
    }
    
    public entry fun convert_mklp_type<T0, T1>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::convert_mklp_type<T0, T1>(arg0, arg1);
    }
    
    public entry fun deposit<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::deposit<T0>(arg0, arg1);
    }
    
    public entry fun deposit_without_mint<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::deposit_without_mint<T0>(arg0, arg1);
    }
    
    public entry fun redeem<T0>(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::redeem<T0>(arg0);
    }
    
    public entry fun register<T0>(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::register<T0>(arg0);
    }
    
    public entry fun register_redeem_plan<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::register_redeem_plan<T0>(arg0, arg1);
    }
    
    public entry fun set_house_lp_deposit_fee<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::set_house_lp_deposit_fee<T0>(arg0, arg1);
    }
    
    public entry fun set_house_lp_hard_break<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::set_house_lp_hard_break<T0>(arg0, arg1);
    }
    
    public entry fun set_house_lp_minimum_deposit<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::set_house_lp_minimum_deposit<T0>(arg0, arg1);
    }
    
    public entry fun set_house_lp_soft_break<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::set_house_lp_soft_break<T0>(arg0, arg1);
    }
    
    public entry fun set_house_lp_withdraw_division<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::set_house_lp_withdraw_division<T0>(arg0, arg1);
    }
    
    public entry fun set_house_lp_withdraw_fee<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::set_house_lp_withdraw_fee<T0>(arg0, arg1);
    }
    
    public entry fun withdraw<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::withdraw<T0>(arg0, arg1);
    }
    
    // decompiled from Move bytecode v6
}


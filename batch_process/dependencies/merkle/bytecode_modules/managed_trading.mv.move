module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_trading {
    
    public entry fun place_order_v3<T0, T1>(arg0: &signer, arg1: address, arg2: u64, arg3: u64, arg4: u64, arg5: bool, arg6: bool, arg7: bool, arg8: u64, arg9: u64, arg10: bool, arg11: address) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::referral::register_referrer<T1>(arg1, arg11);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading::place_order_v3<T0, T1>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10);
    }
    // decompiled from Move bytecode v6
}


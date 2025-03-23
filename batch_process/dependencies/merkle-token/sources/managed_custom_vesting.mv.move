module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_custom_vesting {
    public entry fun cancel(arg0: &signer, arg1: address) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::custom_vesting::cancel(arg0, arg1);
    }
    
    public entry fun claim(arg0: &signer, arg1: address) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::custom_vesting::claim(arg0, arg1);
    }
    
    public entry fun create_custom_vesting<T0>(arg0: &signer, arg1: address, arg2: u64, arg3: u64, arg4: u64, arg5: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::custom_vesting::create_custom_vesting<T0>(arg0, arg1, arg2, arg3, arg4, arg5);
    }
    
    public entry fun pause(arg0: &signer, arg1: address) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::custom_vesting::pause(arg0, arg1);
    }
    
    public entry fun unpause(arg0: &signer, arg1: address) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::custom_vesting::unpause(arg0, arg1);
    }
    
    // decompiled from Move bytecode v6
}


module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_delegate_account {
    public entry fun deposit<T0>(arg0: &signer, arg1: address, arg2: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading::initialize_user_if_needed(arg0);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::delegate_account::deposit<T0>(arg0, arg1, arg2);
    }
    
    public entry fun initialize_module(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::delegate_account::initialize_module(arg0);
    }
    
    public entry fun register<T0>(arg0: &signer, arg1: address) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::delegate_account::register<T0>(arg0, arg1);
    }
    
    public entry fun unregister<T0>(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::delegate_account::unregister<T0>(arg0);
    }
    
    public entry fun withdraw<T0>(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::delegate_account::withdraw<T0>(arg0, arg1);
    }
    
    // decompiled from Move bytecode v6
}


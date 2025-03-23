module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_vault {
    public entry fun register_vault<T0, T1>(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::register_vault<T0, T1>(arg0);
    }
    
    // decompiled from Move bytecode v6
}


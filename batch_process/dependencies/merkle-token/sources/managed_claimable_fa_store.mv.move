module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_claimable_fa_store {
    public entry fun deposit_funding_store(arg0: &signer, arg1: address, arg2: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::claimable_fa_store::deposit_funding_store(arg0, arg1, arg2);
    }
    
    // decompiled from Move bytecode v6
}


module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_pMKL {
    public entry fun claim_season_esmkl(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pMKL::claim_season_esmkl(arg0, arg1);
    }
    
    public fun get_current_season_info() : 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pMKL::SeasonPMKLSupplyView {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pMKL::get_current_season_info()
    }
    
    public fun get_season_info(arg0: u64) : 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pMKL::SeasonPMKLSupplyView {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pMKL::get_season_info(arg0)
    }
    
    public fun get_season_user_pmkl(arg0: address, arg1: u64) : 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pMKL::SeasonUserPMKLInfoView {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pMKL::get_season_user_pmkl(arg0, arg1)
    }
    
    public fun get_user_season_claimable(arg0: address, arg1: u64) : u64 {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pMKL::get_user_season_claimable(arg0, arg1)
    }
    
    public entry fun initialize_module(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pMKL::initialize_module(arg0);
    }
    
    public entry fun set_season_reward(arg0: &signer, arg1: u64, arg2: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pMKL::set_season_reward(arg0, arg1, arg2);
    }
    
    // decompiled from Move bytecode v6
}


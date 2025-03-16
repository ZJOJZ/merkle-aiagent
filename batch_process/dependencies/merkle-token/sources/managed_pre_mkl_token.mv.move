module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_pre_mkl_token {
    public entry fun deploy_pre_mkl_from_growth_fund(arg0: &signer, arg1: address, arg2: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::deploy_pre_mkl_from_growth_fund(arg0, arg1, arg2);
    }
    
    public entry fun initialize_module(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::initialize_module(arg0);
    }
    
    public entry fun run_token_generation_event(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::run_token_generation_event(arg0);
    }
    
    public entry fun swap_pre_mkl_to_mkl(arg0: &signer) {
        0x1::primary_fungible_store::deposit(0x1::signer::address_of(arg0), 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::swap_pre_mkl_to_mkl(arg0));
    }
    
    public entry fun admin_sawp_user_pre_mkl_to_mkl(arg0: &signer, arg1: vector<address>) {
        let v0 = arg1;
        0x1::vector::reverse<address>(&mut v0);
        let v1 = v0;
        let v2 = 0x1::vector::length<address>(&v1);
        while (v2 > 0) {
            let v3 = 0x1::vector::pop_back<address>(&mut v1);
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::admin_swap_premkl_to_mkl(arg0, v3);
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::staking::admin_swap_vemkl_premkl_to_mkl(arg0, v3);
            v2 = v2 - 1;
        };
        0x1::vector::destroy_empty<address>(v1);
    }
    
    public entry fun user_sawp_user_pre_mkl_to_mkl(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::user_swap_premkl_to_mkl(arg0);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::staking::user_swap_vemkl_premkl_to_mkl(arg0);
    }
    
    // decompiled from Move bytecode v6
}


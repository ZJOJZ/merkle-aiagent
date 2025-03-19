module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_staking {
    public entry fun initialize_module(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::staking::initialize_module(arg0);
    }
    
    public entry fun set_epoch_duration(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::staking::set_epoch_duration(arg0, arg1);
    }
    
    public entry fun set_max_lock_duration(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::staking::set_max_lock_duration(arg0, arg1);
    }
    
    public entry fun set_min_lock_duration(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::staking::set_min_lock_duration(arg0, arg1);
    }
    
    public entry fun unlock(arg0: &signer, arg1: address) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::staking::unlock(arg0, arg1);
    }
    
    public entry fun increase_lock_esmkl(arg0: &signer, arg1: address, arg2: u64, arg3: u64) {
        let v0 = if (arg2 > 0) {
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::withdraw_user_esmkl(arg0, arg2)
        } else {
            0x1::fungible_asset::zero<0x1::fungible_asset::Metadata>(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::get_metadata())
        };
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::staking::increase_lock(arg0, arg1, v0, arg3);
    }
    
    public entry fun increase_lock_mkl(arg0: &signer, arg1: address, arg2: u64, arg3: u64) {
        if (0x1::timestamp::now_seconds() >= 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::mkl_tge_at()) {
            if (0x1::primary_fungible_store::balance<0x1::fungible_asset::Metadata>(0x1::signer::address_of(arg0), 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::get_metadata()) > 0) {
                0x1::primary_fungible_store::deposit(0x1::signer::address_of(arg0), 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::swap_pre_mkl_to_mkl(arg0));
            };
            let v0 = if (arg2 > 0) {
                0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::coin_utils::convert_all_coin_to_fungible_asset<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::MKL>(arg0);
                0x1::primary_fungible_store::withdraw<0x1::fungible_asset::Metadata>(arg0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::get_metadata(), arg2)
            } else {
                0x1::fungible_asset::zero<0x1::fungible_asset::Metadata>(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::get_metadata())
            };
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::staking::increase_lock(arg0, arg1, v0, arg3);
        } else {
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::staking::increase_lock(arg0, arg1, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::withdraw_from_user(0x1::signer::address_of(arg0), arg2), arg3);
        };
    }
    
    public entry fun lock_esmkl(arg0: &signer, arg1: u64, arg2: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::staking::lock(arg0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::withdraw_user_esmkl(arg0, arg1), arg2);
    }
    
    public entry fun lock_mkl(arg0: &signer, arg1: u64, arg2: u64) {
        if (0x1::timestamp::now_seconds() >= 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::mkl_tge_at()) {
            if (0x1::primary_fungible_store::balance<0x1::fungible_asset::Metadata>(0x1::signer::address_of(arg0), 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::get_metadata()) > 0) {
                0x1::primary_fungible_store::deposit(0x1::signer::address_of(arg0), 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::swap_pre_mkl_to_mkl(arg0));
            };
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::coin_utils::convert_all_coin_to_fungible_asset<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::MKL>(arg0);
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::staking::lock(arg0, 0x1::primary_fungible_store::withdraw<0x1::fungible_asset::Metadata>(arg0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::get_metadata(), arg1), arg2);
        } else {
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::staking::lock(arg0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::withdraw_from_user(0x1::signer::address_of(arg0), arg1), arg2);
        };
    }
    
    // decompiled from Move bytecode v6
}


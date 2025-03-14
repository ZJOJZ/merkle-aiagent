module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fee_distributor {
    struct DepositFeeEvent has drop, store {
        lp_amount: u64,
        stake_amount: u64,
        dev_amount: u64,
    }

    struct FeeDistributorEvents has key {
        deposit_fee_event: 0x1::event::EventHandle<DepositFeeEvent>,
    }

    struct FeeDistributorInfo<phantom T0> has key {
        lp_weight: u64,
        stake_weight: u64,
        dev_weight: u64,
        total_weight: u64,
    }

    public fun deposit_fee<T0>(arg0: 0x1::coin::Coin<T0>) acquires FeeDistributorEvents, FeeDistributorInfo {
        let v0 = borrow_global_mut<FeeDistributorInfo<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = 0x1::coin::value<T0>(&arg0);
        let v2 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v1, v0.lp_weight, v0.total_weight);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::deposit_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::FeeHouseLPVault, T0>(0x1::coin::extract<T0>(&mut arg0, v2));
        let v3 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v1, v0.stake_weight, v0.total_weight);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::deposit_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::FeeStakingVault, T0>(0x1::coin::extract<T0>(&mut arg0, v3));
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::deposit_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::FeeDevVault, T0>(arg0);
        let v4 = DepositFeeEvent{
            lp_amount    : v2,
            stake_amount : v3,
            dev_amount   : v1 - v2 - v3,
        };
        0x1::event::emit_event<DepositFeeEvent>(&mut borrow_global_mut<FeeDistributorEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).deposit_fee_event, v4);
    }

    public fun deposit_fee_with_rebate<T0>(arg0: 0x1::coin::Coin<T0>, arg1: address) acquires FeeDistributorEvents, FeeDistributorInfo {
        let v0 = borrow_global_mut<FeeDistributorInfo<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = 0x1::coin::value<T0>(&arg0);
        let v2 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v1, v0.lp_weight, v0.total_weight);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::deposit_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::FeeHouseLPVault, T0>(0x1::coin::extract<T0>(&mut arg0, v2));
        let v3 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v1, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::referral::get_rebate_rate<T0>(arg1), 1000000);
        let v4 = v3;
        if (v3 > 0) {
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::referral::add_unclaimed_amount<T0>(arg1, 0x1::coin::extract<T0>(&mut arg0, v3));
            if (0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::referral::is_ancestor_enabled<T0>(arg1)) {
                let v5 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v1, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::referral::get_ancestor_rebate_rate(), 1000000);
                0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::referral::add_ancestor_amount<T0>(arg1, 0x1::coin::extract<T0>(&mut arg0, v5));
                v4 = v3 + v5;
            };
        };
        let v6 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v1 - v2 - v4, v0.stake_weight, v0.stake_weight + v0.dev_weight);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::deposit_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::FeeStakingVault, T0>(0x1::coin::extract<T0>(&mut arg0, v6));
        let v7 = 0x1::coin::value<T0>(&arg0);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::deposit_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::FeeDevVault, T0>(arg0);
        let v8 = DepositFeeEvent{
            lp_amount    : v2,
            stake_amount : v6,
            dev_amount   : v7,
        };
        0x1::event::emit_event<DepositFeeEvent>(&mut borrow_global_mut<FeeDistributorEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).deposit_fee_event, v8);
    }

    public fun initialize<T0>(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        assert!(0x1::coin::is_coin_initialized<T0>(), 0);
        if (exists<FeeDistributorInfo<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)) {
        } else {
            let v0 = FeeDistributorInfo<T0>{
                lp_weight    : 0,
                stake_weight : 0,
                dev_weight   : 0,
                total_weight : 0,
            };
            move_to<FeeDistributorInfo<T0>>(arg0, v0);
        };
        if (exists<FeeDistributorEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)) {
        } else {
            let v1 = FeeDistributorEvents{deposit_fee_event: 0x1::account::new_event_handle<DepositFeeEvent>(arg0)};
            move_to<FeeDistributorEvents>(arg0, v1);
        };
    }

    public fun set_dev_weight<T0>(arg0: &signer, arg1: u64) acquires FeeDistributorInfo {
        let v0 = 0x1::signer::address_of(arg0);
        assert!(v0 == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v1 = borrow_global_mut<FeeDistributorInfo<T0>>(v0);
        v1.dev_weight = arg1;
        v1.total_weight = v1.lp_weight + v1.stake_weight + v1.dev_weight;
    }

    public fun set_lp_weight<T0>(arg0: &signer, arg1: u64) acquires FeeDistributorInfo {
        let v0 = 0x1::signer::address_of(arg0);
        assert!(v0 == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v1 = borrow_global_mut<FeeDistributorInfo<T0>>(v0);
        v1.lp_weight = arg1;
        v1.total_weight = v1.lp_weight + v1.stake_weight + v1.dev_weight;
    }

    public fun set_stake_weight<T0>(arg0: &signer, arg1: u64) acquires FeeDistributorInfo {
        let v0 = 0x1::signer::address_of(arg0);
        assert!(v0 == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v1 = borrow_global_mut<FeeDistributorInfo<T0>>(v0);
        v1.stake_weight = arg1;
        v1.total_weight = v1.lp_weight + v1.stake_weight + v1.dev_weight;
    }

    public fun withdraw_fee_dev<T0>(arg0: &signer, arg1: u64) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fa_box::deposit_asset_to_user<T0>(0x1::signer::address_of(arg0), 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::withdraw_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::FeeDevVault, T0>(arg1));
    }

    public(friend) fun withdraw_fee_houselp_all<T0>() : 0x1::coin::Coin<T0> {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::withdraw_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::FeeHouseLPVault, T0>(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::vault_balance<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::FeeHouseLPVault, T0>())
    }

    public fun withdraw_fee_stake<T0>(arg0: &signer, arg1: u64) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fa_box::deposit_asset_to_user<T0>(0x1::signer::address_of(arg0), 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::withdraw_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::FeeStakingVault, T0>(arg1));
    }

    // decompiled from Move bytecode v7
}


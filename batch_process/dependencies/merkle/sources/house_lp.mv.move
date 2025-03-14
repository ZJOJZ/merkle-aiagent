module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp {
    struct DepositEvent has drop, store {
        asset_type: 0x1::type_info::TypeInfo,
        user: address,
        deposit_amount: u64,
        mint_amount: u64,
        deposit_fee: u64,
    }

    struct WithdrawEvent has drop, store {
        asset_type: 0x1::type_info::TypeInfo,
        user: address,
        withdraw_amount: u64,
        burn_amount: u64,
        withdraw_fee: u64,
    }

    struct FeeEvent has drop, store {
        fee_type: u64,
        asset_type: 0x1::type_info::TypeInfo,
        amount: u64,
        amount_sign: bool,
    }

    struct HouseLP<phantom T0> has key {
        deposit_fee: u64,
        withdraw_fee: u64,
        highest_price: u64,
    }

    struct HouseLPConfig<phantom T0> has key {
        mint_capability: 0x1::coin::MintCapability<MKLP<T0>>,
        burn_capability: 0x1::coin::BurnCapability<MKLP<T0>>,
        freeze_capability: 0x1::coin::FreezeCapability<MKLP<T0>>,
        withdraw_division: u64,
        minimum_deposit: u64,
        soft_break: u64,
        hard_break: u64,
    }

    struct HouseLPEvents has key {
        deposit_events: 0x1::event::EventHandle<DepositEvent>,
        withdraw_events: 0x1::event::EventHandle<WithdrawEvent>,
        fee_events: 0x1::event::EventHandle<FeeEvent>,
    }

    struct HouseLPRedeemEvents has key {
        redeem_events: 0x1::event::EventHandle<RedeemEvent>,
        redeem_cancel_events: 0x1::event::EventHandle<RedeemCancelEvent>,
    }

    struct MKLP<phantom T0> {
        dummy_field: bool,
    }

    struct RedeemCancelEvent has drop, store {
        user: address,
        return_amount: u64,
        initial_amount: u64,
        started_at_sec: u64,
    }

    struct RedeemEvent has drop, store {
        user: address,
        asset_type: 0x1::type_info::TypeInfo,
        burn_amount: u64,
        withdraw_amount: u64,
        redeem_amount_left: u64,
        withdraw_fee: u64,
        started_at_sec: u64,
    }

    struct RedeemPlan<phantom T0> has key {
        mklp: 0x1::coin::Coin<MKLP<T0>>,
        started_at: u64,
        redeem_count: u64,
        initial_amount: u64,
        withdraw_amount: u64,
    }

    struct UserWithdrawInfo has key {
        withdraw_limit: u64,
        withdraw_amount: u64,
        last_withdraw_reset_timestamp: u64,
    }

    public fun deposit<T0>(arg0: &signer, arg1: u64) acquires HouseLP, HouseLPConfig, HouseLPEvents {
        let v0 = borrow_global_mut<HouseLPConfig<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = borrow_global_mut<HouseLP<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v2 = 0x1::signer::address_of(arg0);
        assert!(arg1 >= v0.minimum_deposit, 2);
        deposit_trading_fee<T0>(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fee_distributor::withdraw_fee_houselp_all<T0>());
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::deposit_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::HouseLPVault, T0>(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fa_box::get_fa_coin_if_needed<T0>(arg0, arg1));
        if (0x1::coin::is_account_registered<MKLP<T0>>(v2)) {
        } else {
            0x1::coin::register<MKLP<T0>>(arg0);
        };
        let v3 = 0x1::coin::supply<MKLP<T0>>();
        let v4 = (0x1::option::extract<u128>(&mut v3) as u64);
        let v5 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(arg1, v1.deposit_fee, 1000000);
        let v6 = arg1 - v5;
        let v7 = if (v4 == 0) {
            v6
        } else {
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v4, v6, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::vault_balance<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::HouseLPVault, T0>() - v6 + v5)
        };
        assert!(v7 > 0, 2);
        0x1::coin::deposit<MKLP<T0>>(v2, 0x1::coin::mint<MKLP<T0>>(v7, &v0.mint_capability));
        update_highest_price<T0>();
        if (v5 > 0) {
            let v8 = FeeEvent{
                fee_type    : 1,
                asset_type  : 0x1::type_info::type_of<T0>(),
                amount      : v5,
                amount_sign : true,
            };
            0x1::event::emit_event<FeeEvent>(&mut borrow_global_mut<HouseLPEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).fee_events, v8);
        };
        let v9 = DepositEvent{
            asset_type     : 0x1::type_info::type_of<T0>(),
            user           : v2,
            deposit_amount : v6,
            mint_amount    : v7,
            deposit_fee    : v5,
        };
        0x1::event::emit_event<DepositEvent>(&mut borrow_global_mut<HouseLPEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).deposit_events, v9);
    }

    public fun register<T0>(arg0: &signer) {
        let v0 = 0x1::signer::address_of(arg0);
        assert!(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d == v0, 0);
        assert!(0x1::coin::is_coin_initialized<T0>(), 4);
        if (exists<HouseLPConfig<T0>>(v0)) {
        } else {
            let (v1, v2, v3) = 0x1::coin::initialize<MKLP<T0>>(arg0, 0x1::string::utf8(b"Merkle LP"), 0x1::string::utf8(b"MKLP"), 6, true);
            let v4 = HouseLPConfig<T0>{
                mint_capability   : v3,
                burn_capability   : v1,
                freeze_capability : v2,
                withdraw_division : 200000,
                minimum_deposit   : 0,
                soft_break        : 20000,
                hard_break        : 30000,
            };
            move_to<HouseLPConfig<T0>>(arg0, v4);
        };
        if (exists<HouseLP<T0>>(v0)) {
        } else {
            let v5 = HouseLP<T0>{
                deposit_fee   : 0,
                withdraw_fee  : 1000,
                highest_price : 0,
            };
            move_to<HouseLP<T0>>(arg0, v5);
        };
        if (exists<HouseLPEvents>(v0)) {
        } else {
            let v6 = HouseLPEvents{
                deposit_events  : 0x1::account::new_event_handle<DepositEvent>(arg0),
                withdraw_events : 0x1::account::new_event_handle<WithdrawEvent>(arg0),
                fee_events      : 0x1::account::new_event_handle<FeeEvent>(arg0),
            };
            move_to<HouseLPEvents>(arg0, v6);
        };
        if (exists<HouseLPRedeemEvents>(v0)) {
        } else {
            let v7 = HouseLPRedeemEvents{
                redeem_events        : 0x1::account::new_event_handle<RedeemEvent>(arg0),
                redeem_cancel_events : 0x1::account::new_event_handle<RedeemCancelEvent>(arg0),
            };
            move_to<HouseLPRedeemEvents>(arg0, v7);
        };
    }

    public fun withdraw<T0>(arg0: &signer, arg1: u64) {
        abort 1000
    }

    public fun redeem<T0>(arg0: &signer) acquires HouseLP, HouseLPConfig, HouseLPEvents, HouseLPRedeemEvents, RedeemPlan {
        let v0 = borrow_global_mut<RedeemPlan<T0>>(0x1::signer::address_of(arg0));
        assert!((0x1::timestamp::now_seconds() - v0.started_at) / 86400 == v0.redeem_count, 7);
        deposit_trading_fee<T0>(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fee_distributor::withdraw_fee_houselp_all<T0>());
        let v1 = 0x1::coin::extract<MKLP<T0>>(&mut v0.mklp, v0.initial_amount / 5);
        if (v0.redeem_count == 4) {
            0x1::coin::merge<MKLP<T0>>(&mut v1, 0x1::coin::extract_all<MKLP<T0>>(&mut v0.mklp));
        };
        let v2 = 0x1::coin::value<MKLP<T0>>(&v1);
        let v3 = borrow_global_mut<HouseLPConfig<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v4 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::vault_balance<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::HouseLPVault, T0>();
        let v5 = 0x1::coin::supply<MKLP<T0>>();
        let v6 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v4, v2, (0x1::option::extract<u128>(&mut v5) as u64));
        let v7 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v6, borrow_global_mut<HouseLP<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).withdraw_fee, 1000000);
        let v8 = v6 - v7;
        assert!(v4 >= v8, 3);
        let v9 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::withdraw_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::HouseLPVault, T0>(v8);
        let v10 = 0x1::coin::value<T0>(&v9);
        let v11 = &mut v0.withdraw_amount;
        *v11 = *v11 + v10;
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fa_box::deposit_asset_to_user<T0>(0x1::signer::address_of(arg0), v9);
        let v12 = &mut v0.redeem_count;
        *v12 = *v12 + 1;
        0x1::coin::burn<MKLP<T0>>(v1, &v3.burn_capability);
        update_highest_price<T0>();
        let v13 = RedeemEvent{
            user               : 0x1::signer::address_of(arg0),
            asset_type         : 0x1::type_info::type_of<T0>(),
            burn_amount        : v2,
            withdraw_amount    : v10,
            redeem_amount_left : 0x1::coin::value<MKLP<T0>>(&v0.mklp),
            withdraw_fee       : v7,
            started_at_sec     : v0.started_at,
        };
        0x1::event::emit_event<RedeemEvent>(&mut borrow_global_mut<HouseLPRedeemEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).redeem_events, v13);
        if (0x1::coin::value<MKLP<T0>>(&v0.mklp) == 0) {
            drop_redeem_plan<T0>(move_from<RedeemPlan<T0>>(0x1::signer::address_of(arg0)));
        };
    }

    public fun cancel_redeem_plan<T0>(arg0: &signer) acquires HouseLPRedeemEvents, RedeemPlan {
        let v0 = move_from<RedeemPlan<T0>>(0x1::signer::address_of(arg0));
        assert!((0x1::timestamp::now_seconds() - v0.started_at) / 86400 >= v0.redeem_count, 8);
        let v1 = RedeemCancelEvent{
            user           : 0x1::signer::address_of(arg0),
            return_amount  : 0x1::coin::value<MKLP<T0>>(&v0.mklp),
            initial_amount : v0.initial_amount,
            started_at_sec : v0.started_at,
        };
        0x1::event::emit_event<RedeemCancelEvent>(&mut borrow_global_mut<HouseLPRedeemEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).redeem_cancel_events, v1);
        if (0x1::coin::value<MKLP<T0>>(&v0.mklp) > 0) {
            0x1::aptos_account::deposit_coins<MKLP<T0>>(0x1::signer::address_of(arg0), 0x1::coin::extract_all<MKLP<T0>>(&mut v0.mklp));
        };
        drop_redeem_plan<T0>(v0);
    }

    public fun check_hard_break_exceeded<T0>() : bool acquires HouseLP, HouseLPConfig {
        let v0 = get_mdd<T0>();
        v0 > borrow_global_mut<HouseLPConfig<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).hard_break
    }

    public fun check_soft_break_exceeded<T0>() : bool acquires HouseLP, HouseLPConfig {
        let v0 = get_mdd<T0>();
        v0 > borrow_global_mut<HouseLPConfig<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).soft_break
    }

    public fun convert_mklp_type<T0, T1>(arg0: &signer, arg1: u64) acquires HouseLP, HouseLPConfig, HouseLPEvents {
        assert!(arg1 > 0, 2);
        let v0 = borrow_global_mut<HouseLPConfig<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::vault_balance<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::HouseLPVault, T0>();
        let v2 = 0x1::coin::supply<MKLP<T0>>();
        let v3 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v1, arg1, (0x1::option::extract<u128>(&mut v2) as u64));
        assert!(v1 >= v3, 3);
        let v4 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::withdraw_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::HouseLPVault, T0>(v3);
        let v5 = 0x1::coin::value<T0>(&v4);
        assert!(0xcf93155bab72399a4f9e9b673621e22ca300f54ebea2a98febc55d17f04aac57::redemption_tools::native_balance<T0>() >= v5, 7);
        0x1::coin::deposit<T0>(0x1::signer::address_of(arg0), v4);
        let v6 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fa_box::get_paired_metadata<T1>();
        0xcf93155bab72399a4f9e9b673621e22ca300f54ebea2a98febc55d17f04aac57::redemption_tools::redeem<T0>(arg0, v5);
        0x1::coin::burn<MKLP<T0>>(0x1::coin::withdraw<MKLP<T0>>(arg0, arg1), &v0.burn_capability);
        update_highest_price<T0>();
        deposit<T1>(arg0, 0x1::primary_fungible_store::balance<0x1::fungible_asset::Metadata>(0x1::signer::address_of(arg0), v6) - 0x1::primary_fungible_store::balance<0x1::fungible_asset::Metadata>(0x1::signer::address_of(arg0), v6));
    }

    fun deposit_trading_fee<T0>(arg0: 0x1::coin::Coin<T0>) acquires HouseLPEvents {
        if (0x1::coin::value<T0>(&arg0) > 0) {
            let v0 = FeeEvent{
                fee_type    : 4,
                asset_type  : 0x1::type_info::type_of<T0>(),
                amount      : 0x1::coin::value<T0>(&arg0),
                amount_sign : true,
            };
            0x1::event::emit_event<FeeEvent>(&mut borrow_global_mut<HouseLPEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).fee_events, v0);
        };
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::deposit_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::HouseLPVault, T0>(arg0);
    }

    public fun deposit_without_mint<T0>(arg0: &signer, arg1: u64) acquires HouseLP, HouseLPEvents {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::deposit_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::HouseLPVault, T0>(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fa_box::get_fa_coin_if_needed<T0>(arg0, arg1));
        update_highest_price<T0>();
        let v0 = DepositEvent{
            asset_type     : 0x1::type_info::type_of<T0>(),
            user           : 0x1::signer::address_of(arg0),
            deposit_amount : arg1,
            mint_amount    : 0,
            deposit_fee    : 0,
        };
        0x1::event::emit_event<DepositEvent>(&mut borrow_global_mut<HouseLPEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).deposit_events, v0);
    }

    public fun drop_redeem_plan<T0>(arg0: RedeemPlan<T0>) {
        let RedeemPlan<T0> {
            mklp            : v0,
            started_at      : _,
            redeem_count    : _,
            initial_amount  : _,
            withdraw_amount : _,
        } = arg0;
        0x1::coin::destroy_zero<MKLP<T0>>(v0);
    }

    fun get_mdd<T0>() : u64 acquires HouseLP {
        let v0 = 0x1::coin::supply<MKLP<T0>>();
        if ((0x1::option::extract<u128>(&mut v0) as u64) == 0) {
            return 0
        };
        let v1 = 0x1::coin::supply<MKLP<T0>>();
        let v2 = borrow_global_mut<HouseLP<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (v2.highest_price == 0) {
            return 100000
        };
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v2.highest_price - 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::vault_balance<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::HouseLPVault, T0>(), 1000000, (0x1::option::extract<u128>(&mut v1) as u64)), 100000, v2.highest_price)
    }

    public(friend) fun pnl_deposit_to_lp<T0>(arg0: 0x1::coin::Coin<T0>) acquires HouseLP, HouseLPConfig, HouseLPEvents {
        deposit_trading_fee<T0>(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fee_distributor::withdraw_fee_houselp_all<T0>());
        let v0 = 0x1::coin::value<T0>(&arg0);
        if (v0 > 0) {
            let v1 = FeeEvent{
                fee_type    : 3,
                asset_type  : 0x1::type_info::type_of<T0>(),
                amount      : v0,
                amount_sign : true,
            };
            0x1::event::emit_event<FeeEvent>(&mut borrow_global_mut<HouseLPEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).fee_events, v1);
        };
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::deposit_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::HouseLPVault, T0>(arg0);
        update_highest_price<T0>();
        if (check_hard_break_exceeded<T0>()) {
            abort 5
        };
    }

    public(friend) fun pnl_withdraw_from_lp<T0>(arg0: u64) : 0x1::coin::Coin<T0> acquires HouseLP, HouseLPConfig, HouseLPEvents {
        deposit_trading_fee<T0>(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fee_distributor::withdraw_fee_houselp_all<T0>());
        if (arg0 > 0) {
            let v0 = FeeEvent{
                fee_type    : 3,
                asset_type  : 0x1::type_info::type_of<T0>(),
                amount      : arg0,
                amount_sign : false,
            };
            0x1::event::emit_event<FeeEvent>(&mut borrow_global_mut<HouseLPEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).fee_events, v0);
        };
        update_highest_price<T0>();
        if (check_hard_break_exceeded<T0>()) {
            abort 5
        };
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::withdraw_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::HouseLPVault, T0>(arg0)
    }

    public fun register_redeem_plan<T0>(arg0: &signer, arg1: u64) {
        assert!(arg1 >= 100000, 9);
        let v0 = RedeemPlan<T0>{
            mklp            : 0x1::coin::withdraw<MKLP<T0>>(arg0, arg1),
            started_at      : 0x1::timestamp::now_seconds(),
            redeem_count    : 0,
            initial_amount  : arg1,
            withdraw_amount : 0,
        };
        move_to<RedeemPlan<T0>>(arg0, v0);
    }

    public fun set_house_lp_deposit_fee<T0>(arg0: &signer, arg1: u64) acquires HouseLP {
        assert!(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d == 0x1::signer::address_of(arg0), 0);
        borrow_global_mut<HouseLP<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).deposit_fee = arg1;
    }

    public fun set_house_lp_hard_break<T0>(arg0: &signer, arg1: u64) acquires HouseLPConfig {
        assert!(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d == 0x1::signer::address_of(arg0), 0);
        borrow_global_mut<HouseLPConfig<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).hard_break = arg1;
    }

    public fun set_house_lp_minimum_deposit<T0>(arg0: &signer, arg1: u64) acquires HouseLPConfig {
        assert!(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d == 0x1::signer::address_of(arg0), 0);
        borrow_global_mut<HouseLPConfig<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).minimum_deposit = arg1;
    }

    public fun set_house_lp_soft_break<T0>(arg0: &signer, arg1: u64) acquires HouseLPConfig {
        assert!(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d == 0x1::signer::address_of(arg0), 0);
        borrow_global_mut<HouseLPConfig<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).soft_break = arg1;
    }

    public fun set_house_lp_withdraw_division<T0>(arg0: &signer, arg1: u64) acquires HouseLPConfig {
        assert!(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d == 0x1::signer::address_of(arg0), 0);
        borrow_global_mut<HouseLPConfig<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).withdraw_division = arg1;
    }

    public fun set_house_lp_withdraw_fee<T0>(arg0: &signer, arg1: u64) acquires HouseLP {
        assert!(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d == 0x1::signer::address_of(arg0), 0);
        borrow_global_mut<HouseLP<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).withdraw_fee = arg1;
    }

    fun update_highest_price<T0>() acquires HouseLP {
        let v0 = 0x1::coin::supply<MKLP<T0>>();
        let v1 = (0x1::option::extract<u128>(&mut v0) as u64);
        if (v1 == 0) {
            return
        };
        let v2 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::vault_balance<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::HouseLPVault, T0>(), 1000000, v1);
        let v3 = borrow_global_mut<HouseLP<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (v2 > v3.highest_price) {
            v3.highest_price = v2;
        };
    }

    // decompiled from Move bytecode v7
}


module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading {
    struct Position has store {
        uid: u64,
        size: u64,
        collateral: u64,
        avg_price: u64,
        last_execute_timestamp: u64,
        acc_rollover_fee_per_collateral: u64,
        acc_funding_fee_per_size: u64,
        acc_funding_fee_per_size_positive: bool,
        stop_loss_trigger_price: u64,
        take_profit_trigger_price: u64,
    }
    
    struct AdminCapability<phantom T0, phantom T1> has copy, drop, store {
        dummy_field: bool,
    }
    
    struct CapabilityProvider has copy, drop, store {
        dummy_field: bool,
    }
    
    struct AdminCapabilityV2 has copy, drop, store {
        dummy_field: bool,
    }
    
    struct CancelOrderEvent has copy, drop, store {
        uid: u64,
        event_type: u64,
        pair_type: 0x1::type_info::TypeInfo,
        collateral_type: 0x1::type_info::TypeInfo,
        user: address,
        order_id: u64,
        size_delta: u64,
        collateral_delta: u64,
        price: u64,
        is_long: bool,
        is_increase: bool,
        is_market: bool,
    }
    
    struct ExecuteCapability<phantom T0, phantom T1> has copy, drop, store {
        dummy_field: bool,
    }
    
    struct ExecuteCapabilityV2<phantom T0> has copy, drop, store {
        dummy_field: bool,
    }
    
    struct ExecuteCapabilityV3 has copy, drop, store {
        dummy_field: bool,
    }
    
    struct Order has copy, store {
        uid: u64,
        user: address,
        size_delta: u64,
        collateral_delta: u64,
        price: u64,
        is_long: bool,
        is_increase: bool,
        is_market: bool,
        can_execute_above_price: bool,
        stop_loss_trigger_price: u64,
        take_profit_trigger_price: u64,
        created_timestamp: u64,
    }
    
    struct OrderKey has copy, drop, store {
        pair_type: 0x1::type_info::TypeInfo,
        collateral_type: 0x1::type_info::TypeInfo,
        order_id: u64,
    }
    
    struct PairInfo<phantom T0, phantom T1> has key {
        paused: bool,
        min_leverage: u64,
        max_leverage: u64,
        maker_fee: u64,
        taker_fee: u64,
        rollover_fee_per_timestamp: u64,
        skew_factor: u64,
        max_funding_velocity: u64,
        max_open_interest: u64,
        market_depth_above: u64,
        market_depth_below: u64,
        execute_time_limit: u64,
        liquidate_threshold: u64,
        maximum_profit: u64,
        minimum_order_collateral: u64,
        minimum_position_collateral: u64,
        minimum_position_size: u64,
        maximum_position_collateral: u64,
        execution_fee: u64,
    }
    
    struct PairInfoV2<phantom T0, phantom T1> has key {
        params: 0x1::simple_map::SimpleMap<0x1::string::String, vector<u8>>,
    }
    
    struct PairState<phantom T0, phantom T1> has key {
        next_order_id: u64,
        long_open_interest: u64,
        short_open_interest: u64,
        funding_rate: u64,
        funding_rate_positive: bool,
        acc_funding_fee_per_size: u64,
        acc_funding_fee_per_size_positive: bool,
        acc_rollover_fee_per_collateral: u64,
        last_accrue_timestamp: u64,
        orders: 0x1::table::Table<u64, Order>,
        long_positions: 0x1::table::Table<address, Position>,
        short_positions: 0x1::table::Table<address, Position>,
    }
    
    struct PlaceOrderEvent has copy, drop, store {
        uid: u64,
        pair_type: 0x1::type_info::TypeInfo,
        collateral_type: 0x1::type_info::TypeInfo,
        user: address,
        order_id: u64,
        size_delta: u64,
        collateral_delta: u64,
        price: u64,
        is_long: bool,
        is_increase: bool,
        is_market: bool,
    }
    
    struct PositionEvent has copy, drop, store {
        uid: u64,
        event_type: u64,
        pair_type: 0x1::type_info::TypeInfo,
        collateral_type: 0x1::type_info::TypeInfo,
        user: address,
        order_id: u64,
        is_long: bool,
        price: u64,
        original_size: u64,
        size_delta: u64,
        original_collateral: u64,
        collateral_delta: u64,
        is_increase: bool,
        is_partial: bool,
        pnl_without_fee: u64,
        is_profit: bool,
        entry_exit_fee: u64,
        funding_fee: u64,
        is_funding_fee_profit: bool,
        rollover_fee: u64,
        long_open_interest: u64,
        short_open_interest: u64,
    }
    
    struct TradingEvents has key {
        uid_sequence: u64,
        place_order_events: 0x1::event::EventHandle<PlaceOrderEvent>,
        cancel_order_events: 0x1::event::EventHandle<CancelOrderEvent>,
        position_events: 0x1::event::EventHandle<PositionEvent>,
        update_tp_sl_events: 0x1::event::EventHandle<UpdateTPSLEvent>,
    }
    
    struct UpdateTPSLEvent has drop, store {
        uid: u64,
        pair_type: 0x1::type_info::TypeInfo,
        collateral_type: 0x1::type_info::TypeInfo,
        user: address,
        is_long: bool,
        take_profit_trigger_price: u64,
        stop_loss_trigger_price: u64,
    }
    
    struct UserPositionKey has copy, drop, store {
        pair_type: 0x1::type_info::TypeInfo,
        collateral_type: 0x1::type_info::TypeInfo,
        is_long: bool,
    }
    
    struct UserStates has key {
        order_keys: vector<OrderKey>,
        user_position_keys: vector<UserPositionKey>,
    }
    
    struct UserTradingEvents has key {
        place_order_events: 0x1::event::EventHandle<PlaceOrderEvent>,
        cancel_order_events: 0x1::event::EventHandle<CancelOrderEvent>,
        position_events: 0x1::event::EventHandle<PositionEvent>,
        update_tp_sl_events: 0x1::event::EventHandle<UpdateTPSLEvent>,
    }
    
    fun accrue<T0, T1>(arg0: &PairInfo<T0, T1>, arg1: &mut PairState<T0, T1>) {
        let v0 = 0x1::timestamp::now_seconds();
        let (v1, v2) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_funding_rate(arg1.funding_rate, arg1.funding_rate_positive, arg1.long_open_interest, arg1.short_open_interest, arg0.skew_factor, arg0.max_funding_velocity, v0 - arg1.last_accrue_timestamp);
        let (v3, v4) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_funding_fee_per_size(arg1.acc_funding_fee_per_size, arg1.acc_funding_fee_per_size_positive, arg1.funding_rate, arg1.funding_rate_positive, v1, v2, v0 - arg1.last_accrue_timestamp);
        arg1.acc_rollover_fee_per_collateral = arg1.acc_rollover_fee_per_collateral + 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_rollover_fee_delta(arg1.last_accrue_timestamp, 0x1::timestamp::now_seconds(), arg0.rollover_fee_per_timestamp);
        arg1.acc_funding_fee_per_size = v3;
        arg1.acc_funding_fee_per_size_positive = v4;
        arg1.funding_rate = v1;
        arg1.funding_rate_positive = v2;
        arg1.last_accrue_timestamp = v0;
    }
    
    // fun add_position_key_to_user_states(arg0: address, arg1: 0x1::type_info::TypeInfo, arg2: 0x1::type_info::TypeInfo, arg3: bool) acquires UserStates {
    //     let v0 = borrow_global_mut<UserStates>(arg0);
    //     let v1 = UserPositionKey{
    //         pair_type       : arg1, 
    //         collateral_type : arg2, 
    //         is_long         : arg3,
    //     };
    //     let (v2, _) = 0x1::vector::index_of<UserPositionKey>(&v0.user_position_keys, &v1);
    //     if (v2) {
    //     } else {
    //         0x1::vector::push_back<UserPositionKey>(&mut v0.user_position_keys, v1);
    //     };
    // }
    
    // public fun cancel_order<T0, T1>(arg0: &signer, arg1: u64) acquires PairInfo, PairState, TradingEvents, UserStates, UserTradingEvents {
    //     cancel_order_v3<T0, T1>(arg0, 0x1::signer::address_of(arg0), arg1);
    // }
    
    // fun cancel_order_internal<T0, T1>(arg0: u64, arg1: Order, arg2: u64) acquires TradingEvents, UserStates, UserTradingEvents {
    //     if (arg1.is_increase) {
    //         if (0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::delegate_account::is_active<T1>(arg1.user)) {
    //             0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::delegate_account::deposit_from_trading<T1>(arg1.user, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::withdraw_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::CollateralVault, T1>(arg1.collateral_delta));
    //         } else {
    //             0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fa_box::deposit_asset_to_user<T1>(arg1.user, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::withdraw_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::CollateralVault, T1>(arg1.collateral_delta));
    //         };
    //     };
    //     let v0 = CancelOrderEvent{
    //         uid              : 0, 
    //         event_type       : arg2, 
    //         pair_type        : 0x1::type_info::type_of<T0>(), 
    //         collateral_type  : 0x1::type_info::type_of<T1>(), 
    //         user             : arg1.user, 
    //         order_id         : arg0, 
    //         size_delta       : arg1.size_delta, 
    //         collateral_delta : arg1.collateral_delta, 
    //         price            : arg1.price, 
    //         is_long          : arg1.is_long, 
    //         is_increase      : arg1.is_increase, 
    //         is_market        : arg1.is_market,
    //     };
    //     0x1::event::emit_event<CancelOrderEvent>(&mut borrow_global_mut<TradingEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).cancel_order_events, v0);
    //     0x1::event::emit_event<CancelOrderEvent>(&mut borrow_global_mut<UserTradingEvents>(arg1.user).cancel_order_events, v0);
    //     remove_order_id_from_user_states(arg1.user, 0x1::type_info::type_of<T0>(), 0x1::type_info::type_of<T1>(), arg0);
    //     drop_order(arg1);
    // }
    
    // public fun cancel_order_v3<T0, T1>(arg0: &signer, arg1: address, arg2: u64) acquires PairInfo, PairState, TradingEvents, UserStates, UserTradingEvents {
    //     assert!(0x1::signer::address_of(arg0) == arg1 || 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::delegate_account::is_registered<T1>(arg1, 0x1::signer::address_of(arg0)), 31);
    //     if (borrow_global<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).paused) {
    //         abort 16
    //     };
    //     let v0 = borrow_global_mut<PairState<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
    //     assert!(0x1::table::contains<u64, Order>(&mut v0.orders, arg2), 6);
    //     let v1 = 0x1::table::remove<u64, Order>(&mut v0.orders, arg2);
    //     assert!(v1.user == arg1, 1);
    //     cancel_order_internal<T0, T1>(arg2, v1, 0);
    // }
    
    // fun drop_order(arg0: Order) {
    //     let Order {
    //         uid                       : _,
    //         user                      : _,
    //         size_delta                : _,
    //         collateral_delta          : _,
    //         price                     : _,
    //         is_long                   : _,
    //         is_increase               : _,
    //         is_market                 : _,
    //         can_execute_above_price   : _,
    //         stop_loss_trigger_price   : _,
    //         take_profit_trigger_price : _,
    //         created_timestamp         : _,
    //     } = arg0;
    // }
    
    // // fun execute_decrease_order_internal<T0, T1>(arg0: &PairInfo<T0, T1>, arg1: &mut PairState<T0, T1>, arg2: u64, arg3: u64, arg4: Order) acquires PairInfoV2, TradingEvents, UserStates, UserTradingEvents {
    // //     if (arg4.is_increase) {
    // //         abort 13
    // //     };
    // //     if (arg4.price != arg2 && arg4.can_execute_above_price != arg4.price < arg2) {
    // //         assert!(arg4.is_market, 14);
    // //         cancel_order_internal<T0, T1>(arg3, arg4, 3);
    // //         return
    // //     };
    // //     let v0 = if (arg4.is_long) {
    // //         &mut arg1.long_positions
    // //     } else {
    // //         &mut arg1.short_positions
    // //     };
    // //     assert!(0x1::table::contains<address, Position>(v0, arg4.user), 15);
    // //     let v1 = 0x1::table::borrow_mut<address, Position>(v0, arg4.user);
    // //     if (v1.size < arg4.size_delta) {
    // //         cancel_order_internal<T0, T1>(arg3, arg4, 5);
    // //         return
    // //     };
    // //     let v2 = v1.size;
    // //     let v3 = v2 == arg4.size_delta;
    // //     let (v4, v5, v6, v7, v8) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_risk_fees(arg1.acc_rollover_fee_per_collateral, arg1.acc_funding_fee_per_size, arg1.acc_funding_fee_per_size_positive, v1.size, v1.collateral, arg4.is_long, v1.acc_rollover_fee_per_collateral, v1.acc_funding_fee_per_size, v1.acc_funding_fee_per_size_positive);
    // //     let v9 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_maker_taker_fee(arg1.long_open_interest, arg1.short_open_interest, arg0.maker_fee, arg0.taker_fee, arg4.size_delta, arg4.is_long, arg4.is_increase);
    // //     let v10 = v9 - 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v9, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::get_fee_discount_effect<T0>(arg4.user, true), 1000000);
    // //     let v11 = v10;
    // //     let (v12, v13) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_pnl_without_fee(v1.avg_price, arg2, arg4.size_delta, arg4.is_long);
    // //     let v14 = v12;
    // //     let v15 = get_params_u64_value<T0, T1>(b"cooldown_period_second", 0);
    // //     if (v13 && 0x1::timestamp::now_seconds() - v1.last_execute_timestamp < v15) {
    // //         v14 = 0;
    // //     };
    // //     let v16 = if (v3) {
    // //         v1.collateral
    // //     } else {
    // //         arg4.collateral_delta
    // //     };
    // //     let v17 = v1.collateral;
    // //     let (v18, v19) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_settle_amount(v14, v13, v8, v7);
    // //     if (v13) {
    // //         v14 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::min(v14, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v1.collateral, arg0.maximum_profit, 10000));
    // //     } else {
    // //         v14 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::min(v14, v1.collateral);
    // //     };
    // //     let v20 = if (v19) {
    // //         0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::min(v18, v17)
    // //     } else {
    // //         0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::min(v18, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v1.collateral, arg0.maximum_profit, 10000))
    // //     };
    // //     let (v21, v22) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_partial_close_amounts(v16, v20, v19, v10);
    // //     let v23 = 0;
    // //     if (v3) {
    // //         if (v1.collateral < v22) {
    // //             let v24 = v22 - v1.collateral;
    // //             if (v24 < v10) {
    // //                 v11 = v10 - v24;
    // //             } else {
    // //                 v11 = 0;
    // //             };
    // //         };
    // //     } else {
    // //         let v25 = 0;
    // //         if (v22 < v1.collateral) {
    // //             let v26 = v1.collateral - v22;
    // //             v23 = v26;
    // //             v25 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v1.size - arg4.size_delta, 1000000, v26);
    // //         };
    // //         if (v23 == 0 || v25 < arg0.min_leverage - 100000 || v25 > arg0.max_leverage + 100000) {
    // //             /* goto 59 */
    // //         };
    // //     };
    // //     0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fee_distributor::deposit_fee_with_rebate<T1>(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::withdraw_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::CollateralVault, T1>(v11), arg4.user);
    // //     0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pMKL::mint_pmkl(arg4.user, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_pmkl_amount(arg4.size_delta, arg0.maker_fee, arg0.taker_fee, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::get_pmkl_boost_effect<T0>(arg4.user, true)));
    // //     0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::profile::increase_xp<T0>(arg4.user, v9 * 100);
    // //     if (v19) {
    // //         0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::pnl_deposit_to_lp<T1>(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::withdraw_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::CollateralVault, T1>(v20));
    // //     } else {
    // //         0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::deposit_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::CollateralVault, T1>(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::pnl_withdraw_from_lp<T1>(v20));
    // //     };
    // //     if (v21 > 0) {
    // //         if (0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::delegate_account::is_active<T1>(arg4.user)) {
    // //             0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::delegate_account::deposit_from_trading<T1>(arg4.user, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::withdraw_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::CollateralVault, T1>(v21));
    // //         } else {
    // //             0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fa_box::deposit_asset_to_user<T1>(arg4.user, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::withdraw_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::CollateralVault, T1>(v21));
    // //         };
    // //     };
    // //     v1.acc_rollover_fee_per_collateral = arg1.acc_rollover_fee_per_collateral;
    // //     v1.size = v1.size - arg4.size_delta;
    // //     v1.collateral = v23;
    // //     v1.acc_funding_fee_per_size = arg1.acc_funding_fee_per_size;
    // //     v1.acc_funding_fee_per_size_positive = arg1.acc_funding_fee_per_size_positive;
    // //     if (arg4.is_long) {
    // //         arg1.long_open_interest = arg1.long_open_interest - arg4.size_delta;
    // //     } else {
    // //         arg1.short_open_interest = arg1.short_open_interest - arg4.size_delta;
    // //     };
    // //     let v27 = if (v3) {
    // //         2
    // //     } else {
    // //         1
    // //     };
    // //     let v28 = PositionEvent{
    // //         uid                   : v1.uid, 
    // //         event_type            : v27, 
    // //         pair_type             : 0x1::type_info::type_of<T0>(), 
    // //         collateral_type       : 0x1::type_info::type_of<T1>(), 
    // //         user                  : arg4.user, 
    // //         order_id              : arg3, 
    // //         is_long               : arg4.is_long, 
    // //         price                 : arg2, 
    // //         original_size         : v2, 
    // //         size_delta            : arg4.size_delta, 
    // //         original_collateral   : v17, 
    // //         collateral_delta      : v16, 
    // //         is_increase           : false, 
    // //         is_partial            : v1.size != 0, 
    // //         pnl_without_fee       : v14, 
    // //         is_profit             : v13, 
    // //         entry_exit_fee        : v11, 
    // //         funding_fee           : v6, 
    // //         is_funding_fee_profit : v5, 
    // //         rollover_fee          : v4, 
    // //         long_open_interest    : arg1.long_open_interest, 
    // //         short_open_interest   : arg1.short_open_interest,
    // //     };
    // //     0x1::event::emit_event<PositionEvent>(&mut borrow_global_mut<TradingEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).position_events, v28);
    // //     0x1::event::emit_event<PositionEvent>(&mut borrow_global_mut<UserTradingEvents>(arg4.user).position_events, v28);
    // //     if (v1.size == 0) {
    // //         remove_position_key_from_user_states(arg4.user, 0x1::type_info::type_of<T0>(), 0x1::type_info::type_of<T1>(), arg4.is_long);
    // //     };
    // //     remove_order_id_from_user_states(arg4.user, 0x1::type_info::type_of<T0>(), 0x1::type_info::type_of<T1>(), arg3);
    // //     drop_order(arg4);
    // //     return
    // //     /* label 59 */
    // //     // let v29 = 4;
    // //     // if (((/*raw:*//*undefined:28*/undefined)) < arg0.min_leverage - 100000) {
    // //     //     v29 = 2;
    // //     // } else {
    // //     //     if (((/*raw:*//*undefined:28*/undefined)) > arg0.max_leverage + 100000) {
    // //     //         v29 = 1;
    // //     //     };
    // //     // };
    // //     // cancel_order_internal<T0, T1>(arg3, arg4, v29);
    // // }
    
    // public fun execute_exit_position<T0, T1>(arg0: &signer, arg1: address, arg2: bool, arg3: u64, arg4: vector<u8>, arg5: &ExecuteCapability<T0, T1>) acquires PairInfo, PairInfoV2, PairState, TradingEvents, UserStates, UserTradingEvents {
    //     execute_exit_position_internal<T0, T1>(arg0, arg1, arg2, arg3, arg4);
    // }
    
    // fun execute_exit_position_internal<T0, T1>(arg0: &signer, arg1: address, arg2: bool, arg3: u64, arg4: vector<u8>) acquires PairInfo, PairInfoV2, PairState, TradingEvents, UserStates, UserTradingEvents {
    //     let v0 = borrow_global<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
    //     if (v0.paused) {
    //         abort 16
    //     };
    //     let v1 = borrow_global_mut<PairState<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
    //     accrue<T0, T1>(v0, v1);
    //     0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::update<T0>(arg0, arg3, arg4);
    //     let v2 = if (arg2) {
    //         &mut v1.long_positions
    //     } else {
    //         &mut v1.short_positions
    //     };
    //     assert!(0x1::table::contains<address, Position>(v2, arg1), 15);
    //     let v3 = 0x1::table::borrow_mut<address, Position>(v2, arg1);
    //     let v4 = v3.size;
    //     let v5 = v3.collateral;
    //     let v6 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_price_impact(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::read<T0>(!arg2), v3.size, arg2, false, v1.long_open_interest, v1.short_open_interest, v0.skew_factor);
    //     let (v7, v8, v9, v10, v11) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_risk_fees(v1.acc_rollover_fee_per_collateral, v1.acc_funding_fee_per_size, v1.acc_funding_fee_per_size_positive, v3.size, v3.collateral, arg2, v3.acc_rollover_fee_per_collateral, v3.acc_funding_fee_per_size, v3.acc_funding_fee_per_size_positive);
    //     let v12 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_maker_taker_fee(v1.long_open_interest, v1.short_open_interest, v0.maker_fee, v0.taker_fee, v3.size, arg2, false);
    //     let v13 = false;
    //     let (v14, v15) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_pnl_without_fee(v3.avg_price, v6, v4, arg2);
    //     let (v16, v17) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_settle_amount(v14, v15, v11, v10);
    //     let v18 = v16;
    //     let v19 = if (v15) {
    //         0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::min(v14, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v3.collateral, v0.maximum_profit, 10000))
    //     } else {
    //         0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::min(v14, v3.collateral)
    //     };
    //     if (v17) {
    //         let v20 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::min(v16, v3.collateral);
    //         v3.collateral = v3.collateral - v20;
    //         0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::pnl_deposit_to_lp<T1>(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::withdraw_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::CollateralVault, T1>(v20));
    //     } else {
    //         if (v16 > 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v3.collateral, v0.maximum_profit, 10000)) {
    //             v13 = true;
    //             v18 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v3.collateral, v0.maximum_profit, 10000);
    //         };
    //         v3.collateral = v3.collateral + v18;
    //         0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::deposit_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::CollateralVault, T1>(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::pnl_withdraw_from_lp<T1>(v18));
    //     };
    //     let v21 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::min(v12 - 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v12, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::get_fee_discount_effect<T0>(arg1, true), 1000000), v3.collateral);
    //     v3.collateral = v3.collateral - v21;
    //     0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fee_distributor::deposit_fee_with_rebate<T1>(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::withdraw_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::CollateralVault, T1>(v21), arg1);
    //     let v22 = 3;
    //     let v23 = false;
    //     let v24;
    //     if (v3.collateral <= 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v5, v0.liquidate_threshold, 10000)) {
    //         v23 = true;
    //     } else {
    //         if (arg2) {
    //             v24 = v3.take_profit_trigger_price <= v6;
    //         } else {
    //             v24 = false;
    //         };
    //         let v25 = if (v24) {
    //             true
    //         } else {
    //             if (arg2) {
    //                 false
    //             } else {
    //                 v3.take_profit_trigger_price >= v6
    //             }
    //         };
    //         if (v25 || v13) {
    //             v23 = true;
    //             v22 = 4;
    //         } else {
    //             let v26 = if (arg2 && v3.stop_loss_trigger_price >= v6) {
    //                 true
    //             } else {
    //                 if (arg2) {
    //                     false
    //                 } else {
    //                     v3.stop_loss_trigger_price <= v6
    //                 }
    //             };
    //             if (v26) {
    //                 v23 = true;
    //                 v22 = 5;
    //             };
    //         };
    //     };
    //     let v27 = get_params_u64_value<T0, T1>(b"cooldown_period_second", 0);
    //     if (v15) {
    //         v24 = 0x1::timestamp::now_seconds() - v3.last_execute_timestamp < v27;
    //     } else {
    //         v24 = false;
    //     };
    //     if (v24) {
    //         v23 = false;
    //     };
    //     let v28 = get_params_u64_value<T0, T1>(b"deprecated_pair_collateral", 0);
    //     if (v28 == 1) {
    //         v23 = true;
    //     };
    //     if (0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::adl_target::is_target<T0>(arg1, arg2)) {
    //         0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::adl_target::remove_target<T0>(arg1, arg2);
    //         v23 = true;
    //     };
    //     assert!(v23, 19);
    //     0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pMKL::mint_pmkl(arg1, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_pmkl_amount(v3.size, v0.maker_fee, v0.taker_fee, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::get_pmkl_boost_effect<T0>(arg1, true)));
    //     0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::profile::increase_xp<T0>(arg1, v12 * 100);
    //     if (v3.collateral > 0) {
    //         if (0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::delegate_account::is_active<T1>(arg1)) {
    //             0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::delegate_account::deposit_from_trading<T1>(arg1, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::withdraw_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::CollateralVault, T1>(v3.collateral));
    //         } else {
    //             0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fa_box::deposit_asset_to_user<T1>(arg1, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::withdraw_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::CollateralVault, T1>(v3.collateral));
    //         };
    //     };
    //     v3.size = 0;
    //     v3.collateral = 0;
    //     v3.avg_price = 0;
    //     if (arg2) {
    //         v1.long_open_interest = v1.long_open_interest - v4;
    //     } else {
    //         v1.short_open_interest = v1.short_open_interest - v4;
    //     };
    //     let v29 = PositionEvent{
    //         uid                   : v3.uid, 
    //         event_type            : v22, 
    //         pair_type             : 0x1::type_info::type_of<T0>(), 
    //         collateral_type       : 0x1::type_info::type_of<T1>(), 
    //         user                  : arg1, 
    //         order_id              : 0, 
    //         is_long               : arg2, 
    //         price                 : v6, 
    //         original_size         : v4, 
    //         size_delta            : v4, 
    //         original_collateral   : v5, 
    //         collateral_delta      : v5, 
    //         is_increase           : false, 
    //         is_partial            : false, 
    //         pnl_without_fee       : v19, 
    //         is_profit             : v15, 
    //         entry_exit_fee        : v21, 
    //         funding_fee           : v9, 
    //         is_funding_fee_profit : v8, 
    //         rollover_fee          : v7, 
    //         long_open_interest    : v1.long_open_interest, 
    //         short_open_interest   : v1.short_open_interest,
    //     };
    //     0x1::event::emit_event<PositionEvent>(&mut borrow_global_mut<TradingEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).position_events, v29);
    //     0x1::event::emit_event<PositionEvent>(&mut borrow_global_mut<UserTradingEvents>(arg1).position_events, v29);
    //     remove_position_key_from_user_states(arg1, 0x1::type_info::type_of<T0>(), 0x1::type_info::type_of<T1>(), arg2);
    // }
    
    // public fun execute_exit_position_v2<T0, T1>(arg0: &signer, arg1: address, arg2: bool, arg3: u64, arg4: vector<u8>, arg5: &ExecuteCapabilityV2<T1>) acquires PairInfo, PairInfoV2, PairState, TradingEvents, UserStates, UserTradingEvents {
    //     execute_exit_position_internal<T0, T1>(arg0, arg1, arg2, arg3, arg4);
    // }
    
    // public fun execute_exit_position_v3<T0, T1>(arg0: &signer, arg1: address, arg2: bool, arg3: u64, arg4: vector<u8>, arg5: &ExecuteCapabilityV3) acquires PairInfo, PairInfoV2, PairState, TradingEvents, UserStates, UserTradingEvents {
    //     execute_exit_position_internal<T0, T1>(arg0, arg1, arg2, arg3, arg4);
    // }
    
    // fun execute_increase_order_internal<T0, T1>(arg0: &PairInfo<T0, T1>, arg1: &mut PairState<T0, T1>, arg2: u64, arg3: u64, arg4: Order) acquires PairInfoV2, TradingEvents, UserStates, UserTradingEvents {
    //     assert!(arg4.is_increase, 13);
    //     if (arg4.price != arg2 && arg4.size_delta > 0 && arg4.can_execute_above_price != arg4.price < arg2) {
    //         assert!(arg4.is_market, 14);
    //         cancel_order_internal<T0, T1>(arg3, arg4, 3);
    //         return
    //     };
    //     let v0 = if (arg4.is_long) {
    //         arg1.long_open_interest
    //     } else {
    //         arg1.short_open_interest
    //     };
    //     let v1 = arg4.size_delta + v0;
    //     let v2 = get_params_u64_value<T0, T1>(b"maximum_skew_limit", 18446744073709551615);
    //     let v3 = if (arg4.is_long) {
    //         arg1.short_open_interest
    //     } else {
    //         arg1.long_open_interest
    //     };
    //     let v4 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::diff(v1, v3);
    //     let v5;
    //     let v6 = if (v1 > arg0.max_open_interest) {
    //         true
    //     } else {
    //         if (v4 > v2) {
    //             v5 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::diff(arg1.long_open_interest, arg1.short_open_interest) < v4;
    //         } else {
    //             v5 = false;
    //         };
    //         if (v5) {
    //             arg4.size_delta > 0
    //         } else {
    //             false
    //         }
    //     };
    //     if (v6) {
    //         let v7 = if (v1 > arg0.max_open_interest) {
    //             7
    //         } else {
    //             9
    //         };
    //         cancel_order_internal<T0, T1>(arg3, arg4, v7);
    //         return
    //     };
    //     let v8 = if (arg4.is_long) {
    //         &mut arg1.long_positions
    //     } else {
    //         &mut arg1.short_positions
    //     };
    //     let v9 = 0x1::table::borrow_mut<address, Position>(v8, arg4.user);
    //     if (v9.size + arg4.size_delta < arg0.minimum_position_size) {
    //         cancel_order_internal<T0, T1>(arg3, arg4, 5);
    //         return
    //     };
    //     let v10 = if (v9.size == 0) {
    //         0
    //     } else {
    //         1
    //     };
    //     let v11 = v9.size;
    //     let (v12, v13, v14, v15, v16) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_risk_fees(arg1.acc_rollover_fee_per_collateral, arg1.acc_funding_fee_per_size, arg1.acc_funding_fee_per_size_positive, v9.size, v9.collateral, arg4.is_long, v9.acc_rollover_fee_per_collateral, v9.acc_funding_fee_per_size, v9.acc_funding_fee_per_size_positive);
    //     let v17 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_maker_taker_fee(arg1.long_open_interest, arg1.short_open_interest, arg0.maker_fee, arg0.taker_fee, arg4.size_delta, arg4.is_long, arg4.is_increase);
    //     let v18 = v17 - 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v17, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::get_fee_discount_effect<T0>(arg4.user, true), 1000000);
    //     arg4.collateral_delta = arg4.collateral_delta - v18;
    //     if (arg4.collateral_delta > arg0.maximum_position_collateral) {
    //         cancel_order_internal<T0, T1>(arg3, arg4, 8);
    //         return
    //     };
    //     0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fee_distributor::deposit_fee_with_rebate<T1>(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::withdraw_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::CollateralVault, T1>(v18), arg4.user);
    //     0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pMKL::mint_pmkl(arg4.user, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_pmkl_amount(arg4.size_delta, arg0.maker_fee, arg0.taker_fee, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::get_pmkl_boost_effect<T0>(arg4.user, true)));
    //     0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::profile::increase_xp<T0>(arg4.user, v17 * 100);
    //     if (v10 == 0) {
    //         0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::profile::add_daily_boost(arg4.user);
    //         0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::adl_target::remove_target<T0>(arg4.user, arg4.is_long);
    //     };
    //     if (v15) {
    //         v9.collateral = v9.collateral + v16;
    //         0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::deposit_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::CollateralVault, T1>(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::pnl_withdraw_from_lp<T1>(v16));
    //     } else {
    //         v9.collateral = v9.collateral - v16;
    //         0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::pnl_deposit_to_lp<T1>(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::withdraw_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::CollateralVault, T1>(v16));
    //     };
    //     let v19 = borrow_global_mut<TradingEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
    //     if (v11 == 0) {
    //         v9.uid = v19.uid_sequence;
    //         v19.uid_sequence = v19.uid_sequence + 1;
    //     };
    //     v9.avg_price = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_new_price(v9.avg_price, v9.size, arg2, arg4.size_delta);
    //     v9.acc_rollover_fee_per_collateral = arg1.acc_rollover_fee_per_collateral;
    //     v9.last_execute_timestamp = 0x1::timestamp::now_seconds();
    //     v9.size = v9.size + arg4.size_delta;
    //     v9.collateral = v9.collateral + arg4.collateral_delta;
    //     v9.acc_funding_fee_per_size = arg1.acc_funding_fee_per_size;
    //     v9.acc_funding_fee_per_size_positive = arg1.acc_funding_fee_per_size_positive;
    //     let v20 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v9.collateral, arg0.maximum_profit, 10000);
    //     if (arg4.is_long) {
    //         v9.stop_loss_trigger_price = arg4.stop_loss_trigger_price;
    //         v9.take_profit_trigger_price = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::min(arg4.take_profit_trigger_price, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v9.avg_price, v9.size + v20, v9.size));
    //     } else {
    //         v9.stop_loss_trigger_price = arg4.stop_loss_trigger_price;
    //         let v21 = if (v9.size > v20) {
    //             v9.size - v20
    //         } else {
    //             1
    //         };
    //         v9.take_profit_trigger_price = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::max(arg4.take_profit_trigger_price, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v9.avg_price, v21, v9.size));
    //     };
    //     v9.size = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::max(v9.size, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v9.collateral, arg0.min_leverage, 1000000));
    //     v9.size = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::min(v9.size, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v9.collateral, arg0.max_leverage, 1000000));
    //     let v22 = v9.size - v11;
    //     if (arg4.is_long) {
    //         arg1.long_open_interest = arg1.long_open_interest + v22;
    //     } else {
    //         arg1.short_open_interest = arg1.short_open_interest + v22;
    //     };
    //     if (0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::external_capability_store::capability_exists<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::point::PointCapability>()) {
    //         v5 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::point::is_current_round_started();
    //     } else {
    //         v5 = false;
    //     };
    //     if (v5) {
    //         let v23 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::external_capability_store::get_capability<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::point::PointCapability>();
    //         0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::point::add_point_to_user(&v23, arg4.user, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_point_amount2(arg4.size_delta, arg0.maker_fee, arg0.taker_fee, 230000, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::get_pmkl_boost_effect<T0>(arg4.user, true)));
    //     };
    //     let v24 = PositionEvent{
    //         uid                   : v9.uid, 
    //         event_type            : v10, 
    //         pair_type             : 0x1::type_info::type_of<T0>(), 
    //         collateral_type       : 0x1::type_info::type_of<T1>(), 
    //         user                  : arg4.user, 
    //         order_id              : arg3, 
    //         is_long               : arg4.is_long, 
    //         price                 : arg2, 
    //         original_size         : v11, 
    //         size_delta            : v22, 
    //         original_collateral   : v9.collateral, 
    //         collateral_delta      : arg4.collateral_delta, 
    //         is_increase           : true, 
    //         is_partial            : v9.size != arg4.size_delta, 
    //         pnl_without_fee       : 0, 
    //         is_profit             : false, 
    //         entry_exit_fee        : v18, 
    //         funding_fee           : v14, 
    //         is_funding_fee_profit : v13, 
    //         rollover_fee          : v12, 
    //         long_open_interest    : arg1.long_open_interest, 
    //         short_open_interest   : arg1.short_open_interest,
    //     };
    //     0x1::event::emit_event<PositionEvent>(&mut v19.position_events, v24);
    //     0x1::event::emit_event<PositionEvent>(&mut borrow_global_mut<UserTradingEvents>(arg4.user).position_events, v24);
    //     add_position_key_to_user_states(arg4.user, 0x1::type_info::type_of<T0>(), 0x1::type_info::type_of<T1>(), arg4.is_long);
    //     remove_order_id_from_user_states(arg4.user, 0x1::type_info::type_of<T0>(), 0x1::type_info::type_of<T1>(), arg3);
    //     drop_order(arg4);
    // }
    
    // public fun execute_order<T0, T1>(arg0: &signer, arg1: u64, arg2: u64, arg3: vector<u8>, arg4: &ExecuteCapability<T0, T1>) acquires PairInfo, PairInfoV2, PairState, TradingEvents, UserStates, UserTradingEvents {
    //     execute_order_internal<T0, T1>(arg0, arg1, arg2, arg3);
    // }
    
    // public fun execute_order_all<T0, T1>(arg0: &signer, arg1: u64, arg2: vector<u8>, arg3: &ExecuteCapability<T0, T1>) acquires PairInfo, PairInfoV2, PairState, TradingEvents, UserStates, UserTradingEvents {
    //     let v0 = borrow_global<PairState<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
    //     let v1 = v0.next_order_id - 1;
    //     let v2 = 0x1::vector::empty<u64>();
    //     while (0x1::table::contains<u64, Order>(&v0.orders, v1)) {
    //         if (0x1::table::borrow<u64, Order>(&v0.orders, v1).is_market) {
    //             0x1::vector::push_back<u64>(&mut v2, v1);
    //         };
    //         if (v1 == 0) {
    //             break
    //         };
    //         v1 = v1 - 1;
    //     };
    //     let v3 = v2;
    //     loop {
    //         if (0x1::vector::is_empty<u64>(&v3)) {
    //             break
    //         };
    //         execute_order<T0, T1>(arg0, 0x1::vector::pop_back<u64>(&mut v3), arg1, arg2, arg3);
    //     };
    // }
    
    // public fun execute_order_all_v2<T0, T1>(arg0: &signer, arg1: u64, arg2: vector<u8>, arg3: &ExecuteCapabilityV2<T1>) acquires PairInfo, PairInfoV2, PairState, TradingEvents, UserStates, UserTradingEvents {
    //     let v0 = borrow_global<PairState<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
    //     let v1 = v0.next_order_id - 1;
    //     let v2 = 0x1::vector::empty<u64>();
    //     while (0x1::table::contains<u64, Order>(&v0.orders, v1)) {
    //         if (0x1::table::borrow<u64, Order>(&v0.orders, v1).is_market) {
    //             0x1::vector::push_back<u64>(&mut v2, v1);
    //         };
    //         if (v1 == 0) {
    //             break
    //         };
    //         v1 = v1 - 1;
    //     };
    //     let v3 = v2;
    //     loop {
    //         if (0x1::vector::is_empty<u64>(&v3)) {
    //             break
    //         };
    //         execute_order_v2<T0, T1>(arg0, 0x1::vector::pop_back<u64>(&mut v3), arg1, arg2, arg3);
    //     };
    // }
    
    // public fun execute_order_all_v3<T0, T1>(arg0: &signer, arg1: u64, arg2: vector<u8>, arg3: &ExecuteCapabilityV3) acquires PairInfo, PairInfoV2, PairState, TradingEvents, UserStates, UserTradingEvents {
    //     let v0 = borrow_global<PairState<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
    //     let v1 = v0.next_order_id - 1;
    //     let v2 = 0x1::vector::empty<u64>();
    //     while (0x1::table::contains<u64, Order>(&v0.orders, v1)) {
    //         if (0x1::table::borrow<u64, Order>(&v0.orders, v1).is_market) {
    //             0x1::vector::push_back<u64>(&mut v2, v1);
    //         };
    //         if (v1 == 0) {
    //             break
    //         };
    //         v1 = v1 - 1;
    //     };
    //     let v3 = v2;
    //     loop {
    //         if (0x1::vector::is_empty<u64>(&v3)) {
    //             break
    //         };
    //         execute_order_v3<T0, T1>(arg0, 0x1::vector::pop_back<u64>(&mut v3), arg1, arg2, arg3);
    //     };
    // }
    
    // fun execute_order_internal<T0, T1>(arg0: &signer, arg1: u64, arg2: u64, arg3: vector<u8>) acquires PairInfo, PairInfoV2, PairState, TradingEvents, UserStates, UserTradingEvents {
    //     let v0 = borrow_global<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
    //     if (v0.paused) {
    //         abort 16
    //     };
    //     let v1 = borrow_global_mut<PairState<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
    //     assert!(0x1::table::contains<u64, Order>(&mut v1.orders, arg1), 6);
    //     let v2 = 0x1::table::remove<u64, Order>(&mut v1.orders, arg1);
    //     let v3 = get_params_u64_value<T0, T1>(b"deprecated_pair_collateral", 0);
    //     if (v3 == 1) {
    //         cancel_order_internal<T0, T1>(arg1, v2, 6);
    //         return
    //     };
    //     let v4 = if (v2.is_market && 0x1::timestamp::now_seconds() - v2.created_timestamp > 30) {
    //         true
    //     } else {
    //         if (0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::check_hard_break_exceeded<T1>()) {
    //             true
    //         } else {
    //             if (0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::check_soft_break_exceeded<T1>()) {
    //                 v2.is_increase
    //             } else {
    //                 false
    //             }
    //         }
    //     };
    //     if (v4) {
    //         cancel_order_internal<T0, T1>(arg1, v2, 6);
    //         return
    //     };
    //     accrue<T0, T1>(v0, v1);
    //     0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::update<T0>(arg0, arg2, arg3);
    //     let v5 = v2.is_increase && v2.is_long || !v2.is_long;
    //     if (v2.is_increase) {
    //         execute_increase_order_internal<T0, T1>(v0, v1, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_price_impact(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::read<T0>(v5), v2.size_delta, v2.is_long, v2.is_increase, v1.long_open_interest, v1.short_open_interest, v0.skew_factor), arg1, v2);
    //     } else {
    //         execute_decrease_order_internal<T0, T1>(v0, v1, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_price_impact(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::read<T0>(v5), v2.size_delta, v2.is_long, v2.is_increase, v1.long_open_interest, v1.short_open_interest, v0.skew_factor), arg1, v2);
    //     };
    // }
    
    // public fun execute_order_self<T0, T1>(arg0: &signer, arg1: u64) acquires PairInfo, PairInfoV2, PairState, TradingEvents, UserStates, UserTradingEvents {
    //     let v0 = borrow_global<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
    //     if (v0.paused) {
    //         abort 16
    //     };
    //     let v1 = borrow_global_mut<PairState<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
    //     assert!(0x1::table::contains<u64, Order>(&mut v1.orders, arg1), 6);
    //     let v2 = 0x1::table::remove<u64, Order>(&mut v1.orders, arg1);
    //     assert!(v2.is_market, 11);
    //     if (v2.is_increase) {
    //         abort 13
    //     };
    //     assert!(0x1::signer::address_of(arg0) == v2.user, 20);
    //     assert!(v2.created_timestamp + v0.execute_time_limit < 0x1::timestamp::now_seconds(), 21);
    //     accrue<T0, T1>(v0, v1);
    //     execute_decrease_order_internal<T0, T1>(v0, v1, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_price_impact(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::read<T0>(!v2.is_long), v2.size_delta, v2.is_long, false, v1.long_open_interest, v1.short_open_interest, v0.skew_factor), arg1, v2);
    // }
    
    // public fun execute_order_v2<T0, T1>(arg0: &signer, arg1: u64, arg2: u64, arg3: vector<u8>, arg4: &ExecuteCapabilityV2<T1>) acquires PairInfo, PairInfoV2, PairState, TradingEvents, UserStates, UserTradingEvents {
    //     execute_order_internal<T0, T1>(arg0, arg1, arg2, arg3);
    // }
    
    // public fun execute_order_v3<T0, T1>(arg0: &signer, arg1: u64, arg2: u64, arg3: vector<u8>, arg4: &ExecuteCapabilityV3) acquires PairInfo, PairInfoV2, PairState, TradingEvents, UserStates, UserTradingEvents {
    //     execute_order_internal<T0, T1>(arg0, arg1, arg2, arg3);
    // }
    
    // public fun generate_admin_cap<T0, T1>(arg0: &signer, arg1: &AdminCapability<T0, T1>) : AdminCapability<T0, T1> {
    //     abort 0
    // }
    
    // public fun generate_admin_cap_v2(arg0: &signer, arg1: &CapabilityProvider) : AdminCapabilityV2 {
    //     AdminCapabilityV2{dummy_field: false}
    // }
    
    // public fun generate_admin_cap_with_v2<T0, T1>(arg0: &AdminCapabilityV2) : AdminCapability<T0, T1> {
    //     AdminCapability<T0, T1>{dummy_field: false}
    // }
    
    // public fun generate_capability_provider(arg0: &signer) : CapabilityProvider {
    //     assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
    //     CapabilityProvider{dummy_field: false}
    // }
    
    // public fun generate_execute_cap<T0, T1>(arg0: &signer, arg1: &AdminCapability<T0, T1>) : ExecuteCapability<T0, T1> {
    //     abort 0
    // }
    
    // public fun generate_execute_cap_v2<T0>(arg0: &signer, arg1: &CapabilityProvider) : ExecuteCapabilityV2<T0> {
    //     abort 0
    // }
    
    // public fun generate_execute_cap_v3(arg0: &signer, arg1: &CapabilityProvider) : ExecuteCapabilityV3 {
    //     ExecuteCapabilityV3{dummy_field: false}
    // }
    
    public fun get_params_u64_value<T0, T1>(arg0: vector<u8>, arg1: u64) : u64 acquires PairInfoV2 {
        if (exists<PairInfoV2<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)) {
            let v0 = borrow_global_mut<PairInfoV2<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
            let v1 = 0x1::string::utf8(arg0);
            if (0x1::simple_map::contains_key<0x1::string::String, vector<u8>>(&v0.params, &v1)) {
                let v2 = 0x1::string::utf8(arg0);
                return 0x1::from_bcs::to_u64(*0x1::simple_map::borrow<0x1::string::String, vector<u8>>(&v0.params, &v2))
            };
            return arg1
        };
        arg1
    }
    
    // public fun initialize<T0, T1>(arg0: &signer) : (ExecuteCapability<T0, T1>, AdminCapability<T0, T1>) {
    //     assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
    //     if (exists<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)) {
    //     } else {
    //         let v0 = PairInfo<T0, T1>{
    //             paused                      : false, 
    //             min_leverage                : 0, 
    //             max_leverage                : 0, 
    //             maker_fee                   : 0, 
    //             taker_fee                   : 0, 
    //             rollover_fee_per_timestamp  : 0, 
    //             skew_factor                 : 0, 
    //             max_funding_velocity        : 0, 
    //             max_open_interest           : 0, 
    //             market_depth_above          : 10000000000, 
    //             market_depth_below          : 10000000000, 
    //             execute_time_limit          : 300, 
    //             liquidate_threshold         : 1000, 
    //             maximum_profit              : 100000, 
    //             minimum_order_collateral    : 0, 
    //             minimum_position_collateral : 1000000, 
    //             minimum_position_size       : 0, 
    //             maximum_position_collateral : 18446744073709551615, 
    //             execution_fee               : 0,
    //         };
    //         move_to<PairInfo<T0, T1>>(arg0, v0);
    //     };
    //     if (exists<PairState<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)) {
    //     } else {
    //         let v1 = PairState<T0, T1>{
    //             next_order_id                     : 1, 
    //             long_open_interest                : 0, 
    //             short_open_interest               : 0, 
    //             funding_rate                      : 0, 
    //             funding_rate_positive             : true, 
    //             acc_funding_fee_per_size          : 0, 
    //             acc_funding_fee_per_size_positive : true, 
    //             acc_rollover_fee_per_collateral   : 0, 
    //             last_accrue_timestamp             : 0x1::timestamp::now_seconds(), 
    //             orders                            : 0x1::table::new<u64, Order>(), 
    //             long_positions                    : 0x1::table::new<address, Position>(), 
    //             short_positions                   : 0x1::table::new<address, Position>(),
    //         };
    //         move_to<PairState<T0, T1>>(arg0, v1);
    //     };
    //     if (exists<TradingEvents>(0x1::signer::address_of(arg0))) {
    //     } else {
    //         let v2 = TradingEvents{
    //             uid_sequence        : 0, 
    //             place_order_events  : 0x1::account::new_event_handle<PlaceOrderEvent>(arg0), 
    //             cancel_order_events : 0x1::account::new_event_handle<CancelOrderEvent>(arg0), 
    //             position_events     : 0x1::account::new_event_handle<PositionEvent>(arg0), 
    //             update_tp_sl_events : 0x1::account::new_event_handle<UpdateTPSLEvent>(arg0),
    //         };
    //         move_to<TradingEvents>(arg0, v2);
    //     };
    //     let v3 = ExecuteCapability<T0, T1>{dummy_field: false};
    //     let v4 = AdminCapability<T0, T1>{dummy_field: false};
    //     (v3, v4)
    // }
    
    public fun initialize_user_if_needed(arg0: &signer) {
        let v0 = 0x1::signer::address_of(arg0);
        if (exists<UserTradingEvents>(v0)) {
        } else {
            let v1 = UserTradingEvents{
                place_order_events  : 0x1::account::new_event_handle<PlaceOrderEvent>(arg0), 
                cancel_order_events : 0x1::account::new_event_handle<CancelOrderEvent>(arg0), 
                position_events     : 0x1::account::new_event_handle<PositionEvent>(arg0), 
                update_tp_sl_events : 0x1::account::new_event_handle<UpdateTPSLEvent>(arg0),
            };
            move_to<UserTradingEvents>(arg0, v1);
        };
        if (exists<UserStates>(v0)) {
        } else {
            let v2 = UserStates{
                order_keys         : 0x1::vector::empty<OrderKey>(), 
                user_position_keys : 0x1::vector::empty<UserPositionKey>(),
            };
            move_to<UserStates>(arg0, v2);
        };
    }
    
    // public fun initialize_v2<T0, T1>(arg0: &signer) {
    //     assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
    //     if (exists<PairInfoV2<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)) {
    //     } else {
    //         let v0 = PairInfoV2<T0, T1>{params: 0x1::simple_map::new<0x1::string::String, vector<u8>>()};
    //         move_to<PairInfoV2<T0, T1>>(arg0, v0);
    //     };
    // }
    
    // public fun pause<T0, T1>(arg0: &AdminCapability<T0, T1>) acquires PairInfo {
    //     borrow_global_mut<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).paused = true;
    // }
    
    // public fun place_order<T0, T1>(arg0: &signer, arg1: u64, arg2: u64, arg3: u64, arg4: bool, arg5: bool, arg6: bool, arg7: u64, arg8: u64, arg9: bool) acquires PairInfo, PairInfoV2, PairState, TradingEvents, UserStates, UserTradingEvents {
    //     initialize_user_if_needed(arg0);
    //     place_order_internal<T0, T1>(arg0, 0x1::signer::address_of(arg0), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
    // }
    
    fun place_order_internal<T0, T1>(arg0: &signer, arg1: address, arg2: u64, arg3: u64, arg4: u64, arg5: bool, arg6: bool, arg7: bool, arg8: u64, arg9: u64, arg10: bool) acquires PairInfo, PairInfoV2, PairState, TradingEvents, UserStates, UserTradingEvents {
        let v0 = get_params_u64_value<T0, T1>(b"deprecated_pair_collateral", 0);
        assert!(v0 == 0, 34);
        assert!(exists<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d), 2);
        let v1 = borrow_global<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (v1.paused) {
            abort 16
        };
        let v2 = if (0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::check_hard_break_exceeded<T1>()) {
            true
        } else {
            if (0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::house_lp::check_soft_break_exceeded<T1>()) {
                arg6
            } else {
                false
            }
        };
        if (v2) {
            abort 30
        };
        let v3 = borrow_global_mut<PairState<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        accrue<T0, T1>(v1, v3);
        if (arg6) {
            let v4 = if (0x1::signer::address_of(arg0) == arg1) {
                0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fa_box::get_fa_coin_if_needed<T1>(arg0, arg3)
            } else {
                0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::delegate_account::withdraw_to_trading<T1>(arg1, arg3)
            };
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::deposit_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::CollateralVault, T1>(v4);
        };
        let v5 = Order{
            uid                       : 0, 
            user                      : arg1, 
            size_delta                : arg2, 
            collateral_delta          : arg3, 
            price                     : arg4, 
            is_long                   : arg5, 
            is_increase               : arg6, 
            is_market                 : arg7, 
            can_execute_above_price   : arg10, 
            stop_loss_trigger_price   : arg8, 
            take_profit_trigger_price : arg9, 
            created_timestamp         : 0x1::timestamp::now_seconds(),
        };
        let v6 = if (arg5) {
            &mut v3.long_positions
        } else {
            &mut v3.short_positions
        };
        if (0x1::table::contains<address, Position>(v6, v5.user)) {
        } else {
            let v7 = Position{
                uid                               : 0, 
                size                              : 0, 
                collateral                        : 0, 
                avg_price                         : 0, 
                last_execute_timestamp            : 0x1::timestamp::now_seconds(), 
                acc_rollover_fee_per_collateral   : 0, 
                acc_funding_fee_per_size          : 0, 
                acc_funding_fee_per_size_positive : false, 
                stop_loss_trigger_price           : 0, 
                take_profit_trigger_price         : 0,
            };
            0x1::table::add<address, Position>(v6, arg1, v7);
        };
        validate_order<T0, T1>(&v5, 0x1::table::borrow_mut<address, Position>(v6, v5.user), v1, v3);
        0x1::table::add<u64, Order>(&mut v3.orders, v3.next_order_id, v5);
        let v8 = OrderKey{
            pair_type       : 0x1::type_info::type_of<T0>(), 
            collateral_type : 0x1::type_info::type_of<T1>(), 
            order_id        : v3.next_order_id,
        };
        0x1::vector::push_back<OrderKey>(&mut borrow_global_mut<UserStates>(arg1).order_keys, v8);
        v3.next_order_id = v3.next_order_id + 1;
        let v9 = PlaceOrderEvent{
            uid              : 0, 
            pair_type        : 0x1::type_info::type_of<T0>(), 
            collateral_type  : 0x1::type_info::type_of<T1>(), 
            user             : arg1, 
            order_id         : v3.next_order_id - 1, 
            size_delta       : arg2, 
            collateral_delta : arg3, 
            price            : arg4, 
            is_long          : arg5, 
            is_increase      : arg6, 
            is_market        : arg7,
        };
        0x1::event::emit_event<PlaceOrderEvent>(&mut borrow_global_mut<TradingEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).place_order_events, v9);
        0x1::event::emit_event<PlaceOrderEvent>(&mut borrow_global_mut<UserTradingEvents>(arg1).place_order_events, v9);
    }
    
    public fun place_order_v3<T0, T1>(arg0: &signer, arg1: address, arg2: u64, arg3: u64, arg4: u64, arg5: bool, arg6: bool, arg7: bool, arg8: u64, arg9: u64, arg10: bool) acquires PairInfo, PairInfoV2, PairState, TradingEvents, UserStates, UserTradingEvents {
        assert!(0x1::signer::address_of(arg0) == arg1 || 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::delegate_account::is_registered<T1>(arg1, 0x1::signer::address_of(arg0)), 31);
        if (0x1::signer::address_of(arg0) == arg1) {
            initialize_user_if_needed(arg0);
        };
        place_order_internal<T0, T1>(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10);
    }
    
    // fun remove_order_id_from_user_states(arg0: address, arg1: 0x1::type_info::TypeInfo, arg2: 0x1::type_info::TypeInfo, arg3: u64) acquires UserStates {
    //     let v0 = borrow_global_mut<UserStates>(arg0);
    //     let v1 = OrderKey{
    //         pair_type       : arg1, 
    //         collateral_type : arg2, 
    //         order_id        : arg3,
    //     };
    //     let (v2, v3) = 0x1::vector::index_of<OrderKey>(&v0.order_keys, &v1);
    //     assert!(v2, 6);
    //     0x1::vector::remove<OrderKey>(&mut v0.order_keys, v3);
    // }
    
    // fun remove_position_key_from_user_states(arg0: address, arg1: 0x1::type_info::TypeInfo, arg2: 0x1::type_info::TypeInfo, arg3: bool) acquires UserStates {
    //     let v0 = borrow_global_mut<UserStates>(arg0);
    //     let v1 = UserPositionKey{
    //         pair_type       : arg1, 
    //         collateral_type : arg2, 
    //         is_long         : arg3,
    //     };
    //     let (v2, v3) = 0x1::vector::index_of<UserPositionKey>(&v0.user_position_keys, &v1);
    //     assert!(v2, 15);
    //     0x1::vector::remove<UserPositionKey>(&mut v0.user_position_keys, v3);
    // }
    
    // public fun restart<T0, T1>(arg0: &AdminCapability<T0, T1>) acquires PairInfo {
    //     borrow_global_mut<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).paused = false;
    // }
    
    // public fun set_execute_time_limit<T0, T1>(arg0: u64, arg1: &AdminCapability<T0, T1>) acquires PairInfo {
    //     borrow_global_mut<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).execute_time_limit = arg0;
    // }
    
    // public fun set_execution_fee<T0, T1>(arg0: u64, arg1: &AdminCapability<T0, T1>) acquires PairInfo {
    //     borrow_global_mut<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).execution_fee = arg0;
    // }
    
    // public fun set_liquidate_threshold<T0, T1>(arg0: u64, arg1: &AdminCapability<T0, T1>) acquires PairInfo {
    //     borrow_global_mut<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).liquidate_threshold = arg0;
    // }
    
    // public fun set_maker_fee<T0, T1>(arg0: u64, arg1: &AdminCapability<T0, T1>) acquires PairInfo {
    //     borrow_global_mut<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).maker_fee = arg0;
    // }
    
    // public fun set_market_depth_above<T0, T1>(arg0: u64, arg1: &AdminCapability<T0, T1>) acquires PairInfo {
    //     borrow_global_mut<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).market_depth_above = arg0;
    // }
    
    // public fun set_market_depth_below<T0, T1>(arg0: u64, arg1: &AdminCapability<T0, T1>) acquires PairInfo {
    //     borrow_global_mut<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).market_depth_below = arg0;
    // }
    
    // public fun set_max_funding_velocity<T0, T1>(arg0: u64, arg1: &AdminCapability<T0, T1>) acquires PairInfo {
    //     borrow_global_mut<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).max_funding_velocity = arg0;
    // }
    
    // public fun set_max_interest<T0, T1>(arg0: u64, arg1: &AdminCapability<T0, T1>) acquires PairInfo {
    //     borrow_global_mut<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).max_open_interest = arg0;
    // }
    
    // public fun set_max_leverage<T0, T1>(arg0: u64, arg1: &AdminCapability<T0, T1>) acquires PairInfo {
    //     borrow_global_mut<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).max_leverage = arg0;
    // }
    
    // public fun set_maximum_position_collateral<T0, T1>(arg0: u64, arg1: &AdminCapability<T0, T1>) acquires PairInfo {
    //     borrow_global_mut<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).maximum_position_collateral = arg0;
    // }
    
    // public fun set_maximum_profit<T0, T1>(arg0: u64, arg1: &AdminCapability<T0, T1>) acquires PairInfo {
    //     borrow_global_mut<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).maximum_profit = arg0;
    // }
    
    // public fun set_min_leverage<T0, T1>(arg0: u64, arg1: &AdminCapability<T0, T1>) acquires PairInfo {
    //     borrow_global_mut<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).min_leverage = arg0;
    // }
    
    // public fun set_minimum_order_collateral<T0, T1>(arg0: u64, arg1: &AdminCapability<T0, T1>) acquires PairInfo {
    //     borrow_global_mut<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).minimum_order_collateral = arg0;
    // }
    
    // public fun set_minimum_position_collateral<T0, T1>(arg0: u64, arg1: &AdminCapability<T0, T1>) acquires PairInfo {
    //     borrow_global_mut<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).minimum_position_collateral = arg0;
    // }
    
    // public fun set_minimum_position_size<T0, T1>(arg0: u64, arg1: &AdminCapability<T0, T1>) acquires PairInfo {
    //     borrow_global_mut<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).minimum_position_size = arg0;
    // }
    
    // public fun set_param<T0, T1>(arg0: 0x1::string::String, arg1: vector<u8>, arg2: &AdminCapability<T0, T1>) acquires PairInfoV2 {
    //     let (_, _) = 0x1::simple_map::upsert<0x1::string::String, vector<u8>>(&mut borrow_global_mut<PairInfoV2<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).params, arg0, arg1);
    // }
    
    // public fun set_rollover_fee_per_block<T0, T1>(arg0: u64, arg1: &AdminCapability<T0, T1>) acquires PairInfo {
    //     borrow_global_mut<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).rollover_fee_per_timestamp = arg0;
    // }
    
    // public fun set_skew_factor<T0, T1>(arg0: u64, arg1: &AdminCapability<T0, T1>) acquires PairInfo {
    //     borrow_global_mut<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).skew_factor = arg0;
    // }
    
    // public fun set_taker_fee<T0, T1>(arg0: u64, arg1: &AdminCapability<T0, T1>) acquires PairInfo {
    //     borrow_global_mut<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).taker_fee = arg0;
    // }
    
    // public fun update_position_tp_sl<T0, T1>(arg0: &signer, arg1: bool, arg2: u64, arg3: u64) acquires PairInfo, PairState, TradingEvents {
    //     update_position_tp_sl_v3<T0, T1>(arg0, 0x1::signer::address_of(arg0), arg1, arg2, arg3);
    // }
    
    // fun update_position_tp_sl_internal<T0, T1>(arg0: address, arg1: bool, arg2: u64, arg3: u64) acquires PairInfo, PairState, TradingEvents {
    //     let v0 = borrow_global<PairInfo<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
    //     if (v0.paused) {
    //         abort 16
    //     };
    //     let v1 = if (arg1) {
    //         &mut borrow_global_mut<PairState<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).long_positions
    //     } else {
    //         &mut borrow_global_mut<PairState<T0, T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).short_positions
    //     };
    //     assert!(0x1::table::contains<address, Position>(v1, arg0), 15);
    //     let v2 = 0x1::table::borrow_mut<address, Position>(v1, arg0);
    //     assert!(v2.collateral != 0, 15);
    //     assert!(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v2.size, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::diff(arg2, v2.avg_price), 10000, v2.avg_price), v2.collateral) <= v0.maximum_profit, 24);
    //     v2.take_profit_trigger_price = arg2;
    //     v2.stop_loss_trigger_price = arg3;
    //     let v3 = UpdateTPSLEvent{
    //         uid                       : v2.uid, 
    //         pair_type                 : 0x1::type_info::type_of<T0>(), 
    //         collateral_type           : 0x1::type_info::type_of<T1>(), 
    //         user                      : arg0, 
    //         is_long                   : arg1, 
    //         take_profit_trigger_price : arg2, 
    //         stop_loss_trigger_price   : arg3,
    //     };
    //     0x1::event::emit_event<UpdateTPSLEvent>(&mut borrow_global_mut<TradingEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).update_tp_sl_events, v3);
    // }
    
    // public fun update_position_tp_sl_v3<T0, T1>(arg0: &signer, arg1: address, arg2: bool, arg3: u64, arg4: u64) acquires PairInfo, PairState, TradingEvents {
    //     assert!(0x1::signer::address_of(arg0) == arg1 || 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::delegate_account::is_registered<T1>(arg1, 0x1::signer::address_of(arg0)), 31);
    //     update_position_tp_sl_internal<T0, T1>(arg1, arg2, arg3, arg4);
    // }
    
    fun validate_decrease_order<T0, T1>(arg0: &Order, arg1: &Position, arg2: &PairInfo<T0, T1>, arg3: &PairState<T0, T1>) {
        assert!(arg0.size_delta <= arg1.size, 28);
        let v0 = arg1.size - arg0.size_delta;
        assert!(v0 == 0 || v0 >= arg2.minimum_position_size, 29);
        if (v0 == 0) {
            return
        };
        let v1 = arg1.collateral - arg0.collateral_delta;
        assert!(v1 >= arg2.minimum_position_collateral, 26);
        assert!(v1 <= arg2.maximum_position_collateral, 27);
        assert!(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v0, 1000000, v1) >= arg2.min_leverage - 1000000, 4);
        assert!(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v0, 1000000, v1) <= arg2.max_leverage + 1000000, 5);
    }
    
    fun validate_increase_order<T0, T1>(arg0: &Order, arg1: &Position, arg2: &PairInfo<T0, T1>, arg3: &PairState<T0, T1>) acquires PairInfoV2 {
        let v0 = arg1.size + arg0.size_delta;
        assert!(v0 >= arg2.minimum_position_size, 29);
        assert!(arg0.collateral_delta > 0, 10);
        assert!(arg0.collateral_delta >= arg2.minimum_order_collateral, 25);
        let v1 = if (arg0.is_long) {
            arg3.long_open_interest
        } else {
            arg3.short_open_interest
        };
        let v2 = arg0.size_delta + v1;
        assert!(v2 <= arg2.max_open_interest, 18);
        let v3 = get_params_u64_value<T0, T1>(b"maximum_skew_limit", 18446744073709551615);
        let v4 = if (arg0.is_long) {
            arg3.short_open_interest
        } else {
            arg3.long_open_interest
        };
        let v5 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::diff(v2, v4);
        assert!(v5 <= v3 || 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::diff(arg3.long_open_interest, arg3.short_open_interest) > v5 || arg0.size_delta == 0, 33);
        let (_, _, _, v9, v10) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_risk_fees(arg3.acc_rollover_fee_per_collateral, arg3.acc_funding_fee_per_size, arg3.acc_funding_fee_per_size_positive, arg1.size, arg1.collateral, arg0.is_long, arg1.acc_rollover_fee_per_collateral, arg1.acc_funding_fee_per_size, arg1.acc_funding_fee_per_size_positive);
        let v11 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc::calculate_maker_taker_fee(arg3.long_open_interest, arg3.short_open_interest, arg2.maker_fee, arg2.taker_fee, arg0.size_delta, arg0.is_long, arg0.is_increase);
        let v12 = if (v9) {
            arg1.collateral + arg0.collateral_delta - v11 - 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v11, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::get_fee_discount_effect<T0>(arg0.user, true), 1000000) + v10
        } else {
            arg1.collateral + arg0.collateral_delta - v11 - 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v11, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear::get_fee_discount_effect<T0>(arg0.user, true), 1000000) - v10
        };
        assert!(v12 >= arg2.minimum_position_collateral, 26);
        assert!(v12 <= arg2.maximum_position_collateral, 27);
        assert!(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v0, 1000000, v12) >= arg2.min_leverage - 1000000, 4);
        assert!(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v0, 1000000, v12) <= arg2.max_leverage + 1000000, 5);
    }
    
    fun validate_order<T0, T1>(arg0: &Order, arg1: &Position, arg2: &PairInfo<T0, T1>, arg3: &PairState<T0, T1>) acquires PairInfoV2 {
        assert!(arg0.price != 0, 3);
        assert!(arg0.size_delta != 0 || arg0.collateral_delta != 0, 22);
        if (arg0.is_increase) {
            validate_increase_order<T0, T1>(arg0, arg1, arg2, arg3);
        } else {
            validate_decrease_order<T0, T1>(arg0, arg1, arg2, arg3);
        };
    }
    
    // decompiled from Move bytecode v6
}


module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::liquidity_auction {
    struct DepositAssetEvent has drop, store {
        asset_type: 0x1::type_info::TypeInfo,
        asset_deposit_amount: u64,
        phase1_asset_deposit_amount: u64,
    }
    
    struct DepositPreMklEvent has drop, store {
        pre_mkl_deposit_amount: u64,
        total_pre_mkl_deposit_amount: u64,
    }
    
    struct LiquidityAuctionEvents has key {
        deposit_pre_mkl_events: 0x1::event::EventHandle<DepositPreMklEvent>,
        deposit_asset_events: 0x1::event::EventHandle<DepositAssetEvent>,
        withdraw_asset_events: 0x1::event::EventHandle<WithdrawAssetEvent>,
    }
    
    struct LpInfo<phantom T0> has key {
        lp_vault: 0x1::coin::Coin<0x9cc3c27b8d398ab6fc82cbc9dc6b43bb9164f72da465631628163822662a8580::lp_coin::LP<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::MKL, T0, 0x45ef7a3a1221e7c10d190a550aa30fa5bc3208ed06ee3661ec0afa3d8b418580::curves::Uncorrelated>>,
        total_lp_amount: u64,
        mkl_reward_vault: 0x1::object::Object<0x1::fungible_asset::FungibleStore>,
    }
    
    struct PoolInfo<phantom T0> has key {
        user_infos: 0x1::table::Table<address, UserInfo>,
        pre_mkl: 0x1::object::Object<0x1::fungible_asset::FungibleStore>,
        total_pre_mkl_deposit_amount: u64,
        asset_vault: 0x1::coin::Coin<T0>,
        total_asset_deposit_amount: u64,
    }
    
    struct UserInfo has drop, store {
        pre_mkl_deposit_amount: u64,
        asset_deposit_amount: u64,
        phase1_asset_deposit_amount: u64,
        lp_withdraw_amount: u64,
        last_claimed_at: u64,
    }
    
    struct WithdrawAssetEvent has drop, store {
        asset_type: 0x1::type_info::TypeInfo,
        asset_withdraw_amount: u64,
        asset_total_amount: u64,
        phase1_asset_deposit_amount: u64,
    }
    
    public fun initialize_module<T0>(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        if (exists<PoolInfo<T0>>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = 0x1::object::create_object(0x1::signer::address_of(arg0));
            let v1 = PoolInfo<T0>{
                user_infos                   : 0x1::table::new<address, UserInfo>(), 
                pre_mkl                      : 0x1::fungible_asset::create_store<0x1::fungible_asset::Metadata>(&v0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::get_metadata()), 
                total_pre_mkl_deposit_amount : 0, 
                asset_vault                  : 0x1::coin::zero<T0>(), 
                total_asset_deposit_amount   : 0,
            };
            move_to<PoolInfo<T0>>(arg0, v1);
        };
        if (exists<LiquidityAuctionEvents>(0x1::signer::address_of(arg0))) {
        } else {
            let v2 = LiquidityAuctionEvents{
                deposit_pre_mkl_events : 0x1::account::new_event_handle<DepositPreMklEvent>(arg0), 
                deposit_asset_events   : 0x1::account::new_event_handle<DepositAssetEvent>(arg0), 
                withdraw_asset_events  : 0x1::account::new_event_handle<WithdrawAssetEvent>(arg0),
            };
            move_to<LiquidityAuctionEvents>(arg0, v2);
        };
    }
    
    public fun claim_mkl_reward<T0>(arg0: &signer) acquires LpInfo, PoolInfo {
        let v0 = 0x1::signer::address_of(arg0);
        let v1 = get_claimable_mkl_reward<T0>(v0);
        0x1::table::borrow_mut<address, UserInfo>(&mut borrow_global_mut<PoolInfo<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).user_infos, v0).last_claimed_at = 0x1::timestamp::now_seconds();
        0x1::primary_fungible_store::deposit(v0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::withdraw_from_freezed_mkl_store(&borrow_global<LpInfo<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).mkl_reward_vault, v1));
    }
    
    public fun deposit_asset<T0>(arg0: &signer, arg1: u64) acquires LiquidityAuctionEvents, PoolInfo {
        assert!(arg1 >= 10000, 7);
        let v0 = 0x1::timestamp::now_seconds();
        assert!(1724932800 <= v0 && v0 <= 1725364800, 4);
        let v1 = borrow_global_mut<PoolInfo<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v2 = UserInfo{
            pre_mkl_deposit_amount      : 0, 
            asset_deposit_amount        : 0, 
            phase1_asset_deposit_amount : 0, 
            lp_withdraw_amount          : 0, 
            last_claimed_at             : 1725537600,
        };
        let v3 = 0x1::table::borrow_mut_with_default<address, UserInfo>(&mut v1.user_infos, 0x1::signer::address_of(arg0), v2);
        v3.asset_deposit_amount = v3.asset_deposit_amount + arg1;
        v3.phase1_asset_deposit_amount = v3.asset_deposit_amount;
        v1.total_asset_deposit_amount = v1.total_asset_deposit_amount + arg1;
        0x1::coin::merge<T0>(&mut v1.asset_vault, 0x1::coin::withdraw<T0>(arg0, arg1));
        let v4 = DepositAssetEvent{
            asset_type                  : 0x1::type_info::type_of<T0>(), 
            asset_deposit_amount        : arg1, 
            phase1_asset_deposit_amount : v3.phase1_asset_deposit_amount,
        };
        0x1::event::emit_event<DepositAssetEvent>(&mut borrow_global_mut<LiquidityAuctionEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).deposit_asset_events, v4);
    }
    
    public fun deposit_pre_mkl<T0>(arg0: &signer, arg1: u64) acquires LiquidityAuctionEvents, PoolInfo {
        assert!(arg1 >= 10000, 7);
        let v0 = 0x1::timestamp::now_seconds();
        assert!(1724932800 <= v0 && v0 <= 1725364800, 4);
        let v1 = borrow_global_mut<PoolInfo<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v2 = UserInfo{
            pre_mkl_deposit_amount      : 0, 
            asset_deposit_amount        : 0, 
            phase1_asset_deposit_amount : 0, 
            lp_withdraw_amount          : 0, 
            last_claimed_at             : 1725537600,
        };
        let v3 = 0x1::table::borrow_mut_with_default<address, UserInfo>(&mut v1.user_infos, 0x1::signer::address_of(arg0), v2);
        v3.pre_mkl_deposit_amount = v3.pre_mkl_deposit_amount + arg1;
        v1.total_pre_mkl_deposit_amount = v1.total_pre_mkl_deposit_amount + arg1;
        0x1::fungible_asset::deposit<0x1::fungible_asset::FungibleStore>(v1.pre_mkl, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::withdraw_from_user(0x1::signer::address_of(arg0), arg1));
        let v4 = DepositPreMklEvent{
            pre_mkl_deposit_amount       : arg1, 
            total_pre_mkl_deposit_amount : v3.pre_mkl_deposit_amount,
        };
        0x1::event::emit_event<DepositPreMklEvent>(&mut borrow_global_mut<LiquidityAuctionEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).deposit_pre_mkl_events, v4);
    }
    
    public fun get_claimable_mkl_reward<T0>(arg0: address) : u64 acquires LpInfo, PoolInfo {
        let v0 = get_user_initial_lp_amount<T0>(arg0);
        let v1 = borrow_global<PoolInfo<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::table::contains<address, UserInfo>(&v1.user_infos, arg0)) {
            let v2 = 0x1::table::borrow<address, UserInfo>(&v1.user_infos, arg0);
            let v3 = 0x1::timestamp::now_seconds();
            return 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(1000000000000, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::min(10368000, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::min(v3, 1735905600) - 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::min(v3, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::min(v2.last_claimed_at, 1735905600))), 10368000), v0 - v2.lp_withdraw_amount, borrow_global<LpInfo<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).total_lp_amount)
        };
        0
    }
    
    public fun get_lba_schedule() : (u64, u64, u64) {
        (1724932800, 1725537600, 1735905600)
    }
    
    public fun get_user_initial_lp_amount<T0>(arg0: address) : u64 acquires LpInfo, PoolInfo {
        let v0 = borrow_global<LpInfo<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = borrow_global<PoolInfo<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::table::contains<address, UserInfo>(&v1.user_infos, arg0)) {
            let v2 = 0x1::table::borrow<address, UserInfo>(&v1.user_infos, arg0);
            return 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v0.total_lp_amount, v2.pre_mkl_deposit_amount, v1.total_pre_mkl_deposit_amount * 2) + 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v0.total_lp_amount, v2.asset_deposit_amount, v1.total_asset_deposit_amount * 2)
        };
        0
    }
    
    public fun get_user_withdrawable_lp_amount<T0>(arg0: address) : u64 acquires LpInfo, PoolInfo {
        let v0 = get_user_initial_lp_amount<T0>(arg0);
        get_vested_lp_amount(v0) - 0x1::table::borrow<address, UserInfo>(&borrow_global<PoolInfo<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).user_infos, arg0).lp_withdraw_amount
    }
    
    public fun get_vested_lp_amount(arg0: u64) : u64 {
        let v0 = 0x1::timestamp::now_seconds();
        if (v0 < 1730721600) {
            return 0
        };
        let v1 = arg0 / 3;
        v1 + 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(arg0 - v1, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::min(v0 - 1730721600, 5184000), 5184000)
    }
    
    public fun run_tge_sequence<T0>(arg0: &signer) acquires PoolInfo {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        if (0x1::coin::is_coin_initialized<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::MKL>()) {
        } else {
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::initialize_module(arg0);
        };
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::run_token_generation_event(arg0);
        let v0 = borrow_global_mut<PoolInfo<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::coin::is_account_registered<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::MKL>(0x1::signer::address_of(arg0))) {
        } else {
            0x1::coin::register<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::MKL>(arg0);
        };
        let v1 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::burn_pre_mkl_claim_mkl(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::withdraw_from_freezed_pre_mkl_store(&v0.pre_mkl, v0.total_pre_mkl_deposit_amount));
        let v2 = 0x1::fungible_asset::amount(&v1);
        0x1::primary_fungible_store::deposit(0x1::signer::address_of(arg0), v1);
        let v3 = 0x1::coin::extract_all<T0>(&mut v0.asset_vault);
        let v4 = 0x1::coin::value<T0>(&v3);
        0x1::aptos_account::deposit_coins<T0>(0x1::signer::address_of(arg0), v3);
        if (0x45ef7a3a1221e7c10d190a550aa30fa5bc3208ed06ee3661ec0afa3d8b418580::liquidity_pool::is_pool_exists<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::MKL, T0, 0x45ef7a3a1221e7c10d190a550aa30fa5bc3208ed06ee3661ec0afa3d8b418580::curves::Uncorrelated>()) {
        } else {
            0x45ef7a3a1221e7c10d190a550aa30fa5bc3208ed06ee3661ec0afa3d8b418580::router::register_pool<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::MKL, T0, 0x45ef7a3a1221e7c10d190a550aa30fa5bc3208ed06ee3661ec0afa3d8b418580::curves::Uncorrelated>(arg0);
        };
        0x45ef7a3a1221e7c10d190a550aa30fa5bc3208ed06ee3661ec0afa3d8b418580::scripts::add_liquidity<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::MKL, T0, 0x45ef7a3a1221e7c10d190a550aa30fa5bc3208ed06ee3661ec0afa3d8b418580::curves::Uncorrelated>(arg0, v2, v2, v4, v4);
        let v5 = 0x1::coin::balance<0x9cc3c27b8d398ab6fc82cbc9dc6b43bb9164f72da465631628163822662a8580::lp_coin::LP<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::MKL, T0, 0x45ef7a3a1221e7c10d190a550aa30fa5bc3208ed06ee3661ec0afa3d8b418580::curves::Uncorrelated>>(0x1::signer::address_of(arg0));
        let v6 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::mint_claim_capability<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::GROWTH_POOL>(arg0);
        let v7 = 0x1::transaction_context::generate_auid_address();
        let (v8, _) = 0x1::account::create_resource_account(arg0, 0x1::bcs::to_bytes<address>(&v7));
        let v10 = v8;
        let v11 = 0x1::primary_fungible_store::ensure_primary_store_exists<0x1::fungible_asset::Metadata>(0x1::signer::address_of(&v10), 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::get_metadata());
        0x1::fungible_asset::deposit<0x1::fungible_asset::FungibleStore>(v11, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::claim_mkl_with_cap<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::GROWTH_POOL>(&v6, 1000000000000));
        let v12 = LpInfo<T0>{
            lp_vault         : 0x1::coin::withdraw<0x9cc3c27b8d398ab6fc82cbc9dc6b43bb9164f72da465631628163822662a8580::lp_coin::LP<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::MKL, T0, 0x45ef7a3a1221e7c10d190a550aa30fa5bc3208ed06ee3661ec0afa3d8b418580::curves::Uncorrelated>>(arg0, v5), 
            total_lp_amount  : v5, 
            mkl_reward_vault : v11,
        };
        move_to<LpInfo<T0>>(arg0, v12);
    }
    
    public fun withdraw_asset<T0>(arg0: &signer, arg1: u64) acquires LiquidityAuctionEvents, PoolInfo {
        let v0 = 0x1::timestamp::now_seconds();
        assert!(1724932800 <= v0 && v0 <= 1725537600, 5);
        let v1 = 0x1::signer::address_of(arg0);
        let v2 = borrow_global_mut<PoolInfo<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        assert!(0x1::table::contains<address, UserInfo>(&v2.user_infos, v1), 6);
        let v3 = 0x1::table::borrow_mut<address, UserInfo>(&mut v2.user_infos, v1);
        let v4 = arg1;
        if (arg1 > v3.asset_deposit_amount) {
            v4 = v3.asset_deposit_amount;
        };
        let v5 = v3.phase1_asset_deposit_amount - v3.asset_deposit_amount;
        if (v0 <= 1725364800) {
            v3.phase1_asset_deposit_amount = v3.phase1_asset_deposit_amount - v4;
        } else {
            if (v0 <= 1725451200) {
                let v6 = v3.phase1_asset_deposit_amount / 2;
                if (v6 < v5 + v4) {
                    v4 = v6 - v5;
                };
            } else {
                if (v0 <= 1725537600) {
                    let v7 = v3.phase1_asset_deposit_amount / 2 * (1725537600 - v0) / 86400;
                    if (v7 < v5 + v4) {
                        let v8 = if (v5 < v7) {
                            v7 - v5
                        } else {
                            0
                        };
                        v4 = v8;
                    };
                };
            };
        };
        assert!(v4 > 0, 3);
        0x1::aptos_account::deposit_coins<T0>(v1, 0x1::coin::extract<T0>(&mut v2.asset_vault, v4));
        v3.asset_deposit_amount = v3.asset_deposit_amount - v4;
        assert!(v3.asset_deposit_amount == 0 || v3.asset_deposit_amount >= 10000, 7);
        v2.total_asset_deposit_amount = v2.total_asset_deposit_amount - v4;
        let v9 = WithdrawAssetEvent{
            asset_type                  : 0x1::type_info::type_of<T0>(), 
            asset_withdraw_amount       : v4, 
            asset_total_amount          : v3.asset_deposit_amount, 
            phase1_asset_deposit_amount : v3.phase1_asset_deposit_amount,
        };
        0x1::event::emit_event<WithdrawAssetEvent>(&mut borrow_global_mut<LiquidityAuctionEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).withdraw_asset_events, v9);
        if (v3.asset_deposit_amount == 0 && v3.pre_mkl_deposit_amount == 0) {
            0x1::table::remove<address, UserInfo>(&mut v2.user_infos, v1);
        };
    }
    
    public fun withdraw_lp<T0>(arg0: &signer, arg1: u64) acquires LpInfo, PoolInfo {
        assert!(arg1 > 0, 7);
        claim_mkl_reward<T0>(arg0);
        let v0 = get_user_withdrawable_lp_amount<T0>(0x1::signer::address_of(arg0));
        if (arg1 > v0) {
            arg1 = v0;
        };
        let v1 = 0x1::table::borrow_mut<address, UserInfo>(&mut borrow_global_mut<PoolInfo<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).user_infos, 0x1::signer::address_of(arg0));
        v1.lp_withdraw_amount = v1.lp_withdraw_amount + arg1;
        0x1::aptos_account::deposit_coins<0x9cc3c27b8d398ab6fc82cbc9dc6b43bb9164f72da465631628163822662a8580::lp_coin::LP<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::MKL, T0, 0x45ef7a3a1221e7c10d190a550aa30fa5bc3208ed06ee3661ec0afa3d8b418580::curves::Uncorrelated>>(0x1::signer::address_of(arg0), 0x1::coin::extract<0x9cc3c27b8d398ab6fc82cbc9dc6b43bb9164f72da465631628163822662a8580::lp_coin::LP<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::MKL, T0, 0x45ef7a3a1221e7c10d190a550aa30fa5bc3208ed06ee3661ec0afa3d8b418580::curves::Uncorrelated>>(&mut borrow_global_mut<LpInfo<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).lp_vault, arg1));
    }
    
    public fun withdraw_remaining_reward<T0>(arg0: &signer) acquires LpInfo {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v0 = borrow_global_mut<LpInfo<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        0x1::primary_fungible_store::deposit(0x1::signer::address_of(arg0), 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::withdraw_from_freezed_mkl_store(&v0.mkl_reward_vault, 0x1::fungible_asset::balance<0x1::fungible_asset::FungibleStore>(v0.mkl_reward_vault)));
    }
    
    // decompiled from Move bytecode v6
}


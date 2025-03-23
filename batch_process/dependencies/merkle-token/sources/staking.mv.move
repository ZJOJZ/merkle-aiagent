module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::staking {
    struct LockEvent has drop, store {
        user: address,
        asset_type: 0x1::type_info::TypeInfo,
        amount: u64,
        lock_time: u64,
        unlock_time: u64,
    }
    
    struct StakingEvents has key {
        staking_lock_events: 0x1::event::EventHandle<LockEvent>,
        staking_unlock_events: 0x1::event::EventHandle<UnlockEvent>,
    }
    
    struct UnlockEvent has drop, store {
        user: address,
        mkl_amount: u64,
        esmkl_amount: u64,
        lock_time: u64,
        unlock_time: u64,
    }
    
    struct UserVoteEscrowedMKL has key {
        vemkl_tokens: vector<address>,
        mkl_power: 0x1::simple_map::SimpleMap<u64, u64>,
        esmkl_power: 0x1::simple_map::SimpleMap<u64, u64>,
    }
    
    struct VoteEscrowedMKL has key {
        lock_time: u64,
        unlock_time: u64,
        mutator_ref: 0x4::token::MutatorRef,
        burn_ref: 0x4::token::BurnRef,
        transfer_ref: 0x1::object::TransferRef,
        mkl_token: 0x1::object::Object<0x1::fungible_asset::FungibleStore>,
        mkl_delete_ref: 0x1::object::DeleteRef,
        esmkl_token: 0x1::object::Object<0x1::fungible_asset::FungibleStore>,
        esmkl_delete_ref: 0x1::object::DeleteRef,
        mkl_multiplier: u64,
        esmkl_multiplier: u64,
    }
    
    struct VoteEscrowedMKLConfig has key {
        signer_cap: 0x1::account::SignerCapability,
        collection_mutator_ref: 0x4::collection::MutatorRef,
        royalty_mutator_ref: 0x4::royalty::MutatorRef,
        max_lock_duration: u64,
        min_lock_duration: u64,
        epoch_duration: u64,
        mkl_multiplier: u64,
        esmkl_multiplier: u64,
        max_num_vemkl: u64,
    }
    
    struct VoteEscrowedPowers has key {
        total_mkl_power: 0x1::simple_map::SimpleMap<u64, u64>,
        total_esmkl_power: 0x1::simple_map::SimpleMap<u64, u64>,
    }
    
    public fun admin_swap_vemkl_premkl_to_mkl(arg0: &signer, arg1: address) acquires UserVoteEscrowedMKL, VoteEscrowedMKL, VoteEscrowedMKLConfig {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        swap_vemkl_premkl_to_mkl_internal(arg1);
    }
    
    fun clean_up_ve_powers(arg0: &mut UserVoteEscrowedMKL) acquires VoteEscrowedMKLConfig, VoteEscrowedPowers {
        let v0 = borrow_global_mut<VoteEscrowedPowers>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = borrow_global<VoteEscrowedMKLConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v2 = get_current_epoch_start_time_internal(v1);
        let v3 = 0x1::simple_map::keys<u64, u64>(&v0.total_mkl_power);
        0x1::vector::reverse<u64>(&mut v3);
        let v4 = v3;
        let v5 = 0x1::vector::length<u64>(&v4);
        let v6;
        while (v5 > 0) {
            let v7 = 0x1::vector::pop_back<u64>(&mut v4);
            if (v2 > v7) {
                v6 = (v2 - v7) / v1.epoch_duration > 12;
            } else {
                v6 = false;
            };
            if (v6) {
                let (_, _) = 0x1::simple_map::remove<u64, u64>(&mut v0.total_mkl_power, &v7);
                let (_, _) = 0x1::simple_map::remove<u64, u64>(&mut v0.total_esmkl_power, &v7);
            };
            v5 = v5 - 1;
        };
        0x1::vector::destroy_empty<u64>(v4);
        let v12 = 0x1::simple_map::keys<u64, u64>(&arg0.mkl_power);
        0x1::vector::reverse<u64>(&mut v12);
        let v13 = v12;
        v5 = 0x1::vector::length<u64>(&v13);
        while (v5 > 0) {
            let v14 = 0x1::vector::pop_back<u64>(&mut v13);
            if (v2 > v14) {
                v6 = (v2 - v14) / v1.epoch_duration > 12;
            } else {
                v6 = false;
            };
            if (v6) {
                let (_, _) = 0x1::simple_map::remove<u64, u64>(&mut arg0.mkl_power, &v14);
                let (_, _) = 0x1::simple_map::remove<u64, u64>(&mut arg0.esmkl_power, &v14);
            };
            v5 = v5 - 1;
        };
        0x1::vector::destroy_empty<u64>(v13);
    }
    
    fun drop_vemkl(arg0: VoteEscrowedMKL) {
        let VoteEscrowedMKL {
            lock_time        : _,
            unlock_time      : _,
            mutator_ref      : _,
            burn_ref         : v3,
            transfer_ref     : _,
            mkl_token        : _,
            mkl_delete_ref   : v6,
            esmkl_token      : _,
            esmkl_delete_ref : v8,
            mkl_multiplier   : _,
            esmkl_multiplier : _,
        } = arg0;
        let v11 = v8;
        let v12 = v6;
        0x1::fungible_asset::remove_store(&v12);
        0x1::fungible_asset::remove_store(&v11);
        0x4::token::burn(v3);
    }
    
    public fun get_current_epoch_start_time() : u64 acquires VoteEscrowedMKLConfig {
        get_current_epoch_start_time_internal(borrow_global<VoteEscrowedMKLConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d))
    }
    
    fun get_current_epoch_start_time_internal(arg0: &VoteEscrowedMKLConfig) : u64 {
        let v0 = 0x1::timestamp::now_seconds();
        v0 - v0 % arg0.epoch_duration
    }
    
    public fun get_epoch_duration() : u64 acquires VoteEscrowedMKLConfig {
        borrow_global<VoteEscrowedMKLConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).epoch_duration
    }
    
    public fun get_epoch_user_vote_power(arg0: address, arg1: u64) : (u64, u64) acquires UserVoteEscrowedMKL, VoteEscrowedMKLConfig, VoteEscrowedPowers {
        assert!(arg1 % borrow_global<VoteEscrowedMKLConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).epoch_duration == 0, 5);
        let v0 = borrow_global<VoteEscrowedPowers>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = 0;
        let v2 = 0;
        if (exists<UserVoteEscrowedMKL>(arg0)) {
            let v3 = borrow_global<UserVoteEscrowedMKL>(arg0);
            if (0x1::simple_map::contains_key<u64, u64>(&v3.mkl_power, &arg1)) {
                v1 = *0x1::simple_map::borrow<u64, u64>(&v3.mkl_power, &arg1);
            };
            if (0x1::simple_map::contains_key<u64, u64>(&v3.esmkl_power, &arg1)) {
                v1 = v1 + *0x1::simple_map::borrow<u64, u64>(&v3.esmkl_power, &arg1);
            };
        };
        if (0x1::simple_map::contains_key<u64, u64>(&v0.total_mkl_power, &arg1)) {
            v2 = *0x1::simple_map::borrow<u64, u64>(&v0.total_mkl_power, &arg1);
        };
        if (0x1::simple_map::contains_key<u64, u64>(&v0.total_esmkl_power, &arg1)) {
            v2 = v2 + *0x1::simple_map::borrow<u64, u64>(&v0.total_esmkl_power, &arg1);
        };
        (v1, v2)
    }
    
    public fun increase_lock(arg0: &signer, arg1: address, arg2: 0x1::fungible_asset::FungibleAsset, arg3: u64) acquires StakingEvents, UserVoteEscrowedMKL, VoteEscrowedMKL, VoteEscrowedMKLConfig, VoteEscrowedPowers {
        let v0 = borrow_global_mut<VoteEscrowedMKL>(arg1);
        assert!(0x1::signer::address_of(arg0) == 0x1::object::owner<VoteEscrowedMKL>(0x1::object::address_to_object<VoteEscrowedMKL>(arg1)), 0);
        let v1 = borrow_global_mut<UserVoteEscrowedMKL>(0x1::signer::address_of(arg0));
        clean_up_ve_powers(v1);
        if (0x1::timestamp::now_seconds() <= v0.unlock_time) {
            update_vote_power(0x1::signer::address_of(arg0), v1, v0, false);
        };
        let v2 = if (0x1::timestamp::now_seconds() >= 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::mkl_tge_at() && 0x1::fungible_asset::metadata_from_asset(&arg2) == 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::get_metadata()) {
            if (0x1::fungible_asset::store_metadata<0x1::fungible_asset::FungibleStore>(v0.mkl_token) == 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::get_metadata()) {
                let v3 = 0x1::account::create_signer_with_capability(&borrow_global<VoteEscrowedMKLConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).signer_cap);
                let v4 = 0x1::object::create_object(0x1::signer::address_of(&v3));
                let v5 = 0x1::fungible_asset::create_store<0x1::fungible_asset::Metadata>(&v4, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::get_metadata());
                0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::freeze_mkl_store(&v5, true);
                0x1::fungible_asset::remove_store(&v0.mkl_delete_ref);
                v0.mkl_token = v5;
                v0.mkl_delete_ref = 0x1::object::generate_delete_ref(&v4);
                0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::deposit_to_freezed_mkl_store(&v0.mkl_token, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::swap_pre_mkl_to_mkl_with_fa(arg0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::withdraw_from_freezed_pre_mkl_store(&v0.mkl_token, 0x1::fungible_asset::balance<0x1::fungible_asset::FungibleStore>(v0.mkl_token))));
            };
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::deposit_to_freezed_mkl_store(&v0.mkl_token, arg2);
            0x1::type_info::type_of<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::MKL>()
        } else {
            if (0x1::fungible_asset::metadata_from_asset(&arg2) == 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::get_metadata()) {
                0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::deposit_to_freezed_esmkl_store(&v0.esmkl_token, arg2);
                0x1::type_info::type_of<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::ESMKL>()
            } else {
                assert!(0x1::fungible_asset::metadata_from_asset(&arg2) == 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::get_metadata(), 2);
                0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::deposit_to_freezed_pre_mkl_store(&v0.mkl_token, arg2);
                0x1::type_info::type_of<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::PreMKL>()
            }
        };
        let v6 = borrow_global<VoteEscrowedMKLConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v7 = get_current_epoch_start_time_internal(v6) + v6.epoch_duration;
        let v8 = arg3 - v7;
        assert!(v6.min_lock_duration <= v8 && v8 <= v6.max_lock_duration, 1);
        assert!(v0.unlock_time <= arg3, 1);
        assert!(v8 % 86400 == 0, 1);
        v0.lock_time = v7;
        v0.unlock_time = arg3;
        v0.mkl_multiplier = v6.mkl_multiplier;
        v0.esmkl_multiplier = v6.esmkl_multiplier;
        update_vote_power(0x1::signer::address_of(arg0), v1, v0, true);
        let v9 = LockEvent{
            user        : 0x1::signer::address_of(arg0), 
            asset_type  : v2, 
            amount      : 0x1::fungible_asset::amount(&arg2), 
            lock_time   : v0.lock_time, 
            unlock_time : v0.unlock_time,
        };
        0x1::event::emit_event<LockEvent>(&mut borrow_global_mut<StakingEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).staking_lock_events, v9);
    }
    
    public fun initialize_module(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        if (exists<VoteEscrowedMKLConfig>(0x1::signer::address_of(arg0))) {
        } else {
            let (v0, v1) = 0x1::account::create_resource_account(arg0, x"01");
            let v2 = v0;
            let v3 = 0x4::collection::create_unlimited_collection(&v2, 0x1::string::utf8(b"veMKL"), 0x1::string::utf8(b"veMKL"), 0x1::option::none<0x4::royalty::Royalty>(), 0x1::string::utf8(b""));
            let v4 = VoteEscrowedMKLConfig{
                signer_cap             : v1, 
                collection_mutator_ref : 0x4::collection::generate_mutator_ref(&v3), 
                royalty_mutator_ref    : 0x4::royalty::generate_mutator_ref(0x1::object::generate_extend_ref(&v3)), 
                max_lock_duration      : 31449600, 
                min_lock_duration      : 1209600, 
                epoch_duration         : 604800, 
                mkl_multiplier         : 1, 
                esmkl_multiplier       : 1, 
                max_num_vemkl          : 1,
            };
            move_to<VoteEscrowedMKLConfig>(arg0, v4);
        };
        if (exists<VoteEscrowedPowers>(0x1::signer::address_of(arg0))) {
        } else {
            let v5 = VoteEscrowedPowers{
                total_mkl_power   : 0x1::simple_map::new<u64, u64>(), 
                total_esmkl_power : 0x1::simple_map::new<u64, u64>(),
            };
            move_to<VoteEscrowedPowers>(arg0, v5);
        };
        if (exists<StakingEvents>(0x1::signer::address_of(arg0))) {
        } else {
            let v6 = StakingEvents{
                staking_lock_events   : 0x1::account::new_event_handle<LockEvent>(arg0), 
                staking_unlock_events : 0x1::account::new_event_handle<UnlockEvent>(arg0),
            };
            move_to<StakingEvents>(arg0, v6);
        };
    }
    
    public fun lock(arg0: &signer, arg1: 0x1::fungible_asset::FungibleAsset, arg2: u64) acquires StakingEvents, UserVoteEscrowedMKL, VoteEscrowedMKLConfig, VoteEscrowedPowers {
        assert!(0x1::timestamp::now_seconds() >= 1721908800, 7);
        assert!(0x1::fungible_asset::amount(&arg1) > 100000, 6);
        if (exists<UserVoteEscrowedMKL>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = UserVoteEscrowedMKL{
                vemkl_tokens : 0x1::vector::empty<address>(), 
                mkl_power    : 0x1::simple_map::new<u64, u64>(), 
                esmkl_power  : 0x1::simple_map::new<u64, u64>(),
            };
            move_to<UserVoteEscrowedMKL>(arg0, v0);
        };
        let v1 = borrow_global_mut<UserVoteEscrowedMKL>(0x1::signer::address_of(arg0));
        clean_up_ve_powers(v1);
        assert!(0x1::vector::length<address>(&v1.vemkl_tokens) < borrow_global<VoteEscrowedMKLConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).max_num_vemkl, 4);
        let (v2, v3) = mint_vemkl(0x1::signer::address_of(arg0), arg2);
        let v4 = v3;
        let v5 = v2;
        let v6 = if (0x1::fungible_asset::metadata_from_asset(&arg1) == 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::get_metadata()) {
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::deposit_to_freezed_mkl_store(&v5.mkl_token, arg1);
            0x1::type_info::type_of<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::MKL>()
        } else {
            if (0x1::fungible_asset::metadata_from_asset(&arg1) == 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::get_metadata()) {
                0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::deposit_to_freezed_esmkl_store(&v5.esmkl_token, arg1);
                0x1::type_info::type_of<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::ESMKL>()
            } else {
                assert!(0x1::fungible_asset::metadata_from_asset(&arg1) == 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::get_metadata(), 2);
                0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::deposit_to_freezed_pre_mkl_store(&v5.mkl_token, arg1);
                0x1::type_info::type_of<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::PreMKL>()
            }
        };
        update_vote_power(0x1::signer::address_of(arg0), v1, &v5, true);
        let v7 = LockEvent{
            user        : 0x1::signer::address_of(arg0), 
            asset_type  : v6, 
            amount      : 0x1::fungible_asset::amount(&arg1), 
            lock_time   : v5.lock_time, 
            unlock_time : v5.unlock_time,
        };
        0x1::event::emit_event<LockEvent>(&mut borrow_global_mut<StakingEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).staking_lock_events, v7);
        move_to<VoteEscrowedMKL>(&v4, v5);
        0x1::vector::push_back<address>(&mut v1.vemkl_tokens, 0x1::signer::address_of(&v4));
        return
        abort 2
    }
    
    fun mint_vemkl(arg0: address, arg1: u64) : (VoteEscrowedMKL, signer) acquires VoteEscrowedMKLConfig {
        let v0 = borrow_global<VoteEscrowedMKLConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = get_current_epoch_start_time_internal(v0) + v0.epoch_duration;
        let v2 = arg1 - v1;
        assert!(v0.min_lock_duration <= v2 && v2 <= v0.max_lock_duration, 1);
        assert!(arg1 >= 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::mkl_tge_at() + 1209600, 1);
        assert!(v2 % 86400 == 0, 1);
        let v3 = 0x1::account::create_signer_with_capability(&v0.signer_cap);
        let v4 = 0x4::token::create(&v3, 0x1::string::utf8(b"veMKL"), 0x1::string::utf8(b""), 0x1::string::utf8(b"veMKL"), 0x1::option::none<0x4::royalty::Royalty>(), 0x1::string::utf8(b""));
        let v5 = 0x1::object::generate_signer(&v4);
        let v6 = 0x1::object::generate_transfer_ref(&v4);
        0x1::object::transfer_raw(&v3, 0x1::signer::address_of(&v5), arg0);
        0x1::object::disable_ungated_transfer(&v6);
        let v7 = 0x1::object::create_object(0x1::signer::address_of(&v3));
        let v8 = if (0x1::timestamp::now_seconds() >= 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::mkl_tge_at()) {
            let v8 = 0x1::fungible_asset::create_store<0x1::fungible_asset::Metadata>(&v7, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::get_metadata());
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::freeze_mkl_store(&v8, true);
            v8
        } else {
            let v8 = 0x1::fungible_asset::create_store<0x1::fungible_asset::Metadata>(&v7, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::get_metadata());
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::freeze_pre_mkl_store(&v8, true);
            v8
        };
        let v9 = 0x1::object::create_object(0x1::signer::address_of(&v3));
        let v10 = 0x1::fungible_asset::create_store<0x1::fungible_asset::Metadata>(&v9, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::get_metadata());
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::freeze_esmkl_store(&v10, true);
        let v11 = VoteEscrowedMKL{
            lock_time        : v1, 
            unlock_time      : arg1, 
            mutator_ref      : 0x4::token::generate_mutator_ref(&v4), 
            burn_ref         : 0x4::token::generate_burn_ref(&v4), 
            transfer_ref     : v6, 
            mkl_token        : v8, 
            mkl_delete_ref   : 0x1::object::generate_delete_ref(&v7), 
            esmkl_token      : v10, 
            esmkl_delete_ref : 0x1::object::generate_delete_ref(&v9), 
            mkl_multiplier   : v0.mkl_multiplier, 
            esmkl_multiplier : v0.esmkl_multiplier,
        };
        (v11, v5)
    }
    
    public fun set_epoch_duration(arg0: &signer, arg1: u64) acquires VoteEscrowedMKLConfig {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        borrow_global_mut<VoteEscrowedMKLConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).epoch_duration = arg1;
    }
    
    public fun set_max_lock_duration(arg0: &signer, arg1: u64) acquires VoteEscrowedMKLConfig {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        borrow_global_mut<VoteEscrowedMKLConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).max_lock_duration = arg1;
    }
    
    public fun set_min_lock_duration(arg0: &signer, arg1: u64) acquires VoteEscrowedMKLConfig {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        borrow_global_mut<VoteEscrowedMKLConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).min_lock_duration = arg1;
    }
    
    fun swap_vemkl_premkl_to_mkl_internal(arg0: address) acquires UserVoteEscrowedMKL, VoteEscrowedMKL, VoteEscrowedMKLConfig {
        if (exists<UserVoteEscrowedMKL>(arg0)) {
            let v0 = borrow_global_mut<UserVoteEscrowedMKL>(arg0);
            if (0x1::vector::length<address>(&v0.vemkl_tokens) == 0) {
                return
            };
            let v1 = borrow_global_mut<VoteEscrowedMKL>(*0x1::vector::borrow<address>(&v0.vemkl_tokens, 0));
            if (0x1::fungible_asset::store_metadata<0x1::fungible_asset::FungibleStore>(v1.mkl_token) == 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::get_metadata()) {
                let v2 = 0x1::account::create_signer_with_capability(&borrow_global<VoteEscrowedMKLConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).signer_cap);
                let v3 = 0x1::object::create_object(0x1::signer::address_of(&v2));
                let v4 = 0x1::fungible_asset::create_store<0x1::fungible_asset::Metadata>(&v3, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::get_metadata());
                0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::freeze_mkl_store(&v4, true);
                0x1::fungible_asset::remove_store(&v1.mkl_delete_ref);
                v1.mkl_token = v4;
                v1.mkl_delete_ref = 0x1::object::generate_delete_ref(&v3);
                0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::deposit_to_freezed_mkl_store(&v1.mkl_token, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::swap_pre_mkl_to_mkl_with_fa_v2(arg0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::withdraw_from_freezed_pre_mkl_store(&v1.mkl_token, 0x1::fungible_asset::balance<0x1::fungible_asset::FungibleStore>(v1.mkl_token))));
            };
            return
        };
    }
    
    public fun unlock(arg0: &signer, arg1: address) acquires StakingEvents, UserVoteEscrowedMKL, VoteEscrowedMKL {
        assert!(0x1::signer::address_of(arg0) == 0x1::object::owner<VoteEscrowedMKL>(0x1::object::address_to_object<VoteEscrowedMKL>(arg1)), 0);
        let v0 = move_from<VoteEscrowedMKL>(arg1);
        assert!(0x1::timestamp::now_seconds() >= v0.unlock_time, 3);
        let v1 = 0x1::fungible_asset::balance<0x1::fungible_asset::FungibleStore>(v0.mkl_token);
        if (v1 > 0) {
            if (0x1::fungible_asset::store_metadata<0x1::fungible_asset::FungibleStore>(v0.mkl_token) == 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::get_metadata()) {
                0x1::primary_fungible_store::deposit(0x1::signer::address_of(arg0), 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::withdraw_from_freezed_mkl_store(&v0.mkl_token, v1));
            } else {
                if (0x1::timestamp::now_seconds() >= 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token::mkl_tge_at()) {
                    0x1::primary_fungible_store::deposit(0x1::signer::address_of(arg0), 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::swap_pre_mkl_to_mkl_with_fa(arg0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::withdraw_from_freezed_pre_mkl_store(&v0.mkl_token, v1)));
                } else {
                    0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::deposit_user_pre_mkl(arg0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pre_mkl_token::withdraw_from_freezed_pre_mkl_store(&v0.mkl_token, v1));
                };
            };
        };
        let v2 = 0x1::fungible_asset::balance<0x1::fungible_asset::FungibleStore>(v0.esmkl_token);
        if (v2 > 0) {
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::deposit_user_esmkl(arg0, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::esmkl_token::withdraw_from_freezed_esmkl_store(&v0.esmkl_token, v2));
        };
        0x1::vector::remove_value<address>(&mut borrow_global_mut<UserVoteEscrowedMKL>(0x1::signer::address_of(arg0)).vemkl_tokens, &arg1);
        let v3 = UnlockEvent{
            user         : 0x1::signer::address_of(arg0), 
            mkl_amount   : v1, 
            esmkl_amount : v2, 
            lock_time    : v0.lock_time, 
            unlock_time  : v0.unlock_time,
        };
        0x1::event::emit_event<UnlockEvent>(&mut borrow_global_mut<StakingEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).staking_unlock_events, v3);
        drop_vemkl(v0);
    }
    
    fun update_vote_power(arg0: address, arg1: &mut UserVoteEscrowedMKL, arg2: &VoteEscrowedMKL, arg3: bool) acquires VoteEscrowedMKLConfig, VoteEscrowedPowers {
        let v0 = borrow_global_mut<VoteEscrowedPowers>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = borrow_global<VoteEscrowedMKLConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v2 = get_current_epoch_start_time_internal(v1) + v1.epoch_duration;
        let v3 = arg2.unlock_time - 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::min(v2, arg2.unlock_time);
        let v4 = 0;
        loop {
            if (v3 == 0 || v4 > 52) {
                break
            };
            let v5 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x1::fungible_asset::balance<0x1::fungible_asset::FungibleStore>(arg2.mkl_token) * arg2.mkl_multiplier, v3, v1.max_lock_duration);
            if (0x1::simple_map::contains_key<u64, u64>(&arg1.mkl_power, &v2)) {
                let v6 = 0x1::simple_map::borrow_mut<u64, u64>(&mut arg1.mkl_power, &v2);
                let v7 = if (arg3) {
                    *v6 + v5
                } else {
                    if (*v6 > v5) {
                        *v6 - v5
                    } else {
                        0
                    }
                };
                *v6 = v7;
            } else {
                if (arg3) {
                    0x1::simple_map::add<u64, u64>(&mut arg1.mkl_power, v2, v5);
                };
            };
            if (0x1::simple_map::contains_key<u64, u64>(&v0.total_mkl_power, &v2)) {
                let v8 = 0x1::simple_map::borrow_mut<u64, u64>(&mut v0.total_mkl_power, &v2);
                let v9 = if (arg3) {
                    *v8 + v5
                } else {
                    if (*v8 > v5) {
                        *v8 - v5
                    } else {
                        0
                    }
                };
                *v8 = v9;
            } else {
                if (arg3) {
                    0x1::simple_map::add<u64, u64>(&mut v0.total_mkl_power, v2, v5);
                };
            };
            let v10 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x1::fungible_asset::balance<0x1::fungible_asset::FungibleStore>(arg2.esmkl_token) * arg2.esmkl_multiplier, v3, v1.max_lock_duration);
            if (0x1::simple_map::contains_key<u64, u64>(&arg1.esmkl_power, &v2)) {
                let v11 = 0x1::simple_map::borrow_mut<u64, u64>(&mut arg1.esmkl_power, &v2);
                let v12 = if (arg3) {
                    *v11 + v10
                } else {
                    if (*v11 > v10) {
                        *v11 - v10
                    } else {
                        0
                    }
                };
                *v11 = v12;
            } else {
                if (arg3) {
                    let (_, _) = 0x1::simple_map::upsert<u64, u64>(&mut arg1.esmkl_power, v2, v10);
                };
            };
            if (0x1::simple_map::contains_key<u64, u64>(&v0.total_esmkl_power, &v2)) {
                let v15 = 0x1::simple_map::borrow_mut<u64, u64>(&mut v0.total_esmkl_power, &v2);
                let v16 = if (arg3) {
                    *v15 + v10
                } else {
                    if (*v15 > v10) {
                        *v15 - v10
                    } else {
                        0
                    }
                };
                *v15 = v16;
            } else {
                if (arg3) {
                    let v17 = v2;
                    let (_, _) = 0x1::simple_map::upsert<u64, u64>(&mut v0.total_esmkl_power, v17, v10);
                };
            };
            v2 = v2 + v1.epoch_duration;
            let v20 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::min(v1.epoch_duration, v3);
            v3 = v3 - v20;
            v4 = v4 + 1;
        };
    }
    
    public fun user_swap_vemkl_premkl_to_mkl(arg0: &signer) acquires UserVoteEscrowedMKL, VoteEscrowedMKL, VoteEscrowedMKLConfig {
        swap_vemkl_premkl_to_mkl_internal(0x1::signer::address_of(arg0));
    }
    
    // decompiled from Move bytecode v6
}


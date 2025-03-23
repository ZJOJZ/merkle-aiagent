module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::referral {
    struct AdminCapability has copy, drop, store {
        dummy_field: bool,
    }
    
    struct Affiliates has key {
        users: vector<address>,
    }
    
    struct ClaimEvent has drop, store {
        user: address,
        amount: u64,
        epoch: u64,
        extras: vector<u8>,
    }
    
    struct RebateEvent has drop, store {
        referrer: address,
        referee: address,
        rebate: u64,
        rebate_rate: u64,
        epoch: u64,
        extras: vector<u8>,
    }
    
    struct RefereeUserInfo has drop, store {
        referrer: address,
        registered_at: u64,
    }
    
    struct ReferralConfig has key {
        ancestors: vector<address>,
        params: 0x1::simple_map::SimpleMap<0x1::string::String, vector<u8>>,
    }
    
    struct ReferralEvents has key {
        referral_register_event: 0x1::event::EventHandle<RegisterEvent>,
        referral_rebate_event: 0x1::event::EventHandle<RebateEvent>,
        referral_claim_event: 0x1::event::EventHandle<ClaimEvent>,
    }
    
    struct ReferralInfo has key {
        epoch_period_sec: u64,
        expire_period_sec: u64,
        epoch_start_date_sec: u64,
    }
    
    struct ReferrerUserInfo<phantom T0> has drop, store {
        rebate_rate: u64,
        unclaimed_amount: u64,
        hold_rebate: bool,
    }
    
    struct RegisterEvent has drop, store {
        referrer: address,
        referee: address,
        registered_at: u64,
    }
    
    struct UserInfos<phantom T0> has key {
        referrer: 0x1::table::Table<address, ReferrerUserInfo<T0>>,
        referee: 0x1::table::Table<address, RefereeUserInfo>,
    }
    
    public fun add_affiliate_address(arg0: &signer, arg1: address) acquires Affiliates {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v0 = arg1;
        let v1 = borrow_global_mut<Affiliates>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::vector::contains<address>(&v1.users, &v0)) {
        } else {
            0x1::vector::push_back<address>(&mut v1.users, v0);
        };
    }
    
    public fun add_affiliate_address_admin_cap(arg0: &AdminCapability, arg1: address) acquires Affiliates {
        let v0 = arg1;
        let v1 = borrow_global_mut<Affiliates>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::vector::contains<address>(&v1.users, &v0)) {
        } else {
            0x1::vector::push_back<address>(&mut v1.users, v0);
        };
    }
    
    public(friend) fun add_ancestor_amount<T0>(arg0: address, arg1: 0x1::coin::Coin<T0>) acquires ReferralEvents, UserInfos {
        let v0 = 0x1::coin::value<T0>(&arg1);
        let v1 = borrow_global_mut<UserInfos<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (v0 == 0 || !0x1::table::contains<address, RefereeUserInfo>(&v1.referee, arg0)) {
            abort 2
        };
        let v2 = get_ancestor_address<T0>(v1, arg0);
        let v3 = 0x1::table::borrow_mut<address, ReferrerUserInfo<T0>>(&mut v1.referrer, v2);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::deposit_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::RebateVault, T0>(arg1);
        v3.unclaimed_amount = v3.unclaimed_amount + v0;
        let v4 = RebateEvent{
            referrer    : v2, 
            referee     : arg0, 
            rebate      : v0, 
            rebate_rate : 50000, 
            epoch       : 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number(), 
            extras      : x"02",
        };
        0x1::event::emit_event<RebateEvent>(&mut borrow_global_mut<ReferralEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).referral_rebate_event, v4);
    }
    
    public(friend) fun add_unclaimed_amount<T0>(arg0: address, arg1: 0x1::coin::Coin<T0>) acquires ReferralEvents, UserInfos {
        let v0 = 0x1::coin::value<T0>(&arg1);
        let v1 = borrow_global_mut<UserInfos<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (v0 == 0 || !0x1::table::contains<address, RefereeUserInfo>(&v1.referee, arg0)) {
            abort 2
        };
        let v2 = 0x1::table::borrow<address, RefereeUserInfo>(&v1.referee, arg0);
        let v3 = 0x1::table::borrow_mut<address, ReferrerUserInfo<T0>>(&mut v1.referrer, v2.referrer);
        if (v3.hold_rebate) {
            abort 4
        };
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::deposit_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::RebateVault, T0>(arg1);
        v3.unclaimed_amount = v3.unclaimed_amount + v0;
        let v4 = RebateEvent{
            referrer    : v2.referrer, 
            referee     : arg0, 
            rebate      : v0, 
            rebate_rate : v3.rebate_rate, 
            epoch       : 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number(), 
            extras      : x"01",
        };
        0x1::event::emit_event<RebateEvent>(&mut borrow_global_mut<ReferralEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).referral_rebate_event, v4);
    }
    
    public fun check_affiliates_address(arg0: address) : bool acquires Affiliates {
        0x1::vector::contains<address>(&borrow_global_mut<Affiliates>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).users, &arg0)
    }
    
    public fun claim_all<T0>(arg0: &signer) acquires ReferralEvents, UserInfos {
        let v0 = borrow_global_mut<UserInfos<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        assert!(0x1::table::contains<address, ReferrerUserInfo<T0>>(&v0.referrer, 0x1::signer::address_of(arg0)), 2);
        let v1 = 0x1::table::borrow_mut<address, ReferrerUserInfo<T0>>(&mut v0.referrer, 0x1::signer::address_of(arg0));
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::fa_box::deposit_asset_to_user<T0>(0x1::signer::address_of(arg0), 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault::withdraw_vault<0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::vault_type::RebateVault, T0>(v1.unclaimed_amount));
        let v2 = ClaimEvent{
            user   : 0x1::signer::address_of(arg0), 
            amount : v1.unclaimed_amount, 
            epoch  : 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number(), 
            extras : 0x1::vector::empty<u8>(),
        };
        0x1::event::emit_event<ClaimEvent>(&mut borrow_global_mut<ReferralEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).referral_claim_event, v2);
        v1.unclaimed_amount = 0;
    }
    
    public fun enable_ancestor_admin_cap(arg0: &AdminCapability, arg1: address) acquires ReferralConfig {
        let v0 = borrow_global_mut<ReferralConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::vector::contains<address>(&v0.ancestors, &arg1)) {
        } else {
            0x1::vector::push_back<address>(&mut v0.ancestors, arg1);
        };
    }
    
    public fun generate_admin_cap(arg0: &signer) : AdminCapability {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        AdminCapability{dummy_field: false}
    }
    
    fun get_ancestor_address<T0>(arg0: &UserInfos<T0>, arg1: address) : address {
        if (0x1::table::contains<address, RefereeUserInfo>(&arg0.referee, arg1)) {
            let v0 = 0x1::table::borrow<address, RefereeUserInfo>(&arg0.referee, arg1);
            if (0x1::table::contains<address, RefereeUserInfo>(&arg0.referee, v0.referrer)) {
                return 0x1::table::borrow<address, RefereeUserInfo>(&arg0.referee, v0.referrer).referrer
            };
            return @0x0
        };
        @0x0
    }
    
    public fun get_ancestor_rebate_rate() : u64 {
        50000
    }
    
    public fun get_epoch_info() : (u64, u64, u64) {
        let v0 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number();
        let v1 = 0;
        if (v0 > 1) {
            v1 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_season_end_sec(v0 - 1);
        };
        (v1, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_season_end_sec(v0), v0)
    }
    
    public fun get_rebate_rate<T0>(arg0: address) : u64 acquires ReferralInfo, UserInfos {
        let v0 = borrow_global_mut<UserInfos<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::table::contains<address, RefereeUserInfo>(&v0.referee, arg0)) {
            let v1 = 0x1::table::borrow<address, RefereeUserInfo>(&v0.referee, arg0);
            let v2 = 0x1::table::borrow_mut<address, ReferrerUserInfo<T0>>(&mut v0.referrer, v1.referrer);
            if (v2.hold_rebate || v1.registered_at + borrow_global<ReferralInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).expire_period_sec < 0x1::timestamp::now_seconds()) {
                return 0
            };
            return v2.rebate_rate
        };
        0
    }
    
    public fun get_referrer_address<T0>(arg0: address) : address acquires UserInfos {
        if (exists<UserInfos<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)) {
            let v0 = borrow_global<UserInfos<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
            if (0x1::table::contains<address, RefereeUserInfo>(&v0.referee, arg0)) {
                return 0x1::table::borrow<address, RefereeUserInfo>(&v0.referee, arg0).referrer
            };
            return @0x0
        };
        @0x0
    }
    
    fun init_module<T0>(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        if (exists<ReferralInfo>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = ReferralInfo{
                epoch_period_sec     : 2419200, 
                expire_period_sec    : 31536000, 
                epoch_start_date_sec : 0x1::timestamp::now_seconds() - 0x1::timestamp::now_seconds() % 86400,
            };
            move_to<ReferralInfo>(arg0, v0);
        };
        if (exists<UserInfos<T0>>(0x1::signer::address_of(arg0))) {
        } else {
            let v1 = UserInfos<T0>{
                referrer : 0x1::table::new<address, ReferrerUserInfo<T0>>(), 
                referee  : 0x1::table::new<address, RefereeUserInfo>(),
            };
            move_to<UserInfos<T0>>(arg0, v1);
        };
        if (exists<ReferralEvents>(0x1::signer::address_of(arg0))) {
        } else {
            let v2 = ReferralEvents{
                referral_register_event : 0x1::account::new_event_handle<RegisterEvent>(arg0), 
                referral_rebate_event   : 0x1::account::new_event_handle<RebateEvent>(arg0), 
                referral_claim_event    : 0x1::account::new_event_handle<ClaimEvent>(arg0),
            };
            move_to<ReferralEvents>(arg0, v2);
        };
        if (exists<Affiliates>(0x1::signer::address_of(arg0))) {
        } else {
            let v3 = Affiliates{users: 0x1::vector::empty<address>()};
            move_to<Affiliates>(arg0, v3);
        };
        if (exists<ReferralConfig>(0x1::signer::address_of(arg0))) {
        } else {
            let v4 = ReferralConfig{
                ancestors : 0x1::vector::empty<address>(), 
                params    : 0x1::simple_map::new<0x1::string::String, vector<u8>>(),
            };
            move_to<ReferralConfig>(arg0, v4);
        };
    }
    
    public fun initialize<T0>(arg0: &signer) {
        init_module<T0>(arg0);
    }
    
    public fun is_ancestor_enabled<T0>(arg0: address) : bool acquires ReferralConfig, UserInfos {
        let v0 = get_ancestor_address<T0>(borrow_global<UserInfos<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d), arg0);
        0x1::vector::contains<address>(&borrow_global<ReferralConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).ancestors, &v0)
    }
    
    public fun migrate_referral_info<T0, T1>(arg0: &AdminCapability, arg1: vector<address>) acquires UserInfos {
        let v0 = arg1;
        0x1::vector::reverse<address>(&mut v0);
        let v1 = v0;
        let v2 = 0x1::vector::length<address>(&v1);
        while (v2 > 0) {
            let v3 = 0x1::vector::pop_back<address>(&mut v1);
            let v4 = 0;
            let v5 = false;
            let v6 = false;
            let v7 = @0x0;
            let v8 = 0;
            let v9 = false;
            let v10 = borrow_global<UserInfos<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
            if (0x1::table::contains<address, ReferrerUserInfo<T0>>(&v10.referrer, v3)) {
                let v11 = 0x1::table::borrow<address, ReferrerUserInfo<T0>>(&v10.referrer, v3);
                v4 = v11.rebate_rate;
                v5 = v11.hold_rebate;
                v6 = true;
            };
            if (0x1::table::contains<address, RefereeUserInfo>(&v10.referee, v3)) {
                let v12 = 0x1::table::borrow<address, RefereeUserInfo>(&v10.referee, v3);
                v7 = v12.referrer;
                v8 = v12.registered_at;
                v9 = true;
            };
            if (v6 || v9) {
                let v13 = borrow_global_mut<UserInfos<T1>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
                if (v6) {
                    let v14 = ReferrerUserInfo<T1>{
                        rebate_rate      : v4, 
                        unclaimed_amount : 0, 
                        hold_rebate      : v5,
                    };
                    0x1::table::add<address, ReferrerUserInfo<T1>>(&mut v13.referrer, v3, v14);
                };
                if (v9) {
                    let v15 = RefereeUserInfo{
                        referrer      : v7, 
                        registered_at : v8,
                    };
                    0x1::table::add<address, RefereeUserInfo>(&mut v13.referee, v3, v15);
                };
            };
            v2 = v2 - 1;
        };
        0x1::vector::destroy_empty<address>(v1);
    }
    
    public(friend) fun register_referrer<T0>(arg0: address, arg1: address) : bool acquires ReferralEvents, UserInfos {
        let v0 = borrow_global_mut<UserInfos<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::table::contains<address, RefereeUserInfo>(&v0.referee, arg0) || arg0 == arg1 || arg1 == @0x0) {
            return false
        };
        if (0x1::table::contains<address, RefereeUserInfo>(&v0.referee, arg1)) {
            if (0x1::table::borrow<address, RefereeUserInfo>(&v0.referee, arg1).referrer == arg0) {
                return false
            };
        };
        if (0x1::table::contains<address, ReferrerUserInfo<T0>>(&v0.referrer, arg1)) {
        } else {
            let v1 = ReferrerUserInfo<T0>{
                rebate_rate      : 50000, 
                unclaimed_amount : 0, 
                hold_rebate      : false,
            };
            0x1::table::upsert<address, ReferrerUserInfo<T0>>(&mut v0.referrer, arg1, v1);
        };
        let v2 = RefereeUserInfo{
            referrer      : arg1, 
            registered_at : 0x1::timestamp::now_seconds(),
        };
        0x1::table::upsert<address, RefereeUserInfo>(&mut v0.referee, arg0, v2);
        let v3 = RegisterEvent{
            referrer      : arg1, 
            referee       : arg0, 
            registered_at : 0x1::timestamp::now_seconds(),
        };
        0x1::event::emit_event<RegisterEvent>(&mut borrow_global_mut<ReferralEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).referral_register_event, v3);
        true
    }
    
    public fun remove_affiliate_address(arg0: &signer, arg1: address) acquires Affiliates {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v0 = borrow_global_mut<Affiliates>(0x1::signer::address_of(arg0));
        if (0x1::vector::contains<address>(&v0.users, &arg1)) {
            0x1::vector::remove_value<address>(&mut v0.users, &arg1);
            return
        };
    }
    
    public fun remove_ancestor_admin_cap(arg0: &AdminCapability, arg1: address) acquires ReferralConfig {
        let v0 = borrow_global_mut<ReferralConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::vector::contains<address>(&v0.ancestors, &arg1)) {
            0x1::vector::remove_value<address>(&mut v0.ancestors, &arg1);
        };
    }
    
    public(friend) fun remove_referrer<T0>(arg0: address) acquires UserInfos {
        let v0 = borrow_global_mut<UserInfos<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::table::contains<address, RefereeUserInfo>(&v0.referee, arg0)) {
            0x1::table::remove<address, RefereeUserInfo>(&mut v0.referee, arg0);
        };
    }
    
    public fun set_epoch_period_sec(arg0: &signer, arg1: u64) acquires ReferralInfo {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        borrow_global_mut<ReferralInfo>(0x1::signer::address_of(arg0)).epoch_period_sec = arg1;
    }
    
    public fun set_expire_period_sec(arg0: &signer, arg1: u64) acquires ReferralInfo {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        borrow_global_mut<ReferralInfo>(0x1::signer::address_of(arg0)).expire_period_sec = arg1;
    }
    
    public fun set_user_hold_rebate<T0>(arg0: &signer, arg1: address, arg2: bool) acquires UserInfos {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        0x1::table::borrow_mut<address, ReferrerUserInfo<T0>>(&mut borrow_global_mut<UserInfos<T0>>(0x1::signer::address_of(arg0)).referrer, arg1).hold_rebate = arg2;
    }
    
    public fun set_user_rebate_rate<T0>(arg0: &signer, arg1: address, arg2: u64) acquires UserInfos {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        set_user_rebate_rate_internal<T0>(arg1, arg2);
    }
    
    public fun set_user_rebate_rate_admin_cap<T0>(arg0: &AdminCapability, arg1: address, arg2: u64) acquires UserInfos {
        set_user_rebate_rate_internal<T0>(arg1, arg2);
    }
    
    fun set_user_rebate_rate_internal<T0>(arg0: address, arg1: u64) acquires UserInfos {
        let v0 = borrow_global_mut<UserInfos<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::table::contains<address, ReferrerUserInfo<T0>>(&v0.referrer, arg0)) {
        } else {
            let v1 = ReferrerUserInfo<T0>{
                rebate_rate      : 50000, 
                unclaimed_amount : 0, 
                hold_rebate      : false,
            };
            0x1::table::upsert<address, ReferrerUserInfo<T0>>(&mut v0.referrer, arg0, v1);
        };
        if (arg1 > 500000) {
            abort 3
        };
        0x1::table::borrow_mut<address, ReferrerUserInfo<T0>>(&mut v0.referrer, arg0).rebate_rate = arg1;
    }
    
    // decompiled from Move bytecode v6
}


module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::point {
    struct AddPointEvent has drop, store {
        current_round: u64,
        user: address,
        point_amount: u64,
    }
    
    struct PointCapability has copy, drop, store {
        dummy_field: bool,
    }
    
    struct PointCapabilityCandidate has key {
        candidate: vector<address>,
    }
    
    struct RoundInfo has store {
        start_at_sec: u64,
        finish_at_sec: u64,
        user_points: 0x1::table::Table<u64, 0x1::table::Table<address, u64>>,
    }
    
    struct Rounds has key {
        current_round: u64,
        round_infos: 0x1::table::Table<u64, RoundInfo>,
    }
    
    public entry fun add_point_capability_candidate(arg0: &signer, arg1: address) acquires PointCapabilityCandidate {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        0x1::vector::push_back<address>(&mut borrow_global_mut<PointCapabilityCandidate>(0x1::signer::address_of(arg0)).candidate, arg1);
    }
    
    public fun add_point_to_user(arg0: &PointCapability, arg1: address, arg2: u64) acquires Rounds {
        if (exists<Rounds>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d) && 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::blocked_user::check_blocked(arg1) || true) {
            return
        };
        let v0 = borrow_global_mut<Rounds>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = v0.current_round;
        if (is_round_ended_internal(v0, v1)) {
            v0.current_round = v1 + 1;
        };
        if (is_current_round_started_internal(v0)) {
            let v2 = 0x1::table::borrow_mut<u64, RoundInfo>(&mut v0.round_infos, v0.current_round);
            let v3 = get_current_time_idx();
            if (0x1::table::contains<u64, 0x1::table::Table<address, u64>>(&v2.user_points, v3)) {
            } else {
                0x1::table::add<u64, 0x1::table::Table<address, u64>>(&mut v2.user_points, v3, 0x1::table::new<address, u64>());
            };
            let v4 = 0x1::table::borrow_mut_with_default<address, u64>(0x1::table::borrow_mut<u64, 0x1::table::Table<address, u64>>(&mut v2.user_points, v3), arg1, 0);
            *v4 = *v4 + arg2;
            let v5 = AddPointEvent{
                current_round : v0.current_round, 
                user          : arg1, 
                point_amount  : arg2,
            };
            0x1::event::emit<AddPointEvent>(v5);
            return
        };
    }
    
    public entry fun add_point_to_user_test(arg0: &signer, arg1: u64) {
        abort 0
    }
    
    public fun claim_point_capability_candidate(arg0: &signer) : PointCapability acquires PointCapabilityCandidate {
        let v0 = borrow_global_mut<PointCapabilityCandidate>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = 0x1::signer::address_of(arg0);
        let (v2, v3) = 0x1::vector::index_of<address>(&v0.candidate, &v1);
        assert!(v2, 0);
        0x1::vector::swap_remove<address>(&mut v0.candidate, v3);
        PointCapability{dummy_field: false}
    }
    
    public fun get_current_round() : u64 acquires Rounds {
        borrow_global<Rounds>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).current_round
    }
    
    fun get_current_time_idx() : u64 {
        (0x1::timestamp::now_seconds() + 43200) / 86400
    }
    
    public fun get_round_finish_at_sec(arg0: u64) : u64 acquires Rounds {
        0x1::table::borrow<u64, RoundInfo>(&borrow_global<Rounds>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).round_infos, arg0).finish_at_sec
    }
    
    public fun get_user_current_point_amount(arg0: address) : u64 acquires Rounds {
        if (exists<Rounds>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)) {
            let v0 = borrow_global<Rounds>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
            if (0x1::table::contains<u64, RoundInfo>(&v0.round_infos, v0.current_round)) {
                let v1 = 0x1::table::borrow<u64, RoundInfo>(&v0.round_infos, v0.current_round);
                let v2 = 0x1::timestamp::now_seconds();
                if (v2 < v1.start_at_sec || v1.finish_at_sec < v2) {
                    return 0
                };
                let v3 = get_current_time_idx();
                if (0x1::table::contains<u64, 0x1::table::Table<address, u64>>(&v1.user_points, v3)) {
                    let v4 = 0x1::table::borrow<u64, 0x1::table::Table<address, u64>>(&v1.user_points, v3);
                    if (0x1::table::contains<address, u64>(v4, arg0)) {
                        return *0x1::table::borrow<address, u64>(v4, arg0)
                    };
                    return 0
                };
                return 0
            };
            return 0
        };
        0
    }
    
    public entry fun initialize_module(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        if (exists<PointCapabilityCandidate>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = PointCapabilityCandidate{candidate: 0x1::vector::empty<address>()};
            move_to<PointCapabilityCandidate>(arg0, v0);
        };
    }
    
    public fun is_current_round_started() : bool acquires Rounds {
        if (exists<Rounds>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)) {
            return is_current_round_started_internal(borrow_global<Rounds>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d))
        };
        false
    }
    
    fun is_current_round_started_internal(arg0: &Rounds) : bool {
        if (0x1::table::contains<u64, RoundInfo>(&arg0.round_infos, arg0.current_round)) {
            return 0x1::table::borrow<u64, RoundInfo>(&arg0.round_infos, arg0.current_round).start_at_sec <= 0x1::timestamp::now_seconds()
        };
        false
    }
    
    public fun is_round_ended(arg0: u64) : bool acquires Rounds {
        if (exists<Rounds>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)) {
            return is_round_ended_internal(borrow_global<Rounds>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d), arg0)
        };
        false
    }
    
    fun is_round_ended_internal(arg0: &Rounds, arg1: u64) : bool {
        if (0x1::table::contains<u64, RoundInfo>(&arg0.round_infos, arg1)) {
            return 0x1::table::borrow<u64, RoundInfo>(&arg0.round_infos, arg1).finish_at_sec < 0x1::timestamp::now_seconds()
        };
        false
    }
    
    public entry fun set_current_round(arg0: &signer, arg1: u64) acquires Rounds {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        let v0 = borrow_global_mut<Rounds>(0x1::signer::address_of(arg0));
        assert!(0x1::table::contains<u64, RoundInfo>(&v0.round_infos, arg1), 1);
        v0.current_round = arg1;
    }
    
    public entry fun set_round(arg0: &signer, arg1: u64, arg2: u64, arg3: u64) acquires Rounds {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        if (exists<Rounds>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = Rounds{
                current_round : 0, 
                round_infos   : 0x1::table::new<u64, RoundInfo>(),
            };
            move_to<Rounds>(arg0, v0);
        };
        let v1 = borrow_global_mut<Rounds>(0x1::signer::address_of(arg0));
        if (0x1::table::contains<u64, RoundInfo>(&v1.round_infos, arg1)) {
            let v2 = 0x1::table::borrow_mut<u64, RoundInfo>(&mut v1.round_infos, arg1);
            v2.start_at_sec = arg2;
            v2.finish_at_sec = arg3;
        } else {
            let v3 = RoundInfo{
                start_at_sec  : arg2, 
                finish_at_sec : arg3, 
                user_points   : 0x1::table::new<u64, 0x1::table::Table<address, u64>>(),
            };
            0x1::table::add<u64, RoundInfo>(&mut v1.round_infos, arg1, v3);
        };
        if (v1.current_round == 0) {
            v1.current_round = arg1;
        };
    }
    
    public entry fun set_start_finish_at_sec(arg0: &signer, arg1: u64, arg2: u64, arg3: u64) acquires Rounds {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        let v0 = 0x1::table::borrow_mut<u64, RoundInfo>(&mut borrow_global_mut<Rounds>(0x1::signer::address_of(arg0)).round_infos, arg1);
        v0.start_at_sec = arg2;
        v0.finish_at_sec = arg3;
    }
    
    public(friend) fun spend_point(arg0: address, arg1: u64) acquires Rounds {
        let v0 = borrow_global_mut<Rounds>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = 0x1::table::borrow_mut_with_default<address, u64>(0x1::table::borrow_mut<u64, 0x1::table::Table<address, u64>>(&mut 0x1::table::borrow_mut<u64, RoundInfo>(&mut v0.round_infos, v0.current_round).user_points, get_current_time_idx()), arg0, 0);
        assert!(arg1 <= *v1, 2);
        *v1 = *v1 - arg1;
    }
    
    // decompiled from Move bytecode v6
}


module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::shard_token {
    struct BurnEvent has drop, store {
        user: address,
        amount: u64,
    }
    
    struct MintEvent has drop, store {
        user: address,
        amount: u64,
    }
    
    struct ShardEvents has key {
        mint_events: 0x1::event::EventHandle<MintEvent>,
        burn_event: 0x1::event::EventHandle<BurnEvent>,
    }
    
    struct ShardInfo has key {
        supply: u64,
        user_balance: 0x1::table::Table<address, u64>,
    }
    
    public(friend) fun burn(arg0: address, arg1: u64) acquires ShardEvents, ShardInfo {
        let v0 = borrow_global_mut<ShardInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::table::contains<address, u64>(&v0.user_balance, arg0)) {
        } else {
            0x1::table::upsert<address, u64>(&mut v0.user_balance, arg0, 0);
        };
        let v1 = 0x1::table::borrow_mut<address, u64>(&mut v0.user_balance, arg0);
        assert!(arg1 <= *v1, 2);
        *v1 = *v1 - arg1;
        v0.supply = v0.supply - arg1;
        let v2 = BurnEvent{
            user   : arg0, 
            amount : arg1,
        };
        0x1::event::emit_event<BurnEvent>(&mut borrow_global_mut<ShardEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).burn_event, v2);
    }
    
    public fun get_shard_balance(arg0: address) : u64 acquires ShardInfo {
        let v0 = 0;
        *0x1::table::borrow_with_default<address, u64>(&borrow_global_mut<ShardInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).user_balance, arg0, &v0)
    }
    
    public fun initialize_module(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        if (exists<ShardInfo>(0x1::signer::address_of(arg0))) {
            return
        };
        let v0 = ShardInfo{
            supply       : 0, 
            user_balance : 0x1::table::new<address, u64>(),
        };
        move_to<ShardInfo>(arg0, v0);
        let v1 = ShardEvents{
            mint_events : 0x1::account::new_event_handle<MintEvent>(arg0), 
            burn_event  : 0x1::account::new_event_handle<BurnEvent>(arg0),
        };
        move_to<ShardEvents>(arg0, v1);
    }
    
    public(friend) fun mint(arg0: address, arg1: u64) acquires ShardEvents, ShardInfo {
        let v0 = borrow_global_mut<ShardInfo>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (0x1::table::contains<address, u64>(&v0.user_balance, arg0)) {
        } else {
            0x1::table::upsert<address, u64>(&mut v0.user_balance, arg0, 0);
        };
        let v1 = 0x1::table::borrow_mut<address, u64>(&mut v0.user_balance, arg0);
        *v1 = *v1 + arg1;
        v0.supply = v0.supply + arg1;
        let v2 = MintEvent{
            user   : arg0, 
            amount : arg1,
        };
        0x1::event::emit_event<MintEvent>(&mut borrow_global_mut<ShardEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).mint_events, v2);
    }
    
    // decompiled from Move bytecode v6
}


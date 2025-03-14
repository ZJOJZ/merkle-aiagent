module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::random {
    struct RandomPadding has key {
        num: u64,
        store: 0x1::smart_table::SmartTable<u64, RandomPaddingStore>,
        table: 0x1::table::Table<u64, RandomPaddingStore>,
    }
    
    struct RandomPaddingStore has copy, drop, store {
        addresses: vector<address>,
    }
    
    struct RandomSalt has key {
        salt: u64,
    }
    
    public fun add_random_padding() acquires RandomPadding {
        let v0 = borrow_global_mut<RandomPadding>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = RandomPaddingStore{addresses: vector[@0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa, @0xa]};
        let v2 = 0;
        while (v2 < 5) {
            v0.num = (v0.num + 1) % 10;
            0x1::smart_table::upsert<u64, RandomPaddingStore>(&mut v0.store, v0.num, v1);
            v2 = v2 + 1;
        };
    }
    
    public fun get_random_between(arg0: u64, arg1: u64) : u64 acquires RandomSalt {
        let v0 = borrow_global_mut<RandomSalt>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        v0.salt = v0.salt + 1;
        let v1 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::price_oracle::get_price_for_random() + 0x1::timestamp::now_seconds() + 0x1::timestamp::now_microseconds() + v0.salt;
        0x1::aptos_hash::sip_hash_from_value<u64>(&v1) % (arg1 - arg0 + 1) + arg0
    }
    
    public fun initialize_module(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        if (exists<RandomSalt>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = RandomSalt{salt: 0};
            move_to<RandomSalt>(arg0, v0);
        };
        if (exists<RandomPadding>(0x1::signer::address_of(arg0))) {
        } else {
            let v1 = RandomPadding{
                num   : 0, 
                store : 0x1::smart_table::new<u64, RandomPaddingStore>(), 
                table : 0x1::table::new<u64, RandomPaddingStore>(),
            };
            move_to<RandomPadding>(arg0, v1);
        };
    }
    
    // decompiled from Move bytecode v6
}


module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season {
    struct SeasonInfo has copy, drop, store {
        end_sec: u64,
    }
    
    struct SeasonView has copy, drop {
        season_number: u64,
        end_sec: u64,
    }
    
    struct Seasons has key {
        season_info: 0x1::simple_map::SimpleMap<u64, SeasonInfo>,
    }
    
    public fun add_new_season(arg0: &signer, arg1: u64) acquires Seasons {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v0 = borrow_global_mut<Seasons>(0x1::signer::address_of(arg0));
        let v1 = 0x1::simple_map::keys<u64, SeasonInfo>(&v0.season_info);
        let v2 = SeasonInfo{end_sec: arg1};
        0x1::simple_map::add<u64, SeasonInfo>(&mut v0.season_info, 0x1::vector::length<u64>(&v1) + 1, v2);
    }
    
    public fun get_current_season_info() : SeasonView acquires Seasons {
        let v0 = get_current_season_number();
        let v1 = *0x1::simple_map::borrow<u64, SeasonInfo>(&borrow_global<Seasons>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).season_info, &v0);
        SeasonView{
            season_number : v0, 
            end_sec       : v1.end_sec,
        }
    }
    
    public fun get_current_season_number() : u64 acquires Seasons {
        if (exists<Seasons>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)) {
            let v0 = borrow_global_mut<Seasons>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
            let v1 = 1;
            while (0x1::simple_map::contains_key<u64, SeasonInfo>(&v0.season_info, &v1)) {
                if (0x1::timestamp::now_seconds() <= 0x1::simple_map::borrow<u64, SeasonInfo>(&v0.season_info, &v1).end_sec) {
                    break
                };
                v1 = v1 + 1;
            };
            return v1
        };
        1
    }
    
    public fun get_season_end_sec(arg0: u64) : u64 acquires Seasons {
        let v0 = *0x1::simple_map::borrow<u64, SeasonInfo>(&borrow_global<Seasons>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).season_info, &arg0);
        v0.end_sec
    }
    
    public fun get_season_info(arg0: u64) : SeasonView acquires Seasons {
        let v0 = *0x1::simple_map::borrow<u64, SeasonInfo>(&borrow_global<Seasons>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).season_info, &arg0);
        SeasonView{
            season_number : arg0, 
            end_sec       : v0.end_sec,
        }
    }
    
    public fun initialize_module(arg0: &signer) acquires Seasons {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        if (exists<Seasons>(0x1::signer::address_of(arg0))) {
            return
        };
        let v0 = Seasons{season_info: 0x1::simple_map::new<u64, SeasonInfo>()};
        move_to<Seasons>(arg0, v0);
        let v1 = SeasonInfo{end_sec: 0x1::timestamp::now_seconds() - 0x1::timestamp::now_seconds() % 86400 + 1209600};
        0x1::simple_map::add<u64, SeasonInfo>(&mut borrow_global_mut<Seasons>(0x1::signer::address_of(arg0)).season_info, 1, v1);
    }
    
    public fun set_season_end_sec(arg0: &signer, arg1: u64, arg2: u64) acquires Seasons {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        let v0 = SeasonInfo{end_sec: arg2};
        let (_, _) = 0x1::simple_map::upsert<u64, SeasonInfo>(&mut borrow_global_mut<Seasons>(0x1::signer::address_of(arg0)).season_info, arg1, v0);
    }
    
    // decompiled from Move bytecode v6
}


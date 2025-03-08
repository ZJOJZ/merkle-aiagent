module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::username {
    struct TicketIssueEvent has drop, store {
        ticket: address,
        user: address,
    }
    
    struct Username has drop, key {
        name: 0x1::string::String,
        registered_at: u64,
        expired_at: u64,
    }
    
    struct UsernameDeleteEvent has drop, store {
        user: address,
        name: 0x1::string::String,
    }
    
    struct UsernameRegisterEvent has drop, store {
        user: address,
        name: 0x1::string::String,
        registered_at: u64,
        expired_at: u64,
    }
    
    struct UsernameResource has key {
        collection_mutator_ref: 0x4::collection::MutatorRef,
        royalty_mutator_ref: 0x4::royalty::MutatorRef,
        signer_cap: 0x1::account::SignerCapability,
        duration: u64,
        renewal_available_duration: u64,
        change_cooldown_duration: u64,
        registry: 0x1::table::Table<0x1::string::String, address>,
    }
    
    struct UsernameTicket has key {
        owner: address,
        transfer_ref: 0x1::object::TransferRef,
        mutator_ref: 0x4::token::MutatorRef,
        burn_ref: 0x4::token::BurnRef,
    }
    
    fun burn_ticket(arg0: UsernameTicket) {
        let UsernameTicket {
            owner        : _,
            transfer_ref : _,
            mutator_ref  : _,
            burn_ref     : v3,
        } = arg0;
        0x4::token::burn(v3);
    }
    
    fun check_available(arg0: 0x1::string::String) : bool acquires Username, UsernameResource {
        let v0 = 0x1::string::length(&arg0);
        let v1 = if (true) {
            if (1 < v0) {
                v0 < 13
            } else {
                false
            }
        } else {
            false
        };
        let v2 = v1;
        let v3 = *0x1::string::bytes(&arg0);
        0x1::vector::reverse<u8>(&mut v3);
        let v4 = v3;
        let v5 = 0x1::vector::length<u8>(&v4);
        let v6;
        while (v5 > 0) {
            let v7 = 0x1::vector::pop_back<u8>(&mut v4);
            let v8 = if (v2) {
                if (47 < v7) {
                    v6 = v7 < 58;
                } else {
                    v6 = false;
                };
                let v9 = if (v6) {
                    true
                } else {
                    if (64 < v7) {
                        v7 < 91
                    } else {
                        false
                    }
                };
                if (v9) {
                    true
                } else {
                    if (96 < v7) {
                        v7 < 123
                    } else {
                        false
                    }
                }
            } else {
                false
            };
            v2 = v8;
            v5 = v5 - 1;
        };
        0x1::vector::destroy_empty<u8>(v4);
        let v10 = borrow_global<UsernameResource>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v11 = to_lowercase(arg0);
        if (0x1::table::contains<0x1::string::String, address>(&v10.registry, v11)) {
            if (v2) {
                v6 = borrow_global<Username>(*0x1::table::borrow<0x1::string::String, address>(&v10.registry, v11)).expired_at < 0x1::timestamp::now_seconds();
            } else {
                v6 = false;
            };
            v2 = v6;
        };
        v2
    }
    
    public entry fun delete_username(arg0: &signer) acquires Username, UsernameResource {
        assert!(exists<Username>(0x1::signer::address_of(arg0)), 1);
        delete_username_internal(arg0, borrow_global_mut<UsernameResource>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d));
    }
    
    fun delete_username_internal(arg0: &signer, arg1: &mut UsernameResource) acquires Username {
        let v0 = move_from<Username>(0x1::signer::address_of(arg0));
        if (0x1::table::contains<0x1::string::String, address>(&arg1.registry, v0.name)) {
            if (*0x1::table::borrow<0x1::string::String, address>(&arg1.registry, v0.name) == 0x1::signer::address_of(arg0)) {
                0x1::table::remove<0x1::string::String, address>(&mut arg1.registry, v0.name);
            };
            let v1 = UsernameDeleteEvent{
                user : 0x1::signer::address_of(arg0), 
                name : v0.name,
            };
            0x1::event::emit<UsernameDeleteEvent>(v1);
        };
    }
    
    public entry fun initialize_module(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        if (exists<UsernameResource>(0x1::signer::address_of(arg0))) {
        } else {
            let (v0, v1) = 0x1::account::create_resource_account(arg0, b"Merkle Username");
            let v2 = v0;
            let v3 = 0x4::collection::create_unlimited_collection(&v2, 0x1::string::utf8(b"Merkle Username Ticket"), 0x1::string::utf8(b"Merkle Username Ticket"), 0x1::option::none<0x4::royalty::Royalty>(), 0x1::string::utf8(b""));
            let v4 = UsernameResource{
                collection_mutator_ref     : 0x4::collection::generate_mutator_ref(&v3), 
                royalty_mutator_ref        : 0x4::royalty::generate_mutator_ref(0x1::object::generate_extend_ref(&v3)), 
                signer_cap                 : v1, 
                duration                   : 31536000, 
                renewal_available_duration : 7776000, 
                change_cooldown_duration   : 0, 
                registry                   : 0x1::table::new<0x1::string::String, address>(),
            };
            move_to<UsernameResource>(arg0, v4);
        };
    }
    
    public entry fun issue_ticket(arg0: &signer, arg1: address) acquires UsernameResource {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        let v0 = 0x1::account::create_signer_with_capability(&borrow_global<UsernameResource>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).signer_cap);
        let v1 = 0x4::token::create(&v0, 0x1::string::utf8(b"Merkle Username Ticket"), 0x1::string::utf8(b""), 0x1::string::utf8(b"Merkle Username Ticket"), 0x1::option::none<0x4::royalty::Royalty>(), 0x1::string::utf8(b""));
        let v2 = 0x1::object::generate_signer(&v1);
        let v3 = 0x1::object::generate_transfer_ref(&v1);
        0x1::object::transfer_raw(&v0, 0x1::signer::address_of(&v2), arg1);
        0x1::object::disable_ungated_transfer(&v3);
        let v4 = UsernameTicket{
            owner        : arg1, 
            transfer_ref : v3, 
            mutator_ref  : 0x4::token::generate_mutator_ref(&v1), 
            burn_ref     : 0x4::token::generate_burn_ref(&v1),
        };
        move_to<UsernameTicket>(&v2, v4);
        let v5 = TicketIssueEvent{
            ticket : 0x1::signer::address_of(&v2), 
            user   : arg1,
        };
        0x1::event::emit<TicketIssueEvent>(v5);
    }
    
    public entry fun register_username(arg0: &signer, arg1: address, arg2: 0x1::string::String) acquires Username, UsernameResource, UsernameTicket {
        assert!(0x1::signer::address_of(arg0) == 0x1::object::owner<UsernameTicket>(0x1::object::address_to_object<UsernameTicket>(arg1)), 0);
        assert!(check_available(arg2), 2);
        let v0 = borrow_global_mut<UsernameResource>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        if (exists<Username>(0x1::signer::address_of(arg0))) {
            assert!(borrow_global<Username>(0x1::signer::address_of(arg0)).registered_at + v0.change_cooldown_duration <= 0x1::timestamp::now_seconds(), 3);
            delete_username_internal(arg0, v0);
        };
        let v1 = 0x1::timestamp::now_seconds();
        let v2 = 0x1::timestamp::now_seconds() + v0.duration;
        let v3 = Username{
            name          : arg2, 
            registered_at : v1, 
            expired_at    : v2,
        };
        move_to<Username>(arg0, v3);
        0x1::table::upsert<0x1::string::String, address>(&mut v0.registry, to_lowercase(arg2), 0x1::signer::address_of(arg0));
        burn_ticket(move_from<UsernameTicket>(arg1));
        let v4 = UsernameRegisterEvent{
            user          : 0x1::signer::address_of(arg0), 
            name          : arg2, 
            registered_at : v1, 
            expired_at    : v2,
        };
        0x1::event::emit<UsernameRegisterEvent>(v4);
        return
        abort 3
    }
    
    public entry fun renew_username(arg0: &signer, arg1: address) acquires Username, UsernameResource, UsernameTicket {
        assert!(0x1::signer::address_of(arg0) == 0x1::object::owner<UsernameTicket>(0x1::object::address_to_object<UsernameTicket>(arg1)), 0);
        let v0 = borrow_global_mut<Username>(0x1::signer::address_of(arg0));
        let v1 = borrow_global_mut<UsernameResource>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        assert!(v0.expired_at - v1.renewal_available_duration <= 0x1::timestamp::now_seconds() && 0x1::timestamp::now_seconds() <= v0.expired_at, 4);
        v0.expired_at = v0.expired_at + v1.duration;
        burn_ticket(move_from<UsernameTicket>(arg1));
        let v2 = UsernameRegisterEvent{
            user          : 0x1::signer::address_of(arg0), 
            name          : v0.name, 
            registered_at : v0.registered_at, 
            expired_at    : v0.expired_at,
        };
        0x1::event::emit<UsernameRegisterEvent>(v2);
    }
    
    public entry fun set_duration(arg0: &signer, arg1: u64) acquires UsernameResource {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        borrow_global_mut<UsernameResource>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).duration = arg1;
    }
    
    public entry fun set_renewal_available_duration(arg0: &signer, arg1: u64) acquires UsernameResource {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        borrow_global_mut<UsernameResource>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).renewal_available_duration = arg1;
    }
    
    fun to_lowercase(arg0: 0x1::string::String) : 0x1::string::String {
        let v0 = 0x1::vector::empty<u8>();
        let v1 = *0x1::string::bytes(&arg0);
        0x1::vector::reverse<u8>(&mut v1);
        let v2 = v1;
        let v3 = 0x1::vector::length<u8>(&v2);
        while (v3 > 0) {
            let v4 = 0x1::vector::pop_back<u8>(&mut v2);
            let v5 = v4;
            if (64 < v4 && v4 < 91) {
                v5 = v4 + 32;
            };
            0x1::vector::push_back<u8>(&mut v0, v5);
            v3 = v3 - 1;
        };
        0x1::vector::destroy_empty<u8>(v2);
        0x1::string::utf8(v0)
    }
    
    // decompiled from Move bytecode v6
}


module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::merkle_auth {
    struct AuthConfig has key {
        pause: bool,
    }
    
    struct SessionInfo has drop, store {
        expire_at_sec: u64,
        created_at_sec: u64,
        entry_func_scope: vector<vector<0x1::string::String>>,
    }
    
    struct SessionKey has copy, drop, store {
        pubkey: vector<u8>,
    }
    
    struct Sessions has drop, key {
        session_infos: 0x1::ordered_map::OrderedMap<SessionKey, SessionInfo>,
    }
    
    public fun authenticate(arg0: signer, arg1: 0x1::auth_data::AbstractionAuthData) : signer acquires AuthConfig, Sessions {
        assert!(exists<AuthConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d) && !borrow_global<AuthConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).pause || true, 6);
        let v0 = 0x1::bcs_stream::new(*0x1::auth_data::authenticator(&arg1));
        let v1 = &mut v0;
        let v2 = 0x1::vector::empty<u8>();
        let v3 = 0;
        while (v3 < 0x1::bcs_stream::deserialize_uleb128(v1)) {
            0x1::vector::push_back<u8>(&mut v2, 0x1::bcs_stream::deserialize_u8(v1));
            v3 = v3 + 1;
        };
        let v4 = 0x1::ed25519::new_unvalidated_public_key_from_bytes(v2);
        let v5 = &mut v0;
        let v6 = 0x1::vector::empty<u8>();
        v3 = 0;
        while (v3 < 0x1::bcs_stream::deserialize_uleb128(v5)) {
            0x1::vector::push_back<u8>(&mut v6, 0x1::bcs_stream::deserialize_u8(v5));
            v3 = v3 + 1;
        };
        let v7 = 0x1::ed25519::new_signature_from_bytes(v6);
        let v8 = SessionKey{pubkey: 0x1::ed25519::unvalidated_public_key_to_bytes(&v4)};
        let v9 = &borrow_global<Sessions>(0x1::signer::address_of(&arg0)).session_infos;
        assert!(0x1::ordered_map::contains<SessionKey, SessionInfo>(v9, &v8), 1);
        let v10 = 0x1::ordered_map::borrow<SessionKey, SessionInfo>(v9, &v8);
        assert!(0x1::timestamp::now_seconds() <= v10.expire_at_sec, 2);
        assert!(check_allowed_function(v10.entry_func_scope), 3);
        assert!(0x1::ed25519::signature_verify_strict(&v7, &v4, *0x1::auth_data::digest(&arg1)), 0);
        arg0
    }
    
    fun check_allowed_function(arg0: vector<vector<0x1::string::String>>) : bool {
        let v0 = 0x1::transaction_context::entry_function_payload();
        if (0x1::option::is_none<0x1::transaction_context::EntryFunctionPayload>(&v0)) {
            abort 4
        };
        let v1 = 0x1::option::extract<0x1::transaction_context::EntryFunctionPayload>(&mut v0);
        let v2 = 0x1::transaction_context::account_address(&v1);
        let v3 = &arg0;
        let v4 = false;
        let v5 = 0;
        while (v5 < 0x1::vector::length<vector<0x1::string::String>>(v3)) {
            let v6 = 0x1::vector::borrow<vector<0x1::string::String>>(v3, v5);
            let v7 = if (*0x1::vector::borrow<0x1::string::String>(v6, 0) == 0x1::string::utf8(b"*") || *0x1::vector::borrow<0x1::string::String>(v6, 0) == 0x1::string_utils::to_string<address>(&v2)) {
                if (*0x1::vector::borrow<0x1::string::String>(v6, 1) == 0x1::string::utf8(b"*")) {
                    true
                } else {
                    *0x1::vector::borrow<0x1::string::String>(v6, 1) == 0x1::transaction_context::module_name(&v1)
                }
            } else {
                false
            };
            let v8 = if (v7) {
                if (*0x1::vector::borrow<0x1::string::String>(v6, 2) == 0x1::string::utf8(b"*")) {
                    true
                } else {
                    *0x1::vector::borrow<0x1::string::String>(v6, 2) == 0x1::transaction_context::function_name(&v1)
                }
            } else {
                false
            };
            v4 = v8;
            if (v8) {
                break
            };
            v5 = v5 + 1;
        };
        v4
    }
    
    fun evict_expired_and_oldest_if_needed(arg0: &mut Sessions) {
        let v0 = 0x1::timestamp::now_seconds();
        let v1 = v0;
        let v2 = 0x1::option::none<SessionKey>();
        let v3 = 0x1::ordered_map::keys<SessionKey, SessionInfo>(&arg0.session_infos);
        0x1::vector::reverse<SessionKey>(&mut v3);
        let v4 = v3;
        let v5 = 0x1::vector::length<SessionKey>(&v4);
        while (v5 > 0) {
            let v6 = 0x1::vector::pop_back<SessionKey>(&mut v4);
            let v7 = 0x1::ordered_map::borrow<SessionKey, SessionInfo>(&arg0.session_infos, &v6);
            if (v7.expire_at_sec < v0) {
                0x1::ordered_map::remove<SessionKey, SessionInfo>(&mut arg0.session_infos, &v6);
            } else {
                if (v7.created_at_sec < v1) {
                    v1 = v7.created_at_sec;
                    0x1::option::fill<SessionKey>(&mut v2, v6);
                };
            };
            v5 = v5 - 1;
        };
        0x1::vector::destroy_empty<SessionKey>(v4);
        if (0x1::ordered_map::length<SessionKey, SessionInfo>(&arg0.session_infos) >= 10 && 0x1::option::is_some<SessionKey>(&v2)) {
            let v8 = 0x1::option::extract<SessionKey>(&mut v2);
            0x1::ordered_map::remove<SessionKey, SessionInfo>(&mut arg0.session_infos, &v8);
        };
    }
    
    entry fun register_session(arg0: &signer, arg1: vector<u8>, arg2: vector<vector<0x1::string::String>>) acquires AuthConfig, Sessions {
        assert!(exists<AuthConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d) && !borrow_global<AuthConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).pause || true, 6);
        let v0 = arg2;
        0x1::vector::reverse<vector<0x1::string::String>>(&mut v0);
        let v1 = v0;
        let v2 = 0x1::vector::length<vector<0x1::string::String>>(&v1);
        while (v2 > 0) {
            let v3 = 0x1::vector::pop_back<vector<0x1::string::String>>(&mut v1);
            assert!(0x1::vector::length<0x1::string::String>(&v3) == 3, 5);
            v2 = v2 - 1;
        };
        0x1::vector::destroy_empty<vector<0x1::string::String>>(v1);
        if (exists<Sessions>(0x1::signer::address_of(arg0))) {
        } else {
            let v4 = Sessions{session_infos: 0x1::ordered_map::new<SessionKey, SessionInfo>()};
            move_to<Sessions>(arg0, v4);
        };
        let v5 = borrow_global_mut<Sessions>(0x1::signer::address_of(arg0));
        evict_expired_and_oldest_if_needed(v5);
        let v6 = SessionKey{pubkey: arg1};
        let v7 = SessionInfo{
            expire_at_sec    : 0x1::timestamp::now_seconds() + 2592000, 
            created_at_sec   : 0x1::timestamp::now_seconds(), 
            entry_func_scope : arg2,
        };
        0x1::ordered_map::upsert<SessionKey, SessionInfo>(&mut v5.session_infos, v6, v7);
    }
    
    public entry fun revoke(arg0: &signer, arg1: vector<u8>) acquires Sessions {
        let v0 = SessionKey{pubkey: arg1};
        0x1::ordered_map::remove<SessionKey, SessionInfo>(&mut borrow_global_mut<Sessions>(0x1::signer::address_of(arg0)).session_infos, &v0);
    }
    
    public entry fun revoke_all(arg0: &signer) acquires Sessions {
        move_from<Sessions>(0x1::signer::address_of(arg0));
    }
    
    entry fun set_pause(arg0: &signer, arg1: bool) acquires AuthConfig {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 14566554180833181696);
        if (exists<AuthConfig>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = AuthConfig{pause: false};
            move_to<AuthConfig>(arg0, v0);
        };
        borrow_global_mut<AuthConfig>(0x1::signer::address_of(arg0)).pause = arg1;
    }
    
    // decompiled from Move bytecode v6
}


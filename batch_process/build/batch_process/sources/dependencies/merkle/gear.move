module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear {
    struct MintEvent has drop, store {
        uid: u64,
        gear_address: address,
        season: u64,
        user: address,
        name: 0x1::string::String,
        uri: 0x1::string::String,
        gear_type: u64,
        gear_code: u64,
        tier: u64,
        primary_effect: u64,
        gear_affixes: vector<GearAffix>,
    }
    
    struct AdminCapability has copy, drop, store {
        dummy_field: bool,
    }
    
    struct EquipEvent has drop, store {
        uid: u64,
        gear_address: address,
        user: address,
        durability: u64,
    }
    
    struct EquippedGearView has copy, drop {
        gear_address: address,
        name: 0x1::string::String,
        uri: 0x1::string::String,
        gear_type: u64,
        equipped_time: u64,
    }
    
    struct ForgeEvent has drop, store {
        user: address,
        gear1_uid: u64,
        gear1_address: address,
        gear2_uid: u64,
        gear2_address: address,
        required_shard: u64,
        gear_tier: u64,
        result_tier: u64,
    }
    
    struct GearAffix has copy, drop, store {
        gear_affix_type: u64,
        gear_affix_code: u64,
        target: 0x1::string::String,
        effect: u64,
    }
    
    struct GearDetail has copy, drop {
        uid: u64,
        gear_address: address,
        name: 0x1::string::String,
        uri: 0x1::string::String,
        gear_type: u64,
        gear_code: u64,
        tier: u64,
        durability: u64,
        primary_effect: u64,
        gear_affixes: vector<GearAffix>,
        owner: address,
        soul_bound: bool,
        season: u64,
    }
    
    struct GearEffectEvent has drop, store {
        uid: u64,
        gear_address: address,
        pair_type: 0x1::type_info::TypeInfo,
        user: address,
        effect: u64,
        gear_type: u64,
        gear_code: u64,
    }
    
    struct GearEvents has key {
        mint_events: 0x1::event::EventHandle<MintEvent>,
        salvage_events: 0x1::event::EventHandle<SalvageEvent>,
        repair_events: 0x1::event::EventHandle<RepairEvent>,
        equip_events: 0x1::event::EventHandle<EquipEvent>,
        unequip_events: 0x1::event::EventHandle<UnequipEvent>,
        gear_effect_events: 0x1::event::EventHandle<GearEffectEvent>,
    }
    
    struct GearEventsV2 has key {
        forge_events: 0x1::event::EventHandle<ForgeEvent>,
    }
    
    struct MerkleGearCollection has key {
        property_keys: vector<0x1::string::String>,
        property_types: vector<0x1::string::String>,
        signer_cap: 0x1::account::SignerCapability,
        collection_mutator_ref: 0x4::collection::MutatorRef,
        royalty_mutator_ref: 0x4::royalty::MutatorRef,
        max_durability_duration_sec: u64,
        uid: u64,
        gears: 0x1::table::Table<u64, address>,
    }
    
    struct MerkleGearToken has key {
        delete_ref: 0x1::object::DeleteRef,
        mutator_ref: 0x4::token::MutatorRef,
        burn_ref: 0x4::token::BurnRef,
        transfer_ref: 0x1::object::TransferRef,
        property_mutator_ref: 0x4::property_map::MutatorRef,
        gear_affixes: vector<GearAffix>,
    }
    
    struct RepairEvent has drop, store {
        uid: u64,
        gear_address: address,
        shard_amount: u64,
        user: address,
    }
    
    struct SalvageEvent has drop, store {
        uid: u64,
        gear_address: address,
        shard_amount: u64,
        user: address,
    }
    
    struct UnequipEvent has drop, store {
        uid: u64,
        gear_address: address,
        user: address,
        durability: u64,
    }
    
    struct UserGear has key {
        equipped: 0x1::simple_map::SimpleMap<u64, address>,
        equipped_time: 0x1::simple_map::SimpleMap<u64, u64>,
    }
    
    fun burn_gear(arg0: address) acquires MerkleGearToken {
        let MerkleGearToken {
            delete_ref           : _,
            mutator_ref          : _,
            burn_ref             : v2,
            transfer_ref         : _,
            property_mutator_ref : v4,
            gear_affixes         : _,
        } = move_from<MerkleGearToken>(arg0);
        0x4::property_map::burn(v4);
        0x4::token::burn(v2);
    }
    
    public fun equip(arg0: &signer, arg1: address) acquires GearEvents, MerkleGearCollection, MerkleGearToken, UserGear {
        if (exists<UserGear>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = UserGear{
                equipped      : 0x1::simple_map::create<u64, address>(), 
                equipped_time : 0x1::simple_map::create<u64, u64>(),
            };
            move_to<UserGear>(arg0, v0);
        };
        let v1 = borrow_global_mut<UserGear>(0x1::signer::address_of(arg0));
        let v2 = get_gear_detail(arg1);
        let v3 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number();
        assert!(v2.owner == 0x1::signer::address_of(arg0), 2);
        assert!(v2.durability > 0, 4);
        assert!(v3 < 9 || v3 - v2.season < 6, 12);
        let v4 = borrow_global<MerkleGearToken>(arg1);
        if (0x1::simple_map::contains_key<u64, address>(&v1.equipped, &v2.gear_type)) {
            assert!(*0x1::simple_map::borrow<u64, address>(&v1.equipped, &v2.gear_type) != arg1, 7);
            unequip_internal(&mut v1.equipped, &mut v1.equipped_time, v2, borrow_global_mut<MerkleGearCollection>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).max_durability_duration_sec, &v4.property_mutator_ref);
        };
        0x1::object::disable_ungated_transfer(&v4.transfer_ref);
        0x1::simple_map::add<u64, address>(&mut v1.equipped, v2.gear_type, arg1);
        0x1::simple_map::add<u64, u64>(&mut v1.equipped_time, v2.gear_type, 0x1::timestamp::now_seconds());
        let v5 = EquipEvent{
            uid          : v2.uid, 
            gear_address : arg1, 
            user         : 0x1::signer::address_of(arg0), 
            durability   : v2.durability,
        };
        0x1::event::emit_event<EquipEvent>(&mut borrow_global_mut<GearEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).equip_events, v5);
        return
        abort 7
    }
    
    public fun forge_rand(arg0: &signer, arg1: address, arg2: address) acquires GearEvents, GearEventsV2, MerkleGearCollection, MerkleGearToken, UserGear {
        let v0 = get_gear_detail(arg1);
        let v1 = get_gear_detail(arg2);
        validate_forge(0x1::signer::address_of(arg0), v0, v1);
        let v2 = v0.tier;
        let v3 = v2;
        let (v4, v5) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear_calc::get_forge_rates(v2);
        if (0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::random::get_random_between(1, 1000000) <= v5) {
            v3 = v2 - 1;
        } else {
            if (0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::random::get_random_between(1, 1000000) > v4 && v2 < 4) {
                v3 = v2 + 1;
            };
        };
        mint_rand(arg0, v3);
        let v6 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear_calc::get_forge_required_shard(v2);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::shard_token::burn(0x1::signer::address_of(arg0), v6);
        let v7 = ForgeEvent{
            user           : 0x1::signer::address_of(arg0), 
            gear1_uid      : v0.uid, 
            gear1_address  : arg1, 
            gear2_uid      : v1.uid, 
            gear2_address  : arg2, 
            required_shard : v6, 
            gear_tier      : v2, 
            result_tier    : v3,
        };
        0x1::event::emit_event<ForgeEvent>(&mut borrow_global_mut<GearEventsV2>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).forge_events, v7);
        burn_gear(arg1);
        burn_gear(arg2);
    }
    
    public fun generate_admin_cap(arg0: &signer) : AdminCapability {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        AdminCapability{dummy_field: false}
    }
    
    public fun get_equipped_gears(arg0: address) : vector<EquippedGearView> acquires MerkleGearToken, UserGear {
        if (exists<UserGear>(arg0)) {
            let v0 = borrow_global<UserGear>(arg0);
            let v1 = 0x1::vector::empty<EquippedGearView>();
            let (_, v3) = 0x1::simple_map::to_vec_pair<u64, address>(v0.equipped);
            let v4 = v3;
            let v5 = 0;
            while (v5 < 0x1::vector::length<address>(&v4)) {
                let v6 = 0x1::vector::borrow<address>(&v4, v5);
                let v7 = get_gear_detail(*v6);
                let v8 = EquippedGearView{
                    gear_address  : *v6, 
                    name          : v7.name, 
                    uri           : v7.uri, 
                    gear_type     : v7.gear_type, 
                    equipped_time : *0x1::simple_map::borrow<u64, u64>(&v0.equipped_time, &v7.gear_type),
                };
                0x1::vector::push_back<EquippedGearView>(&mut v1, v8);
                v5 = v5 + 1;
            };
            return v1
        };
        0x1::vector::empty<EquippedGearView>()
    }
    
    public fun get_fee_discount_effect<T0>(arg0: address, arg1: bool) : u64 acquires GearEvents, MerkleGearCollection, MerkleGearToken, UserGear {
        get_gear_type_boost_effect<T0>(arg0, 1, arg1)
    }
    
    public fun get_gear_detail(arg0: address) : GearDetail acquires MerkleGearToken {
        let v0 = borrow_global<MerkleGearToken>(arg0);
        let v1 = 0x1::object::object_from_delete_ref<MerkleGearToken>(&v0.delete_ref);
        let v2 = 0x1::string::utf8(b"uid");
        let v3 = 0x1::string::utf8(b"gear_type");
        let v4 = 0x1::string::utf8(b"gear_code");
        let v5 = 0x1::string::utf8(b"tier");
        let v6 = 0x1::string::utf8(b"durability");
        let v7 = 0x1::string::utf8(b"primary_effect");
        let v8 = 0x1::string::utf8(b"season");
        GearDetail{
            uid            : 0x4::property_map::read_u64<MerkleGearToken>(&v1, &v2), 
            gear_address   : arg0, 
            name           : 0x4::token::name<MerkleGearToken>(v1), 
            uri            : 0x4::token::uri<MerkleGearToken>(v1), 
            gear_type      : 0x4::property_map::read_u64<MerkleGearToken>(&v1, &v3), 
            gear_code      : 0x4::property_map::read_u64<MerkleGearToken>(&v1, &v4), 
            tier           : 0x4::property_map::read_u64<MerkleGearToken>(&v1, &v5), 
            durability     : 0x4::property_map::read_u64<MerkleGearToken>(&v1, &v6), 
            primary_effect : 0x4::property_map::read_u64<MerkleGearToken>(&v1, &v7), 
            gear_affixes   : v0.gear_affixes, 
            owner          : 0x1::object::owner<MerkleGearToken>(v1), 
            soul_bound     : !0x1::object::ungated_transfer_allowed<MerkleGearToken>(v1), 
            season         : 0x4::property_map::read_u64<MerkleGearToken>(&v1, &v8),
        }
    }
    
    fun get_gear_effect<T0>(arg0: GearDetail, arg1: u64, arg2: u64) : u64 {
        let v0 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number();
        let v1 = if (arg0.durability <= 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x1::timestamp::now_seconds() - arg1, 100000000, arg2)) {
            true
        } else {
            if (v0 - arg0.season >= 6) {
                v0 >= 9
            } else {
                false
            }
        };
        if (v1) {
            return 0
        };
        let v2 = arg0.primary_effect;
        let v3 = 0;
        while (v3 < 0x1::vector::length<GearAffix>(&arg0.gear_affixes)) {
            let v4 = 0x1::vector::borrow<GearAffix>(&arg0.gear_affixes, v3);
            if (0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pair_types::check_target<T0>(v4.target)) {
                let v5 = v2 + v4.effect;
                v2 = v5;
                let v6 = if (v0 == 13) {
                    let v7 = 0x1::type_info::type_of<T0>();
                    let v8 = if (0x1::type_info::struct_name(&v7) == b"ETH_USD") {
                        true
                    } else {
                        let v9 = 0x1::type_info::type_of<T0>();
                        0x1::type_info::struct_name(&v9) == b"ARB_USD"
                    };
                    if (v8) {
                        true
                    } else {
                        let v10 = 0x1::type_info::type_of<T0>();
                        0x1::type_info::struct_name(&v10) == b"OP_USD"
                    }
                } else {
                    false
                };
                if (v6) {
                    v2 = v5 + 30000;
                };
            };
            v3 = v3 + 1;
        };
        v2
    }
    
    fun get_gear_type_boost_effect<T0>(arg0: address, arg1: u64, arg2: bool) : u64 acquires GearEvents, MerkleGearCollection, MerkleGearToken, UserGear {
        if (exists<UserGear>(arg0)) {
            let v0 = borrow_global_mut<UserGear>(arg0);
            if (0x1::simple_map::contains_key<u64, address>(&v0.equipped, &arg1)) {
                let v1 = get_gear_detail(*0x1::simple_map::borrow<u64, address>(&v0.equipped, &arg1));
                let v2 = get_gear_effect<T0>(v1, *0x1::simple_map::borrow<u64, u64>(&v0.equipped_time, &arg1), borrow_global<MerkleGearCollection>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).max_durability_duration_sec);
                if (arg2) {
                    arg2 = v2 > 0;
                } else {
                    arg2 = false;
                };
                if (arg2) {
                    use_gear<T0>(v1, v2);
                };
                return v2
            };
            return 0
        };
        0
    }
    
    public fun get_pmkl_boost_effect<T0>(arg0: address, arg1: bool) : u64 acquires GearEvents, MerkleGearCollection, MerkleGearToken, UserGear {
        get_gear_type_boost_effect<T0>(arg0, 0, arg1)
    }
    
    public fun get_repair_shards(arg0: address, arg1: u64) : u64 acquires MerkleGearCollection, MerkleGearToken, UserGear {
        let v0 = get_gear_detail(arg0);
        let v1 = is_equiped(v0.owner, v0.gear_type, arg0);
        let v2 = v0.durability;
        let v3 = v2;
        if (v1) {
            v3 = v2 - 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::min(v2, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x1::timestamp::now_seconds() - *0x1::simple_map::borrow<u64, u64>(&borrow_global<UserGear>(v0.owner).equipped_time, &v0.gear_type), 100000000, borrow_global<MerkleGearCollection>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).max_durability_duration_sec));
        };
        assert!(v3 <= arg1 && arg1 <= 100000000, 5);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear_calc::calc_repair_required_shards(arg1, v3, v0.tier)
    }
    
    public fun get_salvage_shard_range(arg0: address) : (u64, u64) acquires MerkleGearToken {
        let v0 = get_gear_detail(arg0);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear_calc::calc_salvage_shard_range(v0.tier, v0.durability)
    }
    
    public fun get_xp_boost_effect<T0>(arg0: address, arg1: bool) : u64 acquires GearEvents, MerkleGearCollection, MerkleGearToken, UserGear {
        get_gear_type_boost_effect<T0>(arg0, 2, arg1)
    }
    
    public fun initialize_module(arg0: &signer) {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 1);
        if (exists<MerkleGearCollection>(0x1::signer::address_of(arg0))) {
            return
        };
        let (v0, v1) = 0x1::account::create_resource_account(arg0, 0x1::vector::empty<u8>());
        let v2 = v0;
        let v3 = 0x4::collection::create_unlimited_collection(&v2, 0x1::string::utf8(b""), 0x1::string::utf8(b"Merkle Gear"), 0x1::option::none<0x4::royalty::Royalty>(), 0x1::string::utf8(b""));
        let v4 = 0x1::vector::empty<0x1::string::String>();
        let v5 = &mut v4;
        0x1::vector::push_back<0x1::string::String>(v5, 0x1::string::utf8(b"uid"));
        0x1::vector::push_back<0x1::string::String>(v5, 0x1::string::utf8(b"gear_type"));
        0x1::vector::push_back<0x1::string::String>(v5, 0x1::string::utf8(b"gear_code"));
        0x1::vector::push_back<0x1::string::String>(v5, 0x1::string::utf8(b"tier"));
        0x1::vector::push_back<0x1::string::String>(v5, 0x1::string::utf8(b"durability"));
        0x1::vector::push_back<0x1::string::String>(v5, 0x1::string::utf8(b"primary_effect"));
        0x1::vector::push_back<0x1::string::String>(v5, 0x1::string::utf8(b"season"));
        let v6 = 0x1::vector::empty<0x1::string::String>();
        let v7 = &mut v6;
        0x1::vector::push_back<0x1::string::String>(v7, 0x1::string::utf8(b"u64"));
        0x1::vector::push_back<0x1::string::String>(v7, 0x1::string::utf8(b"u64"));
        0x1::vector::push_back<0x1::string::String>(v7, 0x1::string::utf8(b"u64"));
        0x1::vector::push_back<0x1::string::String>(v7, 0x1::string::utf8(b"u64"));
        0x1::vector::push_back<0x1::string::String>(v7, 0x1::string::utf8(b"u64"));
        0x1::vector::push_back<0x1::string::String>(v7, 0x1::string::utf8(b"u64"));
        0x1::vector::push_back<0x1::string::String>(v7, 0x1::string::utf8(b"u64"));
        let v8 = MerkleGearCollection{
            property_keys               : v4, 
            property_types              : v6, 
            signer_cap                  : v1, 
            collection_mutator_ref      : 0x4::collection::generate_mutator_ref(&v3), 
            royalty_mutator_ref         : 0x4::royalty::generate_mutator_ref(0x1::object::generate_extend_ref(&v3)), 
            max_durability_duration_sec : 1814400, 
            uid                         : 0, 
            gears                       : 0x1::table::new<u64, address>(),
        };
        move_to<MerkleGearCollection>(arg0, v8);
        let v9 = GearEvents{
            mint_events        : 0x1::account::new_event_handle<MintEvent>(arg0), 
            salvage_events     : 0x1::account::new_event_handle<SalvageEvent>(arg0), 
            repair_events      : 0x1::account::new_event_handle<RepairEvent>(arg0), 
            equip_events       : 0x1::account::new_event_handle<EquipEvent>(arg0), 
            unequip_events     : 0x1::account::new_event_handle<UnequipEvent>(arg0), 
            gear_effect_events : 0x1::account::new_event_handle<GearEffectEvent>(arg0),
        };
        move_to<GearEvents>(arg0, v9);
    }
    
    public fun initialize_module_v2(arg0: &signer) {
        if (exists<GearEventsV2>(0x1::signer::address_of(arg0))) {
        } else {
            let v0 = GearEventsV2{forge_events: 0x1::account::new_event_handle<ForgeEvent>(arg0)};
            move_to<GearEventsV2>(arg0, v0);
        };
    }
    
    fun is_equiped(arg0: address, arg1: u64, arg2: address) : bool acquires UserGear {
        if (exists<UserGear>(arg0)) {
            let v0 = borrow_global_mut<UserGear>(arg0);
            if (0x1::simple_map::contains_key<u64, address>(&v0.equipped, &arg1)) {
                return *0x1::simple_map::borrow<u64, address>(&v0.equipped, &arg1) == arg2
            };
            return false
        };
        false
    }
    
    public(friend) fun mint_basic(arg0: address, arg1: u64, arg2: u64) acquires GearEvents, MerkleGearCollection, MerkleGearToken {
        let (v0, v1, v2, v3, v4, v5, v6, v7, v8) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear_factory::get_basic_gear_property(arg1, arg2);
        let v9 = v8;
        let v10 = v7;
        let v11 = v6;
        let v12 = v5;
        let v13 = 0;
        let v14 = 0x1::vector::empty<GearAffix>();
        while (v13 < 0x1::vector::length<u64>(&v9)) {
            let v15 = GearAffix{
                gear_affix_type : *0x1::vector::borrow<u64>(&v12, v13), 
                gear_affix_code : *0x1::vector::borrow<u64>(&v11, v13), 
                target          : *0x1::vector::borrow<0x1::string::String>(&v10, v13), 
                effect          : *0x1::vector::borrow<u64>(&v9, v13),
            };
            0x1::vector::push_back<GearAffix>(&mut v14, v15);
            v13 = v13 + 1;
        };
        let v16 = arg1;
        let v17 = v2;
        let v18 = v3;
        let v19 = v4;
        let v20 = v14;
        let v21 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number();
        let v22 = borrow_global_mut<MerkleGearCollection>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v23 = 0x1::account::create_signer_with_capability(&v22.signer_cap);
        let v24 = if (0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number() > 6) {
            0x1::option::some<0x4::royalty::Royalty>(0x4::royalty::create(4, 100, @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d))
        } else {
            0x1::option::none<0x4::royalty::Royalty>()
        };
        let v25 = 0x4::token::create(&v23, 0x1::string::utf8(b"Merkle Gear"), 0x1::string::utf8(b""), v0, v24, v1);
        let v26 = 0x1::object::generate_signer(&v25);
        let v27 = 0x1::object::generate_transfer_ref(&v25);
        0x1::object::transfer_with_ref(0x1::object::generate_linear_transfer_ref(&v27), arg0);
        let v28 = 100000000;
        let v29 = 0x1::vector::empty<vector<u8>>();
        let v30 = &mut v29;
        0x1::vector::push_back<vector<u8>>(v30, 0x1::bcs::to_bytes<u64>(&v22.uid));
        0x1::vector::push_back<vector<u8>>(v30, 0x1::bcs::to_bytes<u64>(&v17));
        0x1::vector::push_back<vector<u8>>(v30, 0x1::bcs::to_bytes<u64>(&v18));
        0x1::vector::push_back<vector<u8>>(v30, 0x1::bcs::to_bytes<u64>(&v16));
        0x1::vector::push_back<vector<u8>>(v30, 0x1::bcs::to_bytes<u64>(&v28));
        0x1::vector::push_back<vector<u8>>(v30, 0x1::bcs::to_bytes<u64>(&v19));
        0x1::vector::push_back<vector<u8>>(v30, 0x1::bcs::to_bytes<u64>(&v21));
        0x4::property_map::init(&v25, 0x4::property_map::prepare_input(v22.property_keys, v22.property_types, v29));
        let v31 = MerkleGearToken{
            delete_ref           : 0x1::object::generate_delete_ref(&v25), 
            mutator_ref          : 0x4::token::generate_mutator_ref(&v25), 
            burn_ref             : 0x4::token::generate_burn_ref(&v25), 
            transfer_ref         : v27, 
            property_mutator_ref : 0x4::property_map::generate_mutator_ref(&v25), 
            gear_affixes         : v20,
        };
        move_to<MerkleGearToken>(&v26, v31);
        0x1::table::add<u64, address>(&mut v22.gears, v22.uid, 0x1::signer::address_of(&v26));
        let v32 = MintEvent{
            uid            : v22.uid, 
            gear_address   : 0x1::signer::address_of(&v26), 
            season         : v21, 
            user           : arg0, 
            name           : v0, 
            uri            : v1, 
            gear_type      : v17, 
            gear_code      : v18, 
            tier           : v16, 
            primary_effect : v19, 
            gear_affixes   : v20,
        };
        0x1::event::emit_event<MintEvent>(&mut borrow_global_mut<GearEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).mint_events, v32);
        v22.uid = v22.uid + 1;
        0x1::object::disable_ungated_transfer(&borrow_global<MerkleGearToken>(0x1::signer::address_of(&v26)).transfer_ref);
    }
    
    public(friend) fun mint_event_rand(arg0: &AdminCapability, arg1: address, arg2: u64, arg3: u64, arg4: u64) acquires GearEvents, MerkleGearCollection, MerkleGearToken {
        assert!(arg2 > 0, 13);
        let v0 = 0x1::vector::empty<0x1::simple_map::SimpleMap<u64, vector<u8>>>();
        let v1 = &mut v0;
        0x1::vector::push_back<0x1::simple_map::SimpleMap<u64, vector<u8>>>(v1, 0x1::simple_map::new_from<u64, vector<u8>>(vector[200, 300, 400, 500], vector[b"ipfs://bafybeigo34rnzwx76yvqoplbdnlawn6y4bhjaj4m7zbyiji3v2snmhqs4y/s13-a200.png", b"ipfs://bafybeigo34rnzwx76yvqoplbdnlawn6y4bhjaj4m7zbyiji3v2snmhqs4y/s13-a300.png", b"ipfs://bafybeigo34rnzwx76yvqoplbdnlawn6y4bhjaj4m7zbyiji3v2snmhqs4y/s13-a400.png", b"ipfs://bafybeigo34rnzwx76yvqoplbdnlawn6y4bhjaj4m7zbyiji3v2snmhqs4y/s13-a500.png"]));
        0x1::vector::push_back<0x1::simple_map::SimpleMap<u64, vector<u8>>>(v1, 0x1::simple_map::new_from<u64, vector<u8>>(vector[200, 300, 400, 500], vector[b"ipfs://bafybeigo34rnzwx76yvqoplbdnlawn6y4bhjaj4m7zbyiji3v2snmhqs4y/s13-b200.png", b"ipfs://bafybeigo34rnzwx76yvqoplbdnlawn6y4bhjaj4m7zbyiji3v2snmhqs4y/s13-b300.png", b"ipfs://bafybeigo34rnzwx76yvqoplbdnlawn6y4bhjaj4m7zbyiji3v2snmhqs4y/s13-b400.png", b"ipfs://bafybeigo34rnzwx76yvqoplbdnlawn6y4bhjaj4m7zbyiji3v2snmhqs4y/s13-b500.png"]));
        0x1::vector::push_back<0x1::simple_map::SimpleMap<u64, vector<u8>>>(v1, 0x1::simple_map::new_from<u64, vector<u8>>(vector[200, 300, 400, 500], vector[b"ipfs://bafybeigo34rnzwx76yvqoplbdnlawn6y4bhjaj4m7zbyiji3v2snmhqs4y/s13-c200.png", b"ipfs://bafybeigo34rnzwx76yvqoplbdnlawn6y4bhjaj4m7zbyiji3v2snmhqs4y/s13-c300.png", b"ipfs://bafybeigo34rnzwx76yvqoplbdnlawn6y4bhjaj4m7zbyiji3v2snmhqs4y/s13-c400.png", b"ipfs://bafybeigo34rnzwx76yvqoplbdnlawn6y4bhjaj4m7zbyiji3v2snmhqs4y/s13-c500.png"]));
        let v2 = 0x1::simple_map::new_from<u64, 0x1::simple_map::SimpleMap<u64, vector<u8>>>(vector[0, 1, 2], v0);
        let (v3, _, v5, v6, v7, _, _, _, _) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear_factory::generate_specific_gear_property_without_affixes_rand(arg2, arg3, arg4);
        let v12 = 0x1::vector::empty<0x1::string::String>();
        let v13 = &mut v12;
        0x1::vector::push_back<0x1::string::String>(v13, 0x1::string::utf8(b"ETH_USD"));
        0x1::vector::push_back<0x1::string::String>(v13, 0x1::string::utf8(b"ARB_USD"));
        0x1::vector::push_back<0x1::string::String>(v13, 0x1::string::utf8(b"OP_USD"));
        let (v14, v15, v16, v17) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear_factory::generate_gear_affix_rand(arg2, v5, v6, v12);
        let v18 = v17;
        let v19 = v16;
        let v20 = v15;
        let v21 = v14;
        let v22 = 0;
        let v23 = 0x1::vector::empty<GearAffix>();
        while (v22 < 0x1::vector::length<u64>(&v18)) {
            if (v22 == 0x1::vector::length<u64>(&v18) - 1) {
                let v24 = GearAffix{
                    gear_affix_type : *0x1::vector::borrow<u64>(&v21, v22), 
                    gear_affix_code : *0x1::vector::borrow<u64>(&v20, v22), 
                    target          : 0x1::string::utf8(b"ETH_USD"), 
                    effect          : *0x1::vector::borrow<u64>(&v18, v22),
                };
                0x1::vector::push_back<GearAffix>(&mut v23, v24);
                v24.target = 0x1::string::utf8(b"ARB_USD");
                0x1::vector::push_back<GearAffix>(&mut v23, v24);
                v24.target = 0x1::string::utf8(b"OP_USD");
                0x1::vector::push_back<GearAffix>(&mut v23, v24);
            } else {
                let v25 = GearAffix{
                    gear_affix_type : *0x1::vector::borrow<u64>(&v21, v22), 
                    gear_affix_code : *0x1::vector::borrow<u64>(&v20, v22), 
                    target          : *0x1::vector::borrow<0x1::string::String>(&v19, v22), 
                    effect          : *0x1::vector::borrow<u64>(&v18, v22),
                };
                0x1::vector::push_back<GearAffix>(&mut v23, v25);
            };
            v22 = v22 + 1;
        };
        let v26 = arg2;
        let v27 = 0x1::string::utf8(*0x1::simple_map::borrow<u64, vector<u8>>(0x1::simple_map::borrow<u64, 0x1::simple_map::SimpleMap<u64, vector<u8>>>(&v2, &arg3), &arg4));
        let v28 = v5;
        let v29 = v6;
        let v30 = v7;
        let v31 = v23;
        let v32 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number();
        let v33 = borrow_global_mut<MerkleGearCollection>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v34 = 0x1::account::create_signer_with_capability(&v33.signer_cap);
        let v35 = if (0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number() > 6) {
            0x1::option::some<0x4::royalty::Royalty>(0x4::royalty::create(4, 100, @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d))
        } else {
            0x1::option::none<0x4::royalty::Royalty>()
        };
        let v36 = 0x4::token::create(&v34, 0x1::string::utf8(b"Merkle Gear"), 0x1::string::utf8(b""), v3, v35, v27);
        let v37 = 0x1::object::generate_signer(&v36);
        let v38 = 0x1::object::generate_transfer_ref(&v36);
        0x1::object::transfer_with_ref(0x1::object::generate_linear_transfer_ref(&v38), arg1);
        let v39 = 100000000;
        let v40 = 0x1::vector::empty<vector<u8>>();
        let v41 = &mut v40;
        0x1::vector::push_back<vector<u8>>(v41, 0x1::bcs::to_bytes<u64>(&v33.uid));
        0x1::vector::push_back<vector<u8>>(v41, 0x1::bcs::to_bytes<u64>(&v28));
        0x1::vector::push_back<vector<u8>>(v41, 0x1::bcs::to_bytes<u64>(&v29));
        0x1::vector::push_back<vector<u8>>(v41, 0x1::bcs::to_bytes<u64>(&v26));
        0x1::vector::push_back<vector<u8>>(v41, 0x1::bcs::to_bytes<u64>(&v39));
        0x1::vector::push_back<vector<u8>>(v41, 0x1::bcs::to_bytes<u64>(&v30));
        0x1::vector::push_back<vector<u8>>(v41, 0x1::bcs::to_bytes<u64>(&v32));
        0x4::property_map::init(&v36, 0x4::property_map::prepare_input(v33.property_keys, v33.property_types, v40));
        let v42 = MerkleGearToken{
            delete_ref           : 0x1::object::generate_delete_ref(&v36), 
            mutator_ref          : 0x4::token::generate_mutator_ref(&v36), 
            burn_ref             : 0x4::token::generate_burn_ref(&v36), 
            transfer_ref         : v38, 
            property_mutator_ref : 0x4::property_map::generate_mutator_ref(&v36), 
            gear_affixes         : v31,
        };
        move_to<MerkleGearToken>(&v37, v42);
        0x1::table::add<u64, address>(&mut v33.gears, v33.uid, 0x1::signer::address_of(&v37));
        let v43 = MintEvent{
            uid            : v33.uid, 
            gear_address   : 0x1::signer::address_of(&v37), 
            season         : v32, 
            user           : arg1, 
            name           : v3, 
            uri            : v27, 
            gear_type      : v28, 
            gear_code      : v29, 
            tier           : v26, 
            primary_effect : v30, 
            gear_affixes   : v31,
        };
        0x1::event::emit_event<MintEvent>(&mut borrow_global_mut<GearEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).mint_events, v43);
        v33.uid = v33.uid + 1;
        let v44 = borrow_global<MerkleGearToken>(0x1::signer::address_of(&v37));
        0x1::object::disable_ungated_transfer(&v44.transfer_ref);
        let v45 = 0x1::string::utf8(b"ETH");
        0x4::property_map::add(&v44.property_mutator_ref, 0x1::string::utf8(b"event"), 0x1::string::utf8(b"0x1::string::String"), 0x1::bcs::to_bytes<0x1::string::String>(&v45));
    }
    
    public(friend) fun mint_rand(arg0: &signer, arg1: u64) acquires GearEvents, MerkleGearCollection {
        let (v0, v1, v2, v3, v4, v5, v6, v7, v8) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear_factory::generate_gear_property_rand(arg1);
        let v9 = v8;
        let v10 = v7;
        let v11 = v6;
        let v12 = v5;
        let v13 = 0;
        let v14 = 0x1::vector::empty<GearAffix>();
        while (v13 < 0x1::vector::length<u64>(&v9)) {
            let v15 = GearAffix{
                gear_affix_type : *0x1::vector::borrow<u64>(&v12, v13), 
                gear_affix_code : *0x1::vector::borrow<u64>(&v11, v13), 
                target          : *0x1::vector::borrow<0x1::string::String>(&v10, v13), 
                effect          : *0x1::vector::borrow<u64>(&v9, v13),
            };
            0x1::vector::push_back<GearAffix>(&mut v14, v15);
            v13 = v13 + 1;
        };
        let v16 = 0x1::signer::address_of(arg0);
        let v17 = arg1;
        let v18 = v2;
        let v19 = v3;
        let v20 = v4;
        let v21 = v14;
        let v22 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number();
        let v23 = borrow_global_mut<MerkleGearCollection>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v24 = 0x1::account::create_signer_with_capability(&v23.signer_cap);
        let v25 = if (0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number() > 6) {
            0x1::option::some<0x4::royalty::Royalty>(0x4::royalty::create(4, 100, @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d))
        } else {
            0x1::option::none<0x4::royalty::Royalty>()
        };
        let v26 = 0x4::token::create(&v24, 0x1::string::utf8(b"Merkle Gear"), 0x1::string::utf8(b""), v0, v25, v1);
        let v27 = 0x1::object::generate_signer(&v26);
        let v28 = 0x1::object::generate_transfer_ref(&v26);
        0x1::object::transfer_with_ref(0x1::object::generate_linear_transfer_ref(&v28), v16);
        let v29 = 100000000;
        let v30 = 0x1::vector::empty<vector<u8>>();
        let v31 = &mut v30;
        0x1::vector::push_back<vector<u8>>(v31, 0x1::bcs::to_bytes<u64>(&v23.uid));
        0x1::vector::push_back<vector<u8>>(v31, 0x1::bcs::to_bytes<u64>(&v18));
        0x1::vector::push_back<vector<u8>>(v31, 0x1::bcs::to_bytes<u64>(&v19));
        0x1::vector::push_back<vector<u8>>(v31, 0x1::bcs::to_bytes<u64>(&v17));
        0x1::vector::push_back<vector<u8>>(v31, 0x1::bcs::to_bytes<u64>(&v29));
        0x1::vector::push_back<vector<u8>>(v31, 0x1::bcs::to_bytes<u64>(&v20));
        0x1::vector::push_back<vector<u8>>(v31, 0x1::bcs::to_bytes<u64>(&v22));
        0x4::property_map::init(&v26, 0x4::property_map::prepare_input(v23.property_keys, v23.property_types, v30));
        let v32 = MerkleGearToken{
            delete_ref           : 0x1::object::generate_delete_ref(&v26), 
            mutator_ref          : 0x4::token::generate_mutator_ref(&v26), 
            burn_ref             : 0x4::token::generate_burn_ref(&v26), 
            transfer_ref         : v28, 
            property_mutator_ref : 0x4::property_map::generate_mutator_ref(&v26), 
            gear_affixes         : v21,
        };
        move_to<MerkleGearToken>(&v27, v32);
        0x1::table::add<u64, address>(&mut v23.gears, v23.uid, 0x1::signer::address_of(&v27));
        let v33 = MintEvent{
            uid            : v23.uid, 
            gear_address   : 0x1::signer::address_of(&v27), 
            season         : v22, 
            user           : v16, 
            name           : v0, 
            uri            : v1, 
            gear_type      : v18, 
            gear_code      : v19, 
            tier           : v17, 
            primary_effect : v20, 
            gear_affixes   : v21,
        };
        0x1::event::emit_event<MintEvent>(&mut borrow_global_mut<GearEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).mint_events, v33);
        v23.uid = v23.uid + 1;
        0x1::signer::address_of(&v27);
    }
    
    public(friend) fun mint_v2_rand(arg0: &signer, arg1: u64, arg2: u64) acquires GearEvents, MerkleGearCollection {
        let (v0, v1, v2, v3, v4, v5, v6, v7, v8) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear_factory::generate_gear_property_rand(arg1);
        let v9 = v8;
        let v10 = v7;
        let v11 = v6;
        let v12 = v5;
        let v13 = 0;
        let v14 = 0x1::vector::empty<GearAffix>();
        while (v13 < 0x1::vector::length<u64>(&v9)) {
            let v15 = GearAffix{
                gear_affix_type : *0x1::vector::borrow<u64>(&v12, v13), 
                gear_affix_code : *0x1::vector::borrow<u64>(&v11, v13), 
                target          : *0x1::vector::borrow<0x1::string::String>(&v10, v13), 
                effect          : *0x1::vector::borrow<u64>(&v9, v13),
            };
            0x1::vector::push_back<GearAffix>(&mut v14, v15);
            v13 = v13 + 1;
        };
        let v16 = 0x1::signer::address_of(arg0);
        let v17 = arg1;
        let v18 = v2;
        let v19 = v3;
        let v20 = v4;
        let v21 = v14;
        let v22 = arg2;
        let v23 = borrow_global_mut<MerkleGearCollection>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v24 = 0x1::account::create_signer_with_capability(&v23.signer_cap);
        let v25 = if (0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number() > 6) {
            0x1::option::some<0x4::royalty::Royalty>(0x4::royalty::create(4, 100, @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d))
        } else {
            0x1::option::none<0x4::royalty::Royalty>()
        };
        let v26 = 0x4::token::create(&v24, 0x1::string::utf8(b"Merkle Gear"), 0x1::string::utf8(b""), v0, v25, v1);
        let v27 = 0x1::object::generate_signer(&v26);
        let v28 = 0x1::object::generate_transfer_ref(&v26);
        0x1::object::transfer_with_ref(0x1::object::generate_linear_transfer_ref(&v28), v16);
        let v29 = 100000000;
        let v30 = 0x1::vector::empty<vector<u8>>();
        let v31 = &mut v30;
        0x1::vector::push_back<vector<u8>>(v31, 0x1::bcs::to_bytes<u64>(&v23.uid));
        0x1::vector::push_back<vector<u8>>(v31, 0x1::bcs::to_bytes<u64>(&v18));
        0x1::vector::push_back<vector<u8>>(v31, 0x1::bcs::to_bytes<u64>(&v19));
        0x1::vector::push_back<vector<u8>>(v31, 0x1::bcs::to_bytes<u64>(&v17));
        0x1::vector::push_back<vector<u8>>(v31, 0x1::bcs::to_bytes<u64>(&v29));
        0x1::vector::push_back<vector<u8>>(v31, 0x1::bcs::to_bytes<u64>(&v20));
        0x1::vector::push_back<vector<u8>>(v31, 0x1::bcs::to_bytes<u64>(&v22));
        0x4::property_map::init(&v26, 0x4::property_map::prepare_input(v23.property_keys, v23.property_types, v30));
        let v32 = MerkleGearToken{
            delete_ref           : 0x1::object::generate_delete_ref(&v26), 
            mutator_ref          : 0x4::token::generate_mutator_ref(&v26), 
            burn_ref             : 0x4::token::generate_burn_ref(&v26), 
            transfer_ref         : v28, 
            property_mutator_ref : 0x4::property_map::generate_mutator_ref(&v26), 
            gear_affixes         : v21,
        };
        move_to<MerkleGearToken>(&v27, v32);
        0x1::table::add<u64, address>(&mut v23.gears, v23.uid, 0x1::signer::address_of(&v27));
        let v33 = MintEvent{
            uid            : v23.uid, 
            gear_address   : 0x1::signer::address_of(&v27), 
            season         : v22, 
            user           : v16, 
            name           : v0, 
            uri            : v1, 
            gear_type      : v18, 
            gear_code      : v19, 
            tier           : v17, 
            primary_effect : v20, 
            gear_affixes   : v21,
        };
        0x1::event::emit_event<MintEvent>(&mut borrow_global_mut<GearEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).mint_events, v33);
        v23.uid = v23.uid + 1;
        0x1::signer::address_of(&v27);
    }
    
    public fun repair(arg0: &signer, arg1: address, arg2: u64) acquires GearEvents, MerkleGearCollection, MerkleGearToken, UserGear {
        assert!(arg2 == 100000000, 5);
        let v0 = get_repair_shards(arg1, arg2);
        if (exists<UserGear>(0x1::signer::address_of(arg0))) {
        } else {
            let v1 = UserGear{
                equipped      : 0x1::simple_map::create<u64, address>(), 
                equipped_time : 0x1::simple_map::create<u64, u64>(),
            };
            move_to<UserGear>(arg0, v1);
        };
        let v2 = get_gear_detail(arg1);
        assert!(v2.owner == 0x1::signer::address_of(arg0), 2);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::shard_token::burn(0x1::signer::address_of(arg0), v0);
        let v3 = 0x1::string::utf8(b"durability");
        0x4::property_map::update(&borrow_global<MerkleGearToken>(arg1).property_mutator_ref, &v3, 0x1::string::utf8(b"u64"), 0x1::bcs::to_bytes<u64>(&arg2));
        if (is_equiped(0x1::signer::address_of(arg0), v2.gear_type, arg1)) {
            let (_, _) = 0x1::simple_map::upsert<u64, u64>(&mut borrow_global_mut<UserGear>(0x1::signer::address_of(arg0)).equipped_time, v2.gear_type, 0x1::timestamp::now_seconds());
        };
        let v6 = RepairEvent{
            uid          : v2.uid, 
            gear_address : arg1, 
            shard_amount : v0, 
            user         : 0x1::signer::address_of(arg0),
        };
        0x1::event::emit_event<RepairEvent>(&mut borrow_global_mut<GearEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).repair_events, v6);
    }
    
    public(friend) fun salvage_rand(arg0: &signer, arg1: address) acquires GearEvents, MerkleGearCollection, MerkleGearToken, UserGear {
        let v0 = get_gear_detail(arg1);
        assert!(v0.owner == 0x1::signer::address_of(arg0), 2);
        if (is_equiped(0x1::signer::address_of(arg0), v0.gear_type, arg1)) {
            abort 6
        };
        let (v1, v2) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear_calc::calc_salvage_shard_range(v0.tier, v0.durability);
        let v3 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::random::get_random_between(v1, v2);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::shard_token::mint(0x1::signer::address_of(arg0), v3);
        burn_gear(arg1);
        let v4 = SalvageEvent{
            uid          : v0.uid, 
            gear_address : arg1, 
            shard_amount : v3, 
            user         : 0x1::signer::address_of(arg0),
        };
        0x1::event::emit_event<SalvageEvent>(&mut borrow_global_mut<GearEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).salvage_events, v4);
        0x1::table::remove<u64, address>(&mut borrow_global_mut<MerkleGearCollection>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).gears, v0.uid);
    }
    
    public fun unequip(arg0: &signer, arg1: address) acquires GearEvents, MerkleGearCollection, MerkleGearToken, UserGear {
        let v0 = get_gear_detail(arg1);
        assert!(is_equiped(0x1::signer::address_of(arg0), v0.gear_type, arg1), 3);
        let v1 = borrow_global_mut<UserGear>(0x1::signer::address_of(arg0));
        unequip_internal(&mut v1.equipped, &mut v1.equipped_time, v0, borrow_global_mut<MerkleGearCollection>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).max_durability_duration_sec, &borrow_global<MerkleGearToken>(arg1).property_mutator_ref);
    }
    
    fun unequip_internal(arg0: &mut 0x1::simple_map::SimpleMap<u64, address>, arg1: &mut 0x1::simple_map::SimpleMap<u64, u64>, arg2: GearDetail, arg3: u64, arg4: &0x4::property_map::MutatorRef) acquires GearEvents {
        let v0 = arg2.durability;
        let v1 = 10000000 + 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x1::timestamp::now_seconds() - *0x1::simple_map::borrow<u64, u64>(arg1, &arg2.gear_type), 100000000, arg3);
        if (v0 > v1) {
            v0 = v0 - v1;
        } else {
            v0 = 0;
        };
        let v2 = 0x1::string::utf8(b"durability");
        0x4::property_map::update(arg4, &v2, 0x1::string::utf8(b"u64"), 0x1::bcs::to_bytes<u64>(&v0));
        let (_, _) = 0x1::simple_map::remove<u64, address>(arg0, &arg2.gear_type);
        let (_, _) = 0x1::simple_map::remove<u64, u64>(arg1, &arg2.gear_type);
        let v7 = UnequipEvent{
            uid          : arg2.uid, 
            gear_address : arg2.gear_address, 
            user         : arg2.owner, 
            durability   : v0,
        };
        0x1::event::emit_event<UnequipEvent>(&mut borrow_global_mut<GearEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).unequip_events, v7);
    }
    
    fun use_gear<T0>(arg0: GearDetail, arg1: u64) acquires GearEvents {
        let v0 = GearEffectEvent{
            uid          : arg0.uid, 
            gear_address : arg0.gear_address, 
            pair_type    : 0x1::type_info::type_of<T0>(), 
            user         : arg0.owner, 
            effect       : arg1, 
            gear_type    : arg0.gear_type, 
            gear_code    : arg0.gear_code,
        };
        0x1::event::emit_event<GearEffectEvent>(&mut borrow_global_mut<GearEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).gear_effect_events, v0);
    }
    
    fun validate_forge(arg0: address, arg1: GearDetail, arg2: GearDetail) acquires UserGear {
        assert!(arg1.tier == arg2.tier, 9);
        assert!(arg1.uid != arg2.uid, 11);
        assert!(arg1.owner == arg0, 2);
        assert!(arg1.durability == 100000000, 8);
        if (is_equiped(arg0, arg1.gear_type, arg1.gear_address)) {
            abort 10
        };
        assert!(arg2.owner == arg0, 2);
        assert!(arg2.durability == 100000000, 8);
        if (is_equiped(arg0, arg2.gear_type, arg2.gear_address)) {
            abort 10
        };
    }
    
    // decompiled from Move bytecode v6
}


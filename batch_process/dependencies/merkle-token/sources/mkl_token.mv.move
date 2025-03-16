module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::mkl_token {
    struct ClaimCapability<phantom T0> has drop, store {
        dummy_field: bool,
    }
    
    struct ADVISOR_POOL {
        dummy_field: bool,
    }
    
    struct COMMUNITY_POOL {
        dummy_field: bool,
    }
    
    struct CORE_TEAM_POOL {
        dummy_field: bool,
    }
    
    struct GROWTH_POOL {
        dummy_field: bool,
    }
    
    struct INVESTOR_POOL {
        dummy_field: bool,
    }
    
    struct MKL {
        dummy_field: bool,
    }
    
    struct MerkleTokenEvents has key {
        mkl_claim_events: 0x1::event::EventHandle<MklClaimEvent>,
    }
    
    struct MklClaimEvent has drop, store {
        pool_type: 0x1::string::String,
        mkl_amount: u64,
    }
    
    struct MklCoinConfig has key {
        mc: 0x1::coin::MintCapability<MKL>,
        bc: 0x1::coin::BurnCapability<MKL>,
        fc: 0x1::coin::FreezeCapability<MKL>,
    }
    
    struct MklConfig has drop, key {
        mint_ref: 0x1::fungible_asset::MintRef,
        transfer_ref: 0x1::fungible_asset::TransferRef,
        burn_ref: 0x1::fungible_asset::BurnRef,
    }
    
    struct PoolStore<phantom T0> has key {
        mkl: 0x1::object::Object<0x1::fungible_asset::FungibleStore>,
        monthly_unlock_amounts: vector<u64>,
    }
    
    public fun claim_mkl_with_cap<T0>(arg0: &ClaimCapability<T0>, arg1: u64) : 0x1::fungible_asset::FungibleAsset acquires MerkleTokenEvents, MklCoinConfig, PoolStore {
        if (arg1 == 0) {
            return 0x1::fungible_asset::zero<0x1::fungible_asset::Metadata>(get_metadata())
        };
        assert!(0x1::timestamp::now_seconds() >= mkl_tge_at(), 2);
        let v0 = get_allocation<T0>();
        let v1 = get_unlock_amount<T0>();
        let v2 = borrow_global<PoolStore<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        assert!(v0 - 0x1::fungible_asset::balance<0x1::fungible_asset::FungibleStore>(v2.mkl) + arg1 <= v1, 1);
        let v3 = 0x1::type_info::type_of<T0>();
        let v4 = MklClaimEvent{
            pool_type  : 0x1::string::utf8(0x1::type_info::struct_name(&v3)), 
            mkl_amount : arg1,
        };
        0x1::event::emit_event<MklClaimEvent>(&mut borrow_global_mut<MerkleTokenEvents>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).mkl_claim_events, v4);
        let (v5, v6) = 0x1::coin::get_paired_transfer_ref<MKL>(&borrow_global<MklCoinConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).fc);
        let v7 = v5;
        0x1::coin::return_paired_transfer_ref(v7, v6);
        0x1::fungible_asset::withdraw_with_ref<0x1::fungible_asset::FungibleStore>(&v7, v2.mkl, arg1)
    }
    
    fun create_pool_fungible_store<T0>(arg0: &signer, arg1: &0x1::fungible_asset::MintRef, arg2: u64, arg3: vector<u64>) : PoolStore<T0> {
        let v0 = 0x1::object::create_object(0x1::signer::address_of(arg0));
        let v1 = 0x1::fungible_asset::create_store<0x1::fungible_asset::Metadata>(&v0, get_metadata());
        0x1::fungible_asset::deposit<0x1::fungible_asset::FungibleStore>(v1, 0x1::fungible_asset::mint(arg1, arg2));
        PoolStore<T0>{
            mkl                    : v1, 
            monthly_unlock_amounts : arg3,
        }
    }
    
    public(friend) fun deposit_to_freezed_mkl_store(arg0: &0x1::object::Object<0x1::fungible_asset::FungibleStore>, arg1: 0x1::fungible_asset::FungibleAsset) acquires MklCoinConfig {
        let (v0, v1) = 0x1::coin::get_paired_transfer_ref<MKL>(&borrow_global<MklCoinConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).fc);
        let v2 = v0;
        0x1::fungible_asset::deposit_with_ref<0x1::fungible_asset::FungibleStore>(&v2, *arg0, arg1);
        0x1::coin::return_paired_transfer_ref(v2, v1);
    }
    
    public(friend) fun freeze_mkl_store(arg0: &0x1::object::Object<0x1::fungible_asset::FungibleStore>, arg1: bool) acquires MklCoinConfig {
        let (v0, v1) = 0x1::coin::get_paired_transfer_ref<MKL>(&borrow_global<MklCoinConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).fc);
        let v2 = v0;
        0x1::fungible_asset::set_frozen_flag<0x1::fungible_asset::FungibleStore>(&v2, *arg0, arg1);
        0x1::coin::return_paired_transfer_ref(v2, v1);
    }
    
    public fun get_allocation<T0>() : u64 acquires PoolStore {
        let v0 = borrow_global<PoolStore<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        *0x1::vector::borrow<u64>(&v0.monthly_unlock_amounts, 0x1::vector::length<u64>(&v0.monthly_unlock_amounts) - 1)
    }
    
    public fun get_metadata() : 0x1::object::Object<0x1::fungible_asset::Metadata> {
        let v0 = 0x1::coin::paired_metadata<MKL>();
        0x1::option::extract<0x1::object::Object<0x1::fungible_asset::Metadata>>(&mut v0)
    }
    
    public fun get_unlock_amount<T0>() : u64 acquires PoolStore {
        if (0x1::timestamp::now_seconds() < 1725537600 || !exists<PoolStore<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d)) {
            return 0
        };
        let v0 = borrow_global<PoolStore<T0>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d);
        let v1 = (0x1::timestamp::now_seconds() - 1725537600) / 2628000 + 1;
        if (v1 >= 0x1::vector::length<u64>(&v0.monthly_unlock_amounts)) {
            return *0x1::vector::borrow<u64>(&v0.monthly_unlock_amounts, 0x1::vector::length<u64>(&v0.monthly_unlock_amounts) - 1)
        };
        *0x1::vector::borrow<u64>(&v0.monthly_unlock_amounts, v1)
    }
    
    public fun initialize_module(arg0: &signer) acquires MklConfig {
        assert!(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d == 0x1::signer::address_of(arg0), 0);
        if (exists<MklCoinConfig>(0x1::signer::address_of(arg0))) {
        } else {
            let (v0, v1, v2) = 0x1::coin::initialize<MKL>(arg0, 0x1::string::utf8(b"MKL"), 0x1::string::utf8(b"MKL"), 6, false);
            let v3 = v0;
            let (v4, v5) = 0x1::coin::get_paired_burn_ref<MKL>(&v3);
            let v6 = v4;
            0x1::fungible_asset::burn(&v6, 0x1::coin::coin_to_fungible_asset<MKL>(0x1::coin::zero<MKL>()));
            0x1::coin::return_paired_burn_ref(v6, v5);
            let v7 = MklCoinConfig{
                mc : v2, 
                bc : v3, 
                fc : v1,
            };
            move_to<MklCoinConfig>(arg0, v7);
        };
        if (exists<MklConfig>(0x1::signer::address_of(arg0))) {
            move_from<MklConfig>(0x1::signer::address_of(arg0));
        };
        if (exists<MerkleTokenEvents>(0x1::signer::address_of(arg0))) {
        } else {
            let v8 = MerkleTokenEvents{mkl_claim_events: 0x1::account::new_event_handle<MklClaimEvent>(arg0)};
            move_to<MerkleTokenEvents>(arg0, v8);
        };
    }
    
    public fun mint_claim_capability<T0>(arg0: &signer) : ClaimCapability<T0> {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        ClaimCapability<T0>{dummy_field: false}
    }
    
    public entry fun mint_mkl(arg0: &signer) acquires MklCoinConfig, PoolStore {
        let (v0, v1) = 0x1::coin::get_paired_transfer_ref<MKL>(&borrow_global<MklCoinConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).fc);
        let v2 = v0;
        0x1::coin::return_paired_transfer_ref(v2, v1);
        0x1::primary_fungible_store::deposit(0x1::signer::address_of(arg0), 0x1::fungible_asset::withdraw_with_ref<0x1::fungible_asset::FungibleStore>(&v2, borrow_global<PoolStore<COMMUNITY_POOL>>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).mkl, 100000000));
    }
    
    public fun mkl_tge_at() : u64 {
        1725537600
    }
    
    public fun run_token_generation_event(arg0: &signer) acquires MklCoinConfig {
        assert!(0x1::signer::address_of(arg0) == @0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d, 0);
        let (v0, v1) = 0x1::coin::get_paired_mint_ref<MKL>(&borrow_global<MklCoinConfig>(0x1::signer::address_of(arg0)).mc);
        let v2 = v0;
        move_to<PoolStore<COMMUNITY_POOL>>(arg0, create_pool_fungible_store<COMMUNITY_POOL>(arg0, &v2, 46000000000000, vector[0, 9500000000000, 10400509123825, 11284809083421, 12153191643744, 13005943317981, 13843345462082, 14665674367589, 15473201352797, 16266192852271, 17044910504755, 17809611239494, 18560547361008, 19297966632335, 20022112356777, 20733223458180, 21431534559757, 22117276061506, 22790674216224, 23451951204156, 24101325206306, 24739010476417, 25365217411667, 25980152622081, 26584018998708, 27177015780556, 27759338620331, 28331179648990, 28892727539132, 29444167567253, 29985681674867, 30517448528544, 31039643578855, 31552439118260, 32056004337956, 32550505383697, 33036105410616, 33512964637049, 33981240397407, 34441087194078, 34892656748409, 35336098050763, 35771557409674, 36199178500124, 36619102410947, 37031467691374, 37436410396754, 37834064133437, 38224560102860, 38608027144833, 38984591780051, 39354378251835, 39717508567126, 40074102536743, 40424277814906, 40768149938062, 41105832363002, 41437436504292, 41763071771040, 42082845602986, 42396863505957, 42705229086674, 43008044086939, 43305408417198, 43597420189513, 43884175749927, 44165769710253, 44442294979293, 44713842793490, 44980502747032, 45242362821410, 45499509414449, 45752027368814, 46000000000000]));
        move_to<PoolStore<GROWTH_POOL>>(arg0, create_pool_fungible_store<GROWTH_POOL>(arg0, &v2, 17000000000000, vector[0, 4000000000000, 4250000000000, 4500000000000, 4750000000000, 5000000000000, 5250000000000, 5500000000000, 5750000000000, 6000000000000, 6250000000000, 6500000000000, 6750000000000, 7000000000000, 7250000000000, 7500000000000, 7750000000000, 8000000000000, 8250000000000, 8500000000000, 8750000000000, 9000000000000, 9250000000000, 9500000000000, 9750000000000, 10000000000000, 10250000000000, 10500000000000, 10750000000000, 11000000000000, 11250000000000, 11500000000000, 11750000000000, 12000000000000, 12250000000000, 12500000000000, 12750000000000, 13000000000000, 13250000000000, 13500000000000, 13750000000000, 14000000000000, 14250000000000, 14500000000000, 14750000000000, 15000000000000, 15250000000000, 15500000000000, 15750000000000, 16000000000000, 16250000000000, 16500000000000, 16750000000000, 17000000000000, 17000000000000, 17000000000000, 17000000000000, 17000000000000, 17000000000000, 17000000000000, 17000000000000, 17000000000000, 17000000000000, 17000000000000, 17000000000000, 17000000000000, 17000000000000, 17000000000000, 17000000000000, 17000000000000, 17000000000000, 17000000000000, 17000000000000, 17000000000000]));
        move_to<PoolStore<CORE_TEAM_POOL>>(arg0, create_pool_fungible_store<CORE_TEAM_POOL>(arg0, &v2, 20000000000000, vector[0, 0, 0, 0, 0, 0, 0, 555555555556, 1111111111111, 1666666666667, 2222222222222, 2777777777778, 3333333333333, 3888888888889, 4444444444444, 5000000000000, 5555555555556, 6111111111111, 6666666666667, 7222222222222, 7777777777778, 8333333333333, 8888888888889, 9444444444444, 10000000000000, 10555555555556, 11111111111111, 11666666666667, 12222222222222, 12777777777778, 13333333333333, 13888888888889, 14444444444444, 15000000000000, 15555555555556, 16111111111111, 16666666666667, 17222222222222, 17777777777778, 18333333333333, 18888888888889, 19444444444444, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000, 20000000000000]));
        move_to<PoolStore<INVESTOR_POOL>>(arg0, create_pool_fungible_store<INVESTOR_POOL>(arg0, &v2, 14000000000000, vector[0, 0, 0, 0, 0, 0, 0, 583333333333, 1166666666667, 1750000000000, 2333333333333, 2916666666667, 3500000000000, 4083333333333, 4666666666667, 5250000000000, 5833333333333, 6416666666667, 7000000000000, 7583333333333, 8166666666667, 8750000000000, 9333333333333, 9916666666667, 10500000000000, 11083333333333, 11666666666667, 12250000000000, 12833333333333, 13416666666667, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000, 14000000000000]));
        move_to<PoolStore<ADVISOR_POOL>>(arg0, create_pool_fungible_store<ADVISOR_POOL>(arg0, &v2, 3000000000000, vector[0, 0, 0, 0, 0, 0, 0, 125000000000, 250000000000, 375000000000, 500000000000, 625000000000, 750000000000, 875000000000, 1000000000000, 1125000000000, 1250000000000, 1375000000000, 1500000000000, 1625000000000, 1750000000000, 1875000000000, 2000000000000, 2125000000000, 2250000000000, 2375000000000, 2500000000000, 2625000000000, 2750000000000, 2875000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000, 3000000000000]));
        0x1::coin::return_paired_mint_ref(v2, v1);
    }
    
    public(friend) fun withdraw_from_freezed_mkl_store(arg0: &0x1::object::Object<0x1::fungible_asset::FungibleStore>, arg1: u64) : 0x1::fungible_asset::FungibleAsset acquires MklCoinConfig {
        let (v0, v1) = 0x1::coin::get_paired_transfer_ref<MKL>(&borrow_global<MklCoinConfig>(@0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d).fc);
        let v2 = v0;
        0x1::coin::return_paired_transfer_ref(v2, v1);
        0x1::fungible_asset::withdraw_with_ref<0x1::fungible_asset::FungibleStore>(&v2, *arg0, arg1)
    }
    
    // decompiled from Move bytecode v6
}


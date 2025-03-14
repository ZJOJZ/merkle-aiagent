module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::claimable_fa_store {
    struct AdminCapability has drop, store {
        resource_account: address,
        extend_ref: 0x1::object::ExtendRef,
        delete_ref: 0x1::object::DeleteRef,
    }
    
    struct ClaimCapability has drop, store {
        resource_account: address,
    }
    
    struct ClaimableFaStore has key {
        fungible_store: 0x1::object::Object<0x1::fungible_asset::FungibleStore>,
        signer_cap: 0x1::account::SignerCapability,
    }
    
    public fun add_claimable_fa_store(arg0: &signer, arg1: 0x1::object::Object<0x1::fungible_asset::Metadata>) : AdminCapability {
        let v0 = 0x1::transaction_context::generate_auid_address();
        let (v1, v2) = 0x1::account::create_resource_account(arg0, 0x1::bcs::to_bytes<address>(&v0));
        let v3 = v1;
        let v4 = 0x1::object::create_object(0x1::signer::address_of(&v3));
        let v5 = ClaimableFaStore{
            fungible_store : 0x1::primary_fungible_store::ensure_primary_store_exists<0x1::fungible_asset::Metadata>(0x1::signer::address_of(&v3), arg1), 
            signer_cap     : v2,
        };
        move_to<ClaimableFaStore>(&v3, v5);
        AdminCapability{
            resource_account : 0x1::signer::address_of(&v3), 
            extend_ref       : 0x1::object::generate_extend_ref(&v4), 
            delete_ref       : 0x1::object::generate_delete_ref(&v4),
        }
    }
    
    public fun claim_funding_store(arg0: &ClaimCapability, arg1: u64) : 0x1::fungible_asset::FungibleAsset acquires ClaimableFaStore {
        let v0 = borrow_global<ClaimableFaStore>(arg0.resource_account);
        let v1 = 0x1::account::create_signer_with_capability(&v0.signer_cap);
        0x1::fungible_asset::withdraw<0x1::fungible_asset::FungibleStore>(&v1, v0.fungible_store, arg1)
    }
    
    public fun deposit_funding_store(arg0: &signer, arg1: address, arg2: u64) acquires ClaimableFaStore {
        let v0 = borrow_global<ClaimableFaStore>(arg1);
        0x1::fungible_asset::deposit<0x1::fungible_asset::FungibleStore>(v0.fungible_store, 0x1::primary_fungible_store::withdraw<0x1::fungible_asset::Metadata>(arg0, 0x1::fungible_asset::store_metadata<0x1::fungible_asset::FungibleStore>(v0.fungible_store), arg2));
    }
    
    public fun deposit_funding_store_fa(arg0: &AdminCapability, arg1: 0x1::fungible_asset::FungibleAsset) acquires ClaimableFaStore {
        let v0 = borrow_global<ClaimableFaStore>(arg0.resource_account);
        assert!(0x1::fungible_asset::metadata_from_asset(&arg1) == 0x1::fungible_asset::store_metadata<0x1::fungible_asset::FungibleStore>(v0.fungible_store), 1);
        0x1::fungible_asset::deposit<0x1::fungible_asset::FungibleStore>(v0.fungible_store, arg1);
    }
    
    public fun deposit_funding_store_with_admin_cap(arg0: &signer, arg1: &AdminCapability, arg2: u64) acquires ClaimableFaStore {
        deposit_funding_store(arg0, arg1.resource_account, arg2);
    }
    
    public fun get_metadata_by_uid(arg0: &ClaimCapability) : 0x1::object::Object<0x1::fungible_asset::Metadata> acquires ClaimableFaStore {
        0x1::fungible_asset::store_metadata<0x1::fungible_asset::FungibleStore>(borrow_global<ClaimableFaStore>(arg0.resource_account).fungible_store)
    }
    
    public fun mint_claim_capability(arg0: &AdminCapability) : ClaimCapability {
        assert!(exists<ClaimableFaStore>(arg0.resource_account), 0);
        ClaimCapability{resource_account: arg0.resource_account}
    }
    
    // decompiled from Move bytecode v6
}


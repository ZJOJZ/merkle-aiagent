module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::pyth_scripts {
    public fun get_price_for_random(arg0: vector<u8>) : u64 {
        let v0 = 0x7e783b349d3e89cf5931af376ebeadbfab855b3fa239b7ada8f5a92fbea6b387::price_identifier::from_byte_vec(arg0);
        assert!(0x7e783b349d3e89cf5931af376ebeadbfab855b3fa239b7ada8f5a92fbea6b387::pyth::price_feed_exists(v0), 0);
        let v1 = 0x7e783b349d3e89cf5931af376ebeadbfab855b3fa239b7ada8f5a92fbea6b387::pyth::get_price_unsafe(v0);
        let v2 = 0x7e783b349d3e89cf5931af376ebeadbfab855b3fa239b7ada8f5a92fbea6b387::price::get_price(&v1);
        0x7e783b349d3e89cf5931af376ebeadbfab855b3fa239b7ada8f5a92fbea6b387::i64::get_magnitude_if_positive(&v2)
    }
    
    public fun get_price_from_vaa_no_older_than(arg0: vector<u8>, arg1: u64) : (u64, u64, u64) {
        let v0 = 0x7e783b349d3e89cf5931af376ebeadbfab855b3fa239b7ada8f5a92fbea6b387::pyth::get_price_no_older_than(0x7e783b349d3e89cf5931af376ebeadbfab855b3fa239b7ada8f5a92fbea6b387::price_identifier::from_byte_vec(arg0), arg1);
        let v1 = 0x7e783b349d3e89cf5931af376ebeadbfab855b3fa239b7ada8f5a92fbea6b387::price::get_expo(&v0);
        if (0x7e783b349d3e89cf5931af376ebeadbfab855b3fa239b7ada8f5a92fbea6b387::i64::get_is_negative(&v1)) {
            arg1 = 0x7e783b349d3e89cf5931af376ebeadbfab855b3fa239b7ada8f5a92fbea6b387::i64::get_magnitude_if_negative(&v1);
        } else {
            arg1 = 0x7e783b349d3e89cf5931af376ebeadbfab855b3fa239b7ada8f5a92fbea6b387::i64::get_magnitude_if_positive(&v1);
        };
        let v2 = 0x7e783b349d3e89cf5931af376ebeadbfab855b3fa239b7ada8f5a92fbea6b387::price::get_price(&v0);
        (0x7e783b349d3e89cf5931af376ebeadbfab855b3fa239b7ada8f5a92fbea6b387::i64::get_magnitude_if_positive(&v2), arg1, 0x7e783b349d3e89cf5931af376ebeadbfab855b3fa239b7ada8f5a92fbea6b387::price::get_timestamp(&v0))
    }
    
    public fun update_pyth(arg0: &signer, arg1: vector<u8>) {
        let v0 = 0x1::vector::empty<vector<u8>>();
        0x1::vector::push_back<vector<u8>>(&mut v0, arg1);
        0x7e783b349d3e89cf5931af376ebeadbfab855b3fa239b7ada8f5a92fbea6b387::pyth::update_price_feeds(v0, 0x1::coin::withdraw<0x1::aptos_coin::AptosCoin>(arg0, 0x7e783b349d3e89cf5931af376ebeadbfab855b3fa239b7ada8f5a92fbea6b387::pyth::get_update_fee(&v0)));
    }
    
    // decompiled from Move bytecode v6
}


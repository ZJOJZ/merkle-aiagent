module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::gear_calc {
    public fun calc_lootbox_shard_range(arg0: u64) : (u64, u64) {
        let v0 = vector[3000000, 6000000, 12000000, 24000000, 48000000];
        let v1 = *0x1::vector::borrow<u64>(&v0, arg0);
        (0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v1 * 10, 70000, 1000000), 900000, 1000000), 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v1 * 10, 70000, 1000000), 1100000, 1000000))
    }
    
    public fun calc_repair_required_shards(arg0: u64, arg1: u64, arg2: u64) : u64 {
        let v0 = vector[100000000, 307692308, 946745562, 2913063268, 8963271594];
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(*0x1::vector::borrow<u64>(&v0, arg2) * 10, arg0 - arg1, 10000000000)
    }
    
    public fun calc_salvage_shard_range(arg0: u64, arg1: u64) : (u64, u64) {
        let v0 = vector[100000000, 307692308, 946745562, 2913063268, 8963271594];
        let v1 = *0x1::vector::borrow<u64>(&v0, arg0);
        (0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v1 * 10, 600000, 100000000), arg1, 100000000), 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v1 * 10, 800000, 100000000), arg1, 100000000))
    }
    
    public fun get_forge_rates(arg0: u64) : (u64, u64) {
        let v0 = vector[857100, 857100, 857100, 857100, 1000000];
        let v1 = vector[0, 0, 0, 0, 0];
        (*0x1::vector::borrow<u64>(&v0, arg0), *0x1::vector::borrow<u64>(&v1, arg0))
    }
    
    public fun get_forge_required_shard(arg0: u64) : u64 {
        let v0 = vector[9000000, 18000000, 36000000, 72000000, 144000000];
        *0x1::vector::borrow<u64>(&v0, arg0)
    }
    
    // decompiled from Move bytecode v6
}


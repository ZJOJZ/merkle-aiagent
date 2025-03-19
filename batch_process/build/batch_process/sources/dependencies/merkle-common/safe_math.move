module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math {
    public fun diff(arg0: u64, arg1: u64) : u64 {
        max(arg0, arg1) - min(arg0, arg1)
    }
    
    public fun exp(arg0: u64, arg1: u64) : u64 {
        let v0 = 1;
        while (arg1 > 0) {
            if (arg1 & 1 > 0) {
                v0 = v0 * arg0;
            };
            arg1 = arg1 >> 1;
            arg0 = arg0 * arg0;
        };
        v0
    }
    
    public fun max(arg0: u64, arg1: u64) : u64 {
        if (arg0 >= arg1) {
            arg0
        } else {
            arg1
        }
    }
    
    public fun min(arg0: u64, arg1: u64) : u64 {
        if (arg0 < arg1) {
            arg0
        } else {
            arg1
        }
    }
    
    public fun safe_mul_div(arg0: u64, arg1: u64, arg2: u64) : u64 {
        if (arg2 == 0) {
            abort 1002
        };
        ((arg0 as u256) * (arg1 as u256) / (arg2 as u256)) as u64
    }
    
    public fun signed_plus(arg0: u64, arg1: bool, arg2: u64, arg3: bool) : (u64, bool) {
        if (arg1 == arg3) {
            return (arg0 + arg2, arg1)
        };
        let v0 = arg0 >= arg2 && arg1 || arg3;
        (diff(arg0, arg2), v0)
    }
    
    // decompiled from Move bytecode v6
}


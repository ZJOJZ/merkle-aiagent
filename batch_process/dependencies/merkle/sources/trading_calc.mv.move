module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::trading_calc {
    public fun calculate_funding_fee(arg0: u64, arg1: bool, arg2: u64, arg3: bool, arg4: u64, arg5: bool) : (u64, bool) {
        let (v0, v1) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::signed_plus(arg0, arg1, arg4, !arg5);
        if (arg3) {
            arg3 = !v1;
        } else {
            arg3 = v1;
        };
        (0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(arg2, v0, 100000000), arg3)
    }
    
    public fun calculate_funding_fee_per_size(arg0: u64, arg1: bool, arg2: u64, arg3: bool, arg4: u64, arg5: bool, arg6: u64) : (u64, bool) {
        let (v0, v1) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::signed_plus(arg2, arg3, arg4, arg5);
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::signed_plus(arg0, arg1, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v0 / 2, arg6, 86400), v1)
    }
    
    public fun calculate_funding_rate(arg0: u64, arg1: bool, arg2: u64, arg3: u64, arg4: u64, arg5: u64, arg6: u64) : (u64, bool) {
        let v0 = arg2 > arg3;
        if (arg4 == 0) {
            arg3 = 0;
        } else {
            arg3 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::diff(arg2, arg3), 100000000000, arg4);
        };
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::signed_plus(arg0, arg1, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::min(arg3, 100000000000), arg5, 100000000000), arg6, 86400), v0)
    }
    
    public fun calculate_maker_taker_fee(arg0: u64, arg1: u64, arg2: u64, arg3: u64, arg4: u64, arg5: bool, arg6: bool) : u64 {
        let v0 = arg0 > arg1;
        let v1 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::diff(arg0, arg1);
        let v2 = arg0 > arg1;
        let v3 = if (arg5 && arg6) {
            true
        } else {
            if (arg5) {
                false
            } else {
                !arg6
            }
        };
        let v4 = if (v3) {
            if (v2) {
                true
            } else {
                v1 < arg4
            }
        } else {
            if (v2) {
                v1 > arg4
            } else {
                false
            }
        };
        if (v2 == v4) {
            if (arg5 == arg6 == v0) {
                arg1 = arg3;
            } else {
                arg1 = arg2;
            };
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(arg4, arg1, 1000000)
        } else {
            let v6 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::diff(arg4, v1), 1000000, arg4);
            0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(arg4, v6, 1000000), arg3, 1000000) + 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(arg4, 1000000 - v6, 1000000), arg2, 1000000)
        }
    }
    
    public fun calculate_new_price(arg0: u64, arg1: u64, arg2: u64, arg3: u64) : u64 {
        if (arg1 == 0) {
            return arg2
        };
        if (arg3 == 0) {
            return arg0
        };
        (((arg1 as u256) + (arg3 as u256)) * 1000000000000000000 / ((arg1 as u256) * 1000000000000000000 / (arg0 as u256) + (arg3 as u256) * 1000000000000000000 / (arg2 as u256))) as u64
    }
    
    public fun calculate_partial_close_amounts(arg0: u64, arg1: u64, arg2: bool, arg3: u64) : (u64, u64) {
        let v0 = if (arg2) {
            if (arg0 > arg1) {
                arg0 - arg1
            } else {
                arg0 = arg1;
                0
            }
        } else {
            arg0 + arg1
        };
        if (v0 > arg3) {
            v0 = v0 - arg3;
        } else {
            arg0 = arg0 + arg3 - v0;
            v0 = 0;
        };
        (v0, arg0)
    }
    
    public fun calculate_pmkl_amount(arg0: u64, arg1: u64, arg2: u64, arg3: u64) : u64 {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(5 * arg0, (arg1 + arg2) / 2, 1000000), 1000000 + arg3, 1000000)
    }
    
    public fun calculate_pnl_without_fee(arg0: u64, arg1: u64, arg2: u64, arg3: bool) : (u64, bool) {
        if (arg0 == arg1) {
            return (0, true)
        };
        let v0 = if (arg1 >= arg0) {
            arg1 - arg0
        } else {
            arg0 - arg1
        };
        let (v1, v2) = if (arg3 == (arg1 >= arg0)) {
            (true, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v0, 1000000, arg0), arg2, 1000000))
        } else {
            (false, 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(v0, 1000000, arg0), arg2, 1000000))
        };
        (v2, v1)
    }
    
    public fun calculate_point_amount(arg0: u64, arg1: u64, arg2: u64) : u64 {
        abort 0
    }
    
    public fun calculate_point_amount2(arg0: u64, arg1: u64, arg2: u64, arg3: u64, arg4: u64) : u64 {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(arg0, arg1 + arg2, 1000000), 1000000, arg3), 1000000 + arg4, 1000000) / 1000000
    }
    
    public fun calculate_price_impact(arg0: u64, arg1: u64, arg2: bool, arg3: bool, arg4: u64, arg5: u64, arg6: u64) : u64 {
        if (arg6 == 0) {
            return arg0
        };
        let v0 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::diff(arg4, arg5);
        let v1 = arg4 > arg5;
        let v2 = if (arg2 && arg3) {
            true
        } else {
            if (arg2) {
                false
            } else {
                !arg3
            }
        };
        let v3 = if (v2) {
            if (v1) {
                arg4 = v0 + arg1;
                true
            } else {
                arg4 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::diff(v0, arg1);
                v0 < arg1
            }
        } else {
            if (v1) {
                arg4 = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::diff(v0, arg1);
                v0 > arg1
            } else {
                arg4 = v0 + arg1;
                false
            }
        };
        if (v1) {
            arg5 = arg0 + 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(arg0, v0, arg6);
        } else {
            arg5 = arg0 - 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(arg0, v0, arg6);
        };
        let v4 = if (v3) {
            arg0 + 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(arg0, arg4, arg6)
        } else {
            arg0 - 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(arg0, arg4, arg6)
        };
        (arg5 + v4) / 2
    }
    
    public fun calculate_risk_fees(arg0: u64, arg1: u64, arg2: bool, arg3: u64, arg4: u64, arg5: bool, arg6: u64, arg7: u64, arg8: bool) : (u64, bool, u64, bool, u64) {
        let v0 = calculate_rollover_fee(arg6, arg0, arg4);
        let (v1, v2) = calculate_funding_fee(arg1, arg2, arg3, arg5, arg7, arg8);
        let (v3, v4) = 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::signed_plus(v0, false, v1, v2);
        (v0, v2, v1, v4, v3)
    }
    
    public fun calculate_rollover_fee(arg0: u64, arg1: u64, arg2: u64) : u64 {
        if (arg2 == 0) {
            return 0
        };
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::safe_math::safe_mul_div(arg1 - arg0, arg2, 1000000) / 100
    }
    
    public fun calculate_rollover_fee_delta(arg0: u64, arg1: u64, arg2: u64) : u64 {
        (arg1 - arg0) * arg2
    }
    
    public fun calculate_settle_amount(arg0: u64, arg1: bool, arg2: u64, arg3: bool) : (u64, bool) {
        let v0 = true;
        let v1 = if (arg1 && arg3) {
            v0 = false;
            arg0 + arg2
        } else {
            if (arg1 && !arg3) {
                if (arg0 > arg2) {
                    v0 = false;
                    arg0 - arg2
                } else {
                    arg2 - arg0
                }
            } else {
                if (arg1 && false || arg3) {
                    if (arg0 > arg2) {
                        arg0 - arg2
                    } else {
                        v0 = false;
                        arg2 - arg0
                    }
                } else {
                    arg0 + arg2
                }
            }
        };
        (v1, v0)
    }
    
    // decompiled from Move bytecode v6
}


module aptos_address::BatchCaller {
    use std::signer;
    use std::vector;
    use std::string::String;
    use std::string;
    use merkle_address::trading;
    use merkle_address::fa_box;
    use merkle_address::pair_types;
    use aptos_framework::bcs_stream;

    const MAX_PRICE: u64 = 18_446_744_073_709_551_615;
    const MIN_PRICE: u64 = 1;
    struct OrderParams has drop {
        p0: address,
        p1: u64,
        p2: u64,
        p3: u64,
        p4: bool,
        p5: bool,
        p6: bool,
        p7: u64,
        p8: u64,
        p9: bool,
        p10: address,
    }
    public fun decode_orderparams(stream: &mut bcs_stream::BCSStream): OrderParams {
        OrderParams {
            p0: bcs_stream::deserialize_address(stream),
            p1: bcs_stream::deserialize_u64(stream),
            p2: bcs_stream::deserialize_u64(stream),
            p3: bcs_stream::deserialize_u64(stream),
            p4: bcs_stream::deserialize_bool(stream),
            p5: bcs_stream::deserialize_bool(stream),
            p6: bcs_stream::deserialize_bool(stream),
            p7: bcs_stream::deserialize_u64(stream),
            p8: bcs_stream::deserialize_u64(stream),
            p9: bcs_stream::deserialize_bool(stream),
            p10: bcs_stream::deserialize_address(stream),
        }
    }
    

    fun choose_minmax(condition: bool): u64 {
        if (condition) { MAX_PRICE } else { MIN_PRICE }
    }

    fun call_place_order<T1, T2>(caller: &signer, sizedelta: u64, amount: u64, side: bool) {
        trading::place_order_v3<T1, T2>(
                caller, 
                signer::address_of(caller),
                sizedelta,
                amount,
                choose_minmax(side),
                side,
                true,
                true,
                choose_minmax(!side),
                choose_minmax(side),
                !side,
        );
    }

    public entry fun batch_execute_merkle_market_v1(
        caller: &signer,
        num_orders: u64,
        ordertype: vector<u8>,
        ordersizedelta: vector<u64>,
        orderamount: vector<u64>,
        orderside: vector<bool>, // true = long, false = short
    ) {
        let i = 0;
        while(i < num_orders) {
            if (ordertype[i] == 0) {
                call_place_order<pair_types::BTC_USD, fa_box::W_USDC>(caller, ordersizedelta[i], orderamount[i], orderside[i]);
            } else if (ordertype[i] == 1) {
                call_place_order<pair_types::ETH_USD, fa_box::W_USDC>(caller, ordersizedelta[i], orderamount[i], orderside[i]);
            } else if (ordertype[i] == 2) {
                call_place_order<pair_types::APT_USD, fa_box::W_USDC>(caller, ordersizedelta[i], orderamount[i], orderside[i]);
            } else if (ordertype[i] == 3) {
                call_place_order<pair_types::SUI_USD, fa_box::W_USDC>(caller, ordersizedelta[i], orderamount[i], orderside[i]);
            } else if (ordertype[i] == 4) {
                call_place_order<pair_types::TRUMP_USD, fa_box::W_USDC>(caller, ordersizedelta[i], orderamount[i], orderside[i]);
            } else if (ordertype[i] == 5) {
                call_place_order<pair_types::DOGE_USD, fa_box::W_USDC>(caller, ordersizedelta[i], orderamount[i], orderside[i]);
            };
            i = i + 1; 
        }
    }

    public entry fun batch_execute_merkle_v1<T0,T1>(
        caller: &signer, 
        num_orders: u64,
        //orders: vector<OrderParams>
        params: vector<u8>,
    ) {
        //assert!(num_orders == vector::length(&orders), 1);
        
        let stream = bcs_stream::new(params);
        let order = decode_orderparams(&mut stream);
        trading::place_order_v3<T0,T1>(
                caller,
                order.p0,
                order.p1,
                order.p2,
                order.p3,
                order.p4,
                order.p5,
                order.p6,
                order.p7,
                order.p8,
                order.p9
            );
        // let i = 0;
        // while (i < num_orders) {
        //     let order = vector::borrow(&orders, i);
            
        //     i = i + 1;
        // }
    }

    public entry fun batch_execute_merkle<T0,T1>(
        caller: &signer, 
        //num_orders: u64,
        //orders: vector<OrderParams>
        p0: address,
        p1: u64,
        p2: u64,
        p3: u64,
        p4: bool,
        p5: bool,
        p6: bool,
        p7: u64,
        p8: u64,
        p9: bool,
        p10: address,
    ) {

        trading::place_order_v3<T0,T1>(
                caller,
                p0,p1,p2,p3,p4,p5,p6,p7,p8,p9
            );

    }
}

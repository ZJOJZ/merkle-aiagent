module aptos_address::BatchCaller {
    use std::signer;
    use std::vector;
    use merkle_address::trading;
    use aptos_framework::bcs_stream;

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

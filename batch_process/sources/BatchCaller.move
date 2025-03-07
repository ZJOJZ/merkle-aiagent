module aptos_address::BatchCaller {
    use aptos_std::transaction;
    use std::string;
    use std::vector;
    use aptos_framework::type_info;

    public entry fun batch_execute(
        caller: &signer, 
        targets: vector<string::String>,   
        type_args_list: vector<vector<string::String>>,
        function_args_list: vector<vector<u8>> 
    ) {
        let num_calls = vector::length(&targets);
        assert!(num_calls == vector::length(&type_args_list), 1);
        assert!(num_calls == vector::length(&function_args_list), 2);

        let i = 0;
        while (i < num_calls) {
            let target_function = vector::borrow(&targets, i);
            let type_args = vector::borrow(&type_args_list, i);
            let function_args = vector::borrow(&function_args_list, i);

            let separator = b"::";
            let parts = string::split_bytes(target_function, &separator);
            assert!(vector::length(&parts) == 3, 3);

            let target_address = string::to_address(vector::borrow(&parts, 0));
            let module_name = vector::borrow(&parts, 1);
            let function_name = vector::borrow(&parts, 2);

            code::execute_entry_function(
                target_address, 
                module_name, 
                function_name, 
                type_args, 
                function_args
            );

            i = i + 1;
        }
    }
}

module 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::managed_season {
    public entry fun add_new_season(arg0: &signer, arg1: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::add_new_season(arg0, arg1);
    }
    
    public fun get_current_season_info() : 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::SeasonView {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_info()
    }
    
    public fun get_season_info(arg0: u64) : 0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::SeasonView {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_season_info(arg0)
    }
    
    public entry fun initialize_module(arg0: &signer) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::initialize_module(arg0);
    }
    
    public entry fun set_season_end_sec(arg0: &signer, arg1: u64, arg2: u64) {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::set_season_end_sec(arg0, arg1, arg2);
    }
    
    public fun current_season_number() : u64 {
        0x33a8693758d1d28a9305946c7758b7548a04736c35929eac22eb0de2a865275d::season::get_current_season_number()
    }
    
    // decompiled from Move bytecode v6
}


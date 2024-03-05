local config = {}

config.ltnc_item_slot_count = 27
config.ltnc_ltn_slot_count  = 13
config.ltnc_misc_slot_count = 14

config.ltn_signals = {
    -- signal_name = {default_value, slot, bounds = {min, max}}
    ["ltn-network-id"] = {default = -1, slot = 1, bounds = {min = -2^31, max = 2^31 - 1}},
    
    ["ltn-requester-threshold"] = {default = 1000, slot = 5, bounds = {min = -2000000000, max = 2000000000}},
    ["ltn-requester-stack-threshold"] = {default = 0, slot = 6, bounds = {min = -2000000000, max = 2000000000}},
    ["ltn-requester-priority"] = {default = 0, slot = 7, bounds = {min = -2000000000, max = 2000000000}},
    
    ["ltn-provider-threshold"] = {default = 1000, slot = 9, bounds = {min = 0, max = 2000000000}},
    ["ltn-provider-stack-threshold"] = {default = 0, slot = 10, bounds = {min = 0, max = 2000000000}},
    ["ltn-provider-priority"] = {default = 0, slot = 11, bounds = {min = -2000000000, max = 2000000000}},

    ["ltn-min-train-length"] = {default = 0, slot = 2, bounds = {min = 0, max = 1000}},
    ["ltn-max-train-length"] = {default = 0, slot = 3, bounds = {min = 0, max = 1000}},
    ["ltn-max-trains"] = {default = 0, slot = 4, bounds = {min = 0, max = 1000}},
    
    ["ltn-disable-warnings"] = {default = 0, slot = 8, bounds = {min = 0, max = 1}},
    ["ltn-locked-slots"] = {default = 0, slot = 12, bounds = {min = 0, max = 40}},
    ["ltn-depot"] = {default = 0, slot = 13, bounds = {min = 0, max = 1}}
}

config.LTN_STOP_NONE      = 0
config.LTN_STOP_DEPOT     = 1
config.LTN_STOP_REQUESTER = 2
config.LTN_STOP_PROVIDER  = 4

config.LTN_STOP_DEFAULT = config.LTN_STOP_PROVIDER

config.high_threshold_count = 50000000

-- todo make network id hidden, in settings lua too
config.default_visibility = {
    ["ltn-network-id"] = true,
    ["ltn-requester-threshold"] = true,
    ["ltn-requester-stack-threshold"] = false,
    ["ltn-requester-priority"] = true,
    ["ltn-provider-threshold"] = true,
    ["ltn-provider-stack-threshold"] = false,
    ["ltn-provider-priority"] = true,
    ["ltn-min-train-length"] = true,
    ["ltn-max-train-length"] = true,
    ["ltn-max-trains"] = false,
    ["ltn-locked-slots"] = false,
    ["ltn-disable-warnings"] = true,
    ["ltn-depot"] = false,
}
return config
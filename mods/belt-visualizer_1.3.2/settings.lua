data:extend{{
    type = "int-setting",
    name = "bv-highlight-maximum",
    setting_type = "runtime-global",
    default_value = 64,
    minimum_value = 1,
    maximum_value = 512
},{
    type = "bool-setting",
    name = "bv-container-passthrough",
    setting_type = "runtime-per-user",
    default_value = true,
}}
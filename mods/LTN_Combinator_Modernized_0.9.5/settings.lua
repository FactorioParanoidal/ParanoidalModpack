data:extend({
    --[[
    {
        type = "bool-setting",
        name = "suppress-custom-gui",
        setting_type = "runtime-global",
        order = "aa",
        default_value = false
    },
    {
        type = "string-setting",
        name = "provide-type",
        setting_type = "runtime-global",
        order = "ac",
        default_value = "only-item-count",
        allowed_values = {"only-item-count", "both-item-stack", "only-stack-count"}
    },
    {
        type = "bool-setting",
        name = "show-ltn-network-id",
        order = "sa",
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "show-ltn-priorities",
        order = "sb",
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "show-ltn-train-length",
        order = "sc",
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "show-ltn-max-trains",
        order = "sd",
        setting_type = "runtime-global",
        default_value = false
    },
    {
        type = "bool-setting",
        name = "show-ltn-locked-slots",
        order = "se",
        setting_type = "runtime-global",
        default_value = false
    },
    {
        type = "bool-setting",
        name = "show-ltn-disable-warnings",
        order = "sf",
        setting_type = "runtime-global",
        default_value = true
    },
    ]]
    {
        type = "bool-setting",
        name = "high-provide-threshold",
        setting_type = "runtime-global",
        order = "ab",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "show-all-panels",
        setting_type = "runtime-per-user",
        order = "ab",
        default_value = false
    },
    {
        type = "bool-setting",
        name = "ltnc-upgradable",
        order = "sg",
        setting_type = "startup",
        default_value = true
    },
})
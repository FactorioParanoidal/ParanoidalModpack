_G.mod = require("mod") --[[@as mod]]

data:extend{
	{
        type = "bool-setting",
        name = mod.prefix.."EnableLog",
        setting_type = "runtime-global",
        order = "a",
        default_value = false,
    },
    {
        type = "string-setting",
        name = mod.prefix.."version-increment",
        setting_type = "runtime-per-user",
        order = "b0",
        default_value = 'auto',
        allowed_values = {'off', 'auto', 'on'}
    },
    {
        type = "string-setting",
        name = mod.prefix.."alt-version-increment",
        setting_type = "runtime-per-user",
        order = "b1",
        default_value = 'on',
        allowed_values = {'off', 'auto', 'on'}
    },
    {
        type = "bool-setting",
        name = mod.prefix.."cardinal-center",
        setting_type = "runtime-per-user",
        order = "b2",
        default_value = true,
    },
    {
        type = "bool-setting",
        name = mod.prefix.."horizontal-invert",
        setting_type = "runtime-per-user",
        order = "c0",
        default_value = false,
    },
    {
        type = "bool-setting",
        name = mod.prefix.."vertical-invert",
        setting_type = "runtime-per-user",
        order = "c1",
        default_value = false,
	},
	{
        type = "bool-setting",
        name = mod.prefix.."support-fluid_permutations",
        setting_type = "runtime-per-user",
        order = "d1",
        default_value = true,
    },
    {
        type = "bool-setting",
        name = mod.prefix.."support-gdiw",
        setting_type = "runtime-per-user",
        order = "d2",
        default_value = true,
	},
    {
        type = "string-setting",
        name = mod.prefix.."landfill-mode",
        setting_type = "runtime-per-user",
        order = "e1",
        default_value = 'tempcopy',
        allowed_values = {'update', 'copy', 'tempcopy'}
    },
	{
        type = "string-setting",
        name = mod.prefix.."remove-landfill-mode",
        setting_type = "runtime-per-user",
        order = "e2",
        default_value = 'tempcopy',
        allowed_values = {'update', 'copy', 'tempcopy'}
    },
    {
        type = "bool-setting",
        name = mod.prefix.."show-mirror",
        setting_type = "runtime-per-user",
        order = "f1",
        default_value = true,
    },
    {
        type = "bool-setting",
        name = mod.prefix.."show-rotate",
        setting_type = "runtime-per-user",
        order = "f2",
        default_value = true,
    },
    {
        type = "bool-setting",
        name = mod.prefix.."show-clone",
        setting_type = "runtime-per-user",
        order = "f3",
        default_value = true,
    },
    {
        type = "bool-setting",
        name = mod.prefix.."show-wireswap",
        setting_type = "runtime-per-user",
        order = "f4",
        default_value = true,
    },
    {
        type = "bool-setting",
        name = mod.prefix.."show-landfill",
        setting_type = "runtime-per-user",
        order = "f5",
        default_value = true,
    },
	{
        type = "bool-setting",
        name = mod.prefix.."show-remove-landfill",
        setting_type = "runtime-per-user",
        order = "f6",
        default_value = true,
    },
}



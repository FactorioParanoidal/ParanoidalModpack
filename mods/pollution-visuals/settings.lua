data:extend({
	{
		type = "bool-setting",
		name = "show-pollution-visuals",
		default_value = true,
		setting_type = "runtime-per-user",
	},

    {
        type = "int-setting",
        name = "layers-pollution-visuals",
        setting_type = "runtime-global",
        minimum_value = 1,
        maximum_value = 10,
        default_value = 5
    },

    {
        type = "double-setting",
        name = "base-pollution-visuals",
        setting_type = "runtime-global",
        minimum_value = 1.1,
        maximum_value = 4,
        default_value = 2.5
    },

    {
        type = "int-setting",
        name = "y-intercept-pollution-visuals",
        setting_type = "runtime-global",
        minimum_value = 1,
        maximum_value = 1000,
        default_value = 30
    },

    {
        type = "int-setting",
        name = "x-offset-pollution-visuals",
        setting_type = "runtime-global",
        minimum_value = -1000,
        maximum_value = 1000,
        default_value = 0
    },

    {
        type = "int-setting",
        name = "chunks-per-tick-pollution-visuals",
        setting_type = "runtime-global",
        minimum_value = 1,
        maximum_value = 20,
        default_value = 10
    },
})

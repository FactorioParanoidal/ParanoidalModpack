data:extend{
    {
        type = "int-setting",
        name = "bottleneck-signals-per-tick",
        setting_type = "runtime-global",
        default_value = 40,
        maximum_value = 2000,
        minimum_value = 1,
        order = "bottleneck-ac[signals-per-tick]"
    },
	{
		type = "string-setting",
		name = "bottleneck-show-running-as",
		setting_type = "runtime-global",
		default_value = "green",
		allowed_values = { "off", "green", "red", "yellow",	"blue",	"redx","yellowmin","offsmall","greensmall","redsmall","yellowsmall","bluesmall","redxsmall","yellowminsmall"}, 
        order = "bottleneck-ad[show-running-as]"
	},
	{
		type = "string-setting",
		name = "bottleneck-show-stopped-as",
		setting_type = "runtime-global",
		default_value = "red",
		allowed_values = { "off", "green", "red", "yellow",	"blue",	"redx","yellowmin","offsmall","greensmall","redsmall","yellowsmall","bluesmall","redxsmall","yellowminsmall"}, 
        order = "bottleneck-ae[show-stopped-as]"
	},
	{
		type = "string-setting",
		name = "bottleneck-show-full-as",
		setting_type = "runtime-global",
		default_value = "yellow",
		allowed_values = { "off", "green", "red", "yellow",	"blue",	"redx","yellowmin","offsmall","greensmall","redsmall","yellowsmall","bluesmall","redxsmall","yellowminsmall"}, 
        order = "bottleneck-af[show-full-as]"
	},
}

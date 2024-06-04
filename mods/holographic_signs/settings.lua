local allowed_values = function() return {"Default", "Fast animation", "No animation"} end
data:extend({

{
	type = "bool-setting",
	name = "hs-opt-animation",
	setting_type = "runtime-global",
	default_value = true,
	order = "a"
},

    {
        type = "string-setting",
        name = "hs-opt-text-animation",
        setting_type = "startup",
        default_value = "Default",
        allowed_values = allowed_values(),
        order = "h"
    },
	
})

local C = require("shared.config")

local function icon(name)
	return C.PATH .. "/graphics/icons/" .. name .. ".png"
end

local function alert(name, file, order)
	return {
		type = "virtual-signal",
		name = name,
		icon = icon(file),
		icon_size = 64,
		subgroup = "tpr-signals",
		order = order,
		hidden = true, -- alert icons only, not offered in signal selection
	}
end

data:extend({
	{ type = "item-subgroup", name = "tpr-signals", group = "signals", order = "z-tpr" },
	{
		type = "virtual-signal",
		name = C.SIGNAL,
		icon = icon("signal-pollution"),
		icon_size = 64,
		subgroup = "tpr-signals",
		order = "a",
	},
	alert(C.ALERT.smog, "alert-smog", "b"),
	alert(C.ALERT.danger, "alert-danger", "c"),
	alert(C.ALERT.filters, "alert-filters", "d"),
})

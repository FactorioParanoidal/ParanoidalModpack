-- Paranoidal fork: the C1/Y2/P3 factories are no longer generic assemblers (user decision 2026-10-24) but the only
-- machines that fabricate Yuoki components. C1 makes structural parts, Y2 and P3 also electronics and frames;
-- P3 is the fastest. Their own recipes are built from the build's late products (ingredients.lua).
local P = require("prototypes.paranoidal.lib")

data:extend({
	{ type = "recipe-category", name = "yuoki-fabrication" },
	{ type = "recipe-category", name = "yuoki-fabrication-advanced" },
})

local factories = {
	ye_fassembly1 = { categories = { "yuoki-fabrication" }, speed = 2, slots = 2 },
	ye_fassembly2 = { categories = { "yuoki-fabrication", "yuoki-fabrication-advanced" }, speed = 3, slots = 3 },
	ye_fassembly_sp = { categories = { "yuoki-fabrication", "yuoki-fabrication-advanced" }, speed = 5, slots = 4 },
}
for name, f in pairs(factories) do
	local m = P.entity("assembling-machine", name)
	m.crafting_categories = f.categories
	m.crafting_speed = f.speed
	m.module_slots = f.slots
	m.fast_replaceable_group = "yuoki-fabricator"
end
P.entity("assembling-machine", "ye_fassembly1").next_upgrade = "ye_fassembly2"
P.entity("assembling-machine", "ye_fassembly2").next_upgrade = "ye_fassembly_sp"
P.entity("assembling-machine", "ye_fassembly_sp").next_upgrade = nil

P.category({
	"y_structure_element", "y_structure_vessel", "y-bluegear", "y-conductive-wire-1", "y_chip_plate", "y_dotzetron",
	"y-heat-pipe", "y_gauge_analog", "y-battery-single-use1", "y-battery-single-use2", "y-battery-single-use3",
	"y_drillhead", "y_toolhead", "y-mixing-rich", "y_catalyst_bp", "y_catalyst_ft", "y-basic-t1-mf",
}, "yuoki-fabrication")

P.category({
	"y-chip-1", "y-chip-2", "y-conductive-coil-1", "y_structure_electric", "y_blocked_capa", "yi_magnetron",
	"y-basic-t2-mf", "ye_center", "y-fuel-reactor",
}, "yuoki-fabrication-advanced")

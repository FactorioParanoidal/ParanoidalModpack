-- Shield switch: select turrets to take them out of the protection of shield generators,
-- alt-select to give it back. Spawned by a shortcut, never stored in inventories.
local shared = require("kts_shared")

local cfg = shared.read(settings.startup)
local icon = shared.root .. "/graphics/blueprint.png"

data:extend({
	{
		type = "selection-tool",
		name = shared.tool,
		icon = icon,
		icon_size = 32,
		flags = {"only-in-cursor", "not-stackable", "spawnable"},
		auto_recycle = false,
		hidden = true,
		subgroup = "tool",
		order = "c[automated-construction]-z[kts-shield-toggle]",
		stack_size = 1,
		select = {
			border_color = {r = 1, g = 0.55, b = 0},
			cursor_box_type = "not-allowed",
			mode = {"same-force", "any-entity"},
			entity_type_filters = shared.turret_types,
		},
		alt_select = {
			border_color = {r = 0.2, g = 0.8, b = 1},
			cursor_box_type = "electricity",
			mode = {"same-force", "any-entity"},
			entity_type_filters = shared.turret_types,
		},
	},
	{
		type = "shortcut",
		name = shared.tool,
		action = "spawn-item",
		item_to_spawn = shared.tool,
		icon = icon,
		icon_size = 32,
		small_icon = icon,
		small_icon_size = 32,
		technology_to_unlock = cfg.research and shared.tech_base or nil,
		unavailable_until_unlocked = cfg.research,
		order = "e[kts-shield-toggle]",
	},
})

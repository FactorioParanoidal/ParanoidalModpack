-- Logistic memory units: the memory unit as a logistic chest (see variants.lua). They share the hidden power
-- source and combinator of the plain unit and are driven by the same control script.

local variants = require "variants"

-- Icons are tinted as a whole. The building keeps the original sprite and gets its dome rings painted by an
-- overlay (white rings cut from the original sprite, shading kept) tinted with the vanilla chest colour.
local ICON_TINT_STRENGTH = 0.75
local OVERLAY = "__deep-storage-unit__/graphics/entity/hr-memory-unit-logistic-overlay.png"

local function soften(tint, strength)
	return {
		r = 1 - (1 - tint.r) * strength,
		g = 1 - (1 - tint.g) * strength,
		b = 1 - (1 - tint.b) * strength,
	}
end

local function unit_icons(tint, packed)
	local icons = {{icon = "__deep-storage-unit__/graphics/icon/memory-unit.png", icon_size = 64, tint = tint}}
	if packed then
		icons[1].scale = 0.5
		icons[2] = {icon = "__deep-storage-unit__/graphics/icon/packing-tape-50.png", icon_size = 64}
	end
	return icons
end

local base = data.raw.container["memory-unit"]
local prototypes = {}
local unlocks = {}

for _, name in ipairs(variants.names) do
	local v = variants.variants[name]
	if v.logistic_mode then
		local icon_tint = soften(v.tint, ICON_TINT_STRENGTH)
		local packed = variants.packed_name(name)
		local order = "c[memory-units]-b[logistic-memory-unit]-" .. v.order

		prototypes[#prototypes + 1] = {
			type = "item",
			name = name,
			icons = unit_icons(icon_tint),
			stack_size = 10,
			place_result = name,
			order = order,
			subgroup = "storage",
			flags = {"primary-place-result"},
		}
		prototypes[#prototypes + 1] = {
			type = "item-with-tags",
			name = packed,
			icons = unit_icons(icon_tint, true),
			weight = 10000000,
			stack_size = 1,
			place_result = name,
			order = order .. "-packed",
			subgroup = "storage",
			localised_name = {"item-name.logistic-memory-unit-with-tags", {"entity-name." .. name}},
			localised_description = {"entity-description." .. name},
			flags = {"not-stackable"},
			hidden = true,
		}

		local overlay = table.deepcopy(base.picture)
		overlay.filename = OVERLAY
		overlay.tint = v.paint
		local picture = {layers = {table.deepcopy(base.picture), overlay}}
		prototypes[#prototypes + 1] = {
			type = "logistic-container",
			name = name,
			logistic_mode = v.logistic_mode,
			-- The storage filter is the only logistic slot of a storage chest.
			max_logistic_slots = v.logistic_mode == "storage" and 1 or nil,
			icons = unit_icons(icon_tint),
			inventory_size = base.inventory_size,
			quality_affects_inventory_size = false,
			inventory_type = "with_filters_and_bar",
			enable_inventory_bar = false,
			not_inventory_moveable = true,
			picture = picture,
			max_health = base.max_health,
			minable = {mining_time = 1, result = name},
			corpse = base.corpse,
			open_sound = table.deepcopy(base.open_sound),
			close_sound = table.deepcopy(base.close_sound),
			selection_box = table.deepcopy(base.selection_box),
			collision_box = table.deepcopy(base.collision_box),
			flags = {"placeable-neutral", "player-creation", "not-rotatable"},
			se_allow_in_space = true,
		}

		prototypes[#prototypes + 1] = {
			type = "recipe",
			name = name,
			ingredients = {
				{type = "item", name = "memory-unit",     amount = 1},
				{type = "item", name = v.chest,           amount = 2},
				{type = "item", name = "processing-unit", amount = 10},
			},
			results = {{type = "item", name = name, amount = 1}},
			enabled = false,
		}
		unlocks[#unlocks + 1] = {type = "unlock-recipe", recipe = name}
	end
end

-- Science packs are completed in data-final-fixes from the prerequisites (logistic-system differs by modset).
prototypes[#prototypes + 1] = {
	type = "technology",
	name = "logistic-memory-unit",
	icons = {{icon = "__deep-storage-unit__/graphics/technology/memory-unit.png", icon_size = 128,
		tint = soften({r = 0.45, g = 0.65, b = 1.00}, ICON_TINT_STRENGTH)}},
	effects = unlocks,
	prerequisites = {"memory-unit", "logistic-system"},
	unit = {
		count = 300,
		ingredients = {
			{"automation-science-pack", 1},
			{"logistic-science-pack",   1},
			{"chemical-science-pack",   1},
		},
		time = 30,
	},
}

data:extend(prototypes)

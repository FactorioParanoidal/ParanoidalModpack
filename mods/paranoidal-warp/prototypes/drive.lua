-- Warp drive (one per platform, platform only), warp charge, the jump recipe and the technology.
-- The drive is an assembling machine with one fixed recipe: 1 warp charge, 30 s of spin-up (user 2026-11-07). The
-- recipe has no results, so the defect system gives it no production modes; control.lua starts the machine only on
-- the player's command and moves the platform when a craft finishes.
local shared = require("shared")

local TINT = {r = 0.75, g = 0.55, b = 1}
local base = data.raw["assembling-machine"]["electromagnetic-plant"]
local thruster_item = data.raw.item.thruster

local drive = table.deepcopy(base)
drive.name = shared.drive
drive.icon = nil
drive.icons = {{icon = "__space-age__/graphics/icons/electromagnetic-plant.png", icon_size = 64, tint = TINT}}
drive.minable = {mining_time = 1, result = shared.drive}
drive.placeable_by = nil
drive.crafting_categories = {shared.jump_recipe}
drive.fixed_recipe = shared.jump_recipe
drive.crafting_speed = 1
drive.energy_usage = "10MW" -- 300 MJ per jump at full speed
drive.module_slots = 0
drive.allowed_effects = {}
drive.allowed_module_categories = nil
drive.effect_receiver = nil
drive.fluid_boxes = nil
drive.fluid_boxes_off_when_no_fluid_recipe = nil
drive.fast_replaceable_group = nil
drive.next_upgrade = nil
drive.additional_pastable_entities = nil
drive.show_recipe_icon = false
-- Only on a space platform (gravity 0).
drive.surface_conditions = {{property = "gravity", min = 0, max = 0}}

data:extend({
	{type = "recipe-category", name = shared.jump_recipe},
	drive,
	{
		type = "item",
		name = shared.drive,
		icons = drive.icons,
		subgroup = thruster_item and thruster_item.subgroup or "space-related",
		order = (thruster_item and thruster_item.order or "z") .. "-z[paranoidal-warp-drive]",
		place_result = shared.drive,
		stack_size = 1,
		weight = 500000, -- 500 kg: one rocket with room for charges
	},
	{
		type = "item",
		name = shared.charge,
		icons = {{icon = "__base__/graphics/icons/nuclear-fuel.png", icon_size = 64, tint = TINT}},
		subgroup = thruster_item and thruster_item.subgroup or "space-related",
		order = (thruster_item and thruster_item.order or "z") .. "-z[paranoidal-warp-charge]",
		stack_size = 10,
		weight = 100000, -- 100 kg: ten per rocket
	},
	{
		type = "recipe",
		name = shared.drive,
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "steel-plate", amount = 200},
			{type = "item", name = "processing-unit", amount = 100},
			{type = "item", name = "low-density-structure", amount = 50},
			{type = "item", name = "electric-engine-unit", amount = 50},
		},
		results = {{type = "item", name = shared.drive, amount = 1}},
	},
	{
		type = "recipe",
		name = shared.charge,
		enabled = false,
		energy_required = 30,
		ingredients = {
			{type = "item", name = "low-density-structure", amount = 5},
			{type = "item", name = "processing-unit", amount = 5},
			{type = "item", name = "rocket-fuel", amount = 10},
		},
		results = {{type = "item", name = shared.charge, amount = 1}},
	},
	{
		type = "recipe",
		name = shared.jump_recipe,
		icons = drive.icons, -- a recipe without results needs its own icon
		subgroup = thruster_item and thruster_item.subgroup or "space-related",
		categories = {shared.jump_recipe}, -- 2.1: category/additional_categories became categories
		enabled = true,
		hidden = true,
		hidden_in_factoriopedia = true,
		energy_required = 30,
		ingredients = {{type = "item", name = shared.charge, amount = 1}},
		results = {},
		allow_productivity = false,
		allow_quality = false,
	},
})

-- The technology: the drive, the charge and every point of the sectors.
local effects = {
	{type = "unlock-recipe", recipe = shared.drive},
	{type = "unlock-recipe", recipe = shared.charge},
}
for _, sector in ipairs(shared.sectors) do
	for _, point in ipairs(sector.points) do
		effects[#effects + 1] = {type = "unlock-space-location", space_location = shared.location(sector, point),
			use_icon_overlay_constant = true}
	end
end
data:extend({{
	type = "technology",
	name = shared.technology,
	icons = {{icon = "__space-age__/graphics/technology/space-platform-thruster.png", icon_size = 256, tint = TINT}},
	effects = effects,
	prerequisites = {"space-platform-thruster"},
	unit = {
		count = 1000,
		time = 60,
		ingredients = {
			{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1},
			{"production-science-pack", 1}, {"utility-science-pack", 1}, {"space-science-pack", 1},
		},
	},
}})

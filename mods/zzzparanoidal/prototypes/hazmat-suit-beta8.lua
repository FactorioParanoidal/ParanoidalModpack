-- Противорадиационный костюм Beta 8 (мод RadioactiveDamage), пачка 01, решение пользователя.
-- Броня как в Beta 8: копия heavy-armor без сетки и бонуса инвентаря, прочность 15.
-- Урон uranium-damage Beta 8 → радиация 2.0 Stuckez12-radiation (её наносит character.damage).
require("__zzzparanoidal__.paralib")
local template = data.raw.armor["heavy-armor"]
if not template or data.raw.armor["hazmat-suit"] then return end

local armor = table.deepcopy(template)
armor.name = "hazmat-suit"
armor.localised_name = nil
armor.localised_description = nil
armor.icon = "__zzzparanoidal__/graphics/hazmat-suit-beta8/hazmat-suit.png"
armor.icon_size = 96
armor.icons = nil
armor.order = (template.order or "") .. "-b"
armor.equipment_grid = nil
armor.inventory_size_bonus = 0
armor.infinite = false
armor.durability = 15
armor.stack_size = 1
armor.resistances = {}
if data.raw["damage-type"]["Stuckez12-radiation"] then
	armor.resistances = { { type = "Stuckez12-radiation", decrease = 1, percent = 99 } }
end
if armor.factoriopedia_simulation then
	armor.factoriopedia_simulation.init = armor.factoriopedia_simulation.init:gsub('"heavy%-armor"', '"hazmat-suit"')
end

data:extend({
	armor,
	{
		type = "recipe",
		name = "hazmat-suit",
		category = "crafting",
		enabled = false,
		energy_required = 8,
		ingredients = {
			{ type = "item", name = "plastic-bar", amount = 100 },
			{ type = "item", name = "bob-lead-plate", amount = 100 },
		},
		results = { { type = "item", name = "hazmat-suit", amount = 1 } },
	},
})
paralib.bobmods.lib.tech.add_recipe_unlock("plastics", "hazmat-suit")

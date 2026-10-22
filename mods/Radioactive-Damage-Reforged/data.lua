-- Radioactive damage type and the Hazmat suit (Beta 8 RadioactiveDamage 0.0.4).
-- The Beta 8 "uranium-damage" stream is not ported: control.lua damages the character directly.

local DAMAGE_TYPE = "uranium-damage"
local SUIT = "hazmat-suit"

local armor = table.deepcopy(data.raw.armor["heavy-armor"])
armor.name = SUIT
armor.localised_name = nil
armor.localised_description = nil
armor.icons = nil
armor.icon = "__Radioactive-Damage-Reforged__/graphics/icons/hazmat-suit.png"
armor.icon_size = 96
armor.order = "b[heavy-armor]-b[hazmat-suit]"
armor.equipment_grid = nil
armor.inventory_size_bonus = 0
armor.infinite = false
armor.durability = 15
armor.stack_size = 1
armor.resistances = { { type = DAMAGE_TYPE, decrease = 1, percent = 99 } }
local simulation = armor.factoriopedia_simulation
if simulation and type(simulation.init) == "string" then
	simulation.init = simulation.init:gsub('"heavy%-armor"', '"' .. SUIT .. '"')
end

data:extend({
	{ type = "damage-type", name = DAMAGE_TYPE },
	armor,
	{
		type = "recipe",
		name = SUIT,
		enabled = false,
		energy_required = 8,
		ingredients = {
			{ type = "item", name = "plastic-bar", amount = 100 },
			{ type = "item", name = "bob-lead-plate", amount = 100 },
		},
		results = { { type = "item", name = SUIT, amount = 1 } },
	},
})

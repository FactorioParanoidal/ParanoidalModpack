-- 1.1 source: angels-smelting-extended/prototypes/recipes/shielding.lua:140-208
-- + items/compression-extended.lua:62-73.

if not data.raw.item["bob-insulated-cable"] then return end
if not data.raw.technology["angels-rubbers"] then return end

-- 1.1 формула: count = ingredient[1] нативного bob-insulated-cable × 8.
local count = 16
local native = data.raw.recipe["bob-insulated-cable"]
if native and native.ingredients and native.ingredients[1] then
	local first = native.ingredients[1]
	local amt = first.amount or first[2]
	if amt then count = amt * 8 end
end

data:extend({
	{
		type = "item",
		name = "angels-wire-coil-insulated",
		icons = {
			{ icon = "__zzzparanoidal__/graphics/icons/wire-coil-insulated.png", icon_size = 64, icon_mipmaps = 4 },
		},
		subgroup = "angels-alloys-casting",
		order = "ja",
		stack_size = 200,
	},
})

local converting_category = mods["bobelectronics"] and "electronics" or "crafting"

data:extend({
	{
		type = "recipe",
		name = "angels-wire-coil-insulated-casting",
		localised_name = { "item-name.angels-wire-coil-insulated" },
		category = "angels-strand-casting-2",
		subgroup = "angels-alloys-casting",
		energy_required = 4,
		enabled = false,
		ingredients = {
			{ type = "fluid", name = "angels-liquid-rubber", amount = 10 },
			{ type = "fluid", name = "angels-liquid-molten-tin", amount = count * 8 },
			{ type = "fluid", name = "angels-liquid-molten-copper", amount = count * 8 },
			{ type = "fluid", name = "water", amount = 40 },
		},
		results = {
			{ type = "item", name = "angels-wire-coil-insulated", amount = count },
		},
	},
	{
		type = "recipe",
		name = "angels-wire-coil-insulated-casting-fast",
		localised_name = { "item-name.angels-wire-coil-insulated" },
		category = "angels-strand-casting-3",
		subgroup = "angels-alloys-casting",
		energy_required = 2,
		enabled = false,
		ingredients = {
			{ type = "fluid", name = "angels-liquid-rubber", amount = 18 },
			{ type = "fluid", name = "angels-liquid-molten-tin", amount = count * 14 },
			{ type = "fluid", name = "angels-liquid-molten-copper", amount = count * 14 },
			{ type = "fluid", name = "angels-liquid-coolant", amount = 40 },
		},
		results = {
			{ type = "item", name = "angels-wire-coil-insulated", amount = count * 2 },
			{ type = "fluid", name = "angels-liquid-coolant-used", amount = 40, temperature = 300 },
		},
		main_product = "angels-wire-coil-insulated",
	},
	{
		type = "recipe",
		name = "angels-wire-coil-insulated-converting",
		localised_name = { "item-name.bob-insulated-cable" },
		category = converting_category,
		subgroup = "angels-alloys-casting",
		energy_required = 1,
		enabled = false,
		ingredients = {
			{ type = "item", name = "angels-wire-coil-insulated", amount = 4 },
		},
		results = {
			{ type = "item", name = "bob-insulated-cable", amount = 20 },
		},
		main_product = "bob-insulated-cable",
	},
})

-- 1.1 unlock'ил эти recipes через тех "rubber"; в 2.0 он переименован в "angels-rubbers".
local OV = angelsmods.functions.OV
OV.add_unlock("angels-rubbers", "angels-wire-coil-insulated-casting")
OV.add_unlock("angels-rubbers", "angels-wire-coil-insulated-casting-fast")
OV.add_unlock("angels-rubbers", "angels-wire-coil-insulated-converting")

-- 4-й fluid input на strand-casting-machine MK1..4. Одинаковая раскладка на
-- всех тирах — upgrade'ы не сдвигают pipe-positions. Position x=±2 = граница
-- bounding_box 5×5 (в 2.0 position обязан быть внутри; в 1.1 было ±3).
local extra_box = {
	production_type = "input",
	pipe_covers = pipecoverspictures(),
	volume = 1000,
	pipe_connections = {
		{ flow_direction = "input-output", position = { -2, 1 }, direction = defines.direction.west },
		{ flow_direction = "input-output", position = {  2, 1 }, direction = defines.direction.east },
	},
}
for _, name in ipairs({
	"angels-strand-casting-machine",
	"angels-strand-casting-machine-2",
	"angels-strand-casting-machine-3",
	"angels-strand-casting-machine-4",
}) do
	local machine = data.raw["assembling-machine"][name]
	if machine and machine.fluid_boxes then
		table.insert(machine.fluid_boxes, table.deepcopy(extra_box))
	end
end

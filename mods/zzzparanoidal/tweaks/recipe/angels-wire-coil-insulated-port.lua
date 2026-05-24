-- Port angels-wire-coil-insulated из 1.1 angels-smelting-extended
-- (shielding.lua:140-208 + items/compression-extended.lua:62-73).
--
-- В 1.1 блок гейтился `if data.raw.item["insulated-cable"] then`. В 2.0 item
-- переименован в `bob-insulated-cable` → гейт возвращал nil, блок терялся.
-- Здесь восстанавливаем с 2.0-именами:
--   insulated-cable → bob-insulated-cable
--   liquid-rubber → angels-liquid-rubber
--   liquid-molten-X → angels-liquid-molten-X
--   liquid-coolant[-used] → angels-liquid-coolant[-used]
--   strand-casting-2/3 → angels-strand-casting-2/3
--   rubber tech → angels-rubbers

if not data.raw.item["bob-insulated-cable"] then return end
-- Также гейт на angels-rubbers tech — подтверждает что Angels chain
-- загружен (нужна и теха для unlock, и категории angels-strand-casting-N,
-- и fluid angels-liquid-rubber). Без неё OV.add_unlock крашнется на nil.
if not data.raw.technology["angels-rubbers"] then return end

-- count рассчитывается из native bob-insulated-cable recipe (ingredient[1].amount × 8).
-- Default 16 если parsing не удался.
local count = 16
local native = data.raw.recipe["bob-insulated-cable"]
if native and native.ingredients and native.ingredients[1] then
	local first = native.ingredients[1]
	local amt = first.amount or first[2]
	if amt then count = amt * 8 end
end

-- Item
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

-- Converting category: 1.1 использовала "electronics" если bobelectronics
-- загружен, иначе "crafting". В 2.0 bobelectronics всегда есть в paranoidal —
-- но guard на всякий случай.
local converting_category = mods["bobelectronics"] and "electronics" or "crafting"

-- Recipes
data:extend({
	-- T2 casting: rubber + tin + copper + water → coils
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
	-- T3 fast: rubber + tin + copper + coolant → coils × 2 + used coolant
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
	-- Converting: 4 coils → 20 insulated-cable (выгоднее vanilla 1:1)
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

-- Tech unlocks на angels-rubbers (1.1 использовал "rubber", в 2.0 — angels-rubbers)
local OV = angelsmods.functions.OV
OV.add_unlock("angels-rubbers", "angels-wire-coil-insulated-casting")
OV.add_unlock("angels-rubbers", "angels-wire-coil-insulated-casting-fast")
OV.add_unlock("angels-rubbers", "angels-wire-coil-insulated-converting")

-- 4-й fluid input для liquid-rubber на strand-casting-machine MK1..4.
-- Default — 3 input + 1 output. Добавляем боковой box на east side.
local extra_box = {
	production_type = "input",
	pipe_covers = pipecoverspictures(),
	volume = 1000,
	filter = "angels-liquid-rubber",
	pipe_connections = { { flow_direction = "input", position = { 2, 1 }, direction = defines.direction.east } },
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

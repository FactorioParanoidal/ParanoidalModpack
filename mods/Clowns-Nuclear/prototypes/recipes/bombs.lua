data:extend(
{
	{
		type = "recipe",
		name = "plutonium-atomic-bomb",
		energy_required = 10,
		enabled = false,
		ingredients =
		{
			{type="item",name="processing-unit", amount=20},
			{type="item",name="explosives", amount=10},
		},
		results = {{type="item",name="atomic-bomb",amount =1}},
		icons =
		{
			{
				icon = "__base__/graphics/icons/atomic-bomb.png",
				icon_size=64
			},
			{
				icon = "__Clowns-Nuclear__/graphics/icons/plutonium-239.png",
				icon_size=32,
				scale = 0.4,
				shift = {-10, 10},
			},
		},
	},
	{
		type = "recipe",
		name = "thermonuclear-bomb",
		energy_required = 60,
		enabled = false,
		ingredients =
		{
			--Others added below
			{type="item",name="atomic-bomb", amount=1}
		},
		results = {{type="item",name="thermonuclear-bomb",amount =1}},
		icons =
		{
			{
				icon = "__Clowns-Nuclear__/graphics/icons/thermonuclear-bomb.png",
				icon_size = 32
			},
		},
	},
}
)

--ADD INGREDIENTS TO THERMONUCLEAR BOMB

if mods["bobmodules"] then
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {type="item",name="bob-speed-module-5", amount=3})
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {type="item",name="bob-productivity-module-5", amount=3})
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {type="item",name="bob-efficiency-module-5", amount=3})
else
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {type="item",name="speed-module-3",amount= 3})
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {type="item",name="productivity-module-3", amount=3})
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {type="item",name="efficiency-module-3", amount=3})
end

if data.raw.item["bob-fission-reactor-equipment-2"] then
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {type="item",name="bob-fission-reactor-equipment-2", amount=1})
else
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {type="item",name="fission-reactor-equipment",amount= 1})
end

if data.raw.item["advanced-processing-unit"] then
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {type="item",name="advanced-processing-unit", amount=200})
else
	table.insert(data.raw["recipe"]["thermonuclear-bomb"].ingredients, {type="item",name="processing-unit", amount=200})
end

if mods["angelspetrochem"] then
	table.insert(data.raw["recipe"]["plutonium-atomic-bomb"].ingredients, {type="item",name="angels-plutonium-239", amount= 10})
else
	table.insert(data.raw["recipe"]["plutonium-atomic-bomb"].ingredients, {type="item",name="plutonium-239",amount= 10})
end
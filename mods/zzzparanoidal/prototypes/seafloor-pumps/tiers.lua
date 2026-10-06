-- Донные насосы Beta 8: три электрических тира вязкой грязной воды.
-- Скорость, энергия, рецепты и открытия — Beta 8; загрязнение растёт с тиром, здоровье выровнено.
local function item(name, amount)
	return { type = "item", name = name, amount = amount }
end

return {
	max_health = 320,
	stack_size = 20,
	{
		name = "angels-seafloor-pump",
		technology = "angels-water-washing-1",
		pumping_speed = 5, -- 300/с
		energy_usage = "500kW",
		pollution = 10,
		energy_required = 2,
		ingredients = {
			item("mining-drill-bit-mk1", 3),
			item("pipe", 25),
			item("bob-basic-circuit-board", 10),
			item("iron-plate", 25),
		},
	},
	{
		name = "paranoidal-seafloor-pump-2",
		sprite = "seafloor-pump-mk2",
		technology = "angels-water-washing-2",
		pumping_speed = 10, -- 600/с
		energy_usage = "1MW",
		pollution = 15,
		energy_required = 5,
		ingredients = {
			item("mining-drill-bit-mk2", 3),
			item("bob-steel-pipe", 30),
			item("electronic-circuit", 15),
			item("steel-plate", 30),
			item("angels-seafloor-pump", 2),
		},
	},
	{
		name = "paranoidal-seafloor-pump-3",
		sprite = "seafloor-pump-mk3",
		technology = "angels-water-washing-3",
		pumping_speed = 20, -- 1200/с
		energy_usage = "1.5MW",
		pollution = 20,
		energy_required = 5,
		ingredients = {
			item("mining-drill-bit-mk3", 3),
			item("bob-titanium-pipe", 25),
			item("advanced-circuit", 15),
			item("bob-titanium-plate", 25),
			item("paranoidal-seafloor-pump-2", 2),
		},
	},
}

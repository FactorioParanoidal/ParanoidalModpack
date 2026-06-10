-- Порт Oberhaul bobssolar.lua (1.1): тир-2/3 панелей/аккумуляторов = пред.тир ×4 + выработка/ёмкость 1.1.
-- Имена 1.1→2.0: solar-panel-*→bob-solar-panel-*, *-accumulator-*→bob-*; large-accum T1 = base accumulator.
-- Гарды на рецепт/энтити/ингредиент.

-- Выставить количество уже существующего ингредиента (предыдущего тира) в рецепте.
local function set_prev(recipe_name, ing_name, amount)
	local r = data.raw.recipe[recipe_name]
	if not (r and r.ingredients) then return end
	for _, ing in ipairs(r.ingredients) do
		if (ing.name or ing[1]) == ing_name then
			if ing.name then ing.amount = amount else ing[2] = amount end
			return
		end
	end
end

-- Панели: выработка (1.1) + предыдущий тир ×4
local panels = {
	["bob-solar-panel-small-2"] = { prev = "bob-solar-panel-small", prod = "106.68kW" },
	["bob-solar-panel-small-3"] = { prev = "bob-solar-panel-small-2", prod = "426.72kW" },
	["bob-solar-panel-2"] = { prev = "solar-panel", prod = "240kW" },
	["bob-solar-panel-3"] = { prev = "bob-solar-panel-2", prod = "960kW" },
	["bob-solar-panel-large-2"] = { prev = "bob-solar-panel-large", prod = "426.72kW" },
	["bob-solar-panel-large-3"] = { prev = "bob-solar-panel-large-2", prod = "1706.88kW" },
}
for name, p in pairs(panels) do
	local e = data.raw["solar-panel"][name]
	if e then e.production = p.prod end
	set_prev(name, p.prev, 4)
end

-- Аккумуляторы: buffer + потоки (1.1) + предыдущий тир ×4
local accs = {
	["bob-large-accumulator-2"] = { prev = "accumulator", buf = "40MJ", inflow = "240kW", outflow = "240kW" },
	["bob-large-accumulator-3"] = { prev = "bob-large-accumulator-2", buf = "160MJ", inflow = "960kW", outflow = "960kW" },
	["bob-fast-accumulator-2"] = { prev = "bob-fast-accumulator", buf = "16MJ", inflow = "960kW", outflow = "3840kW" },
	["bob-fast-accumulator-3"] = { prev = "bob-fast-accumulator-2", buf = "64MJ", inflow = "3840kW", outflow = "15360kW" },
	["bob-slow-accumulator-2"] = { prev = "bob-slow-accumulator", buf = "16MJ", inflow = "960kW", outflow = "120kW" },
	["bob-slow-accumulator-3"] = { prev = "bob-slow-accumulator-2", buf = "64MJ", inflow = "3840kW", outflow = "480kW" },
}
for name, a in pairs(accs) do
	local e = data.raw["accumulator"][name]
	if e and e.energy_source then
		e.energy_source.buffer_capacity = a.buf
		e.energy_source.input_flow_limit = a.inflow
		e.energy_source.output_flow_limit = a.outflow
	end
	set_prev(name, a.prev, 4)
end

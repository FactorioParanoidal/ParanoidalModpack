-- Beta 8 normal: обычные боевые платформы, лаборатория II и шесть тиров miniloader → AAI.
-- После ПР-033 обе старые цены каждого loader-тиpa совпадают; отдельной наценки здесь нет.
-- После Bob/Angels/OV.execute. Категории, свойства и оформление остаются 2.0.
local function item(name, amount)
	return { type = "item", name = name, amount = amount }
end

local ingredients = {
	["laser-turret"] = {
		item("steel-plate", 50), item("electronic-circuit", 25), item("battery", 40), item("electric-motor", 4),
	},
	["artillery-turret"] = {
		item("steel-plate", 60), item("concrete", 60), item("iron-gear-wheel", 40),
		item("advanced-circuit", 20), item("artillery-turret-prototype", 2),
	},
	["tank"] = {
		item("engine-unit", 32), item("steel-plate", 50), item("iron-gear-wheel", 15), item("advanced-circuit", 10),
	},
	["artillery-wagon"] = {
		item("engine-unit", 64), item("iron-gear-wheel", 10), item("pipe", 16),
		item("advanced-circuit", 20), item("bob-invar-alloy", 40),
	},
	["power-armor"] = {
		item("processing-unit", 40), item("electric-engine-unit", 20), item("steel-plate", 40), item("modular-armor", 1),
	},
	["power-armor-mk2"] = {
		-- Нынешние модули II и их количества уже совпадали; сами модули остаются 2.0.
		item("efficiency-module-2", 25), item("speed-module-2", 25), item("processing-unit", 60),
		item("electric-engine-unit", 40), item("low-density-structure", 30), item("power-armor", 1),
	},
	["bob-gun-turret-3"] = {
		item("bob-gun-turret-2", 1), item("bob-steel-bearing", 10), item("bob-invar-alloy", 20), item("bob-brass-gear-wheel", 10),
	},
	["bob-sniper-turret-2"] = {
		item("bob-sniper-turret-1", 1), item("steel-plate", 20), item("bob-cobalt-steel-gear-wheel", 20),
		item("bob-cobalt-steel-bearing", 20), item("bob-invar-alloy", 20),
	},
	["bob-sniper-turret-3"] = {
		item("bob-sniper-turret-2", 1), item("bob-titanium-plate", 20), item("bob-titanium-gear-wheel", 20),
		item("bob-nitinol-alloy", 20), item("bob-nitinol-bearing", 20),
	},
	["bob-robot-brain-combat"] = {
		item("bob-basic-circuit-board", 1), item("bob-basic-electronic-components", 8), item("bob-solder", 5),
	},
	["bob-robot-brain-combat-2"] = {
		item("bob-circuit-board", 1), item("bob-basic-electronic-components", 10),
		item("bob-electronic-components", 2), item("bob-solder", 5),
	},
	["bob-robot-brain-combat-3"] = {
		item("bob-superior-circuit-board", 1), item("bob-basic-electronic-components", 4),
		item("bob-electronic-components", 2), item("bob-integrated-electronics", 1), item("bob-solder", 5),
	},
	["bob-robot-brain-combat-4"] = {
		item("bob-multi-layer-circuit-board", 1), item("bob-basic-electronic-components", 2),
		item("bob-electronic-components", 4), item("bob-integrated-electronics", 2),
		item("bob-processing-electronics", 1), item("bob-solder", 5),
	},
	["bob-robot-tool-combat-2"] = {
		-- Старое Bob glass соответствует bob-glass; оставшийся AAI glass не производится.
		item("bob-brass-alloy", 1), item("bob-brass-gear-wheel", 2), item("battery", 1), item("bob-glass", 1),
	},
	["bob-artillery-wagon-2"] = {
		item("artillery-wagon", 1), item("processing-unit", 20), item("bob-titanium-plate", 40),
		item("bob-titanium-bearing", 8), item("bob-titanium-gear-wheel", 12), item("bob-titanium-pipe", 16),
	},
}

for name, list in pairs(ingredients) do
	local recipe = data.raw.recipe[name]
	if recipe then
		recipe.ingredients = list
	end
end

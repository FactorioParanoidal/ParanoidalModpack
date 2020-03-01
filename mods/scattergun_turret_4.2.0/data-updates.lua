if settings.startup["enable-radars"].value == true then
	require("prototypes.entities.w93-radar-turret")
	require("prototypes.items.items-radar")
	require("prototypes.recipes.recipes-radar")
	require("prototypes.technology.technology-radar")
end

if settings.startup["enable-hardened-inserter"].value == true then
	require("prototypes.entities.w93-hardened-inserter")
	require("prototypes.items.items-inserter")
	require("prototypes.recipes.recipes-inserter")
	table.insert(data.raw["technology"]["w93-modular-turrets"].effects, {type = "unlock-recipe", recipe = "w93-hardened-inserter" })
end

if settings.startup["enable-extra-ammo"].value == true then
	require("prototypes.projectiles.projectiles-ammo")
	require("prototypes.items.items-ammo")
	require("prototypes.recipes.recipes-ammo")
	table.insert(data.raw["technology"]["w93-modular-turrets-gatling"].effects, {type = "unlock-recipe", recipe = "w93-slowdown-magazine" })
	table.insert(data.raw["technology"]["w93-modular-turrets-rocket"].effects, {type = "unlock-recipe", recipe = "w93-turret-rocket" })
	table.insert(data.raw["technology"]["w93-modular-turrets-rocket"].effects, {type = "unlock-recipe", recipe = "w93-turret-explosive-rocket" })
	table.insert(data.raw["technology"]["w93-modular-turrets-rocket"].effects, {type = "unlock-recipe", recipe = "w93-turret-slowdown-rocket" })
	table.insert(data.raw["technology"]["w93-modular-turrets-dcannon"].effects, {type = "unlock-recipe", recipe = "w93-turret-slowdown-shells" })
	table.insert(data.raw["technology"]["w93-modular-turrets-hcannon"].effects, {type = "unlock-recipe", recipe = "w93-turret-cannon-shells" })

	if data.raw["technology"]["uranium-ammo" ] then
		table.insert(data.raw["technology"]["uranium-ammo" ].effects, {type = "unlock-recipe", recipe = "w93-uranium-shotgun-shell"})
		table.insert(data.raw["technology"]["uranium-ammo" ].effects, {type = "unlock-recipe", recipe = "w93-turret-light-uranium-cannon-shells"})
		table.insert(data.raw["technology"]["uranium-ammo" ].effects, {type = "unlock-recipe", recipe = "w93-turret-uranium-cannon-shells"})
	end

	if data.raw["ammo"]["w93-turret-light-cannon-shells"] then
		data.raw["ammo"]["w93-turret-light-cannon-shells"].subgroup = "modular-turrets3-combat"
		data.raw["ammo"]["w93-turret-light-cannon-shells"].order = "l[modular-turrets3-combat]-b[w93-turret-light-cannon-shells]"
	end
end

if bobmods and bobmods.plates then
	data.raw["recipe"]["scattergun-turret"].ingredients = {{"stone-brick", 10},{"iron-plate", 10},{"bronze-alloy", 15},{"iron-gear-wheel", 10}}
	data.raw["recipe"]["w93-modular-gun-hmg"].ingredients = {{"tin-plate", 6},{"electronic-circuit", 1},{"steel-gear-wheel", 2}}
	data.raw["recipe"]["w93-modular-gun-gatling"].ingredients = {{"iron-stick", 12},{"bronze-alloy", 8},{"advanced-circuit", 2},{"electric-engine-unit", 1}}
	data.raw["recipe"]["w93-modular-gun-lcannon"].ingredients = {{"bronze-alloy", 5},{"steel-plate", 4}, {"advanced-circuit", 1},{"steel-gear-wheel", 4}}
	data.raw["recipe"]["w93-modular-gun-hcannon"].ingredients = {{"copper-tungsten-alloy", 10},{"tungsten-carbide", 12}, {"processing-unit", 1}, {type="fluid", name="lubricant", amount=50}}
	data.raw["recipe"]["w93-modular-gun-rocket"].ingredients = {{"titanium-plate", 5}, {"advanced-circuit", 2},{"rocket-launcher", 2}}
	data.raw["recipe"]["w93-modular-gun-tlaser"].ingredients = {{"plastic-bar", 8},{"tungsten-carbide", 2}, {"processing-unit", 2},{"silver-zinc-battery", 10}}
	data.raw["recipe"]["w93-modular-gun-beam"].ingredients = {{"uranium-fuel-cell", 1},{"small-lamp",1},{"low-density-structure", 1},{"poison-capsule", 1}, {"processing-unit", 2},{"silver-zinc-battery", 8}}
	data.raw["recipe"]["w93-turret-light-cannon-shells"].ingredients = {{"copper-plate", 10}, {"lead-plate", 10}}

	data.raw["technology"]["scattergun-turrets"].prerequisites = { "military", "turrets", "alloy-processing-1" }
	data.raw["technology"]["w93-modular-turrets2"].prerequisites = { "w93-modular-turrets", "electric-engine", "advanced-electronics-2", "concrete" }
	data.raw["technology"]["w93-modular-turrets-gatling"].prerequisites = { "w93-modular-turrets", "electric-engine", "alloy-processing-1", "military-3" }
	data.raw["technology"]["w93-modular-turrets-rocket"].prerequisites = { "w93-modular-turrets", "military-3", "rocketry", "titanium-processing" }
	data.raw["technology"]["w93-modular-turrets-tlaser"].prerequisites = { "w93-modular-turrets", "military-4", "battery-3", "tungsten-alloy-processing" }
	data.raw["technology"]["w93-modular-turrets-lcannon"].prerequisites = { "w93-modular-turrets", "advanced-electronics", "alloy-processing-1", "lead-processing" }

	if data.raw["recipe"]["w93-modular-gun-radar"] then
		data.raw["recipe"]["w93-modular-gun-radar"].ingredients = {{"copper-tungsten-alloy", 10},{"effectivity-module-2", 1},{"tungsten-gear-wheel", 10}}
		data.raw["recipe"]["w93-modular-gun-radar2"].ingredients = {{"copper-tungsten-alloy", 15},{"iron-stick", 10},{"speed-module-2", 1},{"tungsten-gear-wheel", 5}}

		data.raw["technology"]["w93-modular-turrets-radar"].prerequisites = { "w93-modular-turrets2", "effectivity-module-2", "speed-module-2", "tungsten-alloy-processing" }
	end

	if data.raw["recipe"]["w93-turret-cannon-shells"] then
		data.raw["recipe"]["w93-turret-cannon-shells"].normal.ingredients = {{"tungsten-plate", 10}, {"plastic-bar", 10}, {"explosives", 20}}
		data.raw["recipe"]["w93-turret-cannon-shells"].expensive.ingredients = {{"tungsten-plate", 20}, {"plastic-bar", 20}, {"explosives", 40}}
	end
end

if mods["Krastorio"] then
	if data.raw["technology"]["physical-projectile-damage-1"] then
		table.insert(data.raw["technology"]["physical-projectile-damage-1"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.1})
	end
	if data.raw["technology"]["physical-projectile-damage-2"] then
		table.insert(data.raw["technology"]["physical-projectile-damage-2"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.1})
	end
	if data.raw["technology"]["physical-projectile-damage-3"] then
		table.insert(data.raw["technology"]["physical-projectile-damage-3"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.1})
	end
	if data.raw["technology"]["physical-projectile-damage-4"] then
		table.insert(data.raw["technology"]["physical-projectile-damage-4"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.1})
	end
	if data.raw["technology"]["physical-projectile-damage-5"] then
		table.insert(data.raw["technology"]["physical-projectile-damage-5"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.1})
	end
	if data.raw["technology"]["physical-projectile-damage-6"] then
		table.insert(data.raw["technology"]["physical-projectile-damage-6"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.1})
	end
	if data.raw["technology"]["physical-projectile-damage-7"] then
		table.insert(data.raw["technology"]["physical-projectile-damage-7"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.2})
	end

	data.raw["technology"]["w93-modular-turrets-damage-1"].effects =
	{{ type = "turret-attack", turret_id = "w93-hmg-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-hmg-turret2", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-gatling-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-gatling-turret2", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-lcannon-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-lcannon-turret2", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-dcannon-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-dcannon-turret2", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-hcannon-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-hcannon-turret2", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-rocket-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-rocket-turret2", modifier = 0.2 }}

	data.raw["technology"]["w93-modular-turrets-damage-2"].effects =
	{{ type = "turret-attack", turret_id = "w93-hmg-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-hmg-turret2", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-gatling-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-gatling-turret2", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-lcannon-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-lcannon-turret2", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-dcannon-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-dcannon-turret2", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-hcannon-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-hcannon-turret2", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-rocket-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-rocket-turret2", modifier = 0.2 }}

	data.raw["technology"]["w93-modular-turrets-damage-3"].effects =
	{{ type = "turret-attack", turret_id = "w93-hmg-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-hmg-turret2", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-gatling-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-gatling-turret2", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-lcannon-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-lcannon-turret2", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-dcannon-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-dcannon-turret2", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-hcannon-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-hcannon-turret2", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-rocket-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-rocket-turret2", modifier = 0.2 }}

	data.raw["technology"]["w93-modular-turrets-damage-4"].effects =
	{{ type = "turret-attack", turret_id = "w93-hmg-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-hmg-turret2", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-gatling-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-gatling-turret2", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-lcannon-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-lcannon-turret2", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-dcannon-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-dcannon-turret2", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-hcannon-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-hcannon-turret2", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-rocket-turret", modifier = 0.2 },
	{ type = "turret-attack", turret_id = "w93-rocket-turret2", modifier = 0.2 }}

	if settings.startup["reb-technology"].value then
		data.raw["technology"]["w93-modular-turrets2"].unit.ingredients = { {"automation-research-data", 1}, {"military-research-data", 1} }

		data.raw["technology"]["w93-modular-turrets-tlaser"].unit.ingredients = { {"military-research-data", 1}, {"chemical-research-data", 1}, {"scientific-research-data", 1} }
		data.raw["technology"]["w93-modular-turrets-tlaser"].unit.count = 500

		data.raw["technology"]["w93-modular-turrets-hcannon"].unit.ingredients = { {"military-research-data", 1}, {"chemical-research-data", 1}, {"scientific-research-data", 1} }
		data.raw["technology"]["w93-modular-turrets-hcannon"].unit.count = 500

		data.raw["technology"]["w93-modular-turrets-beam"].unit.ingredients = { {"military-research-data", 1}, {"chemical-research-data", 1}, {"scientific-research-data", 1}, {"optimization-research-data", 1} }
		data.raw["technology"]["w93-modular-turrets-beam"].unit.count = 1000

		data.raw["technology"]["w93-modular-turrets-damage-3"].unit.ingredients = { {"military-research-data", 1}, {"scientific-research-data", 1} }
		data.raw["technology"]["w93-modular-turrets-damage-3"].prerequisites = { "w93-modular-turrets-damage-2", "k-advanced-processor" }

		data.raw["technology"]["w93-modular-turrets-damage-4"].unit.ingredients = { {"military-research-data", 1}, {"optimization-research-data", 1} }
		data.raw["technology"]["w93-modular-turrets-damage-4"].unit.count_formula = "((L-3)^2)*7500"
		data.raw["technology"]["w93-modular-turrets-damage-4"].max_level = 14

		if data.raw["recipe"]["w93-modular-gun-radar"] then
			data.raw["technology"]["w93-modular-turrets-radar"].unit.ingredients = { {"automation-research-data", 1}, {"military-research-data", 1} }
			data.raw["technology"]["w93-modular-turrets-radar"].unit.count = 300
			data.raw["technology"]["w93-modular-turrets-radar"].prerequisites = { "w93-modular-turrets2", "effectivity-module-2", "speed-module-2" }
		end
	end
else
	if data.raw["technology"]["physical-projectile-damage-1"] then
		table.insert(data.raw["technology"]["physical-projectile-damage-1"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.1})
	end

	if data.raw["technology"]["physical-projectile-damage-2"] then
		table.insert(data.raw["technology"]["physical-projectile-damage-2"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.1})
	end

	if data.raw["technology"]["physical-projectile-damage-3"] then
		table.insert(data.raw["technology"]["physical-projectile-damage-3"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.2})
	end

	if data.raw["technology"]["physical-projectile-damage-4"] then
		table.insert(data.raw["technology"]["physical-projectile-damage-4"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.2})
	end

	if data.raw["technology"]["physical-projectile-damage-5"] then
		table.insert(data.raw["technology"]["physical-projectile-damage-5"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.2})
	end

	if data.raw["technology"]["physical-projectile-damage-6"] then
		table.insert(data.raw["technology"]["physical-projectile-damage-6"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.4})
	end

	if data.raw["technology"]["physical-projectile-damage-7"] then
		table.insert(data.raw["technology"]["physical-projectile-damage-7"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.7})
	end
end
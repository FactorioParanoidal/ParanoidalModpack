function W93_UpdateTechKrastorio()

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

if not (mods["DeadlockIndustry"] or mods["bobrevamp"]) then
	data.raw["technology"]["w93-modular-turrets2"].unit.ingredients = { {"automation-research-data", 1}, {"military-research-data", 1} }

	data.raw["technology"]["w93-modular-turrets-tlaser"].unit.ingredients = { {"military-research-data", 1}, {"chemical-research-data", 1}, {"scientific-research-data", 1} }
	data.raw["technology"]["w93-modular-turrets-tlaser"].unit.count = 500

	data.raw["technology"]["w93-modular-turrets-hcannon"].unit.ingredients = { {"military-research-data", 1}, {"chemical-research-data", 1}, {"scientific-research-data", 1} }
	data.raw["technology"]["w93-modular-turrets-hcannon"].unit.count = 500

	data.raw["technology"]["w93-modular-turrets-beam"].unit.ingredients = { {"military-research-data", 1}, {"chemical-research-data", 1}, {"scientific-research-data", 1}, {"optimization-research-data", 1} }
	data.raw["technology"]["w93-modular-turrets-beam"].unit.count = 1000

	data.raw["technology"]["w93-modular-turrets-damage-3"].unit.ingredients = { {"military-research-data", 1}, {"scientific-research-data", 1} }
	data.raw["technology"]["w93-modular-turrets-damage-3"].prerequisites = { "w93-modular-turrets-damage-2", "menarite-processor" }

	data.raw["technology"]["w93-modular-turrets-damage-4"].unit.ingredients = { {"military-research-data", 1}, {"optimization-research-data", 1} }
	data.raw["technology"]["w93-modular-turrets-damage-4"].unit.count_formula = "((L-3)^2)*7500"
	data.raw["technology"]["w93-modular-turrets-damage-4"].max_level = 14

	if data.raw["recipe"]["w93-modular-gun-radar"] then
		data.raw["technology"]["w93-modular-turrets-radar"].unit.ingredients = { {"automation-research-data", 1}, {"military-research-data", 1} }
		data.raw["technology"]["w93-modular-turrets-radar"].unit.count = 300
		data.raw["technology"]["w93-modular-turrets-radar"].prerequisites = { "w93-modular-turrets2", "effectivity-module-2", "speed-module-2" }
	end
end

end
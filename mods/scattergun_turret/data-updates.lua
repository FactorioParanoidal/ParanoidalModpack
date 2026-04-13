if data.raw["technology"]["physical-projectile-damage-2"] then
	table.insert(data.raw["technology"]["physical-projectile-damage-2"].effects, {type = "turret-attack", turret_id = "w93-scattergun-turret", modifier = 0.2})
end
if data.raw["technology"]["physical-projectile-damage-3"] then
	table.insert(data.raw["technology"]["physical-projectile-damage-3"].effects, {type = "turret-attack", turret_id = "w93-scattergun-turret", modifier = 0.2})
end
if data.raw["technology"]["physical-projectile-damage-4"] then
	table.insert(data.raw["technology"]["physical-projectile-damage-4"].effects, {type = "turret-attack", turret_id = "w93-scattergun-turret", modifier = 0.2})
end
if data.raw["technology"]["physical-projectile-damage-5"] then
	table.insert(data.raw["technology"]["physical-projectile-damage-5"].effects, {type = "turret-attack", turret_id = "w93-scattergun-turret", modifier = 0.2})
end
if data.raw["technology"]["physical-projectile-damage-6"] then
	if mods["space-age"] then
		table.insert(data.raw["technology"]["physical-projectile-damage-6"].effects, {type = "turret-attack", turret_id = "w93-scattergun-turret", modifier = 0.2})
	else
		table.insert(data.raw["technology"]["physical-projectile-damage-6"].effects, {type = "turret-attack", turret_id = "w93-scattergun-turret", modifier = 0.4})
	end
end
if data.raw["technology"]["physical-projectile-damage-7"] then
	if mods["space-age"] then
		table.insert(data.raw["technology"]["physical-projectile-damage-7"].effects, {type = "turret-attack", turret_id = "w93-scattergun-turret", modifier = 0.2})
	else
		table.insert(data.raw["technology"]["physical-projectile-damage-7"].effects, {type = "turret-attack", turret_id = "w93-scattergun-turret", modifier = 0.7})
	end
end

if data.raw["ammo"]["cannon-shell"] and data.raw["projectile"]["cannon-projectile"] then
	data.raw["ammo"]["cannon-shell"].ammo_type.target_type = "position"
	data.raw["ammo"]["cannon-shell"].ammo_type.action.action_delivery.max_range = nil
	data.raw["ammo"]["cannon-shell"].ammo_type.action.action_delivery.direction_deviation = nil
	data.raw["ammo"]["cannon-shell"].ammo_type.action.action_delivery.range_deviation = nil
	data.raw["projectile"]["cannon-projectile"].force_condition = "not-same"
	data.raw["projectile"]["cannon-projectile"].direction_only = false
	data.raw["projectile"]["cannon-projectile"].hit_collision_mask = {layers={object=true, player=true, train=true, trigger_target=true}}
end
if data.raw["ammo"]["explosive-cannon-shell"] and data.raw["projectile"]["explosive-cannon-projectile"] then
	data.raw["ammo"]["explosive-cannon-shell"].ammo_type.target_type = "position"
	data.raw["ammo"]["explosive-cannon-shell"].ammo_type.action.action_delivery.max_range = nil
	data.raw["projectile"]["explosive-cannon-projectile"].force_condition = "not-same"
	data.raw["projectile"]["explosive-cannon-projectile"].hit_collision_mask = {layers={object=true, player=true, train=true, trigger_target=true}}
end
if data.raw["ammo"]["uranium-cannon-shell"] and data.raw["projectile"]["uranium-cannon-projectile"] then
	data.raw["ammo"]["uranium-cannon-shell"].ammo_type.target_type = "position"
	data.raw["ammo"]["uranium-cannon-shell"].ammo_type.action.action_delivery.max_range = nil
	data.raw["ammo"]["uranium-cannon-shell"].ammo_type.action.action_delivery.direction_deviation = nil
	data.raw["ammo"]["uranium-cannon-shell"].ammo_type.action.action_delivery.range_deviation = nil
	data.raw["projectile"]["uranium-cannon-projectile"].force_condition = "not-same"
	data.raw["projectile"]["uranium-cannon-projectile"].direction_only = false
	data.raw["projectile"]["uranium-cannon-projectile"].hit_collision_mask = {layers={object=true, player=true, train=true, trigger_target=true}}
end
if data.raw["ammo"]["explosive-uranium-cannon-shell"] and data.raw["projectile"]["explosive-uranium-cannon-projectile"] then
	data.raw["ammo"]["explosive-uranium-cannon-shell"].ammo_type.target_type = "position"
	data.raw["ammo"]["explosive-uranium-cannon-shell"].ammo_type.action.action_delivery.max_range = nil
	data.raw["projectile"]["explosive-uranium-cannon-projectile"].force_condition = "not-same"
	data.raw["projectile"]["explosive-uranium-cannon-projectile"].hit_collision_mask = {layers={object=true, player=true, train=true, trigger_target=true}}
end

if data.raw["projectile"]["shotgun-pellet"] then
	data.raw["projectile"]["shotgun-pellet"].hit_collision_mask = {layers={object=true, player=true, train=true, trigger_target=true}}
end
if data.raw["projectile"]["piercing-shotgun-pellet"] then
	data.raw["projectile"]["piercing-shotgun-pellet"].hit_collision_mask = {layers={object=true, player=true, train=true, trigger_target=true}}
end

if data.raw["fluid-turret"]["flamethrower-turret"] then
	data.raw["fluid-turret"]["flamethrower-turret"].attack_parameters.fluid_consumption = 2
end

if data.raw["technology"]["uranium-ammo"] then
	table.insert(data.raw["technology"]["uranium-ammo" ].effects, {type = "unlock-recipe", recipe = "w93-uranium-shotgun-shell"})
end

if settings.startup["enable-pretargeting"].value == true then
	data.raw["ammo-turret"]["w93-hmg-turret"].prepare_range = 35
	data.raw["ammo-turret"]["w93-hmg-turret2"].prepare_range = 40
	data.raw["ammo-turret"]["w93-gatling-turret"].prepare_range = 40
	data.raw["ammo-turret"]["w93-gatling-turret2"].prepare_range = 45
	data.raw["ammo-turret"]["w93-lcannon-turret"].prepare_range = 50
	data.raw["ammo-turret"]["w93-lcannon-turret2"].prepare_range = 55
	data.raw["ammo-turret"]["w93-dcannon-turret"].prepare_range = 65
	data.raw["ammo-turret"]["w93-dcannon-turret2"].prepare_range = 70
	data.raw["ammo-turret"]["w93-hcannon-turret"].prepare_range = 80
	data.raw["ammo-turret"]["w93-hcannon-turret2"].prepare_range = 85
	data.raw["ammo-turret"]["w93-rocket-turret"].prepare_range = 95
	data.raw["ammo-turret"]["w93-rocket-turret2"].prepare_range = 100
	data.raw["electric-turret"]["w93-plaser-turret"].prepare_range = 45
	data.raw["electric-turret"]["w93-plaser-turret2"].prepare_range = 50
	data.raw["electric-turret"]["w93-tlaser-turret"].prepare_range = 60
	data.raw["electric-turret"]["w93-tlaser-turret2"].prepare_range = 65
	data.raw["electric-turret"]["w93-beam-turret"].prepare_range = 35
	data.raw["electric-turret"]["w93-beam-turret2"].prepare_range = 55
end

if mods["space-age"] then
	data.raw["technology"]["w93-modular-turrets-dcannon"].prerequisites = { "w93-modular-turrets-lcannon", "military-4", "speed-module" }
	data.raw["technology"]["w93-modular-turrets-dcannon"].unit.ingredients = { {"automation-science-pack", 1},{"logistic-science-pack", 1},{"military-science-pack", 1},{"chemical-science-pack", 1},{"utility-science-pack", 1} }
	data.raw["technology"]["w93-modular-turrets-dcannon"].unit.count = 500

	data.raw["technology"]["w93-modular-turrets-hcannon"].prerequisites = { "w93-modular-turrets-lcannon", "military-3", "metallurgic-science-pack" }
	data.raw["technology"]["w93-modular-turrets-hcannon"].unit.ingredients = { {"automation-science-pack", 1},{"logistic-science-pack", 1},{"military-science-pack", 1},{"chemical-science-pack", 1},{"space-science-pack", 1},{"metallurgic-science-pack", 1} }
	data.raw["technology"]["w93-modular-turrets-hcannon"].unit.count = 500
	data.raw["recipe"]["w93-modular-gun-hcannon"].ingredients = {
		{type="item", name="low-density-structure", amount=2},
		{type="item", name="tungsten-plate", amount=5},
		{type="item", name="advanced-circuit", amount=2},
		{type="fluid", name="lubricant", amount=50}
}

	data.raw["technology"]["w93-modular-turrets-plaser"].prerequisites = { "w93-modular-turrets", "military-3", "laser", "speed-module", "space-science-pack" }
	data.raw["technology"]["w93-modular-turrets-plaser"].unit.ingredients = { {"automation-science-pack", 1},{"logistic-science-pack", 1},{"military-science-pack", 1},{"chemical-science-pack", 1},{"space-science-pack", 1} }
	data.raw["recipe"]["w93-modular-gun-plaser"].ingredients = {
		{type="item", name="carbon", amount=10},
		{type="item", name="electronic-circuit", amount=5},
		{type="item", name="battery", amount=10},
		{type="item", name="speed-module", amount=1}}
	if mods["SpaceAgeWithoutSpace"] then
		table.insert(data.raw["technology"]["w93-modular-turrets-plaser"].prerequisites, "tungsten-carbide")
	end

	data.raw["technology"]["w93-modular-turrets-tlaser"].prerequisites = { "w93-modular-turrets-plaser", "efficiency-module-2", "electromagnetic-science-pack" }
	data.raw["technology"]["w93-modular-turrets-tlaser"].unit.ingredients = { {"automation-science-pack", 1},{"logistic-science-pack", 1},{"military-science-pack", 1},{"chemical-science-pack", 1},{"space-science-pack", 1},{"electromagnetic-science-pack", 1} }
	data.raw["recipe"]["w93-modular-gun-tlaser"].ingredients = {
		{type="item", name="plastic-bar", amount=10},
		{type="item", name="supercapacitor", amount=5},
		{type="item", name="efficiency-module-2", amount=1}}

	data.raw["technology"]["w93-modular-turrets-beam"].prerequisites = { "w93-modular-turrets", "military-4", "laser", "nuclear-power" }

	data.raw["technology"]["w93-modular-turrets-radar"].unit.ingredients = { {"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1},{"utility-science-pack", 1},{"space-science-pack", 1} }
end
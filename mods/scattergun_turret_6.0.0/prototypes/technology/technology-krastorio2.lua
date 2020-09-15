function W93_UpdateTechKrastorio2()

data.raw["technology"]["w93-modular-turrets"].prerequisites = {"turrets", "military-2", "engine", "concrete"}
data.raw["technology"]["w93-modular-turrets"].unit.ingredients = {{"basic-tech-card", 1}, {"automation-science-pack", 1}, {"logistic-science-pack", 1}}
data.raw["technology"]["w93-modular-turrets2"].unit.ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"military-science-pack", 1}}
data.raw["technology"]["w93-modular-turrets-gatling"].unit.ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"military-science-pack", 1}}
data.raw["technology"]["w93-modular-turrets-lcannon"].prerequisites = {"w93-modular-turrets", "military-science-pack"}
data.raw["technology"]["w93-modular-turrets-lcannon"].unit.ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"military-science-pack", 1}}
data.raw["technology"]["w93-modular-turrets-dcannon"].unit.ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"military-science-pack", 1}}
data.raw["technology"]["w93-modular-turrets-hcannon"].unit.ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"military-science-pack", 1}, {"utility-science-pack",1}}
data.raw["technology"]["w93-modular-turrets-rocket"].unit.ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"military-science-pack", 1}}
data.raw["technology"]["w93-modular-turrets-tlaser"].prerequisites = {"w93-modular-turrets", "military-4", "laser", "kr-lithium-sulfur-battery", "kr-quarry-minerals-extraction"}
data.raw["technology"]["w93-modular-turrets-tlaser"].unit.ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"military-science-pack", 1}, {"utility-science-pack",1}}
data.raw["technology"]["w93-modular-turrets-beam"].unit.ingredients = {{"utility-science-pack",1}, {"space-science-pack",1}}

if settings.startup["enable-radars"].value == true then
	data.raw["technology"]["w93-modular-turrets-radar"].unit.ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}, {"military-science-pack", 1}, {"utility-science-pack",1}}
end

if data.raw["technology"]["physical-projectile-damage-1"] then
	table.insert(data.raw["technology"]["physical-projectile-damage-1"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.25})
end
if data.raw["technology"]["physical-projectile-damage-2"] then
	table.insert(data.raw["technology"]["physical-projectile-damage-2"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.25})
end
if data.raw["technology"]["physical-projectile-damage-3"] then
	table.insert(data.raw["technology"]["physical-projectile-damage-3"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.25})
end
if data.raw["technology"]["physical-projectile-damage-4"] then
	table.insert(data.raw["technology"]["physical-projectile-damage-4"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.35})
end
if data.raw["technology"]["physical-projectile-damage-5"] then
	table.insert(data.raw["technology"]["physical-projectile-damage-5"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.35})
end
if data.raw["technology"]["physical-projectile-damage-6"] then
	table.insert(data.raw["technology"]["physical-projectile-damage-6"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.35})
end
if data.raw["technology"]["physical-projectile-damage-7"] then
	table.insert(data.raw["technology"]["physical-projectile-damage-7"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.1})
end
if data.raw["technology"]["physical-projectile-damage-11"] then
	table.insert(data.raw["technology"]["physical-projectile-damage-11"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.1})
end
if data.raw["technology"]["physical-projectile-damage-16"] then
	table.insert(data.raw["technology"]["physical-projectile-damage-16"].effects, {type = "turret-attack", turret_id = "scattergun-turret", modifier = 0.1})
end

end
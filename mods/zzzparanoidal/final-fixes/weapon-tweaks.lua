--###############################################################################################
--Фикс снайперских турелей
data.raw["ammo-turret"]["bob-sniper-turret-1"].attack_parameters.min_range = 15
data.raw["ammo-turret"]["bob-sniper-turret-1"].attack_parameters.cooldown = 300
data.raw["ammo-turret"]["bob-sniper-turret-2"].attack_parameters.min_range = 17
data.raw["ammo-turret"]["bob-sniper-turret-2"].attack_parameters.cooldown = 240
data.raw["ammo-turret"]["bob-sniper-turret-3"].attack_parameters.min_range = 20
data.raw["ammo-turret"]["bob-sniper-turret-3"].attack_parameters.cooldown = 210
bobmods.lib.recipe.set_ingredients("bob-sniper-turret-1", {
	{ type = "item", name = "bob-steel-gear-wheel", amount = 20 },
	{ type = "item", name = "gun-turret", amount = 1 },
	{ type = "item", name = "copper-plate", amount = 20 },
})
--###############################################################################################
--Фикс легкихтурелей
data.raw["ammo-turret"]["w93-scattergun-turret"].attack_parameters.range = 18
data.raw["ammo-turret"]["w93-scattergun-turret"].attack_parameters.damage_modifier = 2.0
data.raw["ammo-turret"]["w93-scattergun-turret"].attack_parameters.min_range = 0
data.raw["ammo-turret"]["w93-scattergun-turret"].attack_parameters.turn_range = 1
bobmods.lib.recipe.set_ingredients("w93-scattergun-turret", {
	{ type = "item", name = "iron-gear-wheel", amount = 20 },
	{ type = "item", name = "gun-turret", amount = 1 },
	{ type = "item", name = "stone-brick", amount = 50 },
})
--###############################################################################################
--Фикс простых турелей
data.raw["ammo-turret"]["gun-turret"].attack_parameters.damage_modifier = 1.5
data.raw["ammo-turret"]["bob-gun-turret-2"].attack_parameters.damage_modifier = 2.0
data.raw["ammo-turret"]["bob-gun-turret-3"].attack_parameters.damage_modifier = 3.0
data.raw["ammo-turret"]["bob-gun-turret-4"].attack_parameters.damage_modifier = 4.0
data.raw["ammo-turret"]["bob-gun-turret-5"].attack_parameters.damage_modifier = 5.0
--###############################################################################################
--Фикс модульных турелей
data.raw["ammo-turret"]["w93-hmg-turret"].attack_parameters.turn_range = 1
data.raw["ammo-turret"]["w93-hmg-turret"].attack_parameters.damage_modifier = 3.0
data.raw["ammo-turret"]["w93-hmg-turret"].attack_parameters.cooldown = 5
data.raw["ammo-turret"]["w93-hmg-turret2"].attack_parameters.damage_modifier = 4.0
data.raw["ammo-turret"]["w93-hmg-turret2"].attack_parameters.cooldown = 5

data.raw["technology"]["w93-modular-turrets2"].prerequisites = { "w93-modular-turrets", "electric-engine", "plastics" }
data.raw.technology["w93-modular-turrets2"].unit.ingredients = {
	{"automation-science-pack", 1 },
	{"logistic-science-pack", 1 },
	{"military-science-pack", 1 },
}
bobmods.lib.tech.remove_recipe_unlock("w93-modular-turrets", "w93-hmg-turret2")
bobmods.lib.tech.add_recipe_unlock("w93-modular-turrets2", "w93-hmg-turret2")
bobmods.lib.tech.add_prerequisite("w93-modular-turrets-gatling", "w93-modular-turrets2")
bobmods.lib.tech.add_prerequisite("w93-modular-turrets-lcannon", "w93-modular-turrets2")
bobmods.lib.tech.add_prerequisite("w93-modular-turrets-rocket", "w93-modular-turrets2")
bobmods.lib.tech.add_prerequisite("w93-modular-turrets-plaser", "w93-modular-turrets2")

data.raw["ammo-turret"]["w93-gatling-turret"].attack_parameters.turn_range = 1
data.raw["ammo-turret"]["w93-gatling-turret"].attack_parameters.damage_modifier = 3.0
data.raw["ammo-turret"]["w93-gatling-turret"].attack_parameters.cooldown = 1
data.raw["ammo-turret"]["w93-gatling-turret2"].attack_parameters.turn_range = 0.5
data.raw["ammo-turret"]["w93-gatling-turret2"].attack_parameters.min_range = 0
data.raw["ammo-turret"]["w93-gatling-turret2"].attack_parameters.damage_modifier = 4.0
data.raw["ammo-turret"]["w93-gatling-turret2"].attack_parameters.cooldown = 1

data.raw["ammo-turret"]["w93-lcannon-turret"].attack_parameters.turn_range = 0.4
data.raw["ammo-turret"]["w93-lcannon-turret"].attack_parameters.range = 40
data.raw["ammo-turret"]["w93-lcannon-turret2"].attack_parameters.turn_range = 0.5
data.raw["ammo-turret"]["w93-lcannon-turret2"].attack_parameters.cooldown = 60
data.raw["ammo-turret"]["w93-lcannon-turret2"].attack_parameters.range = 45

data.raw["ammo-turret"]["w93-dcannon-turret"].attack_parameters.turn_range = 0.4
data.raw["ammo-turret"]["w93-dcannon-turret"].attack_parameters.cooldown = 60
data.raw["ammo-turret"]["w93-dcannon-turret"].attack_parameters.range = 50
data.raw["ammo-turret"]["w93-dcannon-turret"].attack_parameters.min_range = 25
data.raw["ammo-turret"]["w93-dcannon-turret2"].attack_parameters.turn_range = 0.5
data.raw["ammo-turret"]["w93-dcannon-turret2"].attack_parameters.cooldown = 30
data.raw["ammo-turret"]["w93-dcannon-turret2"].attack_parameters.range = 55
data.raw["ammo-turret"]["w93-dcannon-turret2"].attack_parameters.min_range = 32

data.raw["ammo-turret"]["w93-hcannon-turret"].attack_parameters.turn_range = 0.4
data.raw["ammo-turret"]["w93-hcannon-turret2"].attack_parameters.turn_range = 0.5
data.raw["ammo-turret"]["w93-hcannon-turret"].attack_parameters.damage_modifier = 3.0
data.raw["ammo-turret"]["w93-hcannon-turret2"].attack_parameters.min_range = 40
data.raw["ammo-turret"]["w93-hcannon-turret2"].attack_parameters.damage_modifier = 4.0
data.raw["ammo-turret"]["w93-hcannon-turret2"].attack_parameters.cooldown = 120

data.raw["electric-turret"]["w93-plaser-turret"].attack_parameters.turn_range = 0.4
data.raw["electric-turret"]["w93-plaser-turret"].attack_parameters.damage_modifier = 4.5
data.raw["electric-turret"]["w93-plaser-turret2"].attack_parameters.turn_range = 0.5
data.raw["electric-turret"]["w93-plaser-turret2"].attack_parameters.damage_modifier = 5.5
data.raw["electric-turret"]["w93-plaser-turret2"].attack_parameters.cooldown = 12

data.raw["electric-turret"]["w93-tlaser-turret"].attack_parameters.turn_range = 0.4
data.raw["electric-turret"]["w93-tlaser-turret2"].attack_parameters.turn_range = 0.5
data.raw["electric-turret"]["w93-tlaser-turret2"].attack_parameters.range = 65

data.raw["electric-turret"]["w93-beam-turret"].attack_parameters.turn_range = 0.4
data.raw["electric-turret"]["w93-beam-turret"].attack_parameters.damage_modifier = 2.0
data.raw["electric-turret"]["w93-beam-turret"].attack_parameters.range = 40
data.raw["electric-turret"]["w93-beam-turret2"].attack_parameters.turn_range = 0.5
data.raw["electric-turret"]["w93-beam-turret2"].attack_parameters.cooldown = 10

data.raw["ammo-turret"]["w93-rocket-turret"].attack_parameters.turn_range = 0.4
data.raw["ammo-turret"]["w93-rocket-turret"].attack_parameters.cooldown = 120
data.raw["ammo-turret"]["w93-rocket-turret"].attack_parameters.range = 80
data.raw["ammo-turret"]["w93-rocket-turret2"].attack_parameters.turn_range = 0.5
data.raw["ammo-turret"]["w93-rocket-turret2"].attack_parameters.cooldown = 60
data.raw["ammo-turret"]["w93-rocket-turret2"].attack_parameters.range = 95
data.raw["ammo-turret"]["w93-rocket-turret2"].attack_parameters.min_range = 55

--Фикс злых снайперов из Big Monsters
for i = 1, 10 do
	local sniper_name = "bm_fake_human_sniper_" .. i
	if data.raw["unit"][sniper_name] then
		data.raw["unit"][sniper_name].attack_parameters.range = 60
		data.raw["unit"][sniper_name].attack_parameters.min_range = 55
	end
end

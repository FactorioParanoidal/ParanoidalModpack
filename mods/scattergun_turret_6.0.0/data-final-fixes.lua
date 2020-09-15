if mods["Krastorio2"] then
	data.raw["item"]["scattergun-turret"].subgroup = "vanilla-turrets"
	data.raw["item"]["scattergun-turret"].order = "01[scattergun-turret]"
	if krastorio.general.getSafeSettingValue("kr-more-realistic-weapon") then
		if settings.startup["enable-extra-ammo"].value == true then
			data.raw["ammo"]["w93-slowdown-magazine"].flags = {"hidden"}
			table.remove(data.raw["technology"]["w93-modular-turrets-gatling"].effects, 4)
		end
	end
	W93_UpdateTechKrastorio2()
	W93_UpdateRecipesKrastorio2()

	if krastorio.general.getSafeSettingValue("kr-more-realistic-weapon") then
		data.raw["ammo"]["rifle-magazine"].ammo_type.action[1].action_delivery[1].max_range = 35
		data.raw["ammo"]["armor-piercing-rifle-magazine"].ammo_type.action[1].action_delivery[1].max_range = 35
		data.raw["ammo"]["uranium-rifle-magazine"].ammo_type.action[1].action_delivery[1].max_range = 35
		data.raw["ammo"]["imersite-rifle-magazine"].ammo_type.action[1].action_delivery[1].max_range = 35
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

if se_prodecural_tech_exclusions then
	table.insert(se_prodecural_tech_exclusions, "w93-modular-turrets")
end
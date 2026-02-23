
--[[
if mods["Krastorio2"] then
	data.raw["item"]["w93-scattergun-turret"].subgroup = "vanilla-turrets"
	data.raw["item"]["w93-scattergun-turret"].order = "01[w93-scattergun-turret]"
	if krastorio.general.getSafeSettingValue("kr-more-realistic-weapon") then
		data.raw["ammo"]["w93-slowdown-magazine"].hidden = true
		table.remove(data.raw["technology"]["w93-modular-turrets-gatling"].effects, 4)
	end
	W93_UpdateTechKrastorio2()
	W93_UpdateRecipesKrastorio2()

	if krastorio.general.getSafeSettingValue("kr-more-realistic-weapon") then
		data.raw["ammo"]["rifle-magazine"].ammo_type.action[1].action_delivery[1].max_range = 35
		data.raw["ammo"]["armor-piercing-rifle-magazine"].ammo_type.action[1].action_delivery[1].max_range = 35
		data.raw["ammo"]["uranium-rifle-magazine"].ammo_type.action[1].action_delivery[1].max_range = 35
		data.raw["ammo"]["imersite-rifle-magazine"].ammo_type.action[1].action_delivery[1].max_range = 35
	end
end

if mods["IndustrialRevolution3"] then
	W93_UpdateTechIR3()
	W93_UpdateRecipesIR3()
	W93_UpdateItemsIR3()
end

if se_prodecural_tech_exclusions then
	table.insert(se_prodecural_tech_exclusions, "w93-modular-turrets")
	table.insert(se_prodecural_tech_exclusions, "w93-modular-turrets2")
	table.insert(se_prodecural_tech_exclusions, "w93-modular-turrets-gatling")
	table.insert(se_prodecural_tech_exclusions, "w93-modular-turrets-rocket")
	table.insert(se_prodecural_tech_exclusions, "w93-modular-turrets-plaser")
	table.insert(se_prodecural_tech_exclusions, "w93-modular-turrets-tlaser")
	table.insert(se_prodecural_tech_exclusions, "w93-modular-turrets-beam")
	table.insert(se_prodecural_tech_exclusions, "w93-modular-turrets-lcannon")
	table.insert(se_prodecural_tech_exclusions, "w93-modular-turrets-dcannon")
	table.insert(se_prodecural_tech_exclusions, "w93-modular-turrets-hcannon")
	table.insert(se_prodecural_tech_exclusions, "w93-modular-turrets-radar")
end
--]]
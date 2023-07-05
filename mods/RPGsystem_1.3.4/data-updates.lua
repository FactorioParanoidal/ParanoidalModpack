
if settings.startup["charxpmod_enable_potion_loot"].value then
for _, spawner in pairs(data.raw["unit-spawner"]) do
	local loot = spawner.loot or {}
	table.insert ( loot , {item = "rpg_level_up_potion",  count_min = 1,  count_max = 1,  probability = 0.005}) 
	table.insert ( loot , {item = "rpg_amnesia_potion",  count_min = 1,  count_max = 1,  probability = 0.003})
	table.insert ( loot , {item = "rpg_small_xp_potion",  count_min = 1,  count_max = 1,  probability = 0.015})
	table.insert ( loot , {item = "rpg_big_xp_potion",  count_min = 1,  count_max = 1,  probability = 0.01})
	table.insert ( loot , {item = "rpg_small_healing_potion",  count_min = 1,  count_max = 1,  probability = 0.02})
	table.insert ( loot , {item = "rpg_big_healing_potion",  count_min = 1,  count_max = 2,  probability = 0.01})
	table.insert ( loot , {item = "rpg_crafting_potion",  count_min = 1,  count_max = 2,  probability = 0.01})
	table.insert ( loot , {item = "rpg_speed_potion",  count_min = 1,  count_max = 2,  probability = 0.01})
	if mods['death_curses'] then table.insert ( loot , {item = "rpg_curse_cure_potion",  count_min = 1,  count_max = 1,  probability = 0.02}) end
	spawner.loot = loot
	end
end

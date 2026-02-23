

function get_mf_Loot(single)
    local Loot=	{ 
    --	{ item = "msi_portable_technology_data", probability = 0.2, count_min = 1, count_max = 1 },	
        { item = "advanced-circuit",  count_min = 1,  count_max = 3,  probability = 0.60 }	,
        { item = "productivity-module-2",  count_min = 1,  count_max = 3,  probability = 0.50 }	,
        { item = "productivity-module-3",  count_min = 1,  count_max = 2,  probability = 0.25 }	,
        { item = "efficiency-module-2",  count_min = 1,  count_max = 3,  probability = 0.50 }	,
        { item = "efficiency-module-3",  count_min = 1,  count_max = 2,  probability = 0.25 }	,
        { item = "speed-module-2",  count_min = 1,  count_max = 3,  probability = 0.50 }	,
        { item = "speed-module-3",  count_min = 1,  count_max = 2,  probability = 0.25 }	,
        }
    if data.raw.capsule['rpg_level_up_potion'] then
        table.insert ( Loot , {item = "rpg_level_up_potion",  count_min = 1,  count_max = 2,  probability = 0.20})
        table.insert ( Loot , {item = "rpg_amnesia_potion",  count_min = 1,  count_max = 1,  probability = 0.15})
        table.insert ( Loot , {item = "rpg_small_xp_potion",  count_min = 1,  count_max = 3,  probability = 0.50})
        table.insert ( Loot , {item = "rpg_big_xp_potion",  count_min = 1,  count_max = 2,  probability = 0.20})
        table.insert ( Loot , {item = "rpg_speed_potion",  count_min = 1,  count_max = 2,  probability = 0.20})
        table.insert ( Loot , {item = "rpg_crafting_potion",  count_min = 1,  count_max = 2,  probability = 0.20})
        end
     return Loot	
end
   


function get_mf_loot_rpg_potion(max)
    max=max or 1
    local Loot=	{}
    if data.raw.capsule['rpg_level_up_potion'] then
        table.insert ( Loot , {item = "rpg_level_up_potion",  count_min = 1,  count_max = max,  probability = 0.10})
        table.insert ( Loot , {item = "rpg_amnesia_potion",  count_min = 1,  count_max = max,  probability = 0.10})
        table.insert ( Loot , {item = "rpg_small_xp_potion",  count_min = 1,  count_max = max,  probability = 0.30})
        table.insert ( Loot , {item = "rpg_big_xp_potion",  count_min = 1,  count_max = max,  probability = 0.05})
        table.insert ( Loot , {item = "rpg_speed_potion",  count_min = 1,  count_max = max,  probability = 0.10})
        table.insert ( Loot , {item = "rpg_crafting_potion",  count_min = 1,  count_max = max,  probability = 0.10})
        end
     return Loot	
end

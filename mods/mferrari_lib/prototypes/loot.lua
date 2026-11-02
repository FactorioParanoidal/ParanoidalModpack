

function get_mf_Loot(single)
    local Loot=	{ 
    --	{ item = "msi_portable_technology_data", probability = 0.2, count_min = 1, count_max = 1 },	
        { type = "item", name = "advanced-circuit",  amount_min = 1,  amount_max = 3,  independent_probability = 0.60 }	,
        { type = "item", name = "productivity-module-2",  amount_min = 1,  amount_max = 3,  independent_probability = 0.50 }	,
        { type = "item", name = "productivity-module-3",  amount_min = 1,  amount_max = 2,  independent_probability = 0.25 }	,
        { type = "item", name = "efficiency-module-2",  amount_min = 1,  amount_max = 3,  independent_probability = 0.50 }	,
        { type = "item", name = "efficiency-module-3",  amount_min = 1,  amount_max = 2,  independent_probability = 0.25 }	,
        { type = "item", name = "speed-module-2",  amount_min = 1,  amount_max = 3,  independent_probability = 0.50 }	,
        { type = "item", name = "speed-module-3",  amount_min = 1,  amount_max = 2,  independent_probability = 0.25 }	,
        }
    if data.raw.capsule['rpg_level_up_potion'] then
        table.insert ( Loot , {type = "item", name = "rpg_level_up_potion",  amount_min = 1,  amount_max = 2,  independent_probability = 0.20})
        table.insert ( Loot , {type = "item", name = "rpg_amnesia_potion",  amount_min = 1,  amount_max = 1,  independent_probability = 0.15})
        table.insert ( Loot , {type = "item", name = "rpg_small_xp_potion",  amount_min = 1,  amount_max = 3,  independent_probability = 0.50})
        table.insert ( Loot , {type = "item", name = "rpg_big_xp_potion",  amount_min = 1,  amount_max = 2,  independent_probability = 0.20})
        table.insert ( Loot , {type = "item", name = "rpg_speed_potion",  amount_min = 1,  amount_max = 2,  independent_probability = 0.20})
        table.insert ( Loot , {type = "item", name = "rpg_crafting_potion",  amount_min = 1,  amount_max = 2,  independent_probability = 0.20})
        end
     return Loot	
end
   


function get_mf_loot_rpg_potion(max)
    max=max or 1
    local Loot=	{}
    if data.raw.capsule['rpg_level_up_potion'] then
        table.insert ( Loot , {type = "item", name = "rpg_level_up_potion",  amount_min = 1,  amount_max = max,  independent_probability = 0.10})
        table.insert ( Loot , {type = "item", name = "rpg_amnesia_potion",  amount_min = 1,  amount_max = max,  independent_probability = 0.10})
        table.insert ( Loot , {type = "item", name = "rpg_small_xp_potion",  amount_min = 1,  amount_max = max,  independent_probability = 0.30})
        table.insert ( Loot , {type = "item", name = "rpg_big_xp_potion",  amount_min = 1,  amount_max = max,  independent_probability = 0.05})
        table.insert ( Loot , {type = "item", name = "rpg_speed_potion",  amount_min = 1,  amount_max = max,  independent_probability = 0.10})
        table.insert ( Loot , {type = "item", name = "rpg_crafting_potion",  amount_min = 1,  amount_max = max,  independent_probability = 0.10})
        end
     return Loot	
end

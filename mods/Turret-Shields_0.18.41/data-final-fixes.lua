--cheat protection against "Flat infinite costs" mod (i think the costs are more than adequate) -> if player has set infinite costs to >=1000 it's fine (maybe i should set it to 1500...)
 if data.raw.technology["turret-shields-speed-3"].unit.count_formula ~= "(L-2)*500" then
	local f = loadstring("local L = 4; return "..data.raw.technology["turret-shields-speed-3"].unit.count_formula)
	if not f() or f() < 1000 then
		data.raw.technology["turret-shields-speed-3"].unit.count_formula = "1000"
	end
 end

 if data.raw.technology["turret-shields-size-3"].unit.count_formula ~= "(L-2)*500" then
	local f = loadstring("local L = 4; return "..data.raw.technology["turret-shields-size-3"].unit.count_formula)
	if not f() or f() < 1000 then
		data.raw.technology["turret-shields-size-3"].unit.count_formula = "1000"
	end
 end
 
--	{
--		type = "technology",
--		name = "turret-shields-speed-3",
--		icon = "__Turret-Shields__/graphics/speed-research.png",
--		icon_size = 128,
--		effects =
--			{{
--			type = "nothing",
--			effect_description = {"modifier-description.turret-shields-speed-3"},
--			}},
--		prerequisites = {"turret-shields-speed-2"},
--		unit =
--		{
--			count_formula = "(L-2)*500",
--			ingredients =
--			{
--				{"science-pack-1", 1},
--				{"science-pack-2", 1},
--				{"science-pack-3", 1},
--				{"production-science-pack", 1},
--				{"high-tech-science-pack", 1},
--				{"military-science-pack", 1},
--				{"space-science-pack", 1}
--			},
--			time = 60
--		},
--		max_level = "infinite",
--		upgrade = true,
--		enabled = true,
--		order = "e-l-a"
--	},-------------------------------------------------------------------------------------------------------------------------------
--	{
--		type = "technology",
--		name = "turret-shields-size-3",
--		icon = "__Turret-Shields__/graphics/size-research.png",
--		icon_size = 128,
--		effects =
--		{{
--		type = "nothing",
--		effect_description = {"modifier-description.turret-shields-size-3"},
--		}},
--		prerequisites = {"turret-shields-size-2"},
--		unit =
--		{
--			count_formula = "(L-2)*500",
--			ingredients =
--			{
--				{"science-pack-1", 1},
--				{"science-pack-2", 1},
--				{"science-pack-3", 1},
--				{"production-science-pack", 1},
--				{"high-tech-science-pack", 1},
--				{"military-science-pack", 1},
--				{"space-science-pack", 1}
--			},
--			time = 60
--		},
--		max_level = "infinite",
--		upgrade = true,
--		enabled = true,
--		order = "e-l-a"
--	},-------------------------------------------------------------------------------------------------------------------------------


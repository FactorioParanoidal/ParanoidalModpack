if not heroturrets.defines then require ("prototypes.scripts.defines") end

heroturrets_wiki = 
{
	name = "heroturrets",
	title    = "Hero Turrets",		
	mod_path =  "__heroturrets__",		
	{
		name = {"gui.heroturrets-wiki-topic-main"},
		topic = {
			{type = "title", title = {"gui.heroturrets-wiki-topic-main-title"} },
			{type = "line"},
			{				
				type = "image", 
				name = "ht-topic-main-img-1",
				filepath = "__heroturrets__/thumbnail.png",
				width = 144,
				height = 144,
				scale = 1
			},
			{type = "line"},
			{type = "text", text = "Hero Turret Private 2nd Class " .. heroturrets.defines.turret_levelup_one .. " Kills"},
			{type = "text", text = "Hero Turret Corporal " .. heroturrets.defines.turret_levelup_two .." Kills"},
			{type = "text", text = "Hero Turret Sargent  " .. heroturrets.defines.turret_levelup_three .." Kills"},
			{type = "text", text = "Hero Turret General " .. heroturrets.defines.turret_levelup_four .." Kills"},
		},
	},{
		name = {"gui.heroturrets-wiki-topic-1"},
		topic = {
			{type = "title", title = {"gui.heroturrets-wiki-topic-1-title"} },			
			{				
				type = "image", 
				name = "ht-1-img",
				filepath = "__heroturrets__/graphics/entity/turret/hr-hero-1-base.png",
				width = 46,
				height = 48,
				scale = 1
			},
			--{type = "text", text = "" },
			--{type = "line"},
			{type = "custom", interface = "heroturrets", func = "hero_1_detail"}
		}
	},{
		name = {"gui.heroturrets-wiki-topic-2"},
		topic = {
			{type = "title", title = {"gui.heroturrets-wiki-topic-2-title"} },			
			{				
				type = "image", 
				name = "ht-2-img",
				filepath = "__heroturrets__/graphics/entity/turret/hr-hero-2-base.png",
				width = 46,
				height = 48,
				scale = 1
			},
			--{type = "text", text = "" },
			--{type = "line"},
			{type = "custom", interface = "heroturrets", func = "hero_2_detail"}
		}
	},{
		name = {"gui.heroturrets-wiki-topic-3"},
		topic = {
			{type = "title", title = {"gui.heroturrets-wiki-topic-3-title"} },			
			{				
				type = "image", 
				name = "ht-3-img",
				filepath = "__heroturrets__/graphics/entity/turret/hr-hero-3-base.png",
				width = 46,
				height = 48,
				scale = 1
			},
			--{type = "text", text = "" },
			--{type = "line"},
			{type = "custom", interface = "heroturrets", func = "hero_3_detail"}
		}
	},{
		name = {"gui.heroturrets-wiki-topic-4"},
		topic = {
			{type = "title", title = {"gui.heroturrets-wiki-topic-4-title"} },			
			{				
				type = "image", 
				name = "ht-4-img",
				filepath = "__heroturrets__/graphics/entity/turret/hr-hero-4-base.png",
				width = 46,
				height = 48,
				scale = 1
			},
			--{type = "text", text = "" },
			--{type = "line"},
			{type = "custom", interface = "heroturrets", func = "hero_4_detail"}
		}
	}
}
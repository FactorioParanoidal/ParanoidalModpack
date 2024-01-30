-- changed: darkfrei 2021-04-05


local tech_name = "rocket-failure-revision"

local mod_name = '__RocketExplosions__'

local icon_size = 256

local icons = 
	{
		{icon = mod_name .. '/icons/' .. tech_name .. '.png', icon_size = icon_size, icon_mipmaps = 4},
	}

local order = 'g-3'

local ingredients = {
	{"automation-science-pack", 1},
	{"logistic-science-pack", 1},
	{"chemical-science-pack", 1},
	{"production-science-pack", 1},
	{"military-science-pack", 1},
	{"utility-science-pack", 1},
}

data:extend(
{
	
-- level 1
	{
		type = "technology",
--		name = "physical-projectile-damage-1", -- source
--		name = tech_name .. "-1",
		name = tech_name,
		icon_size = icon_size, icon_mipmaps = 4,
		icons = icons,
--		effects =
--		{
--			{
--				type = "ammo-damage",
--				ammo_category = "bullet",
--				modifier = 0.1
--			},
--			{
--				type = "turret-attack",
--				turret_id = "gun-turret",
--				modifier = 0.1
--			},
--			{
--				type = "ammo-damage",
--				ammo_category = "shotgun-shell",
--				modifier = 0.1
--			}
--		},
--		prerequisites = {"military"},
		prerequisites = {"rocket-silo"},
		unit =
		{
			count = 100*1,
			ingredients =ingredients,
			time = 30
		},
		upgrade = true,
		order = order .. "-a"
	},
	
-- level 2
	{
		type = "technology",
		name = tech_name .. "-2",
		icon_size = icon_size, icon_mipmaps = 4,
		icons = icons,
--		effects =
--		{
--			{
--				type = "ammo-damage",
--				ammo_category = "bullet",
--				modifier = 0.1
--			},
--			{
--				type = "turret-attack",
--				turret_id = "gun-turret",
--				modifier = 0.1
--			},
--			{
--				type = "ammo-damage",
--				ammo_category = "shotgun-shell",
--				modifier = 0.1
--			}
--		},
--		prerequisites = {tech_name .. "-1"},
		prerequisites = {tech_name},
		unit =
		{
			count = 100*2,
			ingredients = ingredients,
			time = 30
		},
		upgrade = true,
		order = order .. "-b"
	},
	
-- level 3
	{
		type = "technology",
		name = tech_name .. "-3",
		icon_size = icon_size, icon_mipmaps = 4,
		icons = icons,
--		effects =
--		{
--			{
--				type = "ammo-damage",
--				ammo_category = "bullet",
--				modifier = 0.2
--			},
--			{
--				type = "turret-attack",
--				turret_id = "gun-turret",
--				modifier = 0.2
--			},
--			{
--				type = "ammo-damage",
--				ammo_category = "shotgun-shell",
--				modifier = 0.2
--			}
--		},
		prerequisites = {tech_name .. "-2"},
		unit =
		{
			count = 100*4,
			ingredients = ingredients,
			time = 60
		},
		upgrade = true,
		order = order .. "-c"
	},
	
	
	
-- level 4
	{
		type = "technology",
		name = tech_name .. "-4",
		icon_size = icon_size, icon_mipmaps = 4,
		icons = icons,
--		effects =
--		{
--			{
--				type = "ammo-damage",
--				ammo_category = "bullet",
--				modifier = 0.2
--			},
--			{
--				type = "turret-attack",
--				turret_id = "gun-turret",
--				modifier = 0.2
--			},
--			{
--				type = "ammo-damage",
--				ammo_category = "shotgun-shell",
--				modifier = 0.2
--			}
--		},
		prerequisites = {tech_name .. "-3"},
		unit =
		{
			count = 100*6,
			ingredients = ingredients,
			time = 60
		},
		upgrade = true,
		order = order .. "-d"
	},
	
	
-- level 5
	{
		type = "technology",
		name = tech_name .. "-5",
		icon_size = icon_size, icon_mipmaps = 4,
		icons = icons,
--		effects =
--		{
--			{
--				type = "ammo-damage",
--				ammo_category = "bullet",
--				modifier = 0.2
--			},
--			{
--				type = "turret-attack",
--				turret_id = "gun-turret",
--				modifier = 0.2
--			},
--			{
--				type = "ammo-damage",
--				ammo_category = "shotgun-shell",
--				modifier = 0.2
--			},
--			{
--				type = "ammo-damage",
--				ammo_category = "cannon-shell",
--				modifier = 0.9
--			}
--		},
		prerequisites = {tech_name .. "-4"},
		unit =
		{
			count = 100*8,
			ingredients = ingredients,
			time = 60
		},
		upgrade = true,
		order = order .. "-e"
	},
	
	
-- level 6
	{
		type = "technology",
		name = tech_name .. "-6",
		icon_size = icon_size, icon_mipmaps = 4,
		icons = icons,
--		effects =
--		{
--			{
--				type = "ammo-damage",
--				ammo_category = "bullet",
--				modifier = 0.4
--			},
--			{
--				type = "turret-attack",
--				turret_id = "gun-turret",
--				modifier = 0.4
--			},
--			{
--				type = "ammo-damage",
--				ammo_category = "shotgun-shell",
--				modifier = 0.4
--			},
--			{
--				type = "ammo-damage",
--				ammo_category = "cannon-shell",
--				modifier = 1.3
--			}
--		},
		prerequisites = {tech_name .. "-5"},
		unit =
		{
			count = 100*10,
			ingredients = ingredients,
			time = 60
		},
		upgrade = true,
		order = order .. "-f"
	},
	
	
-- level 7
	{
		type = "technology",
		name = tech_name .. "-7",
		icon_size = 128, icon_mipmaps = 4,
		icons = {
					{icon = mod_name .. '/icons/' .. tech_name .. '2.png', icon_size = 128, icon_mipmaps = 4},
				},
--		effects =
--		{
--			{
--				type = "ammo-damage",
--				ammo_category = "bullet",
--				modifier = 0.4
--			},
--			{
--				type = "turret-attack",
--				turret_id = "gun-turret",
--				modifier = 0.7
--			},
--			{
--				type = "ammo-damage",
--				ammo_category = "shotgun-shell",
--				modifier = 0.4
--			},
--			{
--				type = "ammo-damage",
--				ammo_category = "cannon-shell",
--				modifier = 1
--			}
--		},
		prerequisites = {tech_name .. "-6", "space-science-pack"},
		unit =
		{
			count_formula = "2^(L-7)*1000",
			ingredients =
			{
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"military-science-pack", 1},
				{"production-science-pack", 1},
				{"utility-science-pack", 1},
				{"space-science-pack", 1}
			},
			time = 60
		},
		max_level = "infinite",
		upgrade = true,
		order = order .. "-f"
	},
	
	}
)	
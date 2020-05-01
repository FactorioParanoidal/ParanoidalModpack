data:extend(
{
	{
		type = "technology",
		name = "w93-modular-turrets-damage-11",
		icon = "__scattergun_turret__/graphics/technology/modular-turret-damage-tech.png",
		icon_size = 128,
		effects =
		{
			{
				type = "turret-attack",
				turret_id = "w93-hmg-turret",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-hmg-turret2",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-gatling-turret",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-gatling-turret2",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-lcannon-turret",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-lcannon-turret2",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-dcannon-turret",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-dcannon-turret2",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-hcannon-turret",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-hcannon-turret2",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-rocket-turret",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-rocket-turret2",
				modifier = 0.1
			},
		},
		prerequisites =
		{
			"w93-modular-turrets-damage-4",
			"kr-advanced-tech-card",
		},
		unit =
		{
			count_formula = "((L-10)^2)*3000",
			ingredients =
			{
				{"production-science-pack", 1},

				{"utility-science-pack", 1},

				{"space-science-pack", 1},

				{"matter-tech-card", 1},

				{"advanced-tech-card", 1}
			},
			time = 60
		},
		max_level = 15,
		upgrade = true,
		order = "e-a-z"
	},
	{
		type = "technology",
		name = "w93-modular-turrets-damage-16",
		icon = "__scattergun_turret__/graphics/technology/modular-turret-damage-tech.png",
		icon_size = 128,
		effects =
		{
			{
				type = "turret-attack",
				turret_id = "w93-hmg-turret",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-hmg-turret2",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-gatling-turret",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-gatling-turret2",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-lcannon-turret",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-lcannon-turret2",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-dcannon-turret",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-dcannon-turret2",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-hcannon-turret",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-hcannon-turret2",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-rocket-turret",
				modifier = 0.1
			},
			{
				type = "turret-attack",
				turret_id = "w93-rocket-turret2",
				modifier = 0.1
			},
		},
		prerequisites =
		{
			"w93-modular-turrets-damage-11",
			"kr-singularity-tech-card",
		},
		unit =
		{
			count_formula = "((L-15)^2)*3000",
			ingredients =
			{
				{"production-science-pack", 1},

				{"utility-science-pack", 1},

				{"space-science-pack", 1},

				{"matter-tech-card", 1},

				{"advanced-tech-card", 1},

				{"singularity-tech-card", 1}
			},
			time = 60
		},
		max_level = 18,
		upgrade = true,
		order = "e-a-z"
	},
})
data.raw["technology"]["w93-modular-turrets-damage-1"].unit.count = 400
data.raw["technology"]["w93-modular-turrets-damage-1"].effects =
	{{ type = "turret-attack", turret_id = "w93-hmg-turret", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-hmg-turret2", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-gatling-turret", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-gatling-turret2", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-lcannon-turret", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-lcannon-turret2", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-dcannon-turret", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-dcannon-turret2", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-hcannon-turret", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-hcannon-turret2", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-rocket-turret", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-rocket-turret2", modifier = 0.6 }}
data.raw["technology"]["w93-modular-turrets-damage-2"].unit.count = 500
data.raw["technology"]["w93-modular-turrets-damage-2"].effects =
	{{ type = "turret-attack", turret_id = "w93-hmg-turret", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-hmg-turret2", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-gatling-turret", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-gatling-turret2", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-lcannon-turret", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-lcannon-turret2", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-dcannon-turret", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-dcannon-turret2", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-hcannon-turret", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-hcannon-turret2", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-rocket-turret", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-rocket-turret2", modifier = 0.6 }}
data.raw["technology"]["w93-modular-turrets-damage-3"].unit.count = 600
data.raw["technology"]["w93-modular-turrets-damage-3"].effects =
	{{ type = "turret-attack", turret_id = "w93-hmg-turret", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-hmg-turret2", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-gatling-turret", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-gatling-turret2", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-lcannon-turret", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-lcannon-turret2", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-dcannon-turret", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-dcannon-turret2", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-hcannon-turret", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-hcannon-turret2", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-rocket-turret", modifier = 0.6 },
	{ type = "turret-attack", turret_id = "w93-rocket-turret2", modifier = 0.6 }}
data.raw["technology"]["w93-modular-turrets-damage-4"].unit.count_formula = "((L-3)^2)*3000"
data.raw["technology"]["w93-modular-turrets-damage-4"].max_level = 10
data.raw["technology"]["w93-modular-turrets-damage-4"].effects =
	{{ type = "turret-attack", turret_id = "w93-hmg-turret", modifier = 0.1 },
	{ type = "turret-attack", turret_id = "w93-hmg-turret2", modifier = 0.1},
	{ type = "turret-attack", turret_id = "w93-gatling-turret", modifier = 0.1 },
	{ type = "turret-attack", turret_id = "w93-gatling-turret2", modifier = 0.1 },
	{ type = "turret-attack", turret_id = "w93-lcannon-turret", modifier = 0.1 },
	{ type = "turret-attack", turret_id = "w93-lcannon-turret2", modifier = 0.1 },
	{ type = "turret-attack", turret_id = "w93-dcannon-turret", modifier = 0.1 },
	{ type = "turret-attack", turret_id = "w93-dcannon-turret2", modifier = 0.1 },
	{ type = "turret-attack", turret_id = "w93-hcannon-turret", modifier = 0.1 },
	{ type = "turret-attack", turret_id = "w93-hcannon-turret2", modifier = 0.1 },
	{ type = "turret-attack", turret_id = "w93-rocket-turret", modifier = 0.1 },
	{ type = "turret-attack", turret_id = "w93-rocket-turret2", modifier = 0.1 }}
if krastorio.general.getSafeSettingValue("kr-infinite-technology") then
	data.raw["technology"]["w93-modular-turrets-damage-16"].max_level = "infinite"
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
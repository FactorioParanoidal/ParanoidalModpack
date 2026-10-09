-- Боевой баланс финальной 1.1: Bob prototypes/item/ammo.lua и prototypes/entity/projectiles.lua.
-- Эффекты и характеристики из финального дампа 1.1; скриптовые интеграции 2.0 сохраняются.
local function apply_numbers(prototype_type, name, stats)
	local prototypes = data.raw[prototype_type]
	local prototype = prototypes and prototypes[name]
	if not prototype then
		return
	end
	if stats.piercing_damage then
		prototype.piercing_damage = stats.piercing_damage
	end

	local function visit(node, inside_area)
		if type(node) ~= "table" then
			return
		end
		local area = inside_area or node.type == "area"
		if node.type == "damage" and node.damage then
			local damage
			if area then
				damage = stats.area
			else
				damage = stats.direct
			end
			local amount = damage and damage[node.damage.type]
			if amount then
				node.damage.amount = amount
			end
		elseif node.type == "area" and stats.radius then
			node.radius = stats.radius
		elseif node.type == "direct" and node.repeat_count and stats.repeat_count then
			node.repeat_count = stats.repeat_count
		elseif node.type == "projectile" and node.projectile and node.max_range and stats.max_range then
			node.max_range = stats.max_range
		end
		for _, value in pairs(node) do
			visit(value, area)
		end
	end
	visit(prototype_type == "ammo" and prototype.ammo_type or prototype.action, false)
end

-- Магазины: прямой урон и площадь поражения из финального дампа 1.1.
local magazines = {
	["bob-bullet-magazine"] = { direct = { physical = 16 } },
	["bob-ap-bullet-magazine"] = { direct = { physical = 12, ["bob-pierce"] = 12 } },
	["bob-electric-bullet-magazine"] = { direct = { physical = 12, electric = 12 } },
	["bob-he-bullet-magazine"] = { direct = { physical = 12 }, area = { explosion = 12 }, radius = 3 },
	["bob-flame-bullet-magazine"] = { direct = { physical = 12 }, area = { fire = 12 }, radius = 3 },
	["bob-acid-bullet-magazine"] = { direct = { physical = 12 }, area = { acid = 12 }, radius = 3 },
	["bob-poison-bullet-magazine"] = { direct = { physical = 12 }, area = { poison = 12 }, radius = 3 },
	["bob-plasma-bullet-magazine"] = { direct = { physical = 12 }, area = { ["bob-plasma"] = 15 }, radius = 3 },
	["uranium-rounds-magazine"] = { direct = { physical = 24 } },
}
for name, stats in pairs(magazines) do
	apply_numbers("ammo", name, stats)
end

-- Дробь: число дробинок и дальность полёта из финальной 1.1.
local shotgun = {
	["shotgun-shell"] = 12,
	["piercing-shotgun-shell"] = 16,
	["bob-better-shotgun-shell"] = 20,
	["bob-shotgun-uranium-shell"] = 20,
	["bob-shotgun-ap-shell"] = 20,
	["bob-shotgun-electric-shell"] = 20,
	["bob-shotgun-explosive-shell"] = 10,
	["bob-shotgun-flame-shell"] = 10,
	["bob-shotgun-acid-shell"] = 10,
	["bob-shotgun-poison-shell"] = 10,
	["bob-shotgun-plasma-shell"] = 10,
}
for name, count in pairs(shotgun) do
	apply_numbers("ammo", name, { repeat_count = count, max_range = 36 })
end
apply_numbers("ammo", "bob-scatter-cannon-shell", { max_range = 160 })
apply_numbers("ammo", "high-explosive-cannon-shell", { max_range = 160 })

-- Урон отдельных дробинок из финальной 1.1.
local pellets = {
	["shotgun-pellet"] = { direct = { physical = 5 } },
	["bob-better-shotgun-projectile"] = { direct = { physical = 12 } },
	["bob-shotgun-uranium-projectile"] = { direct = { physical = 16 } },
	["bob-shotgun-ap-projectile"] = { direct = { ["bob-pierce"] = 12 } },
	["bob-shotgun-electric-projectile"] = { direct = { electric = 12 } },
	["bob-shotgun-explosive-projectile"] = { area = { explosion = 12 } },
	["bob-shotgun-flame-projectile"] = { area = { fire = 12 } },
	["bob-shotgun-acid-projectile"] = { area = { acid = 12 } },
	["bob-shotgun-poison-projectile"] = { area = { poison = 12 } },
	["bob-shotgun-plasma-projectile"] = { area = { ["bob-plasma"] = 25 } },
}
for name, stats in pairs(pellets) do
	apply_numbers("projectile", name, stats)
end

-- Ракеты Bob: прямой урон, урон по площади и её радиус.
local rockets = {
	["bob-piercing-rocket"] = { direct = { explosion = 120, ["bob-pierce"] = 240 } },
	["bob-electric-rocket"] = { direct = { explosion = 120, electric = 240 } },
	["bob-explosive-rocket"] = { direct = { explosion = 120 }, area = { explosion = 180 }, radius = 6.5 },
	["bob-flame-rocket"] = { direct = { explosion = 120 }, area = { fire = 180 }, radius = 6.5 },
	["bob-acid-rocket"] = { direct = { explosion = 120 }, area = { acid = 180 }, radius = 6.5 },
	["bob-poison-rocket"] = { direct = { explosion = 120 }, area = { poison = 180 }, radius = 6.5 },
	["bob-plasma-rocket"] = { direct = { ["bob-plasma"] = 120 }, area = { ["bob-plasma"] = 180 }, radius = 6.5 },
}
for name, stats in pairs(rockets) do
	apply_numbers("projectile", name, stats)
end

-- Обычные пушечные снаряды: урон и пробивной запас 1.1.
apply_numbers("projectile", "cannon-projectile", { direct = { physical = 200 }, piercing_damage = 300 })
apply_numbers("projectile", "uranium-cannon-projectile", { direct = { physical = 400 }, piercing_damage = 600 })

-- Урон неядерной артиллерии из финальной 1.1.
local artillery = {
	["artillery-projectile"] = { area = { physical = 500, explosion = 500 } },
	["bob-explosive-artillery-projectile"] = { area = { explosion = 1000 } },
	["bob-fire-artillery-projectile"] = { area = { fire = 750, explosion = 250 } },
	["bob-poison-artillery-projectile"] = { area = { poison = 750, explosion = 250 } },
}
for name, stats in pairs(artillery) do
	apply_numbers("artillery-projectile", name, stats)
end

-- Дополнительные эффекты ракет и дроби из Bob 1.1.
local function visit_attack(node, visitor)
	if type(node) ~= "table" then
		return
	end
	visitor(node)
	for _, value in pairs(node) do
		visit_attack(value, visitor)
	end
end

for _, name in ipairs({ "bob-acid-rocket", "bob-electric-rocket" }) do
	local projectile = data.raw.projectile[name]
	if projectile then
		visit_attack(projectile.action, function(node)
			for index = #node, 1, -1 do
				local effect = node[index]
				if type(effect) == "table" and effect.type == "create-sticker" and (effect.sticker == "slowdown-sticker" or effect.sticker == "stun-sticker") then
					table.remove(node, index)
				end
			end
		end)
	end
end
for name, sticker in pairs({ ["bob-shotgun-flame-projectile"] = "fire-sticker", ["bob-shotgun-poison-projectile"] = "poison-sticker" }) do
	local projectile = data.raw.projectile[name]
	if projectile and data.raw.sticker[sticker] then
		visit_attack(projectile.action, function(node)
			if node.type == "area" and node.action_delivery and node.action_delivery.target_effects then
				local effects = node.action_delivery.target_effects
				local present = false
				for _, effect in ipairs(effects) do
					present = present or (effect.type == "create-sticker" and effect.sticker == sticker)
				end
				if not present then
					table.insert(effects, { type = "create-sticker", sticker = sticker })
				end
			end
		end)
	end
end
local plasma_sticker = data.raw.sticker["bob-plasma-sticker"]
if plasma_sticker then
	plasma_sticker.damage_interval = nil
	plasma_sticker.damage_per_tick = { amount = 1, type = "bob-plasma" }
end
local ground_fire = data.raw.fire["fire-flame"]
if ground_fire then
	-- Bio Cannon добавлен в 2.0; его напалм сохраняет собственный огонь.
	local bio_napalm = data.raw.projectile["NE-Napalm-Small"]
	if bio_napalm then
		local bio_fire = table.deepcopy(ground_fire)
		bio_fire.name = "paranoidal-bio-cannon-fire"
		data:extend({ bio_fire })
		visit_attack(bio_napalm.action, function(node)
			if node.type == "create-entity" and node.entity_name == "fire-flame" then
				node.entity_name = bio_fire.name
			end
		end)
	end
	ground_fire.maximum_damage_multiplier = 6
	ground_fire.initial_lifetime = 120
	ground_fire.fade_out_duration = 30
end
local distractor = data.raw["combat-robot"].distractor
if distractor then
	distractor.max_health = 90
	distractor.time_to_live = 2700
	distractor.resistances = { { type = "fire", percent = 95 }, { type = "acid", decrease = 0, percent = 85 } }
	distractor.attack_parameters.damage_modifier = 0.5
	distractor.attack_parameters.range_mode = "center-to-center"
end

-- Полётные параметры пушечных снарядов и ракет 1.1, без замены формата ammo 2.0.
for _, name in ipairs({ "cannon-shell", "uranium-cannon-shell", "explosive-cannon-shell", "explosive-uranium-cannon-shell" }) do
	local ammo = data.raw.ammo[name]
	if ammo then
		ammo.ammo_type.range_modifier = nil
		visit_attack(ammo.ammo_type, function(node)
			if node.type == "projectile" then
				node.max_range = 160
				node.direction_deviation = 0.1
				node.range_deviation = 0.1
			end
		end)
	end
end
apply_numbers("ammo", "w93-uranium-shotgun-shell", { max_range = 36 })
for _, name in ipairs({ "rocket", "explosive-rocket", "slowdown-rocket", "bob-rocket", "bob-piercing-rocket", "bob-electric-rocket", "bob-explosive-rocket", "bob-flame-rocket", "bob-acid-rocket", "bob-poison-rocket" }) do
	local projectile = data.raw.projectile[name]
	if projectile then
		projectile.acceleration = 0.005
		projectile.turn_speed = nil
		projectile.turning_speed_increases_exponentially_with_projectile_speed = nil
	end
end
for _, name in ipairs({ "rocket", "explosive-rocket" }) do
	local projectile = data.raw.projectile[name]
	if projectile then
		projectile.turn_speed = 0.003
		projectile.turning_speed_increases_exponentially_with_projectile_speed = true
	end
end
local incendiary_rocket = data.raw.projectile["Schall-incendiary-rocket"]
if incendiary_rocket then
	incendiary_rocket.turn_speed = nil
	incendiary_rocket.turning_speed_increases_exponentially_with_projectile_speed = nil
end
for _, name in ipairs({ "cannon-projectile", "uranium-cannon-projectile" }) do
	local projectile = data.raw.projectile[name]
	if projectile then
		projectile.direction_only = true
	end
end
local scatter_projectile = data.raw.projectile["cannon-projectile-pellet"]
if scatter_projectile then
	scatter_projectile.force_condition = nil
end
local slowdown_ammo = data.raw.ammo["w93-turret-slowdown-rocket"]
if slowdown_ammo then
	slowdown_ammo.magazine_size = 4
	visit_attack(slowdown_ammo.ammo_type, function(node)
		if node.type == "projectile" then
			node.starting_speed = 0.9
		end
	end)
end
if data.raw.ammo["ammo-nano-levelers"] then
	data.raw.ammo["ammo-nano-levelers"].magazine_size = 20
end
-- Nanobots 1.1: каждый из четырёх уровней скорости давал +100% nano-ammo.
for level = 1, 4 do
	local technology = data.raw.technology["nano-speed-" .. level]
	if technology then
		for _, effect in ipairs(technology.effects or {}) do
			if effect.type == "gun-speed" and effect.ammo_category == "nano-ammo" then
				effect.modifier = 1
			end
		end
	end
end

-- В финальной 1.1 orbital-ai-core давал +100% laser; восстановить потерянный эффект.
local orbital_ai = data.raw.technology["orbital-ai-core"]
if orbital_ai then
	orbital_ai.effects = orbital_ai.effects or {}
	local present = false
	for _, effect in ipairs(orbital_ai.effects) do
		if effect.type == "ammo-damage" and effect.ammo_category == "laser" then
			effect.modifier = 1
			present = true
		end
	end
	if not present then
		table.insert(orbital_ai.effects, { type = "ammo-damage", ammo_category = "laser", modifier = 1 })
	end
end

-- Ядерные атаки финальной 1.1. nuke-explosion.created_effect с радиацией остаётся в 2.0.
-- AtomicArtillery2 имеет отдельный новый снаряд, без соответствия в финальной 1.1.
local new_atomic_artillery = data.raw["artillery-projectile"]["atomic-artillery-projectile"]
if new_atomic_artillery then
	for _, name in ipairs({ "atomic-bomb-ground-zero-projectile", "atomic-bomb-wave" }) do
		local source = data.raw.projectile[name]
		if source then
			local projectile = table.deepcopy(source)
			projectile.name = "paranoidal-atomic-artillery-" .. name
			data:extend({ projectile })
			visit_attack(new_atomic_artillery.action, function(node)
				if node.type == "projectile" and node.projectile == name then
					node.projectile = projectile.name
				end
			end)
		end
	end
end
local nuclear_attacks = {
	{ "projectile", "atomic-rocket", 400 },
	{ "artillery-projectile", "bob-atomic-artillery-projectile", 400, 2000 },
	{ "artillery-projectile", "artillery-projectile-nuclear", 400 },
	{ "projectile", "thermonuclear-rocket", 560, nil, true },
	{ "artillery-projectile", "artillery-projectile-thermonuclear", 560, nil, true },
}
local thermonuclear_effects
for _, spec in ipairs(nuclear_attacks) do
	local prototype = data.raw[spec[1]][spec[2]]
	if prototype then
		visit_attack(prototype.action, function(node)
			if node.type == "damage" and node.damage and node.damage.type == "bob-plasma" then
				node.damage = { amount = spec[3], type = "explosion" }
			elseif node.type == "area" and spec[4] and node.action_delivery
				and node.action_delivery.projectile == "atomic-bomb-ground-zero-projectile" then
				node.repeat_count = spec[4]
			elseif node.type == "area" and spec[2] == "artillery-projectile-nuclear" and node.radius == 4 then
				visit_attack(node, function(effect)
					if effect.type == "damage" then
						effect.damage.amount = 500
					end
				end)
			end
			if spec[5] then
				for index = #node, 1, -1 do
					local effect = node[index]
					if type(effect) == "table" and effect.type == "destroy-cliffs" and effect.radius == 18 then
						table.remove(node, index)
					end
				end
				if node.type == "create-entity" and node.entity_name == "nuke-effects-nauvis" then
					if not thermonuclear_effects and data.raw.explosion["nuke-effects-nauvis"] then
						thermonuclear_effects = table.deepcopy(data.raw.explosion["nuke-effects-nauvis"])
						thermonuclear_effects.name = "paranoidal-thermonuclear-effects"
						visit_attack(thermonuclear_effects.created_effect, function(effect)
							if effect.type == "set-tile" then
								effect.radius = 16.8
							end
						end)
						data:extend({ thermonuclear_effects })
					end
					if thermonuclear_effects then
						node.entity_name = thermonuclear_effects.name
					end
				end
			end
		end)
	end
end
for name, amount in pairs({ ["atomic-bomb-ground-zero-projectile"] = 100, ["atomic-bomb-wave"] = 400 }) do
	local projectile = data.raw.projectile[name]
	if projectile then
		visit_attack(projectile.action, function(node)
			if node.type == "damage" then
				node.damage = { amount = amount, type = "explosion" }
				node.upper_damage_modifier = name == "atomic-bomb-wave" and 0.1 or 0.01
			end
		end)
	end
end

-- MIRV 1.1: 13 вариантов по 154 снаряда; совместимые графика и скрипты MIRV2 сохраняются.
local mirv = data.raw["artillery-projectile"]["mirv-projectile"]
if mirv and data.raw["artillery-projectile"]["mirv-nuke-projectile1"] and data.raw.fire["nuke-fire1"] then
	local variants = {
		{ 300, 11, 15120, 9468 },
		{ 1140, 17, 9072, 11700 },
		{ 720, 17, 10332, 11700 },
		{ 540, 20, 14760, 12204 },
		{ 780, 10, 10872, 13428 },
		{ 480, 14, 9144, 9576 },
		{ 900, 14, 10152, 13680 },
		{ 600, 11, 12564, 11160 },
		{ 660, 11, 12960, 9036 },
		{ 1140, 19, 15804, 13104 },
		{ 540, 19, 13932, 15264 },
		{ 1080, 11, 13212, 9864 },
		{ 420, 15, 13140, 13464 },
	}
	for index, stats in ipairs(variants) do
		local source_index = (index - 1) % 4 + 1
		local name = "mirv-nuke-projectile" .. index
		local projectile = data.raw["artillery-projectile"][name]
		if not projectile then
			projectile = table.deepcopy(data.raw["artillery-projectile"]["mirv-nuke-projectile" .. source_index])
			projectile.name = name
			data:extend({ projectile })
		end
		local fire_name = "nuke-fire" .. index
		local fire = data.raw.fire[fire_name]
		if not fire then
			fire = table.deepcopy(data.raw.fire["nuke-fire" .. source_index])
			fire.name = fire_name
			data:extend({ fire })
		end
		fire.initial_lifetime = stats[1]
		fire.fade_out_duration = 30
		for suffix = 1, 2 do
			local corpse_name = "nuke-scorchmark" .. index .. suffix
			local corpse = data.raw.corpse[corpse_name]
			if not corpse then
				corpse = table.deepcopy(data.raw.corpse["nuke-scorchmark" .. source_index .. suffix])
				corpse.name = corpse_name
				corpse.time_before_removed = stats[suffix + 2]
				data:extend({ corpse })
			end
		end
		visit_attack(projectile.action, function(node)
			if node.type == "create-fire" then
				node.entity_name = fire_name
				node.initial_ground_flame_count = stats[2]
			elseif node.type == "create-entity" and node.entity_name == "nuke-scorchmark" .. source_index .. "1" then
				node.entity_name = "nuke-scorchmark" .. index .. "1"
			elseif node.type == "create-entity" and node.entity_name == "nuke-scorchmark" .. source_index .. "2" then
				node.entity_name = "nuke-scorchmark" .. index .. "2"
			end
		end)
	end
	local effects = mirv.action.action_delivery.target_effects
	local template, position
	for index = #effects, 1, -1 do
		local effect = effects[index]
		local area = effect.type == "nested-result" and effect.action and effect.action[1]
		local delivery = area and area.action_delivery
		if delivery and delivery.projectile and string.match(delivery.projectile, "^mirv%-nuke%-projectile%d+$") then
			template = table.deepcopy(effect)
			position = index
			table.remove(effects, index)
		end
	end
	if template then
		for index = 1, 13 do
			local effect = table.deepcopy(template)
			effect.action[1].repeat_count = 154
			effect.action[1].action_delivery.projectile = "mirv-nuke-projectile" .. index
			table.insert(effects, position + index - 1, effect)
		end
	end
end

-- Старые раздельные W93/Schall ammo возвращаются под собственными ID, вне чужих миграций.
-- Эффекты, магазины и рецепты взяты из финального data-raw-dump 1.1.
local legacy_projectiles = {
	{
		name = "paranoidal-schall-rocket-cluster",
		template = "explosive-rocket",
		action = {
			{
				type = "cluster",
				cluster_count = 7,
				distance = 8,
				distance_deviation = 3,
				action_delivery = { type = "projectile", projectile = "explosive-rocket", direction_deviation = 0.6, starting_speed = 0.25, starting_speed_deviation = 0.3 },
			},
		},
		acceleration = 0.005,
	},
	{
		name = "paranoidal-schall-napalm-rocket",
		template = "rocket",
		action = {
			{
				type = "direct",
				action_delivery = {
					type = "instant",
					target_effects = {
						{
							repeat_count = 100,
							type = "create-trivial-smoke",
							smoke_name = "nuclear-smoke",
							offset_deviation = { { -1, -1 }, { 1, 1 } },
							slow_down_factor = 1,
							starting_frame = 3,
							starting_frame_deviation = 5,
							starting_frame_speed = 0,
							starting_frame_speed_deviation = 5,
							speed_from_center = 0.5,
							speed_deviation = 0.2,
						},
						{ type = "create-entity", entity_name = "napalm-big-explosion" },
						{ type = "create-entity", entity_name = "small-scorchmark", check_buildability = true },
						{
							type = "nested-result",
							action = {
								type = "cluster",
								cluster_count = 200,
								distance = 2,
								distance_deviation = 50,
								action_delivery = { type = "projectile", projectile = "Schall-napalm-fire", direction_deviation = 0.6, starting_speed = 0.3, starting_speed_deviation = 0.1 },
							},
						},
					},
				},
			},
		},
		acceleration = 0.005,
	},
	{
		name = "paranoidal-schall-poison-rocket",
		template = "rocket",
		action = {
			{
				type = "cluster",
				cluster_count = 6,
				distance = 8,
				distance_deviation = 3,
				action_delivery = { type = "projectile", projectile = "paranoidal-schall-poison-capsule", starting_speed = 0.3 },
			},
		},
		acceleration = 0.005,
	},
	{
		name = "paranoidal-schall-poison-capsule",
		template = "poison-capsule",
		action = {
			type = "direct",
			action_delivery = { type = "instant", target_effects = { type = "create-entity", show_in_tooltip = true, entity_name = "Schall-poison-cloud" } },
		},
		acceleration = 0.005,
	},
}
for _, spec in ipairs(legacy_projectiles) do
	local source = data.raw.projectile[spec.template]
	local napalm_ready = spec.name ~= "paranoidal-schall-napalm-rocket" or data.raw.projectile["Schall-napalm-fire"]
	if mods["paranoidal-tank-platoon"] and source and napalm_ready then
		if spec.name == "paranoidal-schall-napalm-rocket" and not data.raw.explosion["napalm-big-explosion"] then
			local explosion = table.deepcopy(data.raw.explosion["big-explosion"])
			explosion.name = "napalm-big-explosion"
			data:extend({ explosion })
		end
		local projectile = table.deepcopy(source)
		projectile.name = spec.name
		projectile.action = table.deepcopy(spec.action)
		projectile.final_action = nil
		projectile.acceleration = spec.acceleration
		projectile.turn_speed = nil
		projectile.turning_speed_increases_exponentially_with_projectile_speed = nil
		data:extend({ projectile })
	end
end
local poison_cloud = data.raw["smoke-with-trigger"]["poison-cloud"]
if poison_cloud and data.raw.projectile["paranoidal-schall-poison-capsule"] then
	local cloud = table.deepcopy(poison_cloud)
	cloud.name = "Schall-poison-cloud"
	cloud.action = {
		type = "direct",
		action_delivery = {
			type = "instant",
			target_effects = {
				type = "nested-result",
				action = {
					type = "area",
					radius = 11,
					entity_flags = { "breaths-air" },
					action_delivery = { type = "instant", target_effects = { type = "damage", damage = { amount = 8, type = "poison" } } },
				},
			},
		},
	}
	cloud.action_cooldown = 30
	cloud.duration = 1200
	cloud.affected_by_wind = false
	cloud.spread_duration = 10
	data:extend({ cloud })
end
local legacy_ammo = {
	{
		name = "paranoidal-w93-light-cannon-shell",
		template = "cannon-shell",
		localised_name = { "?", { "item-name.w93-turret-light-cannon-shells" }, "W93 light cannon shells" },
		ammo_category = "cannon-shell",
		magazine_size = 6,
		stack_size = 200,
		ammo_type = {
			action = {
				type = "direct",
				action_delivery = {
					type = "instant",
					source_effects = { type = "create-explosion", entity_name = "explosion-gunshot" },
					target_effects = { { type = "create-entity", entity_name = "explosion" }, { type = "damage", damage = { amount = 100, type = "physical" } } },
				},
			},
		},
		recipe = {
			type = "recipe",
			name = "paranoidal-w93-light-cannon-shell",
			category = "crafting",
			enabled = false,
			energy_required = 8,
			ingredients = { { name = "copper-plate", type = "item", amount = 6 }, { name = "steel-plate", type = "item", amount = 3 } },
			results = { { type = "item", name = "paranoidal-w93-light-cannon-shell", amount = 1 } },
			allow_productivity = false,
		},
		unlocks = { "w93-modular-turrets-lcannon" },
		icon_badge_item = "w93-modular-gun-lcannon",
	},
	{
		name = "paranoidal-w93-light-uranium-cannon-shell",
		template = "uranium-cannon-shell",
		localised_name = { "?", { "item-name.w93-turret-light-uranium-cannon-shells" }, "W93 uranium light cannon shells" },
		ammo_category = "cannon-shell",
		magazine_size = 6,
		stack_size = 200,
		ammo_type = {
			action = {
				type = "direct",
				action_delivery = {
					type = "instant",
					source_effects = { type = "create-explosion", entity_name = "explosion-gunshot" },
					target_effects = { { type = "create-entity", entity_name = "explosion" }, { type = "damage", damage = { amount = 200, type = "physical" } } },
				},
			},
		},
		recipe = {
			type = "recipe",
			name = "paranoidal-w93-light-uranium-cannon-shell",
			category = "crafting",
			enabled = false,
			energy_required = 12,
			ingredients = { { name = "paranoidal-w93-light-cannon-shell", type = "item", amount = 1 }, { name = "uranium-238", type = "item", amount = 2 } },
			results = { { type = "item", name = "paranoidal-w93-light-uranium-cannon-shell", amount = 1 } },
			allow_productivity = false,
		},
		unlocks = { "uranium-ammo" },
		icon_badge_item = "w93-modular-gun-lcannon",
	},
	{
		name = "paranoidal-w93-cannon-shell",
		template = "explosive-cannon-shell",
		localised_name = { "?", { "item-name.w93-turret-cannon-shells" }, "W93 cannon shells" },
		ammo_category = "cannon-shell",
		magazine_size = 6,
		stack_size = 200,
		ammo_type = {
			cooldown_modifier = 1.25,
			action = {
				type = "direct",
				action_delivery = {
					type = "instant",
					source_effects = { type = "create-explosion", entity_name = "explosion-gunshot" },
					target_effects = {
						{ type = "create-entity", entity_name = "big-explosion" },
						{
							type = "nested-result",
							action = {
								type = "area",
								radius = 4,
								action_delivery = { type = "instant", target_effects = { type = "damage", damage = { amount = 120, type = "explosion" } } },
							},
						},
					},
				},
			},
		},
		recipe = {
			type = "recipe",
			name = "paranoidal-w93-cannon-shell",
			category = "crafting",
			enabled = false,
			energy_required = 8,
			ingredients = { { name = "paranoidal-w93-light-cannon-shell", type = "item", amount = 1 }, { name = "explosives", type = "item", amount = 6 } },
			results = { { type = "item", name = "paranoidal-w93-cannon-shell", amount = 1 } },
			allow_productivity = false,
		},
		unlocks = { "w93-modular-turrets-hcannon" },
		icon_badge_item = "w93-modular-gun-hcannon",
	},
	{
		name = "paranoidal-w93-uranium-cannon-shell",
		template = "explosive-uranium-cannon-shell",
		localised_name = { "?", { "item-name.w93-turret-uranium-cannon-shells" }, "W93 uranium cannon shells" },
		ammo_category = "cannon-shell",
		magazine_size = 6,
		stack_size = 200,
		ammo_type = {
			cooldown_modifier = 1.25,
			action = {
				type = "direct",
				action_delivery = {
					type = "instant",
					source_effects = { type = "create-explosion", entity_name = "explosion-gunshot" },
					target_effects = {
						{ type = "create-entity", entity_name = "big-explosion" },
						{
							type = "nested-result",
							action = {
								type = "area",
								radius = 4.25,
								action_delivery = { type = "instant", target_effects = { type = "damage", damage = { amount = 240, type = "explosion" } } },
							},
						},
					},
				},
			},
		},
		recipe = {
			type = "recipe",
			name = "paranoidal-w93-uranium-cannon-shell",
			category = "crafting",
			enabled = false,
			energy_required = 12,
			ingredients = { { name = "paranoidal-w93-cannon-shell", type = "item", amount = 1 }, { name = "uranium-238", type = "item", amount = 2 } },
			results = { { type = "item", name = "paranoidal-w93-uranium-cannon-shell", amount = 1 } },
			allow_productivity = false,
		},
		unlocks = { "uranium-ammo" },
		icon_badge_item = "w93-modular-gun-hcannon",
	},
	{
		name = "paranoidal-w93-slowdown-cannon-shell",
		template = "w93-fragmentation-cannon-shell",
		localised_name = { "?", { "item-name.w93-turret-slowdown-shells" }, "W93 slowdown cannon shells" },
		ammo_category = "cannon-shell",
		magazine_size = 6,
		stack_size = 200,
		ammo_type = {
			action = {
				type = "direct",
				action_delivery = {
					type = "instant",
					source_effects = { type = "create-explosion", entity_name = "explosion-gunshot" },
					target_effects = {
						{ type = "create-entity", entity_name = "big-explosion" },
						{
							type = "nested-result",
							action = {
								type = "area",
								radius = 4,
								action_delivery = {
									type = "instant",
									target_effects = {
										{ type = "damage", damage = { amount = 80, type = "explosion" } },
										{ type = "create-sticker", sticker = "slowdown-sticker-medium", show_in_tooltip = true },
									},
								},
							},
						},
					},
				},
			},
		},
		recipe = {
			type = "recipe",
			name = "paranoidal-w93-slowdown-cannon-shell",
			category = "crafting",
			enabled = false,
			energy_required = 8,
			ingredients = {
				{ name = "plastic-bar", type = "item", amount = 6 },
				{ name = "steel-plate", type = "item", amount = 6 },
				{ name = "explosives", type = "item", amount = 12 },
				{ name = "slowdown-capsule", type = "item", amount = 1 },
			},
			results = { { type = "item", name = "paranoidal-w93-slowdown-cannon-shell", amount = 2 } },
			allow_productivity = false,
		},
		unlocks = { "w93-modular-turrets-dcannon" },
		icon_badge_item = "w93-modular-gun-dcannon",
	},
	{
		name = "paranoidal-w93-rocket-pack",
		template = "rocket",
		localised_name = { "?", { "item-name.w93-turret-rocket" }, "W93 rocket pack" },
		ammo_category = "rocket",
		magazine_size = 4,
		stack_size = 200,
		ammo_type = {
			action = {
				type = "direct",
				action_delivery = {
					type = "projectile",
					projectile = "rocket",
					starting_speed = 0.9,
					source_effects = { type = "create-entity", entity_name = "explosion-hit" },
				},
			},
		},
		recipe = {
			type = "recipe",
			name = "paranoidal-w93-rocket-pack",
			category = "crafting",
			enabled = false,
			energy_required = 16,
			ingredients = { { name = "rocket", type = "item", amount = 4 }, { name = "solid-fuel", type = "item", amount = 1 } },
			results = { { type = "item", name = "paranoidal-w93-rocket-pack", amount = 1 } },
			allow_productivity = false,
		},
		unlocks = { "w93-modular-turrets-rocket" },
		icon_badge_item = "w93-modular-gun-rocket",
	},
	{
		name = "paranoidal-w93-explosive-rocket-pack",
		template = "explosive-rocket",
		localised_name = { "?", { "item-name.w93-turret-explosive-rocket" }, "W93 explosive rocket pack" },
		ammo_category = "rocket",
		magazine_size = 4,
		stack_size = 200,
		ammo_type = {
			cooldown_modifier = 1.25,
			action = {
				type = "direct",
				action_delivery = {
					type = "projectile",
					projectile = "explosive-rocket",
					starting_speed = 0.9,
					source_effects = { type = "create-entity", entity_name = "explosion-hit" },
				},
			},
		},
		recipe = {
			type = "recipe",
			name = "paranoidal-w93-explosive-rocket-pack",
			category = "crafting",
			enabled = false,
			energy_required = 16,
			ingredients = { { name = "explosive-rocket", type = "item", amount = 4 }, { name = "solid-fuel", type = "item", amount = 1 } },
			results = { { type = "item", name = "paranoidal-w93-explosive-rocket-pack", amount = 1 } },
			allow_productivity = false,
		},
		unlocks = { "w93-modular-turrets-rocket" },
		icon_badge_item = "w93-modular-gun-rocket",
	},
	{
		name = "paranoidal-schall-explosive-rocket-pack",
		template = "explosive-rocket",
		localised_name = { "?", { "item-name.Schall-explosive-rocket-pack" }, "Explosive rocket pack" },
		ammo_category = "rocket",
		magazine_size = 1,
		stack_size = 50,
		ammo_type = {
			{
				source_type = "default",
				action = {
					type = "direct",
					action_delivery = {
						type = "projectile",
						projectile = "explosive-rocket",
						starting_speed = 0.1,
						min_range = 10,
						source_effects = { type = "create-entity", entity_name = "explosion-hit" },
					},
				},
			},
			{
				source_type = "vehicle",
				target_type = "position",
				clamp_position = true,
				action = {
					type = "direct",
					action_delivery = {
						type = "projectile",
						projectile = "paranoidal-schall-rocket-cluster",
						starting_speed = 0.1,
						source_effects = { type = "create-entity", entity_name = "explosion-hit" },
					},
				},
			},
		},
		recipe = {
			type = "recipe",
			name = "paranoidal-schall-explosive-rocket-pack",
			category = "crafting",
			enabled = false,
			energy_required = 8,
			ingredients = { { name = "explosive-rocket", type = "item", amount = 5 } },
			results = { { type = "item", name = "paranoidal-schall-explosive-rocket-pack", amount = 1 } },
			allow_productivity = false,
		},
		unlocks = {  },
	},
	{
		name = "paranoidal-schall-napalm-bomb",
		template = "Schall-incendiary-rocket",
		localised_name = { "?", { "item-name.Schall-napalm-bomb" }, "Napalm bomb" },
		ammo_category = "rocket",
		magazine_size = 1,
		stack_size = 200,
		ammo_type = {
			range_modifier = 3,
			cooldown_modifier = 3,
			target_type = "position",
			action = {
				type = "direct",
				action_delivery = {
					type = "projectile",
					projectile = "paranoidal-schall-napalm-rocket",
					starting_speed = 0.05,
					source_effects = { type = "create-entity", entity_name = "explosion-hit" },
				},
			},
		},
		recipe = {
			type = "recipe",
			name = "paranoidal-schall-napalm-bomb",
			category = "chemistry",
			enabled = false,
			energy_required = 40,
			ingredients = {
				{ type = "item", name = "advanced-circuit", amount = 20 },
				{ type = "item", name = "steel-plate", amount = 10 },
				{ type = "item", name = "explosives", amount = 10 },
				{ type = "fluid", name = "angels-liquid-fuel-oil", amount = 500 },
				{ type = "fluid", name = "angels-liquid-naphtha", amount = 500 },
			},
			results = { { type = "item", name = "paranoidal-schall-napalm-bomb", amount = 1 } },
			allow_productivity = false,
		},
		unlocks = {  },
	},
	{
		name = "paranoidal-schall-poison-bomb",
		template = "rocket",
		localised_name = { "?", { "item-name.Schall-poison-bomb" }, "Poison bomb" },
		ammo_category = "rocket",
		magazine_size = 1,
		stack_size = 200,
		ammo_type = {
			range_modifier = 3,
			cooldown_modifier = 3,
			target_type = "position",
			action = {
				type = "direct",
				action_delivery = {
					type = "projectile",
					projectile = "paranoidal-schall-poison-rocket",
					starting_speed = 0.05,
					source_effects = { type = "create-entity", entity_name = "explosion-hit" },
				},
			},
		},
		recipe = {
			type = "recipe",
			name = "paranoidal-schall-poison-bomb",
			category = "chemistry",
			enabled = false,
			energy_required = 40,
			ingredients = {
				{ type = "item", name = "rocket", amount = 2 },
				{ type = "item", name = "electronic-circuit", amount = 2 },
				{ type = "item", name = "coal", amount = 60 },
				{ type = "fluid", name = "sulfuric-acid", amount = 300 },
			},
			results = { { type = "item", name = "paranoidal-schall-poison-bomb", amount = 1 } },
			allow_productivity = false,
		},
		unlocks = {  },
	},
}
for _, spec in ipairs(legacy_ammo) do
	local source = data.raw.ammo[spec.template]
	local required_mod = spec.name:find("^paranoidal%-w93%-") and "scattergun_turret" or "paranoidal-tank-platoon"
	local enabled_mod = mods[required_mod]
	local supports_ready = true
	visit_attack(spec.ammo_type, function(node)
		if node.type == "projectile" and node.projectile and not data.raw.projectile[node.projectile] then
			supports_ready = false
		end
	end)
	if enabled_mod and source and supports_ready then
		local ammo = table.deepcopy(source)
		ammo.name = spec.name
		ammo.localised_name = spec.localised_name
		ammo.localised_description = nil
		ammo.custom_tooltip_fields = nil
		ammo.factoriopedia_alternative = nil
		ammo.ammo_category = spec.ammo_category
		ammo.ammo_type = table.deepcopy(spec.ammo_type)
		ammo.magazine_size = spec.magazine_size
		ammo.stack_size = spec.stack_size
		if spec.icon_badge_item and data.raw.item[spec.icon_badge_item] then
			local badge = data.raw.item[spec.icon_badge_item]
			ammo.icons = table.deepcopy(source.icons or { { icon = source.icon, icon_size = source.icon_size or 64 } })
			if badge.icon then
				table.insert(ammo.icons, { icon = badge.icon, icon_size = badge.icon_size or 64, scale = 0.25, shift = { 8, 8 } })
			else
				for _, icon in ipairs(badge.icons or {}) do
					local layer = table.deepcopy(icon)
					layer.scale = (layer.scale or 1) * 0.25
					layer.shift = { 8, 8 }
					table.insert(ammo.icons, layer)
				end
			end
			ammo.icon = nil
		end
		data:extend({ ammo, table.deepcopy(spec.recipe) })
		for _, name in ipairs(spec.unlocks) do
			local technology = data.raw.technology[name]
			if technology then
				technology.effects = technology.effects or {}
				table.insert(technology.effects, { type = "unlock-recipe", recipe = spec.name })
			end
		end
	end
end
-- Размеры стопок боеприпасов из финального дампа 1.1; после ReStack и правок модов.
local ammo_stack_sizes = {
	[10] = {
		["artillery-shell"] = true,
		["bob-atomic-artillery-shell"] = true,
		["bob-distractor-artillery-shell"] = true,
		["bob-explosive-artillery-shell"] = true,
		["bob-fire-artillery-shell"] = true,
		["bob-poison-artillery-shell"] = true,
	},
	[200] = {
		["atomic-bomb"] = true,
		["bob-acid-bullet-magazine"] = true,
		["bob-acid-rocket"] = true,
		["bob-ap-bullet-magazine"] = true,
		["bob-better-shotgun-shell"] = true,
		["bob-bullet-magazine"] = true,
		["bob-electric-bullet-magazine"] = true,
		["bob-electric-rocket"] = true,
		["bob-explosive-rocket"] = true,
		["bob-flame-bullet-magazine"] = true,
		["bob-flame-rocket"] = true,
		["bob-he-bullet-magazine"] = true,
		["bob-laser-rifle-battery"] = true,
		["bob-laser-rifle-battery-amethyst"] = true,
		["bob-laser-rifle-battery-diamond"] = true,
		["bob-laser-rifle-battery-emerald"] = true,
		["bob-laser-rifle-battery-ruby"] = true,
		["bob-laser-rifle-battery-sapphire"] = true,
		["bob-laser-rifle-battery-topaz"] = true,
		["bob-piercing-rocket"] = true,
		["bob-plasma-bullet-magazine"] = true,
		["bob-plasma-rocket"] = true,
		["bob-poison-bullet-magazine"] = true,
		["bob-poison-rocket"] = true,
		["bob-rocket"] = true,
		["bob-scatter-cannon-shell"] = true,
		["bob-shotgun-acid-shell"] = true,
		["bob-shotgun-ap-shell"] = true,
		["bob-shotgun-electric-shell"] = true,
		["bob-shotgun-explosive-shell"] = true,
		["bob-shotgun-flame-shell"] = true,
		["bob-shotgun-plasma-shell"] = true,
		["bob-shotgun-poison-shell"] = true,
		["bob-shotgun-uranium-shell"] = true,
		["cannon-shell"] = true,
		["clowns-osmium-rounds-magazine"] = true,
		["explosive-cannon-shell"] = true,
		["explosive-rocket"] = true,
		["explosive-uranium-cannon-shell"] = true,
		["firearm-magazine"] = true,
		["maf-small-atomic-rocket"] = true,
		["piercing-rounds-magazine"] = true,
		["piercing-shotgun-shell"] = true,
		["rocket"] = true,
		["shotgun-shell"] = true,
		["uranium-cannon-shell"] = true,
		["uranium-rounds-magazine"] = true,
		["w93-fragmentation-cannon-shell"] = true,
		["w93-slowdown-magazine"] = true,
		["w93-turret-slowdown-rocket"] = true,
		["w93-uranium-shotgun-shell"] = true,
	},
}
for stack_size, names in pairs(ammo_stack_sizes) do
	for name in pairs(names) do
		local ammo = data.raw.ammo[name]
		if ammo then
			ammo.stack_size = stack_size
		end
	end
end

-- Маска попадания 1.1: object/player/train и боевые летающие цели Rampant.
-- Старые динамические layer13/14/15 соответствуют trigger_target и слоям объектов 2.0.
for _, name in ipairs({
	"bob-better-shotgun-projectile",
	"bob-shotgun-acid-projectile",
	"bob-shotgun-ap-projectile",
	"bob-shotgun-electric-projectile",
	"bob-shotgun-explosive-projectile",
	"bob-shotgun-flame-projectile",
	"bob-shotgun-plasma-projectile",
	"bob-shotgun-poison-projectile",
	"bob-shotgun-uranium-projectile",
	"cannon-H1-projectile",
	"cannon-H2-projectile",
	"cannon-projectile-pellet",
	"explosive-autocannon-projectile",
	"explosive-cannon-H1-projectile",
	"explosive-cannon-H2-projectile",
	"explosive-uranium-autocannon-projectile",
	"explosive-uranium-cannon-H1-projectile",
	"explosive-uranium-cannon-H2-projectile",
	"high-explosive-cannon-projectile",
	"uranium-cannon-H1-projectile",
	"uranium-cannon-H2-projectile",
}) do
	local projectile = data.raw.projectile[name]
	if projectile then
		projectile.hit_collision_mask = { layers = { object = true, player = true, train = true, trigger_target = true } }
	end
end
local napalm_fire = data.raw.fire["Schall-napalm-fire-flame"]
if napalm_fire then
	napalm_fire.fade_out_duration = 30
end
local burning_tree = data.raw.fire["fire-flame-on-tree"]
if burning_tree then
	burning_tree.tree_dying_factor = 1
end
local payload_napalm = data.raw.fire["napalm_fire_flame"]
if payload_napalm then
	payload_napalm.emissions = nil
	payload_napalm.emissions_per_second = { pollution = 0.05 }
end
local artillery_projectile = data.raw["artillery-projectile"]["artillery-projectile"]
if artillery_projectile then
	artillery_projectile.reveal_map = false
end

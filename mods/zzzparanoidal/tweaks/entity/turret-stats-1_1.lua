-- Финальные характеристики Paranoidal 1.1; до генерации рангов Hero на data-final-fixes.
local function apply_stats(prototype_type, name, health, attack)
	local turret = data.raw[prototype_type][name]
	if not turret then
		return
	end
	if health then
		turret.max_health = health
	end
	for field, value in pairs(attack) do
		turret.attack_parameters[field] = value
	end
end

-- Bio_Industries 1.1: prototypes/Bio_Turret/entity.lua.
apply_stats("ammo-turret", "bi-dart-turret", nil, { range = 15, cooldown = 4 })

-- Bob 1.1: prototypes/entity/turrets.lua; HP первых четырёх тиров из zzz/tweaks/entity/warfare.lua.
for tier, stats in ipairs({
	{ health = 2000, range = 60, cooldown = 200, damage = 12 },
	{ health = 2200, range = 65, cooldown = 150, damage = 18 },
	{ health = 2400, range = 70, cooldown = 120, damage = 25.2 },
	{ health = 2600, range = 75, cooldown = 100, damage = 33.6 },
}) do
	apply_stats("electric-turret", "bob-plasma-turret-" .. tier, stats.health, {
		min_range = 30,
		range = stats.range,
		cooldown = stats.cooldown,
		damage_modifier = stats.damage,
	})
end

-- Bob 1.1 и zzz/tweaks/entity/warfare.lua: расход заряда 1, минимальная дальность и интервал.
for tier, stats in ipairs({
	{ health = 400, min_range = 15, range = 30, cooldown = 300, damage = 15 },
	{ health = 600, min_range = 17, range = 35, cooldown = 240, damage = 20 },
	{ health = 800, min_range = 20, range = 40, cooldown = 210, damage = 25 },
}) do
	apply_stats("ammo-turret", "bob-sniper-turret-" .. tier, stats.health, {
		min_range = stats.min_range,
		range = stats.range,
		cooldown = stats.cooldown,
		damage_modifier = stats.damage,
		ammo_consumption_modifier = 1,
	})
end

-- Финальная 1.1: расход огнемёта 0.2, дальность W93 Gatling 25/30.
apply_stats("fluid-turret", "flamethrower-turret", nil, { fluid_consumption = 0.2 })
apply_stats("ammo-turret", "w93-gatling-turret", nil, { range = 25 })
apply_stats("ammo-turret", "w93-gatling-turret2", nil, { range = 30 })

-- W93 1.1: ammo_type.category = "laser" у лучевой турели MK2.
apply_stats("electric-turret", "w93-beam-turret2", nil, { ammo_category = "laser" })

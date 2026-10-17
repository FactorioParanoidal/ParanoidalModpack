-- W93 Modular Turrets: исправления поверх scattergun_turret без форка мода.
-- Подключается после ammo-stats-1_1: копия дробинки берёт её урон 1.1.
if not mods["scattergun_turret"] then
	return
end

-- Улучшение MK1 -> MK2 без петли: у плазменного лазера MK1 вёл сам в себя, у остальных пар
-- MK2 возвращал к MK1, радары тоже были закольцованы.
for _, pair in ipairs({
	{ "ammo-turret", "w93-hmg-turret" },
	{ "ammo-turret", "w93-gatling-turret" },
	{ "ammo-turret", "w93-lcannon-turret" },
	{ "ammo-turret", "w93-dcannon-turret" },
	{ "ammo-turret", "w93-hcannon-turret" },
	{ "ammo-turret", "w93-rocket-turret" },
	{ "electric-turret", "w93-plaser-turret" },
	{ "electric-turret", "w93-tlaser-turret" },
	{ "electric-turret", "w93-beam-turret" },
	{ "radar", "w93-radar-turret" },
}) do
	local prototypes = data.raw[pair[1]]
	local mk1, mk2 = prototypes[pair[2]], prototypes[pair[2] .. "2"]
	if mk1 and mk2 then
		mk1.next_upgrade = mk2.name
		mk2.next_upgrade = nil
	end
end

-- Лучевая турель MK2: разряд вокруг цели бил и замедлял свои стены, турели и игроков,
-- а 25 искр на каждый объект в радиусе давали основную нагрузку на обсчёт частиц.
local beam = data.raw.beam["w93-electric-beam"]
if beam then
	local function visit(node)
		if type(node) ~= "table" then
			return
		end
		if node.type == "area" then
			node.force = "not-same"
		elseif node.type == "create-particle" and node.particle_name == "pole-spark-particle" then
			node.repeat_count = 4
		end
		for _, value in pairs(node) do
			visit(value)
		end
	end
	visit(beam.action)
end

-- Осколочный снаряд: удар и осколки не задевают своих, как и сам снаряд (force_condition = "not-same").
local fragmentation = data.raw.projectile["w93-fragmentation-cannon-projectile"]
local pellet = data.raw.projectile["shotgun-pellet"]
if fragmentation and pellet then
	local own_pellet = table.deepcopy(pellet)
	own_pellet.name = "paranoidal-w93-fragmentation-pellet"
	own_pellet.force_condition = "not-same"
	own_pellet.hidden = true
	data:extend({ own_pellet })

	local function visit(node)
		if type(node) ~= "table" then
			return
		end
		if node.type == "area" then
			node.force = "not-same"
		elseif node.type == "projectile" and node.projectile == "shotgun-pellet" then
			node.projectile = own_pellet.name
		end
		for _, value in pairs(node) do
			visit(value)
		end
	end
	visit(fragmentation.action)
	visit(fragmentation.final_action)
end

-- Paranoidal fork: F12+ defense — the Yuoki turrets as advanced versions of the build's top simple turrets (user
-- decision 2026-10-24). Each recipe consumes the turret it supersedes; stats are set above that turret. Starting
-- numbers, to be balanced later. Also the high-tier Yuoki repair tools above Bob's repair pack 5.
local P = require("prototypes.paranoidal.lib")

local function turret(type_name, name, fields)
	local t = P.entity(type_name, name)
	local ap = t.attack_parameters
	for k, v in pairs(fields) do
		if k == "max_health" then
			t.max_health = v
		elseif k == "energy" then
			ap.ammo_type.energy_consumption = v
		else
			ap[k] = v
		end
	end
end

-- above bob-gun-turret-5 (range 22, cooldown 6, damage x5): about 1.8x the damage per second
turret("ammo-turret", "y_turret_gun2f12", { range = 28, cooldown = 4, damage_modifier = 6, max_health = 3000 })
P.ingredients("y_turret_gun2f12", { { "bob-gun-turret-5", 1 }, { "y-basic-t1-mf", 1 }, { "y_structure_element", 12 },
	{ "y-bluegear", 3 } })
-- rapid-fire cannon turret (cannon shells)
turret("ammo-turret", "y_turret_gun1f12", { range = 36, cooldown = 15, damage_modifier = 3, max_health = 3500 })
P.ingredients("y_turret_gun1f12", { { "bob-gun-turret-5", 1 }, { "y-basic-t1-mf", 1 }, { "y_structure_element", 12 },
	{ "bob-tungsten-pipe", 4 } })
-- above bob-laser-turret-5 (range 32, cooldown 20, damage x7.2)
turret("electric-turret", "y_turret_laser22f12", { range = 34, cooldown = 12, damage_modifier = 8, energy = "2MJ",
	max_health = 3000 })
P.ingredients("y_turret_laser22f12", { { "bob-laser-turret-5", 1 }, { "y-basic-t2-mf", 1 }, { "y_blocked_capa", 2 },
	{ "y-conductive-coil-1", 3 }, { "y_structure_electric", 4 } })
-- plasma cannon on Yuoki plasma capsules (Bob's plasma turrets are electric)
P.ingredients("y_turret_plasma", { { "bob-plasma-turret-2", 1 }, { "y_structure_element", 8 }, { "y_structure_vessel", 2 },
	{ "y-basic-t2-mf", 1 }, { "y-conductive-coil-1", 4 }, { "y-raw-fuelnium", 1 } })
-- flamethrower on solid blaze canisters, no fluid piping
P.ingredients("y_turret_flame", { { "flamethrower-turret", 1 }, { "y_structure_element", 4 }, { "y_structure_vessel", 4 },
	{ "y-basic-t1-mf", 2 } })
-- 3x3 rapid laser fortress
P.ingredients("y-weapon-ztt", { { "bob-laser-turret-5", 2 }, { "bob-reinforced-wall", 8 }, { "y-basic-t2-mf", 2 },
	{ "y-chip-2", 2 }, { "y-accumulator-b-t2", 1 }, { "y-infused-uca2", 1 } })
-- Vitduo force field (reflects damage) on top of a reinforced wall
P.ingredients("y-wall-forcefield", { { "bob-reinforced-wall", 1 }, { "y-conductive-coil-1", 3 },
	{ "y-conductive-wire-1", 1 } })

-- repair tools above bob-repair-pack-5 (speed 10, durability 5000)
local repair = {
	["y-repair-durotal"] = { speed = 12, durability = 8000, stack = 100,
		recipe = { { "bob-repair-pack-5", 1 }, { "y-unicomp-raw", 2 }, { "y_structure_element", 1 } } },
	["y-repair-krakon"] = { speed = 16, durability = 15000, stack = 100,
		recipe = { { "y-repair-durotal", 1 }, { "y-orange-stuff", 4 }, { "y-chip-2", 1 } } },
	y_repair_quantrinum = { speed = 30, durability = 30000, stack = 50,
		recipe = { { "y-repair-krakon", 1 }, { "y-quantrinum", 1 }, { "y-infused-uca2", 1 } } },
}
for name, r in pairs(repair) do
	local tool = P.entity("repair-tool", name)
	tool.speed = r.speed
	tool.durability = r.durability
	tool.stack_size = r.stack
	P.ingredients(name, r.recipe)
end

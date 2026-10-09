-- Bob/zzz 1.1: пятый тир плазмы с графикой текущего T4.
local source = data.raw["electric-turret"]["bob-plasma-turret-4"]
if not source then
	return
end

local turret = table.deepcopy(source)
turret.name = "bob-plasma-turret-5"
turret.minable = { mining_time = 0.5, result = turret.name }
turret.max_health = 4000
turret.resistances = nil
turret.next_upgrade = nil
turret.prepare_range = 82
turret.energy_source.buffer_capacity = "4020000kJ"
turret.energy_source.input_flow_limit = "400000kW"
turret.energy_source.drain = "9600kW"
turret.attack_parameters.range = 80
turret.attack_parameters.min_range = 30
turret.attack_parameters.cooldown = 85
turret.attack_parameters.damage_modifier = 43.2
turret.attack_parameters.ammo_type.energy_consumption = "800000kJ"
local function set_projectile_range(node)
	if type(node) ~= "table" then
		return
	end
	if node.type == "projectile" and node.projectile then
		node.max_range = 160
	end
	for _, value in pairs(node) do
		set_projectile_range(value)
	end
end
set_projectile_range(turret.attack_parameters.ammo_type.action)
require("prototypes.plasma-turret-5-graphics")(turret)
data:extend({ turret })

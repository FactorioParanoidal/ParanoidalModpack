-- SPECIAL TURRET / no ammo / power 

function mf_fake_human_add_turrets(base_name,dmg_multiplier,hp_multiplier) 

  local function add_ammo_turret(name)
  if data.raw["ammo-turret"][name] then 
    local gun_turret = table.deepcopy(data.raw["ammo-turret"][name])
    gun_turret.name=base_name ..'_'..name
   -- gun_turret.flags = {"placeable-player", "placeable-enemy", "not-repairable"}
    gun_turret.hidden = true
    gun_turret.attack_parameters.ammo_consumption_modifier = 0 -- does not consume ammo
    gun_turret.attack_parameters.damage_modifier = 1 + dmg_multiplier
    gun_turret.max_health = gun_turret.max_health * hp_multiplier
    data:extend({gun_turret})
  end
  end

  local function add_electric_turret(name)
    if data.raw["electric-turret"][name] then   
    local laser_turret = table.deepcopy(data.raw["electric-turret"][name])
    laser_turret.name=base_name ..'_'..name
   -- laser_turret.flags = {"placeable-player", "placeable-enemy", "not-repairable"}
    laser_turret.attack_parameters.ammo_type.energy_consumption = "0kJ"
    laser_turret.attack_parameters.damage_modifier = 3 * dmg_multiplier
    laser_turret.max_health = laser_turret.max_health * hp_multiplier
    laser_turret.hidden = true
    laser_turret.energy_source =
        {
          type = "void",
          buffer_capacity = "15MJ",
          input_flow_limit = "7MW",
          drain = "1MW",
          usage_priority = "primary-input"
        }
    data:extend({laser_turret})
      end
    end

local turrets = {"gun-turret","railgun-turret","rocket-turret"}
for _,name in pairs(turrets) do add_ammo_turret(name) end

local turrets = {"laser-turret","tesla-turret"}
for _,name in pairs(turrets) do add_electric_turret(name) end
end

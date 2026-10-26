-- Defence towers of the citadel: electric turrets on the citadel power network (a module whose power
-- plants are destroyed goes dark). They fire the droid ammo categories, so the damage and rate
-- bonuses of the citadel force apply to them as well. "player-creation" lets the shield of Defence
-- Tower Reforged protect them (it only covers buildable-looking turrets).
local S = require("lib.shared")
local G = require("prototypes.gfx")
local E = S.entity
local raw = data.raw

local RESIST = {
  {type = "physical", decrease = 5, percent = 30},
  {type = "explosion", decrease = 10, percent = 35},
  {type = "fire", percent = 80},
  {type = "acid", percent = 40},
  {type = "laser", percent = 25},
  {type = "electric", percent = 25},
  {type = "poison", percent = 100},
}
local MAP = {r = 0.55, g = 0.1, b = 0.15}
local GRAPHICS = {"folded_animation", "preparing_animation", "prepared_animation", "prepared_alternative_animation",
  "starting_attack_animation", "attacking_animation", "ending_attack_animation", "folding_animation",
  "graphics_set", "integration"}

local function tower(name, from, tint, health, energy, attack)
  local p = G.copy(from)
  p.type = "electric-turret"
  p.name = name
  for _, k in pairs(GRAPHICS) do
    if p[k] then G.tint_all(p[k], tint) end
  end
  p.energy_source = {type = "electric", usage_priority = "primary-input", buffer_capacity = energy.buffer,
    input_flow_limit = energy.flow, drain = energy.drain}
  p.attack_parameters = attack
  p.inventory_size = nil
  p.automated_ammo_count = nil
  p.flags = {"placeable-enemy", "player-creation", "not-blueprintable", "not-deconstructable", "not-rotatable"}
  p.max_health = health
  p.resistances = RESIST
  p.minable = nil
  p.placeable_by = nil
  p.fast_replaceable_group = nil
  p.next_upgrade = nil
  p.circuit_connector = nil
  p.circuit_wire_max_distance = nil
  p.call_for_help_radius = 40
  p.map_color = MAP
  p.enemy_map_color = MAP
  p.hidden_in_factoriopedia = true
  p.factoriopedia_simulation = nil
  p.icons = G.icons(from, tint)
  p.icon = nil
  p.icon_size = nil
  p.subgroup = "enemies"
  p.order = "z[replicators]-" .. name
  p.collision_box = {{-0.7, -0.7}, {0.7, 0.7}}
  p.selection_box = {{-1, -1}, {1, 1}}
  return p
end

local gun = raw["ammo-turret"]["gun-turret"]
local laser = raw["electric-turret"]["laser-turret"]
local gun_attack = gun.attack_parameters or {}
local laser_attack = laser.attack_parameters or {}

-- Mortar shell: the grenade flight and explosion, area damage to enemies of the shooter only.
local shell = G.copy(raw.projectile.grenade)
shell.name = S.prefix .. "mortar-shell"
shell.hidden = true
shell.action = {
  {
    type = "direct",
    action_delivery = {type = "instant", target_effects = {
      {type = "create-entity", entity_name = "grenade-explosion"},
      {type = "create-entity", entity_name = "small-scorchmark-tintable", check_buildability = true},
    }},
  },
  {
    type = "area",
    radius = 4,
    force = "enemy",
    action_delivery = {type = "instant", target_effects = {
      {type = "damage", damage = {amount = 60, type = "explosion"}},
      {type = "create-entity", entity_name = "explosion"},
    }},
  },
}

-- Tesla tower: the chain lightning of the tesla droid (Robot Army Reforged).
local tesla_attack = G.copy(raw.unit["droid-tesla"].attack_parameters)
tesla_attack.animation = nil
tesla_attack.range = 22
tesla_attack.cooldown = 60
tesla_attack.projectile_center = {0, -0.8}
tesla_attack.projectile_creation_distance = 1.2
tesla_attack.ammo_type.energy_consumption = "600kJ"

data:extend({
  shell,
  tower(E.gun_tower, gun, {r = 0.75, g = 0.45, b = 0.45}, 2200,
    {buffer = "1MJ", flow = "1MW", drain = "15kW"},
    {
      type = "projectile",
      ammo_category = "droid-bullet",
      cooldown = 6,
      range = 20,
      projectile_creation_distance = gun_attack.projectile_creation_distance or 1.39,
      projectile_center = gun_attack.projectile_center or {0, -0.09},
      shell_particle = gun_attack.shell_particle,
      sound = gun_attack.sound,
      ammo_type = {
        energy_consumption = "20kJ",
        action = {type = "direct", action_delivery = {type = "instant",
          source_effects = {{type = "create-explosion", entity_name = "explosion-gunshot"}},
          target_effects = {
            {type = "create-entity", entity_name = "explosion-hit"},
            {type = "damage", damage = {amount = 9, type = "physical"}},
          }}},
      },
    }),
  tower(E.laser_tower, laser, {r = 1.0, g = 0.45, b = 0.4}, 2000,
    {buffer = "2MJ", flow = "2MW", drain = "20kW"},
    {
      type = "projectile",
      ammo_category = "droid-energy",
      cooldown = 20,
      range = 24,
      projectile_creation_distance = 1.4,
      projectile_center = {0, -1.1},
      sound = laser_attack.sound,
      ammo_type = {
        energy_consumption = "250kJ",
        action = {type = "direct", action_delivery = {type = "projectile", projectile = "droid-laser-bolt", starting_speed = 0.35}},
      },
    }),
  tower(E.mortar_tower, gun, {r = 1.0, g = 0.6, b = 0.25}, 2400,
    {buffer = "3MJ", flow = "1MW", drain = "15kW"},
    {
      type = "projectile",
      ammo_category = "droid-rocket",
      cooldown = 180,
      range = 40,
      min_range = 10,
      projectile_creation_distance = 1.4,
      projectile_center = {0, -0.4},
      sound = {filename = "__base__/sound/fight/tank-cannon.ogg", volume = 0.5},
      ammo_type = {
        energy_consumption = "1MJ",
        target_type = "position",
        action = {type = "direct", action_delivery = {type = "projectile", projectile = shell.name, starting_speed = 0.45}},
      },
    }),
  tower(E.tesla_tower, laser, {r = 0.45, g = 1.0, b = 1.0}, 2000,
    {buffer = "3MJ", flow = "2MW", drain = "20kW"},
    tesla_attack),
})

local shared = require("prototypes.shared")

local guns = data.raw.gun

-- Vehicle guns are derived from the 2.0 tank guns for graphics and sounds; combat values are Beta 8.
local function derive(base_name, name, parameters)
  local gun = table.deepcopy(guns[base_name])
  gun.name = name
  for key, value in pairs(parameters) do
    gun.attack_parameters[key] = value
  end
  return gun
end

local autocannon = derive("tank-cannon", "tank-autocannon", {
  ammo_category = "autocannon-shell",
  cooldown = 9,
  range = 20,
  min_range = 5,
  damage_modifier = 1.5
})
autocannon.attack_parameters.sound = table.deepcopy(autocannon.attack_parameters.sound)
shared.scale_sound(autocannon.attack_parameters.sound, 0.3)

local cannon_h1 = derive("tank-cannon", "tank-cannon-H1", {
  ammo_category = "cannon-H1-shell",
  cooldown = 180,
  range = 30,
  min_range = 5,
  damage_modifier = 1.5,
  health_penalty = -1
})
cannon_h1.icon = nil
cannon_h1.icons = {{icon = "__base__/graphics/icons/tank-cannon.png"}, shared.caliber_icon.H1}

local cannon_h2 = derive("tank-cannon", "tank-cannon-H2", {
  ammo_category = "cannon-H2-shell",
  cooldown = 360,
  range = 35,
  min_range = 5,
  damage_modifier = 1.5,
  health_penalty = -1
})
cannon_h2.icon = nil
cannon_h2.icons = {{icon = "__base__/graphics/icons/tank-cannon.png"}, shared.caliber_icon.H2}

local machine_gun_single = derive("tank-machine-gun", "tank-machine-gun-single", {
  cooldown = 8,
  damage_modifier = 1.5
})

local sniper_rifle = {
  type = "gun",
  name = "Schall-sniper-rifle",
  icon = shared.icons .. "sniper-rifle.png",
  icon_size = 128,
  subgroup = "gun",
  order = "a[basic-clips]-s[sniper-rifle]",
  attack_parameters = {
    type = "projectile",
    ammo_categories = {"bullet", "Schall-sniper-bullet"},
    warmup = 60,
    cooldown = 120,
    movement_slow_down_factor = 1,
    movement_slow_down_cooldown = 120,
    damage_modifier = 4,
    min_range = 8,
    range = 48,
    health_penalty = -1,
    projectile_creation_distance = 1.125,
    shell_particle = {
      name = "shell-particle",
      direction_deviation = 0.1,
      speed = 0.1,
      speed_deviation = 0.03,
      center = {0, 0.1},
      creation_distance = -0.5,
      starting_frame_speed = 0.4,
      starting_frame_speed_deviation = 0.1
    },
    sound = {filename = shared.MOD .. "/sound/sniper-rifle-gunshot.ogg", volume = 0.6}
  },
  stack_size = 5
}

data:extend({autocannon, cannon_h1, cannon_h2, machine_gun_single, sniper_rifle})

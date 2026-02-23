local ICONPATH = "__Aircraft-space-age__/graphics/icons/"
local heavygunshotsounds = {
  variations = {
    { filename = "__base__/sound/fight/heavy-gunshot-1.ogg", volume = 0.8 },
    { filename = "__base__/sound/fight/heavy-gunshot-2.ogg", volume = 0.8 },
    { filename = "__base__/sound/fight/heavy-gunshot-3.ogg", volume = 0.8 },
    { filename = "__base__/sound/fight/heavy-gunshot-4.ogg", volume = 0.8 }
  }
}
local flamethrowersounds = {
  begin_sound = { { filename = "__base__/sound/fight/flamethrower-start.ogg", volume = 0.7 } },
  middle_sound = { { filename = "__base__/sound/fight/flamethrower-mid.ogg", volume = 0.7 } },
  end_sound = { { filename = "__base__/sound/fight/flamethrower-end.ogg", volume = 0.7 } } }
local rocketlaunchersound = { {filename = "__base__/sound/fight/rocket-launcher.ogg", volume = 0.7 } }
local tankcannonsound = { { filename = "__base__/sound/fight/tank-cannon.ogg", volume = 1 } }

data:extend({
-----------------------------------------------AIRPLANES----------------------------------------------------
 { -- Gunship
    type = "item-with-entity-data",
    name = "gunship",
    icon = ICONPATH .. "gunship_icon.png",
    icon_size = 64,
    flags = {},
    subgroup = "transport",
    order = "b[personal-transport]-e[gunship]",
    place_result = "gunship",
    stack_size = 1,
  },
  { -- Cargo Plane
    type = "item-with-entity-data",
    name = "cargo-plane",
    icon = ICONPATH .. "cargo_plane_icon.png",
    icon_size = 64,
    flags = {},
    subgroup = "transport",
    order = "b[personal-transport]-f[cargo-plane]",
    place_result = "cargo-plane",
    stack_size = 1,
  },
  { -- Jet
    type = "item-with-entity-data",
    name = "jet",
    icon = ICONPATH .. "jet_icon.png",
    icon_size = 64,
    flags = {},
    subgroup = "transport",
    order = "b[personal-transport]-g[jet]",
    place_result = "jet",
    stack_size = 1,
  },
  { -- Flying Fortress
    type = "item-with-entity-data",
    name = "flying-fortress",
    icon = ICONPATH .. "flying_fortress_icon.png",
    icon_size = 64,
    flags = {},
    subgroup = "transport",
    order = "b[personal-transport]-h[flying-fortress]",
    place_result = "flying-fortress",
    stack_size = 1,
  },
-----------------------------------------------WEAPONS----------------------------------------------------
  { -- Aircraft machine gun
    type = "gun",
    name = "aircraft-machine-gun",
    icon = "__base__/graphics/icons/submachine-gun.png",
    icon_size = 64,
    hidden = true,
    subgroup = "gun",
    order = "a[basic-clips]-c[aircraft-machine-gun]",
    attack_parameters =
    {
      type = "projectile",
      ammo_category = "bullet",
      cooldown = 3,
      movement_slow_down_factor = 0.5,
      shell_particle =
      {
        name = "shell-particle",
        direction_deviation = 0.1,
        speed = 0.1,
        speed_deviation = 0.03,
        center = {0, 0},
        creation_distance = -0.6875,
        starting_frame_speed = 0.4,
        starting_frame_speed_deviation = 0.1
      },
      projectile_creation_distance = 0.65,
      range = 30,
      sound = heavygunshotsounds,
    },
    stack_size = 1
  },
  { -- Aircraft rocket launcher
    type = "gun",
    name = "aircraft-rocket-launcher",
    icon = "__base__/graphics/icons/rocket-launcher.png",
    icon_size = 64,
    hidden = true,
    subgroup = "gun",
    order = "e[aircraft-rocket-launcher]",
    attack_parameters =
    {
      type = "projectile",
      ammo_category = "rocket",
      movement_slow_down_factor = 0.9,
      cooldown = 30,
      projectile_creation_distance = 0.6,
      range = 35,
      projectile_center = {-0.17, 0},
      sound = rocketlaunchersound,
    },
    stack_size = 1
  },
  { -- Cargo plane machine gun
    type = "gun",
    name = "cargo-plane-machine-gun",
    icon = "__base__/graphics/icons/submachine-gun.png",
    icon_size = 64,
    hidden = true,
    subgroup = "gun",
    order = "a[basic-clips]-c[cargo-plane-machine-gun]",
    attack_parameters =
    {
      type = "projectile",
      ammo_category = "bullet",
      cooldown = 3.5,
      movement_slow_down_factor = 0.8,
      shell_particle =
      {
        name = "shell-particle",
        direction_deviation = 0.1,
        speed = 0.1,
        speed_deviation = 0.03,
        center = {0, 0},
        creation_distance = -0.6875,
        starting_frame_speed = 0.4,
        starting_frame_speed_deviation = 0.1
      },
      projectile_creation_distance = 0.65,
      range = 15,
      sound = heavygunshotsounds,
    },
    stack_size = 1
  },
  { -- Aircraft cannon
    type = "gun",
    name = "aircraft-cannon",
    icon = "__base__/graphics/icons/tank-cannon.png",
    icon_size = 64,
    hidden = true,
    subgroup = "gun",
    order = "z[tank]-a[cannon]",
    attack_parameters =
    {
      type = "projectile",
      ammo_category = "cannon-shell",
      cooldown = 40.0,
      movement_slow_down_factor = 0.2,
      projectile_creation_distance = 1.6,
      projectile_center = {-0.15625, -0.07812},
      range = 50,
      sound = tankcannonsound,
    },
    stack_size = 1
  },
  { -- Flying Fortress machine gun
    type = "gun",
    name = "flying-fortress-machine-gun",
    icon = "__base__/graphics/icons/submachine-gun.png",
    icon_size = 64,
    hidden = true,
    subgroup = "gun",
    order = "a[basic-clips]-c[aircraft-machine-gun]",
    attack_parameters = {
      type = "projectile",
      ammo_category = "bullet",
      cooldown = 2.5,
      movement_slow_down_factor = 0.2,
      shell_particle = {
        name = "shell-particle",
        direction_deviation = 0.1,
        speed = 0.8,
        speed_deviation = 0.03,
        center = {0, 0},
        creation_distance = -0.6875,
        starting_frame_speed = 0.4,
        starting_frame_speed_deviation = 0.1
      },
      projectile_creation_distance = 0.65,
      range = 40,
      sound = heavygunshotsounds,
    },
    stack_size = 1
  },
  { -- Flying Fortress rocket launcher
    type = "gun",
    name = "flying-fortress-rocket-launcher",
    icon = "__base__/graphics/icons/rocket-launcher.png",
    icon_size = 64,
    hidden = true,
    subgroup = "gun",
    order = "e[flying-fortress-rocket-launcher]",
    attack_parameters = {
      type = "projectile",
      ammo_category = "rocket",
      movement_slow_down_factor = 0.9,
      cooldown = 20,
      projectile_creation_distance = 0.6,
      range = 50,
      projectile_center = {-0.17, 0},
      sound = rocketlaunchersound,
    },
    stack_size = 1
  },
  { -- Napalm launcher
    type = "gun",
    name = "napalm-launcher",
    icon = "__base__/graphics/icons/flamethrower.png",
    icon_size = 64,
    hidden = true,
    subgroup = "gun",
    order = "e[napalm-launcher]",
    attack_parameters = {
      type = "stream",
      ammo_category = "flamethrower",
      cooldown = 0.5,
      movement_slow_down_factor = 0.6,
      projectile_creation_distance = 0.6,
      gun_barrel_length = 0.8,
      gun_center_shift = { 0, -1 },
      range = 25,
      min_range = 3,
      cyclic_sound = flamethrowersounds,
    },
    stack_size = 1
  },
-----------------------------------------------AMMO----------------------------------------------------
  { -- High explosive cannon shell
    type = "ammo",
    name = "high-explosive-cannon-shell",
    -- added due to 2.0 modding API changes
	ammo_category = "cannon-shell",
    icon = ICONPATH .. "high_explosive_shell_icon.png",
    icon_size = 64,
    flags = {},
    ammo_type = {
      category = "cannon-shell",
      target_type = "direction",
      action = {
        type = "direct",
        action_delivery = {
          type = "projectile",
          projectile = "high-explosive-cannon-projectile",
          starting_speed = 1,
          direction_deviation = 0.1,
          range_deviation = 0.1,
          max_range = 30,
          min_range = 5,
          source_effects = {
            type = "create-explosion",
            entity_name = "explosion-gunshot"
          },
        }
      },
    },
    subgroup = "ammo",
    order = "d[cannon-shell]-c[explosive]",
    stack_size = 200
  },
  { -- Napalm
    type = "ammo",
    name = "napalm",
    -- added due to 2.0 modding API changes
	ammo_category = "flamethrower",
    icon = ICONPATH .. "napalm-ammo.png",
    icon_size = 64,
    flags = {},
    ammo_type = {
      source_type = "vehicle",
      consumption_modifier = 1.5,
      category = "flamethrower",
      target_type = "position",
      clamp_position = true,
      action = {
        type = "direct",
        action_delivery = {
          type = "stream",
          stream = "napalm-flamethrower-fire-stream",
          --max_length = 30,
          --duration = 320,
        }
      }
    },
    magazine_size = 100,
    subgroup = "ammo",
    order = "e[napalm]",
    stack_size = 100
  },
-----------------------------------------------EQUIPMENT----------------------------------------------------
  { -- Aircraft energy shield
    type = "item",
    name = "aircraft-energy-shield",
    icon = ICONPATH .. "aircraft_energy_shield_icon.png",
    icon_size = 64,
     place_as_equipment_result = "aircraft-energy-shield",
    flags = {},
    subgroup = "equipment",
    order = "b[shield]-c[aircraft-energy-shield]",
    stack_size = 10,
    default_request_amount = 10,
  },
  { -- Aircraft afterburner
    type = "item",
    name = "aircraft-afterburner",
    icon = ICONPATH .. "aircraft_afterburner_icon.png",
    icon_size = 64,
     place_as_equipment_result = "aircraft-afterburner",
    flags = {},
    subgroup = "equipment",
    order = "e[engine]-a[aircraft-afterburner]",
    stack_size = 10,
    default_request_amount = 10,
  },
})
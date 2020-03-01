data:extend({
 { -- Gunship
    type = "item-with-entity-data",
    name = "gunship",
    icon = "__Aircraft__/graphics/Gunship_Icon.png",
	icon_size = 32,
    flags = {},
    subgroup = "transport",
	order = "b[personal-transport]-e[gunship]",
    place_result= "gunship",
    stack_size= 1,
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Cargo Plane
    type = "item-with-entity-data",
    name = "cargo-plane",
    icon = "__Aircraft__/graphics/Cargo_Plane_Icon.png",
	icon_size = 32,
    flags = {},
    subgroup = "transport",
	order = "b[personal-transport]-f[cargo-plane]",
    place_result= "cargo-plane",
    stack_size= 1,
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Jet
    type = "item-with-entity-data",
    name = "jet",
    icon = "__Aircraft__/graphics/Jet_Icon.png",
	icon_size = 32,
    flags = {},
    subgroup = "transport",
	order = "b[personal-transport]-g[jet]",
    place_result= "jet",
    stack_size= 1,
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Flying Fortress
    type = "item-with-entity-data",
    name = "flying-fortress",
    icon = "__Aircraft__/graphics/Flying_Fortress_Icon.png",
	icon_size = 32,
    flags = {},
    subgroup = "transport",
	order = "b[personal-transport]-h[flying-fortress]",
    place_result= "flying-fortress",
    stack_size= 1,
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Aircraft machine gun
    type = "gun",
    name = "aircraft-machine-gun",
    icon = "__base__/graphics/icons/submachine-gun.png",
	icon_size = 32,
    flags = {"hidden"},
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
      sound = make_heavy_gunshot_sounds(),
    },
    stack_size = 1
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Aircraft rocket launcher
    type = "gun",
    name = "aircraft-rocket-launcher",
    icon = "__base__/graphics/icons/explosive-rocket.png",
	icon_size = 32,
    flags = {"hidden"},
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
      sound =
      {
        {
          filename = "__base__/sound/fight/rocket-launcher.ogg",
          volume = 0.7
        }
      }
    },
    stack_size = 5
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Cargo plane machine gun
    type = "gun",
    name = "cargo-plane-machine-gun",
    icon = "__base__/graphics/icons/submachine-gun.png",
	icon_size = 32,
    flags = {"hidden"},
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
      sound = make_heavy_gunshot_sounds(),
    },
    stack_size = 1
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Aircraft cannon
    type = "gun",
    name = "aircraft-cannon",
    icon = "__base__/graphics/icons/explosive-cannon-shell.png",
	icon_size = 32,
    flags = {"hidden"},
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
      sound =
      {
        {
          filename = "__base__/sound/fight/tank-cannon.ogg",
          volume = 1.0
        }
      },
    },
    stack_size = 1
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- High explosive cannon shell
    type = "ammo",
    name = "high-explosive-cannon-shell",
    icon = "__Aircraft__/graphics/High_Explosive_Shell_Icon.png",
	icon_size = 32,
    flags = {},
    ammo_type =
    {
      category = "cannon-shell",
      target_type = "direction",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "projectile",
          projectile = "high-explosive-cannon-projectile",
          starting_speed = 1,
          direction_deviation = 0.1,
          range_deviation = 0.1,
          max_range = 30,
		  min_range = 5,
          source_effects =
          {
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
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Flying Fortress machine gun
    type = "gun",
    name = "flying-fortress-machine-gun",
    icon = "__base__/graphics/icons/submachine-gun.png",
	icon_size = 32,
    flags = {"hidden"},
    subgroup = "gun",
    order = "a[basic-clips]-c[aircraft-machine-gun]",
    attack_parameters =
    {
      type = "projectile",
      ammo_category = "bullet",
      cooldown = 2.5,
      movement_slow_down_factor = 0.2,
      shell_particle =
      {
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
      sound = make_heavy_gunshot_sounds(),
    },
    stack_size = 1
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Flying Fortress rocket launcher
    type = "gun",
    name = "flying-fortress-rocket-launcher",
    icon = "__base__/graphics/icons/explosive-rocket.png",
	icon_size = 32,
    flags = {"hidden"},
    subgroup = "gun",
    order = "e[flying-fortress-rocket-launcher]",
    attack_parameters =
    {
      type = "projectile",
      ammo_category = "rocket",
      movement_slow_down_factor = 0.9,
      cooldown = 20,
      projectile_creation_distance = 0.6,
      range = 50,
      projectile_center = {-0.17, 0},
      sound =
      {
        {
          filename = "__base__/sound/fight/rocket-launcher.ogg",
          volume = 0.75
        }
      }
    },
    stack_size = 1
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Napalm launcher
    type = "gun",
    name = "napalm-launcher",
    icon = "__base__/graphics/icons/flamethrower.png",
	icon_size = 32,
    flags = {"hidden"},
    subgroup = "gun",
    order = "e[napalm-launcher]",
    attack_parameters =
    {
      type = "stream",
      ammo_category = "flamethrower",
      cooldown = 0.5,
      movement_slow_down_factor = 0.6,
      projectile_creation_distance = 0.6,
      gun_barrel_length = 0.8,
      gun_center_shift = { 0, -1 },
      range = 25,
      min_range = 3,
      cyclic_sound =
      {
        begin_sound =
        {
          {
            filename = "__base__/sound/fight/flamethrower-start.ogg",
            volume = 0.7
          }
        },
        middle_sound =
        {
          {
            filename = "__base__/sound/fight/flamethrower-mid.ogg",
            volume = 0.7
          }
        },
        end_sound =
        {
          {
            filename = "__base__/sound/fight/flamethrower-end.ogg",
            volume = 0.7
          }
        }
      }
    },
    stack_size = 1
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[ { -- Cheat machine (DO NOT USE)
    type = "item-with-entity-data",
    name = "cheat-machine",
    icon = "__Aircraft__/graphics/Flying_Fortress_Icon.png",
	icon_size = 32,
    flags = {"hidden"},
    subgroup = "ammo",
    place_result= "cheat-machine",
    stack_size= 1,
  }, ]]
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Aircraft energy shield
	type = "item",
	name = "aircraft-energy-shield",
	icon = "__Aircraft__/graphics/Aircraft_Energy_Shield_Icon.png",
	icon_size = 32,
	placed_as_equipment_result = "aircraft-energy-shield",
	flags = {},
	subgroup = "equipment",
	order = "b[shield]-c[aircraft-energy-shield]",
	stack_size = 10,
	default_request_amount = 10,
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Aircraft afterburner
    type = "item",
    name = "aircraft-afterburner",
    icon = "__Aircraft__/graphics/Aircraft_Afterburner_Icon.png",
	icon_size = 32,
    placed_as_equipment_result = "aircraft-afterburner",
    flags = {},
    subgroup = "equipment",
    order = "e[engine]-a[aircraft-afterburner]",
    stack_size = 10,
	default_request_amount = 10,
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Napalm
    type = "ammo",
    name = "napalm",
    icon = "__base__/graphics/icons/flamethrower-ammo.png",
	icon_size = 32,
    flags = {},
    ammo_type =
	  {
        {
          source_type = "vehicle",
          consumption_modifier = 1.5,
          category = "flamethrower",
          target_type = "position",
          clamp_position = true,

          action =
          {
            type = "direct",
            action_delivery =
            {
              type = "stream",
              stream = "handheld-flamethrower-fire-stream",
              max_length = 30,
              duration = 320,
            }
          }
        }
      },
    magazine_size = 100,
    subgroup = "ammo",
    order = "e[napalm]",
    stack_size = 100
  }
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
})
data:extend({
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[ { -- Cheat Machine (DO NOT USE, BREAKS GAME HILARIOUSLY)
      type = "car",
      name = "cheat-machine",
      icon = "__Aircraft__/graphics/Flying_Fortress_Icon.png",
	  icon_size = 32,
      flags = {"placeable-neutral", "player-creation", "placeable-off-grid", "not-on-map"},
      minable = {mining_time = 1, result = "cheat-machine"},
      max_health = 1000000000,
			corpse = "medium-remnants",
			dying_explosion = "medium-explosion",
			energy_per_hit_point = 0.8,
			terrain_friction_modifier = 0,
			resistances =
    {
      {
        type = "fire",
        decrease = 100,
        percent = 100
      },
      {
        type = "physical",
        decrease = 100,
        percent = 100
      },
      {
        type = "impact",
        decrease = 100,
        percent = 100
      },
      {
        type = "explosion",
        decrease = 100,
        percent = 100
      },
      {
        type = "acid",
        decrease = 100,
        percent = 100
      }
    },
		collision_box = {{-0.9, -1.3}, {0.9, 1.3}},
		collision_mask = {},
		selection_box = {{-0.9, -1.3}, {0.9, 1.3}},
    effectivity = 2.3,
    braking_power = "3000kW",
    burner =
    {
      effectivity = 0.99,
      fuel_inventory_size = 1,
      smoke =
      {
        {
          name = "smoke",
          deviation = {0.25, 0.25},
          frequency = 50,
          position = {0, 1.5},
          starting_frame = 3,
          starting_frame_deviation = 5,
          starting_frame_speed = 0,
          starting_frame_speed_deviation = 5
        }
      }
    },
		consumption = "9001kW",
    friction = 0.001,
		light =
    {
      {
        type = "oriented",
        minimum_darkness = 0.3,
        picture =
        {
          filename = "__core__/graphics/light-cone.png",
          priority = "medium",
          scale = 2,
          width = 200,
          height = 200
        },
        shift = {-0.1, -12},
        size = 2,
        intensity = 0.8
      }
    },
		render_layer = "air-object", 
	  final_render_layer = "air-object",
		animation =
    {
			    filename = "__Aircraft__/graphics/Flying_Fortress_Spritesheet.png",
          priority = "high",
				  width = 224,
          height = 224,
          frame_count = 1,
          direction_count = 36,
					line_length = 6,
					line_height = 6,
          shift = {0, 0},
          max_advance = 1,
    },
      sound_no_fuel =
    {
      {
        filename = "__base__/sound/fight/tank-no-fuel-1.ogg",
        volume = 0.6
      },
    },
		  sound_minimum_speed = 0.15;
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound =
      {
        filename = "__Aircraft__/sounds/jet-loop.ogg",
        volume = 0.4
      },
      activate_sound =
      {
        filename = "__Aircraft__/sounds/jet-start.ogg",
        volume = 0.4
      },
      deactivate_sound =
      {
        filename = "__Aircraft__/sounds/jet-stop.ogg",
        volume = 0.4
      },
      match_speed_to_activity = false,
    },
			stop_trigger_speed = 0.1,
      acceleration_per_energy = 1,
      breaking_speed = 1,
			open_sound = { filename = "__base__/sound/car-door-open.ogg", volume=0.7 },
      close_sound = { filename = "__base__/sound/car-door-close.ogg", volume = 0.7 },
      rotation_speed = 1,
			tank_driving = true,
      weight = 0.000001,
      inventory_size = 15,
			guns = { "flying-fortress-machine-gun", "aircraft-cannon", "flying-fortress-rocket-launcher", "napalm-launcher"},
  }, ]]
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- High explosive cannon projectile
    type = "projectile",
    name = "high-explosive-cannon-projectile",
    flags = {"not-on-map"},
    collision_box = {{-0.05, -1.1}, {0.05, 1.1}},
    acceleration = 0,
    direction_only = true,
    piercing_damage = 125,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            damage = { amount = 275, type = "physical"}
          }
        }
      }
    },
    final_action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-entity",
            entity_name = "big-explosion",
            check_buildability = true
          },
          {
            type = "nested-result",
            action =
            {
              type = "area",
              radius = 6,
              action_delivery =
              {
                type = "instant",
                target_effects =
                {
                  {
                    type = "damage",
                    damage = {amount = 325, type = "explosion"}
                  },
                  {
                    type = "create-entity",
                    entity_name = "big-explosion"
                  }
                }
              }
            }
          }
        }
      }
    },
    animation =
    {
      filename = "__base__/graphics/entity/bullet/bullet.png",
      frame_count = 1,
      width = 3,
      height = 50,
      priority = "high"
    },
 },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
})

-- list of planes with additional configuration parameters
-- current parameters: 
-- volume: jet sound volume 
-- belt_immunity: set false if belt immunity option should not affect this plane
local planes = {
  ["gunship"] = {volume = 0.4, belt_immunity = true}, 
  ["cargo-plane"] = {volume = 0.4, belt_immunity = true},
  ["jet"] = {volume = 0.4, belt_immunity = true},
  ["flying-fortress"] = {volume = 0.4, belt_immunity = true},
}

-- add in planes
data:extend({
 { -- Gunship with Car sound
    type = "car",
    name = "gunship",
    icon = "__Aircraft__/graphics/Gunship_Icon.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation", "placeable-off-grid"},
    has_belt_immunity = false,
    minable = {mining_time = 1, result = "gunship"},
    max_health = 500,
    corpse = "medium-remnants",
    dying_explosion = "medium-explosion",
    energy_per_hit_point = 0.5,
    terrain_friction_modifier = 0,
    resistances =
    {
      {
        type = "fire",
        decrease = 2,
        percent = 50
      },
      {
        type = "physical",
        decrease = 2,
        percent = 30
      },
      {
        type = "impact",
        decrease = 10,
        percent = 60
      },
      {
        type = "explosion",
        decrease = 2,
        percent = 30
      },
      {
        type = "acid",
        decrease = 60,
        percent = 20
      }
    },
		collision_box = {{-0.9, -1.3}, {0.9, 1.3}},
		collision_mask = {},
		selection_box = {{-0.9, -1.3}, {0.9, 1.3}},
	selection_priority = 60,
    effectivity = 0.7,
    braking_power = "450kW",
    burner =
    {
      effectivity = 1,
      fuel_inventory_size = 2,
      smoke =
      {
        {
          name = "smoke",
          deviation = {0.25, 0.25},
          frequency = 50,
          position = {0, 1.5},
          starting_frame = 3,
          starting_frame_deviation = 5,
          starting_frame_speed = 0,
          starting_frame_speed_deviation = 5
        }
      }
    },
		consumption = "650kW",
    friction = 0.003,
		light =
    {
      {
        type = "oriented",
        minimum_darkness = 0.3,
        picture =
        {
          filename = "__core__/graphics/light-cone.png",
          priority = "medium",
          scale = 2,
          width = 200,
          height = 200
        },
        shift = {-0.1, -12},
        size = 2,
        intensity = 0.8
      }
    },
		render_layer = "air-object", 
	  final_render_layer = "air-object",
		animation =
    {
			    filename = "__Aircraft__/graphics/Gunship_Spritesheet.png",
          priority = "high",
				  width = 224,
          height = 224,
          frame_count = 1,
          direction_count = 36,
					line_length = 6,
					line_height = 6,
          shift = {0, 0},
          max_advance = 1,
    },
      sound_no_fuel =
    {
      {
        filename = "__base__/sound/fight/tank-no-fuel-1.ogg",
        volume = 0.6
      },
    },
		  sound_minimum_speed = 0.15;
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/car-engine.ogg",
        volume = 0.6
      },
      activate_sound =
      {
        filename = "__base__/sound/car-engine-start.ogg",
        volume = 0.6
      },
      deactivate_sound =
      {
        filename = "__base__/sound/car-engine-stop.ogg",
        volume = 0.6
      },
      match_speed_to_activity = true,
    },
	  stop_trigger_speed = 0.2,
      acceleration_per_energy = 0.35,
      breaking_speed = 0.09,
	  open_sound = { filename = "__base__/sound/car-door-open.ogg", volume=0.7 },
      close_sound = { filename = "__base__/sound/car-door-close.ogg", volume = 0.7 },
      rotation_speed = 0.01,
	  tank_driving = true,
      weight = 750,
      inventory_size = 30,
	  guns = { "aircraft-machine-gun", "aircraft-rocket-launcher"},
	  equipment_grid="gunship-equipment-grid",
  },
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Cargo Plane with Car sound
    type = "car",
    name = "cargo-plane",
    icon = "__Aircraft__/graphics/Cargo_Plane_Icon.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation", "placeable-off-grid"},
    has_belt_immunity = false,
    minable = {mining_time = 1, result = "cargo-plane"},
    max_health = 500,
    corpse = "medium-remnants",
    dying_explosion = "medium-explosion",
    energy_per_hit_point = 0.5,
    terrain_friction_modifier = 0,
    resistances =
    {
      {
        type = "fire",
        decrease = 2,
        percent = 50
      },
      {
        type = "physical",
        decrease = 2,
        percent = 30
      },
      {
        type = "impact",
        decrease = 5,
        percent = 60
      },
      {
        type = "explosion",
        decrease = 2,
        percent = 30
      },
      {
        type = "acid",
        decrease = 60,
        percent = 20
      }
    },
		collision_box = {{-0.9, -1.3}, {0.9, 1.3}},
		collision_mask = {},
		selection_box = {{-0.9, -1.3}, {0.9, 1.3}},
	selection_priority = 60,
    effectivity = 1.0,
    braking_power = "650kW",
    burner =
    {
      effectivity = 1,
      fuel_inventory_size = 6,
      smoke =
      {
        {
          name = "smoke",
          deviation = {0.25, 0.25},
          frequency = 50,
          position = {0, 1.5},
          starting_frame = 3,
          starting_frame_deviation = 5,
          starting_frame_speed = 0,
          starting_frame_speed_deviation = 5
        }
      }
    },
		consumption = "1250kW",
    friction = 0.010,
		light =
    {
      {
        type = "oriented",
        minimum_darkness = 0.3,
        picture =
        {
          filename = "__core__/graphics/light-cone.png",
          priority = "medium",
          scale = 2,
          width = 200,
          height = 200
        },
        shift = {-0.1, -12},
        size = 2,
        intensity = 0.8
      }
    },
		render_layer = "air-object", 
	  final_render_layer = "air-object",
		animation =
    {
			    filename = "__Aircraft__/graphics/Cargo_Plane_Spritesheet.png",
          priority = "high",
				  width = 224,
          height = 224,
          frame_count = 1,
          direction_count = 36,
					line_length = 6,
					line_height = 6,
          shift = {0, 0},
          max_advance = 1,
    },
      sound_no_fuel =
    {
      {
        filename = "__base__/sound/fight/tank-no-fuel-1.ogg",
        volume = 0.6
      },
    },
		  sound_minimum_speed = 0.15;
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/car-engine.ogg",
        volume = 0.6
      },
      activate_sound =
      {
        filename = "__base__/sound/car-engine-start.ogg",
        volume = 0.6
      },
      deactivate_sound =
      {
        filename = "__base__/sound/car-engine-stop.ogg",
        volume = 0.6
      },
      match_speed_to_activity = true,
    },
			stop_trigger_speed = 0.2,
      acceleration_per_energy = 0.15,
      breaking_speed = 0.15,
			open_sound = { filename = "__base__/sound/car-door-open.ogg", volume=0.7 },
      close_sound = { filename = "__base__/sound/car-door-close.ogg", volume = 0.7 },
      rotation_speed = 0.006,
			tank_driving = true,
      weight = 3500,
      inventory_size = 120,
			guns = { "cargo-plane-machine-gun"},
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Jet with Car sound
    type = "car",
    name = "jet",
    icon = "__Aircraft__/graphics/Jet_Icon.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation", "placeable-off-grid"},
    has_belt_immunity = false,
    minable = {mining_time = 1, result = "jet"},
    max_health = 250,
    corpse = "medium-remnants",
    dying_explosion = "medium-explosion",
    energy_per_hit_point = 0.5,
    terrain_friction_modifier = 0,
    resistances =
    {
      {
        type = "fire",
        decrease = 0,
        percent = 100
      },
      {
        type = "physical",
        decrease = 0,
        percent = 30
      },
      {
        type = "impact",
        decrease = 0,
        percent = 60
      },
      {
        type = "explosion",
        decrease = 1,
        percent = 30
      },
      {
        type = "acid",
        decrease = 60,
        percent = 20
      }
    },
		collision_box = {{-0.9, -1.3}, {0.9, 1.3}},
		collision_mask = {},
		selection_box = {{-0.9, -1.3}, {0.9, 1.3}},
	selection_priority = 60,
    effectivity = 0.9,
    braking_power = "2000kW",
    burner =
    {
      effectivity = 1,
      fuel_inventory_size = 3,
      smoke =
      {
        {
          name = "smoke",
          deviation = {0.25, 0.25},
          frequency = 50,
          position = {0, 1.5},
          starting_frame = 3,
          starting_frame_deviation = 5,
          starting_frame_speed = 0,
          starting_frame_speed_deviation = 5
        }
      }
    },
		consumption = "850kW",
    friction = 0.001,
		light =
    {
      {
        type = "oriented",
        minimum_darkness = 0.3,
        picture =
        {
          filename = "__core__/graphics/light-cone.png",
          priority = "medium",
          scale = 2,
          width = 200,
          height = 200
        },
        shift = {-0.1, -12},
        size = 2,
        intensity = 0.8
      }
    },
		render_layer = "air-object", 
	  final_render_layer = "air-object",
		animation =
    {
			    filename = "__Aircraft__/graphics/Jet_Spritesheet.png",
          priority = "high",
				  width = 224,
          height = 224,
          frame_count = 1,
          direction_count = 36,
					line_length = 6,
					line_height = 6,
          shift = {0, 0},
          max_advance = 1,
    },
      sound_no_fuel =
    {
      {
        filename = "__base__/sound/fight/tank-no-fuel-1.ogg",
        volume = 0.6
      },
    },
		  sound_minimum_speed = 0.15;
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/car-engine.ogg",
        volume = 0.6
      },
      activate_sound =
      {
        filename = "__base__/sound/car-engine-start.ogg",
        volume = 0.6
      },
      deactivate_sound =
      {
        filename = "__base__/sound/car-engine-stop.ogg",
        volume = 0.6
      },
      match_speed_to_activity = true,
    },
			stop_trigger_speed = 0.2,
      acceleration_per_energy = 0.80,
      breaking_speed = 0.03,
			open_sound = { filename = "__base__/sound/car-door-open.ogg", volume=0.7 },
      close_sound = { filename = "__base__/sound/car-door-close.ogg", volume = 0.7 },
      rotation_speed = 0.01,
			tank_driving = true,
      weight = 500,
      inventory_size = 5,
			guns = { "aircraft-machine-gun", "aircraft-rocket-launcher", "napalm-launcher"},
	  equipment_grid = "jet-equipment-grid",
  },
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 { -- Flying Fortress with Car sound
    type = "car",
    name = "flying-fortress",
    icon = "__Aircraft__/graphics/Flying_Fortress_Icon.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation", "placeable-off-grid"},
    has_belt_immunity = false,
    minable = {mining_time = 1, result = "flying-fortress"},
    max_health = 2000,
    corpse = "medium-remnants",
    dying_explosion = "medium-explosion",
    energy_per_hit_point = 0.8,
    terrain_friction_modifier = 0,
    resistances =
    {
      {
        type = "fire",
        decrease = 10,
        percent = 50
      },
      {
        type = "physical",
        decrease = 7,
        percent = 30
      },
      {
        type = "impact",
        decrease = 20,
        percent = 60
      },
      {
        type = "explosion",
        decrease = 10,
        percent = 30
      },
      {
        type = "acid",
        decrease = 60,
        percent = 20
      }
    },
		collision_box = {{-0.9, -1.3}, {0.9, 1.3}},
		collision_mask = {},
		selection_box = {{-0.9, -1.3}, {0.9, 1.3}},
	selection_priority = 60,
    effectivity = 2.3,
    braking_power = "850kW",
    burner =
    {
      effectivity = 1,
      fuel_inventory_size = 4,
      smoke =
      {
        {
          name = "smoke",
          deviation = {0.25, 0.25},
          frequency = 50,
          position = {0, 1.5},
          starting_frame = 3,
          starting_frame_deviation = 5,
          starting_frame_speed = 0,
          starting_frame_speed_deviation = 5
        }
      }
    },
		consumption = "1850kW",
    friction = 0.015,
		light =
    {
      {
        type = "oriented",
        minimum_darkness = 0.3,
        picture =
        {
          filename = "__core__/graphics/light-cone.png",
          priority = "medium",
          scale = 2,
          width = 200,
          height = 200
        },
        shift = {-0.1, -12},
        size = 2,
        intensity = 0.8
      }
    },
		render_layer = "air-object", 
	  final_render_layer = "air-object",
		animation =
    {
			    filename = "__Aircraft__/graphics/Flying_Fortress_Spritesheet.png",
          priority = "high",
				  width = 224,
          height = 224,
          frame_count = 1,
          direction_count = 36,
					line_length = 6,
					line_height = 6,
          shift = {0, 0},
          max_advance = 1,
    },
      sound_no_fuel =
    {
      {
        filename = "__base__/sound/fight/tank-no-fuel-1.ogg",
        volume = 0.6
      },
    },
		  sound_minimum_speed = 0.15;
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/car-engine.ogg",
        volume = 0.6
      },
      activate_sound =
      {
        filename = "__base__/sound/car-engine-start.ogg",
        volume = 0.6
      },
      deactivate_sound =
      {
        filename = "__base__/sound/car-engine-stop.ogg",
        volume = 0.6
      },
      match_speed_to_activity = true,
    },
			stop_trigger_speed = 0.1,
      acceleration_per_energy = 0.30,
      breaking_speed = 0.001,
			open_sound = { filename = "__base__/sound/car-door-open.ogg", volume=0.7 },
      close_sound = { filename = "__base__/sound/car-door-close.ogg", volume = 0.7 },
      rotation_speed = 0.004,
			tank_driving = true,
      weight = 3000,
      inventory_size = 20,
			guns = { "flying-fortress-machine-gun", "aircraft-cannon", "flying-fortress-rocket-launcher"},
	  equipment_grid = "flying-fortress-equipment-grid",
  },
 })

-- toggle startup options if necessary
for k, v in pairs(planes) do
  local plane = data.raw["car"][k]
  if plane then
    -- insert jet sounds
    if settings.startup["aircraft-sound-setting"].value == true then
      plane.working_sound = {
        sound =
        {
          filename = "__Aircraft__/sounds/jet-loop.ogg",
          volume = v.volume
        },
        activate_sound =
        {
          filename = "__Aircraft__/sounds/jet-start.ogg",
          volume = v.volume
        },
        deactivate_sound =
        {
          filename = "__Aircraft__/sounds/jet-stop.ogg",
          volume = v.volume
        },
        match_speed_to_activity = false,
      }
    end
    
    -- insert belt immunity
    if settings.startup["aircraft-belt-immunity"].value == true then
      plane.has_belt_immunity = v.belt_immunity
    end
  end
end


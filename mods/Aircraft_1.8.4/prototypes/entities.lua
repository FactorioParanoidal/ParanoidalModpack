local ICONPATH = "__Aircraft__/graphics/icons/"
local ENTITYPATH = "__Aircraft__/graphics/entity/"

local function addcommonanimlines(anim)
  for _,layer in pairs(anim.layers) do
    layer.width, layer.height = 224, 224
    layer.hr_version.width, layer.hr_version.height = 448, 448
    layer.hr_version.scale = 0.5
    layer.frame_count, layer.hr_version.frame_count = 1, 1
    layer.direction_count, layer.hr_version.direction_count = 36, 36
    layer.line_length, layer.hr_version.line_length = 6, 6
    layer.max_advance, layer.hr_version.max_advance = 1, 1
  end
  return anim
end

local function airplaneAnimation(name)
  local anim = {}
  anim.layers = {
    {
      filename = ENTITYPATH .. name .. "/" .. name .. "_spritesheet.png",
      shift = util.by_pixel(9, -10),
      hr_version = {
        filename = ENTITYPATH .. name .. "/hr-" .. name .. "_spritesheet.png",
        shift = util.by_pixel(9, -10),
      }
    },
    {
      filename = ENTITYPATH .. name .. "/" .. name .. "_spritesheet-shadow.png",
      shift = util.by_pixel(54, 35),
      draw_as_shadow = true,
      hr_version = {
        filename = ENTITYPATH .. name .. "/hr-" .. name .. "_spritesheet-shadow.png",
        shift = util.by_pixel(54, 35),
        draw_as_shadow = true,
      }
    }
  }
  addcommonanimlines(anim)
  return anim
end

local function airplaneLightAnimation(name)
  local anim = {}
  anim.layers = {
    {
      filename = ENTITYPATH .. name .. "/" .. name .. "_spritesheet-light.png",
      shift = util.by_pixel(9, -10),
      draw_as_light = true,
      hr_version = {
        filename = ENTITYPATH .. name .. "/hr-" .. name .. "_spritesheet-light.png",
        shift = util.by_pixel(9, -10),
        draw_as_light = true,
      }
    }
  }
  addcommonanimlines(anim)
  return anim
end

local function lightdef(shift, distance, intensity)
  return {
    type = "oriented",
    minimum_darkness = 0.3,
    picture = {
      filename = ENTITYPATH .. "particle/hr-light-cone.png",
      scale = 0.5,
      width = 800,
      height = 800
    },
    shift = util.by_pixel(shift, distance),
    size = 2,
    intensity = intensity/10,
  }
end

local function smokedef(shift, radius, height)
  return {
    --name = "smoke",
    name = "aircraft-trail",
    --frequency = 200,
    frequency = 60,
    --deviation = util.by_pixel(2, 2), --position randomness
    deviation = util.by_pixel(0, 0), --position randomness
    position = util.by_pixel(shift, radius),
    height = height/32,
    starting_frame = 3,
    starting_frame_deviation = 5,
    starting_frame_speed = 5,
    starting_frame_speed_deviation = 5,
  }
end

local jetsounds = {
  sound = { filename = "__Aircraft__/sounds/jet-loop.ogg", volume = 0.5 },
  --activate_sound = { filename = "__Aircraft__/sounds/jet-start.ogg", volume = 0.5 },
  deactivate_sound = { filename = "__Aircraft__/sounds/jet-stop.ogg", volume = 0.5 },
  --match_speed_to_activity = false,
  match_speed_to_activity = true,
  fade_in_ticks = 30,
}

local carsounds = {
  sound = { filename = "__base__/sound/car-engine.ogg", volume = 0.6 },
  activate_sound = { filename = "__base__/sound/car-engine-start.ogg", volume = 0.6 },
  deactivate_sound = { filename = "__base__/sound/car-engine-stop.ogg", volume = 0.6 },
  match_speed_to_activity = true,
}

---add in one function all the common parameteres between aircrafts
local function add_recurrent_params(craft)
  craft.icon_size = 64
  craft.flags = {"placeable-neutral", "player-creation", "placeable-off-grid"}
  craft.has_belt_immunity = settings.startup["aircraft-belt-immunity"].value or false
  craft.dying_explosion = "medium-explosion"
  craft.terrain_friction_modifier = 0
  craft.collision_box = {{-0.9, -1.3}, {0.9, 1.3}}
  craft.collision_mask = {}
  craft.selection_box = {{-0.9, -1.3}, {0.9, 1.3}}
  craft.selection_priority = 60
  craft.render_layer = "air-object"
  craft.final_render_layer = "air-object"
  craft.tank_driving = true
  craft.sound_no_fuel = { { filename = "__base__/sound/fight/tank-no-fuel-1.ogg", volume = 0.6 } }
  craft.vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 }
  craft.working_sound = settings.startup["aircraft-sound-setting"].value and jetsounds or carsounds
  craft.sound_minimum_speed = 0.19
  craft.sound_scaling_ratio = 0.06
  craft.open_sound = { filename = "__base__/sound/car-door-open.ogg", volume = 0.7 }
  craft.close_sound = { filename = "__base__/sound/car-door-close.ogg", volume = 0.7 }
  craft.mined_sound = {filename = "__core__/sound/deconstruct-large.ogg",volume = 0.8}
  craft.create_ghost_on_death = false
  --craft.alert_icon_shift = {0,-1}
  craft.minimap_representation = {
    filename = ICONPATH .. "aircraft-minimap-representation.png",
    flags = {"icon"},
    size = {40, 40},
    scale = 0.5
  }
  craft.selected_minimap_representation = {
    filename = ICONPATH .. "aircraft-minimap-representation-selected.png",
    flags = {"icon"},
    size = {40, 40},
    scale = 0.5
  }
  --craft.immune_to_tree_impacts = true --craft.immune_to_rock_impacts = true
  --craft.created_smoke = { smoke_name = "smoke" }
end

local function resist(type, decrease, percent)
  return {
    type = type,
    decrease = decrease,
    percent = percent
  }
end

local gunship = { -- Gunship with Car sound
    type = "car",
    name = "gunship",
    icon = ICONPATH .. "gunship_icon.png",
    minable = {mining_time = 1, result = "gunship"},
    light = { lightdef(-43, -416, 5), lightdef(43, -416, 5) },
    animation = airplaneAnimation("gunship"),
    light_animation = airplaneLightAnimation("gunship"),
    corpse = "medium-remnants",
        ----SPECS
    max_health = 500,
    energy_per_hit_point = 0.5,
    resistances = {
      resist("fire",     2,  50),
      resist("physical", 2,  30),
      resist("impact",   10, 60),
      resist("explosion",10, 30),
      resist("acid",     60, 20),
    },
    inventory_size = 30,
    guns = { "aircraft-machine-gun", "aircraft-rocket-launcher"},
    equipment_grid = "gunship-equipment-grid",
        --MOVEMENT
    effectivity = 0.7,
    braking_power = "450kW",
    burner = {
      fuel_inventory_size = 2,
      smoke = { smokedef(-16, 60, 38), smokedef(16, 60, 38) }
    },
    consumption = "650kW",
    friction = 0.003,
    stop_trigger_speed = 0.2,
    acceleration_per_energy = 0.35,
    breaking_speed = 0.09,
    rotation_speed = 0.01,
    weight = 750,
  }
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local cargo_plane = { -- Cargo Plane with Car sound
    type = "car",
    name = "cargo-plane",
    icon = ICONPATH .. "cargo_plane_icon.png",
    minable = {mining_time = 1, result = "cargo-plane"},
    light = { lightdef(0, -416, 8) },
    animation = airplaneAnimation("cargo_plane"),
    light_animation = airplaneLightAnimation("cargo_plane"),
    corpse = "medium-remnants",
        --SPECS
    max_health = 500,
    energy_per_hit_point = 0.5,
    resistances = {
      resist("fire",      2, 50),
      resist("physical",  2, 30),
      resist("impact",    5, 60),
      resist("explosion", 2, 30),
      resist("acid",     60, 20),
    },
    inventory_size = 120,
    guns = { "cargo-plane-machine-gun"},
        --MOVEMENT
    effectivity = 1,
    braking_power = "650kW",
    burner = {
      fuel_inventory_size = 6,
      smoke = { smokedef(0, 40, 36) }
    },
    consumption = "1250kW",
    friction = 0.010,
    stop_trigger_speed = 0.2,
    acceleration_per_energy = 0.15,
    breaking_speed = 0.15,
    rotation_speed = 0.006,
    weight = 3500,
  }
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local jet = { -- Jet with Car sound
    type = "car",
    name = "jet",
    icon = ICONPATH .. "jet_icon.png",
    minable = {mining_time = 1, result = "jet"},
    light = { lightdef(-22, -416, 5), lightdef(22, -416, 5) },
    animation = airplaneAnimation("jet"),
    light_animation = airplaneLightAnimation("jet"),
    corpse = "medium-remnants",
        --SPECS
    max_health = 250,
    energy_per_hit_point = 0.5,
    resistances = {
      resist("fire",      0, 100),
      resist("physical",  0, 30),
      resist("impact",    0, 60),
      resist("explosion", 1, 30),
      resist("acid",     60, 20),
    },
    inventory_size = 5,
    guns = { "aircraft-machine-gun", "aircraft-rocket-launcher", "napalm-launcher"},
    equipment_grid = "jet-equipment-grid",
        --MOVEMENT
    effectivity = 0.9,
    braking_power = "2000kW",
    burner = {
      fuel_inventory_size = 4,
      smoke = { smokedef(0, 62, 38) }
    },
    consumption = "850kW",
    friction = 0.001,
    stop_trigger_speed = 0.2,
    acceleration_per_energy = 0.80,
    breaking_speed = 0.03,
    rotation_speed = 0.01,
    weight = 500,
  }
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local flying_fortress = { -- Flying Fortress with Car sound
    type = "car",
    name = "flying-fortress",
    icon = ICONPATH .. "flying_fortress_icon.png",
    minable = {mining_time = 1, result = "flying-fortress"},
    light = { lightdef(-22, -416, 5), lightdef(22, -416, 5) },
    animation = airplaneAnimation("flying_fortress"),
    light_animation = airplaneLightAnimation("flying_fortress"),
    corpse = "medium-remnants",
        --SPECS
    max_health = 2000,
    energy_per_hit_point = 0.8,
    resistances = {
      resist("fire",      0, 100),
      resist("physical",  0, 30),
      resist("impact",    0, 60),
      resist("explosion", 1, 30),
      resist("acid",     60, 20),
    },
    inventory_size = 20,
    guns = { "flying-fortress-machine-gun", "aircraft-cannon", "flying-fortress-rocket-launcher"},
    equipment_grid = "flying-fortress-equipment-grid",
        --MOVEMENT
    effectivity = 2.3,
    braking_power = "850kW",
    burner = {
      fuel_inventory_size = 4,
      smoke = { smokedef(0, 65, 38) }
    },
    consumption = "1850kW",
    friction = 0.015,
    stop_trigger_speed = 0.1,
    acceleration_per_energy = 0.30,
    breaking_speed = 0.001,
    rotation_speed = 0.004,
    weight = 3000,
  }

add_recurrent_params(gunship)
add_recurrent_params(cargo_plane)
add_recurrent_params(jet)
add_recurrent_params(flying_fortress)

data:extend({
  gunship, cargo_plane, jet, flying_fortress
})

flib_data_util=require("__flib__.data-util")

local ICONPATH = "__Aircraft-space-age__/graphics/icons/"
local ENTITYPATH = "__Aircraft-space-age__/graphics/entity/"

local function addcommonanimlines(anim)
  for _,layer in pairs(anim.layers) do
    layer.width, layer.height = 448, 448
    layer.scale = 0.5
    layer.frame_count = 1, 1
    layer.direction_count = 36, 36
    layer.line_length = 6, 6
    layer.max_advance = 1, 1
  end
  return anim
end

local function airplaneAnimation(name)
  local anim = {}
  anim.layers = {
    {
      filename = ENTITYPATH .. name .. "/hr-" .. name .. "_spritesheet.png",
      shift = util.by_pixel(9, -10),
    },
    {
      filename = ENTITYPATH .. name .. "/hr-" .. name .. "_spritesheet-shadow.png",
      shift = util.by_pixel(54, 35),
      draw_as_shadow = true,
    }
  }
  if mods["AircraftRealism"] then --Moves shadows closer to aircraft sprite when "AircraftRealism" is active, creating illusion of aircraft being closer to the ground 
    anim.layers[2].shift = util.by_pixel(0, 0)
  end
  addcommonanimlines(anim)
  return anim
end

local function airplaneLightAnimation(name)
  local anim = {}
  anim.layers = {
    {
      filename = ENTITYPATH .. name .. "/hr-" .. name .. "_spritesheet-light.png",
      shift = util.by_pixel(9, -10),
      draw_as_light = true,
    }
  }
  addcommonanimlines(anim)
  return anim
end

-- Updated collision mask definition for Factorio 2.0
local function getCollisionMask()
  return {
    "object-layer",  -- Basic collision with objects
    "player-layer",  -- Collision with players
    "train-layer"    -- Collision with trains
  }
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
  sound = { filename = "__Aircraft-space-age__/sounds/jet-loop.ogg", volume = 0.3 },
  --activate_sound = { filename = "__Aircraft-space-age__/sounds/jet-start.ogg", volume = 0.3 },
  deactivate_sound = { filename = "__Aircraft-space-age__/sounds/jet-stop.ogg", volume = 0.3 },
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

---add in one function all the common parameters between aircrafts
local function add_recurrent_params(craft)
  craft.icon_size = 64
  craft.flags = {"placeable-neutral", "player-creation", "placeable-off-grid"}
  -- Overriding the "car" default disables acid puddle damage.
  craft.trigger_target_mask = { "common" }
  craft.has_belt_immunity = settings.startup["aircraft-belt-immunity"].value or false
  craft.dying_explosion = "medium-explosion"
  craft.terrain_friction_modifier = 0
  craft.collision_box = {{-0.9, -1.3}, {0.9, 1.3}}
  -- Original
  --craft.collision_mask = getCollisionMask() -- Updated collision mask
  -- added due to 2.0 modding API changes
  if not mods["AircraftRealism"] then
    craft.collision_mask = { layers = {} } 
  end
  
  craft.selection_box = {{-0.9, -1.3}, {0.9, 1.3}}
  craft.selection_priority = 60
  craft.render_layer = "air-object"
  craft.final_render_layer = "air-object"
  if settings.startup["disable-tank-controls"].value==false then
    craft.tank_driving = true
  else
    craft.tank_driving = false
  end
  craft.sound_no_fuel = { { filename = "__base__/sound/fight/tank-no-fuel-1.ogg", volume = 0.6 } }
  craft.vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 }
  craft.working_sound = settings.startup["aircraft-sound-setting"].value and jetsounds or carsounds
  craft.sound_minimum_speed = 0.19
  craft.sound_scaling_ratio = 0.06
  craft.open_sound = { filename = "__base__/sound/car-door-open.ogg", volume = 0.7 }
  craft.close_sound = { filename = "__base__/sound/car-door-close.ogg", volume = 0.7 }
  craft.mined_sound = {filename = "__core__/sound/deconstruct-large.ogg",volume = 0.8}
  craft.energy_source.fuel_categories=data.raw["car"]["car"].energy_source.fuel_categories
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
  local fuel_multiplier=settings.startup["fuel-consumption-multiplier"].value
  if  fuel_multiplier~= 1 then
    local val,suffix=flib_data_util.get_energy_value(craft.consumption)
    craft.consumption=val*fuel_multiplier .. suffix
    craft.effectivity=craft.effectivity/fuel_multiplier
  end
  
  
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
    --inventory_size = 30,
    inventory_size = 30,
    guns = { "aircraft-machine-gun", "aircraft-rocket-launcher"},
    equipment_grid = "gunship-equipment-grid",
        --MOVEMENT
    effectivity = 0.7,
    braking_power = "450kW",
    energy_source = {
      type = "burner",
      fuel_inventory_size = 4,
      smoke = { smokedef(-16, 60, 38), smokedef(16, 60, 38) }
    },
    consumption = "650kW",
    --consumption = "45MW",
    friction = 0.003,
    stop_trigger_speed = 0.2,
    acceleration_per_energy = 0.35,
    breaking_speed = 0.09,
    rotation_speed = 0.01,
    weight = 750,
    allow_remote_driving=true,
    trash_inventory_size=10,

  }

if settings.startup["use-old-stats"].value==true then
    --gunship.inventory_size = 30
    --gunship.effectivity=0.7
    --gunship.consumption = "650kW"
    --gunship.acceleration_per_energy = 0.35
  end

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
    energy_source = {
      type = "burner",
      fuel_inventory_size = 10,
      smoke = { smokedef(0, 40, 36) }
    },
    consumption = "1250kW",
    --consumption = "85MW",
    friction = 0.01,
    stop_trigger_speed = 0.2,
    acceleration_per_energy = 0.15,
    breaking_speed = 0.15,
    rotation_speed = 0.006,
    weight = 3500,
    allow_remote_driving = true,
    trash_inventory_size = 10,
  }
if settings.startup["use-old-stats"].value==true then
  --cargo_plane.inventory_size = 120
  --cargo_plane.effectivity=1
  --cargo_plane.consumption = "1250kW"
  --cargo_plane.acceleration_per_energy=0.15
end
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
    energy_source = {
      type = "burner",
      fuel_inventory_size = 8,
      smoke = { smokedef(0, 62, 38) }
    },
    consumption = "850kW",
    --consumption= "65MW", --All aircraft will have consumption multiplied by 100.
    friction = 0.001,
    stop_trigger_speed = 0.2,
    acceleration_per_energy = 0.80,
    breaking_speed = 0.03,
    rotation_speed = 0.01,
    --weight = 50000,
    weight = 500,
    allow_remote_driving = true,
    trash_inventory_size = 10,

  }

if settings.startup["use-old-stats"].value==true then
  --jet.inventory_size = 5
  --jet.effectivity=0.9
  --jet.consumption = "850kW"
  --jet.acceleration_per_energy=0.8
  --jet.weight=500
end


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
    --inventory_size = 20,
    inventory_size = 20,
    guns = { "flying-fortress-machine-gun", "aircraft-cannon", "flying-fortress-rocket-launcher"},
    equipment_grid = "flying-fortress-equipment-grid",
        --MOVEMENT
    effectivity = 2.3,
    braking_power = "850kW",
	energy_source = {
      type = "burner",
      fuel_inventory_size = 8,
      smoke = { smokedef(0, 65, 38) }
    },
    consumption = "1850kW",
    --consumption = "130MW",
    friction = 0.015,
    stop_trigger_speed = 0.1,
    acceleration_per_energy = 0.30,
    breaking_speed = 0.001,
    rotation_speed = 0.004,
    weight = 3000,
    allow_remote_driving=true,
    trash_inventory_size=10,
    
  }
if settings.startup["use-old-stats"].value==true then
    --flying_fortress.inventory_size = 20
    --flying_fortress.effectivity=2.3
    --flying_fortress.acceleration_per_energy=0.30
  end


add_recurrent_params(gunship)
add_recurrent_params(cargo_plane)
add_recurrent_params(jet)
add_recurrent_params(flying_fortress)

data:extend({
  gunship, cargo_plane, jet, flying_fortress
})
Aircraft_List= {"gunship", "cargo-plane", "jet", "flying-fortress" } --List of aircraft to apply following transformations to
if mods["space-age"] and settings.startup["lock-surfaces-space-age"].value==true then --Add surface conditions if space age enabled
  
  for i,entity in ipairs(Aircraft_List) do
    data.raw["car"][entity].surface_conditions =
    {
      {
        property = "pressure",
        min = 700,
        
      },
      {
        property = "gravity",
        max = 20,
        
      }
    }
  end
end

if mods["AircraftRealism"] then

local arapi=require("__AircraftRealism__.api")
  for i,entity in ipairs(Aircraft_List) do
    local aircraft_grounded=data.raw["car"][entity]
    local aircraft_flying=table.deepcopy(data.raw["car"][entity])
    aircraft_flying.name=aircraft_flying.name .. "-flying"
    aircraft_grounded["collision_box"]=data.raw["car"][entity]["selection_box"]
    aircraft_grounded["render_layer"] = "object"
    aircraft_flying.animation.layers[2]=nil --Shadows managed dynamically by AircraftRealism when in flight
    aircraft_flying.collision_mask = { layers = {} } 
    aircraft_grounded.friction=aircraft_grounded.friction*0.5
    aircraft_flying.effectivity=aircraft_flying.effectivity/4
    aircraft_flying.friction=aircraft_flying.friction/6
    local braking_power_val,prefix=flib_data_util.get_energy_value(aircraft_flying.braking_power)
    aircraft_flying.braking_power=tostring(braking_power_val/10) .. prefix
    data:extend{aircraft_flying}

    --Shadow sprites, copied from https://github.com/jaihysc/Factorio-AircraftRealism/blob/2.0.0/Docs/Api.md
    local underscored_name=entity:gsub("-","_")
    local spriteNames = {}
    for i=0,35 do
        local xPos = i % 6
        local yPos = math.floor(i / 6)

        spriteNames[i + 1] = underscored_name.."-shadow-" .. tostring(i)
        local sprite = {
            type = "sprite",
            name = underscored_name.."-shadow-" .. tostring(i),
            filename = "__Aircraft-space-age__/graphics/entity/"..underscored_name.."/hr-"..underscored_name.."_spritesheet-shadow.png",
            width = 448,
            height = 448,
            x = xPos * 448,
            y = yPos * 448,
            shift = util.by_pixel(0, 0),
            scale = 0.5,
        }
        data:extend{sprite}
    end
    --End shadow sprites
    arapi.register_plane({
      grounded_name = data.raw["car"][entity].name,
      airborne_name = aircraft_flying.name,
      transition_speed_setting = "transition-speed-" .. data.raw["car"][entity].name,
      shadow_sprite = spriteNames,
      --shadow_offset={4,4},
      shadow_end_speed=settings.startup["shadow-end-animation-speed-".. data.raw["car"][entity].name].value/216
    })
    
    
    -- data:extend({
    --   {
    --     type = "double-setting",
    --     name = "transition-speed-" .. data.raw.car[entity].name,
    --     setting_type="runtime-global",
    --     --minimum_value=0,
    --     default_value=v_liftoff(data.raw["car"][entity],wing_area,C_lift)
    --   }
    -- })
  end
  
end




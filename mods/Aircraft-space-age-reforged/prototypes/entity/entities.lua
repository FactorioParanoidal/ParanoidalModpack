local aircraft = require("shared.aircraft")
local path = aircraft.path
local realism = mods["AircraftRealism"] ~= nil
local carbon_enabled = mods["space-age"] and settings.startup["carbon-fiber-aircraft"].value
local hardmode = settings.startup["aircraft-hardmode"].value
local fuel_multiplier = settings.startup["fuel-consumption-multiplier"].value
assert(fuel_multiplier > 0 and fuel_multiplier < math.huge, "Aircraft fuel multiplier must be finite and positive")

local function sheet(spec, suffix)
  local name = spec.sheet
  if name == "flying_fortress" and suffix ~= "" then name = "jet" end
  return path .. "graphics/entity/" .. name .. "/hr-" .. name .. "_spritesheet" .. suffix .. ".png"
end

local function layer(spec, suffix)
  local shadow = suffix == "-shadow"
  return {
    filename = sheet(spec, suffix), width = shadow and 224 or 448, height = shadow and 224 or 448,
    scale = shadow and 1 or 0.5, frame_count = 1, direction_count = 36, line_length = 6, max_advance = 1,
    shift = shadow and util.by_pixel(realism and 0 or 54, realism and 0 or 35) or util.by_pixel(9, -10),
    draw_as_shadow = shadow or nil, draw_as_light = suffix == "-light" or nil
  }
end

local function lights(spec)
  local result = {}
  for _, value in ipairs(spec.lights) do
    result[#result + 1] = {
      type = "oriented", minimum_darkness = 0.3,
      picture = {filename = path .. "graphics/entity/particle/hr-light-cone.png", scale = 0.5, width = 800, height = 800},
      shift = util.by_pixel(value[1], value[2]), size = 2, intensity = value[3] / 10
    }
  end
  return result
end

local function trails(spec)
  local result = {}
  for _, value in ipairs(spec.trails) do
    result[#result + 1] = {
      name = "aircraft-trail", frequency = 60, deviation = {0, 0},
      position = util.by_pixel(value[1], value[2]), height = value[3] / 32,
      starting_frame = 3, starting_frame_deviation = 5,
      starting_frame_speed = 5, starting_frame_speed_deviation = 5
    }
  end
  return result
end

local jet_sound = {
  sound = {filename = path .. "sounds/jet-loop.ogg", volume = 0.3},
  deactivate_sound = {filename = path .. "sounds/jet-stop.ogg", volume = 0.3},
  match_speed_to_activity = true, fade_in_ticks = 30
}
local car_sound = {
  sound = {filename = "__base__/sound/car-engine.ogg", volume = 0.6},
  activate_sound = {filename = "__base__/sound/car-engine-start.ogg", volume = 0.6},
  deactivate_sound = {filename = "__base__/sound/car-engine-stop.ogg", volume = 0.6},
  match_speed_to_activity = true
}

local function make_plane(spec, carbon)
  local name = aircraft.name(spec, carbon)
  local economy = carbon and 0.5 or 1
  local flags = {"placeable-neutral", "player-creation", "placeable-off-grid"}
  if settings.startup["inserter-immunity"].value then
    flags[#flags + 1] = "no-automated-item-removal"
    flags[#flags + 1] = "no-automated-item-insertion"
  end
  local plane = {
    type = "car", name = name, icon = aircraft.icon(spec, carbon), icon_size = 64, flags = flags,
    minable = {mining_time = 1, result = name}, max_health = spec.health * (carbon and 0.5 or 1),
    resistances = table.deepcopy(hardmode and spec.hard or spec.normal),
    inventory_size = spec.inventory, trash_inventory_size = 10, equipment_grid = spec.grid,
    guns = table.deepcopy(spec.guns), energy_per_hit_point = spec.impact_energy,
    weight = spec.weight * (carbon and 0.5 or 1),
    -- Preserve wheel output while changing the amount of fuel burned.
    consumption = tostring(spec.power_kw * fuel_multiplier * economy) .. "kW",
    effectivity = spec.effectivity / fuel_multiplier / economy,
    braking_force = spec.brake_kw * 1000 / 60, friction_force = spec.friction,
    rotation_speed = spec.rotation, tank_driving = not settings.startup["disable-tank-controls"].value,
    terrain_friction_modifier = 0, allow_remote_driving = true,
    energy_source = {
      type = "burner", fuel_inventory_size = spec.fuel_slots,
      fuel_categories = table.deepcopy(data.raw.car.car.energy_source.fuel_categories or {"chemical"}), smoke = trails(spec)
    },
    trigger_target_mask = {"common"}, collision_box = {{-0.9, -1.3}, {0.9, 1.3}},
    collision_mask = not realism and {layers = {}} or nil, selection_box = {{-0.9, -1.3}, {0.9, 1.3}},
    selection_priority = 60, render_layer = "air-object", has_belt_immunity = settings.startup["aircraft-belt-immunity"].value,
    corpse = "medium-remnants", dying_explosion = "medium-explosion", create_ghost_on_death = false,
    animation = {layers = {layer(spec, ""), layer(spec, "-shadow")}},
    light_animation = {layers = {layer(spec, "-light")}}, light = lights(spec),
    sound_no_fuel = {{filename = "__base__/sound/fight/tank-no-fuel-1.ogg", volume = 0.6}},
    working_sound = table.deepcopy(settings.startup["aircraft-sound-setting"].value and jet_sound or car_sound),
    crash_trigger = table.deepcopy(data.raw.car.car.crash_trigger), stop_trigger_speed = spec.stop_speed,
    open_sound = {filename = "__base__/sound/car-door-open.ogg", volume = 0.7},
    close_sound = {filename = "__base__/sound/car-door-close.ogg", volume = 0.7},
    mined_sound = {filename = "__core__/sound/deconstruct-large.ogg", volume = 0.8},
    minimap_representation = {filename = path .. "graphics/icons/aircraft-minimap-representation.png", flags = {"icon"}, size = {40, 40}, scale = 0.5},
    selected_minimap_representation = {filename = path .. "graphics/icons/aircraft-minimap-representation-selected.png", flags = {"icon"}, size = {40, 40}, scale = 0.5}
  }
  if mods["space-age"] and settings.startup["lock-surfaces-space-age"].value then
    plane.surface_conditions = {{property = "pressure", min = 700}, {property = "gravity", max = 20}}
  end
  return plane
end

local arapi = realism and require("__AircraftRealism__.api") or nil
for _, spec in ipairs(aircraft.aircraft) do
  local shadow_names = {}
  if realism then
    local sprites = {}
    for i = 0, 35 do
      local name = spec.sheet .. "-shadow-" .. i
      shadow_names[#shadow_names + 1] = name
      sprites[#sprites + 1] = {
        type = "sprite", name = name, filename = sheet(spec, "-shadow"), width = 224, height = 224,
        x = (i % 6) * 224, y = math.floor(i / 6) * 224, shift = {0, 0}, scale = 1
      }
    end
    data:extend(sprites)
  end
  for _, carbon in ipairs(carbon_enabled and {false, true} or {false}) do
    local grounded = make_plane(spec, carbon)
    if realism then
      local flying = table.deepcopy(grounded)
      flying.name = grounded.name .. "-flying"
      flying.animation.layers = {flying.animation.layers[1]}
      flying.collision_mask = {layers = {}}
      flying.effectivity = flying.effectivity / 4
      flying.friction_force = flying.friction_force / 6
      flying.braking_force = flying.braking_force / 10
      grounded.friction_force = grounded.friction_force / 2
      grounded.render_layer = "object"
      data:extend({grounded, flying})
      arapi.register_plane({
        grounded_name = grounded.name, airborne_name = flying.name,
        transition_speed_setting = "transition-speed-" .. grounded.name, shadow_sprite = shadow_names,
        shadow_end_speed = settings.startup["shadow-end-animation-speed-" .. grounded.name].value / 216
      })
    else
      data:extend({grounded})
    end
  end
end

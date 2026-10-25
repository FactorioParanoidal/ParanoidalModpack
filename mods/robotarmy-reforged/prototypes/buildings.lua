-- Droid assembler, guard station, droid counter, drop pod and (optional) loot chest.
local util = require("util")
local shared = require("lib.shared")

local ICONS = shared.mod_path .. "/graphics/icons/"
local BUILDINGS = shared.mod_path .. "/graphics/entity/buildings/"
local B = shared.buildings

local RESISTANCES = {{type = "fire", percent = 70}, {type = "acid", percent = 70}}

local WORKING_SOUND = {
  sound = {
    {filename = "__base__/sound/assembling-machine-t2-1.ogg", volume = 0.8},
    {filename = "__base__/sound/assembling-machine-t2-2.ogg", volume = 0.8},
  },
  idle_sound = {filename = "__base__/sound/idle1.ogg", volume = 0.6},
  apparent_volume = 1.5,
}

local function picture(file, width, height)
  return {
    layers = {
      {filename = BUILDINGS .. "hr-" .. file .. ".png", width = width, height = height, frame_count = 1, line_length = 1, scale = 0.5},
      {filename = BUILDINGS .. "hr-" .. file .. "-shadow.png", width = width, height = height, frame_count = 1, line_length = 1, scale = 0.5, draw_as_shadow = true},
    },
  }
end

local function deployer(p)
  return {
    type = "assembling-machine",
    name = p.name,
    icon = ICONS .. p.name .. ".png",
    icon_size = 64,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.5, result = p.name},
    max_health = 400,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    resistances = RESISTANCES,
    fluid_boxes = p.fluid_boxes,
    collision_box = p.collision_box,
    selection_box = p.selection_box,
    graphics_set = {animation = p.animation},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    impact_category = "metal",
    working_sound = WORKING_SOUND,
    crafting_categories = {"droids"},
    crafting_speed = 1,
    energy_source = {type = "electric", usage_priority = "secondary-input"},
    energy_usage = "300kW",
    ingredient_count = p.ingredient_count,
    module_slots = p.module_slots,
    allowed_effects = {"consumption", "speed", "pollution"},
    -- circuit network: enable/disable by condition, read contents, set the deploy recipe
    circuit_wire_max_distance = assembling_machine_circuit_wire_max_distance,
    circuit_connector = circuit_connector_definitions["assembling-machine"],
  }
end

-- The assembler keeps its (unused) pipe connections only so that it can be rotated:
-- droids are spawned on the side of the output connection.
local function pipe(production_type, direction, y)
  return {
    volume = 100,
    production_type = production_type,
    pipe_picture = assembler2pipepictures(),
    pipe_covers = pipecoverspictures(),
    pipe_connections = {{flow_direction = production_type, direction = direction, position = {0, y}}},
  }
end

local led = {
  filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-N.png",
  width = 14,
  height = 12,
  scale = 0.5,
  shift = util.by_pixel(9, -11.5),
  draw_as_glow = true,
}

local wire_points = {
  shadow = {red = {0.15625, -0.28125}, green = {0.65625, -0.25}},
  wire = {red = {-0.28125, -0.5625}, green = {0.21875, -0.5625}},
}

local function combinator(name, led_offset, light_color)
  return {
    type = "constant-combinator",
    name = name,
    icon = ICONS .. name .. ".png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = name},
    max_health = 50,
    corpse = "small-remnants",
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    sprites = {
      layers = {
        {filename = BUILDINGS .. "hr-" .. name .. ".png", width = 128, height = 128, scale = 0.5},
        {filename = BUILDINGS .. "hr-" .. name .. "-shadow.png", width = 128, height = 128, scale = 0.5, draw_as_shadow = true},
      },
    },
    activity_led_sprites = {north = led, east = led, south = led, west = led},
    activity_led_light = {intensity = 0.8, size = 1, color = light_color},
    activity_led_light_offsets = {led_offset, led_offset, led_offset, led_offset},
    circuit_wire_connection_points = {wire_points, wire_points, wire_points, wire_points},
    circuit_wire_max_distance = 10,
  }
end

data:extend({
  deployer({
    name = B.assembler,
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    animation = picture("droid-assembler", 312, 278),
    fluid_boxes = {pipe("input", defines.direction.north, -1.2), pipe("output", defines.direction.south, 1.2)},
    ingredient_count = 3,
    module_slots = 3,
  }),
  deployer({
    name = B.station,
    collision_box = {{-1.7, -1.7}, {1.7, 1.7}},
    selection_box = {{-2, -2}, {2, 2}},
    animation = picture("guard-station", 416, 456),
    ingredient_count = 2, -- the miner deploy recipe also takes its land mines
    module_slots = 0,
  }),
  combinator(B.counter, {0.234375, -0.484375}, {r = 1, g = 1, b = 1}),
  {
    -- Drop pod on the ground. Not minable while it holds a squad (the control script turns mining
    -- on once the squad has landed); not blueprintable: the squad lives in the item tags.
    type = "simple-entity-with-owner",
    name = shared.pod.entity,
    icons = {{icon = ICONS .. "loot-chest.png", icon_size = 64, tint = {r = 0.6, g = 0.75, b = 0.45}}},
    flags = {"placeable-neutral", "placeable-player", "player-creation", "not-blueprintable"},
    minable = {mining_time = 0.5, result = shared.pod.item},
    max_health = 500,
    corpse = "small-remnants",
    dying_explosion = "medium-explosion",
    resistances = {{type = "fire", percent = 80}, {type = "acid", percent = 50}},
    collision_box = {{-0.8, -0.8}, {0.8, 0.8}},
    selection_box = {{-1, -1}, {1, 1}},
    render_layer = "object",
    picture = {
      layers = {
        {filename = BUILDINGS .. "hr-loot-chest.png", width = 66, height = 76, shift = util.by_pixel(-1, -1), scale = 1,
         tint = {r = 0.6, g = 0.75, b = 0.45}},
        {filename = BUILDINGS .. "hr-loot-chest-shadow.png", width = 110, height = 50, shift = util.by_pixel(25, 16), scale = 1, draw_as_shadow = true},
      },
    },
  },
})

if settings.startup[shared.setting.loot_chest].value then
  data:extend({
    {
      type = "container",
      name = B.loot,
      icon = ICONS .. "loot-chest.png",
      icon_size = 64,
      flags = {"placeable-neutral", "player-creation"},
      minable = {mining_time = 1, result = B.loot},
      max_health = 400,
      corpse = "small-remnants",
      open_sound = {filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.65},
      close_sound = {filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7},
      impact_category = "metal",
      resistances = {{type = "fire", percent = 90}},
      collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
      selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
      inventory_size = 48,
      picture = {
        layers = {
          {filename = BUILDINGS .. "hr-loot-chest.png", width = 66, height = 76, shift = util.by_pixel(-0.5, -0.5), scale = 0.5},
          {filename = BUILDINGS .. "hr-loot-chest-shadow.png", width = 110, height = 50, shift = util.by_pixel(12.5, 8), scale = 0.5, draw_as_shadow = true},
        },
      },
      circuit_connector = circuit_connector_definitions.create_single(universal_connector_template, {
        variation = 18,
        main_offset = util.by_pixel(2.5, 18.0),
        shadow_offset = util.by_pixel(2.0, 18.0),
        show_shadow = false,
      }),
      circuit_wire_max_distance = 7.5,
    },
  })
end

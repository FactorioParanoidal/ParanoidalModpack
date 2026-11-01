-- Larger lamps (after Larger Lamps 2.0 by Deadlock989 and others): large, copper, electric copper and floor lamp.
-- Sprites are the HR sheets of the original mod; the copper lamps share one set of pictures.
local G = "__paranoidal-lighting__/graphics/"
local ENTITY = G .. "entity/"

local LARGE = "deadlock-large-lamp"
local COPPER = "deadlock-copper-lamp"
local ELECTRIC_COPPER = "deadlock-electric-copper-lamp"
local FLOOR = "deadlock-floor-lamp"

local MINING_TIME = 0.3
local GLOW_COLOUR = {r = 1.0, g = 1.0, b = 0.75}
local TINT_COLOUR = {r = 1.0, g = 1.0, b = 0.95}

local function sprite(file, extra)
  local s = {filename = ENTITY .. file, width = 128, height = 128, scale = 0.5, shift = {0, 0}, priority = "high"}
  for k, v in pairs(extra or {}) do s[k] = v end
  return s
end

local function oriented_light(colour, intensity)
  return {
    color = colour,
    intensity = intensity,
    size = 60,
    type = "oriented",
    picture = {filename = ENTITY .. "lamp-light.png", width = 256, height = 256, scale = 0.125},
  }
end

local connector = {
  points = {
    shadow = {red = {0.47, -0.48}, green = {0.47, -0.48}},
    wire = {red = {0.47, -0.48}, green = {0.47, -0.48}},
  }
}
local solid_mask = {layers = {object = true, water_tile = true, meltable = true, player = true}}
local mined_sound = {filename = "__base__/sound/deconstruct-bricks.ogg"}
local impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65}
local signal_colours = data.raw.lamp["small-lamp"].signal_to_color_mapping

local function electric_lamp(name, icon, fields)
  local lamp = {
    type = "lamp",
    name = name,
    icon = G .. "icons/" .. icon,
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = MINING_TIME, result = name},
    max_health = 150,
    corpse = "small-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-0.6, -0.6}, {0.6, 0.6}},
    selection_box = {{-1.0, -1.0}, {1.0, 1.0}},
    tile_width = 2,
    tile_height = 2,
    energy_source = {type = "electric", usage_priority = "lamp"},
    energy_usage_per_tick = "20kW",
    darkness_for_all_lamps_off = 0.3,
    darkness_for_all_lamps_on = 0.5,
    glow_color_intensity = 1,
    glow_size = 12,
    glow_render_mode = "multiplicative",
    light = oriented_light(GLOW_COLOUR, 0.75),
    light_when_colored = {color = GLOW_COLOUR, intensity = 0, size = 12},
    resistances = {{type = "fire", percent = 50}},
    signal_to_color_mapping = signal_colours,
    mined_sound = mined_sound,
    vehicle_impact_sound = impact_sound,
    squeak_behaviour = false,
  }
  for k, v in pairs(fields) do lamp[k] = v end
  return lamp
end

local electric_copper_lamp = electric_lamp(ELECTRIC_COPPER, "copper-lamp.png", {
  collision_mask = solid_mask,
  circuit_connector = connector,
  circuit_wire_max_distance = 9,
  picture_off = {layers = {
    sprite("copper-lamp/base.png"),
    sprite("copper-lamp/shadow.png", {draw_as_shadow = true}),
  }},
  -- First frame of the copper lamp flame sheet.
  picture_on = sprite("copper-lamp/working.png", {blend_mode = "additive-soft", tint = TINT_COLOUR}),
})
-- As in Larger Lamps: engine default health (10), no mining sound, engine default darkness thresholds.
electric_copper_lamp.max_health = nil
electric_copper_lamp.mined_sound = nil
electric_copper_lamp.darkness_for_all_lamps_on = nil
electric_copper_lamp.darkness_for_all_lamps_off = nil

data:extend({
  {type = "recipe-category", name = "lamp-burning"},

  electric_lamp(LARGE, "large-lamp.png", {
    collision_mask = solid_mask,
    circuit_connector = connector,
    circuit_wire_max_distance = 9,
    fast_replaceable_group = "large-lamp",
    picture_off = {layers = {
      sprite("large-lamp/base.png"),
      sprite("large-lamp/shadow.png", {draw_as_shadow = true}),
    }},
    picture_on = sprite("large-lamp/light.png", {blend_mode = "additive-soft", tint = TINT_COLOUR}),
  }),

  electric_copper_lamp,

  -- Walkable floor panel: blocks building on top, not players or vehicles.
  electric_lamp(FLOOR, "floor-lamp.png", {
    collision_mask = {layers = {item = true, water_tile = true, meltable = true}},
    energy_usage_per_tick = "10kW",
    fast_replaceable_group = "large-lamp",
    light = oriented_light(GLOW_COLOUR, 0.4),
    picture_off = {filename = ENTITY .. "blank.png", width = 1, height = 1, priority = "low"},
    picture_on = sprite("floor-lamp/light.png", {blend_mode = "additive-soft", tint = {r = 1.0, g = 1.0, b = 0.85}}),
    integration_patch_layer = "floor-mechanics-under-corpse",
    integration_patch = sprite("floor-lamp/base.png"),
  }),

  -- Copper lamp: a burner assembling machine with one fixed hidden recipe that lasts a game day.
  {
    type = "assembling-machine",
    name = COPPER,
    icon = G .. "icons/copper-lamp.png",
    icon_size = 64,
    flags = {"placeable-player", "placeable-neutral", "player-creation"},
    minable = {mining_time = MINING_TIME, result = COPPER},
    max_health = 100,
    corpse = "small-remnants",
    dying_explosion = "medium-explosion",
    resistances = {{type = "fire", percent = 95}},
    collision_box = {{-0.6, -0.6}, {0.6, 0.6}},
    selection_box = {{-1.0, -1.0}, {1.0, 1.0}},
    collision_mask = solid_mask,
    fast_replaceable_group = "large-lamp",
    next_upgrade = LARGE,
    crafting_speed = 1,
    crafting_categories = {"lamp-burning"},
    fixed_recipe = COPPER .. "-burning",
    show_recipe_icon = false,
    show_recipe_icon_on_map = false,
    source_inventory_size = 1,
    result_inventory_size = 1,
    energy_source = {
      type = "burner",
      fuel_categories = {"chemical"},
      fuel_inventory_size = 1,
      burnt_inventory_size = 1,
      emissions_per_minute = {pollution = 0.02},
      light_flicker = {color = {0, 0, 0, 0}}, -- no default burner glow
      render_no_power_icon = false,
    },
    energy_usage = "10kW",
    graphics_set = {
      animation = {layers = {
        sprite("copper-lamp/base.png"),
        sprite("copper-lamp/shadow.png", {draw_as_shadow = true}),
      }},
      working_visualisations = {{
        animation = sprite("copper-lamp/working.png", {
          frame_count = 30, line_length = 6, animation_speed = 1, draw_as_glow = true, blend_mode = "additive-soft"}),
        light = oriented_light({1.0, 0.75, 0.5}, 0.75),
      }},
    },
    working_sound = {sound = {filename = "__base__/sound/furnace.ogg", volume = 1.0}},
    open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.75},
    close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
    mined_sound = mined_sound,
    vehicle_impact_sound = impact_sound,
    squeak_behaviour = false,
  },
})

local function item(name, icon, order)
  return {
    type = "item",
    name = name,
    icon = G .. "icons/" .. icon,
    icon_size = 64,
    subgroup = "circuit-network",
    order = order,
    place_result = name,
    stack_size = 50,
  }
end

local function recipe(name, enabled, order, ingredients)
  return {
    type = "recipe",
    name = name,
    enabled = enabled,
    category = "crafting",
    ingredients = ingredients,
    results = {{type = "item", name = name, amount = 1}},
    subgroup = "circuit-network",
    order = order,
  }
end

local electric_parts = {
  {type = "item", name = "electronic-circuit", amount = 1},
  {type = "item", name = "copper-cable", amount = 4},
  {type = "item", name = "iron-plate", amount = 6},
}

data:extend({
  item(LARGE, "large-lamp.png", "a[lamp]-a[large-lamp]"),
  item(COPPER, "copper-lamp.png", "a[lamp]-b[copper-lamp]"),
  item(ELECTRIC_COPPER, "electric-copper-lamp.png", "a[lamp]-c[electric-copper-lamp]"),
  item(FLOOR, "floor-lamp.png", "a[lamp]-d[floor-lamp]"),

  recipe(LARGE, false, "a[lamp]-a[large-lamp]", electric_parts),
  recipe(COPPER, true, "a[lamp]-b[copper-lamp]", {{type = "item", name = "copper-plate", amount = 6}}),
  recipe(ELECTRIC_COPPER, true, "a[lamp]-c[electric-copper-lamp]", {
    {type = "item", name = "advanced-circuit", amount = 2},
    {type = "item", name = "copper-cable", amount = 4},
    {type = "item", name = "iron-plate", amount = 6},
  }),
  recipe(FLOOR, false, "a[lamp]-d[floor-lamp]", table.deepcopy(electric_parts)),
  {
    type = "recipe",
    name = COPPER .. "-burning",
    enabled = true,
    hidden = true,
    hide_from_stats = true,
    icon = G .. "icons/copper-lamp.png",
    icon_size = 64,
    category = "lamp-burning",
    ingredients = {},
    results = {},
    subgroup = "other",
    energy_required = 25000 / 60, -- one game day
  },
})

local lamp_tech = data.raw.technology.lamp
if lamp_tech then
  lamp_tech.effects = lamp_tech.effects or {}
  for _, name in ipairs({LARGE, FLOOR, ELECTRIC_COPPER}) do
    table.insert(lamp_tech.effects, {type = "unlock-recipe", recipe = name})
  end
end

-- Lights of large lamps reach farther than the engine searches by default.
local constants = data.raw["utility-constants"].default
if constants and constants.light_renderer_search_distance_limit
  and constants.light_renderer_search_distance_limit < 25 then
  constants.light_renderer_search_distance_limit = 25
end

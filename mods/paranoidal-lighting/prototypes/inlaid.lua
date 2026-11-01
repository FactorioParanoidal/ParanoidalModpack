-- Inlaid lamps (after Inlaid Lamps Extended by Mathematician, CobaltTiger, Pi-C): lamps set into the floor,
-- 1x1 and 2x2, that players and vehicles pass over. Copies of the vanilla lamp with their own pictures.
local G = "__paranoidal-lighting__/graphics/"
local ENTITY = G .. "entity/inlaid-lamp/"

local SMALL = "flat-lamp"
local BIG = "flat-lamp-big"
local BIG_FACTOR = 4
local light_size = settings.startup["inlaid-lamps-extended-light_size"].value

local small_lamp = data.raw.lamp["small-lamp"]
-- Inlaid lamps and the vanilla lamp replace each other.
small_lamp.fast_replaceable_group = "lamps"

local resistances = {
  {type = "physical", decrease = 20, percent = 30},
  {type = "explosion", decrease = 20, percent = 30},
  {type = "fire", decrease = 20, percent = 30},
}

local function led(colour, size, shift)
  return {filename = ENTITY .. "connector-led-" .. colour .. ".png", width = size, height = size, priority = "low", shift = shift}
end

local small = table.deepcopy(small_lamp)
small.name = SMALL
small.icon = G .. "icons/inlaid-lamp.png"
small.icon_size = 64
small.icons = nil
small.minable = {mining_time = 0.5, result = SMALL}
small.corpse = "lamp-remnants"
small.collision_mask = {layers = {doodad = true, object = true, water_tile = true}}
small.collision_box = {{-0.4, -0.4}, {0.4, 0.4}}
small.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
small.resistances = resistances
small.hide_resistances = false
small.vehicle_impact_sound = nil -- vehicles do not damage inlaid lamps
small.energy_usage_per_tick = "5kW"
small.light = {intensity = 0.9, size = light_size, color = {r = 1.0, g = 1.0, b = 1.0}}
small.light_when_colored = {intensity = 1, size = 6, color = {r = 1.0, g = 1.0, b = 1.0}}
small.glow_size = 6
small.glow_color_intensity = 0.235
small.darkness_for_all_lamps_on = small_lamp.darkness_for_all_lamps_on or 0.7
small.darkness_for_all_lamps_off = small_lamp.darkness_for_all_lamps_off or 0.5
small.picture_off = {
  filename = ENTITY .. "off.png", priority = "high", flags = {"low-object"},
  width = 90, height = 78, shift = util.by_pixel(0, -7), scale = 1,
}
small.picture_on = table.deepcopy(small.picture_off)
small.picture_on.filename = ENTITY .. "on.png"
small.circuit_connector = {
  sprites = {
    led_red = led("red", 12, {-0.32, -0.34}),
    led_green = led("green", 12, {-0.32, -0.30}),
    led_blue = led("blue", 12, {-0.32, -0.32}),
    led_light = {intensity = 0.8, size = 0.9},
    connector_main = {
      filename = ENTITY .. "connector-main.png", width = 12, height = 128, scale = 0.5, priority = "low", shift = {-0.32, 0},
    },
    blue_led_light_offset = {0.0, 0.0},
    red_green_led_light_offset = {-0.3, -0.3},
  },
  points = {
    wire = {red = {-0.32, -0.32}, green = {-0.32, -0.32}},
    shadow = {red = {-0.32, -0.32}, green = {-0.32, -0.32}},
  },
}
small.fast_replaceable_group = "lamps"

local big = table.deepcopy(small)
big.name = BIG
big.icon = G .. "icons/inlaid-lamp-big-entity.png"
big.icon_size = 128
big.minable = {mining_time = small.minable.mining_time * BIG_FACTOR, result = BIG}
big.max_health = small.max_health * BIG_FACTOR * 0.75
big.corpse = "medium-remnants"
big.collision_box = {{-0.8, -0.8}, {0.8, 0.8}}
big.selection_box = {{-1, -1}, {1, 1}}
big.tile_width = 2
big.tile_height = 2
big.energy_usage_per_tick = "10kW"
big.light.size = 2 * small.light.size
big.light_when_colored.size = 2 * small.light_when_colored.size
big.picture_off.scale = 2
big.picture_off.shift = {x = small.picture_off.shift[1] * 2, y = small.picture_off.shift[2] * 2}
big.picture_on.scale = 2
big.picture_on.shift = {x = small.picture_on.shift[1] * 2, y = small.picture_on.shift[2] * 2}
big.circuit_connector = {
  sprites = {
    led_red = led("red", 12, {-0.64, -0.64}),
    led_green = led("green", 12, {-0.64, -0.64}),
    led_blue = {filename = ENTITY .. "connector-led-blue.png", width = 12, height = 12},
    led_light = {intensity = 0.8, size = 0.9},
    connector_main = {
      filename = ENTITY .. "connector-main.png", width = 12, height = 128, scale = 0.5, priority = "low", shift = {-0.64, 0},
    },
    red_green_led_light_offset = {-0.6, -0.6},
  },
  points = {
    wire = {red = {-0.64, -0.64}, green = {-0.64, -0.64}},
    shadow = {red = {-0.64, -0.64}, green = {-0.64, -0.64}},
  },
}
big.fast_replaceable_group = nil

data:extend({
  small,
  big,
  {
    type = "item",
    name = SMALL,
    icon = G .. "icons/inlaid-lamp.png",
    icon_size = 64,
    subgroup = "circuit-network",
    order = "a[light-InlaidLampsExtended]-u[flat-lamp]",
    place_result = SMALL,
    stack_size = 50,
  },
  {
    type = "item",
    name = BIG,
    icon = G .. "icons/inlaid-lamp-big.png",
    icon_size = 64,
    subgroup = "circuit-network",
    order = "a[light-InlaidLampsExtended]-v[flat-lamp-big]",
    place_result = BIG,
    stack_size = 50,
  },
  {
    type = "recipe",
    name = SMALL,
    enabled = false,
    ingredients = {
      {type = "item", name = "small-lamp", amount = 1},
      {type = "item", name = "steel-plate", amount = 2},
      {type = "item", name = "concrete", amount = 2},
    },
    results = {{type = "item", name = SMALL, amount = 1}},
  },
  {
    type = "recipe",
    name = BIG,
    enabled = false,
    energy_required = 0.5 * BIG_FACTOR,
    ingredients = {
      {type = "item", name = SMALL, amount = BIG_FACTOR},
      {type = "item", name = "concrete", amount = 2},
      {type = "item", name = "steel-plate", amount = 2},
      {type = "item", name = "electronic-circuit", amount = 0.5 * BIG_FACTOR},
      {type = "item", name = "copper-cable", amount = BIG_FACTOR},
    },
    results = {{type = "item", name = BIG, amount = 1}},
  },
  {
    type = "technology",
    name = SMALL,
    icon = G .. "icons/inlaid-lamp-technology.png",
    icon_size = 128,
    prerequisites = {"lamp", "automobilism", "concrete"},
    effects = {
      {type = "unlock-recipe", recipe = SMALL},
      {type = "unlock-recipe", recipe = BIG},
    },
    unit = {
      count = 275,
      ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}},
      time = 30,
    },
    order = "a-h-a",
  },
})

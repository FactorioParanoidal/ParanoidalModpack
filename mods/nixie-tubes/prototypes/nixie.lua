circuit_connector_definitions["nixie"] = circuit_connector_definitions.create
(
  universal_connector_template,
  {
    --{ variation = 26, main_offset = util.by_pixel(4.5, 7.5), shadow_offset = util.by_pixel(3.5, 7.5), show_shadow = true },
    { variation = 26, main_offset = util.by_pixel(2.5, 18.0), shadow_offset = util.by_pixel(2.0, 18.0), show_shadow = true },
  }
)

circuit_connector_definitions["nixie-small"] = circuit_connector_definitions.create
(
  universal_connector_template,
  {
    { variation = 26, main_offset = util.by_pixel(2.5, 10.0), shadow_offset = util.by_pixel(2.0, 10.0), show_shadow = true },
  }
)


data:extend{

  -- original 2x1 tile one-digit nixie tube
  {
    type = "recipe",
    name = "nixie-tube",
    enabled = false,
    ingredients =
    {
      {"electronic-circuit",1},
      {"iron-plate",2},
      {"iron-stick", 10},
    },
    result = "nixie-tube"
  },
  {
    type = "item",
    name = "nixie-tube",
    icon = "__nixie-tubes__/graphics/nixie-base-icon.png",
    icon_size = 32,
    subgroup = "circuit-network",
    order = "c-a",
    place_result = "nixie-tube",
    stack_size = 50
  },
  {
    type = "lamp",
    name = "nixie-tube",
    icon = "__nixie-tubes__/graphics/nixie-base-icon.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation", "not-on-map"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "nixie-tube"},
    max_health = 55,
    order = "z[zebra]",
    corpse = "small-remnants",
    collision_box = {{-0.4, -0.9}, {0.4, .9}},
    selection_box = {{-.5, -1.0}, {0.5, 1.0}},
    energy_source =
    {
      type = "electric",
      usage_priority = "lamp",
    },
    energy_usage_per_tick = "4KW",
    light = {intensity = 0.0, size = 0, color = {r=1, g=.6, b=.3, a=0}},
    picture_off =
    {
      filename = "__nixie-tubes__/graphics/nixie-base.png",
      priority = "high",
      width = 80, -- New size image 2x
      height = 128, -- New size image 2x
      scale = 0.5, -- Reduced so that the sprite does not crawl over the edges
      shift = {4/32,0} -- Shift the sprite so that it does not overlap with neighboring grid cells
    },
    picture_on =
    {
      filename = "__nixie-tubes__/graphics/empty.png",
      priority = "high",
      width = 1,
      height = 1,
      shift = {0,0}
    },
    circuit_wire_connection_point = circuit_connector_definitions["nixie"].points,
    circuit_connector_sprites = circuit_connector_definitions["nixie"].sprites,
    circuit_wire_max_distance = 7.5
  },

  -- 2x1 tile one-charater alpha nixie tube
  {
    type = "recipe",
    name = "nixie-tube-alpha",
    enabled = false,
    ingredients =
    {
      {"electronic-circuit",1},
      {"iron-plate",2},
      {"iron-stick", 10},
    },
    result = "nixie-tube-alpha"
  },
  {
    type = "item",
    name = "nixie-tube-alpha",
    icon = "__nixie-tubes__/graphics/nixie-alpha-base-icon.png",
    icon_size = 32,
    subgroup = "circuit-network",
    order = "c-a",
    place_result = "nixie-tube-alpha",
    stack_size = 50
  },
  {
    type = "lamp",
    name = "nixie-tube-alpha",
    icon = "__nixie-tubes__/graphics/nixie-alpha-base-icon.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation", "not-on-map"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "nixie-tube-alpha"},
    max_health = 55,
    order = "z[zebra]",
    corpse = "small-remnants",
    collision_box = {{-0.4, -0.9}, {0.4, .9}},
    selection_box = {{-.5, -1.0}, {0.5, 1.0}},
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
    },
    energy_usage_per_tick = "4KW",
    light = {intensity = 0.0, size = 0, color = {r=1, g=.6, b=.3, a=0}},
    picture_off =
    {
      filename = "__nixie-tubes__/graphics/nixie-base.png",
      priority = "high",
      width = 80, -- New size image 2x
      height = 128, -- New size image 2x
      scale = 0.5, -- Reduced so that the sprite does not crawl over the edges
      shift = {4/32,0} -- Shift the sprite so that it does not overlap with neighboring grid cells
    },
    picture_on =
    {
      filename = "__nixie-tubes__/graphics/empty.png",
      priority = "high",
      width = 1,
      height = 1,
      shift = {0,0}
    },
    circuit_wire_connection_point = circuit_connector_definitions["nixie"].points,
    circuit_connector_sprites = circuit_connector_definitions["nixie"].sprites,
    circuit_wire_max_distance = 7.5
  },

  -- small 1x1 tile two-digit nixie tube
  {
    type = "recipe",
    name = "nixie-tube-small",
    enabled = false,
    ingredients =
    {
      {"electronic-circuit",1},
      {"iron-plate", 1},
      {"iron-stick", 5},
    },
    result = "nixie-tube-small"
  },
  {
    type = "item",
    name = "nixie-tube-small",
    icon = "__nixie-tubes__/graphics/nixie-small-base-icon.png",
    icon_size = 32,
    subgroup = "circuit-network",
    order = "c-a",
    place_result = "nixie-tube-small",
    stack_size = 50
  },
  {
    type = "lamp",
    name = "nixie-tube-small",
    icon = "__nixie-tubes__/graphics/nixie-small-base-icon.png",
    icon_size = 32,
    flags = {"placeable-neutral","player-creation", "not-on-map"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "nixie-tube-small"},
    max_health = 40,
    order = "z[zebra]",
    corpse = "small-remnants",
    collision_box = {{-0.4, -0.4}, {0.4, .4}},
    selection_box = {{-.5, -0.5}, {0.5, 0.5}},
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
    },
    energy_usage_per_tick = "4KW",
    light = {intensity = 0.0, size = 0, color = {r=1, g=.6, b=.3, a=0}},
    light_when_colored = {intensity = 1, size = 6, color = {r=1.0, g=1.0, b=1.0}},
    picture_off =
    {
      filename = "__nixie-tubes__/graphics/nixie-small-base.png",
      priority = "high",
      width = 96, -- New size image 2x
      height = 84, -- New size image 2x
      scale = 0.5, -- Reduced so that the sprite does not crawl over the edges
      shift = {8/32,-5/32} -- Shift the sprite so that it does not overlap with neighboring grid cells
    },
    picture_on =
    {
      filename = "__nixie-tubes__/graphics/empty.png",
      priority = "high",
      width = 1,
      height = 1,
      shift = {0,0}
    },
    circuit_wire_max_distance = 7.5,

    circuit_wire_connection_point = circuit_connector_definitions["nixie-small"].points,
    circuit_connector_sprites = circuit_connector_definitions["nixie-small"].sprites,
  },
}

function nixie_sprite(char,xoffset,yoffset)
  return   {
      type = "sprite",
      name = "nixie-tube-sprite-" .. char,
      filename = "__nixie-tubes__/graphics/nixie-chars-mono.png",
      x = xoffset * 40, -- Increase the offset by image table
      y = yoffset * 88,
      width = 40, -- New size image 2x
      height = 88, -- New size image 2x
      scale = 0.5, -- Reduced so that the sprite does not crawl over the edges
      apply_runtime_tint = true,
      shift = {-2/64,-18/64}, -- Move the sprite to fit into the tube
    }
end

local spritelist =
  {
  ["0"]=settings.startup["nixie-tube-slashed-zero"].value and {x=0,y=0} or {x=4,y=5},
  ["1"]={x=1,y=0},
  ["2"]={x=2,y=0},
  ["3"]={x=3,y=0},
  ["4"]={x=4,y=0},
  ["5"]={x=5,y=0},
  ["6"]={x=6,y=0},
  ["7"]={x=7,y=0},
  ["8"]={x=8,y=0},
  ["9"]={x=9,y=0},
  ["A"]={x=0,y=1},
  ["B"]={x=1,y=1},
  ["C"]={x=2,y=1},
  ["D"]={x=3,y=1},
  ["E"]={x=4,y=1},
  ["F"]={x=5,y=1},
  ["G"]={x=6,y=1},
  ["H"]={x=7,y=1},
  ["I"]={x=8,y=1},
  ["J"]={x=9,y=1},
  ["K"]={x=0,y=2},
  ["L"]={x=1,y=2},
  ["M"]={x=2,y=2},
  ["N"]={x=3,y=2},
  ["O"]={x=4,y=2},
  ["P"]={x=5,y=2},
  ["Q"]={x=6,y=2},
  ["R"]={x=7,y=2},
  ["S"]={x=8,y=2},
  ["T"]={x=9,y=2},
  ["U"]={x=0,y=3},
  ["V"]={x=1,y=3},
  ["W"]={x=2,y=3},
  ["X"]={x=3,y=3},
  ["Y"]={x=4,y=3},
  ["Z"]={x=5,y=3},
  ["err"]={x=6,y=3},
  ["dot"]={x=7,y=3},
  ["negative"]={x=8,y=3}, -- for negative numbers
  ["off"]={x=9,y=3},

  --extended symbols
  ["?"]={x=0,y=4},
  ["!"]={x=1,y=4},
  ["@"]={x=2,y=4},
  ["["]={x=3,y=4},
  ["]"]={x=4,y=4},
  ["{"]={x=5,y=4},
  ["}"]={x=6,y=4},
  ["("]={x=7,y=4},
  [")"]={x=8,y=4},
  ["slash"]={x=9,y=4},
  ["*"]={x=0,y=5},
  ["-"]={x=1,y=5}, -- for subtraction operation
  ["+"]={x=2,y=5},
  ["%"]={x=3,y=5},

  }

for ch,offset in pairs(spritelist) do
  data:extend{
    nixie_sprite(ch,offset.x,offset.y)
  }
end

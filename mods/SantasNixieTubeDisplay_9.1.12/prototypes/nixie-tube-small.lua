local shift_digit = {x = -1/32, y = -7/32}
local arrow_box = {{-.5, -.1}, {0.5, -.1}}

local function SNTD_nixie_tube_sprite_small_getNumber(number)
  local function getSmallNumberOrientation(number)
    local orientation = {}
    orientation.filename = "__SantasNixieTubeDisplay__/graphics/nixie-tube-numbers.png"
    orientation.width = 20
    orientation.height = 44
    orientation.scale = .5
    orientation.shift = shift_digit
    orientation.x = orientation.width * number
    orientation.y=0

    return util.table.deepcopy(orientation)
  end

  return util.table.deepcopy({
    north = getSmallNumberOrientation(number),
    east  = getSmallNumberOrientation(number),
    south = getSmallNumberOrientation(number),
    west  = getSmallNumberOrientation(number),
  })
end

local SNTD_nixie_tube_small_recipe =
{
  type = "recipe",
  name = "SNTD-nixie-tube-small",
  enabled = "false",
  energy_required = 5,
  ingredients = {
    {"SNTD-old-nixie-tube", 2},
    {"steel-plate", 3},
    {"iron-stick", 10},
  },
  result = "SNTD-nixie-tube-small"
}

local SNTD_nixie_tube_small_item =
{
  type = "item",
  name = SNTD_nixie_tube_small_recipe.result,
  icon = "__SantasNixieTubeDisplay__/graphics/nixie-tube-small-icon.png",
  icon_size = 32,
  --flags = {},
  subgroup = "circuit-network",
  order = "c-a-c",
  place_result = "SNTD-nixie-tube-small",
  stack_size = 50
}

local SNTD_nixie_tube_small_entity =
{
  type = "lamp",
  name = SNTD_nixie_tube_small_item.place_result,
  icon = SNTD_nixie_tube_small_item.icon,
  icon_size = SNTD_nixie_tube_small_item.icon_size,
  flags = {"placeable-neutral","player-creation","not-on-map"},
  minable = {hardness = 0.2, mining_time = 0.5, result = SNTD_nixie_tube_small_item.name},
  max_health = 200,
  order = "z[zebra]",
  corpse = "small-remnants",
  collision_box = {{-0.49, -0.49}, {0.49, .49}},
  selection_box = {{-.5, -.5}, {0.5, .5}},
  energy_source =
  {
    type = "electric",
    usage_priority = "secondary-input",
  },
  energy_usage_per_tick = "4KW",
  light = {intensity = 0.0, size = 0, color = {r=1, g=.6, b=.3, a=0}},
  resistances =
  {
    {
      type = "fire",
      percent = 100
    },
    {
      type = "physical",
      percent = 50
    },
  },
  picture_off =
  {
    filename = "__SantasNixieTubeDisplay__/graphics/nixie-tube-small-base.png",
    priority = "high",
    width = 48,
    height = 42,
    frame_count = 1,
    axially_symmetrical = false,
    direction_count = 1,
    shift = {8/32,-6/32}
  },
  picture_on =
  {
    filename = "__SantasNixieTubeDisplay__/graphics/empty.png",
    priority = "low",
    width = 1,
    height = 1,
    frame_count = 1,
    axially_symmetrical = false,
    direction_count = 1,
    shift = {0,0}
  },
  circuit_wire_connection_point =
  {
    shadow = {
      red = {12/32, -23/32},
      green = {12/32, -20/32},
    },
    wire = {
      red = {12/32, -25/32},
      green = {12/32, -21/32},
    }
  },
  circuit_connector_sprites = nil,
  circuit_wire_max_distance = 7.5
}

local emptySprite =
{
  filename = "__SantasNixieTubeDisplay__/graphics/empty.png",
  width = 1,
  height = 1,
  frame_count = 1,
  shift = {0,0}
}

local SNTD_nixie_tube_small_sprite =
{
  type = "arithmetic-combinator",
  name = SNTD_nixie_tube_small_entity.name.."-sprite",
  localised_name = {"", "__ENTITY__"..SNTD_nixie_tube_small_entity.name.."__"},
  icon = SNTD_nixie_tube_small_item.icon,
  icon_size = SNTD_nixie_tube_small_item.icon_size,
  flags = {"placeable-neutral", "placeable-off-grid", "hide-alt-info","not-blueprintable", "not-deconstructable"},
  minable = SNTD_nixie_tube_small_entity.minable,
  max_health = SNTD_nixie_tube_small_entity.max_health,
  order = SNTD_nixie_tube_small_entity.order,
  corpse = SNTD_nixie_tube_small_entity.corpse,
  collision_box = {{-0.1, -.1}, {.1,.1}},
  selection_box = {{0,-.25}, {0,-.25}},

  energy_source =
  {
    type = "void",
    usage_priority = "secondary-input",
    render_no_network_icon = false,
    render_no_power_icon = false
  },
  active_energy_usage = "1W",

  working_sound =
  {
    sound =
    {
      filename = "__base__/sound/combinator.ogg",
      volume = 0,
    },
    max_sounds_per_type = 1,
    match_speed_to_activity = true,
  },
  vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },

  -- base of the nixie tube
  sprites =
  {
    north = emptySprite,
    east  = emptySprite,
    south = emptySprite,
    west  = emptySprite,
  },

  activity_led_sprites =
  {
    north = emptySprite,
    east  = emptySprite,
    south = emptySprite,
    west  = emptySprite,
  },

  activity_led_light =
  {
    intensity = 0,
    size = 1,
    color = {r = 1.0, g = 1.0, b = 1.0}
  },

  activity_led_light_offsets =
  {
    {0, 0},
    {0, 0},
    {0, 0},
    {0, 0}
  },

  screen_light =
  {
    intensity = 0.3,
    size = 0.6,
    color = {r = 1.0, g = 1.0, b = 1.0}
  },

  screen_light_offsets =
  {
    {0.015625, -0.234375},
    {0.015625, -0.296875},
    {0.015625, -0.234375},
    {0.015625, -0.296875}
  },

  -- empty number display
  multiply_symbol_sprites =
  {
    north = emptySprite,
    east  = emptySprite,
    south = emptySprite,
    west  = emptySprite,
  },

  plus_symbol_sprites        = SNTD_nixie_tube_sprite_small_getNumber(0), -- number 0
  minus_symbol_sprites       = SNTD_nixie_tube_sprite_small_getNumber(1), -- number 1
  divide_symbol_sprites      = SNTD_nixie_tube_sprite_small_getNumber(2), -- number 2
  modulo_symbol_sprites      = SNTD_nixie_tube_sprite_small_getNumber(3), -- number 3
  power_symbol_sprites       = SNTD_nixie_tube_sprite_small_getNumber(4), -- number 4
  left_shift_symbol_sprites  = SNTD_nixie_tube_sprite_small_getNumber(5), -- number 5
  right_shift_symbol_sprites = SNTD_nixie_tube_sprite_small_getNumber(6), -- number 6
  and_symbol_sprites         = SNTD_nixie_tube_sprite_small_getNumber(7), -- number 7
  or_symbol_sprites          = SNTD_nixie_tube_sprite_small_getNumber(8), -- number 8
  xor_symbol_sprites         = SNTD_nixie_tube_sprite_small_getNumber(9), -- number 9


  input_connection_bounding_box = arrow_box,
  input_connection_points = {
    {
      shadow = {
        red = {12/32, 15/32},
        green = {12/32, 19/32},
      },
      wire = {
        red = {12/32, 13/32},
        green = {12/32, 18/32},
      }
    },
    {
      shadow = {
        red = {12/32, 15/32},
        green = {12/32, 19/32},
      },
      wire = {
        red = {12/32, 13/32},
        green = {12/32, 18/32},
      }
    },
    {
      shadow = {
        red = {12/32, 15/32},
        green = {12/32, 19/32},
      },
      wire = {
        red = {12/32, 13/32},
        green = {12/32, 18/32},
      }
    },
    {
      shadow = {
        red = {12/32, 15/32},
        green = {12/32, 19/32},
      },
      wire = {
        red = {12/32, 13/32},
        green = {12/32, 18/32},
      }
    }
  },

  output_connection_bounding_box = arrow_box,
  output_connection_points = {
    {
      shadow = {
        red = {12/32, 15/32},
        green = {12/32, 19/32},
      },
      wire = {
        red = {12/32, 13/32},
        green = {12/32, 18/32},
      }
    },
    {
      shadow = {
        red = {12/32, 15/32},
        green = {12/32, 19/32},
      },
      wire = {
        red = {12/32, 13/32},
        green = {12/32, 18/32},
      }
    },
    {
      shadow = {
        red = {12/32, 15/32},
        green = {12/32, 19/32},
      },
      wire = {
        red = {12/32, 13/32},
        green = {12/32, 18/32},
      }
    },
    {
      shadow = {
        red = {12/32, 15/32},
        green = {12/32, 19/32},
      },
      wire = {
        red = {12/32, 13/32},
        green = {12/32, 18/32},
      }
    }
  },

  circuit_wire_max_distance = 9
}

data:extend{

  -- nixie-tube-small
  SNTD_nixie_tube_small_recipe,
  SNTD_nixie_tube_small_item,
  SNTD_nixie_tube_small_entity,
  SNTD_nixie_tube_small_sprite,
}

local function get_setting(name)
  return settings.startup[name] and settings.startup[name].value
end


log("collision layers:"..serpent.block(data.raw["collision-layer"]))

local light_intensity = get_setting("inlaid-lamps-extended-light_intensity")    --.9
local light_size = get_setting("inlaid-lamps-extended-light_size")              --40
local light_colored_intensity = get_setting("inlaid-lamps-extended-light_colored_intensity") --1
local light_colored_size = get_setting("inlaid-lamps-extended-light_colored_size") --6
local loc_glow_color_intensity = get_setting("inlaid-lamps-extended-loc_glow_color_intensity") --0.235
local loc_glow_size = get_setting("inlaid-lamps-extended-loc_glow_size") --6

local loc_energy_usage
do
  local light = 5 * light_intensity * light_size/36
  local color = 5 * light_colored_intensity * light_colored_size/36
  loc_energy_usage = math.ceil(math.max(light, color))
end

local lamps = data.raw["lamp"]
local lamp = lamps["small-lamp"]

log("Vanilla lamp: "..serpent.block(lamp))

-- Copy base lamp's staggering parameters, falling back to a sensible default
local loc_darkness_for_all_lamps_on = lamp.darkness_for_all_lamps_on or 0.7
local loc_darkness_for_all_lamps_off = lamp.darkness_for_all_lamps_off or 0.5

-- Enable fast replacing
lamp.fast_replaceable_group = "lamps"


local biglamp_factor = 4


local IMGPATH = "__InlaidLampsExtended__/graphics/"
local ICONPATH = IMGPATH.."icon/"
--~ local BASEIMGPATH = "__base__/graphics/entity/circuit-connector/"


local function get_iconname(lamp_name)
  return ICONPATH..lamp_name..".png"
end

local function multiply_shift(tab, factor)
  local ret = {
    x = (tab[1] or tab.x) * factor,
    y = (tab[2] or tab.y) * factor,
  }
  return ret
end


local resistances = {
  {
    type = "physical",
    decrease = 20,
    percent = 30,
  },
  {
    type = "explosion",
    decrease = 20,
    percent = 30,
  },
  {
    type = "fire",
    decrease = 20,
    percent = 30,
  },
}


------------------------------------------------------------------------------------
--                                Flat Lamp Entity                                --
------------------------------------------------------------------------------------
local lamp_name = INLAID_LAMP_NAMES.small
local small_lamp = table.deepcopy(lamp)
small_lamp.name = lamp_name
small_lamp.icon = get_iconname(lamp_name)
small_lamp.icon_size = 64

small_lamp.minable = { mining_time = 0.5, result = lamp_name }
small_lamp.corpse = "lamp-remnants"
--~ small_lamp.integration_patch_render_layer = "ground-tile"
  --~ collision_mask={"doodad-layer", "object-layer", "water-tile"},
small_lamp.collision_mask = {
  layers = { doodad = true, object = true, water_tile = true },
}
small_lamp.resistances = resistances
small_lamp.hide_resistances = false

small_lamp.collision_box = {{-0.4, -0.4}, {0.4, 0.4}}
small_lamp.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}

-- Inlaid lamps won't be damaged by vehicles, turn the vehicle impact sound off!
small_lamp.vehicle_impact_sound = nil
small_lamp.energy_usage_per_tick = "5kW"
small_lamp.light = {
  intensity = light_intensity,
  size = light_size,
  color = {r = 1.0, g = 1.0, b = 1.0}
}
small_lamp.light_when_colored = {
  intensity = light_colored_intensity,
  size = light_colored_size,
  color = {r = 1.0, g = 1.0, b = 1.0}
}

small_lamp.glow_size = loc_glow_size
small_lamp.glow_color_intensity = loc_glow_color_intensity

small_lamp.darkness_for_all_lamps_on = loc_darkness_for_all_lamps_on
small_lamp.darkness_for_all_lamps_off = loc_darkness_for_all_lamps_off

small_lamp.picture_off = {
  filename = IMGPATH.."light-off-flat.png",
  priority = "high",
  flags = { "low-object" },
  width = 90,
  height = 78,
  shift = util.by_pixel(0, -7),
  scale = 1
}

small_lamp.picture_on = table.deepcopy(small_lamp.picture_off)
small_lamp.picture_on.filename = IMGPATH.."light-on-flat.png"

small_lamp.circuit_connector = {
  sprites = {
    -- Obligatory
    led_red = {
      filename = IMGPATH.."circuit/connector-led-red.png",
      size = 12,
      priority = "low",
      shift = { -0.32, -0.34 },
      x = 0,
      y = 0
    },
    led_green = {
      filename = IMGPATH.."circuit/connector-led-green.png",
      size = 12,
      priority = "low",
      shift = { -0.32, -0.30 },
      x = 0,
      y = 0
    },
    led_blue = {
      filename = IMGPATH.."circuit/connector-led-blue.png",
      size = 12,
      priority = "low",
      shift = { -0.32, -0.32 },
      x = 0,
      y = 0
    },
    led_light = {
      intensity = 0.8,
      size = 0.9
    },

    -- Optional
    connector_main = {
      --~ filename = IMGPATH.."circuit/connector-main.png",
      --~ height = 12,
      --~ width = 12,
      filename = IMGPATH.."circuit/connector-main-new.png",
      height = 128,
      width = 12,
      scale = .5,
      priority = "low",
      --~ shift = { -0.32, -0.32 },
      shift = { -0.32, 0 },
      x = 0,
      y = 0
    },
    --~ logistic_animation = {
      --~ blend_mode = "additive",
      --~ filename = BASEIMGPATH.."circuit-connector-logistic-animation.png",
      --~ frame_count = 15,
      --~ height = 43,
      --~ line_length = 4,
      --~ priority = "low",
      --~ shift = { 0.0, 0.0 },
      --~ width = 43
    --~ },
    blue_led_light_offset = {
      0.0,
      0.0
    },
    red_green_led_light_offset = {
      -0.3,
      -0.3
    }
  },
  points = {
    wire = {
      red = {-0.32, -0.32},
      green = {-0.32, -0.32},
    },
    shadow = {
      red = {-0.32, -0.32},
      green = {-0.32, -0.32},
    },
  },
}

small_lamp.fast_replaceable_group = "lamps"

data:extend({small_lamp})
small_lamp = lamps[lamp_name]
log("Small lamp: "..serpent.block(lamps[small_lamp.name]))


------------------------------------------------------------------------------------
--                              2x2 Flat Lamp Entity                              --
------------------------------------------------------------------------------------
lamp_name = INLAID_LAMP_NAMES.big

local big_lamp = table.deepcopy(small_lamp)
big_lamp.name = lamp_name
big_lamp.icon = get_iconname(lamp_name.."-entity")
big_lamp.icon_size = 128
--~ log("big_lamp.name: "..big_lamp.name)
--~ log("big_lamp.icon: "..big_lamp.icon)
--~ error("Break!")
big_lamp.minable = {
  mining_time = small_lamp.minable.mining_time * biglamp_factor,
  result = lamp_name,
}

big_lamp.max_health = small_lamp.max_health * biglamp_factor * 0.75

big_lamp.corpse = "medium-remnants"
big_lamp.collision_box = {{-0.8, -0.8}, {0.8, 0.8}}
big_lamp.selection_box = {{-1, -1}, {1, 1}}

big_lamp.tile_height = 2
big_lamp.tile_width = 2

big_lamp.energy_usage_per_tick = "10kW"

big_lamp.light.size = 2 * small_lamp.light.size
big_lamp.light_when_colored.size = 2 * small_lamp.light_when_colored.size

big_lamp.picture_off.scale = small_lamp.picture_off.scale * 2
big_lamp.picture_off.shift = multiply_shift(small_lamp.picture_off.shift, 2)

big_lamp.picture_on.scale = small_lamp.picture_off.scale * 2
big_lamp.picture_on.shift = multiply_shift(small_lamp.picture_on.shift, 2)

big_lamp.circuit_connector = {
  sprites = {
    -- Obligatory
    led_red = {
      filename = IMGPATH.."circuit/connector-led-red.png",
      height = 12,
      width = 12,
      priority = "low",
      shift = { -0.64, -0.64 },
      x = 0,
      y = 0
    },
    led_green = {
      filename = IMGPATH.."circuit/connector-led-green.png",
      height = 12,
      width = 12,
      priority = "low",
      shift = { -0.64, -0.64 },
      x = 0,
      y = 0
    },
    led_blue = {
      filename = IMGPATH.."circuit/connector-led-blue.png",
      height = 12,
      width = 12,
      --~ priority = "low",
      --~ shift = { -0.64, -0.64 },
      --~ x = 0,
      --~ y = 0
    },
    led_light = {
      intensity = 0.8,
      size = 0.9
    },

    -- Optional
    connector_main = {
      --~ filename = IMGPATH.."circuit/connector-main.png",
      --~ height = 12,
      --~ width = 12,
      --~ priority = "low",
      --~ shift = { -0.64, -0.64 },
      --~ x = 0,
      --~ y = 0
      filename = IMGPATH.."circuit/connector-main-new.png",
      height = 128,
      width = 12,
      priority = "low",
      shift = { -0.64, -0 },
      scale = .5,
      x = 0,
      y = 0
    },
    --~ blue_led_light_offset = {
      --~ 0.0,
      --~ 0.0
    --~ },
    red_green_led_light_offset = {
      -0.6,
      -0.6
    }
  },
  points = {
    wire = {
      red = {-0.64, -0.64},
      green = {-0.64, -0.64},
    },
    shadow = {
      green = {-0.64, -0.64},
      red = {-0.64, -0.64},
    },
  },
}
big_lamp.fast_replaceable_group = nil

data:extend({big_lamp})
big_lamp = lamps[lamp_name]
log("Big lamp: "..serpent.block(big_lamp))

--~ error("Break!")
------------------------------------------------------------------------------------
if get_setting("inlaid_lamps_extended_change_energy_usage") then
  small_lamp.energy_usage_per_tick = loc_energy_usage.."kW"

  big_lamp.energy_usage_per_tick = (biglamp_factor * loc_energy_usage).."kW"
end
------------------------------------------------------------------------------------

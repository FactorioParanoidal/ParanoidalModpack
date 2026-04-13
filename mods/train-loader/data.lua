local train_loader_entity = table.deepcopy(data.raw["container"]["steel-chest"])
train_loader_entity.name = "train-loader"
train_loader_entity.minable = {result = "train-loader", mining_time = 1, count = 0}
local stored_size = tonumber(settings.startup["train_loader_inventory_size"].value) or 96
train_loader_entity.inventory_size = stored_size



-- Original 4x4 size
local small_collision_box = {{-1.8, -1.8}, {1.8, 1.8}}
local small_selection_box = {{-1.85, -1.85}, {1.85, 1.85}}

-- New 6x6 size
local large_collision_box = {{-2.8, -2.8}, {2.8, 2.8}}
local large_selection_box = {{-2.85, -2.85}, {2.85, 2.85}}

local function get_loader_specs()
    if settings.startup["use_loader_stubby_graphic"].value then
        return {
            filename = "loader-stubby",
            width = 128,
            height = 384,
            shift_y = -128,
            scale = 1,
            shadow = {
                filename = "stubby-shadow",
                width = 384,
                height = 93,
                shift_x = 141,
                shift_y = 16
            
            }
        }
    else
        return {
            filename = "loader-tall-silo",
            width = 290,
            height = 590,
            shift_y = -90,
            scale = 0.5,
            shadow = {
                filename = "tall-shadow",
                width = 600,
                height = 400,
                shift_x = 0,
                shift_y = -90
            }
        }
    end
end

local loader_specs = get_loader_specs()

local size_setting = settings.startup["train_loader_size"].value
train_loader_entity.collision_box = size_setting == "6x6" and large_collision_box or small_collision_box
train_loader_entity.selection_box = size_setting == "6x6" and large_selection_box or small_selection_box
train_loader_entity.flags = {"player-creation", "get-by-unit-number"}
train_loader_entity.icon_draw_specification = {shift = {0, -3}, scale = 1.4, scale_for_many = 2.4}
-- local loader_graphic = settings.startup["use_loader_stubby_graphic"].value and "loader-stubby" or "silo-new"
train_loader_entity.picture = {
    layers = {
        {
            filename = "__train-loader__/graphics/" .. loader_specs.filename .. ".png",
            priority = "extra-high",
            width = loader_specs.width,
            height = loader_specs.height,
            shift = util.by_pixel(0, loader_specs.shift_y),
            scale = loader_specs.scale
        },
        {
            filename = "__train-loader__/graphics/light.png",
            priority = "extra-high", 
            -- set the width to 290, or 1, if train loader is stubby
            width = settings.startup["use_loader_stubby_graphic"].value and 1 or 290,
            height = settings.startup["use_loader_stubby_graphic"].value and 1 or 656,
            shift = util.by_pixel(0, loader_specs.shift_y + 32),
            scale = 1,
            draw_as_glow = true,
            blend_mode = "additive"
        },
        {
            filename = "__train-loader__/graphics/" .. loader_specs.shadow.filename .. ".png",
            priority = "extra-high",
            draw_as_shadow = true,
            width = loader_specs.shadow.width,
            height = loader_specs.shadow.height,
            shift = util.by_pixel(loader_specs.shadow.shift_x, loader_specs.shadow.shift_y),
        }
    }
}
train_loader_entity.collision_mask = {layers = {}}
-- this is so much code to just move the circuit connector position, not sure if I'm doing something wrong
train_loader_entity.circuit_connector = {
    points = {
      shadow = {
        green = {
          0.671875,
          -0.446875
        },
        red = {
          0.859375,
          -0.446875
        }
      },
      wire = {
        green = {
          0.40625,
          -2.421875
        },
        red = {
          0.34375,
          -2.203125
        }
      }
    },
    sprites = {
      blue_led_light_offset = {
        0.09375,
        0.453125
      },
      connector_main = {
        filename = "__base__/graphics/entity/circuit-connector/ccm-universal-04a-base-sequence.png",
        height = 50,
        priority = "low",
        scale = 0.5,
        shift = {
          0.09375,
          -2.403125
        },
        width = 52,
        x = 104,
        y = 150
      },
      connector_shadow = {
        draw_as_shadow = true,
        filename = "__base__/graphics/entity/circuit-connector/ccm-universal-04b-base-shadow-sequence.png",
        height = 46,
        priority = "low",
        scale = 0.5,
        shift = {
          0.3125,
          -2.3125
        },
        width = 60,
        x = 120,
        y = 138
      },
      led_blue = {
        draw_as_glow = true,
        filename = "__base__/graphics/entity/circuit-connector/ccm-universal-04e-blue-LED-on-sequence.png",
        height = 60,
        priority = "low",
        scale = 0.5,
        shift = {
          0.09375,
          -2.371875
        },
        width = 60,
        x = 120,
        y = 180
      },
      led_blue_off = {
        filename = "__base__/graphics/entity/circuit-connector/ccm-universal-04f-blue-LED-off-sequence.png",
        height = 44,
        priority = "low",
        scale = 0.5,
        shift = {
          0.09375,
          -2.371875
        },
        width = 46,
        x = 92,
        y = 132
      },
      led_green = {
        draw_as_glow = true,
        filename = "__base__/graphics/entity/circuit-connector/ccm-universal-04h-green-LED-sequence.png",
        height = 46,
        priority = "low",
        scale = 0.5,
        shift = {
          0.09375,
          -2.371875
        },
        width = 48,
        x = 96,
        y = 138
      },
      led_light = {
        intensity = 0,
        size = 0.9
      },
      led_red = {
        draw_as_glow = true,
        filename = "__base__/graphics/entity/circuit-connector/ccm-universal-04i-red-LED-sequence.png",
        height = 46,
        priority = "low",
        scale = 0.5,
        shift = {
          0.09375,
          -2.371875
        },
        width = 48,
        x = 96,
        y = 138
      },
      red_green_led_light_offset = {
        0.09375,
        -2.359375
      },
      wire_pins = {
        filename = "__base__/graphics/entity/circuit-connector/ccm-universal-04c-wire-sequence.png",
        height = 58,
        priority = "low",
        scale = 0.5,
        shift = {
          0.09375,
          -2.403125
        },
        width = 62,
        x = 124,
        y = 174
      },
      wire_pins_shadow = {
        draw_as_shadow = true,
        filename = "__base__/graphics/entity/circuit-connector/ccm-universal-04d-wire-shadow-sequence.png",
        height = 54,
        priority = "low",
        scale = 0.5,
        shift = {
          0.390625,
          -2.54375
        },
        width = 68,
        x = 136,
        y = 162
      }
    }
  }

-- train_loader_entity.circuit_connector = {
--     shadow = {
--         red = {0, 4},
--         green = {0, 4}
--     },
--     wire = {
--         red = {0, 4},
--         green = {0, 4}
--     }
-- }

data:extend{train_loader_entity}

local train_loader_item = {
    type = "item",
    name = "train-loader",
    icon = "__base__/graphics/icons/steel-chest.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "storage",
    order = "b[storage]-b[steel-chest]",
    place_result = "train-loader",
    stack_size = 50
}

data:extend{train_loader_item}


data:extend({
    {
        type = "sprite",
        name = "custom-silo-sprite",
        layers = {
            {
                filename = "__train-loader__/graphics/" .. loader_specs.filename .. ".png",
                width = loader_specs.width,
                height = loader_specs.height,
                shift = util.by_pixel(0, loader_specs.shift_y),
                scale = loader_specs.scale
            },
            {
                filename = "__train-loader__/graphics/light.png",
                width = settings.startup["use_loader_stubby_graphic"].value and 1 or 290,
                height = settings.startup["use_loader_stubby_graphic"].value and 1 or 656,
                shift = util.by_pixel(0, loader_specs.shift_y + 32),
                scale = 1,
                draw_as_glow = true,
                blend_mode = "additive"
            },
        }
    }
})

local loader_recipe_enabled = settings.startup["train_loader_recipe_enabled"].value
local train_loader_recipe = {
    type = "recipe",
    name = "train-loader",
    enabled = loader_recipe_enabled,
    ingredients = {
        {type = "item", name = "iron-chest", amount = 2},
    },
    results = {{type = "item", name = "train-loader", amount = 1}}
}

data:extend{train_loader_recipe}

-- I really want to avoid compound entities and there has to be a better way to do this
-- but this only loads for cybersyn so it's not too bad
local invisible_inserter = table.deepcopy(data.raw["inserter"]["fast-inserter"])
invisible_inserter.name = "invisible-inserter"
invisible_inserter.minable = {result = "iron-plate", mining_time = 0.4, count = 0}
invisible_inserter.collision_box = {{-0.15, -0.15}, {0.15, 0.15}}
invisible_inserter.selection_box = {{-0.1, -0.1}, {0.1, 0.1}}
invisible_inserter.extension_speed = 0
invisible_inserter.rotation_speed = 0
invisible_inserter.hand_base_picture = {
    filename = "__core__/graphics/empty.png",
    priority = "extra-high",
    width = 1,
    height = 1,
    frame_count = 1
}
invisible_inserter.hand_closed_picture = {
    filename = "__core__/graphics/empty.png",
    priority = "extra-high",
    width = 1,
    height = 1,
    frame_count = 1
}
invisible_inserter.hand_open_picture = {
    filename = "__core__/graphics/empty.png",
    priority = "extra-high",
    width = 1,
    height = 1,
    frame_count = 1
}
invisible_inserter.platform_picture = {
    sheet = {
        filename = "__core__/graphics/empty.png",
        priority = "extra-high",
        width = 1,
        height = 1,
        frame_count = 1
    }
}
invisible_inserter.energy_source = {type = "void"}

data:extend{invisible_inserter}
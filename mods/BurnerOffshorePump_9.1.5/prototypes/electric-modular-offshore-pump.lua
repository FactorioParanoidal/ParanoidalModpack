
local name = 'electric-modular-offshore-pump'

local entity_picture = '__BurnerOffshorePump__/graphics/entity/electric-offshore-pump.png'
local icon = '__BurnerOffshorePump__/graphics/icons/'..name..'.png'

  
local placeholder = table.deepcopy(data.raw["offshore-pump"]["offshore-pump"])
placeholder.name = name..'-placeholder'
placeholder.minable = {mining_time = 1, result = name}
placeholder.pumping_speed = 20 -- 5 is 300 fluids/s, vanilla has 20 and 1200
-- placeholder.localised_name = {'burner bop placeholder'}
-- placeholder.localised_name = {'entity.burner-offshore-pump'}
placeholder.localised_name = {'entity-name.electric-modular-offshore-pump'}
placeholder.max_health = 800

local animation = require ('electric-animation')

local item = {
    type = "item",
    name = name,
    icon = icon,
    icon_size = 32,
    subgroup = "extraction-machine",
    order = "b[fluids]-b[electric-offshore-pump-mk2]",
    place_result = name..'-placeholder',
    stack_size = 20,
    localised_name = {'entity-name.'..name}
  }

local recipe = {
    type = "recipe",
    name = name,
    ingredients =
    {
      {"advanced-circuit", 5},
      {"pipe", 12},
      --{"electric-engine-unit", 4},
      {"steel-plate", 20}
    },
    result = name
  }
  
local entity = {
    type = "assembling-machine",
    name = name,
    icon = icon,
    icon_size = 32,
    flags = {"placeable-player", "placeable-off-grid"},
    
    minable = {mining_time = 0.2, result = name},
    placeable_by = {item = name, count = 1},
    
    max_health = 400,
    dying_explosion = "medium-explosion",
    corpse = "medium-remnants",
    alert_icon_shift = util.by_pixel(-3, -12),
    resistances = {{type = "fire", percent = 70}},
    fluid_boxes = {fluid_box =
    {
      base_area = 1,
      base_level = 1,
      pipe_covers = pipecoverspictures(),
      production_type = "output",
      filter = "water",
      pipe_connections =
      {
        {
          position = {0, 1},
          type = "output"
        }
      }
    }, off_when_no_fluid_recipe = false},
    collision_box = {{-0.6, -1.05}, {0.6, 0.3}},
    selection_box = {{-1, -1.49}, {1, 0.49}},
    animation = animation,
--    animation = 
--    {
--      north =
--      {
--        filename = entity_picture,
--        priority = "high",
--        shift = {0.90625, 0.0625},
--        width = 160,
--        height = 102
--      },
--      east =
--      {
--        filename = entity_picture,
--        priority = "high",
--        shift = {0.90625, 0.0625},
--        x = 160,
--        width = 160,
--        height = 102
--      },
--      south =
--      {
--        filename = entity_picture,
--        priority = "high",
--        shift = {0.90625, 0.65625},
--        x = 320,
--        width = 160,
--        height = 102
--      },
--      west =
--      {
--        filename = entity_picture,
--        priority = "high",
--        shift = {1.0, 0.0625},
--        x = 480,
--        width = 160,
--        height = 102
--      }
--    },
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound =
      {
        {
          filename = "__base__/sound/assembling-machine-t2-1.ogg",
          volume = 0.8
        },
        {
          filename = "__base__/sound/assembling-machine-t2-2.ogg",
          volume = 0.8
        }
      },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 1.5
    },
    crafting_categories = {"bop-fluids-making"},
    fixed_recipe = "bop-make-water",
    crafting_speed = 4,
    energy_source =
      -- {
        -- type = "burner",
        -- fuel_category = "chemical",
        -- effectivity = 1,
        -- fuel_inventory_size = 1,
        -- emissions_per_minute = 3
      -- },
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = 3
    },

    energy_usage = "2400kW",
    
    order = "b-o-p",
    trigger_created_entity = true,

    module_specification =
    {
      module_slots = 2
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution"}
  }
  




data:extend ({placeholder, item, recipe, entity})
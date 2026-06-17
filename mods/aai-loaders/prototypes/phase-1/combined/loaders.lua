local item_sounds = require("__base__.prototypes.item_sounds")

---@diagnostic disable: redundant-parameter
local sprite_shift = {0, -0.15} -- {0.15625, 0.0703125}
local shadow_shift = {0.4, 0.15}
local operating_mode = settings.startup["aai-loaders-mode"].value
local graphics_path = "__aai-loaders__/graphics/"
local no_lubricant_multiplier = 10
local dark_suffix = "_dark"

local heating_energy = data.raw["assembling-machine"]["assembling-machine-1"] and data.raw["assembling-machine"]["assembling-machine-1"].heating_energy or nil

-- Add item subgroup
data:extend{
  {
    type = "item-subgroup",
    name = "loader",
    group = "logistics",
    order = "b[belt]-d"
  },
}

local pipecovers = pipecoverspictures()
pipecovers.north = util.empty_sprite()

local function get_fluid(input)
  return input.fluid or "lubricant"
end

local function get_consumption(input)
  return math.ceil(math.max(0.1, input.fluid_per_minute or 1) * 100) / 100
end

local function make_loader_entity(input)
  local suffix = input.dark and dark_suffix or ""
  local structure = input.structure or "loader"
  local localised_description = operating_mode == "lubricated" and
    {"entity-description.aai-loader-lubricated-shared", tostring(get_consumption(input)), tostring(get_fluid(input))} or
    {"entity-description.aai-loader-expensive-shared"}

  local entity = {
    name = input.name,
    type = "loader-1x1",
    icons = {
      {
        icon = graphics_path .. "icons/" .. (input.icon or "loader") .. suffix .. ".png",
        icon_size = 64
      },
      {
        icon = graphics_path .. "icons/" .. (input.icon or "loader") .. "_mask" .. suffix .. ".png",
        icon_size = 64,
        tint = input.color
      }
    },
    localised_name = input.localised_name,
    localised_description = localised_description,
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {
      mining_time = 0.25, -- too fast?
      result = input.name
    },
    max_health = 300,
    filter_count = 5,
    corpse = "small-remnants",
    dying_explosion = input.transport_belt.dying_explosion,
    resistances = {
      {
        type = "fire",
        percent = 90
      }
    },
    collision_box = { {-0.4, -0.45}	, {0.4, 0.45} },
    selection_box = { {-0.5, -0.5}	, {0.5, 0.5} 	},
    drawing_box = { {-0.4, -0.4}	, {0.4, 0.4} 	},
    animation_speed_coefficient = 32,
    icon_draw_specification = {scale = 0.7},
    container_distance = 0.75, -- Default: 1.5
    -- belt_distance = 0.5, --Default1x1: 0.0  --Default2x1: 0.5
    belt_length = 0.5, -- Default: 0.5
    structure_render_layer = "object",
    -- structure_render_layer = "transport-belt-circuit-connector", --Default:"lower-object"
    belt_animation_set = input.transport_belt.belt_animation_set,
    fast_replaceable_group = input.fast_replaceable_group or "transport-belt",
    next_upgrade = input.next_upgrade or input.upgrade, -- For backwards compat
    speed = input.speed or input.transport_belt.speed,
    se_allow_in_space = input.se_allow_in_space,
    -- Integration Patch to render tiny pieces behind the belt
    integration_patch_render_layer = "decals",
    integration_patch = {
      north = util.empty_sprite(),
      east = util.empty_sprite(),
      south = util.empty_sprite(),
      west = util.empty_sprite(),
    },
    heating_energy = heating_energy,
    circuit_connector =  circuit_connector_definitions.create_vector(
      universal_connector_template,
      {
        { variation = 4, main_offset = util.by_pixel(3, 2), shadow_offset = util.by_pixel(7.5, 7.5), show_shadow = false },
        { variation = 2, main_offset = util.by_pixel(-11, -5), shadow_offset = util.by_pixel(7.5, 7.5), show_shadow = false },
        { variation = 0, main_offset = util.by_pixel(-3, -23), shadow_offset = util.by_pixel(7.5, 7.5), show_shadow = false },
        { variation = 6, main_offset = util.by_pixel(10, -17), shadow_offset = util.by_pixel(7.5, 7.5), show_shadow = false },

        { variation = 0, main_offset = util.by_pixel(-3, -23), shadow_offset = util.by_pixel(7.5, 7.5), show_shadow = false },
        { variation = 6, main_offset = util.by_pixel(10, -17), shadow_offset = util.by_pixel(7.5, 7.5), show_shadow = false },
        { variation = 4, main_offset = util.by_pixel(3, 2), shadow_offset = util.by_pixel(7.5, 7.5), show_shadow = false },
        { variation = 2, main_offset = util.by_pixel(-11, -5), shadow_offset = util.by_pixel(7.5, 7.5), show_shadow = false },
      }
    ),
    circuit_wire_max_distance = transport_belt_circuit_wire_max_distance,
    structure = {
      direction_in = {
        sheets = {
           {
            filename = graphics_path .. "entity/loader/" .. structure .. "_shadows.png",
            priority = "extra-high",
            shift = shadow_shift,
            width = 138,
            height = 79,
            scale = 0.5,
            draw_as_shadow = true
          },
          {
            filename = graphics_path .. "entity/loader/" .. structure .. suffix .. ".png",
            priority = "extra-high",
            shift = sprite_shift,
            width = 99,
            height = 117,
            scale = 0.5
          },
          {
            filename = graphics_path .. "entity/loader/" .. structure .. "_tint" .. suffix .. ".png",
            priority = "extra-high",
            shift = sprite_shift,
            width = 99,
            height = 117,
            scale = 0.5,
            tint = input.color
          },
        }
      },
      direction_out = {
        sheets = {
          {
            filename = graphics_path .. "entity/loader/" .. structure .. "_shadows.png",
            priority = "extra-high",
            shift = shadow_shift,
            width = 138,
            height = 79,
            y = 79,
            scale = 0.5,
            draw_as_shadow = true,
          },
          {
            filename = graphics_path .. "entity/loader/" .. structure .. suffix .. ".png",
            priority = "extra-high",
            shift = sprite_shift,
            width = 99,
            height = 117,
            y = 117,
            scale = 0.5
          },
          {
            filename = graphics_path .. "entity/loader/" .. structure .. "_tint" .. suffix .. ".png",
            priority = "extra-high",
            shift = sprite_shift,
            width = 99,
            height = 117,
            y = 117,
            scale = 0.5,
            tint = input.color
          }
        }
      },
      frozen_patch_in = {
        sheet = {
          filename = graphics_path .. "entity/loader/frozen/" .. structure .. ".png",
          priority = "extra-high",
          shift = sprite_shift,
          width = 99,
          height = 117,
          scale = 0.5
        }
      },
      frozen_patch_out = {
        sheet = {
          filename = graphics_path .. "entity/loader/frozen/" .. structure .. ".png",
          priority = "extra-high",
          shift = sprite_shift,
          width = 99,
          height = 117,
          y = 117,
          scale = 0.5
        }
      },
    }
  }

  if feature_flags["space_travel"] and settings.startup["aai-loaders-belt-stacking-mode"].value ~= "off" then
    entity.max_belt_stack_size = data.raw["utility-constants"]["default"].max_belt_stack_size
    entity.adjustable_belt_stack_size = true
  end

  data:extend {entity}

  return data.raw['loader-1x1'][input.name]
end

local function make_loader_pipe(input)
  local suffix = input.dark and dark_suffix or ""
  local fluid = get_fluid (input)
  local consumption = get_consumption(input)
  local pipe = {
    type = "storage-tank",
    name = input.name .. "-pipe",
    icons = {
      {
        icon = graphics_path .. "icons/" .. (input.icon or "loader")  .. suffix .. ".png",
        icon_size = 64
      },
      {
        icon = graphics_path .. "icons/" .. (input.icon or "loader") .. "_mask" .. suffix .. ".png",
        icon_size = 64,
        tint = input.color
      }
    },
    localised_name = {"aai-loader.loader-pipe-name", input.localised_name or {"entity-name." .. input.name}},
    scale_info_icons = false,
    render_layer = "higher-object-above",
    flags = {"placeable-player", "player-creation", "placeable-off-grid", "not-deconstructable", "not-blueprintable", "hide-alt-info"},
    hidden = true,
    max_health = 100,
    order = "zz",
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
    collision_mask = {layers = { }},
    selectable_in_game = false,
    selection_priority = is_debug_mode and 46 or 44, -- 45 is the default selection priority for loaders
    fluid_box =
    {
      volume = 100 + consumption,
      pipe_covers = table.deepcopy(pipecovers),
      pipe_connections = {
        {position={0, 0}, direction=defines.direction.east},
        {position={0, 0}, direction=defines.direction.west}
      },
      filter = fluid
    },
    two_direction_only = false,
    window_bounding_box = {{-0.0, 0.0}, {0.0, 1.0}},
    pictures = {
      picture = {
        east = {
          filename = "__aai-loaders__/graphics/entity/loader/pipe-straight-vertical" .. suffix .. ".png",
          priority = "extra-high",
          width = 128,
          height = 128,
          scale = 0.5
        },
        west = {
          filename = "__aai-loaders__/graphics/entity/loader/pipe-straight-vertical" .. suffix .. ".png",
          priority = "extra-high",
          width = 128,
          height = 128,
          scale = 0.5
        },
        north = util.empty_sprite(),
        south = util.empty_sprite(),
      },
      window_background = util.empty_sprite(),
      fluid_background = util.empty_sprite(),
      flow_sprite = util.empty_sprite(),
      gas_flow = util.empty_sprite(),
    },
    flow_length_in_ticks = 360,
    se_allow_in_space = true,  -- space-tile collision mask prevents fast-replacing loader
  }

  data:extend{pipe}

  return data.raw['storage-tank'][input.name .. "-pipe"]
end

local function make_loader_recipe(input)
  if not input.recipe then return end

  local recipe_template = table.deepcopy(input.recipe)

  if operating_mode == "expensive" then
    if input.unlubricated_recipe then
      recipe_template = table.deepcopy(input.unlubricated_recipe)
    else
      -- multiply
      for _, ingredient in pairs(recipe_template.ingredients) do
        ingredient.amount = ingredient.amount * no_lubricant_multiplier
      end
    end
  end

  local recipe = {
    name = recipe_template.name or input.name,
    type = "recipe",
    category = recipe_template.crafting_category,
    order = input.order or string.format("d[loader]-a%02d[%s]", input.count, input.name),
    localised_name = input.localised_name
  }

  recipe.ingredients = recipe_template.ingredients or {}
  recipe.enabled = false
  recipe.energy_required = recipe_template.energy_required
  recipe.results = {{type = "item", name = input.name, amount = 1}}

  data:extend{recipe}

  return data.raw.recipe[recipe.name]
end

local function make_loader_tech(input)
  local suffix = input.dark and dark_suffix or ""
  local name = input.technology and input.technology.name or input.name

  if not data.raw.technology[name] and input.technology then
    local localised_description = operating_mode == "lubricated" and
      {"technology-description.aai-loader-lubricated-shared", tostring(get_consumption(input)), tostring(get_fluid(input))} or
      {"technology-description.aai-loader-expensive-shared"}

    local tech = {
      name = name,
      type = "technology",
      icons = {
        {
          icon = graphics_path .. "technology/loader-tech-icon" .. suffix .. ".png" ,
          icon_size = 256
        },
        {
          icon = graphics_path .. "technology/loader-tech-icon_mask" .. suffix .. ".png",
          icon_size = 256, tint = input.color}
      },
      order = input.order or string.format("d[loader]-a%02d[%s]", input.count, input.name),
      localised_name = input.localised_name,
      localised_description = localised_description
    }

    tech.unit = input.technology.unit
    tech.upgrade = false
    tech.prerequisites = input.technology.prerequisites or {}

    if operating_mode == "lubricated" and input.fluid_technology_prerequisites then
      for _, prereq in pairs(input.fluid_technology_prerequisites) do
        tech.prerequisites = tech.prerequisites or { }
        table.insert(tech.prerequisites, prereq)
      end
    end

    data:extend{tech}

    return data.raw.technology[name]
  else
    return data.raw.technology[name]
  end
end

local function make_loader_item(input)
  local suffix = input.dark and dark_suffix or ""
  local localised_description = operating_mode == "lubricated" and
    {"entity-description.aai-loader-lubricated-shared", tostring(get_consumption(input)), tostring(get_fluid(input))} or
    {"entity-description.aai-loader-expensive-shared"}

  data:extend{
    {
      name = input.name,
      type = "item",
      icons = {
        {
          icon = graphics_path .. "icons/" .. (input.icon or "loader") .. suffix .. ".png",
          icon_size = 64
        },
        {
          icon = graphics_path .. "icons/" .. (input.icon or "loader") .. "_mask" .. suffix .. ".png",
          icon_size = 64,
          tint = input.color
        }
      },
      localised_name = input.localised_name,
      localised_description = localised_description,
      stack_size = 50,
      default_import_location = input.default_import_location,
      subgroup = input.subgroup or "loader",
      order = input.order or string.format("d[loader]-a%02d[%s]", input.count, input.name),
      place_result = input.name,
      pick_sound = item_sounds.mechanical_inventory_pickup,
      drop_sound = item_sounds.mechanical_inventory_move,
      inventory_move_sound = item_sounds.mechanical_inventory_move,
      color_hint = data.raw.item[input.transport_belt.name].color_hint,
    }
  }
  return data.raw.item[input.name]
end

AAILoaders = AAILoaders or {}
AAILoaders.loader_count = 0

function AAILoaders.make_tier(input)
  -- Do nothing if in graphics-only mode
  if operating_mode == "graphics-only" then return end

  if not input.name then
    debug_log("AAI Loader Error: name field is required.")
    return
  end

  debug_log("Beginning to create AAI Loader: " .. input.name)

  if input.name == "" then
    -- Basic loader will get this name
    input.name = "aai-loader"
  else
    input.name = "aai-" .. input.name .. "-loader"
  end

  if not input.transport_belt then
    debug_log ("Error: no transport belt name provided; `transport_belt` field is required.")
    return
  elseif not data.raw['transport-belt'][input.transport_belt] then
    debug_log ("Error: bad transport belt name provided; `transport_belt` field is required.")
    return
  end
  input.transport_belt = data.raw['transport-belt'][input.transport_belt]

  if not input.recipe then
    debug_log ("Error: `recipe` field is required.")
    return
  end

  if not input.speed then
    debug_log ("No speed input provided: using value from transport belt.")
  end

  if not input.color then
    debug_log ("No color input provided: using default color.")
    input.color = { r = 1.0, g = 1.0, b = 1.0 }
  end

  if not input.technology then
    if not data.raw.technology[input.name] then
      debug_log("No technology input provided: loaders won't be avaivable to unlock.")
    else
      debug_log(string.format("No `technology` field provided: loaders will be added to existing tecnology: %s.", input.name))
    end
  end

  if input.localise then
    input.localised_name = {
      "aai-loader.loader-name",
      (input.transport_belt.localised_name or {"entity-name." .. input.transport_belt.name})
    }
  end
  --refine the escape clauses some more? add validation to the input beyond it's existance?

  AAILoaders.loader_count = AAILoaders.loader_count + 1
  input.count = AAILoaders.loader_count

  local entity = make_loader_entity(input)
  local item = make_loader_item(input)
  local recipe = make_loader_recipe(input)
  local tech = make_loader_tech(input)

  if operating_mode == "lubricated" then
    make_loader_pipe(input)
  end

  if tech and recipe then
    tech.effects = tech.effects or {}
    table.insert(tech.effects, {type="unlock-recipe", recipe=recipe.name})
  end

  return {loader=entity, item=item, recipe=recipe, technology=tech}
end

--local resource_autoplace = require("resource-autoplace")
--local sounds = require("prototypes.entity.sounds")
local simulations = require("__base__.prototypes.factoriopedia-simulations")

--local resource = require("__base__.prototypes.entity.resources")
local resource_autoplace = require("lib.resource-autoplace")

-- local function resource(resource_parameters, autoplace_parameters)
--   return
--   {
--     type = "resource",
--     name = resource_parameters.name,
--     icon = "__muluna-graphics__/graphics/icons/" .. resource_parameters.name .. ".png",
--     flags = {"placeable-neutral"},
--     order="a-b-"..resource_parameters.order,
--     tree_removal_probability = 0.8,
--     tree_removal_max_distance = 32 * 32,
--     minable = resource_parameters.minable or
--     {
--       mining_particle = resource_parameters.name .. "-particle",
--       mining_time = resource_parameters.mining_time,
--       result = resource_parameters.name
--     },
--     category = resource_parameters.category,
--     subgroup = resource_parameters.subgroup,
--     walking_sound = resource_parameters.walking_sound,
--     driving_sound = resource_parameters.driving_sound,
--     collision_mask = resource_parameters.collision_mask,
--     collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
--     selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
--     autoplace = resource_autoplace.resource_autoplace_settings
--     {
--       name = resource_parameters.name,
--       order = resource_parameters.order,
--       base_density = autoplace_parameters.base_density,
--       base_spots_per_km = autoplace_parameters.base_spots_per_km2,
--       has_starting_area_placement = true,
--       regular_rq_factor_multiplier = autoplace_parameters.regular_rq_factor_multiplier,
--       starting_rq_factor_multiplier = autoplace_parameters.starting_rq_factor_multiplier,
--       candidate_spot_count = autoplace_parameters.candidate_spot_count,
--       tile_restriction = autoplace_parameters.tile_restriction
--     },
--     stage_counts = {15000, 9500, 5500, 2900, 1300, 400, 150, 80},
--     stages =
--     {
--       sheet =
--       {
--         filename = "__muluna-graphics__/graphics/entities/" .. resource_parameters.name .. "/" .. resource_parameters.name .. ".png",
--         priority = "extra-high",
--         size = 128,
--         frame_count = 8,
--         variation_count = 8,
--         scale = 0.5
--       }
--     },
--     map_color = resource_parameters.map_color,
--     mining_visualisation_tint = resource_parameters.mining_visualisation_tint,
--     factoriopedia_simulation = resource_parameters.factoriopedia_simulation
--   }
-- end

local resource = Muluna.resource






local u_ore_order = table.deepcopy(data.raw["autoplace-control"]["uranium-ore"].order)

if mods["any-planet-start"] then if settings.startup["aps-planet"].value == "muluna" then
  u_ore_order = "aaa"
end end


Muluna:extend {{
    type = "autoplace-control",
    category = "resource",
    name = "oxide-asteroid-chunk",
    localised_name = {"", "[item=oxide-asteroid-chunk]", " ",{"entity-name.oxide-asteroid-chunk"}},
    order = u_ore_order.."00",
    richness = true
}}
Muluna:extend {{
    type = "autoplace-control",
    category = "resource",
    name = "metallic-asteroid-chunk",
    localised_name = {"","[item=metallic-asteroid-chunk]" ," ",{"entity-name.metallic-asteroid-chunk"}},
    order = u_ore_order.."01",
    richness = true
}}
Muluna:extend {{
    type = "autoplace-control",
    category = "resource",
    name = "carbonic-asteroid-chunk",
    localised_name = {"", "[item=carbonic-asteroid-chunk]"," ", {"entity-name.carbonic-asteroid-chunk"}},
    order = u_ore_order.."02",
    richness = true
}}
Muluna:extend {{
  type = "autoplace-control",
  category = "resource",
  name = "anorthite-chunk",
  localised_name = {"", "[item=anorthite-chunk]"," ", {"item-name.anorthite-chunk"}},
  order = u_ore_order.."03",
  richness = true
}}
-- Muluna:extend {{
--   type = "autoplace-control",
--   category = "resource",
--   name = "helium",
--   localised_name = {"", "[fluid=helium]"," ", {"fluid-name.helium"}},
--   order = u_ore_order.."04",
--   richness = true
-- }}
if mods["cupric-asteroids"] then
  Muluna:extend {{
    type = "autoplace-control",
    category = "resource",
    name = "cupric-asteroid-chunk",
    localised_name = {"", "[item=cupric-asteroid-chunk]"," ", {"entity-name.cupric-asteroid-chunk"}},
    order = u_ore_order.."05",
    richness = true
}}
end

Muluna:extend {{
  type = "autoplace-control",
  category = "terrain",
  name = "lunar_rocks",
  --localised_name = {"entity-name.lunar-rock"},
  order = u_ore_order.."5",
  richness = true
}}

-- local coral_variants = {}
-- for i = 1, 3 do
--     coral_variants[i] = {
--         filename = "__maraxsis__/graphics/icons/coral-" .. i .. ".png",
--         width = 64,
--         height = 64,
--         scale = 0.65,
--         flags = {"icon"},
--     }
-- end

local metal_ore = table.deepcopy(data.raw["resource"]["iron-ore"])
local carbon_ore = table.deepcopy(data.raw["resource"]["coal"])
local ice_ore = table.deepcopy(data.raw["resource"]["copper-ore"])
local helium = table.deepcopy(data.raw["resource"]["crude-oil"])

metal_ore.name = "metallic-asteroid-chunk"
carbon_ore.name = "carbonic-asteroid-chunk"
ice_ore.name = "oxide-asteroid-chunk"
helium.name = "helium"
ice_ore.factoriopedia_simulation ={ init = make_resource("oxide-asteroid-chunk") }


metal_ore.icon = data.raw["item"]["metallic-asteroid-chunk"].icon
carbon_ore.icon = data.raw["item"]["carbonic-asteroid-chunk"].icon
ice_ore.icon = data.raw["item"]["oxide-asteroid-chunk"].icon
--helium.icon =  data.raw["fluid"]["helium-4"].icon



metal_ore.localised_name = {"entity-name.metallic-asteroid-chunk"}
carbon_ore.localised_name = {"entity-name.carbonic-asteroid-chunk"}
ice_ore.localised_name = {"entity-name.oxide-asteroid-chunk"}
helium.localised_name = {"fluid-name.helium"}


metal_ore.name = "metallic-asteroid-chunk"
carbon_ore.name = "carbonic-asteroid-chunk"
ice_ore.name = "oxide-asteroid-chunk"
helium.name = "helium"


ice_ore.map_color = {0.50, 0.50, 1}
helium.map_color = {r=0.2, g=0.6, b=0.2}

ice_ore.stages =
{
  sheet =
  {
    filename = "__muluna-graphics__/graphics/entities/oxide-asteroid-ore/oxide-asteroid-ore.png",
    priority = "extra-high",
    size = 128,
    frame_count = 8,
    variation_count = 8,
    scale = 0.5,
  }
}

local ice_ore_particle = table.deepcopy(data.raw["optimized-particle"]["copper-ore-particle"])
ice_ore_particle.name = "carbonic-asteroid-chunk-particle"
Muluna.rro.deep_replace(ice_ore,"copper-ore-particle","carbonic-asteroid-chunk-particle")
ice_ore_particle.pictures = {
    {
      filename = "__muluna-graphics__/graphics/particle/ice-ore-particle/ice-ore-particle-1.png",
      priority = "extra-high",
      width = 32,
      height = 32,
      scale = 0.5
    },
    {
      filename = "__muluna-graphics__/graphics/particle/ice-ore-particle/ice-ore-particle-2.png",
      priority = "extra-high",
      width = 32,
      height = 32,
      scale = 0.5
    },
    {
      filename = "__muluna-graphics__/graphics/particle/ice-ore-particle/ice-ore-particle-3.png",
      priority = "extra-high",
      width = 32,
      height = 32,
      scale = 0.5
    },
    {
      filename = "__muluna-graphics__/graphics/particle/ice-ore-particle/ice-ore-particle-4.png",
      priority = "extra-high",
      width = 32,
      height = 32,
      scale = 0.5
    }
  }

  local anorthite_chunk_particle = table.deepcopy(data.raw["optimized-particle"]["copper-ore-particle"])
  anorthite_chunk_particle.name="anorthite-chunk-particle"


  anorthite_chunk_particle.pictures = {
    {
      filename = "__muluna-graphics__/graphics/particle/grayscale-particle/grayscale-particle-1.png",
      priority = "extra-high",
      width = 32,
      height = 32,
      scale = 0.5
    },
    {
      filename = "__muluna-graphics__/graphics/particle/grayscale-particle/grayscale-particle-2.png",
      priority = "extra-high",
      width = 32,
      height = 32,
      scale = 0.5
    },
    {
      filename = "__muluna-graphics__/graphics/particle/grayscale-particle/grayscale-particle-3.png",
      priority = "extra-high",
      width = 32,
      height = 32,
      scale = 0.5
    },
    {
      filename = "__muluna-graphics__/graphics/particle/grayscale-particle/grayscale-particle-4.png",
      priority = "extra-high",
      width = 32,
      height = 32,
      scale = 0.5
    }
  }

-- local ice_ore = resource(
--     {
--       name = "ice",
--       order = "b",
--       map_color = {0.415, 0.525, 0.580},
--       mining_time = 1,
--       --walking_sound = sounds.ore,
--       --driving_sound = stone_driving_sound,
--       mining_visualisation_tint = {r = 0.895, g = 0.965, b = 1.000, a = 1.000}, -- #e4f6ffff
--       factoriopedia_simulation = simulations.factoriopedia_iron_ore,
--     },
--     {
--       base_density = 10,
--       regular_rq_factor_multiplier = 1.10,
--       starting_rq_factor_multiplier = 1.5,
--       candidate_spot_count = 62, -- To match 0.17.50 placement
--     }
--   )

metal_ore.minable.result = "metallic-asteroid-chunk"
carbon_ore.minable.result = "carbonic-asteroid-chunk"
ice_ore.minable.result = "oxide-asteroid-chunk"
helium.minable.results[1].name = "helium"

metal_ore.minable.mining_time = 10
carbon_ore.minable.mining_time = 10
ice_ore.minable.mining_time = 10

metal_ore.autoplace.control = "metallic-asteroid-chunk"
carbon_ore.autoplace.control = "carbonic-asteroid-chunk"
ice_ore.autoplace.control = "oxide-asteroid-chunk"
helium.autoplace.control = "helium"

carbon_ore.map_color = {15,15,15}
--Autoplace settings

metal_ore.autoplace = resource_autoplace.resource_autoplace_settings
    { --Copied from iron ore
      name = "metallic-asteroid-chunk",
      order = "b",
      base_density = 10,
      --size_multiplier = 4,
      regular_rq_factor_multiplier = 1*1.10,
      starting_rq_factor_multiplier = 1.5,
      candidate_spot_count = 22, -- To match 0.17.50 placement
      --richness_distance_factor = 0, --Added to eliminate influence of distance on richness
      --distance_add = 400,
      richness_post_multiplier = 0.1,
      has_starting_area_placement = true,
    }

carbon_ore.autoplace = resource_autoplace.resource_autoplace_settings

    {
      name = "carbonic-asteroid-chunk",
      order = "b",
      base_density = 8,
      --size_multiplier = 4,
      regular_rq_factor_multiplier = 1*1.0,
      starting_rq_factor_multiplier = 1.1,
      --richness_distance_factor = 0,
      --distance_add = 400,
      richness_post_multiplier = 0.1,
      has_starting_area_placement = true,
      frequency_multiplier = 2
    }

ice_ore.autoplace = resource_autoplace.resource_autoplace_settings
    { --Copied from copper
      name = "oxide-asteroid-chunk",
      order = "b",
      base_density = 8,
      --size_multiplier = 4,
      regular_rq_factor_multiplier = 1*1.10,
      starting_rq_factor_multiplier = 1.2,
      candidate_spot_count = 22, -- To match 0.17.50 placement
      --richness_distance_factor = 0,
      --distance_add = 400,
      richness_post_multiplier = 0.1,
      has_starting_area_placement = true,
      frequency_multiplier = 4
    }

helium.autoplace = resource_autoplace.resource_autoplace_settings
    {
      name = "helium",
      order = "c", -- Other resources are "b"; oil won't get placed if something else is already there.
      base_density = 8.2,
      base_spots_per_km2 = 1.8,
      random_probability = 1/48,
      random_spot_size_minimum = 1,
      random_spot_size_maximum = 1, -- don't randomize spot size
      additional_richness = 220000, -- this increases the total everywhere, so base_density needs to be decreased to compensate
      has_starting_area_placement = false,
      regular_rq_factor_multiplier = 1,
      --richness_distance_factor = 0,
    }

--local anorthite=table.deepcopy(data.raw["resource"]["calcite"])

local anorthite=resource(
  {
    name = "anorthite-chunk",
    order = "b",
    map_color = {0.700, 0.700, 0.700},
    mining_time = 1,
    --walking_sound = sounds.ore,
    --driving_sound = stone_driving_sound,
    mining_visualisation_tint = {r = 0.900, g = 0.900, b = .900, a = 1.000}, -- #e4f6ffff
    --factoriopedia_simulation = simulations.factoriopedia_iron_ore,
  },
  {
    base_density = 10,
    regular_rq_factor_multiplier = 1.10,
    starting_rq_factor_multiplier = 1.5,
    candidate_spot_count = 52, -- To match 0.17.50 placement
    richness_post_multiplier = 0.1,
    has_starting_area_placement = true,
    --richness_distance_factor = 0,
    --distance_add = 1000,
  }
)

anorthite.minable.result= "anorthite-chunk"
anorthite.minable.mining_time = 10
anorthite.autoplace.control="anorthite-chunk"
anorthite.factoriopedia_simulation ={ init = make_resource("anorthite-chunk") }
string.gsub(anorthite.factoriopedia_simulation.init,"oxide%-asteroid%-chunk","anorthite-chunk")
anorthite.icons=nil
anorthite.icon="__muluna-graphics__/graphics/icons/anorthite-chunk.png"
anorthite.stages =
{
  sheet =
  {
    filename = "__muluna-graphics__/graphics/entities/oxide-asteroid-ore/grayscale-ore.png",
    priority = "extra-high",
    size = 128,
    frame_count = 8,
    variation_count = 8,
    scale = 0.5,
  }
}

if mods["cupric-asteroids"] then
  local cupric=resource(
  {
    name = "cupric-asteroid-chunk",
    order = "b",
    map_color = data.raw["resource"]["copper-ore"].map_color, -- {0.700, 0.700, 0.700},
    mining_time = 1,
    --walking_sound = sounds.ore,
    --driving_sound = stone_driving_sound,
    mining_visualisation_tint = {r = 0.900, g = 0.900, b = .900, a = 1.000}, -- #e4f6ffff
    --factoriopedia_simulation = simulations.factoriopedia_iron_ore,
  },
  {
    base_density = 4,
    regular_rq_factor_multiplier = 1.10,
    starting_rq_factor_multiplier = 1.5,
    candidate_spot_count = 112, -- To match 0.17.50 placement
  }
)
cupric.minable.result= "cupric-asteroid-chunk"
cupric.minable.mining_time = 20
cupric.autoplace.control="cupric-asteroid-chunk"
cupric.icons=nil
cupric.icon=data.raw["item"]["cupric-asteroid-chunk"].icon
cupric.stages = data.raw["resource"]["copper-ore"].stages
local cupric_chunk_particle = table.deepcopy(data.raw["optimized-particle"]["copper-ore-particle"])
cupric_chunk_particle.name="cupric-asteroid-chunk-particle"
Muluna:extend{cupric,cupric_chunk_particle}
end
-- ice_ore.autoplace = {
--     control = "ice",
--     default_enabled = false,
--     force = "neutral",
--     order = "z",
--     placement_density = 1,
--     probability_expression = "maraxsis_coral_ore",
--     richness_expression = [[var("control:maraxsis-coral:richness") * random_penalty(x, y, 9232 + (sqrt(x*x + y*y) / 10), 99, 1000)]],
-- }

Muluna:extend{metal_ore,carbon_ore,ice_ore,ice_ore_particle,anorthite,anorthite_chunk_particle}
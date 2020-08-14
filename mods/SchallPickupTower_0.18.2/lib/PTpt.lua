local PTlib = require("lib.PTlib")
local cfg1 = require("config.config-1")



local PTpt = {}

PTpt.debuglog = PTlib.debuglog


function PTpt.PT_item_name(tier)
  return cfg1.pickuptower_name .. "-R" .. cfg1.PT_range(tier)
end

function PTpt.PT_upper_itemname(tier)
  return cfg1.pickuptower_name .. "-R" .. cfg1.PT_range(tier) .. cfg1.pickuptower_name_upper_suffix
end

function PTpt.PT_tech_name(tier)
  return cfg1.pickuptower_name .. "-" .. tier
end

function PTpt.PT_item_icons(tier)
  return
  {
    PTlib.PT_icon_layer,
    PTlib.tier_icon_layer(tier)
  }
end

function PTpt.PT_item_name_table_replace(rt)
  for k, v in pairs(rt) do
    rt[k][1] = v[1]:gsub("__PT__(%d+)__", PTpt.PT_item_name)
  end
end

function PTpt.PT_tech_name_table_replace(rt)
  for k, v in pairs(rt) do
    rt[k] = v:gsub("__PT__(%d+)__", PTpt.PT_tech_name)
  end
end



-- Pickup Tower Graphics
function PTpt.pickup_tower_sheet(inputs)
return
{
  layers = 
  {
    {
      filename = "__SchallPickupTower__/graphics/entity/pickup-tower-sheet.png",
      priority = "high",
      scale = inputs.scale or 0.5,
      width = 320,
      height = 320,
      direction_count = inputs.direction_count and inputs.direction_count or 16, --64,
      -- frame_count = inputs.frame_count or 16, --1,
      line_length = inputs.line_length and inputs.line_length or 4, --8,
      run_mode = inputs.run_mode and inputs.run_mode or "forward",
      shift = inputs.shift or {0.85, -1.1}, --{0.87, -1.1}, --{-0.03, -0.4}, --{0, 0},
      axially_symmetrical = false,
    }
  }
}
end


function PTpt.pickup_tower_base_sheet(inputs)
return
{
  layers =
  {
    data.raw["container"][inputs.chest_type].picture,
    {
      filename = "__SchallPickupTower__/graphics/entity/pickup-tower-base.png",
      priority = "medium",
      scale = inputs.scale or 0.5,
      width = 320,
      height = 320,
      -- direction_count = inputs.direction_count and inputs.direction_count or 16, --64,
      -- frame_count = inputs.frame_count or 16, --1,
      -- line_length = inputs.line_length and inputs.line_length or 4, --8,
      -- run_mode = inputs.run_mode and inputs.run_mode or "forward",
      shift = inputs.shift or {0.85, -1.1}, --{0.87, -1.1}, --{-0.03, -0.4}, --{0, 0},
      axially_symmetrical = false,
    }
  }
}
end



-- Pickup Tower Prototypes
function PTpt.PT_item_1(tier)
  local name = PTpt.PT_item_name(tier)
  local item =
  {
    type = "item",
    name = name,
    icons = PTpt.PT_item_icons(tier),
    subgroup = "storage",
    -- subgroup = "logistic-network",
    order = "i[pickup]-"..tier,
    place_result = name,
    stack_size = 20
  }
  return item
end


function PTpt.PT_item_2(tier)
  local name = PTpt.PT_upper_itemname(tier)
  local item =
  {
    type = "item",
    name = name,
    icons = PTpt.PT_item_icons(tier),
    flags = {"hidden"},
    subgroup = "storage",
    -- subgroup = "logistic-network",
    order = "i[pickup]-"..tier,
    place_result = name,
    stack_size = 20
  }
  return item
end


function PTpt.PT_entity_1(tier)
  local name = PTpt.PT_item_name(tier)
  local range = cfg1.PT_range(tier)
  local interval = cfg1.PT_interval(tier)
  local energy_usage = cfg1.PT_energy_usage(tier)
  local energy_per_sector = cfg1.PT_energy_per_sector(tier)
  local enty =
  {
    type = "container",
    -- type = "logistic-container",
    name = name,
    icons = PTpt.PT_item_icons(tier),
    localised_description = PTlib.PT_localised_description(range, interval, energy_usage),
    flags = {"placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = name},
    -- render_layer = "lower-object-above-shadow",
    -- final_render_layer = "decorative",
    -- render_layer = "decorative",
    max_health = 350,
    corpse = "medium-remnants",
    collision_box = {{ -0.7, -0.7}, {0.7, 0.7}},
    selection_box = {{ -1, -1}, {1, 1}},
    resistances =
    {
      {
        type = "fire",
        percent = 90
      },
      {
        type = "impact",
        percent = 60
      }
    },
    -- fast_replaceable_group = "container",
    inventory_size = 40,
    -- logistic_mode = "passive-provider",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    picture = PTpt.pickup_tower_base_sheet{chest_type = "steel-chest"},
    -- picture = data.raw["container"]["steel-chest"].picture,
    vector_to_place_result = {0.5, -1.35},--{0, -1.85},
    radius_visualisation_specification =
    {
      sprite = 
      {
        filename = "__SchallPickupTower__/graphics/entity/pickup-tower-radius.png",
        priority = "medium",
        width = 64,
        height = 64,
        scale = 0.5
      },
      distance = range,
      -- offset = {0, 0}
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = default_circuit_wire_max_distance
  }
  return enty
end


function PTpt.PT_entity_2(tier)
  local name = PTpt.PT_upper_itemname(tier)
  local range = cfg1.PT_range(tier)
  local interval = cfg1.PT_interval(tier)
  local energy_usage = cfg1.PT_energy_usage(tier)
  local energy_per_sector = cfg1.PT_energy_per_sector(tier)
  local enty =
  {
    type = "radar",
    name = name,
    icons = PTpt.PT_item_icons(tier),
    localised_description = PTlib.PT_localised_description(range, interval, energy_usage),
    flags = {"not-blueprintable", "not-deconstructable", "placeable-off-grid"},
    -- minable = {hardness = 0.2, mining_time = 0.5, result = PTpt.PT_item_name(tier)},
    create_ghost_on_death = false,
    -- render_layer = "higher-object-above",
    -- final_render_layer = "higher-object-above",
    max_health = 350,
    -- corpse = "medium-remnants",
    collision_mask = {"water-tile"}, --nil,
    -- collision_box = {{ -0.7, -0.7}, {0.7, 0.7}},
    collision_box = {{0, 0}, {0, 0}},
    -- selection_box = {{ -1, -1}, {1, 1}},
    selection_box = {{0, 0}, {0, 0}},
    -- selection_box = {{-2, -2}, {0, 0}}, -- For debug only
    drawing_box = {{ -1, -1.01}, {1, 0.99}},
    -- drawing_box = {{ -1, -1}, {1, 1}},
    resistances =
    {
      {
        type = "fire",
        percent = 90
      },
      {
        type = "impact",
        percent = 60
      }
    },
    energy_per_sector = energy_per_sector.."J", --"7.5MJ",
    max_distance_of_sector_revealed = 0,
    max_distance_of_nearby_sector_revealed = tier, --1,
    energy_per_nearby_scan = "250kJ",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_usage = energy_usage.."W", --"250kW",
    pictures = PTpt.pickup_tower_sheet{}
  }
  return enty
end


function PTpt.PT_recipe(tier, specs)
  local itemname = PTpt.PT_item_name(tier)
  local itemnameprev = PTpt.PT_item_name(tier-1)
  local rcp = table.deepcopy(specs.recipe[tier])
  rcp.type = "recipe"
  rcp.name = itemname
  if rcp.normal then
    rcp.normal.enabled = rcp.normal.enabled or false
    rcp.normal.result = itemname
    PTpt.PT_item_name_table_replace(rcp.normal.ingredients)
    rcp.expensive.enabled = rcp.expensive.enabled or false
    rcp.expensive.result = itemname
    PTpt.PT_item_name_table_replace(rcp.expensive.ingredients)
  else
    rcp.enabled = rcp.enabled or false
    rcp.result = itemname
    PTpt.PT_item_name_table_replace(rcp.ingredients)
  end
  return rcp
end


function PTpt.PT_technology(tier, specs)
  local techname = PTpt.PT_tech_name(tier)
  local technameprev = PTpt.PT_tech_name(tier-1)
  local itemname = PTpt.PT_item_name(tier)
  local tech = table.deepcopy(specs.technology[tier])
  tech.type = "technology"
  tech.name = techname
  tech.icons = { PTlib.PT_tech_icon_layer }
  tech.effects = { { type = "unlock-recipe", recipe = itemname } }
  tech.upgrade = true
  tech.order = "c-e-c"
  PTpt.PT_tech_name_table_replace(tech.prerequisites)
  return tech
end



return PTpt
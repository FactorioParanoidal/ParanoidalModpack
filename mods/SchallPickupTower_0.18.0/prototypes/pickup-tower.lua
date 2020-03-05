local pickup_tower_icon_layer = {icon = "__SchallPickupTower__/graphics/icons/pickup-tower.png", icon_size = 128, icon_mipmaps = 3}
local pickup_tower_tech_layer = {icon = "__SchallPickupTower__/graphics/technology/pickup-tower.png", icon_size = 128}
local tier_icon_layer = {
  [1] = {icon = "__SchallPickupTower__/graphics/icons/mk1.png", icon_size = 128, icon_mipmaps = 3},
  [2] = {icon = "__SchallPickupTower__/graphics/icons/mk2.png", icon_size = 128, icon_mipmaps = 3},
  [3] = {icon = "__SchallPickupTower__/graphics/icons/mk3.png", icon_size = 128, icon_mipmaps = 3},
  [4] = {icon = "__SchallPickupTower__/graphics/icons/mk4.png", icon_size = 128, icon_mipmaps = 3},
}



-- Pickup Tower Graphics
function pickup_tower_sheet(inputs)
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


function pickup_tower_base_sheet(inputs)
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
local function create_tower_item_1(tier)
  local range = tier * 32
  local item =
  {
    type = "item",
    name = "Schall-pickup-tower-R"..range,
    icons = { pickup_tower_icon_layer,
              tier_icon_layer[tier] },
    subgroup = "storage",
    -- subgroup = "logistic-network",
    order = "i[pickup]-"..tier,
    place_result = "Schall-pickup-tower-R"..range,
    stack_size = 20
  }
  return item
end


local function create_tower_item_2(tier)
  local range = tier * 32
  local item =
  {
    type = "item",
    name = "Schall-pickup-tower-R"..range.."-upper",
    icons = { pickup_tower_icon_layer,
              tier_icon_layer[tier] },
    flags = {"hidden"},
    subgroup = "storage",
    -- subgroup = "logistic-network",
    order = "i[pickup]-"..tier,
    place_result = "Schall-pickup-tower-R"..range.."-upper",
    stack_size = 20
  }
  return item
end


local function create_tower_entity_1(tier)
  local range = tier * 32
  local entity =
  {
    type = "container",
    -- type = "logistic-container",
    name = "Schall-pickup-tower-R"..range,
    icons = { pickup_tower_icon_layer,
              tier_icon_layer[tier] },
    flags = {"placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "Schall-pickup-tower-R"..range},
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
    picture = pickup_tower_base_sheet{chest_type = "steel-chest"},
    -- picture = data.raw["container"]["steel-chest"].picture,
    -- picture = pickup_tower_sheet_logistics{filename = "__base__/graphics/entity/logistic-chest/logistic-chest-storage.png"},
    -- "__base__/graphics/entity/logistic-chest/logistic-chest-passive-provider.png"
    vector_to_place_result = {0.5, -1.35},--{0, -1.85},
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = default_circuit_wire_max_distance
  }
  return entity
end


local function create_tower_entity_2(tier)
  local range = tier * 32
  local energy_usage = 0.250 * tier^2 -- "MW"
  local energy_per_sector = energy_usage * 30 * tier --"MJ"
  local entity =
  {
    type = "radar",
    name = "Schall-pickup-tower-R"..range.."-upper",
    icons = { pickup_tower_icon_layer,
              tier_icon_layer[tier] },
    flags = {"not-blueprintable", "not-deconstructable", "placeable-off-grid"},
    -- minable = {hardness = 0.2, mining_time = 0.5, result = "Schall-pickup-tower-R"..range},
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
    energy_per_sector = energy_per_sector.."MJ", --"7.5MJ",
    max_distance_of_sector_revealed = 0,
    max_distance_of_nearby_sector_revealed = tier, --1,
    energy_per_nearby_scan = "250kJ",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_usage = energy_usage.."MW", --"250kW",
    pictures = pickup_tower_sheet{}
  }
  return entity
end


local function create_tower_recipe(tier)
  local range = tier * 32
  local rangeprev = (tier-1) * 32
  local itemname = "Schall-pickup-tower-R"..range
  local itemnameprev = "Schall-pickup-tower-R"..rangeprev
  local recipe = {
    type = "recipe",
    name = itemname,
    -- icons = { pickup_tower_icon_layer,
    --           tier_icon_layer[tier] },
    -- order = "i[pickup]-"..tier,
    enabled = false,
    -- energy_required = 10,
    -- ingredients = {
    --   {"radar", 1},
    --   {"steel-chest", 1},
    --   {"advanced-circuit", 10}
    -- },
    result = itemname
  }
  if tier == 1 then
    recipe.energy_required = 10
    recipe.ingredients = {
      {"radar", 1},
      {"steel-chest", 1},
      {"advanced-circuit", 10}
    }
  else
    recipe.energy_required = 10 + 20 * (tier-1)
    recipe.ingredients = {
      {itemnameprev, 4},
      {"advanced-circuit", 10}
    }
  end
  return recipe
end


local function create_tower_technology(tier)
  local range = tier * 32
  local techname = "Schall-pickup-tower-"..tier
  local technameprev = "Schall-pickup-tower-"..tier-1
  local itemname = "Schall-pickup-tower-R"..range
  local tech = {
    type = "technology",
    name = techname,
    icons = { pickup_tower_tech_layer },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = itemname
      }
    },
    -- prerequisites = {"electric-energy-distribution-2"},
    unit =
    {
      count = 150,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1}
      },
      time = 30
    },
    upgrade = true,
    order = "c-e-c"
  }
  if tier == 1 then
    tech.prerequisites = {"electric-energy-distribution-2"}
    tech.unit.count = 150
  else
    tech.prerequisites = {technameprev}
    tech.unit.count = 150 + 50 * (tier-1)
  end
  return tech
end



local tiermax
local dataextendlist = {}
local tiermax = settings.startup["Schall-pickup-tower-tier-max"].value -- 4

-- Fast Inserters
for tier = 1,tiermax do
  table.insert( dataextendlist, create_tower_item_1  (tier) )
  table.insert( dataextendlist, create_tower_item_2  (tier) )
  table.insert( dataextendlist, create_tower_entity_1(tier) )
  table.insert( dataextendlist, create_tower_entity_2(tier) )
  table.insert( dataextendlist, create_tower_recipe  (tier) )
  table.insert( dataextendlist, create_tower_technology(tier) )
end

data:extend(dataextendlist)

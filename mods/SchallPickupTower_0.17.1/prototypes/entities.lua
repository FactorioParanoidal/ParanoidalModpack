local pickup_tower_icon_path = {icon = "__SchallPickupTower__/graphics/icons/pickup-tower.png"}
local mk1_icon_overlay = {icon = "__SchallPickupTower__/graphics/icons/mk1.png"}
local mk2_icon_overlay = {icon = "__SchallPickupTower__/graphics/icons/mk2.png"}



-- Towers
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



data:extend(
{
  -- Pickup Tower (Range 32)
  {
    type = "radar",
    name = "Schall-pickup-tower-R32-upper",
    icons = { pickup_tower_icon_path,
              mk1_icon_overlay },
    icon_size = 32,
    flags = {"not-blueprintable", "not-deconstructable", "placeable-off-grid"},
    -- minable = {hardness = 0.2, mining_time = 0.5, result = "Schall-pickup-tower-R32"},
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
    energy_per_sector = "15MJ", --"10MJ",
    max_distance_of_sector_revealed = 0,
    max_distance_of_nearby_sector_revealed = 1,
    energy_per_nearby_scan = "250kJ",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_usage = "500kW", --"300kW",
    pictures = pickup_tower_sheet{},
  },
  {
    type = "container",
    -- type = "logistic-container",
    name = "Schall-pickup-tower-R32",
    icons = { pickup_tower_icon_path,
              mk1_icon_overlay },
    icon_size = 32,
    flags = {"placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "Schall-pickup-tower-R32"},
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
  },
  -- Pickup Tower (Range 64)
  {
    type = "radar",
    name = "Schall-pickup-tower-R64-upper",
    icons = { pickup_tower_icon_path,
              mk2_icon_overlay },
    icon_size = 32,
    flags = {"not-blueprintable", "not-deconstructable", "placeable-off-grid"},
    -- minable = {hardness = 0.2, mining_time = 0.5, result = "Schall-pickup-tower-R64"},
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
    energy_per_sector = "60MJ", --"15MJ", --"10MJ",
    max_distance_of_sector_revealed = 0,
    max_distance_of_nearby_sector_revealed = 2,
    energy_per_nearby_scan = "250kJ",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_usage = "1000kW", --"500kW", --"300kW",
    pictures = pickup_tower_sheet{},
  },
  {
    type = "container",
    -- type = "logistic-container",
    name = "Schall-pickup-tower-R64",
    icons = { pickup_tower_icon_path,
              mk2_icon_overlay },
    icon_size = 32,
    flags = {"placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "Schall-pickup-tower-R64"},
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
  },


}
)

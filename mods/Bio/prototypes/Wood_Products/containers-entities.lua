data:extend({
-- Large Wooden Chest
{
    type = "container",
    name = "bi-wooden-chest-large",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/wood_chest_large.png",
    icon_size = 64, icon_mipmaps = 4,
    scale_info_icons = true,
    se_allow_in_space = true,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1, result = "bi-wooden-chest-large"},
    max_health = 200,
    --corpse = "bi-wooden-chest-large-remnant",
    corpse = "small-remnants",
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
    selection_box = {{-1.0, -1.0}, {1.0, 1.0}},
    fast_replaceable_group = "container",
    inventory_size = 128,
    open_sound = {filename = "__base__/sound/wooden-chest-open.ogg"},
    close_sound = {filename = "__base__/sound/wooden-chest-close.ogg"},
    vehicle_impact_sound = 
    {
      {filename = "__base__/sound/car-wood-impact.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-02.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-03.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-04.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-05.ogg", volume = 0.65},
    },  
    picture = {
      layers = {
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/chests/large_wooden_chest.png",
          priority = "extra-high",
          width = 64,
          height = 64,
          shift = {0, 0},
          scale = 1,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/chests/hr_large_wooden_chest.png",
            priority = "extra-high",
            width = 128,
            height = 128,
            shift = {0, 0},
            scale = 0.5,
          }
        },
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/chests/large_wooden_chest_shadow.png",
          priority = "extra-high",
          width = 64,
          height = 64,
          shift = {1, 0},
          scale = 1,
          draw_as_shadow = true,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/chests/hr_large_wooden_chest_shadow.png",
            priority = "extra-high",
            width = 128,
            height = 128,
            shift = {1, 0},
            scale = 0.5,
            draw_as_shadow = true,
          }
        },
      },
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = default_circuit_wire_max_distance
  },
--###############################################################################################
-- Huge Wooden Chest
{
    type = "container",
    name = "bi-wooden-chest-huge",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/wood_chest_huge.png",
    icon_size = 64, icon_mipmaps = 4,
    scale_info_icons = true,
    se_allow_in_space = true,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1.5, result = "bi-wooden-chest-huge"},
    max_health = 350,
    --corpse = "bi-wooden-chest-huge-remnant",
    corpse = "small-remnants",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fast_replaceable_group = "container",
    inventory_size = 432,
    open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" },
    close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" },
    vehicle_impact_sound = 
    {
      {filename = "__base__/sound/car-wood-impact.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-02.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-03.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-04.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-05.ogg", volume = 0.65},
    },  
    picture = {
      layers = {
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/chests/huge_wooden_chest.png",
          priority = "extra-high",
          width = 112,
          height = 112,
          shift = {0, 0},
          scale = 1,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/chests/hr_huge_wooden_chest.png",
            priority = "extra-high",
            width = 224,
            height = 224,
            shift = {0, 0},
            scale = 0.5,
          }
        },
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/chests/huge_wooden_chest_shadow.png",
          priority = "extra-high",
          width = 112,
          height = 112,
          shift = {1, 0},
          scale = 1,
          draw_as_shadow = true,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/chests/hr_huge_wooden_chest_shadow.png",
            priority = "extra-high",
            width = 224,
            height = 224,
            shift = {1, 0},
            scale = 0.5,
            draw_as_shadow = true,
          }
        },
      },
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = default_circuit_wire_max_distance
},
--###############################################################################################
-- Giga Wooden Chest
{
    type = "container",
    name = "bi-wooden-chest-giga",
    icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/entity/wood_chest_giga.png",
    icon_size = 64, icon_mipmaps = 4,
    scale_info_icons = true,
    se_allow_in_space = true,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 3.5, result = "bi-wooden-chest-giga"},
    max_health = 350,
    corpse = "big-remnants",
    collision_box = {{-2.8, -2.8}, {2.8, 2.8}},
    selection_box = {{-3, -3}, {3, 3}},
    fast_replaceable_group = "container",
    inventory_size = 1728,
    open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" },
    close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" },
    vehicle_impact_sound = 
    {
      {filename = "__base__/sound/car-wood-impact.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-02.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-03.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-04.ogg", volume = 0.65},
      {filename = "__base__/sound/car-wood-impact-05.ogg", volume = 0.65},
    },  
    picture = {
      layers = {
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/chests/giga_wooden_chest.png",
          priority = "extra-high",
          width = 192,
          height = 224,
          shift = {0, -0.5},
          scale = 1,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/chests/hr_giga_wooden_chest.png",
            priority = "extra-high",
            width = 384,
            height = 448,
            shift = {0, -0.5},
            scale = 0.5,
          }
        },
        {
          filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/chests/giga_wooden_chest_shadow.png",
          priority = "extra-high",
          width = 96,
          height = 192,
          shift = {3.5, 0},
          scale = 1,
          draw_as_shadow = true,
          hr_version = {
            filename = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/entities/wood_products/chests/hr_giga_wooden_chest_shadow.png",
            priority = "extra-high",
            width = 192,
            height = 384,
            shift = {3.5, 0},
            scale = 0.5,
            draw_as_shadow = true,
          }
        }
      },
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = default_circuit_wire_max_distance
  },
})
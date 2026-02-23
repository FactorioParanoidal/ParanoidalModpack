if not BI.Settings.BI_Bigger_Wooden_Chests then
  return
end

local BioInd = require('common')('Bio_Industries_2')

BioInd.writeDebug("Creating bigger wooden chests!")

local ICONPATH = BioInd.modRoot .. "/graphics/icons/"
local ICONPATH_E = BioInd.modRoot .. "/graphics/icons/entity/"
local WOODPATH = BioInd.modRoot .. "/graphics/entities/wood_products/"
local REMNANTSPATH = BioInd.modRoot .. "/graphics/entities/remnants/"
local SNDPATH = "__base__/sound/"
local sounds = {}
sounds.open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" }
sounds.close_sound = { filename = SNDPATH .. "wooden-chest-close.ogg" }
sounds.walking_sound = {}
for i = 1, 11 do
  sounds.walking_sound[i] = {
    filename = SNDPATH .. "walking/concrete-" .. i ..".ogg",
    volume = 1.2
  }
end


------------------------------------------------------------------------------------
--                         Rename the vanill wooden chest!                        --
------------------------------------------------------------------------------------
data.raw.container["wooden-chest"].localised_name = {"entity-name.bi-wooden-chest"}


------------------------------------------------------------------------------------
--                        Create the bigger wooden chests!                        --
------------------------------------------------------------------------------------

------- Large Wooden Chest
data:extend({
  {
    type = "container",
    name = "bi-wooden-chest-large",
	icons = { {icon = ICONPATH_E .. "large_wooden_chest_icon.png", icon_size = 64, } },
    -- This is necessary for "Space Exploration" (if not true, the entity can only be
    -- placed on Nauvis)!
    se_allow_in_space = true,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1, result = "bi-wooden-chest-large"},
    max_health = 200,
    corpse = "bi-wooden-chest-large-remnant",
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
    selection_box = {{-1.0, -1.0}, {1.0, 1.0}},
    fast_replaceable_group = "container",
    inventory_size = 128, -- 64
    open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" },
    close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" },
    impact_category = "wood",
    picture = {
	layers = {
	{
      filename = WOODPATH .. "large_wooden_chest.png",
      priority = "extra-high",
      width = 128,
      height = 128,
      shift = {0, 0},
      scale = 0.5,
    },
	{
      filename = WOODPATH .. "large_wooden_chest_shadow.png",
      priority = "extra-high",
      width = 128,
      height = 128,
      shift = {1, 0},
	  draw_as_shadow = true,
      scale = 0.5,
    },
	},	
	},
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = default_circuit_wire_max_distance
  },
  
  --- corpse
	  {
	  type = "corpse",
	  name = "bi-wooden-chest-large-remnant",
	  localised_name = {"entity-name.bi-wooden-chest-large-remnant"},
	  icon = "__base__/graphics/icons/remnants.png",
	  icon_size = 64,
	  icon_mipmaps = 4,
	  BI_add_icon = true,
	  flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
	  subgroup = "remnants",
	  order = "z-z-z",
	  selection_box = {{-1, -1}, {1, 1}},
	  tile_width = 2,
	  tile_height = 2,
	  selectable_in_game = false,
	  time_before_removed = 60 * 60 * 15, -- 15 minutes
	  final_render_layer = "remnants",
	  remove_on_tile_placement = false,
	  animation =
	  {
		{
		  filename = REMNANTSPATH .. "large_wooden_chest_remnant.png",
		  line_length = 1,
		  width = 256,
		  height = 256,
		  frame_count = 1,
		  direction_count = 1,
		  shift = {0,0},
		  scale = 0.5
		}
	  }
	},
  
})

------- Huge Wooden Chest
data:extend({
  {
    type = "container",
    name = "bi-wooden-chest-huge",
	icons = { {icon = ICONPATH_E .. "huge_wooden_chest_icon.png", icon_size = 64, } },
    scale_info_icons = true,
    -- This is necessary for "Space Exploration" (if not true, the entity can only be
    -- placed on Nauvis)!
    se_allow_in_space = true,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1.5, result = "bi-wooden-chest-huge"},
    max_health = 350,
    corpse = "bi-wooden-chest-huge-remnant",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fast_replaceable_group = "container",
    inventory_size = 432, --144
    open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" },
    close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" },
    impact_category = "wood",
    picture = {
	layers = {
	{
      filename = WOODPATH .. "huge_wooden_chest.png",
      priority = "extra-high",
      width = 224,
      height = 224,
      shift = {0, 0},
      scale = 0.5,
    },
	{
      filename = WOODPATH .. "huge_wooden_chest_shadow.png",
      priority = "extra-high",
      width = 224,
      height = 224,
      shift = {1, 0},
	  draw_as_shadow = true,
      scale = 0.5,
    },	
	},
	},
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = default_circuit_wire_max_distance
  },
  
  --- corpse
	  {
	  type = "corpse",
	  name = "bi-wooden-chest-huge-remnant",
	  localised_name = {"entity-name.bi-wooden-chest-huge-remnant"},
	  icon = "__base__/graphics/icons/remnants.png",
	  icon_size = 64,
	  icon_mipmaps = 4,
	  BI_add_icon = true,
	  flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
	  subgroup = "remnants",
	  order = "z-z-z",
	  selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
	  tile_width = 3,
	  tile_height = 3,
	  selectable_in_game = false,
	  time_before_removed = 60 * 60 * 15, -- 15 minutes
	  final_render_layer = "remnants",
	  remove_on_tile_placement = false,
	  animation =
	  {
		{
		  filename = REMNANTSPATH .. "huge_wooden_chest_remnant.png",
		  line_length = 1,
		  width = 336,
		  height = 336,
		  frame_count = 1,
		  direction_count = 1,
		  shift = {0,0},
		  scale = 0.5
		}
	  }
	},

})

------- Giga Wooden Chest
data:extend({
  {
    type = "container",
    name = "bi-wooden-chest-giga",
	icons = { {icon = ICONPATH_E .. "giga_wooden_chest_icon.png", icon_size = 64, } },
    scale_info_icons = true,
    -- This is necessary for "Space Exploration" (if not true, the entity can only be
    -- placed on Nauvis)!
    se_allow_in_space = true,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 3.5, result = "bi-wooden-chest-giga"},
    max_health = 350,
    corpse = "bi-wooden-chest-giga-remnant",
    collision_box = {{-2.8, -2.8}, {2.8, 2.8}},
    selection_box = {{-3, -3}, {3, 3}},
    fast_replaceable_group = "container",
    inventory_size = 1728, --576
    open_sound = { filename = "__base__/sound/wooden-chest-open.ogg" },
    close_sound = { filename = "__base__/sound/wooden-chest-close.ogg" },
    impact_category = "wood",
    picture = {
	layers = {
	{
      filename = WOODPATH .. "giga_wooden_chest.png",
      priority = "extra-high",
      width = 384,
      height = 448,
      shift = {0, -0.5},
      scale = 0.5,
    },
	{
      filename = WOODPATH .. "giga_wooden_chest_shadow.png",
      priority = "extra-high",
      width = 192,
      height = 384,
      shift = {1, -0.5},
	  draw_as_shadow = true,
      scale = 0.5,
    },	
	},
	},
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = default_circuit_wire_max_distance
  },
  
  --- corpse
	  {
	  type = "corpse",
	  name = "bi-wooden-chest-giga-remnant",
	  localised_name = {"entity-name.bi-wooden-chest-giga-remnant"},
	  icon = "__base__/graphics/icons/remnants.png",
	  icon_size = 64,
	  icon_mipmaps = 4,
	  BI_add_icon = true,
	  flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
	  subgroup = "remnants",
	  order = "z-z-z",
	  selection_box = {{-3, -3}, {3, 3}},
	  tile_width = 6,
	  tile_height = 6,
	  selectable_in_game = false,
	  time_before_removed = 60 * 60 * 15, -- 15 minutes
	  final_render_layer = "remnants",
	  remove_on_tile_placement = false,
	  animation =
	  {
		{
		  filename = REMNANTSPATH .. "giga_wooden_chest_remnant.png",
		  line_length = 1,
		  width = 576,
		  height = 576,
		  frame_count = 1,
		  direction_count = 1,
		  shift = {0, -0},
		  scale = 0.5
		}
	  }
	},
  
})

-- paths
local fmf_icons_path = "__FluidMustFlow__/graphics/icon/entities/"

--libs
local SpritesBuilder  = require("__FluidMustFlow__/linver-lib/SpritesBuilder")
local sprites_builder = SpritesBuilder:new()
local pipes_overlay   = require("__FluidMustFlow__/prototypes/scripts/pipes-overlay")

-- Circutis connections
circuit_connector_definitions["fmf-non-return-duct"] = circuit_connector_definitions.create
(
	universal_connector_template,
	{
		{ variation = 2, main_offset = util.by_pixel(0, 4), shadow_offset = util.by_pixel(-2, 2), show_shadow = true },
		{ variation = 4, main_offset = util.by_pixel(-27, -13), shadow_offset = util.by_pixel(-25, -13), show_shadow = true },
		{ variation = 2, main_offset = util.by_pixel(0, -42), shadow_offset = util.by_pixel(-2, -42), show_shadow = true },
		{ variation = 4, main_offset = util.by_pixel(19, -13), shadow_offset = util.by_pixel(21, -13), show_shadow = true }
	}
)

-- static paths
local entity_sprite_path = "__FluidMustFlow__/graphics/entity/"
local duct_intermediate_points_sprite_path = entity_sprite_path .. "ducts_intermediate_points/"

sprites_builder:setWidth(128)
sprites_builder:setHRWidth(256)
sprites_builder:setHeight(128)
sprites_builder:setHRHeight(256)
sprites_builder:setScale(1)
sprites_builder:setHRScale(0.5)
sprites_builder:setPriority("high")	
sprites_builder:setHRPriority("high")	
sprites_builder:setFrameCount(16)
sprites_builder:setLineLength(4)
sprites_builder:setAnimationSpeed(1.0)

-- Non-Return Duct Sprites
-------------------------------
local empty_sprite = sprites_builder.getEmptySprite() -- for replace missing graphic

sprites_builder:setFilename(duct_intermediate_points_sprite_path .. "non_return_duct_up.png")
sprites_builder:setHRFilename(duct_intermediate_points_sprite_path .. "hr_non_return_duct_up.png")
sprites_builder:setShadow(duct_intermediate_points_sprite_path .. "non_return_duct_vertical_shadow.png")
sprites_builder:setHRShadow(duct_intermediate_points_sprite_path .. "hr_non_return_duct_vertical_shadow.png")
local non_return_duct_north = sprites_builder:buildImage()

sprites_builder:setFilename(duct_intermediate_points_sprite_path .. "non_return_duct_down.png")
sprites_builder:setHRFilename(duct_intermediate_points_sprite_path .. "hr_non_return_duct_down.png")
local non_return_duct_south = sprites_builder:buildImage()

sprites_builder:setFilename(duct_intermediate_points_sprite_path .. "non_return_duct_right.png")
sprites_builder:setHRFilename(duct_intermediate_points_sprite_path .. "hr_non_return_duct_right.png")
sprites_builder:setShadow(duct_intermediate_points_sprite_path .. "non_return_duct_horizontal_shadow.png")
sprites_builder:setHRShadow(duct_intermediate_points_sprite_path .. "hr_non_return_duct_horizontal_shadow.png")
local non_return_duct_east = sprites_builder:buildImage()

sprites_builder:setFilename(duct_intermediate_points_sprite_path .. "non_return_duct_left.png")
sprites_builder:setHRFilename(duct_intermediate_points_sprite_path .. "hr_non_return_duct_left.png")
local non_return_duct_west = sprites_builder:buildImage()

local non_return_duct_picture = sprites_builder.getPicture4Parts
(
	non_return_duct_north, 
	non_return_duct_east, 
	non_return_duct_south, 
	non_return_duct_west
) 

local non_return_duct_unload_pictures =	
{
	north = 
	{
		non_return_duct_north, -- tons of placeholder, animations is to much expensive
		non_return_duct_north,
		non_return_duct_north,
		non_return_duct_north,
		non_return_duct_north,
		non_return_duct_north
	},
	east = 
	{
		non_return_duct_east,
		non_return_duct_east,
		non_return_duct_east,
		non_return_duct_east,
		non_return_duct_east,
		non_return_duct_east
	},
	south = 
	{
		non_return_duct_south,
		non_return_duct_south,
		non_return_duct_south,
		non_return_duct_south,
		non_return_duct_south,
		non_return_duct_south
	}, 
	west =
	{
		non_return_duct_west,
		non_return_duct_west,
		non_return_duct_west,
		non_return_duct_west,
		non_return_duct_west,
		non_return_duct_west
	}
}

-- -- -- Entities
-- Initializing entities

-- -- Duct Intermediate Points

-- Non-Return Duct

--base setting

data:extend({{
	type = "pump",
	name = "non-return-duct",
	icon = fmf_icons_path .. "non-return-duct.png",
	icon_size = 64,
	flags = {"placeable-neutral", "player-creation"},
	minable = {mining_time = 0.4, result = "non-return-duct"},
	max_health = 200 * settings.startup["fmf-duct-health-multiplier"].value,
	resistances = data.raw["pump"]["pump"].resistances,
	fast_replaceable_group = "duct-intermediate-points",
	next_upgrade = nil,
	--placeable_by = {item = "duct-end-point-intake", count = 1},
	corpse = "small-remnants",
	dying_explosion = "pump-explosion",
	-- boxes (collision, selection, fluid)
	collision_box = {{-0.77, -0.9}, {0.77, 0.9}},
	selection_box = {{-1, -1}, {1, 1}},
	fluid_box =
	{
		base_area = settings.startup["fmf-duct-base-level-multiplier"].value / 4,
		base_level = 0,
		height = 8,
		pipe_covers = nil,
		pipe_connections =	
		{
			{ position = {0.5, -1.5},  type="output", max_underground_distance = 1  },
			{ position = {-0.5, -1.5}, type="output", max_underground_distance = 1  },
			{ position = {-0.6, 1.6},  type="input", max_underground_distance = 1   },
			{ position = {0.6, 1.6},   type="input", max_underground_distance = 1   }
		}
	},
	-- sprites
	animations = non_return_duct_picture,
	fluid_wagon_connector_frame_count = 0,
	fluid_wagon_connector_graphics = 
	{
		load_animations = non_return_duct_unload_pictures,
		unload_animations = non_return_duct_unload_pictures
	},
	glass_pictures = empty_sprite,
	fluid_animation =
	{
		north = empty_sprite,
		east = empty_sprite,
		south = empty_sprite,
		west = empty_sprite
	},
	working_visualisations = nil,
	--pumping stastistic increase
	energy_usage = "1W", -- base 30 x0
	energy_source =
	{
		type = "void"
		--[[
		emissions_per_minute = 0,
		emissions_per_second_per_watt = 0,
		emissions = 0,
		render_no_power_icon = false,
		render_no_network_icon = false,
		buffer_capacity  = "0kW",
		usage_priority = "secondary-input"
		--]]
	},
	pumping_speed = 400, -- base 200 x2
	-- other
	circuit_wire_connection_points = circuit_connector_definitions["fmf-non-return-duct"].points,
	circuit_connector_sprites      = circuit_connector_definitions["fmf-non-return-duct"].sprites,
	circuit_wire_max_distance      = data.raw["storage-tank"]["storage-tank"].circuit_wire_max_distance,
	vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
}})

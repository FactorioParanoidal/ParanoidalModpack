-- paths
local fmf_icons_path = "__FluidMustFlow__/graphics/icon/entities/"

--libs
local SpritesBuilder  = require("__FluidMustFlow__/linver-lib/SpritesBuilder")
local sprites_builder = SpritesBuilder:new()
local pipes_overlay   = require("__FluidMustFlow__/prototypes/scripts/pipes-overlay")

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

local non_return_duct = util.table.deepcopy(data.raw["pump"]["pump"])
non_return_duct.name = "non-return-duct"
non_return_duct.fast_replaceable_group = "duct-intermediate-points"
non_return_duct.next_upgrade = nil
non_return_duct.icon = fmf_icons_path .. "non-return-duct.png"
non_return_duct.icon_size = 64
non_return_duct.minable = {mining_time = 0.4, result = "non-return-duct"}
non_return_duct.placeable_by = {item = "duct-end-point-intake", count = 1}
non_return_duct.max_health = 200 * settings.startup["fmf-duct-health-multiplier"].value
non_return_duct.resistances = data.raw["pump"]["pump"].resistances
non_return_duct.corpse = "small-remnants"
-- boxes (collision, selection, fluid)
non_return_duct.collision_box = {{-0.77, -0.9}, {0.77, 0.9}}
non_return_duct.selection_box = {{-1, -1}, {1, 1}}
non_return_duct.fluid_box =
{
	base_area = settings.startup["fmf-duct-base-level-multiplier"].value / 4,
	base_level = 0,
	height = 8,
	pipe_covers = nil,
	pipe_connections =	
	{
		{ position = {0.5, -1.5},  type="output" },
		{ position = {-0.5, -1.5}, type="output" },
		{ position = {-0.6, 1.6},  type="input"  },
		{ position = {0.6, 1.6},   type="input"  }
	}
}
-- sprites
non_return_duct.animations = non_return_duct_picture
non_return_duct.fluid_wagon_connector_frame_count = 0
non_return_duct.fluid_wagon_connector_graphics = 
{
	load_animations = non_return_duct_unload_pictures,
	unload_animations = non_return_duct_unload_pictures
}
non_return_duct.glass_pictures = empty_sprite
non_return_duct.fluid_animation =
{
	north = empty_sprite,
	east = empty_sprite,
	south = empty_sprite,
	west = empty_sprite
}
non_return_duct.working_visualisations = nil
--pumping stastistic increase
non_return_duct.energy_usage = "1W" -- base 30 x0
non_return_duct.energy_source =
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
}
non_return_duct.pumping_speed = 400 -- base 200 x2
-- other
non_return_duct.circuit_wire_connection_points = data.raw["storage-tank"]["storage-tank"].circuit_wire_connection_points
non_return_duct.circuit_connector_sprites      = data.raw["storage-tank"]["storage-tank"].circuit_connector_sprites
non_return_duct.circuit_wire_max_distance      = data.raw["storage-tank"]["storage-tank"].circuit_wire_max_distance
non_return_duct.vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 }

data:extend({non_return_duct})

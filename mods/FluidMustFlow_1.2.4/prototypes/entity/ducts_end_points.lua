-- paths
local fmf_icons_path = "__FluidMustFlow__/graphics/icon/entities/"

--libs
local SpritesBuilder  = require("__FluidMustFlow__/linver-lib/SpritesBuilder")
local sprites_builder = SpritesBuilder:new()
local pipes_overlay   = require("__FluidMustFlow__/prototypes/scripts/pipes-overlay")

-- static paths
local entity_sprite_path = "__FluidMustFlow__/graphics/entity/"
local duct_end_points_sprite_path = entity_sprite_path .. "ducts_end_points/"

-- -- -- Sprites 
--Initializing sprites

empty_sprite = sprites_builder.getEmptySprite() -- for replace missing graphic

-- -- Ducts End Point Sprites

sprites_builder:setWidth(128)
sprites_builder:setHRWidth(256)
sprites_builder:setHeight(128)
sprites_builder:setHRHeight(256)
sprites_builder:setScale(1)
sprites_builder:setHRScale(0.5)
sprites_builder:setPriority("high")
sprites_builder:setHRPriority("high")	
sprites_builder:setFrameCount(8)
sprites_builder:setLineLength(4)
sprites_builder:setAnimationSpeed(0.8)

-- Duct End Point Intake Sprites
-------------------------------

sprites_builder:setFilename(duct_end_points_sprite_path .. "duct_end_point_intake/duct_end_point_intake_up.png")
sprites_builder:setHRFilename(duct_end_points_sprite_path .. "duct_end_point_intake/hr_duct_end_point_intake_up.png")
sprites_builder:setShadow(duct_end_points_sprite_path .. "duct_end_points_up_shadow.png")
sprites_builder:setHRShadow(duct_end_points_sprite_path .. "hr_duct_end_points_up_shadow.png")
local duct_end_point_intake_north = sprites_builder:buildImage()

sprites_builder:setFilename(duct_end_points_sprite_path .. "duct_end_point_intake/duct_end_point_intake_right.png")
sprites_builder:setHRFilename(duct_end_points_sprite_path .. "duct_end_point_intake/hr_duct_end_point_intake_right.png")
sprites_builder:setShadow(duct_end_points_sprite_path .. "duct_end_points_right_shadow.png")
sprites_builder:setHRShadow(duct_end_points_sprite_path .. "hr_duct_end_points_right_shadow.png")
local duct_end_point_intake_east = sprites_builder:buildImage()

sprites_builder:setFilename(duct_end_points_sprite_path .. "duct_end_point_intake/duct_end_point_intake_down.png")
sprites_builder:setHRFilename(duct_end_points_sprite_path .. "duct_end_point_intake/hr_duct_end_point_intake_down.png")
sprites_builder:setShadow(duct_end_points_sprite_path .. "duct_end_points_down_shadow.png")
sprites_builder:setHRShadow(duct_end_points_sprite_path .. "hr_duct_end_points_down_shadow.png")
local duct_end_point_intake_south = sprites_builder:buildImage()

sprites_builder:setFilename(duct_end_points_sprite_path .. "duct_end_point_intake/duct_end_point_intake_left.png")
sprites_builder:setHRFilename(duct_end_points_sprite_path .. "duct_end_point_intake/hr_duct_end_point_intake_left.png")
sprites_builder:setShadow(duct_end_points_sprite_path .. "duct_end_points_left_shadow.png")
sprites_builder:setHRShadow(duct_end_points_sprite_path .. "hr_duct_end_points_left_shadow.png")
local duct_end_point_intake_west = sprites_builder:buildImage()

local duct_end_point_intake_picture = sprites_builder.getPicture4Parts
(
	duct_end_point_intake_north, 
	duct_end_point_intake_east, 
	duct_end_point_intake_south, 
	duct_end_point_intake_west
) 

local duct_end_point_intake_load_unload_pictures =	
{
	north = 
	{
		duct_end_point_intake_north, -- tons of placeholder, animations is to much expensive
		duct_end_point_intake_north,
		duct_end_point_intake_north,
		duct_end_point_intake_north,
		duct_end_point_intake_north,
		duct_end_point_intake_north
	},
	east = 
	{
		duct_end_point_intake_east,
		duct_end_point_intake_east,
		duct_end_point_intake_east,
		duct_end_point_intake_east,
		duct_end_point_intake_east,
		duct_end_point_intake_east
	},
	south = 
	{
		duct_end_point_intake_south,
		duct_end_point_intake_south,
		duct_end_point_intake_south,
		duct_end_point_intake_south,
		duct_end_point_intake_south,
		duct_end_point_intake_south
	},
	west =
	{
		duct_end_point_intake_west,
		duct_end_point_intake_west,
		duct_end_point_intake_west,
		duct_end_point_intake_west,
		duct_end_point_intake_west,
		duct_end_point_intake_west
	}
}

-- Duct End Point Outtake Sprites

sprites_builder:setFilename(duct_end_points_sprite_path .. "duct_end_point_outtake/duct_end_point_outtake_up.png")
sprites_builder:setHRFilename(duct_end_points_sprite_path .. "duct_end_point_outtake/hr_duct_end_point_outtake_up.png")
sprites_builder:setShadow(duct_end_points_sprite_path .. "duct_end_points_up_shadow.png")
sprites_builder:setHRShadow(duct_end_points_sprite_path .. "hr_duct_end_points_up_shadow.png")
local duct_end_point_outtake_north = sprites_builder:buildImage()

sprites_builder:setFilename(duct_end_points_sprite_path .. "duct_end_point_outtake/duct_end_point_outtake_right.png")
sprites_builder:setHRFilename(duct_end_points_sprite_path .. "duct_end_point_outtake/hr_duct_end_point_outtake_right.png")
sprites_builder:setShadow(duct_end_points_sprite_path .. "duct_end_points_right_shadow.png")
sprites_builder:setHRShadow(duct_end_points_sprite_path .. "hr_duct_end_points_right_shadow.png")
local duct_end_point_outtake_east = sprites_builder:buildImage()

sprites_builder:setFilename(duct_end_points_sprite_path .. "duct_end_point_outtake/duct_end_point_outtake_down.png")
sprites_builder:setHRFilename(duct_end_points_sprite_path .. "duct_end_point_outtake/hr_duct_end_point_outtake_down.png")
sprites_builder:setShadow(duct_end_points_sprite_path .. "duct_end_points_down_shadow.png")
sprites_builder:setHRShadow(duct_end_points_sprite_path .. "hr_duct_end_points_down_shadow.png")
local duct_end_point_outtake_south = sprites_builder:buildImage()

sprites_builder:setFilename(duct_end_points_sprite_path .. "duct_end_point_outtake/duct_end_point_outtake_left.png")
sprites_builder:setHRFilename(duct_end_points_sprite_path .. "duct_end_point_outtake/hr_duct_end_point_outtake_left.png")
sprites_builder:setShadow(duct_end_points_sprite_path .. "duct_end_points_left_shadow.png")
sprites_builder:setHRShadow(duct_end_points_sprite_path .. "hr_duct_end_points_left_shadow.png")
local duct_end_point_outtake_west = sprites_builder:buildImage()

local duct_end_point_outtake_picture = sprites_builder.getPicture4Parts
(
	duct_end_point_outtake_north, 
	duct_end_point_outtake_east, 
	duct_end_point_outtake_south, 
	duct_end_point_outtake_west
) 

local duct_end_point_outtake_load_unload_pictures =	
{
	north = 
	{
		duct_end_point_outtake_north, -- tons of placeholder, animations is to much expensive
		duct_end_point_outtake_north,
		duct_end_point_outtake_north,
		duct_end_point_outtake_north,
		duct_end_point_outtake_north,
		duct_end_point_outtake_north
	},
	east = 
	{
		duct_end_point_outtake_east,
		duct_end_point_outtake_east,
		duct_end_point_outtake_east,
		duct_end_point_outtake_east,
		duct_end_point_outtake_east,
		duct_end_point_outtake_east
	},
	south = 
	{
		duct_end_point_outtake_south,
		duct_end_point_outtake_south,
		duct_end_point_outtake_south,
		duct_end_point_outtake_south,
		duct_end_point_outtake_south,
		duct_end_point_outtake_south
	},
	west =
	{
		duct_end_point_outtake_west,
		duct_end_point_outtake_west,
		duct_end_point_outtake_west,
		duct_end_point_outtake_west,
		duct_end_point_outtake_west,
		duct_end_point_outtake_west
	}
}

-- -- -- Entities
-- Initializing entities

-- -- Duct End Points

-- Duct End Point Intake

--base setting
local duct_end_point_intake_south = util.table.deepcopy(data.raw["pump"]["pump"])
duct_end_point_intake_south.name = "duct-end-point-intake-south"
duct_end_point_intake_south.fast_replaceable_group = "duct-end-points"
duct_end_point_intake_south.next_upgrade = nil
duct_end_point_intake_south.icon = fmf_icons_path .. "duct-end-point.png"
duct_end_point_intake_south.icon_size = 64
duct_end_point_intake_south.minable = {mining_time = 0.4, result = "duct-end-point-intake"}
duct_end_point_intake_south.placeable_by = {item = "duct-end-point-intake", count = 1}
duct_end_point_intake_south.max_health = 200 * settings.startup["fmf-duct-health-multiplier"].value
duct_end_point_intake_south.resistances = data.raw["pump"]["pump"].resistances
duct_end_point_intake_south.corpse = "small-remnants"
-- boxes (collision, selection, fluid)
duct_end_point_intake_south.collision_box = {{-0.9, -0.9}, {0.9, 0.9}}
duct_end_point_intake_south.selection_box = {{-1, -1}, {1, 1}}
duct_end_point_intake_south.fluid_box =
{
	base_area = settings.startup["fmf-duct-base-level-multiplier"].value,
	base_level = 0,
	height = 2,
	pipe_covers = pipes_overlay.getDuctFixedPipeCoversPictures(defines.direction.south),
	pipe_picture = pipes_overlay.getDuctFixedPipePictures(),
	pipe_connections =	
	{
		{ position = {0.5, -1.5},  type="input"  },
		{ position = {-0.5, -1.5}, type="input"  },
		{ position = {0.6, 1.6},   type="output" },
		{ position = {-0.6, 1.6},  type="output" },
		{ position = {1.5, -0.5},  type="input"  },
		{ position = {1.5, 0.5},   type="input"  },
		{ position = {-1.5, -0.5}, type="input"  },
		{ position = {-1.5, 0.5},  type="input"  }
	},
	secondary_draw_orders = {south = 1}
}
-- sprites
duct_end_point_intake_south.animations = duct_end_point_intake_picture
duct_end_point_intake_south.fluid_wagon_connector_frame_count = 0
duct_end_point_intake_south.fluid_wagon_connector_graphics = 
{
	load_animations = duct_end_point_intake_load_unload_pictures,
	unload_animations = duct_end_point_intake_load_unload_pictures
}
duct_end_point_intake_south.glass_pictures = sprites_builder.getEmptySprite()
duct_end_point_intake_south.fluid_animation =
{
	north = sprites_builder.getEmptySprite(),
	east = sprites_builder.getEmptySprite(),
	south = sprites_builder.getEmptySprite(),
	west = sprites_builder.getEmptySprite()
}
duct_end_point_intake_south.working_visualisations =
{	
	{
		light =
		{
			intensity = 0.3,
			size = 2,
			shift = {0, 0},
			color = {r=0.1, g=0.5, b=1}
		}
	},
	{
		animation =
		{
			filename = duct_end_points_sprite_path .. "duct_end_point-animation.png",
			width = 328,
			height = 124,
			scale = 0.5,
			frame_count = 8,
			line_length = 2,
			shift = {0, 0},
			animation_speed = 0.3
		}
	}
}
--pumping stastistic increase
duct_end_point_intake_south.energy_usage = "180kW" -- base 30 x4
duct_end_point_intake_south.pumping_speed = 1200 -- base 200 x6
-- other
duct_end_point_intake_south.circuit_wire_connection_points = data.raw["storage-tank"]["storage-tank"].circuit_wire_connection_points
duct_end_point_intake_south.circuit_connector_sprites      = data.raw["storage-tank"]["storage-tank"].circuit_connector_sprites
duct_end_point_intake_south.circuit_wire_max_distance      = data.raw["storage-tank"]["storage-tank"].circuit_wire_max_distance
duct_end_point_intake_south.vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 }

local duct_end_point_intake_west = util.table.deepcopy(duct_end_point_intake_south)
duct_end_point_intake_west.name = "duct-end-point-intake-west"
duct_end_point_intake_west.fluid_box.pipe_covers = pipes_overlay.getDuctFixedPipeCoversPictures(defines.direction.west)

local duct_end_point_intake_north = util.table.deepcopy(duct_end_point_intake_south)
duct_end_point_intake_north.name = "duct-end-point-intake-north"
duct_end_point_intake_north.fluid_box.pipe_covers = pipes_overlay.getDuctFixedPipeCoversPictures(defines.direction.north)

local duct_end_point_intake_east = util.table.deepcopy(duct_end_point_intake_south)
duct_end_point_intake_east.name = "duct-end-point-intake-east"
duct_end_point_intake_east.fluid_box.pipe_covers = pipes_overlay.getDuctFixedPipeCoversPictures(defines.direction.east)

-- Duct End Point Outtake

local duct_end_point_outtake_south = util.table.deepcopy(duct_end_point_intake_south)
duct_end_point_outtake_south.icon = fmf_icons_path .. "duct-end-point.png"
duct_end_point_outtake_south.name = "duct-end-point-outtake-south"
duct_end_point_outtake_south.minable.result = "duct-end-point-outtake"
duct_end_point_outtake_south.placeable_by = {item = "duct-end-point-outtake", count = 1}
duct_end_point_outtake_south.animations = duct_end_point_outtake_picture
duct_end_point_outtake_south.fluid_box.pipe_connections =
{
	{ position = {0.5, -1.5},  type="output" },
	{ position = {-0.5, -1.5}, type="output" },
	{ position = {0.6, 1.6},   type="input"  },
	{ position = {-0.6, 1.6},  type="input"  },
	{ position = {1.5, -0.5},  type="output" },
	{ position = {1.5, 0.5},   type="output" },
	{ position = {-1.5, -0.5}, type="output" },
	{ position = {-1.5, 0.5},  type="output" }
}

local duct_end_point_outtake_west = util.table.deepcopy(duct_end_point_outtake_south)
duct_end_point_outtake_west.name = "duct-end-point-outtake-west"
duct_end_point_outtake_west.fluid_box.pipe_covers = pipes_overlay.getDuctFixedPipeCoversPictures(defines.direction.west)

local duct_end_point_outtake_north = util.table.deepcopy(duct_end_point_outtake_south)
duct_end_point_outtake_north.name = "duct-end-point-outtake-north"
duct_end_point_outtake_north.fluid_box.pipe_covers = pipes_overlay.getDuctFixedPipeCoversPictures(defines.direction.north)

local duct_end_point_outtake_east = util.table.deepcopy(duct_end_point_outtake_south)
duct_end_point_outtake_east.name = "duct-end-point-outtake-east"
duct_end_point_outtake_east.fluid_box.pipe_covers = pipes_overlay.getDuctFixedPipeCoversPictures(defines.direction.east)

-- Adding entities
data:extend(
{
	duct_end_point_intake_south,
	duct_end_point_intake_west,
	duct_end_point_intake_north,	
	duct_end_point_intake_east,

	duct_end_point_outtake_south,
	duct_end_point_outtake_west,
	duct_end_point_outtake_north,
	duct_end_point_outtake_east
})

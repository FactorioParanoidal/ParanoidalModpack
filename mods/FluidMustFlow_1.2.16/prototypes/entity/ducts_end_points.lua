-- paths
local fmf_icons_path = "__FluidMustFlow__/graphics/icon/entities/"

--libs
local SpritesBuilder  = require("__FluidMustFlow__/linver-lib/SpritesBuilder")
local sprites_builder = SpritesBuilder:new()
local pipes_overlay   = require("__FluidMustFlow__/prototypes/scripts/pipes-overlay")

-- Circutis connections
circuit_connector_definitions["fmf-end-points"] = circuit_connector_definitions.create
(
	universal_connector_template,
	{
		{ variation = 2, main_offset = util.by_pixel(0, 3), shadow_offset = util.by_pixel(-2, 3), show_shadow = true },
		{ variation = 4, main_offset = util.by_pixel(-4, 18), shadow_offset = util.by_pixel(-2, 18), show_shadow = true },
		{ variation = 4, main_offset = util.by_pixel(-4, 18), shadow_offset = util.by_pixel(-2, 18), show_shadow = true },
		{ variation = 4, main_offset = util.by_pixel(-4, 18), shadow_offset = util.by_pixel(-2, 18), show_shadow = true }
	}
)

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
--intake rotated by 180 degrees so as to align with the 'pump' direction. Helpful for visualization mods like picker (pipe tools) which display the direction of flow
sprites_builder:setFilename(duct_end_points_sprite_path .. "duct_end_point_intake/duct_end_point_intake_up.png")
sprites_builder:setHRFilename(duct_end_points_sprite_path .. "duct_end_point_intake/hr_duct_end_point_intake_up.png")
sprites_builder:setShadow(duct_end_points_sprite_path .. "duct_end_points_up_shadow.png")
sprites_builder:setHRShadow(duct_end_points_sprite_path .. "hr_duct_end_points_up_shadow.png")
local duct_end_point_intake_south = sprites_builder:buildImage()

sprites_builder:setFilename(duct_end_points_sprite_path .. "duct_end_point_intake/duct_end_point_intake_right.png")
sprites_builder:setHRFilename(duct_end_points_sprite_path .. "duct_end_point_intake/hr_duct_end_point_intake_right.png")
sprites_builder:setShadow(duct_end_points_sprite_path .. "duct_end_points_right_shadow.png")
sprites_builder:setHRShadow(duct_end_points_sprite_path .. "hr_duct_end_points_right_shadow.png")
local duct_end_point_intake_west = sprites_builder:buildImage()

sprites_builder:setFilename(duct_end_points_sprite_path .. "duct_end_point_intake/duct_end_point_intake_down.png")
sprites_builder:setHRFilename(duct_end_points_sprite_path .. "duct_end_point_intake/hr_duct_end_point_intake_down.png")
sprites_builder:setShadow(duct_end_points_sprite_path .. "duct_end_points_down_shadow.png")
sprites_builder:setHRShadow(duct_end_points_sprite_path .. "hr_duct_end_points_down_shadow.png")
local duct_end_point_intake_north = sprites_builder:buildImage()

sprites_builder:setFilename(duct_end_points_sprite_path .. "duct_end_point_intake/duct_end_point_intake_left.png")
sprites_builder:setHRFilename(duct_end_points_sprite_path .. "duct_end_point_intake/hr_duct_end_point_intake_left.png")
sprites_builder:setShadow(duct_end_points_sprite_path .. "duct_end_points_left_shadow.png")
sprites_builder:setHRShadow(duct_end_points_sprite_path .. "hr_duct_end_points_left_shadow.png")
local duct_end_point_intake_east = sprites_builder:buildImage()

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

duct_end_point_intake = 
{
	type = "pump",
	name = "duct-end-point-intake",
	fast_replace_group = "duct-end-points",
	next_upgrade = nil,
	icon = fmf_icons_path .. "duct-end-point.png",
	icon_size = 64,
	flags = {"placeable-neutral", "player-creation"},
	minable = {mining_time = 0.4, result = "duct-end-point-intake"},
	max_health = 200 * settings.startup["fmf-duct-health-multiplier"].value,
	resistances = data.raw["pump"]["pump"].resistances,
	corpse = "small-remnants",
	-- boxes (collision, selection, fluid)
	collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
	selection_box = {{-1, -1}, {1, 1}},
	fluid_box =
	{
		base_area = settings.startup["fmf-duct-base-level-multiplier"].value / 4,
		base_level = 0,
		height = 8,
		pipe_covers = pipecoverspictures(), --pipes_overlay.getDuctFixedPipeCoversPictures(defines.direction.south),
		pipe_picture = pipes_overlay.getDuctFixedPipePictures(),
		pipe_connections =	
		{
			{ position = {0.5, 1.5},  type="input"},
			{ position = {-0.5, 1.5}, type="input"  },
			{ position = {0.6, -1.6},   type="output", max_underground_distance = 1 }, --use underground for regular duct connections so as to bypass pipe covers.
			{ position = {-0.6, -1.6},  type="output", max_underground_distance = 1 },
			{ position = {1.5, -0.5},  type="input"  },
			{ position = {1.5, 0.5},   type="input"  },
			{ position = {-1.5, -0.5}, type="input"  },
			{ position = {-1.5, 0.5},  type="input"  }
		},
		secondary_draw_orders = {north = -1}
	},
	-- sprites
	animations = duct_end_point_intake_picture,
	fluid_wagon_connector_frame_count = 0,
	fluid_wagon_connector_graphics = 
	{
		load_animations = duct_end_point_intake_load_unload_pictures,
		unload_animations = duct_end_point_intake_load_unload_pictures
	},
	glass_pictures = sprites_builder.getEmptySprite(),
	fluid_animation =
	{
		north = sprites_builder.getEmptySprite(),
		east = sprites_builder.getEmptySprite(),
		south = sprites_builder.getEmptySprite(),
		west = sprites_builder.getEmptySprite()
	},
	working_visualisations =
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
	},
	--pumping stastistic increase
	energy_source =
	{
		type = "electric",
		usage_priority = "secondary-input",
		drain = "1kW"
	},
	energy_usage = "180kW", -- base 30 x4
	pumping_speed = 1200, -- base 200 x6
	-- other
	circuit_wire_connection_points = circuit_connector_definitions["fmf-end-points"].points,
	circuit_connector_sprites      = circuit_connector_definitions["fmf-end-points"].sprites,
	circuit_wire_max_distance      = data.raw["storage-tank"]["storage-tank"].circuit_wire_max_distance,
	vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
}

-- Duct End Point Outtake

local duct_end_point_outtake = util.table.deepcopy(duct_end_point_intake)
duct_end_point_outtake.icon = fmf_icons_path .. "duct-end-point.png"
duct_end_point_outtake.name = "duct-end-point-outtake"
duct_end_point_outtake.minable.result = "duct-end-point-outtake"
duct_end_point_outtake.placeable_by = {item = "duct-end-point-outtake", count = 1}
duct_end_point_outtake.animations = duct_end_point_outtake_picture
duct_end_point_outtake.fluid_box.pipe_connections =
{
	{ position = {0.5, -1.5},  type="output" },
	{ position = {-0.5, -1.5}, type="output" },
	{ position = {0.6, 1.6},   type="input", max_underground_distance = 1 },
	{ position = {-0.6, 1.6},  type="input", max_underground_distance = 1 },
	{ position = {1.5, -0.5},  type="output" },
	{ position = {1.5, 0.5},   type="output" },
	{ position = {-1.5, -0.5}, type="output" },
	{ position = {-1.5, 0.5},  type="output" }
}

-- Adding entities
data:extend(
{
	duct_end_point_intake,
	duct_end_point_outtake,
})

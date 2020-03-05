-- paths
local fmf_icons_path = "__FluidMustFlow__/graphics/icon/entities/"

-- libs
local SpritesBuilder  = require("__FluidMustFlow__/linver-lib/SpritesBuilder")
local sprites_builder = SpritesBuilder:new()
local pipes_overlay   = require("__FluidMustFlow__/prototypes/scripts/pipes-overlay")

-- -- -- Sprites 
--Initializing sprites

local empty_sprite = sprites_builder.getEmptySprite() -- for replace missing graphic

-- Small Ducts picture

sprites_builder:setWidth(64)
sprites_builder:setHRWidth(128)
sprites_builder:setHeight(128)
sprites_builder:setHRHeight(256)
sprites_builder:setScale(1)
sprites_builder:setHRScale(0.5)
sprites_builder:setPriority("high")
sprites_builder:setHRPriority("high")	
sprites_builder:setShadowShift({0.5, 0})
sprites_builder:setHRShadowShift({0.5, 0})

sprites_builder:setFilename("__FluidMustFlow__/graphics/entity/duct/duct_small/duct_small_straight_horizontal.png")
sprites_builder:setHRFilename("__FluidMustFlow__/graphics/entity/duct/duct_small/hr_duct_small_straight_horizontal.png")
sprites_builder:setShadow("__FluidMustFlow__/graphics/entity/duct/duct_small/duct_small_straight_horizontal_shadow.png")
sprites_builder:setHRShadow("__FluidMustFlow__/graphics/entity/duct/duct_small/hr_duct_small_straight_horizontal_shadow.png")
local duct_small_east = sprites_builder:buildImage()
local duct_small_west = duct_small_east -- is the same perspective

sprites_builder:setWidth(128)
sprites_builder:setHRWidth(256)
sprites_builder:setHeight(80)
sprites_builder:setHRHeight(160)
sprites_builder:setShadowShift(nil)
sprites_builder:setHRShadowShift(nil)

sprites_builder:setFilename("__FluidMustFlow__/graphics/entity/duct/duct_small/duct_small_straight_vertical.png")
sprites_builder:setHRFilename("__FluidMustFlow__/graphics/entity/duct/duct_small/hr_duct_small_straight_vertical.png")
sprites_builder:setShadow("__FluidMustFlow__/graphics/entity/duct/duct_small/duct_small_straight_vertical_shadow.png")
sprites_builder:setHRShadow("__FluidMustFlow__/graphics/entity/duct/duct_small/hr_duct_small_straight_vertical_shadow.png")

local duct_small_north = sprites_builder:buildImage()
local duct_small_south = duct_small_north -- is the same perspective

local duct_small_picture = sprites_builder.getPicture4Parts(duct_small_north, duct_small_east, duct_small_south, duct_small_west)
-- Long Duct picture

sprites_builder:setWidth(128)
sprites_builder:setHRWidth(256)
sprites_builder:setHeight(180)
sprites_builder:setHRHeight(360)
sprites_builder:setFilenameWithShadow('__FluidMustFlow__/graphics/entity/duct/duct_long/', 'duct_long_horizontal')
local duct_long_north = sprites_builder:buildImage()
local duct_long_south = duct_long_north -- is the same perspective

sprites_builder:setWidth(256)
sprites_builder:setHRWidth(512)
sprites_builder:setHeight(128)
sprites_builder:setHRHeight(256)
sprites_builder:setFilenameWithShadow('__FluidMustFlow__/graphics/entity/duct/duct_long/', 'duct_long_vertical')
local duct_long_east = sprites_builder:buildImage()
local duct_long_west = duct_long_east -- is the same perspective

local duct_long_picture = sprites_builder.getPicture4Parts(duct_long_north, duct_long_east, duct_long_south, duct_long_west)

-- Duct picture

sprites_builder:setWidth(128)
sprites_builder:setHRWidth(256)

sprites_builder:setFilenameWithShadow('__FluidMustFlow__/graphics/entity/duct/duct/', 'duct_horizontal')
local duct_north = sprites_builder:buildImage()
local duct_south = duct_north -- is the same perspective
sprites_builder:setFilenameWithShadow('__FluidMustFlow__/graphics/entity/duct/duct/', 'duct_vertical')
local duct_east = sprites_builder:buildImage()
local duct_west = duct_east -- is the same perspective

local duct_picture = sprites_builder.getPicture4Parts(duct_north, duct_east, duct_south, duct_west)

-- Duct_T_junction picture
sprites_builder:setFilenameWithShadow('__FluidMustFlow__/graphics/entity/duct/duct_T/', 'duct_T_up')
local duct_t_junction_north = sprites_builder:buildImage()
sprites_builder:setFilenameWithShadow('__FluidMustFlow__/graphics/entity/duct/duct_T/', 'duct_T_right')
local duct_t_junction_east = sprites_builder:buildImage()
sprites_builder:setFilenameWithShadow('__FluidMustFlow__/graphics/entity/duct/duct_T/', 'duct_T_down')
local duct_t_junction_south = sprites_builder:buildImage()
sprites_builder:setFilenameWithShadow('__FluidMustFlow__/graphics/entity/duct/duct_T/', 'duct_T_left')
local duct_t_junction_west = sprites_builder:buildImage()

local duct_t_junction_picture = sprites_builder.getPicture4Parts(duct_t_junction_north, duct_t_junction_east, duct_t_junction_south, duct_t_junction_west)

-- Curved Duct
sprites_builder:setFilenameWithShadow('__FluidMustFlow__/graphics/entity/duct/duct_corner/', 'duct_corner_up_left')
local duct_curve_north = sprites_builder:buildImage()
sprites_builder:setFilenameWithShadow('__FluidMustFlow__/graphics/entity/duct/duct_corner/', 'duct_corner_up_right')
local duct_curve_east = sprites_builder:buildImage()
sprites_builder:setFilenameWithShadow('__FluidMustFlow__/graphics/entity/duct/duct_corner/', 'duct_corner_down_right')
local duct_curve_south = sprites_builder:buildImage()
sprites_builder:setFilenameWithShadow('__FluidMustFlow__/graphics/entity/duct/duct_corner/', 'duct_corner_down_left')
local duct_curve_west = sprites_builder:buildImage()

local duct_curve_picture = sprites_builder.getPicture4Parts(duct_curve_north, duct_curve_east, duct_curve_south, duct_curve_west)
	
-- Cross Duct

sprites_builder:setFilename("__FluidMustFlow__/graphics/entity/duct/duct_cross/duct_cross.png")
sprites_builder:setHRFilename("__FluidMustFlow__/graphics/entity/duct/duct_cross/hr_duct_cross.png")
sprites_builder:setShadow("__FluidMustFlow__/graphics/entity/duct/duct_cross/duct_cross_shadow.png")
sprites_builder:setHRShadow("__FluidMustFlow__/graphics/entity/duct/duct_cross/hr_duct_cross_shadow.png")
local duct_cross_all = sprites_builder:buildImage()

local duct_cross_picture = sprites_builder.getPicture4Parts(duct_cross_all, duct_cross_all, duct_cross_all, duct_cross_all)

-- Underground duct

sprites_builder:setFilename("__FluidMustFlow__/graphics/entity/duct/duct-ground/duct-ground-up.png")
sprites_builder:setHRFilename("__FluidMustFlow__/graphics/entity/duct/duct-ground/hr_duct-ground-up.png")
sprites_builder:setShadow("__FluidMustFlow__/graphics/entity/duct/duct-ground/duct-ground-up_shadow.png")
sprites_builder:setHRShadow("__FluidMustFlow__/graphics/entity/duct/duct-ground/hr_duct-ground-up_shadow.png")
local duct_underground_north = sprites_builder:buildImage()

sprites_builder:setFilename("__FluidMustFlow__/graphics/entity/duct/duct-ground/duct-ground-left.png")
sprites_builder:setHRFilename("__FluidMustFlow__/graphics/entity/duct/duct-ground/hr_duct-ground-left.png")
sprites_builder:setShadow("__FluidMustFlow__/graphics/entity/duct/duct-ground/duct-ground-left_shadow.png")
sprites_builder:setHRShadow("__FluidMustFlow__/graphics/entity/duct/duct-ground/hr_duct-ground-left_shadow.png")
local duct_underground_east = sprites_builder:buildImage()

sprites_builder:setFilename("__FluidMustFlow__/graphics/entity/duct/duct-ground/duct_ground_down.png")
sprites_builder:setHRFilename("__FluidMustFlow__/graphics/entity/duct/duct-ground/hr_duct_ground_down.png")
sprites_builder:setShadow("__FluidMustFlow__/graphics/entity/duct/duct-ground/duct_ground_down_shadow.png")
sprites_builder:setHRShadow("__FluidMustFlow__/graphics/entity/duct/duct-ground/hr_duct_ground_down_shadow.png")
local duct_underground_south = sprites_builder:buildImage()

sprites_builder:setFilename("__FluidMustFlow__/graphics/entity/duct/duct-ground/duct_ground_right.png")
sprites_builder:setHRFilename("__FluidMustFlow__/graphics/entity/duct/duct-ground/hr_duct_ground_right.png")
sprites_builder:setShadow("__FluidMustFlow__/graphics/entity/duct/duct-ground/duct_ground_right_shadow.png")
sprites_builder:setHRShadow("__FluidMustFlow__/graphics/entity/duct/duct-ground/hr_duct_ground_right_shadow.png")
local duct_underground_west = sprites_builder:buildImage()

local duct_underground_picture = 
{
	up = duct_underground_north, 	 
	left = duct_underground_east, 
	down = duct_underground_south,
	right = duct_underground_west
}

-- -- -- Entities
--Initializing entities

-- Duct Small
--base setting
duct_small = util.table.deepcopy(data.raw["storage-tank"]["storage-tank"])
duct_small.name = "duct-small"
duct_small.fast_replaceable_group = "ducts"
duct_small.next_upgrade = nil
duct_small.icon = fmf_icons_path .. "duct-small.png"
duct_small.icon_size = 64
duct_small.minable = {mining_time = 0.4, result = "duct-small"}
duct_small.max_health = 100 * settings.startup["fmf-duct-health-multiplier"].value
duct_small.resistances = data.raw["pipe"]["pipe"].resistances
duct_small.corpse = "small-remnants"
-- boxes (collision, selection, fluid)
duct_small.collision_box = {{-0.77, -0.45}, {0.77, 0.45}}
duct_small.selection_box = {{-1.2, -0.6}, {1.2, 0.6}}
duct_small.fluid_box =
{
	base_area = settings.startup["fmf-duct-base-level-multiplier"].value,
	base_level = 0,
	pipe_covers = nil,
	pipe_connections =
	{
		{ position = {0.6, -1.1} },
		{ position = {-0.6, -1.1} },
		{ position = {-0.6, 1.1} },
		{ position = {0.6, 1.1} }
	}
}
duct_small.pictures =
{
	picture = duct_small_picture,
	gas_flow = empty_sprite,
	fluid_background = empty_sprite,
	window_background = empty_sprite,
	flow_sprite = empty_sprite
}
duct_small.circuit_wire_max_distance = 0
duct_small.working_sound =
{
	sound = 
	{
		{
			filename = "__base__/sound/pipe.ogg",
			volume = 1
		}
	},
	match_volume_to_activity = true,
	max_sounds_per_type = 3
}
duct_small.vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 }

-- Duct

--base setting
duct = util.table.deepcopy(data.raw["storage-tank"]["storage-tank"])
duct.name = "duct"
duct.fast_replaceable_group = "ducts"
duct.next_upgrade = nil
duct.icon = fmf_icons_path .. "duct.png"
duct.icon_size = 64
if settings.startup["fmf-enable-duct-auto-join"].value then
	duct.minable = {mining_time = 0.6, result = "duct-small", count = 2}
else
	duct.minable = {mining_time = 0.6, result = "duct", count = 1}
end
duct.max_health = 200 * settings.startup["fmf-duct-health-multiplier"].value
duct.resistances = data.raw["pipe"]["pipe"].resistances
duct.corpse = "small-remnants"
--duct.fast_replaceable_group = No
-- boxes (collision, selection, fluid)
duct.collision_box = {{-0.77, -0.95}, {0.77, 0.95}}
duct.selection_box = {{-1.1, -1.1}, {1.1, 1.1}}
duct.fluid_box =
{
	base_area = 2*settings.startup["fmf-duct-base-level-multiplier"].value,
	base_level = 0,
	pipe_covers = nil, -- for debug: pipecoverspictures()
	pipe_connections =
	{
		{ position = {0.6, -1.6} },
		{ position = {-0.6, -1.6} },
		{ position = {0.6, 1.6} },
		{ position = {-0.6, 1.6} }
	}
}
duct.pictures =
{
	picture = duct_picture,
	gas_flow = empty_sprite,
	fluid_background = empty_sprite,
	window_background = empty_sprite,
	flow_sprite = empty_sprite
}
duct.circuit_wire_max_distance = 0
duct.working_sound =
{
	sound = 
	{
		{
			filename = "__base__/sound/pipe.ogg",
			volume = 1
		}
	},
	match_volume_to_activity = true,
	max_sounds_per_type = 3
}
duct.vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 }

-- Duct Long

duct_long = util.table.deepcopy(duct)
duct_long.name = "duct-long"
duct_long.icon = fmf_icons_path .. "duct-long.png"
if settings.startup["fmf-enable-duct-auto-join"].value then
	duct_long.minable = {mining_time = 0.8, result = "duct-small", count = 4}
else
	duct_long.minable = {mining_time = 0.8, result = "duct-long", count = 1}
end
duct_long.max_health = 400 * settings.startup["fmf-duct-health-multiplier"].value
duct_long.collision_box = {{-0.77, -1.95}, {0.77, 1.95}}
duct_long.selection_box = {{-1.1, -2.2}, {1.1, 2.2}}
duct_long.fluid_box =
{
	base_area = 4*settings.startup["fmf-duct-base-level-multiplier"].value,
	base_level = 0,
	pipe_covers = nil, -- for debug pipecoverspictures()
	pipe_connections =
	{
		{ position = {0.6, -2.6} },
		{ position = {-0.6, -2.6} },
		{ position = {0.6, 2.6} },
		{ position = {-0.6, 2.6} }
	}
}
duct_long.pictures =
{
	picture = duct_long_picture,
	gas_flow = empty_sprite,
	fluid_background = empty_sprite,
	window_background = empty_sprite,
	flow_sprite = empty_sprite
}

-- Duct T junction

duct_t_junction = util.table.deepcopy(duct)
duct_t_junction.name = "duct-t-junction"
duct_t_junction.icon = fmf_icons_path .. "duct-t-junction.png"
duct_t_junction.minable = {mining_time = 0.4, result = "duct-t-junction"}
duct_t_junction.two_direction_only = false
duct_t_junction.collision_box = {{-0.8, -0.9}, {0.8, 0.7}}
duct_t_junction.fluid_box.pipe_connections =
{
	{ position = {0.6, -1.6} },
	{ position = {-0.6, -1.6} },
	{ position = {1.6, -0.6} },
	{ position = {1.6, 0.6} },
	{ position = {-1.6, -0.6} },
	{ position = {-1.6, 0.6} }
}
duct_t_junction.pictures =
{
	picture = duct_t_junction_picture,
	gas_flow = empty_sprite,
	fluid_background = empty_sprite,
	window_background = empty_sprite,
	flow_sprite = empty_sprite
}

-- Curved duct

duct_curve = util.table.deepcopy(duct_t_junction)
duct_curve.name = "duct-curve"
duct_curve.icon = fmf_icons_path .. "duct-curve.png"
duct_curve.minable.result = "duct-curve"
duct_curve.collision_box = {{-0.9, -0.9}, {0.75, 0.75}}
duct_curve.fluid_box.pipe_connections =
{
	{ position = {0.6, -1.6} },
	{ position = {-0.6, -1.6} },
	{ position = {-1.6, -0.6} },
	{ position = {-1.6, 0.6} }
}
duct_curve.pictures =
{
	picture = duct_curve_picture,
	gas_flow = empty_sprite,
	fluid_background = empty_sprite,
	window_background = empty_sprite,
	flow_sprite = empty_sprite
}

-- Cross duct

duct_cross = util.table.deepcopy(duct_t_junction)
duct_cross.name = "duct-cross"
duct_cross.fast_replaceable_group = "ducts"
duct_cross.icon = fmf_icons_path .. "duct-cross.png"
duct_cross.minable.result = "duct-cross"
duct_cross.collision_box = {{-0.85, -0.85}, {0.85, 0.85}}
duct_cross.fluid_box.pipe_connections =
{
		{ position = {0.6, -1.6} },
		{ position = {-0.6, -1.6} },
		{ position = {0.6, 1.6} },
		{ position = {-0.6, 1.6} },
		{ position = {1.6, -0.6} },
		{ position = {1.6, 0.6} },
		{ position = {-1.6, -0.6} },
		{ position = {-1.6, 0.6} }
}
duct_cross.pictures =
{
	picture = duct_cross_picture,
	gas_flow = empty_sprite,
	fluid_background = empty_sprite,
	window_background = empty_sprite,
	flow_sprite = empty_sprite
}

-- Underground duct

duct_underground =
{
	type = "pipe-to-ground",
	name = "duct-underground",
	fast_replaceable_group = "ducts",
	icon = fmf_icons_path .. "duct-to-ground.png",
	icon_size = 64,
	flags = {"placeable-neutral", "player-creation"},
	minable = {mining_time = 0.4, result = "duct-underground"},
	max_health = 200 * settings.startup["fmf-duct-health-multiplier"].value,
	corpse = "small-remnants",
	resistances = data.raw["pipe"]["pipe"].resistances,
	collision_box = {{-0.80, -0.95}, {0.63, 0.80}},
	selection_box = {{-1.0, -1.2}, {1.1, 0.9}},
	two_direction_only = false,
	fluid_box =
	{
		base_area = 2 * settings.startup["fmf-duct-base-level-multiplier"].value,
		base_level = 0,
		pipe_covers = nil,
		pipe_connections =
		{
			{ position = {0.6, -1.6} },
			{
				position = {0.6, 1.6},
				max_underground_distance = settings.startup["fmf-underground-duct-max-length"].value
			},
			{ position = {-0.6, -1.6} },
			{
				position = {-0.6, 1.6},
				max_underground_distance = settings.startup["fmf-underground-duct-max-length"].value
			}
		}
	},
	underground_sprite =
	{
		filename = "__core__/graphics/arrows/underground-lines.png",
		priority = "high",
		width = 64,
		height = 64,
		scale = 0.5,
	},
	pictures = duct_underground_picture
}

-- Adding entities
data:extend({duct_small, duct, duct_long, duct_t_junction, duct_curve, duct_cross, duct_underground})
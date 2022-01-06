-----------------------------------------------------------
---- here is where all animation properties are stored ----
-----------------------------------------------------------

-- Setup animation host
local animation_set = {}

-- Enlist entity names
local entity_table =
{
	"offshore-pump-0",
	"offshore-pump-2",
	"offshore-pump-3",
	"offshore-pump-4"
}

-- Store animation functions
local function make_stripes(count, filename)
	 local stripe = {filename=filename, width_in_frames = 1, height_in_frames = 1}
	 local stripes = {}
	for i = 1, count do
		stripes[i] = stripe
	end
	return stripes
end

-- Underwater sprite set
local underwater_sprite_NORTH =
{
	stripes = make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/common/offshore-pump_North-underwater.png"),
	priority = "high",
	frame_count = 32,
	animation_speed = 0.25,
	width = 52,
	height = 16,
	shift = util.by_pixel(-2, -34),
	hr_version =
	{
		stripes = make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/common/hr-offshore-pump_North-underwater.png"),
		priority = "high",
		frame_count = 32,
		animation_speed = 0.25,
		width = 98,
		height = 36,
		shift = util.by_pixel(-1, -32),
		scale = 0.5
	}
}
local underwater_sprite_EAST =
{
	stripes = make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/common/offshore-pump_East-underwater.png"),
	priority = "high",
	frame_count = 32,
	animation_speed = 0.25,
	width = 18,
	height = 38,
	shift = util.by_pixel(40, 16),
	hr_version =
	{
		stripes = make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/common/hr-offshore-pump_East-underwater.png"),
		priority = "high",
		frame_count = 32,
		animation_speed = 0.25,
		width = 40,
		height = 72,
		shift = util.by_pixel(39, 17),
		scale = 0.5
	}
}
local underwater_sprite_SOUTH =
{
	stripes = make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/common/offshore-pump_South-underwater.png"),
	priority = "high",
	frame_count = 32,
	animation_speed = 0.25,
	width = 52,
	height = 26,
	shift = util.by_pixel(-2, 48),
	hr_version =
	{
		stripes = make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/common/hr-offshore-pump_South-underwater.png"),
		priority = "high",
		frame_count = 32,
		animation_speed = 0.25,
		width = 98,
		height = 48,
		shift = util.by_pixel(-1, 49),
		scale = 0.5
		}
}
local underwater_sprite_WEST =
{
	stripes = make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/common/offshore-pump_West-underwater.png"),
	priority = "high",
	frame_count = 32,
	animation_speed = 0.25,
	width = 20,
	height = 34,
	shift = util.by_pixel(-40, 18),
	hr_version =
	{
		stripes = make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/common/hr-offshore-pump_West-underwater.png"),
		priority = "high",
		frame_count = 32,
		animation_speed = 0.25,
		width = 40,
		height = 72,
		shift = util.by_pixel(-40, 17),
		scale = 0.5
	}
}

-- Pump sprite set
local pump_sprite_NORTH =
{
	filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North.png",
	priority = "high",
	line_length = 8,
	frame_count = 32,
	animation_speed = 0.25,
	width = 48,
	height = 84,
	shift = util.by_pixel(-2, -16),
	hr_version =
	{
		filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_North.png",
		priority = "high",
		line_length = 8,
		frame_count = 32,
		animation_speed = 0.25,
		width = 90,
		height = 162,
		shift = util.by_pixel(-1, -15),
		scale = 0.5
	}
}
local pump_sprite_EAST =
{
	filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East.png",
	priority = "high",
	line_length = 8,
	frame_count = 32,
	animation_speed = 0.25,
	width = 64,
	height = 52,
	shift = util.by_pixel(14, -2),
	hr_version =
	{
		filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_East.png",
		priority = "high",
		line_length = 8,
		frame_count = 32,
		animation_speed = 0.25,
		width = 124,
		height = 102,
		shift = util.by_pixel(15, -2),
		scale = 0.5
	}
}
local pump_sprite_SOUTH =
{
	filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South.png",
	priority = "high",
	line_length = 8,
	frame_count = 32,
	animation_speed = 0.25,
	width = 48,
	height = 96,
	shift = util.by_pixel(-2, 0),
	hr_version =
	{
		filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_South.png",
		priority = "high",
		line_length = 8,
		frame_count = 32,
		animation_speed = 0.25,
		width = 92,
		height = 192,
		shift = util.by_pixel(-1, 0),
		scale = 0.5
	}
}
local pump_sprite_WEST =
{
	filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West.png",
	priority = "high",
	line_length = 8,
	frame_count = 32,
	animation_speed = 0.25,
	width = 64,
	height = 52,
	shift = util.by_pixel(-16, -2),
	hr_version =
	{
		filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_West.png",
		priority = "high",
		line_length = 8,
		frame_count = 32,
		animation_speed = 0.25,
		width = 124,
		height = 102,
		shift = util.by_pixel(-15, -2),
		scale = 0.5
	}	
}

-- Shadow sprite set
local shadow_sprite_NORTH =
{
	filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North-shadow.png",
	priority = "high",
	line_length = 8,
	frame_count = 32,
	animation_speed = 0.25,
	width = 78,
	height = 70,
	shift = util.by_pixel(12, -8),
	draw_as_shadow = true,
	hr_version =
	{
		filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_North-shadow.png",
		priority = "high",
		line_length = 8,
		frame_count = 32,
		animation_speed = 0.25,
		width = 150,
		height = 134,
		shift = util.by_pixel(13, -7),
		draw_as_shadow = true,
		scale = 0.5
	}
}
local shadow_sprite_EAST =
{
	filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East-shadow.png",
	priority = "high",
	line_length = 8,
	frame_count = 32,
	animation_speed = 0.25,
	width = 88,
	height = 34,
	shift = util.by_pixel(28, 8),
	draw_as_shadow = true,
	hr_version =
	{
		filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_East-shadow.png",
		priority = "high",
		line_length = 8,
		frame_count = 32,
		animation_speed = 0.25,
		width = 180,
		height = 66,
		shift = util.by_pixel(27, 8),
		draw_as_shadow = true,
		scale = 0.5
	}
}
local shadow_sprite_SOUTH =
{
	filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South-shadow.png",
	priority = "high",
	line_length = 8,
	frame_count = 32,
	animation_speed = 0.25,
	width = 80,
	height = 66,
	shift = util.by_pixel(16, 22),
	draw_as_shadow = true,
	hr_version =
	{
		filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_South-shadow.png",
		priority = "high",
		line_length = 8,
		frame_count = 32,
		animation_speed = 0.25,
		width = 164,
		height = 128,
		shift = util.by_pixel(15, 23),
		draw_as_shadow = true,
		scale = 0.5
	}
}
local shadow_sprite_WEST =
{
	filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West-shadow.png",
	priority = "high",
	line_length = 8,
	frame_count = 32,
	animation_speed = 0.25,
	width = 88,
	height = 34,
	shift = util.by_pixel(-4, 8),
	draw_as_shadow = true,
	hr_version =
	{
		filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_West-shadow.png",
		priority = "high",
		line_length = 8,
		frame_count = 32,
		animation_speed = 0.25,
		width = 172,
		height = 66,
		shift = util.by_pixel(-3, 8),
		draw_as_shadow = true,
		scale = 0.5
	}
}

-- Fluid sprite set
local fluid_sprite_NORTH =
{
	filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North-fluid.png",
	tint = {r=0, g=0.34, b=0.6},
	line_length = 8,
	frame_count = 32,
	animation_speed = 0.25,
	width = 22,
	height = 20,
	shift = util.by_pixel(-2, -22),
	hr_version =
	{
		filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_North-fluid.png",
		tint = {r=0, g=0.34, b=0.6},
		line_length = 8,
		frame_count = 32,
		animation_speed = 0.25,
		width = 40,
		height = 40,
		shift = util.by_pixel(-1, -22),
		scale = 0.5
	}
}
local fluid_sprite_EAST =
{
	filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East-fluid.png",
	tint = {r=0, g=0.34, b=0.6},
	line_length = 8,
	frame_count = 32,
	animation_speed = 0.25,
	width = 20,
	height = 24,
	shift = util.by_pixel(6, -10),
	hr_version =
	{
		filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_East-fluid.png",
		tint = {r=0, g=0.34, b=0.6},
		line_length = 8,
		frame_count = 32,
		animation_speed = 0.25,
		width = 38,
		height = 50,
		shift = util.by_pixel(6, -11),
		scale = 0.5
	}
}
local fluid_sprite_SOUTH =
{
	filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South-fluid.png",
	tint = {r=0, g=0.34, b=0.6},
	line_length = 8,
	frame_count = 32,
	animation_speed = 0.25,
	width = 20,
	height = 8,
	shift = util.by_pixel(-2, -4),
	hr_version =
	{
		filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_South-fluid.png",
		tint = {r=0, g=0.34, b=0.6},
		line_length = 8,
		frame_count = 32,
		animation_speed = 0.25,
		width = 36,
		height = 14,
		shift = util.by_pixel(-1, -4),
		scale = 0.5
	}
}
local fluid_sprite_WEST =
{
	filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West-fluid.png",
	tint = {r=0, g=0.34, b=0.6},
	line_length = 8,
	frame_count = 32,
	animation_speed = 0.25,
	width = 20,
	height = 24,
	shift = util.by_pixel(-8, -10),
	hr_version =
	{
		filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_West-fluid.png",
		tint = {r=0, g=0.34, b=0.6},
		line_length = 8,
		frame_count = 32,
		animation_speed = 0.25,
		width = 36,
		height = 50,
		shift = util.by_pixel(-7, -11),
		scale = 0.5
	}
}

-- Glass sprite set
local glass_sprite_NORTH =
{
	stripes = make_stripes (8*4, "__base__/graphics/entity/offshore-pump/offshore-pump_North-glass.png"),
	priority = "high",
	frame_count = 32,
	animation_speed = 0.25,
	width = 18,
	height = 20,
	shift = util.by_pixel(-2, -22),
	hr_version =
	{
		stripes = make_stripes (8*4, "__base__/graphics/entity/offshore-pump/hr-offshore-pump_North-glass.png"),
		priority = "high",
		frame_count = 32,
		animation_speed = 0.25,
		width = 36,
		height = 40,
		shift = util.by_pixel(-2, -22),
		scale = 0.5
	}
}
local glass_sprite_EAST =
{
	stripes = make_stripes (8*4, "__base__/graphics/entity/offshore-pump/offshore-pump_East-glass.png"),
	priority = "high",
	frame_count = 32,
	animation_speed = 0.25,
	width = 18,
	height = 18,
	shift = util.by_pixel(4, -14),
	hr_version =
	{
		stripes = make_stripes (8*4, "__base__/graphics/entity/offshore-pump/hr-offshore-pump_East-glass.png"),
		priority = "high",
		frame_count = 32,
		animation_speed = 0.25,
		width = 30,
		height = 32,
		shift = util.by_pixel(5, -13),
		scale = 0.5
	}
}
local glass_sprite_SOUTH =
{
	stripes = make_stripes (8*4, "__base__/graphics/entity/offshore-pump/offshore-pump_South-glass.png"),
	priority = "high",
	frame_count = 32,
	animation_speed = 0.25,
	width = 22,
	height = 12,
	shift = util.by_pixel(-2, -6),
	hr_version =
	{
		stripes = make_stripes (8*4, "__base__/graphics/entity/offshore-pump/hr-offshore-pump_South-glass.png"),
		priority = "high",
		frame_count = 32,
		animation_speed = 0.25,
		width = 40,
		height = 24,
		shift = util.by_pixel(-1, -6),
		scale = 0.5
	}
}
local glass_sprite_WEST =
{
	stripes = make_stripes (8*4, "__base__/graphics/entity/offshore-pump/offshore-pump_West-glass.png"),
	priority = "high",
	frame_count = 32,
	animation_speed = 0.25,
	width = 16,
	height = 16,
	shift = util.by_pixel(-6, -14),
	hr_version =
	{
		stripes = make_stripes (8*4, "__base__/graphics/entity/offshore-pump/hr-offshore-pump_West-glass.png"),
		priority = "high",
		frame_count = 32,
		animation_speed = 0.25,
		width = 30,
		height = 32,
		shift = util.by_pixel(-6, -14),
		scale = 0.5
	}
}

-- Legs sprite set
local legs_sprite_NORTH =
{
	stripes = make_stripes (8*4, "__base__/graphics/entity/offshore-pump/offshore-pump_North-legs.png"),
	priority = "high",
	frame_count = 32,
	animation_speed = 0.25,
	width = 60,
	height = 52,
	shift = util.by_pixel(-2, -4),
	hr_version =
	{
		stripes = make_stripes (8*4, "__base__/graphics/entity/offshore-pump/hr-offshore-pump_North-legs.png"),
		priority = "high",
		frame_count = 32,
		animation_speed = 0.25,
		width = 114,
		height = 106,
		shift = util.by_pixel(-1, -5),
		scale = 0.5
	}
}
local legs_sprite_EAST =
{
	stripes = make_stripes (8*4, "__base__/graphics/entity/offshore-pump/offshore-pump_East-legs.png"),
	priority = "high",
	frame_count = 32,
	animation_speed = 0.25,
	width = 54,
	height = 32,
	shift = util.by_pixel(4, 12),
	hr_version =
	{
		stripes = make_stripes (8*4, "__base__/graphics/entity/offshore-pump/hr-offshore-pump_East-legs.png"),
		priority = "high",
		frame_count = 32,
		animation_speed = 0.25,
		width = 106,
		height = 60,
		shift = util.by_pixel(4, 13),
		scale = 0.5
	}
}
local legs_sprite_SOUTH =
{
	stripes = make_stripes (8*4, "__base__/graphics/entity/offshore-pump/offshore-pump_South-legs.png"),
	priority = "high",
	frame_count = 32,
	animation_speed = 0.25,
	width = 56,
	height = 54,
	shift = util.by_pixel(-2, 6),
	hr_version =
	{
		stripes = make_stripes (8*4, "__base__/graphics/entity/offshore-pump/hr-offshore-pump_South-legs.png"),
		priority = "high",
		frame_count = 32,
		animation_speed = 0.25,
		width = 110,
		height = 108,
		shift = util.by_pixel(-2, 6),
		scale = 0.5
	}
}
local legs_sprite_WEST =
{
	stripes = make_stripes (8*4, "__base__/graphics/entity/offshore-pump/offshore-pump_West-legs.png"),
	priority = "high",
	frame_count = 32,
	animation_speed = 0.25,
	width = 54,
	height = 32,
	shift = util.by_pixel(-6, 12),
	hr_version =
	{
		stripes = make_stripes (8*4, "__base__/graphics/entity/offshore-pump/hr-offshore-pump_West-legs.png"),
		priority = "high",
		frame_count = 32,
		animation_speed = 0.25,
		width = 108,
		height = 64,
		shift = util.by_pixel(-6, 12),
		scale = 0.5
	}
}

-- Recolor Masks
function animation_set.sprite_recolor()
	for _, entity_name in pairs (entity_table) do

		local mask_unpowered
		local mask_powered
		local mask_placeholder
		
		if data.raw["assembling-machine"][entity_name] then
			mask_powered = data.raw["assembling-machine"][entity_name].animation
			mask_placeholder = data.raw["offshore-pump"][entity_name .. "-placeholder"].graphics_set.animation		
		elseif data.raw["offshore-pump"][entity_name] then
			mask_unpowered = data.raw["offshore-pump"][entity_name].graphics_set.animation
		end
		
		local mask_table =
		{
			mask_unpowered,
			mask_powered,
			mask_placeholder
		}
		
		for _, mask in pairs (mask_table) do
			-- North
			table.insert(mask.north.layers,
			{
				stripes = make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/" .. entity_name .. "/" .. entity_name .. "-mask_North.png"),
				priority = "high",
				frame_count = 32,
				animation_speed = 0.25,
				width = 48,
				height = 84,
				shift = util.by_pixel(-2, -16),
				hr_version =
				{
					stripes = make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/" .. entity_name .. "/hr-" .. entity_name .. "-mask_North.png"),
					priority = "high",
					frame_count = 32,
					animation_speed = 0.25,
					width = 90,
					height = 162,
					shift = util.by_pixel(-1, -15),
					scale = 0.5
				}
			})
			-- East
			table.insert(mask.east.layers,
			{
				stripes = make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/" .. entity_name .. "/" .. entity_name .. "-mask_East.png"),
				priority = "high",
				frame_count = 32,
				animation_speed = 0.25,
				width = 52,
				height = 16,
				shift = util.by_pixel(14, -2),
				hr_version =
				{
					stripes = make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/" .. entity_name .. "/hr-" .. entity_name .. "-mask_East.png"),
					priority = "high",
					frame_count = 32,
					animation_speed = 0.25,
					width = 124,
					height = 102,
					shift = util.by_pixel(15, -2),
					scale = 0.5
				}
			})
			-- South
			table.insert(mask.south.layers,
			{
				stripes = make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/" .. entity_name .. "/" .. entity_name .. "-mask_South.png"),
				priority = "high",
				frame_count = 32,
				animation_speed = 0.25,
				width = 48,
				height = 96,
				shift = util.by_pixel(-2, 0),
				hr_version =
				{
					stripes = make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/" .. entity_name .. "/hr-" .. entity_name .. "-mask_South.png"),
					priority = "high",
					frame_count = 32,
					animation_speed = 0.25,
					width = 92,
					height = 192,
					shift = util.by_pixel(-1, 0),
					scale = 0.5
				}
			})
			-- West
			table.insert(mask.west.layers,
			{
				stripes = make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/" .. entity_name .. "/" .. entity_name .. "-mask_West.png"),
				priority = "high",
				frame_count = 32,
				animation_speed = 0.25,
				width = 64,
				height = 52,
				shift = util.by_pixel(-16, -2),
				hr_version =
				{
					stripes = make_stripes (8*4, "__P-U-M-P-S__/graphics/entity/" .. entity_name .. "/hr-" .. entity_name .. "-mask_West.png"),
					priority = "high",
					frame_count = 32,
					animation_speed = 0.25,
					width = 124,
					height = 102,
					shift = util.by_pixel(-15, -2),
					scale = 0.5
				}
			})
		end
	end
end
function animation_set.pumpjack_tiering()

	-- Set input parameters
	local assign_icon_tier = require("utils.lib").assign_icon_tier
	local inputs =
	{
		type = "assembling-machine",
		base_entity = "pumpjack",
		mod = "bobs",
		group = "mining",
		particles = {["small"] = 3},
	}
	
	local tier_map =
	{
		["water-pumpjack-1"] = {1},
		["water-pumpjack-2"] = {2},
		["water-pumpjack-3"] = {3},
		["water-pumpjack-4"] = {4},
		["water-pumpjack-5"] = {5}
	}
	
	local entity_highlights =
	{
		priority = "high",
		filename = "__reskins-bobs__/graphics/entity/mining/pumpjack/pumpjack-horsehead-highlights.png",
		line_length = 8,
		width = 104,
		height = 102,
		frame_count = 40,
		shift = util.by_pixel(-4, -24),
		blend_mode = reskins.lib.blend_mode, -- "additive",
		animation_speed = 0.5,
		hr_version =
		{
			priority = "high",
			filename = "__reskins-bobs__/graphics/entity/mining/pumpjack/hr-pumpjack-horsehead-highlights.png",
			animation_speed = 0.5,
			scale = 0.5,
			line_length = 8,
			frame_count = 40,
			width = 206,
			height = 202,
			shift = util.by_pixel(-4, -24),
			blend_mode = reskins.lib.blend_mode, -- "additive",
		}
	}
	
	for name, map in pairs(tier_map) do
	
		-- Fetch entity
		local entity = data.raw[inputs.type][name]
	
		-- Check if entity exists, if not, skip this iteration
		if not entity then goto continue end
	
		-- Parse map
		local tier = map[1]
	
		-- Determine what tint we're using
		inputs.tint = reskins.lib.tint_index[tier]
	
		-- Parse inputs
		reskins.lib.parse_inputs(inputs)

		-- Create particles and explosions
		if inputs.make_explosions then
			reskins.lib.create_explosions_and_particles(name, inputs)
		end

		-- Create remnants
		if inputs.make_remnants then
			reskins.lib.create_remnant(name, inputs)
		end

		local entity_mask =
		{
			filename = "__reskins-bobs__/graphics/entity/mining/pumpjack/pumpjack-horsehead-mask.png",
			priority = "high",
			line_length = 8,
			frame_count = 40,
			animation_speed = 0.5,
			width = 104,
			height = 102,
			shift = util.by_pixel(-4, -24),
			tint = inputs.tint,
			hr_version =
			{
				filename = "__reskins-bobs__/graphics/entity/mining/pumpjack/hr-pumpjack-horsehead-mask.png",
				priority = "high",
				line_length = 8,
				frame_count = 40,
				animation_speed = 0.5,
				width = 206,
				height = 202,
				shift = util.by_pixel(-4, -24),
				tint = inputs.tint,
				scale = 0.5
			}
		}
		
		table.insert(entity.animation.north.layers,entity_mask)
		table.insert(entity.animation.north.layers,entity_highlights)
		table.insert(entity.animation.east.layers,entity_mask)
		table.insert(entity.animation.east.layers,entity_highlights)
		table.insert(entity.animation.south.layers,entity_mask)
		table.insert(entity.animation.south.layers,entity_highlights)
		table.insert(entity.animation.west.layers,entity_mask)
		table.insert(entity.animation.west.layers,entity_highlights)
		
		-- Fetch remnants
		local remnant = data.raw.corpse[name.."-remnants"]
		
		-- Reskin remnants
		remnant.animation = make_rotated_animation_variations_from_sheet(2,{
			layers = {
				-- Base
				{
					filename = "__P-U-M-P-S__/graphics/entity/water-pumpjack/remnants/water-pumpjack-remnants.png",
					line_length = 1,
					width = 138,
					height = 142,
					frame_count = 1,
					direction_count = 1,
					shift = util.by_pixel(0, 3),
					hr_version = {
						filename = "__P-U-M-P-S__/graphics/entity/water-pumpjack/remnants/hr-water-pumpjack-remnants.png",
						line_length = 1,
						width = 274,
						height = 284,
						frame_count = 1,
						direction_count = 1,
						shift = util.by_pixel(0, 3.5),
						scale = 0.5,
					}
				},
				-- Mask
				{
					filename = "__reskins-bobs__/graphics/entity/mining/pumpjack/remnants/pumpjack-remnants-mask.png",
					line_length = 1,
					width = 138,
					height = 142,
					frame_count = 1,
					direction_count = 1,
					shift = util.by_pixel(0, 3),
					tint = inputs.tint,
					hr_version = {
						filename = "__reskins-bobs__/graphics/entity/mining/pumpjack/remnants/hr-pumpjack-remnants-mask.png",
						line_length = 1,
						width = 274,
						height = 284,
						frame_count = 1,
						direction_count = 1,
						shift = util.by_pixel(0, 3.5),
						tint = inputs.tint,
						scale = 0.5,
					}
				},
				-- Highlights
				{
					filename = "__reskins-bobs__/graphics/entity/mining/pumpjack/remnants/pumpjack-remnants-highlights.png",
					line_length = 1,
					width = 138,
					height = 142,
					frame_count = 1,
					direction_count = 1,
					shift = util.by_pixel(0, 3),
					blend_mode = reskins.lib.blend_mode, -- "additive",
					hr_version = {
						filename = "__reskins-bobs__/graphics/entity/mining/pumpjack/remnants/hr-pumpjack-remnants-highlights.png",
						line_length = 1,
						width = 274,
						height = 284,
						frame_count = 1,
						direction_count = 1,
						shift = util.by_pixel(0, 3.5),
						blend_mode = reskins.lib.blend_mode, -- "additive",
						scale = 0.5,
					}
				}
			}
		})
		-- Label to skip to next iteration
		::continue::
	end
end

-- Make animation sets
function animation_set.template_unpowered_animation() return
{
	underwater_sprite_layer_offset = 30,
	base_render_layer = "ground-patch",
	animation =
	{
		north =
		{
			layers =
			{
				pump_sprite_NORTH,
				shadow_sprite_NORTH
			}
		},
		east =
		{
			layers =
			{
				pump_sprite_EAST,
				shadow_sprite_EAST
			}
		},
		south =
		{
			layers =
			{
				pump_sprite_SOUTH,
				shadow_sprite_SOUTH
			}
		},
		west =
		{
			layers =
			{
				pump_sprite_WEST,
				shadow_sprite_WEST
			}
		}
	},
	fluid_animation =
	{
		north =
		{
			layers =
			{
				fluid_sprite_NORTH
			}
		},
        east =
        {
			layers =
			{
				fluid_sprite_EAST
			}
        },
        south =
        {
			layers =
			{
				fluid_sprite_SOUTH
			}
        },
        west =
        {
			layers =
			{
				fluid_sprite_WEST
			}
        }
	},
	glass_pictures =
	{
		north =
		{
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North-glass.png",
			width = 18,
			height = 20,
			shift = util.by_pixel(-2, -22),
			hr_version =
			{
				filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_North-glass.png",
				width = 36,
				height = 40,
				shift = util.by_pixel(-2, -22),
				scale = 0.5
			}
		},
		east =
		{
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East-glass.png",
			width = 18,
			height = 18,
			shift = util.by_pixel(4, -14),
			hr_version =
			{
				filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_East-glass.png",
				width = 30,
				height = 32,
				shift = util.by_pixel(5, -13),
				scale = 0.5
			}
		},
		south =
		{
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South-glass.png",
			width = 22,
			height = 12,
			shift = util.by_pixel(-2, -6),
			hr_version =
			{
				filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_South-glass.png",
				width = 40,
				height = 24,
				shift = util.by_pixel(-1, -6),
				scale = 0.5
			}
		},
		west =
		{
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West-glass.png",
			width = 16,
			height = 16,
			shift = util.by_pixel(-6, -14),
			hr_version =
			{
				filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_West-glass.png",
				width = 30,
				height = 32,
				shift = util.by_pixel(-6, -14),
				scale = 0.5
			}
		}
	},
	base_pictures =
	{
		north =
		{
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North-legs.png",
			width = 60,
			height = 52,
			shift = util.by_pixel(-2, -4),
			hr_version =
			{
				filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_North-legs.png",
				width = 114,
				height = 106,
				shift = util.by_pixel(-1, -5),
				scale = 0.5
			}
		},
		east =
		{
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East-legs.png",
			width = 54,
			height = 32,
			shift = util.by_pixel(4, 12),
			hr_version =
			{
				filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_East-legs.png",
				width = 106,
				height = 60,
				shift = util.by_pixel(4, 13),
				scale = 0.5
			}
		},
		south =
		{
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South-legs.png",
			width = 56,
			height = 54,
			shift = util.by_pixel(-2, 6),
			hr_version =
			{
				filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_South-legs.png",
				width = 110,
				height = 108,
				shift = util.by_pixel(-2, 6),
				scale = 0.5
			}
		},
		west =
		{
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West-legs.png",
			width = 54,
			height = 32,
			shift = util.by_pixel(-6, 12),
			hr_version =
			{
				filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_West-legs.png",
				width = 108,
				height = 64,
				shift = util.by_pixel(-6, 12),
				scale = 0.5
			}
		}
	},
	underwater_pictures =
	{
		north =
        {
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_North-underwater.png",
			width = 52,
			height = 16,
			shift = util.by_pixel(-2, -34),
			hr_version =
			{
				filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_North-underwater.png",
				width = 98,
				height = 36,
				shift = util.by_pixel(-1, -32),
				scale = 0.5
			}
		},
		east =
		{
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_East-underwater.png",
			width = 18,
			height = 38,
			shift = util.by_pixel(40, 16),
			hr_version =
			{
				filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_East-underwater.png",
				width = 40,
				height = 72,
				shift = util.by_pixel(39, 17),
				scale = 0.5
			}
		},
		south =
		{
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_South-underwater.png",
			width = 52,
			height = 26,
			shift = util.by_pixel(-2, 48),
			hr_version =
			{
				filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_South-underwater.png",
				width = 98,
				height = 48,
				shift = util.by_pixel(-1, 49),
				scale = 0.5
			}
		},
		west =
		{
			filename = "__base__/graphics/entity/offshore-pump/offshore-pump_West-underwater.png",
			width = 20,
			height = 34,
			shift = util.by_pixel(-40, 18),
			hr_version =
			{
				filename = "__base__/graphics/entity/offshore-pump/hr-offshore-pump_West-underwater.png",
				width = 40,
				height = 72,
				shift = util.by_pixel(-40, 17),
				scale = 0.5
			}
		}
	}
}
end
function animation_set.template_powered_animation() return
{
	north =
	{
		layers =
		{
			underwater_sprite_NORTH,
			pump_sprite_NORTH,
			shadow_sprite_NORTH,
			fluid_sprite_NORTH,
			glass_sprite_NORTH,
			legs_sprite_NORTH
		}
	},
	east =
	{
		layers =
		{
			underwater_sprite_EAST,
			pump_sprite_EAST,
			shadow_sprite_EAST,
			fluid_sprite_EAST,
			glass_sprite_EAST,
			legs_sprite_EAST
		}
	},
	south =
	{
		layers =
		{
			underwater_sprite_SOUTH,
			pump_sprite_SOUTH,
			shadow_sprite_SOUTH,
			fluid_sprite_SOUTH,
			glass_sprite_SOUTH,
			legs_sprite_SOUTH
		}
	},
	west =
	{
		layers =
		{
			underwater_sprite_WEST,
			pump_sprite_WEST,
			shadow_sprite_WEST,
			fluid_sprite_WEST,
			glass_sprite_WEST,
			legs_sprite_WEST
		}
	}
}
end
function animation_set.water_pumpjack_animation() return
{
	north =
	{
		layers =
		{
			{
				stripes = make_stripes (10*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack_North-shadow.png"),
				priority = "high",
				frame_count = 40,
				width = 110,
				height = 111,
				shift = util.by_pixel(6, 0.5),
				draw_as_shadow = true,
				hr_version =
				{
					stripes = make_stripes (10*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack_North-shadow.png"),
					priority = "high",
					frame_count = 40,
					width = 220,
					height = 220,
					shift = util.by_pixel(6, 0.5),
					draw_as_shadow = true,
					scale = 0.5,
				}
			},
			{
				stripes = make_stripes (10*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack_North-base.png"),
				priority = "high",
				frame_count = 40,
				width = 131,
				height = 137,
				shift = util.by_pixel(-2.5, -4.5),
				hr_version =
				{
					stripes = make_stripes (10*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack_North-base.png"),
					priority = "high",
					frame_count = 40,
					width = 260,
					height = 273,
					shift = util.by_pixel(-2.25, -4.75),
					scale = 0.5
				}
			},
			{
				filename = "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack-horsehead.png",
				priority = "high",
				line_length = 8,
				frame_count = 40,
				animation_speed = 0.5,
				width = 104,
				height = 102,
				shift = util.by_pixel(-4, -24),
				hr_version =
				{
					filename = "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack-horsehead.png",
					priority = "high",
					line_length = 8,
					frame_count = 40,
					animation_speed = 0.5,
					width = 206,
					height = 202,
					shift = util.by_pixel(-4, -24),
					scale = 0.5
				}
			},
			{
				priority = "high",
				filename = "__base__/graphics/entity/pumpjack/pumpjack-horsehead-shadow.png",
				animation_speed = 0.5,
				line_length = 8,
				frame_count = 40,
				width = 155,
				height = 41,
				shift = util.by_pixel(17.5, 14.5),
				draw_as_shadow = true,
				hr_version =
				{
					priority = "high",
					filename = "__base__/graphics/entity/pumpjack/hr-pumpjack-horsehead-shadow.png",
					line_length = 8,
					frame_count = 40,
					animation_speed = 0.5,
					width = 309,
					height = 82,
					shift = util.by_pixel(17.75, 14.5),
					draw_as_shadow = true,
					scale = 0.5
				}
			}
		}
	},
	east =
	{
		layers =
		{
			{
				stripes = make_stripes (10*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack_East-shadow.png"),
				priority = "high",
				frame_count = 40,
				width = 110,
				height = 111,
				shift = util.by_pixel(6, 0.5),
				draw_as_shadow = true,
				hr_version =
				{
					stripes = make_stripes (10*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack_East-shadow.png"),
					priority = "high",
					frame_count = 40,
					width = 220,
					height = 220,
					shift = util.by_pixel(6, 0.5),
					draw_as_shadow = true,
					scale = 0.5,
				}
			},
			{
				stripes = make_stripes (10*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack_East-base.png"),
				priority = "high",
				frame_count = 40,
				width = 131,
				height = 137,
				shift = util.by_pixel(-2.5, -4.5),
				hr_version =
				{
					stripes = make_stripes (10*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack_East-base.png"),
					priority = "high",
					frame_count = 40,
					width = 260,
					height = 273,
					shift = util.by_pixel(-2.25, -4.75),
					scale = 0.5
				}
			},
			{
				filename = "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack-horsehead.png",
				priority = "high",
				line_length = 8,
				frame_count = 40,
				animation_speed = 0.5,
				width = 104,
				height = 102,
				shift = util.by_pixel(-4, -24),
				hr_version =
				{
					filename = "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack-horsehead.png",
					priority = "high",
					line_length = 8,
					frame_count = 40,
					animation_speed = 0.5,
					width = 206,
					height = 202,
					shift = util.by_pixel(-4, -24),
					scale = 0.5
				}
			},
			{
				priority = "high",
				filename = "__base__/graphics/entity/pumpjack/pumpjack-horsehead-shadow.png",
				animation_speed = 0.5,
				line_length = 8,
				frame_count = 40,
				width = 155,
				height = 41,
				shift = util.by_pixel(17.5, 14.5),
				draw_as_shadow = true,
				hr_version =
				{
					priority = "high",
					filename = "__base__/graphics/entity/pumpjack/hr-pumpjack-horsehead-shadow.png",
					line_length = 8,
					frame_count = 40,
					animation_speed = 0.5,
					width = 309,
					height = 82,
					shift = util.by_pixel(17.75, 14.5),
					draw_as_shadow = true,
					scale = 0.5
				}
			}
		}
	},
	south =
	{
		layers =
		{
			{
				stripes = make_stripes (10*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack_South-shadow.png"),
				priority = "high",
				frame_count = 40,
				width = 110,
				height = 111,
				shift = util.by_pixel(6, 0.5),
				draw_as_shadow = true,
				hr_version =
				{
					stripes = make_stripes (10*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack_South-shadow.png"),
					priority = "high",
					frame_count = 40,
					width = 220,
					height = 220,
					shift = util.by_pixel(6, 0.5),
					draw_as_shadow = true,
					scale = 0.5,
				}
			},
			{
				stripes = make_stripes (10*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack_South-base.png"),
				priority = "high",
				frame_count = 40,
				width = 131,
				height = 137,
				shift = util.by_pixel(-2.5, -4.5),
				hr_version =
				{
					stripes = make_stripes (10*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack_South-base.png"),
					priority = "high",
					frame_count = 40,
					width = 260,
					height = 273,
					shift = util.by_pixel(-2.25, -4.75),
					scale = 0.5
				}
			},
			{
				filename = "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack-horsehead.png",
				priority = "high",
				line_length = 8,
				frame_count = 40,
				animation_speed = 0.5,
				width = 104,
				height = 102,
				shift = util.by_pixel(-4, -24),
				hr_version =
				{
					filename = "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack-horsehead.png",
					priority = "high",
					line_length = 8,
					frame_count = 40,
					animation_speed = 0.5,
					width = 206,
					height = 202,
					shift = util.by_pixel(-4, -24),
					scale = 0.5
				}
			},
			{
				priority = "high",
				filename = "__base__/graphics/entity/pumpjack/pumpjack-horsehead-shadow.png",
				animation_speed = 0.5,
				line_length = 8,
				frame_count = 40,
				width = 155,
				height = 41,
				shift = util.by_pixel(17.5, 14.5),
				draw_as_shadow = true,
				hr_version =
				{
					priority = "high",
					filename = "__base__/graphics/entity/pumpjack/hr-pumpjack-horsehead-shadow.png",
					line_length = 8,
					frame_count = 40,
					animation_speed = 0.5,
					width = 309,
					height = 82,
					shift = util.by_pixel(17.75, 14.5),
					draw_as_shadow = true,
					scale = 0.5
				}
			}
		}
	},
	west =
	{
		layers =
		{
			{
				stripes = make_stripes (10*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack_West-shadow.png"),
				priority = "high",
				frame_count = 40,
				width = 110,
				height = 111,
				shift = util.by_pixel(6, 0.5),
				draw_as_shadow = true,
				hr_version =
				{
					stripes = make_stripes (10*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack_West-shadow.png"),
					priority = "high",
					frame_count = 40,
					width = 220,
					height = 220,
					shift = util.by_pixel(6, 0.5),
					draw_as_shadow = true,
					scale = 0.5,
				}
			},
			{
				stripes = make_stripes (10*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack_West-base.png"),
				priority = "high",
				frame_count = 40,
				width = 131,
				height = 137,
				shift = util.by_pixel(-2.5, -4.5),
				hr_version =
				{
					stripes = make_stripes (10*5, "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack_West-base.png"),
					priority = "high",
					frame_count = 40,
					width = 260,
					height = 273,
					shift = util.by_pixel(-2.25, -4.75),
					scale = 0.5
				}
			},
			{
				filename = "__P-U-M-P-S__/graphics/entity/water-pumpjack/water-pumpjack-horsehead.png",
				priority = "high",
				line_length = 8,
				frame_count = 40,
				animation_speed = 0.5,
				width = 104,
				height = 102,
				shift = util.by_pixel(-4, -24),
				hr_version =
				{
					filename = "__P-U-M-P-S__/graphics/entity/water-pumpjack/hr-water-pumpjack-horsehead.png",
					priority = "high",
					line_length = 8,
					frame_count = 40,
					animation_speed = 0.5,
					width = 206,
					height = 202,
					shift = util.by_pixel(-4, -24),
					scale = 0.5
				}
			},
			{
				priority = "high",
				filename = "__base__/graphics/entity/pumpjack/pumpjack-horsehead-shadow.png",
				animation_speed = 0.5,
				line_length = 8,
				frame_count = 40,
				width = 155,
				height = 41,
				shift = util.by_pixel(17.5, 14.5),
				draw_as_shadow = true,
				hr_version =
				{
					priority = "high",
					filename = "__base__/graphics/entity/pumpjack/hr-pumpjack-horsehead-shadow.png",
					line_length = 8,
					frame_count = 40,
					animation_speed = 0.5,
					width = 309,
					height = 82,
					shift = util.by_pixel(17.75, 14.5),
					draw_as_shadow = true,
					scale = 0.5
				}
			}
		}
	}
}
end

return animation_set
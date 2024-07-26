---------------------------
----  local functions  ----
---------------------------

-- Setup function host
local OSM_local = {}

-- Fix offshore pumps collision mask
function OSM_local.fix_collision_mask()

	local offshore_pumps =
	{
		"offshore-pump-0",
		"offshore-pump-1",
		"offshore-pump-2",
		"offshore-pump-3",
		"offshore-pump-4"
	}

	for _, pump in pairs(offshore_pumps) do
		if data.raw["assembling-machine"][pump] then
		
			local offshore_pump = data.raw["assembling-machine"][pump]
			local offshore_placeholder = data.raw["offshore-pump"][pump.."-placeholder"]
			
			offshore_placeholder.collision_mask = offshore_pump.collision_mask
			offshore_placeholder.collision_box = offshore_pump.collision_box
			offshore_placeholder.selection_box = offshore_pump.selection_box
			offshore_placeholder.adjacent_tile_collision_box = offshore_pump.adjacent_tile_collision_box
		end
	end
end

-- Assign tiers to pumpjack icons
function OSM_local.pumpjack_icon_tiering()

	-- Setup entity host
	local tier_map=
	{
		["water-pumpjack-1"] = {1},
		["water-pumpjack-2"] = {2},
		["water-pumpjack-3"] = {3},
		["water-pumpjack-4"] = {4},
		["water-pumpjack-5"] = {5}
	}

	-- Set inputs
	local type = "assembling-machine"
	local mask = "__reskins-bobs__/graphics/icons/mining/pumpjack/pumpjack-icon-mask.png"
	local highlights = "__reskins-bobs__/graphics/icons/mining/pumpjack/pumpjack-icon-highlights.png"
	
	for name, map in pairs(tier_map) do
		if data.raw.item[name] then

			-- Parse map
			local tier = map[1]
		
			-- Determine what tint we're using
			local tint = reskins.lib.tint_index[tier]
			local icon = data.raw.item[name].icon
			
			-- Make icon inputs
			local icon_input
		
			if mask ~= nil and highlights ~= nil then
				icon_input =
				{
					{
						icon = icon,
						icon_size = 64,
						icon_mipmaps = 4
					},
					{
						icon = mask,
						icon_size = 64,
						icon_mipmaps = 4,
						tint = tint
					},
					{
				icon = highlights,
				icon_size = 64,
				icon_mipmaps = 4,
				tint = {1, 1, 1, 0}
			}
				}
			else
				icon_input =
				{
			{
				icon = icon,
				icon_size = 64,
				icon_mipmaps = 4
			}
		}
			end
		
			local inputs =
			{
		tint = reskins.lib.tint_index[tier],
		tier_labels = reskins.lib.setting("reskins-bobs-do-bobmining"),
		icon = icon_input
	}
		
			-- Insert tier label
			reskins.lib.append_tier_labels(tier, inputs)
		
			-- Apply icon reskin
			data.raw.item[name].icons = inputs.icon
			if data.raw[type][name] then
				data.raw[type][name].icons = inputs.icon
			elseif data.raw[type][name .. "-placeholder"] then
				data.raw[type][name .. "-placeholder"].icons = inputs.icon
			end
		end
	end
end

-- Assign tiers to pumpjack entities
function OSM_local.pumpjack_entity_tiering()

	-- Set input parameters
	local inputs =
	{
		type = "assembling-machine",
		base_entity_name = "pumpjack",
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

return OSM_local
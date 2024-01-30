require('scripts.prng')
require('scripts.math_utils')

--- @alias position { x?: number, y?: number }

--- @alias sprite_segment
--- | { filename?: string, width?: number, height?: number, frame_count?: number, scale?: number, shift?: position, tint?: Color }
--- | position

--- @alias sprite_segment_variants sprite_segment | sprite_segment[]

--- @alias widths { left: number, middle: number, right: number }
--- @alias heights { top: number, middle: number, bottom: number }

--- @alias sprite_definition
--- | { top_left?: sprite_segment_variants }
--- | { top?: sprite_segment_variants }
--- | { top_right?: sprite_segment_variants }
--- | { left?: sprite_segment_variants }
--- | { middle?: sprite_segment_variants }
--- | { right?: sprite_segment_variants }
--- | { bottom_left?: sprite_segment_variants }
--- | { bottom?: sprite_segment_variants }
--- | { bottom_right?: sprite_segment_variants }
--- | { top_center?: sprite_segment_variants }
--- | { left_center?: sprite_segment_variants }
--- | { center?: sprite_segment_variants }
--- | { right_center?: sprite_segment_variants }
--- | { bottom_center?: sprite_segment_variants }
--- | { filename: string, scale: number, shift: position, widths: widths, heights: heights, tint?: Color }
--- | { shadow?: boolean }

--- @alias entity_sprite
--- | { entity: sprite_definition, shadow?: sprite_definition }

--- @alias segments_data
--- | { wide_segments?: entity_sprite }
--- | { high_segments?: entity_sprite }
--- | { warehouse_segments?: entity_sprite }
--- | { trashdump_segments?: entity_sprite }

local function postprocess_sprite(sprite)
	local lcm = 1
	for _, layer in ipairs(sprite) do
		if layer.frame_count then
			lcm = math.lcm(lcm, layer.frame_count)
		end
	end

	if lcm > 1 then
		for _, layer in ipairs(sprite) do
			layer.repeat_count = lcm / (layer.frame_count or 1)
		end
	end
end

-- top left corner of sprite will be placed onto center of entity (plus shifts)
-- random decals may be used
-- shiftX, shiftY = local segment tile shift
-- shifts in segment(s) are pixel shifts
--- @param segments sprite_definition
--- @param segment sprite_segment_variants
--- @param shift_x number
--- @param shift_y number
--- @param width number | nil
--- @param height number | nil
--- @return table
local function create_sprite_tile(segments, segment, shift_x, shift_y, width, height)
	local main_segment = segment

	if segment[1] ~= nil then
		if segment[2] ~= nil and prng.range(1, 100) < MergingChests.get_mod_settings().sprite_variation_chance then
			main_segment = segment[1]
			segment = segment[prng.range(2, table_size(segment))]
		else
			main_segment = segment
			segment = segment[1]
		end
	end

	width = segment.width or width
	height = segment.height or height

	return
	{
		filename = segment.filename or segments.filename,
		priority = 'medium',
		x = (segment.x or main_segment.x or 0),
		y = (segment.y or main_segment.y or 0),
		width = width,
		height = height,
		shift =
		{
			shift_x + (width / 2.0 * (segments.scale or 1) + (segment.shift and segment.shift.x or 0) + segments.shift.x) / 32.0,
			shift_y + (height / 2.0 * (segments.scale or 1) + (segment.shift and segment.shift.y or 0) + segments.shift.y) / 32.0
		},
		scale = segment.scale or segments.scale or 1,
		frame_count = segment.frame_count or 1,
		draw_as_shadow = segments.shadow or false,
		tint = segment.tint or segments.tint
	}
end

--- @param width number
--- @param height number
--- @param segments sprite_definition
--- @param sprite_layers table
local function create_entity_sprite(width, height, segments, sprite_layers)
	local x0 = -width / 2
	local y0 = -height / 2
	local xM = width / 2 - 1
	local yM = height / 2 - 1

	-- do top line
	if segments.top_left then
		table.insert(sprite_layers, create_sprite_tile(segments, segments.top_left, x0, y0, segments.widths.left, segments.heights.top))
	end
	if segments.top then
		for x = 1, width - 2 do
			table.insert(sprite_layers, create_sprite_tile(segments, segments.top, x0 + x, y0, segments.widths.middle, segments.heights.top))
		end
	end
	if segments.top_right then
		table.insert(sprite_layers, create_sprite_tile(segments, segments.top_right, xM, y0, segments.widths.right, segments.heights.top))
	end

	-- do middle horizontal lines
	for y = 1, height - 2 do
		if segments.left then
			table.insert(sprite_layers, create_sprite_tile(segments, segments.left, x0, y0 + y, segments.widths.left, segments.heights.middle))
		end
		if segments.middle then
			for x = 1, width - 2 do
				table.insert(sprite_layers, create_sprite_tile(segments, segments.middle, x0 + x, y0 + y, segments.widths.middle, segments.heights.middle))
			end
		end
		if segments.right then
			table.insert(sprite_layers, create_sprite_tile(segments, segments.right, xM, y0 + y, segments.widths.right, segments.heights.middle))
		end
	end

	-- do bottom line
	if segments.bottom_left then
		table.insert(sprite_layers, create_sprite_tile(segments, segments.bottom_left, x0, yM, segments.widths.left, segments.heights.bottom))
	end
	if segments.bottom then
		for x = 1, width - 2 do
			table.insert(sprite_layers, create_sprite_tile(segments, segments.bottom, x0 + x, yM, segments.widths.middle, segments.heights.bottom))
		end
	end
	if segments.bottom_right then
		table.insert(sprite_layers, create_sprite_tile(segments, segments.bottom_right, xM, yM, segments.widths.right, segments.heights.bottom))
	end

	-- centers
	if segments.top_center then
		table.insert(sprite_layers, create_sprite_tile(segments, segments.top_center, (x0 + xM) / 2, y0, nil, nil))
	end
	if segments.left_center then
		table.insert(sprite_layers, create_sprite_tile(segments, segments.left_center, x0, (y0 + yM) / 2, nil, nil))
	end
	if segments.center then
		table.insert(sprite_layers, create_sprite_tile(segments, segments.center, (x0 + xM) / 2, (y0 + yM) / 2, nil, nil))
	end
	if segments.right_center then
		table.insert(sprite_layers, create_sprite_tile(segments, segments.right_center, xM, (y0 + yM) / 2, nil, nil))
	end
	if segments.bottom_center then
		table.insert(sprite_layers, create_sprite_tile(segments, segments.bottom_center, (x0 + xM) / 2, yM, nil, nil))
	end
end

--- @param width number
--- @param height number
--- @param segments entity_sprite
local function create_sprite(width, height, segments)
	local sprite_layers = { }

	create_entity_sprite(width, height, segments.entity, sprite_layers)
	if segments.shadow then
		create_entity_sprite(width, height, segments.shadow, sprite_layers)
	end

	postprocess_sprite(sprite_layers)

	return sprite_layers
end

return create_sprite
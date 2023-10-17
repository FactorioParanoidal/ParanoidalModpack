require("prng")

MergingChests.DecalChance = settings.startup["sprite-decal-chance"].value

function MergingChests.IndexToCoordinates(index, mod)
	return
		math.floor(math.fmod(index, mod)),
		math.floor(index / mod)
end

function MergingChests.PostprocessSprite(sprite)
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

---@param width number
---@param height number
---@param segments entity_sprite
function MergingChests.CreateSprite(width, height, segments)
	local sprite = { }

	MergingChests.CreateEntitySprite(width, height, segments.entity, sprite)
	if segments.shadow then
		MergingChests.CreateEntitySprite(width, height, segments.shadow, sprite)
	end
	
	MergingChests.PostprocessSprite(sprite)

	return sprite;
end

---@param width number
---@param height number
---@param segments sprite_definition
---@param sprite table
function MergingChests.CreateEntitySprite(width, height, segments, sprite)
	local x0 = -width / 2
	local y0 = -height / 2
	local xM = width / 2 - 1
	local yM = height / 2 - 1
	
	-- do top line
	if segments.top_left then
		table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 0, x0, y0))
	end
	if segments.top then
		for x = 1, width - 2 do
			table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 1, x0 + x, y0))
		end
	end
	if segments.top_right then
		table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 2, xM, y0))
	end
	
	-- do middle horizontal lines
	for y = 1, height - 2 do
		if segments.left then
			table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 3, x0, y0 + y))
		end
		if segments.middle then
			for x = 1, width - 2 do
				table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 4, x0 + x, y0 + y))
			end
		end
		if segments.right then
			table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 5, xM, y0 + y))
		end
	end
	
	-- do bottom line
	if segments.bottom_left then
		table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 6, x0, yM))
	end
	if segments.bottom then
		for x = 1, width - 2 do
			table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 7, x0 + x, yM))
		end
	end
	if segments.bottom_right then
		table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 8, xM, yM))
	end

	-- centers
	if segments.top_center then
		table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 11, (x0 + xM) / 2, y0))
	end
	if segments.left_center then
		table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 13, x0, (y0 + yM) / 2))
	end
	if segments.center then
		table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 14, (x0 + xM) / 2, (y0 + yM) / 2))
	end
	if segments.right_center then
		table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 15, xM, (y0 + yM) / 2))
	end
	if segments.bottom_center then
		table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 17, (x0 + xM) / 2, yM))
	end
end

-- top left corner of sprite will be placed onto center of entity (plus shifts)
-- random decals may be used
-- shiftX, shiftY = local segment tile shift
-- shifts in segment(s) are pixel shifts
---@param sprite_definition sprite_definition
---@param segment_index number
---@param shift_x number
---@param shift_y number
---@return table
function MergingChests.CreateSpriteInfo(sprite_definition, segment_index, shift_x, shift_y)
	local segment = sprite_definition[segment_index]
	local main_segment = segment

	if segment[1] ~= nil then
		if segment[2] ~= nil and prng.range(1, 100) < MergingChests.DecalChance then
			main_segment = segment[1]
			segment = segment[prng.range(2, table_size(segment))]
		else
			main_segment = segment
			segment = segment[1]
		end
	end
	
	local index_horizontal, index_vertical = MergingChests.IndexToCoordinates(segment_index, 3)
	local width = segment.width or sprite_definition.widths[index_horizontal]
	local height = segment.height or sprite_definition.heights[index_vertical]
	
	return
	{
		filename = segment.sprite or sprite_definition.sprite,
		priority = "medium",
		x = (segment.x or main_segment.x or 0),
		y = (segment.y or main_segment.y or 0),
		width = width,
		height = height,
		shift =
		{
			shift_x + (width / 2.0 * (sprite_definition.scale or 1) + (segment.shift and segment.shift.x or 0) + sprite_definition.shift.x) / 32.0,
			shift_y + (height / 2.0 * (sprite_definition.scale or 1) + (segment.shift and segment.shift.y or 0) + sprite_definition.shift.y) / 32.0
		},
		scale = segment.scale or sprite_definition.scale or 1,
		frame_count = segment.frame_count or 1,
		draw_as_shadow = sprite_definition.shadow or false
	}
end
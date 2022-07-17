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

function MergingChests.CreateSprite(width, height, segments)
	local sprite = { }

	MergingChests.CreateEntitySprite(width, height, segments.entity, sprite)
	if segments.shadow then
		MergingChests.CreateEntitySprite(width, height, segments.shadow, sprite)
	end
	
	MergingChests.PostprocessSprite(sprite)

	return sprite;
end

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
-- segments.shift.x, segments.shift.x = global entity pixel shift (32 pixels pet tile)
-- segment.shift.x, segment.shift.y = local segment pixel shift (32 pixels pet tile)
function MergingChests.CreateSpriteInfo(segments, segmentIndex, shiftX, shiftY)
	local segment = segments[segmentIndex]
	
	if #segment > 0 then
		if prng.range(1, 100) < MergingChests.DecalChance then
			segment = segment[prng.range(2, #segment)]
		else
			segment = segment[1]
		end
	end
	
	local indexH, indexV = MergingChests.IndexToCoordinates(segmentIndex, 3)
	local width = segment.width or segments.widths[indexH + 1]
	local height = segment.height or segments.heights[indexV + 1]
	
	return
	{
		filename = segment.sprite or segments.sprite,
		priority = "medium",
		x = segment.x or 0,
		y = segment.y or 0,
		width = segment.width or width,
		height = segment.height or height,
		shift =
		{
			shiftX + (width / 2.0 * (segments.scale or 1.0) + (segment.shift and segment.shift.x or 0) + segments.shift.x) / 32.0,
			shiftY + (height / 2.0 * (segments.scale or 1.0) + (segment.shift and segment.shift.y or 0) + segments.shift.y) / 32.0
		},
		scale = segments.scale or 1,
		frame_count = segment.frame_count or 1,
		draw_as_shadow = segments.shadow or false
	}
end
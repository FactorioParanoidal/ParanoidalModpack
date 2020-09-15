function MergingChests.IndexToCoordinates(index, mod)
	return
		math.floor(math.fmod(index, mod)),
		math.floor(index / mod)
end

MergingChests.DecalChance = settings.startup["sprite-decal-chance"].value

------  PRNG for generation sprite decals
-- Code from https://github.com/bobbens/ArtTreeKS/blob/master/examples/prng.lua

prng = { z = 1 }

function prng.initHash(str)
   local hash = 5381
   local i = 1
   local bytes = { string.byte(str, 1, string.len(str)) }
   for _,c in ipairs(bytes) do
      hash = hash * 33 + c
   end
   prng.z = math.abs(math.fmod(hash, 4294967295))
end

function prng.num()
   prng.z = math.abs(math.fmod(prng.z * 279470273, 4294967295))
   return prng.z / 4294967295
end

function prng.range(min, max)
   local n = prng.num()
   return math.floor(min + n * (max - min) + 0.5)
end

prng.initHash("MergingChests")

------ /PRNG for generation sprite decals

function MergingChests.CreateSprite(width, height, segments)
	local sprite = { }

	MergingChests.CreateEntitySprite(width, height, segments.entity, sprite)
	if segments.shadow then
		MergingChests.CreateEntitySprite(width, height, segments.shadow, sprite)
	end

	return sprite;
end

function MergingChests.CreateEntitySprite(width, height, segments, sprite)
	local x0 = -width / 2
	local y0 = -height / 2
	local xM = width / 2 - 1
	local yM = height / 2 - 1
	
	-- do top line
	if segments.top_left then
		table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 0, segments.top_left, x0, y0))
	end
	if segments.top then
		for x = 1, width - 2 do
			table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 1, segments.top, x0 + x, y0))
		end
	end
	if segments.top_right then
		table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 2, segments.top_right, xM, y0))
	end
	
	-- do middle horizontal lines
	for y = 1, height - 2 do
		if segments.left then
			table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 3, segments.left, x0, y0 + y))
		end
		if segments.middle then
			for x = 1, width - 2 do
				table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 4, segments.middle, x0 + x, y0 + y))
			end
		end
		if segments.right then
			table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 5, segments.right, xM, y0 + y))
		end
	end
	
	-- do bottom line
	if segments.bottom_left then
		table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 6, segments.bottom_left, x0, yM))
	end
	if segments.bottom then
		for x = 1, width - 2 do
			table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 7, segments.bottom, x0 + x, yM))
		end
	end
	if segments.bottom_right then
		table.insert(sprite, MergingChests.CreateSpriteInfo(segments, 8, segments.bottom_right, xM, yM))
	end
end

-- top left corner of sprite will be placed onto center of entity (plus shifts)
-- random decals may be used
-- shiftX, shiftY = local segment tile shift
-- segment.shift.x, segment.shift.x = global entity pixel shift (32 pixels pet tile)
-- segmentData.shiftX, segmentData.shiftX = local segment pixel shift (32 pixels pet tile)
function MergingChests.CreateSpriteInfo(segments, segmentIndex, segmentData, shiftX, shiftY)
	local sheetX = 0
	local sheetY = 0
	local indexH, indexV
	
	if segments.spritesheet and segments.spritesheet.count > 1 then
		if prng.range(1, 100) < MergingChests.DecalChance then
			local sheetIndex = prng.range(1, segments.spritesheet.count - 1)
			
			indexH, indexV = MergingChests.IndexToCoordinates(sheetIndex, segments.spritesheet.columns)
			
			sheetX = segments.spritesheet.width * indexH
			sheetY = segments.spritesheet.height * indexV
		end
	end
	
	indexH, indexV = MergingChests.IndexToCoordinates(segmentIndex, 3)
	
	local width = segments.widths[indexH + 1]
	local height = segments.heights[indexV + 1]
	
	return
	{
		filename = segmentData.sprite or segments.sprite,
		priority = "medium",
		x = sheetX + (segmentData.x or 0),
		y = sheetY + (segmentData.y or 0),
		width = width,
		height = height,
		shift =
		{
			shiftX + (width / 2.0 * (segments.scale or 1.0) + (segmentData.shiftX or 0) + segments.shift.x) / 32.0,
			shiftY + (height / 2.0 * (segments.scale or 1.0) + (segmentData.shiftY or 0) + segments.shift.y) / 32.0
		},
		scale = segments.scale or 1,
		draw_as_shadow = segments.shadow or false
	}
end
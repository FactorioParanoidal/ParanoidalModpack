if (bitersEnrageG) then
    return bitersEnrageG
end
local bitersEnrage = {}

local bitersInRange_Query = {
	position = nil,
	radius = 32,
	limit = 200,
	force = "enemy",
	type = {"unit"}
    }

local function enrageStickersParameters()
	local enrageStickers = {}
	for i = 1, 13 do
		enrageStickers[#enrageStickers+1] = {lvl = i, movementModifier = 1 + (i-1)*0.10, tint = {r = 0.3+(i-1)*0.05, g = 0.7-(i-1)*0.05, b = 0.5-(i-1)*0.02, a = 0.005 + 0.02*(i-1) }, name = "enrage-sticker-lvl"..i.."-rampant"}
	end
	return enrageStickers
end

function bitersEnrage.createStickers()
	
	local enrageStickers = enrageStickersParameters()
	for i, stickerParameters in pairs (enrageStickers) do
		-- stickerTemplate.animation.tint = stickerParameters.tint
		-- stickerTemplate.target_movement_modifier = stickerParameters.movementModifier
		data:extend({{
		type = "sticker",
		name = stickerParameters.name,
		flags = {"not-on-map"},

		animation =
		{
		  filename = "__base__/graphics/entity/fire-flame/fire-flame-13.png",
		  line_length = 8,
		  width = 60,
		  height = 118,
		  frame_count = 25,
		  blend_mode = "normal",
		  animation_speed = 0.5,
		  scale = 0.3,
		  tint = stickerParameters.tint,
		  --shift = math3d.vector2.mul({-0.078125, -1.8125}, 0.1),
		  draw_as_glow = true
		},
		force_visibility = "ally",
		duration_in_ticks = 30 * 60,
		target_movement_modifier = stickerParameters.movementModifier
		}}
		)
	
	end
end

local function createEnrageSequence()
	local enrageSequence = {}
	local enrageStickers = enrageStickersParameters()
	local prevSticker
	for i, stickerParameters in pairs (enrageStickers) do
		enrageSequence[(prevSticker or "none")] = stickerParameters.name
		prevSticker = stickerParameters.name
	end
	if prevSticker then
		enrageSequence[prevSticker] = prevSticker		
	end
	return enrageSequence
end
local enrageSequence = createEnrageSequence()

local function getNeighborChunksArray(map, x, y)
    local neighbors = {}
    local chunkYRow1 = y - 32
    local chunkYRow3 = y + 32
    local xChunks = map[x-32]
    if xChunks then
        neighbors[#neighbors+1] = xChunks[chunkYRow1]
        neighbors[#neighbors+1] = xChunks[y]
        neighbors[#neighbors+1] = xChunks[chunkYRow3]
     end

    xChunks = map[x+32]
    if xChunks then
        neighbors[#neighbors+1] = xChunks[chunkYRow1]
        neighbors[#neighbors+1] = xChunks[y]
        neighbors[#neighbors+1] = xChunks[chunkYRow3]
    end

    xChunks = map[x]
    if xChunks then
        neighbors[#neighbors+1] = xChunks[chunkYRow1]
        neighbors[#neighbors+1] = xChunks[chunkYRow3]
    end
    return neighbors
end

function bitersEnrage.enrageBitersInRange(map, position, chunk, tick)
	if chunk == -1 then
		return false
	end
	if chunk.enrageTick and (chunk.enrageTick > tick) then
		return false
	end
	local surface = map.surface
	bitersInRange_Query.position = position
	local entities = surface.find_entities_filtered(bitersInRange_Query) 

	chunk.enrageTick = tick + 600
	if #entities > 60 then
		local neighbors = getNeighborChunksArray(map, chunk.x, chunk.y)
		for i, neighborChunk in pairs(neighbors) do
			if neighborChunk ~= -1 then
				neighborChunk.enrageTick = chunk.enrageTick 
			end
		end
		local flyingTextparameters = {text = "biters enraged", surface = surface, position = position, color = {1, 0, 0}, speed  = 4, time_to_live = 120}
		for i, player in pairs(game.connected_players) do
			if player.valid then
				if map.surface.index == ((player.surface and player.surface.index) or 0) then
					player.create_local_flying_text(flyingTextparameters)
				end	
			end	
		end
		local enrageStickerName
		for i, entity in pairs(entities) do
			if entity.valid and (not entity.has_flag("not-in-kill-statistics")) then
				if entity.stickers then
					for ii, sticker in pairs(entity.stickers) do
						if enrageSequence[sticker.name] then
							enrageStickerName = enrageSequence[sticker.name]
						end
					end
				end	
				enrageStickerName = (enrageStickerName or enrageSequence["none"])
				surface.create_entity({name= enrageStickerName, position = position, target = entity})
			end	
		 end
	end
end


bitersEnrageG = bitersEnrage
return bitersEnrage
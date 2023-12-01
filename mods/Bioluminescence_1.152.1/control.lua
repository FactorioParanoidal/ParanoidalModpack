require "config"
require "constants"
require "functions"
require "prototypes.colorkeys"

require "__DragonIndustries__.strings"
require "__DragonIndustries__.mathhelper"

addCommands()


function initGlobal(markDirty)
	if not global.biolum then
		global.biolum = {}
	end
	local bb = global.biolum
	bb.dirty = markDirty
end

script.on_configuration_changed(function(data)
	initGlobal(true)
	reloadAllLights(false)
end)

local function controlChunk(surface, area)
	if not Config.glowPlants then return end
	
	local rand = game.create_random_generator()
	local seed = createSeed(surface, area.left_top.x, area.left_top.y) --[[@as uint]]
	rand.re_seed(seed)
	for class,rate in pairs(PLANT_SPAWN_RATE) do
		local f1 = rand(0, 2147483647)/2147483647
		--game.print("Chunk at " .. serpent.block(area) .. " with chance " .. f .. " / " .. f1)
		if f1 <= rate.chunkChance then
			local f2 = rand(0, 2147483647)/2147483647
			--game.print("Genning Chunk with " .. class .. " at " .. serpent.block(area))
			local count = rand(1, rate.perChunk)
			count = math.max(1, math.ceil(count*Config.density))
			--game.print("Chunk at " .. serpent.block(area) .. " attempting " .. count)
			for i = 1, count do
				local dx = rand(area.left_top.x, area.right_bottom.x)
				local dy = rand(area.left_top.y, area.right_bottom.y)
				if f2 <= rate.clusterChance then
					local f3 = rand(0, 2147483647)/2147483647
					local s = math.floor(rate.clusterSize[1]+f3*(rate.clusterSize[2]-rate.clusterSize[1])+0.5)
					local r = math.floor(rate.clusterRadius[1]+f3*(rate.clusterRadius[2]-rate.clusterRadius[1])+0.5)
					for k = 1, s do
						local ddx = rand(dx-r, dx+r)
						local ddy = rand(dy-r, dy+r)
						placeIfCan(surface, ddx, ddy, rand, class)
					end
				else
					placeIfCan(surface, dx, dy, rand, class)
				end
			end
		end
	end
end

script.on_event(defines.events.on_chunk_generated, function(event)
	controlChunk(event.surface, event.area)
end)

script.on_event(defines.events.on_tick, function(event)	
	if not ranTick and Config.retrogenDistance >= 0 then
		local surface = game.surfaces["nauvis"]
		for chunk in surface.get_chunks() do
			local x = chunk.x
			local y = chunk.y
			if surface.is_chunk_generated({x, y}) then
				local area = {
					left_top = {
						x = x*CHUNK_SIZE,
						y = y*CHUNK_SIZE
					},
					right_bottom = {
						x = (x+1)*CHUNK_SIZE,
						y = (y+1)*CHUNK_SIZE
					}
				}
				local dx = x*CHUNK_SIZE+CHUNK_SIZE/2
				local dy = y*CHUNK_SIZE+CHUNK_SIZE/2
				local dist = math.sqrt(dx*dx+dy*dy)
				if dist >= Config.retrogenDistance then
					controlChunk(surface, area)
				end
			end
		end
		ranTick = true
		for name,force in pairs(game.forces) do
			force.rechart()
		end
		--game.print("Ran load code")
	end
	
	local biolum = global.biolum
	if biolum and biolum.chunks_to_refresh and Config.treeRefreshRate > 0 then
		for i = 1,Config.treeRefreshRate do
			if #biolum.chunks_to_refresh > 0 then
				local e = biolum.chunks_to_refresh[1]
				local c = reloadLightsInArea(e.surface, {{e.chunk.x*32, e.chunk.y*32}, {e.chunk.x*32+31, e.chunk.y*32+31}})
				--game.print("Reloaded " .. c .. " lights in chunk " .. e.chunk.x .. ", " .. e.chunk.y .. "; " .. (#biolum.chunks_to_refresh-1) .. " remaining")
				table.remove(biolum.chunks_to_refresh, 1)
			end
		end
	end
	
	--local pos=game.players[1].position
	--for k,v in pairs(game.surfaces.nauvis.find_entities_filtered{area={{pos.x-1,pos.y-1},{pos.x+1,pos.y+1}}, type="resource"}) do v.destroy() end
end)

local function onEntityRemoved(event)	
	local entity = event.entity
	if not Config.scriptLight and string.find(entity.name, "glowing-tree", 1, true) then
		--game.print(entity.name)
		removeLightsAroundEntity(entity)
	end
end

local function onEntityAdded(event)	
	local entity = event.created_entity
	if string.find(entity.name, "glowing-tree", 1, true) then
		createTreeLightSimple(entity)
	end
end

local function onEntitySpawned(event)	
	local entity = event.entity
	
	if entity.type == "unit" and Config.glowBiters then
		--[[
		if string.find(entity.name, "biter", 1, true) or string.find(entity.name, "spitter", 1, true) then
			local key = literalReplace(entity.name, "-biter", "")
			key = literalReplace(key, "-spitter", "")
			--game.print(key)
			local params = BITER_GLOW_PARAMS[key]
			if params then
				rendering.draw_light{sprite="utility/light_medium", scale=params.size, intensity=1, color=params.color, target=entity, surface=entity.surface}
			end
		end
		--]]
		--createBiterLight(entity)
	end
end

script.on_event(defines.events.on_entity_died, onEntityRemoved)
script.on_event(defines.events.script_raised_destroy, onEntityRemoved)
script.on_event(defines.events.on_player_mined_entity, onEntityRemoved)
script.on_event(defines.events.on_robot_mined_entity, onEntityRemoved)

script.on_event(defines.events.on_built_entity, onEntityAdded)
script.on_event(defines.events.on_robot_built_entity, onEntityAdded)

--script.on_event(defines.events.on_entity_spawned, onEntitySpawned)
require "modules.tools"
local Area =  require("__stdlib__/stdlib/area/area") -- required for Chunk
local Chunk = require("__stdlib__/stdlib/area/chunk")

function findNestNear(entity, chunk_position)
	local search = Chunk.to_area(chunk_position)
	local spawners = entity.surface.find_entities_filtered{area = search, type = "unit-spawner"}
	if #spawners > 0 then
		return spawners[math.random(#spawners)]
	end
	if settings.global["ion-cannon-target-worms"].value then
		local worms = entity.surface.find_entities_filtered{area = search, type = "turret"}
		if #worms > 0 then
			return worms[math.random(#worms)]
		end
	end
	return false
end

--- Alerts each player in force that ion cannon has fired
local alertCannonFired = function (force, target, message)
	for _, player in pairs(force.connected_players) do
		if settings.get_player_settings(player)["ion-cannon-custom-alerts"].value then
			player.add_custom_alert(target, {type = "item", name = "orbital-ion-cannon"}, message, true)
		end
	end
end

local processQueue = function ()
	--print("processQueue")
	local target = global.forces_ion_cannon_table["Queue"][1]
	if not target or not target.valid then
		table.remove(global.forces_ion_cannon_table["Queue"], 1)
		return
	end

	local tryToFire = function (force)
		--print("tryToFire",force.name,countIonCannonsReady(force, target.surface),settings.global["ion-cannon-min-cannons-ready"].value )
		if countIonCannonsReady(force, target.surface) <= settings.global["ion-cannon-min-cannons-ready"].value then return false end
		local current_tick = game.tick
		if global.auto_tick >= current_tick then return false end
		global.auto_tick = current_tick + (settings.startup["ion-cannon-heatup-multiplier"].value * 210)
		local fired = targetIonCannon(force, target.position, target.surface)
		if not fired then return false end
		alertCannonFired(force, target, {"ion-cannon-target-location", true, target.position.x, target.position.y, "Auto"});
		table.remove(global.forces_ion_cannon_table["Queue"], 1)
		return true
	end

	for _, force in pairs(game.forces) do
		if tryToFire(force) then break end
	end
end

--- Called when the radar finishes scanning a sector. Can be filtered for the radar using
-- radar :: LuaEntity: The radar that did the scanning.
-- chunk_position :: ChunkPosition: The chunk scanned.
-- area :: BoundingBox: Area of the scanned chunk.
script.on_event(defines.events.on_sector_scanned, function(event)
	--print("on_sector_scanned",serpent.line(event.chunk_position), serpent.line(event.area))
	if #global.forces_ion_cannon_table["Queue"] > 0 then
		processQueue();
	end

	--local p = false; if global.permissions[-2] then p = true end
	--local t = event.radar.force.technologies["auto-targeting"].researched
	--local s = settings.global["ion-cannon-min-cannons-ready"].value
	--local c = countIonCannonsReady(event.radar.force, event.radar.surface)
	--print(p,t,s,c)
	if not global.permissions[-2] then return end
	local radar = event.radar
	local force = radar.force
	if not force.technologies["auto-targeting"].researched then return end
	if countIonCannonsReady(force, radar.surface) <= settings.global["ion-cannon-min-cannons-ready"].value then return end
	local target = findNestNear(radar, event.chunk_position)
	if not target then return end
	local fired = targetIonCannon(force, target.position, radar.surface)
	if not fired then return end
	alertCannonFired(force,target,{"auto-target-designated", radar.backer_name, target.position.x, target.position.y})
end)

--- Called when a biter migration builds a base.
-- entity :: LuaEntity: The built entity.
-- Note: This will be called multiple times as each biter in a given migration is sacrificed and builds part of the base.
script.on_event(defines.events.on_biter_base_built, function(e)
	--print("on_biter_base_built", serpent.line(e.entity.position))
	if not settings.global["ion-cannon-auto-target-visible"].value then return end
	-- Auto-Target New Nests in Visible Regions
	local biterBase = e.entity
	local chunk = Chunk.from_position(biterBase.position)
	for _, force in pairs(game.forces) do
		if force.technologies["auto-targeting"].researched == true and force.is_chunk_visible(biterBase.surface, chunk) then
			--print("insert biter base to Queue")
			table.insert(global.forces_ion_cannon_table["Queue"], biterBase)
			return
		end
	end
end)

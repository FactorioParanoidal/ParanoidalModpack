local Area =  require("__Kux-CoreLib__/stdlib/area/area") -- required for Chunk
local Chunk = require("__Kux-CoreLib__/stdlib/area/chunk")
local Events = KuxCoreLib.Events

---@class AutoTargeter
AutoTargeter = {}
---@class AutoTargeter.private
local this = {}

require "modules/tools"
require "modules/IonCannonStorage"
---------------------------------------------------------------------------------------------------

function findNestNear(entity, chunk_position)
	local search = Chunk.to_area(chunk_position)
	local spawners = entity.surface.find_entities_filtered{area = search, type = "unit-spawner", limit = 3} --limit is arbitrarily set for testing, can/should be reduced later if it doesn't cause any undesirable behavior
	for _, dest in ipairs(spawners) do
		if dest.force.name == entity.force.name then spawners = {}; break end
	end
	if #spawners > 0 then
		return spawners[math.random(#spawners)]
	end
	if settings.global["ion-cannon-target-worms"].value then
		local worms = entity.surface.find_entities_filtered{area = search, type = "turret", limit = 6, collision_mask = "player"} --limit is arbitrarily set for testing, can/should be reduced later if it doesn't cause any undesirable behavior
		for _, dest in ipairs(worms) do
			if dest.force.name == entity.force.name then worms = {}; break end
		end
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
	local queue = IonCannonStorage.getQueue()
	local target = queue[1] --[[@as LuaEntity]]
	if not target or not target.valid then
		table.remove(queue, 1)
		return
	end

	local tryToFire = function (force)
		--print("tryToFire",force.name,IonCannonStorage.countIonCannonsReady(force, target.surface),settings.global["ion-cannon-min-cannons-ready"].value )
		if IonCannonStorage.countIonCannonsReady(force, target.surface) <= settings.global["ion-cannon-min-cannons-ready"].value then return false end
		local current_tick = game.tick
		if storage.auto_tick >= current_tick then return false end
		storage.auto_tick = current_tick + (settings.startup["ion-cannon-heatup-multiplier"].value * 210)
		local fired = IonCannon.target(force, target.position, target.surface)
		if not fired then return false end
		alertCannonFired(force, target, {"ion-cannon-target-location", true, target.position.x, target.position.y, "Auto"});
		table.remove(queue, 1)
		return true
	end

	for _, force in pairs(game.forces) do
		if tryToFire(force) then break end
	end
end

---comments
---@param e EventData.on_sector_scanned
--- Called when the radar finishes scanning a sector. Can be filtered for the radar using
-- radar :: LuaEntity: The radar that did the scanning.
-- chunk_position :: ChunkPosition: The chunk scanned.
-- area :: BoundingBox: Area of the scanned chunk.
function this.on_sector_scanned(e)
	--print("on_sector_scanned",serpent.line(event.chunk_position), serpent.line(event.area))
	if IonCannonStorage.countQueue() > 0 then processQueue(); end

	--local p = false; if global.permissions[-2] then p = true end
	--local t = event.radar.force.technologies["auto-targeting"].researched
	--local s = settings.global["ion-cannon-min-cannons-ready"].value
	--local c = IonCannonStorage.countIonCannonsReady(event.radar.force, event.radar.surface)
	--print(p,t,s,c)
	if not storage.permissions[-2] then return end
	local radar = e.radar
	local force = radar.force
	if not force.technologies["auto-targeting"].researched then return end
	if IonCannonStorage.countIonCannonsReady(force, radar.surface) <= settings.global["ion-cannon-min-cannons-ready"].value then return end
	local target = findNestNear(radar, e.chunk_position)
	if not target then return end
	local fired = IonCannon.target(force, target.position, radar.surface)
	if not fired then return end
	alertCannonFired(force,target,{"auto-target-designated", radar.backer_name, target.position.x, target.position.y})
end

Events.on_event(defines.events.on_sector_scanned, this.on_sector_scanned)
if prototypes.custom_event.script_raised_sector_scanned then
	Events.on_event(prototypes.custom_event.script_raised_sector_scanned.event_id, this.on_sector_scanned)
end

--- Called when a biter migration builds a base.
-- entity :: LuaEntity: The built entity.
-- Note: This will be called multiple times as each biter in a given migration is sacrificed and builds part of the base.
Events.on_event(defines.events.on_biter_base_built, function(e)
	--print("on_biter_base_built", serpent.line(e.entity.position))
	if not settings.global["ion-cannon-auto-target-visible"].value then return end
	-- Auto-Target New Nests in Visible Regions
	local biterBase = e.entity
	local chunk = Chunk.from_position(biterBase.position)
	for _, force in pairs(game.forces) do
		if force.technologies["auto-targeting"].researched == true and force.is_chunk_visible(biterBase.surface, chunk) then
			--print("insert biter base to Queue")
			table.insert(IonCannonStorage.getQueue(), biterBase)
			return
		end
	end
end)
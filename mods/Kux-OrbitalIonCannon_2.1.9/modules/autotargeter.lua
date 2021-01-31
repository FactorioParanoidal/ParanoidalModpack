require "modules.tools"
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

--- Called when the radar finishes scanning a sector. Can be filtered for the radar using
-- radar :: LuaEntity: The radar that did the scanning.
-- chunk_position :: ChunkPosition: The chunk scanned.
-- area :: BoundingBox: Area of the scanned chunk.
script.on_event(defines.events.on_sector_scanned, function(event)
	--print("on_sector_scanned",serpent.line(event.chunk_position), serpent.line(event.area))
	local surfaceName = event.radar.surface.name -- TODO same as target.surface?
	if #global.forces_ion_cannon_table["Queue"] > 0 then
		local target = global.forces_ion_cannon_table["Queue"][1]
		if target and target.valid then
			for i, force in pairs(game.forces) do
				if settings.global["ion-cannon-min-cannons-ready"].value < countIonCannonsReady(force, target.surface) then
					local current_tick = game.tick
					if global.auto_tick < current_tick then
						global.auto_tick = current_tick + (settings.startup["ion-cannon-heatup-multiplier"].value * 210)
						local fired = targetIonCannon(force, target.position, target.surface)
						if fired then
							for _, player in pairs(force.connected_players) do
								if settings.get_player_settings(player)["ion-cannon-custom-alerts"].value then
									player.add_custom_alert(target, {type = "item", name = "orbital-ion-cannon"}, {"ion-cannon-target-location", fired, target.position.x, target.position.y, "Auto"}, true)
								end
							end
							table.remove(global.forces_ion_cannon_table["Queue"], 1)
							break
						end
					end
				end
			end
		else
			table.remove(global.forces_ion_cannon_table["Queue"], 1)
		end
	end

	--local p = false; if global.permissions[-2] then p = true end
	--local t = event.radar.force.technologies["auto-targeting"].researched
	--local s = settings.global["ion-cannon-min-cannons-ready"].value
	--local c = countIonCannonsReady(event.radar.force, event.radar.surface)
	--print(p,t,s,c)
	if global.permissions[-2] then
		local radar = event.radar
		local force = radar.force
		if force.technologies["auto-targeting"].researched == true and settings.global["ion-cannon-min-cannons-ready"].value < countIonCannonsReady(force, radar.surface) then
			local target = findNestNear(radar, event.chunk_position)
			if target then
				local fired = targetIonCannon(force, target.position, radar.surface)
				if fired then
					for i, player in pairs(force.connected_players) do
						if settings.get_player_settings(player)["ion-cannon-custom-alerts"].value then
							player.add_custom_alert(target, {type = "item", name = "orbital-ion-cannon"}, {"auto-target-designated", radar.backer_name, target.position.x, target.position.y}, true)
						end
					end
				end
			end
		end
	end
end)

--- Called when a biter migration builds a base.
-- entity :: LuaEntity: The built entity.
-- Note: This will be called multiple times as each biter in a given migration is sacrificed and builds part of the base.
script.on_event(defines.events.on_biter_base_built, function(e)
	--print("on_biter_base_built", serpent.line(e.entity.position))
	if settings.global["ion-cannon-auto-target-visible"].value then -- Auto-Target New Nests in Visible Regions
		local biterBase = e.entity
		for _, force in pairs(game.forces) do
			if force.technologies["auto-targeting"].researched == true and force.is_chunk_visible(biterBase.surface, Chunk.from_position(biterBase.position)) then
				print("insert biter base to Queue")
				table.insert(global.forces_ion_cannon_table["Queue"], biterBase)
				return
			end
		end
	end
end)

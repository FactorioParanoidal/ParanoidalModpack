if mod.modules.IonCannon then return mod.modules.IonCannon end

---@class IonCannon
IonCannon = {}
mod.modules.IonCannon = IonCannon

---@class IonCannon.private : IonCannon
local this = setmetatable({}, {__index = IonCannon})

-----------------------------------------------------------------------------------------------------------------------

---@param surface LuaSurfaceId
---@return LuaSurface
function IonCannon.getOrbitingSurface(surface)
	surface = getSurface(surface)
	if surface.platform and surface.platform.space_location and surface.platform.space_location.type=="planet" then
		local s = game.surfaces[surface.platform.space_location.name]
		if s and s.valid then surface = s end
	end
	return surface
end

--Reduce cannon cooldowns. Time parameter is optional, defaults to 1
function IonCannon.ReduceIonCannonCooldowns(time)
	time = time or 1;
	for _, force in pairs(game.forces) do
		local cannons = IonCannonStorage.fromForce(force)
		for k, cannon in pairs(cannons) do
			if cannon[1] > 0 then
				cannons[k][1] = cannons[k][1] - time
				if cannon[1] < 0 then cannon[1] = 0 end
			end
		end
	end
end

---@param player LuaPlayer
---@return boolean
function IonCannon.isAllIonCannonOnCooldown(player)
	for i, cooldown in pairs(IonCannonStorage.fromForce(player.force)) do
		if cooldown[2] == 1 then return false end
	end
	return true
end

---@param force LuaForceId
---@param surface LuaSurfaceId
---@return integer
function IonCannon.countReady(force, surface)
	surfaceName = this.getOrbitingSurface(surface).name
	local count = 0
	for i, cannon in pairs(IonCannonStorage.fromForce(force)) do
		if cannon[3]==surfaceName and cannon[2] == 1 then count = count + 1 end
	end
	return count
end

---@param force LuaForceId
---@return boolean
function IonCannon.isIonCannonReady(force)
	local found = false
	for i, cooldown in pairs(IonCannonStorage.fromForce(force)or {}) do
		if cooldown[1] == 0 and cooldown[2] == 0 then
			cooldown[2] = 1
			found = true
		end
	end
	return found
end

--Given a surface, counts the number of orbiting ion cannons. If the surface is an orbit, it counts the number of cannons attached to the associated planet instead
---@param force LuaForceId
---@param surface LuaSurfaceId
---@return integer
function IonCannon.countOrbitingIonCannons(force, surface)
	surface = getSurface(surface)
	local surfaceName = surface.name

	if mods["space-exploration"] then
		local suffix=" Orbit"
		if #surfaceName > #suffix and string.sub(surfaceName, -#suffix) == suffix then
			local sn = string.sub(surfaceName, 1, #surfaceName-#suffix)
			if game.surfaces[surfaceName] then surfaceName = sn end
			surfaceName = sn
		end
	end

	surfaceName = this.getOrbitingSurface(surfaceName).name

	local total = 0
	local cannons = IonCannonStorage.fromForce(force)
	if not cannons then return 0 end
	for i = 1, #cannons do
		if surfaceName == cannons[i][3] then
			total = total + 1
		end
	end
	return total
end

---@param force integer|string|LuaForce
---@param surface string|LuaSurface
---@return number
function IonCannon.timeUntilNextReady(force, surface) -- TODO check all callers
	local surfaceName = nil
	if type(surface) == "string" then surfaceName = surface else surfaceName = surface.name end

	local shortestCooldown = settings.global["ion-cannon-cooldown-seconds"].value --[[@as number]]
	local cannons = IonCannonStorage.fromForce(force)
	if not cannons then return shortestCooldown end
	for i, cooldown in pairs(cannons) do
		if cooldown[1] < shortestCooldown and cooldown[2] == 0 and cooldown[3] == surfaceName then
			shortestCooldown = cooldown[1]
		end
	end
	return shortestCooldown
end

--Adds an ion cannon. Ensures Ion cannons aren't added in orbit.
--Returns the name of the surface the cannon was added to.
---@param force integer|string|LuaForce
---@param surface string|LuaSurface
---@return string
function IonCannon.add(force, surface)
	local surfaceName = getSurfaceName(surface)
	if(mods["space-exploration"]) then -- "Nauvis Orbit" => "Nauvis"
		local suffix=" Orbit"
		if #surfaceName > #suffix and string.sub(surfaceName, -#suffix) == suffix then
			local sn = string.sub(surfaceName, 1, #surfaceName-#suffix)
			if game.surfaces[surfaceName] then surfaceName = sn end
			surfaceName = sn
		end
	end
	table.insert(IonCannonStorage.fromForce(force), {settings.global["ion-cannon-cooldown-seconds"].value, 0, surfaceName})
	storage.IonCannonLaunched = true
	return surfaceName
end

--Removes an ion cannon.
--Returns the name of the surface the cannon was removed from.
-- function removeIonCannon(force, surface)
-- 	local surfaceName = surface.name
-- 	if GetCannonTableFromForce(force).size()
-- end


---@param force integer|string|LuaForce
---@param position MapPosition
---@param surface LuaSurface
---@param player LuaPlayer?
---@return boolean
function IonCannon.target(force, position, surface, player)
	local cannonNum = 0
	local targeterName = "Auto"

	for i, cannon in pairs(IonCannonStorage.fromForce(force)) do
		if cannon[2] == 1 and cannon[3] == surface.name then
			cannonNum = i
			break
		end
	end

	if player then targeterName = player.name end
	if cannonNum == 0 then
		if player then
			player.print({"unable-to-fire"})
			playSoundForPlayer(mod.defines.sound.unable_to_comply, player)
		end
		return false
	else
		local current_tick = game.tick
		local TargetPosition = position
		TargetPosition.y = TargetPosition.y + 1
		local target = surface.create_entity({name = "ion-cannon-target", position = TargetPosition, force = game.forces.neutral}) or error("Invalid state")
		local marker = force.add_chart_tag(surface, {icon = {type = "item", name = "ion-cannon-targeter"}, text = "Ion cannon #" .. cannonNum .. " target location (" .. targeterName .. ")", position = TargetPosition})
		table.insert(storage.markers, {marker, current_tick + settings.global["ion-cannon-chart-tag-duration"].value})
		local CrosshairsPosition = position
		CrosshairsPosition.y = CrosshairsPosition.y - 20
		local projectile = force.technologies[mod.tech.cannon_mk2] and force.technologies[mod.tech.cannon_mk2].researched and "crosshairs-mk2" or "crosshairs"
		surface.create_entity({name = projectile, target = target, force = force, position = CrosshairsPosition, speed = 0})
		for i, player in pairs(game.connected_players) do
			if player.controller_type ~= defines.controllers.character and player.controller_type ~= defines.controllers.remote then goto next_player end
			local klaxon_distance = settings.get_player_settings(player)["ion-cannon-play-klaxon"].value
			if klaxon_distance == "none" then goto next_player end
			if klaxon_distance == "surface" and player.physical_surface.name ~= surface.name then goto next_player end
			if storage.klaxonTick >= current_tick then goto next_player end
			storage.klaxonTick = current_tick + 60
			local max_volume = settings.get_player_settings(player)["ion-cannon-klaxon-volume"].value / 100
			if klaxon_distance == "local" then
				--WORKOROUND for too quiet entity placement sound
				--create additional sound at players position
				local max_distance = 32 -- Maximum distance up to which the sound is audible
				local distance = math.sqrt((player.physical_position.x - CrosshairsPosition.x)^2 + (player.physical_position.y - CrosshairsPosition.y)^2)
				if distance <= max_distance then
					-- Calculate the volume based on the distance
					local volume = (1 - (distance / max_distance)) --[[ 1 in the near, 0 at the edge]]--* max_volume
					player.play_sound({path = "ion-cannon-klaxon", position = player.physical_position, volume_modifier = volume})
				end
			else
				player.play_sound({path = "ion-cannon-klaxon", position=player.physical_position, volume_modifier = max_volume})
			end

			::next_player::
		end
		--if not player or not player.cheat_mode then
			local cannons = IonCannonStorage.fromForce(force)
			cannons[cannonNum][1] = settings.global["ion-cannon-cooldown-seconds"].value
			cannons[cannonNum][2] = 0
		--end
		if player then
			player.print({"targeting-ion-cannon" , cannonNum})
			for i, p in pairs(player.force.connected_players) do
				if settings.get_player_settings(p)["ion-cannon-custom-alerts"].value then
					p.add_custom_alert(target, {type = "item", name = "orbital-ion-cannon"}, {"ion-cannon-target-location", cannonNum, TargetPosition.x, TargetPosition.y, targeterName}, true)
				end
			end
			script.raise_event(_G.when_ion_cannon_targeted, {surfce = surface, force = force, position = position, radius = this.getRadius(force), player_index = player.index,})		-- Passes event.surface, event.force, event.position, event.radius, and event.player_index
		else
			script.raise_event(_G.when_ion_cannon_targeted, {surface = surface, force = force, position = position, radius =this.getRadius(force)})		-- Passes event.surface, event.force, event.position, and event.radius
		end
		return cannonNum>0
	end
end

---Installs an ion cannon for a force on a surface, initialites the GUI, shows a message to the force, and plays a sound.
---@param force integer|string|LuaForce
---@param surface string|LuaSurface
function IonCannon.install(force, surface)
	local surfaceName = IonCannon.add(force, surface)

	Control.enableNthTick60()
	for _, player in pairs(force.connected_players) do
		init_GUI(player)
		playSoundForPlayer(mod.defines.sound.charging, player)
	end
	if IonCannonStorage.count(force) == 1 then
		force.print({"congratulations-first"})
		force.print({"first-help"})
		force.print({"second-help"})
		force.print({"third-help"})
	else
		force.print({"congratulations-additional"})
		force.print({"ion-cannons-in-orbit", surfaceName, IonCannon.countOrbitingIonCannons(force, surface)})
	end
end



---@param e {entity: LuaEntity?, platform: LuaSpacePlatform?}
function this.on_built(e)
	if not e.entity or not e.entity.valid then return end
	--print("on_space_platform_built_entity "..e.entity.name)

	if e.entity.name ~= "orbital-ion-cannon" and e.entity.name ~= "orbital-ion-cannon-mk2" then return end
	if not e.platform then e.platform = e.entity.surface.platform end
	if not e.platform then return end
	local force = e.platform.force
	local isMk2Editity = e.entity.name == "orbital-ion-cannon-mk2"
	local isMk2Tech = force.technologies[mod.tech.cannon_mk2_upgrade] and force.technologies[mod.tech.cannon_mk2_upgrade].researched
	local result = (isMk2Editity and isMk2Tech) or (not isMk2Editity and not isMk2Tech)
	local isPlanet = e.platform.space_location and e.platform.space_location.type == "planet"
	if isPlanet and result then
		IonCannon.install(e.platform.force, e.platform.space_location.name)
	else
		e.entity.surface.create_entity({ name = "big-explosion", position = e.entity.position})
		e.entity.destroy()
		if not result then force.print({"explosion-because-obsolete-technology"}) end
		if not isPlanet then force.print({"explosion-because-invalid-location"}) end
	end
end

---@param force LuaForceId?
function IonCannon.getRadius(force)
	local radius = settings.startup["ion-cannon-radius"].value
	if(not force) then return radius end
	local force = getForce(force)
	if force.technologies[mod.tech.cannon_mk2_upgrade] and force.technologies[mod.tech.cannon_mk2_upgrade].researched then
		--TODO: configuration
		--radius = settings.startup["ion-cannon-radius-mk2"].value
		radius = radius *1.5
	end
	return radius
end

---@param e EventData.on_research_finished
function this.on_research_finished(e)
	if e.research.name ~= mod.tech.cannon_mk2_upgrade then return end
	local force = e.research.force
	local perSurface = IonCannonStorage.countBySurface(force)
	storage.forces_ion_cannon_table[force.name] = {}
	for force_name, count in pairs(perSurface) do
		count =  math.floor(count/10 +0.5)
		for i = 1, count do IonCannon.install(force, game.surfaces[force_name]) end
	end
	force.print({"upgrade-to-ion-cannon-mk2"})
end

Events.on_built(this.on_built)
Events.on_event(defines.events.on_research_finished, this.on_research_finished)
---------------------------------------------------------------------------------------------------
return IonCannon
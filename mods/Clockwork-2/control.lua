require("util")

script.on_init(function(event)
	storage.permanight_surfaces = {}
	
	setsettings()
	setsettings_permanight()
end)

script.on_event(defines.events.on_player_created, function(event)
	-- Thanks to the freeplay scenario script setting daytime in on_player_created, we
	-- can't do this in on_init() anymore or it just gets overridden. 
	
	-- possibly checking game.tick isn't needed anymore?
	if event.player_index == 1 and game.tick == 0 then
		for index, _ in pairs(game.surfaces) do
			game.surfaces[index].daytime = settings.global["Clockwork-starttime"].value
			if settings.global["Clockwork-multisurface"].value then else break end
		end
	end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	if event.setting:find("Clockwork") then
		setsettings()
		if event.setting == "Clockwork-permanight"
			or event.setting == "Clockwork-permanight-grace"
		then
			setsettings_permanight()
		end
	end
end)

script.on_event(defines.events.on_tick, function(event)
	if storage.permanight then
		local tick = event.tick
		-- we're not actually turning off permanight
		-- but when we have no more work to do, this keeps on_tick minimal
		storage.permanight = false
		
		for index, _ in pairs(storage.permanight_surfaces) do
			if storage.grace then
				if tick == storage.permanight_surfaces[index] then
					game.surfaces[index].freeze_daytime = false
					game.surfaces[index].print({"description.grace-end-prelude"})
					game.surfaces[index].print({"description.grace-end"}, {r=1.0, g=0.0, b=0.0})
				end
			end
			if game.surfaces[index].daytime >= storage.midnight
				-- safety check in case someone sets the starting time to morning
				and game.surfaces[index].daytime <= storage.midnight + 0.05
			then
				game.surfaces[index].freeze_daytime = true
				--game.print("froze: " .. index)
				-- Finished; don't need to track this surface anymore.
				storage.permanight_surfaces[index] = nil
			end
			-- If there isn't at least one surface, this line will not run
			storage.permanight = true
		end
	end
end)

function setsettings_permanight()
	-- If these settings are changed in the middle of a session, it essentially counts as a reset.
	storage.grace = fif(settings.global["Clockwork-permanight-grace"].value > 0, true, false)
	--storage.grace_ticks = game.tick + settings.global["Clockwork-permanight-grace"].value * 60 * 60
	storage.permanight = settings.global["Clockwork-permanight"].value
	
	if storage.permanight then
		settings.global["Clockwork-multisurface-ignore-frozen"] = {value = false}
	end
	
	
	storage.permanight_surfaces = {}
	-- This does assume surface 1 (aka Nauvis) will always be valid.
	-- But the API doc does say the default surface always exists...
	storage.permanight_surfaces[1] = game.tick or 1
	if settings.global["Clockwork-multisurface"].value then
		for index, surface in pairs(game.surfaces) do
			if surface.index > 1 and surface.always_day and settings.global["Clockwork-multisurface-ignore-always-day"].value == false then
				storage.permanight_surfaces[surface.index] = game.tick or 1
			end
		end
	end
	
	-- log(serpent.block(storage.surfaces))
	-- log(serpent.block(storage.permanight_surfaces))
	
	if storage.permanight and storage.grace then
		-- freeze daytime to allow the grace period to pass
		-- In case this is added to an existing save, make sure it's day too.
		
		for index, _ in pairs(storage.permanight_surfaces) do
			grace_setup(index)
		end
	end
	if storage.permanight then else
		-- we want to make sure it's off for all of our tracked surfaces.
		-- We don't need to do a safety check here as setsettings() runs first
		for index, surface in pairs(game.surfaces) do
			if surface.index == 1 or settings.global["Clockwork-multisurface"].value then
				surface.freeze_daytime = false
			end
		end
	end
end

function surface_added(event)
	--game.print("surface added: " .. event.surface_index .. ": " .. game.surfaces[event.surface_index].name)
	local index = event.surface_index
	
	-- Check if permanight was on (the storage might be false if all other surfaces finished their sunsets)
	-- If it was, we'll restart the process so the new surface can sunset into permanent night
	if settings.global["Clockwork-permanight"].value and settings.global["Clockwork-multisurface"].value then
		storage.permanight = true
		storage.permanight_surfaces[index] = game.tick
		if storage.grace then
			grace_setup(index)
		end
	end
	
	-- new surface will be configured according to the mod's settings.
	-- We don't rerun setsettings_permanight as this would put surfaces back to daytime.
	setsettings()
end

function grace_setup(index)
	storage.permanight_surfaces[index] = game.tick + settings.global["Clockwork-permanight-grace"].value * 60 * 60
	game.surfaces[index].freeze_daytime = true
	game.surfaces[index].daytime = settings.global["Clockwork-starttime"].value
end

function surface_removed(event)
	--game.print("surface removed: " .. event.surface_index)
	storage.permanight_surfaces[event.surface_index] = nil
end

function setsettings()
	
	-- defaults: 25,000 ticks per day, dusk 0.25, evening 0.45, morning 0.55, dawn 0.75
	-- cycle_ticks is no longer default - we track each surface's original day length and multiply off that.
	-- May make it an option later.
	-- local cycle_ticks = math.floor(25000 * settings.global["Clockwork-cycle-length"].value)
	local cycle_multi = settings.global["Clockwork-cycle-length"].value
	local ignore_always_day = settings.global["Clockwork-multisurface-ignore-always-day"].value
	local ignore_frozen = settings.global["Clockwork-multisurface-ignore-frozen"].value
	local dusk = settings.global["Clockwork-dusk"].value or 0.25
	local evening = settings.global["Clockwork-evening"].value or 0.45
	local morning = settings.global["Clockwork-morning"].value or 0.55
	local dawn = settings.global["Clockwork-dawn"].value or 0.75
	local warning = false
	-- safety checks
	if dawn <= dusk then
		dawn = dusk + 0.005
		warning = true
	end
	if morning >= dawn then
		morning = dawn - 0.005
		warning = true
	end
	if evening >= morning then
		evening = morning - 0.005
		warning = true
	end
	if dusk >= evening then
		dusk = evening - 0.005
		warning = true
	end
	if warning then
		game.print("WARNING: Invalid day/night settings detected. Values have been internally corrected.")
	end
	
	storage.midnight = (evening + morning) / 2
	
	for index, surface in pairs(game.surfaces) do
		
		local original_ticks = 25000
		-- game.print(index)
		-- validation
		if not surface.valid
			-- Always applies to Nauvis. Unless Nauvis becomes invalid, somehow.
			or (surface.index > 1) and ((surface.always_day and ignore_always_day) or (surface.freeze_daytime and ignore_frozen))
		then 
		else
			surface.ticks_per_day = math.floor(original_ticks * cycle_multi)
			
			-- RIP min brightness.
			-- surface.min_brightness = settings.global["Clockwork-minbrightness"].value
			
			-- brightness: 0.15.
			local dark_percent = settings.global["Clockwork-darknight-percent"].value / 100.0
			surface.brightness_visual_weights = { 1 / 0.85 * dark_percent, 1 / 0.85 * dark_percent, 1 / 0.85 * dark_percent } 
			
			
			local retry
			local cnt = 0
			repeat 
				retry = false
				
				-- Checks that values are within range in the same order as:
				-- dusk 0.25, evening 0.45, morning 0.55, dawn 0.75
				-- second round of checks are necessary as the game will crash if, for example, dawn is less than
				-- surface.morning, even though the 'morning' we want to apply after is valid.
				
				if dawn <= surface.morning then
					retry = true
				else
					surface.dawn = dawn
				end
				
				if morning >= surface.dawn or morning <= surface.evening then
					retry = true
				else
					surface.morning = morning
				end
				
				if evening >= surface.morning or evening <= surface.dusk then
					retry = true
				else
					surface.evening = evening
				end
				
				if dusk >= surface.evening then
					retry = true
				else
					surface.dusk = dusk
				end
				
				cnt = cnt + 1
				if cnt > 4 then
					break
				end
			until retry == false
			--game.print("dusk: " .. surface.dusk .. " evening: " .. surface.evening .. " morning: " .. surface.morning ..
			--	" dawn: " .. surface.dawn)
		end
		
		if settings.global["Clockwork-multisurface"].value == false then
			break
		end
	end
	

end

function fif(condition, if_true, if_false)
  if condition then return if_true else return if_false end
end

script.on_event({defines.events.on_surface_created, defines.events.on_surface_imported}, surface_added)
script.on_event(defines.events.on_surface_deleted, surface_removed)
---------------------
---- control.lua ----
---------------------

local PUMPS = {}

-- Init handlers
function PUMPS.on_init()

	-- Set on_first_tick() trigger state
	global.first_tick_trigger = true
	
	-- Init before tick
	
	-- Init on first tick
	script.on_event(defines.events.on_tick, OSM.PUMPS.init.on_first_tick)
end

-- Init on first tick
function PUMPS.on_first_tick()
	if global.first_tick_trigger then

		OSM.PUMPS.init.regenerate_pumps()
		global.first_tick_trigger = nil

	else -- Unregister on_first_tick() trigger
		script.on_event(defines.events.on_tick, nil)
	end
end

-- Init on load
function PUMPS.on_load()
	if global.first_tick_trigger then
		script.on_event(defines.events.on_tick, OSM.PUMPS.init.on_first_tick)
	else
		script.on_event(defines.events.on_tick, nil)
	end
end

function PUMPS.regenerate_pumps()
	log("----------------------------------------------------------------------")
	log("--- Regenerating offshore and ground pumps...")
	log("----------------------------------------------------------------------")
	
	local pump_count = 0
	local collision_count = 0
	
	for _, surface in pairs (game.surfaces) do
		
		-- Destroy bugged pumps
		for _, bugged_pump in pairs (OSM.PUMPS.bugged_pumps) do
			for _, bug_pump in pairs(surface.find_entities_filtered{name=bugged_pump}) do
				bug_pump.destroy()
			end
		end
		
		-- Regenerate pumps
		for _, powered_pump in pairs (OSM.PUMPS.powered_pumps) do
			for _, pump in pairs(surface.find_entities_filtered{name=powered_pump.name}) do

				local name = pump.name
				local position = pump.position
				local direction = pump.direction
				local force = pump.force
	
				pump.destroy()

				surface.create_entity
				{
					name = OSM.PUMPS.collision_layer,
					position = position,
					direction = direction,
					force = "neutral",
					fast_replace = true,
					spill = false,
					raise_built = false,
					create_build_effect_smoke = false
				}

				surface.create_entity
				{
					name = name,
					position = position,
					direction = direction,
					force = force,
					fast_replace = true,
					spill = false,
					raise_built = true,
					create_build_effect_smoke = false
				}
				
				pump_count=pump_count+1
			end
		end

		-- Remove collision layer if pump is not there (redundant safety check)
		local powered_pumps = {}
	
		-- Get pump position
		for _, powered_pump in pairs (OSM.PUMPS.powered_pumps) do
			for _, pump in pairs(surface.find_entities_filtered{name=powered_pump.name}) do
				local i = string.gsub(tostring(pump.position.x)..tostring(pump.position.y), "%.", "-")
				powered_pumps[i] = pump.position
			end
		end
		
		-- Compare collision layer position to pump position
		for _, collision_layer in pairs(surface.find_entities_filtered{name=OSM.PUMPS.collision_layer}) do
			local i = string.gsub(tostring(collision_layer.position.x)..tostring(collision_layer.position.y), "%.", "-")
			if not powered_pumps[i] then
				collision_layer.destroy()
				collision_count = collision_count+1
			end
		end
	end
	log("Info: Regenerated "..pump_count.." offshore pumps")
	log("Info: Removed "..collision_count.." orphan collision layers")
end

return PUMPS
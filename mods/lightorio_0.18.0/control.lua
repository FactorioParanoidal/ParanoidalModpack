--when a building is placed, add a tiny lamplight if it's an assembler, and add the new lamp at the building's entity unit_number in the assembler lamp table.

function addEventHandler(event)
	if event.created_entity ~= nil then
		add_lamp(event.created_entity)
	elseif event.entity ~= nil then
		add_lamp(event.entity)
	end
end

function add_lamp(entity)
	local assemblerlamp -- as as entity
    -- If the entity that's been built is an assembly machine...
	
    if entity.type == "assembling-machine" then
		assemblerlamp = entity.surface.create_entity{name = "assembler-lamp", position = {x= entity.position.x, y = entity.position.y} , force = entity.force}
		-- at index of assembler in assembler table, set the lamp entity
		global.assemblerlamps[entity.unit_number] = assemblerlamp

    end
	-- add custom lamp for miners?
	if entity.type == "mining-drill"  and entity.name ~= "burner-mining-drill" then
		assemblerlamp = entity.surface.create_entity{name = "assembler-lamp", position = {x= entity.drop_position.x, y = entity.drop_position.y} , force = entity.force}

			-- at index of assembler in assembler table, set the lamp entity
		global.assemblerlamps[entity.unit_number] = assemblerlamp
	end
	
	-- below applies now for bob miners now - suspect this is to do wit hchange to mining speeds, drills done as a separate entity now
	-- space exploration core-miner mod bodge
	-- space exploration core-miner places the core-miner simple-entity-with-force then builds the core-miner-drill over the top by script
	-- so have to find the drill it just built to position the lamp properly
	-- ofcourse cant do it in the same tick (the creation script in space expo wont have run yet!) so need to do some arbitrary delay...
	-- this could be tidier
	if entity.type == "simple-entity-with-force" then
		table.insert(global.coredrills, entity)	
	end
end

local function clone_lamp(event)
	local originalentity = event.source
	local clonedentity = event.destination
	-- kill cloned assemblerlamps
	if originalentity.name == "assembler-lamp" then
		clonedentity.destroy()
	else
		-- otherwise add assemblerlamps as appropriate for cloned entity
		add_lamp(clonedentity)
	end
end

-- this is disgusting, but apparently necessary now
local function checkForCoreDrillsWithDelay ()
	local assemblerlamp
	local actualminers
	local index = 1
	for _, drill in pairs(global.coredrills) do 
	-- if the entity has vanished (for some reason) this will break, so check entity is still valid
		if drill.valid then
			actualminers = drill.surface.find_entities_filtered{position={drill.position.x, drill.position.y}, radius=1, type="mining-drill"}
			if actualminers[1] ~= nil then
				assemblerlamp = actualminers[1].surface.create_entity{name = "assembler-lamp", position = {x= actualminers[1].drop_position.x, y = actualminers[1].drop_position.y} , force = actualminers[1].force}
				global.assemblerlamps[actualminers[1].unit_number] = assemblerlamp
			end
			global.coredrills[index] = nil
			index = index + 1
		else
			index = index + 1
			global.coredrills[index] = nil
		end
		
	end
end


--when a building is rotated, move the lamp if it is not placed centrally (eg miner)
local function move_lamp(event)
	local entity = event.entity
	if entity.type == "mining-drill" and entity.name ~= "burner-mining-drill" then
		-- find the assemblerlamp for the entity
		local assemblerlamp = global.assemblerlamps[entity.unit_number]
		--move it to the new output location
		assemblerlamp.teleport(entity.drop_position)
	end
end


-- When a building is removed, find the building in the assemblerlamp table, remove the assemblerlamp table entry, and remove the lamp
function remove_lamp(event)
    local entity = event.entity
    local index = entity.unit_number -- as an integer (for index of table)

	local assemblerlamp = global.assemblerlamps[index] -- the entity at this index of global.assemblerlamps

    if assemblerlamp then -- safety check to avoid crash
	   assemblerlamp.destroy()
       global.assemblerlamps[index] = nil 
    end
end

-- If the mod has just been installed, or other config changed, destroy all the assemblerlamps that exist, clear the assembler lamp table, and rebuild it
local function create_assemblerlamptable()
    --Find all assembling machines on the map
	global.assemblerlamps = {}
	global.coredrills = {}
    for _, surface in pairs(game.surfaces) do
        
		-- first destroy any existing lamps to avoid duplicates
		for _, assemblerlamp in pairs(surface.find_entities_filtered{name="assembler-lamp"}) do
			assemblerlamp.destroy()
		end
		-- run the build function to place an assemblerlamp on each assembler
        for _, each in pairs(surface.find_entities_filtered{type="assembling-machine"}) do
            add_lamp(each)
        end
		
		-- run the build function to place an assemblerlamp on each miner
        for _, each in pairs(surface.find_entities_filtered{type="mining-drill"}) do
            add_lamp(each)
        end

    end
	
end


local function init()
    create_assemblerlamptable()
end


local function on_configuration_changed(event)
    if event.mod_changes then
        local changes = event.mod_changes["lightorio"]
        if changes then
			if changes.old_version ~= nil then 
				game.print("Lightorio: Updated from ".. tostring(changes.old_version) .. " to " .. tostring(changes.new_version))
				game.print("Lightorio: Clearing and rebuilding ambient lamps")
			else
				game.print("Lightorio version " .. tostring(changes.new_version) .. " installed.")
				game.print("Lightorio: Adding ambient lamps...")
			end
        end
        create_assemblerlamptable()
		global.coredrills = {}
    end
end

-- define events for creation or removal of assemblerlights
local e=defines.events
local remove_events = {e.on_player_mined_entity, e.on_robot_pre_mined, e.on_entity_died, e.script_raised_destroy}
local add_events = {e.on_built_entity, e.on_robot_built_entity, e.script_raised_built,e.script_raised_revive}
local clone_events = {e.on_entity_cloned}

--event for moving assemblerlight on miner rotation
local move_events = {e.on_player_rotated_entity}


-- Event handlers for creating the lamp table the first time and on config change
script.on_init(init)
script.on_configuration_changed(on_configuration_changed)
-- Event handler for building removal
script.on_event(remove_events, remove_lamp)
-- Event handler for building placement
script.on_event(add_events, addEventHandler)
-- Event handler for building cloned
script.on_event(clone_events, clone_lamp)
--event handler for light movement when miner rotated
script.on_event(move_events, move_lamp)
script.on_nth_tick(30, checkForCoreDrillsWithDelay)

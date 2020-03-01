--when a building is placed, add a tiny lamplight if it's an assembler, and add the new lamp at the building's entity unit_number in the assembler lamp table.
local function add_lamp(event)
    local entity = event.created_entity 
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
    for _, surface in pairs(game.surfaces) do
        
		-- first destroy any existing lamps to avoid duplicates
		for _, assemblerlamp in pairs(surface.find_entities_filtered{name="assembler-lamp"}) do
			assemblerlamp.destroy()
		end
		-- run the build function to place an assemblerlamp on each assembler
        for _, each in pairs(surface.find_entities_filtered{type="assembling-machine"}) do
            add_lamp({created_entity = each})
        end
		
		-- run the build function to place an assemblerlamp on each miner
        for _, each in pairs(surface.find_entities_filtered{type="mining-drill"}) do
            add_lamp({created_entity = each})
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
    end
end

-- define events for creation or removal of assemblerlights
local e=defines.events
local remove_events = {e.on_player_mined_entity, e.on_robot_pre_mined, e.on_entity_died}
local add_events = {e.on_built_entity, e.on_robot_built_entity}

--event for moving assemblerlight on miner rotation
local move_events = {e.on_player_rotated_entity}


-- Event handlers for creating the lamp table the first time and on config change
script.on_init(init)
script.on_configuration_changed(on_configuration_changed)
-- Event handler for building removal
script.on_event(remove_events, remove_lamp)
-- Event handler for building placement
script.on_event(add_events, add_lamp)
--event handler for light movement when miner rotated
script.on_event(move_events, move_lamp)


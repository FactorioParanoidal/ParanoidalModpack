--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: replaceLocomotive.lua
 * Description: Replaces one Locomotive Entity with a new one of a different entity-name.
 *    Preserves as many properties of the original as possible.
 * Parameters: loco (locomotive entity to be replaced), newName (name of locomotive entity to replace it)
 * Returns: newLoco entity if successful, nil if unsuccessful
 * Dependencies:  saveGrid.lua, saveBurner.lua, saveItemRequestProxy.lua
--]]


function replaceLocomotive(loco, newName)

	
	-- Save basic parameters
	local position = loco.position
	local force = loco.force
	local surface = loco.surface
	local orientation = loco.orientation
	local backer_name = loco.backer_name
	local color = loco.color
	local health = loco.health
	local to_be_deconstructed = loco.to_be_deconstructed(force)
	local player_driving = loco.get_driver()
	local last_user = loco.last_user
	
	-- Save equipment grid contents
	local grid_equipment = saveGrid(loco.grid)
	
	-- Save item requests left over from a blueprint
	local item_requests = saveItemRequestProxy(loco)
	
	-- Save the burner progress
	local saved_burner = saveBurner(loco.burner)
	
	-- Adjust the direction of the new locomotive
	-- This mapping was determined by brute force because direction and orientation for trains are stupid.
	local newDirection = 0
	if orientation > 0 and orientation <= 0.5 then
		newDirection = 2
	end
	
	-- Save the train schedule.  If we are replacing a lone MU with a regular loco, the train schedule will be lost when we delete it.
	local train_schedule = loco.train.schedule
	local manual_mode = loco.train.manual_mode
	
	-- Save its coupling state.  By default, created locos couple to everything nearby, which we have to undo
	--   if we're replacing after intentional uncoupling.
	local disconnected_back = loco.disconnect_rolling_stock(defines.rail_direction.back)
	local disconnected_front = loco.disconnect_rolling_stock(defines.rail_direction.front)
	
	-- Destroy the old Locomotive so we have space to make the new one
	loco.destroy{raise_destroy=true}
	------------------------------
	-- Create the new locomotive in the same spot and orientation
	local newLoco = surface.create_entity{
		name = newName, 
		position = position, 
		direction = newDirection, 
		force = force, 
		create_build_effect_smoke = false,
		raise_built = false,
		snap_to_train_stop = false}
	-- make sure it was actually created
	if not newLoco then
		return nil
	end
	
	-- Restore coupling state
	if not disconnected_back then
		newLoco.disconnect_rolling_stock(defines.rail_direction.back)
	end
	if not disconnected_front then
		newLoco.disconnect_rolling_stock(defines.rail_direction.front)
	end
	
	-- Restore parameters
	if backer_name then newLoco.backer_name = backer_name end
	if last_user then newLoco.last_user = last_user end
	if color then newLoco.color = color end
	newLoco.health = health
	if to_be_deconstructed == true then
		newLoco.order_deconstruction(force)
	end
	
	-- Restore item_request_proxy by creating a new one
	if item_requests then
		newProxy = surface.create_entity{name="item-request-proxy", position=position, force=force, target=newLoco, modules=item_requests}
	end
	
	-- Restore the partially-used burner fuel
	if saved_burner then
		restoreBurner(newLoco.burner, saved_burner)
	end
	
	-- Restore the equipment grid
	if grid_equipment and newLoco.grid and newLoco.grid.valid then
		restoreGrid(newLoco.grid, grid_equipment)
	end
	
	-- Restore the player driving
	if player_driving then
		newLoco.set_driver(player_driving)
	end
	
	-- After all that, fire an event so other scripts can reconnect to it
	script.raise_event(defines.events.script_raised_built, {entity = newLoco})
	
	-- Restore the train schedule and mode
	if train_schedule.records ~= nil then
		local num_stops = 0
		for k,v in pairs(train_schedule.records) do
			num_stops = num_stops + 1
		end
		-- If the schedule is not empty, assign it and restore manual/automatic mode
		if num_stops > 0 then
			newLoco.train.schedule = train_schedule
			newLoco.train.manual_mode = manual_mode
		end
		-- If the saved schedule has no stops, do not write to train.schedule.  In 0.17.59, this will cause a script error.
	end
	
	--game.print("Finished replacing. Used direction "..newDirection..", new orientation: " .. newLoco.orientation)
	return newLoco
end

return replaceLocomotive

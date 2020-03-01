--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: mapBlueprint.lua
 * Description: Handlers for on_player_pipette, on_player_setup_blueprint, on_player_configured_blueprint.
 *    When player creates or edits a blueprint containing, or uses pipette on a non-craftable entity, 
 *    these functions will replace it with the craftable entity if possible.
 *  event: Event parameter object.
 *  map:   Dictionary mapping non-craftable entity names to craftable entity names.
 --]]
  

function purgeBlueprint(bp,map)
	-- Get Entity table from blueprint
	local entities = bp.get_blueprint_entities()
	-- Find any downgradable items and downgrade them
	if entities and next(entities) then
		for _,e in pairs(entities) do
			if map[e.name] then
				e.name = map[e.name]
			end
		end
		-- Write tables back to the blueprint
		bp.set_blueprint_entities(entities)
	end
	-- Find icons too
	local icons = bp.blueprint_icons
	if icons and next(icons) then
		for _,i in pairs(icons) do
			if i.signal.type == "item" then
				if map[i.signal.name] then
					i.signal.name = map[i.signal.name]
				end
			end
		end
		-- Write tables back to the blueprint
		bp.blueprint_icons = icons
	end
end


function mapBlueprint(event,map)
	-- Get Blueprint from player (LuaItemStack object)
	-- If this is a Copy operation, BP is in cursor_stack
	-- If this is a Blueprint operation, BP is in blueprint_to_setup
	-- Need to use "valid_for_read" because "valid" returns true for empty LuaItemStack in cursor
	
	local item1 = game.get_player(event.player_index).blueprint_to_setup
	local item2 = game.get_player(event.player_index).cursor_stack
	if item1 and item1.valid_for_read==true then
		purgeBlueprint(item1,map)
	elseif item2 and item2.valid_for_read==true and item2.is_blueprint==true then
		purgeBlueprint(item2,map)
	end
	
end


function mapPipette(event,map)
	local item = event.item
	if item and item.valid then
		if map[item.name] then
			local player = game.players[event.player_index]
			local newName = map[item.name]
			local cursor = player.cursor_stack
			local inventory = player.get_main_inventory()
			-- Check if the player got MU versions from inventory, and convert them
			if cursor.valid_for_read == true and event.used_cheat_mode == false then
				-- Huh, he actually had MU items.
				cursor.set_stack({name=newName,count=cursor.count})
			else
				-- Check if the player could have gotten the right thing from inventory/cheat, otherwise clear the cursor
				local newItemStack = inventory.find_item_stack(newName)
				cursor.set_stack(newItemStack)
				if not cursor.valid_for_read then
					if player.cheat_mode==true then
						cursor.set_stack({name=newName, count=game.item_prototypes[newName].stack_size})
					end
				else
					inventory.remove(newItemStack)
				end
			end
		end
	end
end


return purgeBlueprint,mapBlueprint,mapPipette

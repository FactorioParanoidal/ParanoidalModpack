
local searchDirection = { {-1,0}, { -1, -1 }, {0,-1}, {1,-1}, {1,0}, {1, 1}, {0,1}, {-1,1} }
local function railFromThing(entity,neg)
	local x=entity.position.x+(neg*searchDirection[entity.direction+1][1])
	local y=entity.position.y+(neg*searchDirection[entity.direction+1][2])
	return entity.surface.find_entities( {{x-0.5,y-0.5},{x+0.5,y+0.5}});
end



script.on_event(defines.events.on_robot_built_entity, function(event)
	local checkThis = false;
	local negDir = 1;
	local item = event.created_entity.name;
	if( item == "train-stop-scrap" ) then 
		checkThis = true;
		negDir = 1;
	elseif( item == "rail-signal-scrap" or item=="rail-chain-signal-scrap" ) then 
		checkThis = true;
		negDir = -1;
	end
	if checkThis then
		local near_items = railFromThing( event.created_entity, negDir );
		local valid = false;
		for i=1, #near_items do
			log( 'near item:'..near_items[i].name);
			if near_items[i].name == "curved-scrap-rail" or near_items[i].name == "straight-scrap-rail" then
				valid = true;
				break;
			end
		end
		if not valid then			
			--game.players[event.player_index].print({"invalid-rail-type"})
			event.robot.insert( { name = item, count=1 } )
			event.created_entity.destroy();
		end
	end
end)


script.on_event(defines.events.on_built_entity, function(event)
	local item = event.created_entity.name;
	--log( "event.created_neity:"..tostring( event.created_entity.valid ).. " name:".. 
	--         tostring(item.name).. " other:"..event.created_entity.name
	--        .. " pos ".. event.created_entity.direction.. "   "..event.created_entity.position.x .. ",".. event.created_entity.position.y );
	local checkThis;
	local negDir;

	if( item.name == "blueprint" ) then
		if( item.name == "train-stop-scrap" ) then
			checkThis = true;
			negDir = 1;
		elseif( item.name=="rail-signal-scrap" 
		       or item.name=="rail-chain-signal-scrap" ) then 
			checkThis = true;
			negDir = -1;
		end
		if( checkThis ) then
			local near_items = railFromThing( event.created_entity, negDir );
			for i=1, #near_items do
				if near_items[i].name == "entity-ghost" then 
					if near_items[i].ghost_name == "curved-scrap-rail" or near_items[i].ghost_name == "straight-scrap-rail" then
						valid = true;
						break;
					end
				elseif near_items[i].name == "curved-scrap-rail" or near_items[i].name == "straight-scrap-rail" then
					valid = true;
					break;
				end
			end
			if not valid then
				event.created_entity.destroy();
			end

		end
	end
	if( item.name == "train-stop-scrap" ) then
		checkThis = true;
		negDir = 1;
	elseif( item.name=="rail-signal-scrap" 
	       or item.name=="rail-chain-signal-scrap" ) then 
		checkThis = true;
		negDir = -1;
	end;
	if( checkThis ) then
		local near_items = railFromThing( event.created_entity, negDir );
		local valid = false;
		for i=1, #near_items do
			if near_items[i].name == "curved-scrap-rail" or near_items[i].name == "straight-scrap-rail" then
				valid = true;
				break;
			end
		end
		if not valid then
			game.players[event.player_index].print({"invalid-rail-type-"..item.name})
			if event.created_entity.name ~= "ghost-entity"  then 
				game.players[event.player_index].insert( { name = item.name, count=1 } )
			end
			event.created_entity.destroy();
		end
	end
end)

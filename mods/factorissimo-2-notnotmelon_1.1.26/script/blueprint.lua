Blueprint = {}

local has_layout = Layout.has_layout

local function find_construction_bot_owner(robot)
	local network = robot.logistic_network
	if not network then return end
	local player = network.cells
	if #player == 1 then
		player = player[1].owner
		if player.type == 'character' then return player.player, network end
	end
	return nil
end

local function swap(tags, item_1, item_2)
	if item_2.valid_for_read and item_1.name == item_2.name and item_2.type == 'item-with-tags' and item_2.tags.id == tags.id then
		item_1.tags, item_2.tags = {id = item_2.tags.id}, {id = item_1.tags.id}
		return true
	end
end

-- whenever a factory building is placed and the item tags do not match the ghost tags,
-- search the player's inventory for the correct item and swap their tags
local function swap_factory_item_tags(robot, tags, item_1)
	if not tags or item_1.tags.id == tags.id then return end
	
	local player, network = find_construction_bot_owner(robot)
	if not player then return end
	
	local inventory = player.get_main_inventory()
	for i = 1, #inventory do
		local item_2 = inventory[i]
		if swap(tags, item_1, item_2) then return end
	end
	
	for _, robot_2 in pairs(network.construction_robots) do
		if robot ~= robot_2 then -- also search any construction robots that are in the air
			local inventory = robot_2.get_inventory(defines.inventory.robot_cargo)
			if #inventory ~= 0 and swap(tags, item_1, inventory[1]) then return end
		end
	end
	
	swap(tags, item_1, player.cursor_stack)
end
Blueprint.swap_factory_item_tags = swap_factory_item_tags

-- setup ghost tags for factory components
script.on_event(defines.events.on_player_setup_blueprint, function(event)
	local player = game.get_player(event.player_index)
	local blueprint = player.blueprint_to_setup
	if not blueprint.valid_for_read then blueprint = player.cursor_stack end
	if not blueprint or not blueprint.valid_for_read then return end
	
	local entities = blueprint.get_blueprint_entities()
	if not entities then return end
	local mapping = event.mapping.get()
	for i, entity in ipairs(entities) do
		local map = mapping[i]
		if not map or map.name ~= entity.name then return end -- Another mod has broken the mapping, abort
	end
	
	for i, entity in pairs(mapping) do
		local factory = global.factories_by_entity[entity.unit_number]
		if factory and has_layout(entity.name) then
			blueprint.set_blueprint_entity_tag(i, 'id', factory.id)
		elseif Connections.indicator_names[entity.name] then
			local factory = remote_api.find_surrounding_factory(entity.surface, entity.position)
			if factory then
				for cid, indicator in pairs(factory.connection_indicators) do
					if indicator.valid and indicator.unit_number == entity.unit_number then
						local ctype = Connections.indicator_names[entity.name]
						local settings = Connections.get_connection_settings(factory, cid, ctype)
						for k, v in pairs(settings) do
							blueprint.set_blueprint_entity_tag(i, k, v)
						end
					end
				end
			end
		end
	end
end)

local function get_cpos(factory, position)
	local x, y = position.x or position[1], position.y or position[2]
	for _, cpos in pairs(factory.layout.connections) do
		if cpos.inside_x + factory.inside_x + cpos.indicator_dx == x and cpos.inside_y + factory.inside_y + cpos.indicator_dy == y then
			return cpos
		end
	end
end

local function unpack_connection_settings_from_blueprint(entity)
	if not entity.tags or not next(entity.tags) then return end
	local surface = entity.surface
	local position = entity.position
	local factory = remote_api.find_surrounding_factory(surface, position)
	if not factory then return end
	
	local ctype = Connections.indicator_names[entity.ghost_name]
	local cpos = get_cpos(factory, position)
	if cpos then
		local cid = cpos.id
		local settings = Connections.get_connection_settings(factory, cid, ctype)
		for k, v in pairs(entity.tags) do
			settings[k] = v
		end
		local conn = factory.connections[cid]
		if conn then
			Connections.destroy_connection(conn)
			Connections.init_connection(factory, cid, cpos)
		end
		return
	end
end
Blueprint.unpack_connection_settings_from_blueprint = unpack_connection_settings_from_blueprint

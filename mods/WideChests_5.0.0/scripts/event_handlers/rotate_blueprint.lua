local function rotate_entity_clockwise(entity)
	entity.position = {
		x = -entity.position.y,
		y = entity.position.x
	}

	entity.direction = ((entity.direction or 0) + 2) % 8
end

local function rotate_entity_counterclockwise(entity)
	entity.position = {
		x = entity.position.y,
		y = -entity.position.x
	}

	entity.direction = ((entity.direction or 0) - 2 + 8) % 8
end

local function rotate_tile_clockwise(tile)
	tile.position = {
		x = -tile.position.y - 1,
		y = tile.position.x
	}
end

local function rotate_tile_counterclockwise(tile)
	tile.position = {
		x = tile.position.y,
		y = -tile.position.x - 1
	}
end

--- @param player_index integer
local function get_blueprint_in_cursor(player_index)
	player = game.players[player_index]
	local cursor = player.cursor_stack
	if player.is_cursor_blueprint() and cursor and cursor.valid_for_read then
		if cursor.is_blueprint_book and cursor.active_index then
			local blueprint_inventory = cursor.get_inventory(defines.inventory.item_main)
			if blueprint_inventory == nil or blueprint_inventory.get_item_count() == 0 then
				return nil
			end
			cursor = blueprint_inventory[cursor.active_index]
		end

		for _, entity in ipairs(cursor.get_blueprint_entities() or {}) do
			local split_chest_name, width, height = MergingChests.get_merged_chest_info(entity.name)
			if split_chest_name ~= nil and width ~= nil and height ~= nil and not MergingChests.is_size_allowed(height, width, split_chest_name) then
				return nil
			end
		end
		return cursor
	end
	return nil
end

--- @param player_index integer
--- @param rotate_entity function
--- @param rotate_tile function
local function rotate_blueprint(player_index, rotate_entity, rotate_tile)
	local blueprint = get_blueprint_in_cursor(player_index)
	if blueprint == nil then
		return
	end

	local entities = blueprint.get_blueprint_entities()
	if entities == nil then
		return
	end

	for _, entity in ipairs(entities) do
		local split_chest_name, width, height = MergingChests.get_merged_chest_info(entity.name)
		if split_chest_name ~= nil and width ~= nil and height ~= nil and width ~= height then
			entity.name = MergingChests.get_merged_chest_name(split_chest_name, height, width)
		end

		rotate_entity(entity)
	end
	blueprint.set_blueprint_entities(entities)

	local tiles = blueprint.get_blueprint_tiles()
	if tiles ~= nil then
		for _, tile in ipairs(tiles) do
			rotate_tile(tile)
		end
		blueprint.set_blueprint_tiles(tiles)
	end
end

local function on_rotate_blueprint_clockwise(event)
    rotate_blueprint(event.player_index, rotate_entity_clockwise, rotate_tile_clockwise)
end

local function on_rotate_blueprint_counterclockwise(event)
    rotate_blueprint(event.player_index, rotate_entity_counterclockwise, rotate_tile_counterclockwise)
end

script.on_event(MergingChests.custom_input_names.rotate_blueprint_clockwise, on_rotate_blueprint_clockwise)
script.on_event(MergingChests.custom_input_names.rotate_blueprint_counterclockwise, on_rotate_blueprint_counterclockwise)

--- @param vector Vector | MapPosition | nil
--- @return number | nil, number | nil
local function vector_xy(vector)
	if vector == nil then
		return nil, nil
	end
	return vector.x or vector[1], vector.y or vector[2]
end

--- @param vector Vector | MapPosition | nil
--- @return table | nil
local function rotate_vector_clockwise(vector)
	local x, y = vector_xy(vector)
	if x == nil or y == nil then
		return vector
	end
	return { x = -y, y = x }
end

--- @param vector Vector | MapPosition | nil
--- @return table | nil
local function rotate_vector_counterclockwise(vector)
	local x, y = vector_xy(vector)
	if x == nil or y == nil then
		return vector
	end
	return { x = y, y = -x }
end

-- Paranoidal: custom inserter vectors (bobinserters) and vehicle orientation are rotated together with the entity
local function rotate_entity_clockwise(entity)
	entity.position = rotate_vector_clockwise(entity.position)
	entity.pickup_position = rotate_vector_clockwise(entity.pickup_position)
	entity.drop_position = rotate_vector_clockwise(entity.drop_position)
	if entity.orientation then
		entity.orientation = (entity.orientation + 0.25) % 1
	end

	entity.direction = ((entity.direction or 0) + 4) % 16
end

local function rotate_entity_counterclockwise(entity)
	entity.position = rotate_vector_counterclockwise(entity.position)
	entity.pickup_position = rotate_vector_counterclockwise(entity.pickup_position)
	entity.drop_position = rotate_vector_counterclockwise(entity.drop_position)
	if entity.orientation then
		entity.orientation = (entity.orientation + 0.75) % 1
	end

	entity.direction = ((entity.direction or 0) - 4 + 16) % 16
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

--- Swaps the snapping grid size and rotates the absolute grid offset
--- @param blueprint LuaItemStack | LuaRecord
--- @param clockwise boolean
local function rotate_grid(blueprint, clockwise)
	local size = blueprint.blueprint_snap_to_grid
	if size == nil then
		return
	end
	local width, height = size.x, size.y
	local relative = blueprint.blueprint_absolute_snapping and blueprint.blueprint_position_relative_to_grid or nil

	if width ~= height then
		blueprint.blueprint_snap_to_grid = { x = height, y = width }
	end
	if relative then
		if clockwise then
			blueprint.blueprint_position_relative_to_grid = { x = (-relative.y) % height, y = relative.x % width }
		else
			blueprint.blueprint_position_relative_to_grid = { x = relative.y % height, y = (-relative.x) % width }
		end
	end
end

--- Returns the blueprint selected in the cursor: a blueprint item (also inside nested books)
--- or a writable blueprint record from the library.
--- @param player LuaPlayer
--- @return LuaItemStack | LuaRecord | nil
local function get_selected_blueprint(player)
	if not player.is_cursor_blueprint() then
		return nil
	end

	local cursor = player.cursor_stack
	if cursor and cursor.valid_for_read then
		-- Paranoidal: books may be nested in 2.0, descend to the active blueprint
		while cursor.is_blueprint_book do
			local active_index = cursor.active_index
			local book_inventory = cursor.get_inventory(defines.inventory.item_main)
			if active_index == nil or book_inventory == nil or active_index > #book_inventory then
				return nil
			end
			cursor = book_inventory[active_index]
			if not cursor.valid_for_read then
				return nil
			end
		end
		if cursor.is_blueprint and cursor.is_blueprint_setup() then
			return cursor
		end
		return nil
	end

	-- Paranoidal: blueprint from the library is held as a record, not as an item
	local record = player.cursor_record
	while record and record.valid and record.type == 'blueprint-book' do
		record = record.get_selected_record(player)
	end
	if record and record.valid and record.type == 'blueprint' and record.valid_for_write and record.is_blueprint_setup() then
		return record
	end
	return nil
end

--- @param player_index integer
--- @return LuaItemStack | LuaRecord | nil
local function get_blueprint_in_cursor(player_index)
	local player = game.get_player(player_index)
	if not player then
		return nil
	end

	local blueprint = get_selected_blueprint(player)
	if blueprint == nil then
		return nil
	end

	for _, entity in ipairs(blueprint.get_blueprint_entities() or {}) do
		local split_chest_name, width, height = MergingChests.get_merged_chest_info(entity.name)
		if split_chest_name ~= nil and width ~= nil and height ~= nil and width ~= height
			and prototypes.entity[MergingChests.get_merged_chest_name(split_chest_name, height, width)] == nil then
			return nil
		end
	end
	return blueprint
end

--- @param player_index integer
--- @param rotate_entity function
--- @param rotate_tile function
--- @param clockwise boolean
local function rotate_blueprint(player_index, rotate_entity, rotate_tile, clockwise)
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

	rotate_grid(blueprint, clockwise)
end

local function on_rotate_blueprint_clockwise(event)
    rotate_blueprint(event.player_index, rotate_entity_clockwise, rotate_tile_clockwise, true)
end

local function on_rotate_blueprint_counterclockwise(event)
    rotate_blueprint(event.player_index, rotate_entity_counterclockwise, rotate_tile_counterclockwise, false)
end

script.on_event(MergingChests.custom_input_names.rotate_blueprint_clockwise, on_rotate_blueprint_clockwise)
script.on_event(MergingChests.custom_input_names.rotate_blueprint_counterclockwise, on_rotate_blueprint_counterclockwise)

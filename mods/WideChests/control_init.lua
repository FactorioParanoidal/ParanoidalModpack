--- @alias chest_merged_event { player_index: number, surface: LuaSurface, split_chests: LuaEntity[], merged_chest: LuaEntity }

--- @param entity LuaEntity
--- @return integer
local function non_blank_inventory_slots_count(entity)
	local count = 0
	local inventory = entity.get_inventory(defines.inventory.chest)
	if inventory then
		for i = 1, #inventory do
			if inventory[i].valid_for_read then
				count = count + 1
			end
		end
	end

	return count
end

--- @param from_entities LuaEntity[]
--- @param to_entity_name string
--- @param to_entity_count integer
--- @return boolean
function MergingChests.can_move_inventories(from_entities, to_entity_name, to_entity_count)
	local from_item_count = 0
	for _, from_entity in ipairs(from_entities) do
		from_item_count = from_item_count + non_blank_inventory_slots_count(from_entity)
	end
	local quality = MergingChests.get_minimum_quality(from_entities)

	local to_inventory_size = prototypes.entity[to_entity_name].get_inventory_size(defines.inventory.chest, quality) or 0

	local is_merged_chest, _, _ = MergingChests.get_merged_chest_info(to_entity_name)

	-- Paranoidal: the merged prototype size already includes the size multiplier and limit.
	-- Applying them a second time overestimated the capacity, and the extra stacks were deleted.
	return from_item_count <= (is_merged_chest and to_inventory_size or to_inventory_size * to_entity_count)
end

--- @param from_entities LuaEntity[]
--- @param to_entities LuaEntity[]
function MergingChests.move_inventories(from_entities, to_entities)
	local to_entity_index = 1
	local to_inventory_index = 1

	--- Returns the current target inventory with a free slot index, skipping targets without inventory
	--- @return LuaInventory | nil
	local function current_target()
		while to_entity_index <= #to_entities do
			local to_entity = to_entities[to_entity_index]
			local to_inventory = to_entity and to_entity.valid and to_entity.get_inventory(defines.inventory.chest)
			if to_inventory and to_inventory_index <= #to_inventory then
				return to_inventory
			end
			to_entity_index = to_entity_index + 1
			to_inventory_index = 1
		end
		return nil
	end

	for _, from_entity in ipairs(from_entities) do
		local from_inventory = from_entity.get_inventory(defines.inventory.chest)
		if from_inventory then
			for i = 1, #from_inventory do
				local item = from_inventory[i]
				if item.valid_for_read then
					local to_inventory = current_target()
					if not to_inventory then
						return
					end
					to_inventory[to_inventory_index].set_stack(item)
					to_inventory_index = to_inventory_index + 1
				end
			end
		end
	end
end

---@param entity LuaEntity
---@param blueprint_entities BlueprintEntity[]
---@return integer | nil
local function get_blueprint_entities_bar(entity, blueprint_entities)
	for _, blueprint_entity in ipairs(blueprint_entities) do
		if entity.ghost_name == blueprint_entity.name and math.abs(entity.position.x - blueprint_entity.position.x) < 1e-6 and math.abs(entity.position.y - blueprint_entity.position.y) < 1e-6 then
			return blueprint_entity.bar
		end
	end
	return nil
end

--- Number of usable slots of a ghost chest, `nil` when the ghost has no bar
---@param entity LuaEntity
---@return integer | nil
local function get_ghost_bar(entity)
	local inventory = game.create_inventory(1)
	inventory.insert({name = "blueprint"})
	inventory[1].create_blueprint{
	  surface = entity.surface,
	  force = entity.force,
	  area = {
		{ entity.position.x - 0.01, entity.position.y - 0.01 },
		{ entity.position.x + 0.01, entity.position.y + 0.01 }
	  }
	}

	local blueprint_entities = inventory[1].get_blueprint_entities() or {}
	local bar = get_blueprint_entities_bar(entity, blueprint_entities)

	inventory.destroy()
	return bar
end

--- Number of usable slots of a chest, `nil` when the bar is not set
---@param entity LuaEntity
---@return integer | nil
local function get_entity_bar(entity)
	local inventory = entity.get_inventory(defines.inventory.chest)
	if inventory and inventory.supports_bar() then
		-- get_bar() is the index where the red area starts; #inventory + 1 means no bar
		local bar = inventory.get_bar()
		if bar <= #inventory then
			return bar - 1
		end
	end
	return nil
end

--- Total number of usable slots of `entities`, or `nil` when none of them has a bar.
--- Chests without a bar contribute their full size.
--- @param entities LuaEntity[]
--- @param is_ghost boolean
--- @return integer | nil
function MergingChests.get_total_bar(entities, is_ghost)
	local bar_count = 0
	local is_limited = false
	for _, entity in ipairs(entities) do
		local size = (is_ghost and entity.ghost_prototype or entity.prototype).get_inventory_size(defines.inventory.chest, entity.quality) or 0
		local bar
		if is_ghost then
			bar = get_ghost_bar(entity)
		else
			bar = get_entity_bar(entity)
		end
		if bar and bar < size then
			is_limited = true
			bar_count = bar_count + bar
		else
			bar_count = bar_count + size
		end
	end

	return is_limited and bar_count or nil
end

--- Applies the number of usable slots to a newly created chest or chest ghost.
--- Real chests use LuaInventory.set_bar, which has the same indexing as get_bar.
--- Ghosts can only get the bar through create_entity, so it is passed in `entity_data` instead.
--- @param entity LuaEntity
--- @param usable_slots integer | nil
function MergingChests.apply_bar(entity, usable_slots)
	if usable_slots == nil or not entity.valid or entity.name == 'entity-ghost' then
		return
	end
	local inventory = entity.get_inventory(defines.inventory.chest)
	if inventory and inventory.supports_bar() and usable_slots < #inventory then
		inventory.set_bar(usable_slots + 1)
	end
end

--- Returns `bar` field for create_entity of a ghost: usable slots if they are lower than the chest size
--- @param entity_name string
--- @param quality LuaQualityPrototype
--- @param usable_slots integer | nil
--- @return integer | nil
function MergingChests.get_ghost_bar_value(entity_name, quality, usable_slots)
	if usable_slots == nil then
		return nil
	end
	local size = prototypes.entity[entity_name].get_inventory_size(defines.inventory.chest, quality) or 0
	if usable_slots < size then
		return usable_slots
	end
	return nil
end

--- @param entities LuaEntity[]
--- @return LuaQualityPrototype
function MergingChests.get_minimum_quality(entities)
	local min_quality = nil
	for _, entity in ipairs(entities) do
		if min_quality == nil or min_quality.level > entity.quality.level then
			min_quality = entity.quality
		end
	end

	return min_quality or prototypes.quality['normal']
end

--- @param from_entities LuaEntity[]
--- @param to_entities LuaEntity[]
function MergingChests.reconnect_circuits(from_entities, to_entities)
	local from_entities_set = { }
	for _, from_entity in ipairs(from_entities) do
		from_entities_set[from_entity] = from_entity
	end

	local outside_connectors = { }
	for _, from_entity in ipairs(from_entities) do
		-- Paranoidal: get_wire_connectors returns a dictionary keyed by wire_connector_id;
		-- ipairs stopped before the green connector when the red one did not exist.
		for _, connector in pairs(from_entity.get_wire_connectors(false)) do
			for _, connection in ipairs(connector.connections) do
				if not from_entities_set[connection.target.owner] then
					outside_connectors[connector.wire_connector_id] = outside_connectors[connector.wire_connector_id] or {}
					outside_connectors[connector.wire_connector_id][connection.target.owner.unit_number..'/'..connection.target.wire_connector_id] = connection
				end
			end
		end
	end

	if next(outside_connectors) ~= nil then
		local red = outside_connectors[defines.wire_connector_id.circuit_red] ~= nil
		local green = outside_connectors[defines.wire_connector_id.circuit_green] ~= nil

		local grid = MergingChests.entities_to_grid(to_entities)

		--- @param x integer
		--- @param y integer
		--- @param wire_connector_id defines.wire_connector_id
		local function connect_neighbours(x, y, wire_connector_id)
			local entity = grid[x] and grid[x][y]
			if not entity then
				return
			end
			local right = grid[x + 1] and grid[x + 1][y]
			local below = grid[x][y + 1]
			if right then
				entity.get_wire_connector(wire_connector_id, true)
					.connect_to(right.get_wire_connector(wire_connector_id, true))
			end
			if below then
				entity.get_wire_connector(wire_connector_id, true)
					.connect_to(below.get_wire_connector(wire_connector_id, true))
			end
		end

		for x = grid.min_x, grid.max_x do
			for y = grid.min_y, grid.max_y do
				if red then
					connect_neighbours(x, y, defines.wire_connector_id.circuit_red)
				end
				if green then
					connect_neighbours(x, y, defines.wire_connector_id.circuit_green)
				end
			end
		end

		for wire_connector_id, connections in pairs(outside_connectors) do
			for _, connection in pairs(connections) do
				local connector = connection.target
				local closest_entity = nil
				local min = nil

				for _, to_entity in ipairs(to_entities) do
					local diffX = to_entity.position.x - connector.owner.position.x
					local diffY = to_entity.position.y - connector.owner.position.y

					if not min or (diffX * diffX + diffY * diffY < min) then
						min = diffX * diffX + diffY * diffY
						closest_entity = to_entity
					end
				end

				if closest_entity then
					closest_entity.get_wire_connector(wire_connector_id, true).connect_to(connector, true, connection.origin)
				end
			end
		end
	end
end

MergingChests.on_chest_merged_event_name = script.generate_event_name()
MergingChests.on_chest_split_event_name = script.generate_event_name()

local function get_chest_merged_event_name()
	return MergingChests.on_chest_merged_event_name
end

local function get_chest_split_event_name()
	return MergingChests.on_chest_split_event_name
end

remote.add_interface('MergingChests', {
	get_chest_merged_event_name = get_chest_merged_event_name,
	get_chest_split_event_name = get_chest_split_event_name
})

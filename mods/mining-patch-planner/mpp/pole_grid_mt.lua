local table_insert = table.insert
local min, max = math.min, math.max
local floor, ceil = math.floor, math.ceil

-- broke: implement power pole connection calculation yourself
-- woke: place ghosts to make factorio calculate the connections

---@class PowerPoleGrid
---@field [number] table<number, GridPole>
local pole_grid_mt = {}
pole_grid_mt.__index = pole_grid_mt

---@class GridPole
---@field ix number Position in the pole grid
---@field iy number Position in the pole grid
---@field grid_x number Position in the full grid
---@field grid_y number Position in the full grid
---@field built boolean? Does the pole need to be built
---@field entity LuaEntity? Pole ghost LuaEntity
---@field has_consumers boolean Does pole cover any powered items
---@field backtracked boolean
---@field connections table<GridPole, true>
---@field set_id number?
---@field no_light boolean?

function pole_grid_mt.new()
	local new = {
		_max_x = 1,
		_max_y = 1,
	}
	return setmetatable(new, pole_grid_mt)
end

---@param x number
---@param y number
---@param p GridPole
function pole_grid_mt:set_pole(x, y, p)
	if p.connections == nil then p.connections = {} end
	if not self[y] then self[y] = {} end
	self._max_x = max(self._max_x, x)
	self._max_y = max(self._max_y, y)
	self[y][x] = p
end

---@param p GridPole
function pole_grid_mt:add_pole(p)
	self:set_pole(p.ix, p.iy, p)
end

---@param x number
---@param y number
---@return GridPole | nil
function pole_grid_mt:get_pole(x, y)
	if self[y] then return self[y][x] end
end

---@param p1 GridPole
---@param p2 GridPole
---@param struct PoleStruct
---@return boolean
function pole_grid_mt:pole_reaches(p1, p2, struct)
	local x, y = p1.grid_x - p2.grid_x, p1.grid_y - p2.grid_y
	return (x * x + y * y) ^ 0.5 <= (struct.wire)
end

---@param p1 GridPole
---@param p2 GridPole
---@return integer
---@return integer
function pole_grid_mt:get_pole_midpoint(p1, p2)
	local x1, y1 = p1.grid_x, p1.grid_y
	local x2, y2 = p2.grid_x, p2.grid_y
	return floor(x1+(x2-x1)/2), floor(y1+(y2-y1)/2)
end

---@param P PoleStruct
---@return table<number, table<GridPole, true>>
function pole_grid_mt:find_connectivity(P)
	-- this went off the rails

	local all_poles = {}
	---@type table<GridPole, true>
	local not_visited = {}

	-- Make connections
	for y1 = 1, #self do
		local row = self[y1]
		for x1 = 1, #row do
			local pole = row[x1]
			if pole == nil then goto continue end

			table.insert(all_poles, pole)

			local right = self:get_pole(x1+1, y1)
			local bottom = self:get_pole(x1, y1+1)

			if right and self:pole_reaches(pole, right, P) then
				pole.connections[right], right.connections[pole] = true, true
			end

			if bottom and self:pole_reaches(pole, bottom, P) then
				pole.connections[bottom], bottom.connections[pole] = true, true
			end

			::continue::
		end
	end

	-- Process network connection sets
	local unconnected = {}
	---@type number, table<GridPole, true>
	local set_id, current_set = 1, {}
	---@type PoleConnectivity
	local sets = {[0]=unconnected, [1]=current_set}
	for _, v in pairs(all_poles) do not_visited[v] = true end

	---@param pole GridPole
	---@return number?
	local function is_continuation(pole)
		for other, _ in pairs(pole.connections) do
			if other.set_id then
				return other.set_id
			end
		end
	end

	---@param start_pole GridPole
	local function iterate_connections(start_pole)

		local continuation = is_continuation(start_pole)
		if not continuation and table_size(current_set) > 0 then
			if sets[set_id] == nil then
				sets[set_id] = current_set
			end
			current_set, set_id = {}, set_id + 1
		end

		---@param pole GridPole
		---@param depth_remaining number
		local function recurse_pole(pole, depth_remaining)
			not_visited[start_pole] = nil
			
			if not pole.has_consumers then
				unconnected[pole] = true
				return
			end

			if pole.set_id and pole.set_id < set_id then
				--Encountered a different set, merge to it
				local target_set_id = pole.set_id
				local target_set = sets[target_set_id]
				for current_pole, v in pairs(current_set) do
					current_set[current_pole], target_set[current_pole] = nil, true
					current_pole.set_id = target_set_id
				end
				set_id = pole.set_id
				current_set = target_set
			else
				pole.set_id = set_id
			end
			current_set[pole] = true

			for other, _ in pairs(pole.connections) do
				local other_not_visited = not_visited[other]

				if other_not_visited and depth_remaining > 0 then
					recurse_pole(other, depth_remaining-1)
				end
			end
		end

		recurse_pole(start_pole, 5)
	end

	local remaining = next(not_visited)
	while remaining do
		iterate_connections(remaining)
		remaining = next(not_visited)
	end
	sets[set_id] = current_set

	return sets
end

---List of sets
---set at index 0 are unconnected power poles
---@alias PoleConnectivity table<number, table<GridPole, true>>

---@param connectivity PoleConnectivity
---@return GridPole[]
function pole_grid_mt:ensure_connectivity(connectivity)
	---@type GridPole[]
	local connected = {}
	local unconnecteds_set, main_set = connectivity[0], connectivity[1]

	-- connect trivial power poles
	for connector_pole in pairs(unconnecteds_set) do
		--Set id is key and value is merge marker
		local different_sets = {} --[[@as table<number, boolean>]]
		for connection in pairs(connector_pole.connections) do
			if connection.set_id ~= nil then
				different_sets[connection.set_id] = true
			end
		end
		if table_size(different_sets) < 2 then goto skip_pole end

		local target_set_id = different_sets[1] and 1 or next(different_sets)
		local target_set = connectivity[target_set_id]

		for source_set_id in pairs(different_sets) do
			if source_set_id == target_set_id then goto skip_merge_set end
			local source_set = connectivity[source_set_id]

			if different_sets[source_set_id] == true then
				for source_pole in pairs(source_set) do
					target_set[source_pole], source_set[source_pole] = true, nil
					source_pole.set_id = target_set_id
					different_sets[source_set_id] = false
				end
			end
			::skip_merge_set::
		end

		connector_pole.built = true
		connector_pole.set_id = target_set_id
		target_set[connector_pole] = true
		unconnecteds_set[connector_pole] = nil
		
		::skip_pole::
	end

	---- append the main set to output list
	--for pole in pairs(main_set) do table_insert(connected, pole) end

	for set_id, pole_set in pairs(connectivity) do
		if set_id == 0 then goto continue_set end
		--if set_id == 1 then	goto continue_set end

		for pole in pairs(pole_set) do table_insert(connected, pole) end

		::continue_set::
	end

	return connected
end

function pole_grid_mt:get_y_gap()
	if self._max_y < 2 or self._max_x < 1 then return 1/0 end
	local p1, p2 = self[1][1], self[2][1]
	return p2.grid_y - p1.grid_y
end

return pole_grid_mt

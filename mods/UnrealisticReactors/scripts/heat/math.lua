local rpath = (...):match("(.-)[^%.]+$")
local rroot = rpath:match("^([^%.]+%.)")
local heat_buffer_transition_position = require(rpath .. "buffer").heat_buffer_transition_position
local heat_buffer_transitions = require(rpath .. "buffer").heat_buffer_transitions
local isempty = require(rroot .. "util").isempty
local noop = require(rroot .. "util").noop
local util = require(rpath .. "util")
local imerge = util.imerge
local set3d  = util.set3d
local get3d  = util.get3d
local get2d  = util.get2d
local  rm2d  = util. rm2d

local inf = 1/0

local function distance(x1,y1,x2,y2)
	-- pythagoras
	-- return math.sqrt(math.pow(x2 - x1,2) + math.pow(y2 - y1, 2))

	-- and

	-- chebyshev
-- 	return math.max(math.abs(x2 - x1), math.abs(y2 - y1)) -- I AM THE KING!

	-- in a

	-- taxicab
	return math.abs(x2 - x1) + math.abs(y2 - y1)
end

local function heuristic(a,b)
	return distance(a.x, a.y, b.x, b.y)
end

local function lowest_score(set, score)
	local lowest, best = inf
	for node,_ in pairs(set) do
		local value = score[node]
		if value < lowest then
			lowest, best = value, node
		end
	end
	return best
end

local function calculate_score(score, node, goal)
	local a = node.position or node.chunk.position
	local b = goal.position or goal.chunk.position
	return score[node] + heuristic(a,b)
end

local function astar(callback, start, goal, neighbours, ...) -- A*
	if start == goal then return start end -- connected
	local current
	local count     = 1
	local closedSet = {}
	local openSet   = {[start] = true}
	local gScore    = {[start] = 0}
	local fScore    = {[start] = calculate_score(gScore,start,goal)}
	local function score(node)
		if not closedSet[node] then
			local tentative_gScore = calculate_score(gScore, current, node)
			if not openSet[node] or tentative_gScore < gScore[node] then
				callback(current, node)
				gScore[node] = tentative_gScore
				fScore[node] = calculate_score(gScore, node, goal)
				if not openSet[node] then
					openSet[node] = true
					count = count + 1
				end
			end
		end
	end
	while count > 0 do
		current = lowest_score(openSet, fScore)
		if current == goal then return goal end -- connected
		count = count - 1
		openSet[current] = nil
		closedSet[current] = true
		neighbours(current, score, ...)
	end
	return nil -- not connected
end

local function testpath(...) -- A* → bool
	return astar(noop, ...)
end

local function getpath(...) -- A* → {node,...}
	local cameFrom = {}
	local goal = astar(function (current,node) cameFrom[node] = current end, ...)
	if not goal then return nil end
	local path = {goal}
	while cameFrom[goal] do
		goal = cameFrom[goal]
		table.insert(path, 1, goal) -- prepend
	end
	return path
end

local function is_connected_outside(path)
	if not path then return false end
	local before = path[1]
	for i = 2,#path do
		local current = path[i]
		if heuristic(before.position, current.position) > 1 then -- distance
			return true -- must have moved trough linked entities
		end
	end
	return false
end



local function cleanup_heat_network(id)
-- 	log("cleanup heat network " .. tostring(id))
	HEAT.network[id] = nil
	HEAT.ids[id] = nil
end

local function clear_heat_network_for_surface(z)
	HEAT.cells  [z] = nil
	HEAT.outlets[z] = nil
	for id,network in pairs(HEAT.network) do
		local chunks =            select(2,next(network.chunks))
		local chunk  = chunks and select(2,next(chunks))
		if chunk and chunk.position.z == z then
			cleanup_heat_network(id)
		end
	end
end

-- x,y,z = position.x, position.y, surface.index
-- using z,x,y order for easier removal
local function rm_heat_network_cell(x,y,z) return rm2d(HEAT.cells[z] or {}, x,y) end

local function get_heat_network_cell(x,y,z,d) return get3d(HEAT.cells, z,x,y, d) end
local function set_heat_network_cell(x,y,z,v) return set3d(HEAT.cells, z,x,y, v) end

local function get_heat_outlet(x,y,z,d) return get3d(HEAT.outlets, z,x,y, d) end
local function set_heat_outlet(x,y,z,v) return set3d(HEAT.outlets, z,x,y, v) end


-- cps instead of coroutine
local function direct_neighbour_nodes(entities, entity, callback, ...)
	local z = entity.surface.index
	local is_reactor = entity.type == 'reactor'
	for i,p,o in heat_buffer_transitions(entity) do
-- 		local neighbour = get2d(is_reactor and (get_heat_network_cell(o.x,o.y,z) or {}).entities or entities, o.x,o.y)
		local neighbour = get2d(entities, o.x,o.y)
		if neighbour and neighbour.valid then
			callback(neighbour, o, ...)
		end
		if is_reactor or i == 1 then
			if is_reactor then callback(entity, p, ...) end -- THIS LINE IS MAGIC
			local reactors = get_heat_outlet(p.x,p.y,z, {})
			for _,reactor in pairs(reactors) do
				local r = reactor.position
				local neighbour = get2d(reactor.cell.entities, r.x,r.y)
				if neighbour and neighbour.valid then
					if get2d(entities, r.x,r.y) then -- same cell
						callback(neighbour, r, ...)
					else
						local position = heat_buffer_transition_position(reactor, r,p)
						if position then callback(neighbour, position, ...) end
					end
				end
			end
		end
	end
end
local function cell_nodes(entities)
	return function (...) return direct_neighbour_nodes(entities, ...) end
end

local function linked_neighbour_nodes(entities, linked, entity, callback, ...)
	direct_neighbour_nodes(entities, entity, callback, ...)
	if not linked[entity] then return end
	for position,neighbour in pairs(linked[entity]) do
		if neighbour ~= entity then
			callback(neighbour, position, ...)
		end
	end
end
local function chunk_nodes(entities, linked)
	return function (...) return linked_neighbour_nodes(entities, linked, ...) end
end


local function neighbour_chunks(chunk, callback, chunks)
	local x,y = chunk.position.x, chunk.position.y
	for _,o in pairs(O) do
		local neighbour = get2d(chunks, o.x+x, o.y+y)
		if neighbour then callback(neighbour) end
	end
end

local function neighbour_cells(chunk, filter, callback, ...)
	local network,area = chunk.network,chunk.area
	local x,y,z = chunk.position.x, chunk.position.y
	for d,o in pairs(O) do
		local corner,k = next(M[d])
		local a = area[corner][k]
		local other = get2d(network.chunks, o.x+x, o.y+y)
		if other then
			for c,cell in pairs(chunk.border[d]) do
				if cell == filter then
					local neighbour = other.border[R[d]][c] -- of same network
					if neighbour then
						local p = {[k]=a, [V[k]]=c}
						callback(neighbour,p,o,...)
					end
				end
			end
		end
	end
end

local function connected_cells(cell, callback, ignore)
	if ignore == cell then return end
	neighbour_cells(cell.chunk, cell, callback)
end

local function chunked(v) return math.floor(v/32) end
local function get_chunk_neighbour(cell, x,y, callback, ...)
	local p = {x=x,y=y} -- entity.position
	local cx,cy = chunked(x), chunked(y) -- chunk position
	for _,corner in ipairs{'left_top','right_bottom'} do
		for k,v in pairs(p) do
			if cell.chunk.area[corner][k] == v then
				local d = A[corner][k]
				local o = O[d]
				local neighbour = get2d(cell.chunk.network.chunks, cx+o.x, cy+o.y)
				local other = neighbour and neighbour.border[R[d]][p[V[k]]] -- of same network
				if other then callback(other,p,o,...) end
			end
		end
	end
end


local function Linked(others)
	-- gather result
-- 	log"linked entities:"
	local linked = {}
	for _,cells in pairs(others) do
		if #cells > 1 then
			local entities = {}
-- 			log"linked:"
			for _,other in ipairs(cells) do
				local entity = other.entity
				entities[other.position] = entity
				linked[entity] = entities
-- 				log(string.format("entity=%s  x=%s y=%s  %s", entity.unit_number, entity.position.x, entity.position.y, dbgVector(other.position)))
			end
		end
	end
	return linked
end

local function inside_linked_entities(cell)
	local entities = cell.entities
	local others,neighbours = {},cell_nodes(entities)
	-- test if entities are connected inside chunk
	neighbour_cells(cell.chunk, cell, function (cell,position)
-- 		log(dbgVector(position))
-- 		log(dbgHeatNetworkCell(cell))
		local entity = get2d(entities, position.x, position.y)
		local found = nil
		for _,cells in ipairs(others) do
			if testpath(entity, cells[1].entity, neighbours) then -- inner
-- 				log"connected inside"
				found = cells
				break
			end
		end
		if not found then
			found = {}
			table.insert(others, found)
		end
		table.insert(found, {cell=cell, entity=entity, position=position})
	end)
-- 	log("Inside ".. dbgLinked(others))
	return others
end

local function outside_linked_entities(cell, others)
	-- test if entities are connected outside chunk
	local n = #others
	if n > 1 then
		for i = 1,n do
			local current = others[i]
			if current then
				local start = current[1].cell
				for j,cells in pairs(others) do
					if current ~= cells then
						for _,goal in pairs(cells) do goal = goal.cell
							if testpath(start, goal, connected_cells, cell) then -- outer
-- 								log"connected outside"
								current = imerge(current, cells)
								others[current == cells and i or j] = nil
								break
							end
						end
					end
				end
			end
		end
	end
-- 	log("Outside ".. dbgLinked(others))
	return others
end

local function get_linked_entities(cell)
	local others = inside_linked_entities(cell)
	local inside = Linked(others)
	      others = outside_linked_entities(cell, others)
	local outside = Linked(others)
	return outside, inside
end

local function get_entity_neighbour_cells(entity,callback,...)
	local z = entity.surface.index
	local is_reactor = entity.type == 'reactor'
	for i,p,o in heat_buffer_transitions(entity) do
		local cell = get_heat_network_cell(o.x,o.y,z)
		if cell then callback(cell,o,...) end
		if is_reactor or i == 1 then
			for _,reactor in pairs(get_heat_outlet(p.x,p.y,z,{})) do
				local position = heat_buffer_transition_position(reactor, reactor.position,p)
				local cell = get_heat_network_cell(position.x,position.y,z)
				if cell then callback(cell, position, ...) end
			end
			if is_reactor then
				local cell = get_heat_network_cell(p.x,p.y,z)
				if cell then callback(cell, p, ...) end
			end
		end
	end
end


return { -- exports
	testpath = testpath,
	 getpath =  getpath,
	is_connected_outside = is_connected_outside,
	chunk_nodes = chunk_nodes,
	 cell_nodes =  cell_nodes,
	neighbour_chunks = neighbour_chunks,
	neighbour_cells  = neighbour_cells,
	connected_cells  = connected_cells,
	get_chunk_neighbour = get_chunk_neighbour,
	get_linked_entities = get_linked_entities,
	get_entity_neighbour_cells = get_entity_neighbour_cells,
	clear_heat_network_for_surface = clear_heat_network_for_surface,
	cleanup_heat_network = cleanup_heat_network,
	rm_heat_network_cell = rm_heat_network_cell,
	get_heat_network_cell = get_heat_network_cell,
	set_heat_network_cell = set_heat_network_cell,
	get_heat_outlet = get_heat_outlet,
	set_heat_outlet = set_heat_outlet,
	distance = heuristic,
}


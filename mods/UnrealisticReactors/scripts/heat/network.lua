local rpath = (...):match("(.-)[^%.]+$")
local rroot = rpath:match("^([^%.]+%.)")
local get_reactor_core_power = require(rroot .. "entity.util").get_reactor_core_power
local mod = require(rpath .. "init")
local heat_buffer_transition_position = require(rpath .. "buffer").heat_buffer_transition_position
local heat_buffer_transitions = require(rpath .. "buffer").heat_buffer_transitions
local netmath = require(rpath .. "math")
local getpath = netmath.getpath
local testpath = netmath.testpath
local is_connected_outside = netmath.is_connected_outside
local chunk_nodes = netmath.chunk_nodes
local  cell_nodes = netmath. cell_nodes
local connected_cells = netmath.connected_cells
local neighbour_cells = netmath.neighbour_cells
local get_chunk_neighbour = netmath.get_chunk_neighbour
local get_linked_entities = netmath.get_linked_entities
local get_entity_neighbour_cells = netmath.get_entity_neighbour_cells
local clear_heat_network_for_surface = netmath.clear_heat_network_for_surface
local cleanup_heat_network = netmath.cleanup_heat_network
local rm_heat_network_cell = netmath.rm_heat_network_cell
local get_heat_network_cell = netmath.get_heat_network_cell
local set_heat_network_cell = netmath.set_heat_network_cell
local get_heat_outlet = netmath.get_heat_outlet
local set_heat_outlet = netmath.set_heat_outlet
local isempty = require(rroot .. "util").isempty
local debug = require(rpath .. "debug")
local util = require(rpath .. "util")
local get2d = util.get2d
local set2d = util.set2d
local  rm2d = util. rm2d
local sameposition = util.sameposition
-- local   growarea = util.  growarea
-- local    subarea = util.   subarea
-- local shrinkarea = util.shrinkarea


local function Coordinates(entity)
	local x,y,z = entity.position.x,entity.position.y,entity.surface.index
	return math.floor(x), math.floor(y), z
end

local CHUNK_SIZE = 32 -- in tiles
local function ChunkCoordinates(x,y,z)
	return math.floor(x / CHUNK_SIZE), math.floor(y / CHUNK_SIZE), z
end

local function Vector(x,y,z) return {
	x = x,
	y = y,
	z = z,
} end

-- FIXME area not used! could be removed or used to pimp split?
-- function Area(...) return {
-- 	 left_top    = Vector(...),
-- 	right_bottom = Vector(...),
-- } end

local function ChunkArea(x,y) return {
	 left_top    = Vector(CHUNK_SIZE * (0 + x) - 0, CHUNK_SIZE * (0 + y) - 0),
	right_bottom = Vector(CHUNK_SIZE * (1 + x) - 1, CHUNK_SIZE * (1 + y) - 1),
} end

local function ReactorPosition(entity) return {
	id = entity.unit_number,
	name = entity.name,
	position = Vector(Coordinates(entity)),
-- 	cell = HeatNetworkCell(), -- HeatNetworkCell which the reactor belongs to
} end

local function HeatChunk(...) return {
	position = Vector(ChunkCoordinates(...)),
	area =  ChunkArea(ChunkCoordinates(...)),
	cells = {}, -- array of HeatNetworkCell indexed by itself
-- 	network = HeatNetwork(), -- network this chunk belongs to
	border = {
		[N] = {}, -- array of HeatNetworkCell indexed by x
		[E] = {}, -- array of HeatNetworkCell indexed by y
		[S] = {}, -- array of HeatNetworkCell indexed by x
		[W] = {}, -- array of HeatNetworkCell indexed by y
	},
	count = {
		cell = 0, -- number of HeatNetworkCell
		 [N] = 0, -- number of HeatNetworkCell
		 [E] = 0, -- number of HeatNetworkCell
		 [S] = 0, -- number of HeatNetworkCell
		 [W] = 0, -- number of HeatNetworkCell
	},
} end


-- only required for debugging
local function HeatNetworkId()
	local i = -1
	for id in pairs(HEAT.ids) do
		i = math.max(i,id)
	end
	local id = i + 1
	HEAT.ids[id] = id
-- 	log("create new network " .. tostring(id))
	return id -- uniq number
end

local function HeatNetwork() return {
	id = HeatNetworkId(),
	reactors = {}, -- array of ReactorPosition indexed by entity.unit_number
	chunks   = {}, -- array of HeatChunk       indexed by x,y
	count = {
		chunk   = 0, -- number of HeatChunk
		cell    = 0, -- number of HeatNetworkCell
		reactor = 0, -- number of reactors
	},
} end

local function HeatNetworkCell() return {
-- 	chunk = HeatChunk(), -- chunk this cell belongs to
	entities = {}, -- matrix of heat-pipe and reactor entities indexed by x,y
	reactors = {}, -- array  of ReactorPosition                indexed by entity.unit_number
-- 	area = Area(), -- bounding box of network
	count = {
		entity  = 0, -- number of heat-pipes
		reactor = 0, -- number of reactors
		outlet  = 0, -- number of reactor outlets
	},
} end



local function set_chunk_borders(chunk, x,y, cell)
	local p = Vector(x,y)
	local count = cell and 1 or -1
	for _,corner in ipairs{'left_top','right_bottom'} do
		for k,v in pairs(p) do
			if chunk.area[corner][k] == v then
				local d = A[corner][k]
				chunk.border[d][p[V[k]]] = cell
				chunk.count[d] = chunk.count[d] + count
-- 				log(string.format("%s chunk border in network %s at x=%s y=%s", cell and "add cell to" or "remove cell from", chunk.network.id, x,y))
			end
		end
	end
end

local function get_or_create_heat_network_chunk(x,y,z, network)
	local cx,cy = ChunkCoordinates(x,y,z)
	local chunk = get2d(network.chunks, cx,cy)
	if chunk then return chunk end
	chunk = HeatChunk(x,y,z)
	chunk.network = network
-- 	log(string.format("create new chunk in network %s at x=%s y=%s z=%s", network.id, chunk.position.x,chunk.position.y,chunk.position.z))
	set2d(network.chunks, cx,cy, chunk)
	network.count.chunk = network.count.chunk + 1
	return chunk
end

local function create_heat_network_cell(x,y,z, network)
	local chunk = get_or_create_heat_network_chunk(x,y,z, network)
	local cell = HeatNetworkCell()
-- 	log(string.format("create heat network cell in network %s at x=%s y=%s z=%s", network.id, x,y,z))
-- 	cell.area = growarea(cell.area, Area(x,y))
	network.count.cell = network.count.cell + 1
	chunk.count.cell = chunk.count.cell + 1
	chunk.cells[cell] = cell
	cell.chunk = chunk
	return cell
end

local function create_heat_network(x,y,z)
	local network = HeatNetwork()
	local cell = create_heat_network_cell(x,y,z, network)
	HEAT.network[network.id] = network
-- 	log(string.format("created heat network %s", network.id))
	return cell
end

local function remove_heat_network(x,y,z, cell)
	local chunk,network = cell.chunk,cell.chunk.network
	rm_heat_network_cell(x,y,z)
	set_chunk_borders(chunk, x,y, nil)
-- 	log(string.format("removed heat network %s", network.id))
	if cell.count.entity + cell.count.reactor + cell.count.outlet > 0 then return end
	chunk.cells[cell] = nil
	chunk.count.cell = chunk.count.cell - 1
	network.count.cell = network.count.cell - 1
	if chunk.count.cell > 0 then return end
	rm2d(network.chunks, chunk.position.x,chunk.position.y)
	network.count.chunk = network.count.chunk - 1
	if network.count.chunk > 0 then return end
	-- network gets garbage collected
	cleanup_heat_network(network.id)
end


local move_entities
local function move_cells(cell, position, offset, network, neighbours, inside, last, dst, ignore)
	local old = cell.chunk
	local x,y,z = position.x+offset.x,position.y+offset.y,old.position.z
	if cell == ignore then
		local entity = get2d(cell.entities, x,y)
		if entity then
			if inside[entity] == inside[last] then
-- 				log(string.format("leafing recursion cuz cell is connected inside at x=%s y=%s", x,y))
				return
			end
-- 			log(string.format("return to crawling at x=%s y=%s", x,y))
			dst = create_heat_network_cell(x,y,z, network)
			move_entities(entity, Vector(x,y), dst,cell, neighbours, inside)
		end
		return -- to crawling
	end
	local new = get_or_create_heat_network_chunk(x,y,z, network)
	if old.network == new.network then return end
-- 	log(string.format("move cells into network %s from %s at x=%s y=%s z=%s",  network.id,old.network.id, x,y,z))
	cell.chunk = new
	old.cells[cell] = nil
	new.cells[cell] = cell
	old.count.cell = old.count.cell - 1
	new.count.cell = new.count.cell + 1
	old.network.count.cell = old.network.count.cell - 1
	    network.count.cell =     network.count.cell + 1
	for id,reactor in pairs(cell.reactors) do
		if not network.reactors[id] then
			old.network.reactors[id] = nil
			    network.reactors[id] = reactor
			old.network.count.reactor = old.network.count.reactor - 1
			    network.count.reactor = network.count.reactor + 1
		end
	end
	if not (old.count.cell > 0) then
		rm2d(old.network.chunks, ChunkCoordinates(x,y))
		old.network.count.chunk = old.network.count.chunk - 1
	end
	neighbour_cells(old, cell, move_cells, network, neighbours, inside, last, dst, ignore)
	set_chunk_borders(old, x,y, nil)
	set_chunk_borders(new, x,y, cell)
	for d in pairs(O) do
		for c,other in pairs(old.border[d]) do
			if other == cell then
				old.border[d][c] = nil
				new.border[d][c] = cell
				old.count[d] = old.count[d] - 1
				new.count[d] = new.count[d] + 1
			end
		end
	end
end

move_entities = function (entity, position, new,old, neighbours, inside) -- salami tactics
	local x,y,z = position.x,position.y,old.chunk.position.z -- use this instead of entity.position which could be in another cell
	if not get2d(old.entities, x,y) then
		local other = get_heat_network_cell(x,y,z)
		if other ~= old then -- found outside
			move_cells(other, position, Vector(0,0), new.chunk.network, neighbours,inside,entity,new,old)
		end
		return
	end
-- 	log(string.format("move entity between networks from %s to %s at x=%s y=%s z=%s  %s", old.chunk.network.id, new.chunk.network.id, x,y,z, serpent.line{from=old.count,to=new.count}))
-- 	new.area = growarea(new.area, Area(x,y))
	if entity.type ~= "reactor" then
		old.count.entity = old.count.entity - 1
		new.count.entity = new.count.entity + 1
	elseif old.reactors[entity.unit_number] then
		old.count.reactor = old.count.reactor - 1
		new.count.reactor = new.count.reactor + 1
		local reactor = old.reactors[entity.unit_number]
		old.reactors[reactor.id] = nil
		new.reactors[reactor.id] = reactor
		reactor.cell = new
		old.chunk.network.reactors[reactor.id] = nil
		new.chunk.network.reactors[reactor.id] = reactor
		old.chunk.network.count.reactor = old.chunk.network.count.reactor - 1
		new.chunk.network.count.reactor = new.chunk.network.count.reactor + 1
	else
		old.count.outlet = old.count.outlet - 1
		new.count.outlet = new.count.outlet + 1
	end
	 rm2d(old.entities, x,y)
	set2d(new.entities, x,y, entity)
	if old.chunk.network ~= new.chunk.network then
		get_chunk_neighbour(old, x,y, move_cells, new.chunk.network, neighbours,inside,entity,new,old)
	end
	remove_heat_network(x,y,z, old)
	set_heat_network_cell(x,y,z, new)
	set_chunk_borders(new.chunk, x,y, new)
	neighbours(entity, move_entities, new,old, neighbours, inside)
end


local function is_border(area,p)
	for _,corner in ipairs{'left_top','right_bottom'} do
		for k,v in pairs(p) do
			if v == area[corner][k] then return true end
		end
	end
	return false
end
local function counter(cell,_,count) count[cell], count.value = true, count.value + 1 end
local function insert_table(e,p,a,b) table.insert(a,e) table.insert(b,p) end
local function split_heat_network_cell(cell,x,y,z,entity)
	local count = {value=0}
	get_entity_neighbour_cells(entity, counter, count)
	if count.value < 2 then return end -- this was the last
-- 	log(string.format("try to split network %s at at x=%s y=%s z=%s  %s ", cell.chunk.network.id, x,y,z, entity.name))
-- 	log(dbgHeatNetwork(cell.chunk.network))
-- 	local area
	local others,positions = {},{}
	local outside,inside = get_linked_entities(cell)
	local chunk_neighbours = chunk_nodes(cell.entities, outside)
	local  cell_neighbours =  cell_nodes(cell.entities)
	chunk_neighbours(entity, insert_table, others, positions)
	local n,c = #others,table_size(count)-1
-- 	log(string.format("found %s entities in %s cells inside of %s total", n,c,count.value))
	if n == 0 then return elseif n == 1 then
		if not is_border(cell.chunk.area, Vector(x,y)) then return end
-- 		log(string.format("split heat network alone  %s", serpent.line{count=cell.count}))
		local connected = false
		get_entity_neighbour_cells(entity, function (neighbour)
			if not connected and cell.chunk ~= neighbour.chunk then
				connected = testpath(cell, neighbour, connected_cells) -- outside
			end
		end)
		if connected then -- outside connected
-- 			log(" ... but nothing happens, cuz cells are connected on the outside")
		else
			local p,other = positions[1],others[1]
			local new = create_heat_network(p.x,p.y,z)
			move_entities(other, p, new,cell, cell_neighbours, inside)
-- 			log("moved into new network " .. tostring(new.chunk.network.id))
-- 			log(dbgHeatNetwork(new.chunk.network))
		end
		return -- weird, lol
	end
	if c > 1 then
		get_entity_neighbour_cells(entity, function (other,p)
			if other ~= cell then
				if not testpath(cell, other, connected_cells) then -- outside
					local new = create_heat_network(p.x,p.y,z)
					move_cells(other, p, Vector(0,0), new.chunk.network, cell_neighbours,new,cell)
-- 					log("moved neighbour into new network " .. tostring(new.chunk.network.id))
				end
			end
		end)
	end
	local before = others[n]
-- 	log(string.format("split heat network  %s", serpent.line{count=cell.count}))
	for i,other in ipairs(others) do
		local p = positions[i]
		if get2d(cell.entities, p.x,p.y) then
			if before and before ~= other then
				local path = getpath(before, other, chunk_neighbours)
				if path and #path == 2 and path[1] == entity then path = nil --[[log"WTF"]] end
				local outside = is_connected_outside(path)
				if path then
-- 					log(string.format("found path of length %s %sside", #path, outside and "out" or "in"))
					for _,node in ipairs(path) do
-- 						log(node.name .. ":  " .. dbgVector(node.position))
					end
				end
				if not path or outside then
					-- TODO determine which half is now smaller then the other and fill-move the smaller one. -- maybe impossibru ? -- maybe with area?
					local network
					if path then -- outside
						if not testpath(before, other, cell_neighbours) then -- inside
-- 							log("splitting cell inside network")
							local new = create_heat_network_cell(p.x,p.y,z, cell.chunk.network)
							move_entities(other, p, new,cell, cell_neighbours, inside)
							network = new.chunk.network
						end
					else -- inside
						local new = create_heat_network(p.x,p.y,z)
						move_entities(other, p, new,cell, cell_neighbours, inside)
						network = new.chunk.network
					end
-- 					area = growarea(area, new.area)
					other = nil -- skip this before
					if not path then
-- 						log("moved into new network " .. tostring(network.id))
-- 						log(dbgHeatNetwork(network))
					end
				end
			end
			before = other or before
		end
	end
-- 	cell.area = subarea(area, cell.area)
end


local function network_score(network)
	local count = network.count
	return count.chunk + count.cell + count.reactor
end
local function chunk_score(chunk)
	local sum = 0 for _,count in pairs(chunk.count) do sum = sum + count end
	return sum + network_score(chunk.network)
end
local function cell_score(cell)
	local count = cell.count
	return 2 * count.entity + count.reactor + count.outlet + chunk_score(cell.chunk)
end

local function merge_heat_chunk(a,b)
	if chunk_score(a) < chunk_score(b) then a,b = b,a end -- spare some work
-- 	log(string.format("merge heat chunk at x=%s y=%s z=%s", a.position.x,a.position.y,a.position.z))
	for k,count in pairs(b.count) do
		a.count[k] = a.count[k] + count
	end
	for cell in pairs(b.cells) do
		a.cells[cell] = cell
		cell.chunk = a
	end
	for d,border in pairs(b.border) do
		for c,cell in pairs(border) do
			a.border[d][c] = cell
		end
	end
	return a
end

local function merge_heat_network(a,b)
	local an,bn = a.chunk.network, b.chunk.network
	if an ~= bn then
		if cell_score(a) < cell_score(b) then an,bn = bn,an end -- spare some work
-- 		log(string.format("merge heat network %s into %s  %s", bn.id, an.id, serpent.line{from=bn.count,to=an.count}))
		for k,count in pairs(bn.count) do
			an.count[k] = an.count[k] + count
		end
		for id,reactor in pairs(bn.reactors) do
			an.reactors[id] = reactor
		end
		for x,xs in pairs(bn.chunks) do
			for y,chunk in pairs(xs) do
				local current = get2d(an.chunks, x,y)
				chunk.network = an
				if current then
					an.count.chunk = an.count.chunk - 1
					chunk = merge_heat_chunk(current, chunk)
				end
				set2d(an.chunks, x,y, chunk)
			end
		end
		cleanup_heat_network(bn.id)
	end
	return a
end

local function merge_heat_network_cells(x,y,z, a,b)
	if not b or b == a then return a end
	if sameposition(a.chunk.position, b.chunk.position) then
		if cell_score(a) < cell_score(b) then a,b = b,a end -- spare some work
-- 		log(string.format("merge heat network cells %s into %s  %s", b.chunk.network.id, a.chunk.network.id, serpent.line{from=b.count,to=a.count}))
-- 		a.area = growarea(a.area, b.area)
		for k,count in pairs(b.count) do
			a.count[k] = a.count[k] + count
		end
		local z = a.chunk.position.z
		for x,xs in pairs(b.entities) do
			for y,entity in pairs(xs) do
				set2d(a.entities, x,y, entity)
				set_heat_network_cell(x,y,z, a)
				set_chunk_borders(b.chunk, x,y, nil)
				set_chunk_borders(a.chunk, x,y, a)
			end
		end
		for _,reactor in pairs(b.reactors) do
			local p = reactor.position
			reactor.cell = a
			a.reactors[reactor.id] = reactor
		end
		for d,border in pairs(b.chunk.border) do
			for c,cell in pairs(border) do
				if cell == b then
					a.chunk.border[d][c] = a
				end
			end
		end
		b.chunk.cells[b] = nil
		b.chunk.count.cell = b.chunk.count.cell - 1
		b.chunk.network.count.cell = b.chunk.network.count.cell - 1
	end
	return merge_heat_network(a,b)
end


local function add_entity_to_network_cell(x,y,z,entity)
	local cell = create_heat_network(x,y,z)
	local is_reactor = entity.type == 'reactor'
	for i,p,o in heat_buffer_transitions(entity) do
		-- add heat pipe neighbours
-- 		log(string.format("looking at x=%s y=%s for heat network cell", o.x,o.y))
		cell = merge_heat_network_cells(x,y,z, cell, get_heat_network_cell(o.x,o.y,z))
		-- add reactor neighbours
		if is_reactor or i == 1 then -- assuming heat pipe is just one tile in size (all connection positions are the same)
			local reactors = get_heat_outlet(p.x,p.y,z, {})
-- 			log(string.format("test x=%s y=%s for outlet with %s reactors", p.x,p.y, table_size(reactors)))
			for _,reactor in pairs(reactors) do
				local q = heat_buffer_transition_position(reactor, reactor.position,p)
				cell = merge_heat_network_cells(x,y,z, cell, get_heat_network_cell(q.x,q.y,z))
			end
		end
	end
	set_heat_network_cell(x,y,z, cell)
	set_chunk_borders(cell.chunk, x,y, cell)
	set2d(cell.entities, x,y, entity)
	if is_reactor then
		cell.chunk.network.count.reactor = cell.chunk.network.count.reactor + 1
		cell.count.reactor = cell.count.reactor + 1
	else
		cell.count.entity = cell.count.entity + 1
	end
-- 	log(string.format("added cell to network %s at x=%s y=%s z=%s  %s", cell.chunk.network.id, x,y,z, serpent.line{count=cell.count}))
	return cell
end

local function remove_entity_from_network_cell(x,y,z,entity,cell)
	local network = cell.chunk.network
	if entity.type ~= "reactor" then
		cell.count.entity = cell.count.entity - 1
	else
		cell.chunk.network.count.reactor = cell.chunk.network.count.reactor - 1
		cell.count.reactor = cell.count.reactor - 1
	end
	rm2d(cell.entities, x,y)
	remove_heat_network(x,y,z, cell)
	if cell.count.entity + cell.count.reactor + cell.count.outlet > 0 then
		split_heat_network_cell(cell, x,y,z, entity)
	end
-- 	shrinkarea(cell.area,cell.entities) -- shrink area by entity on border
-- 	log(string.format("removed cell from network %s at x=%s y=%s z=%s  %s", cell.chunk.network.id, x,y,z, serpent.line{count=cell.count}))
-- 	log(dbgHeatNetwork(network))
end


local function get_heat_network(entity)
	local cell = get_heat_network_cell(Coordinates(entity))
	return cell and cell.chunk.network
end

local function get_connected_reactors(entity)
	local network = get_heat_network(entity)
	return network and network.reactors or {}
end


local function calculate_corner_index(area, x,y)
	local i = 1
	if x < area.left_top.x or area.right_bottom.x < x then i = i + 1 end
	if y < area.left_top.y or area.right_bottom.y < y then i = i + 2 end
	return i -- {1=(x,y inside area), 2=(x outside area), 3=(y outside area), 4=(x,y outside area)}
end
local function add_reactor_to_network(entity)
	if get_reactor_core_power(entity) then return end -- ignore reactor cores
	local x,y,z = Coordinates(entity)
-- 	log(string.format("add reactor to network  x=%s y=%s z=%s", x,y,z))
	local cell = add_entity_to_network_cell(x,y,z,entity)
	local reactor = ReactorPosition(entity)
	cell.chunk.network.reactors[reactor.id] = reactor
	cell.reactors[reactor.id] = reactor
	reactor.cell = cell
	-- merge outlets
	local corner = {cell} -- up to 4 cells
	for _,p,o in heat_buffer_transitions(entity) do
		local reactors = get_heat_outlet(o.x,o.y,z, {})
-- 		log(string.format("outlet at x=%s y=%s z=%s with %s others", o.x,o.y,z, table_size(reactors)))
		reactors[reactor.id] = reactor
		set_heat_outlet(o.x,o.y,z, reactors)
		local i = calculate_corner_index(cell.chunk.area, p.x,p.y)
		local other = corner[i] or create_heat_network_cell(p.x,p.y,z, cell.chunk.network)
		if not get2d(other.entities, p.x,p.y) then
			other.count.outlet = other.count.outlet + 1
			set2d(other.entities, p.x,p.y, entity)
			set_chunk_borders(other.chunk, p.x,p.y, other)
			set_heat_network_cell(p.x,p.y,z, other)
		end
		other = merge_heat_network_cells(p.x,p.y,z, other, get_heat_network_cell(o.x,o.y,z))
		corner[i] = other
	end
	debug.update()
end


local function remove_reactor_from_network(entity)
	if get_reactor_core_power(entity) then return end -- ignore reactor cores
	local x,y,z = Coordinates(entity)
	local cell = get_heat_network_cell(x,y,z)
	local reactor = cell and cell.reactors[entity.unit_number]
	if not reactor then return end
-- 	log(string.format("remove reactor from network cell %s at x=%s y=%s z=%s  %s", cell.chunk.network.id, x,y,z, serpent.line{count=cell.count}))
	-- cleanup outlets
	local remove = {}
	for _,p,o in heat_buffer_transitions(entity) do
		local reactors = get_heat_outlet(o.x,o.y,z, {})
		reactors[reactor.id] = nil
		if isempty(reactors) then reactors = nil end
		set_heat_outlet(o.x,o.y,z, reactors)
		set2d(remove, p.x,p.y, get_heat_network_cell(p.x,p.y,z))
	end
	-- remove from cells now cuz of duplicate positions
	for x,xs in pairs(remove) do
		for y,other in pairs(xs) do
			other.count.outlet = other.count.outlet - 1
			remove_heat_network(x,y,z, other)
			set_chunk_borders(other.chunk, x,y)
			rm2d(other.entities, x,y)
		end
	end
	remove_entity_from_network_cell(x,y,z, entity, cell)
	cell.chunk.network.reactors[reactor.id] = nil
	cell.reactors[reactor.id] = nil
	reactor.cell = nil
	debug.update()
end


local function add_heat_pipe_to_network(entity)
	local x,y,z = Coordinates(entity)
-- 	log(string.format("add heat pipe to network cell at x=%s y=%s z=%s", x,y,z))
	add_entity_to_network_cell(x,y,z,entity)
	debug.update()
end

local function remove_heat_pipe_from_network(entity)
	local x,y,z = Coordinates(entity)
	local cell = get_heat_network_cell(x,y,z)
	if not cell then return end
-- 	log(string.format("remove heat pipe from network cell %s at x=%s y=%s z=%s  %s", cell.chunk.network.id, x,y,z, serpent.line{count=cell.count}))
	remove_entity_from_network_cell(x,y,z, entity, cell)
	debug.update()
end


local function remove_heat_network_from_surface(z)
-- 	log("clear heat networks on surface " .. tostring(z))
	clear_heat_network_for_surface(z)
	debug.update()
end

local function remove_heat_network_from_chunk(x,y,z) -- chunk coords
-- 	log(string.format("clear heat networks from chunk at x=%s y=%s z=%s", x,y,z))
	local area = ChunkArea(ChunkCoordinates(x,y,z))
	for x = area.left_top.x, area.right_bottom.x do
		for y = area.left_top.y, area.right_bottom.y do
			local cell = get_heat_network_cell(x,y,z)
			if cell then remove_heat_network(x,y,z, cell) end
		end
	end
	debug.update()
end


-- circular dependency
mod.add_reactor   = add_reactor_to_network
mod.add_heat_pipe = add_heat_pipe_to_network
return { -- exports
	init=mod.init, load=mod.load,
	get = get_heat_network,
	get_connected_reactors = get_connected_reactors,
	   add_reactor      = add_reactor_to_network,
	remove_reactor      = remove_reactor_from_network,
	   add_heat_pipe    =    add_heat_pipe_to_network,
	remove_heat_pipe    = remove_heat_pipe_from_network,
	remove_from_surface = remove_heat_network_from_surface,
	remove_from_chunk   = remove_heat_network_from_chunk,
	debug = debug,
}

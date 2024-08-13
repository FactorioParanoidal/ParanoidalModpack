local rpath = (...):match("(.-)[^%.]+$")
local rroot = rpath:match("^([^%.]+%.)")
local isempty = require(rroot .. "util").isempty
local distance = require(rpath .. "math").distance
local cell_nodes = require(rpath .. "math").cell_nodes
local sameposition = require(rpath .. "util").sameposition

local PRETTYCHECK = "%s (%s)%s"
local function check(value,actual)
	return value, actual, (value == actual and "" or " FAIL")
end
local function Coordinates(entity)
	local x,y,z = entity.position.x,entity.position.y,entity.surface.index
	return math.floor(x), math.floor(y), z
end
local function Vector(x,y,z) return {
	x = x,
	y = y,
	z = z,
} end

-- debugging pretty prints

function dbgLinked(others)
	local strings = {}
	for _,cells in pairs(others) do
		local str = {}
		for _,cell in pairs(cells) do
			table.insert(str, string.format("{entity = %s}", cell.entity.unit_number))
		end
		table.insert(strings, string.format("{%s}", table.concat(str, ", ")))
	end
	return string.format("{%s}", table.concat(strings, ", "))
end

function dbgVector(vector) return "Vector" .. serpent.line(vector) end
function dbgChunkArea(area) return "ChunkArea" .. serpent.line(area) end
function dbgReactorPosition(reactor)
	local strings = {}
	table.insert(strings, "id = " .. tostring(reactor.id))
	table.insert(strings, "position = " .. dbgVector(reactor.position))
	if reactor.cell and reactor.cell.chunk and reactor.cell.chunk.network then
		table.insert(strings, "network = " .. tostring(reactor.cell.chunk.network.id))
	end
	table.insert(strings, "name = " .. tostring(reactor.name))
	return string.format("ReactorPosition{%s}", table.concat(strings, ", "))
end
function dbgHeatNetworkCell(cell)
	local strings = {}
	table.insert(strings, "\tnetwork = " .. tostring(cell.chunk.network.id))
	local entities = {}
	local counter = {entity = 0, reactor = 0, outlet = 0}
	for x,xs in pairs(cell.entities) do
		for y,entity in pairs(xs) do
			local str = {}
			if not entity.valid then
				table.insert(str, "\t\t\tvalid = false")
			else
				table.insert(str, "\t\t\tname = " .. entity.name)
				table.insert(str, "\t\t\ttype = " .. entity.type)
				table.insert(str, "\t\t\tposition = " .. serpent.line(entity.position))
				table.insert(str, "\t\t\tunit_number = " .. entity.unit_number)
				if entity.type ~= 'reactor' then
					counter.entity = counter.entity + 1
				elseif sameposition(Vector(x,y),Vector(Coordinates(entity))) then
					counter.reactor = counter.reactor + 1
				else
					counter.outlet = counter.outlet + 1
				end
			end
			table.insert(entities, string.format("\t\t[%s,%s] = Entity{\n%s\n\t\t}", x,y, table.concat(str, ",\n")))
		end
	end
	local reactors = {}
	for _,reactor in pairs(cell.reactors) do
		table.insert(reactors, "\t\t" .. dbgReactorPosition(reactor))
	end
	local counts = {}
	for k,count in pairs(cell.count) do
		actual = 0
		if k == 'entity' then
			actual = counter.entity
		elseif k == 'reactor' then
			actual = counter.reactor
		elseif k == 'outlet' then
			actual = counter.outlet
		end
		table.insert(counts, string.format("\t\t%s = "..PRETTYCHECK, k, check(count, actual)))
	end
	if isempty(entities) then
		table.insert(strings, "\tentities = {}")
	else
		table.insert(strings, "\tentities = {\n" .. table.concat(entities, ",\n") .. "\n\t} " .. string.format(PRETTYCHECK, check(#entities, counter.entity + counter.reactor + counter.outlet)))
	end
	if isempty(reactors) then
		table.insert(strings, "\treactors = {}")
	else
		table.insert(strings, "\treactors = {\n" .. table.concat(reactors, ",\n") .. "\n\t} " .. string.format(PRETTYCHECK, check(#reactors, counter.reactor)))
	end
	table.insert(strings, "\tcount = {\n" .. table.concat(counts, ",\n") .. "\n\t}")
	return "HeatNetworkCell{\n" .. table.concat(strings, ",\n") .. "\n}"
end
function dbgHeatChunk(chunk)
	local direction = {[N]="north", [S]="south", [E]="east", [W]="west"}
	local strings = {}
	table.insert(strings, "\tnetwork = " .. tostring(chunk.network.id))
	table.insert(strings, "\tposition = " .. dbgVector(chunk.position))
	table.insert(strings, "\tarea = " .. dbgChunkArea(chunk.area))
	local cells,lookup = {},{}
	for cell in pairs(chunk.cells) do
		table.insert(cells, "\t\t" .. string.gsub(dbgHeatNetworkCell(cell), "\n", "\n\t\t"))
		lookup[cell] = #cells
	end
	if isempty(cells) then
		table.insert(strings, "\tcells = {}")
	else
		table.insert(strings, "\tcells = {\n" .. table.concat(cells, ",\n") .. "\n\t}")
	end
	local border = {}
	for d,border_cells in pairs(chunk.border) do
		if not isempty(border_cells) then
			local cells = {}
			for c,cell in pairs(border_cells) do
				table.insert(cells, string.format("[%s] = %s", c,tostring(lookup[cell])))
			end
			table.insert(border, string.format("\t\t%s = {%s}", direction[d], table.concat(cells, ", ")))
		end
	end
	if isempty(border) then
		table.insert(strings, "\tborder = {}")
	else
		table.insert(strings, "\tborder = {\n" .. table.concat(border, ",\n") .. "\n\t}")
	end
	local counts = {}
	for k,count in pairs(chunk.count) do
		actual = 0
		if k == 'cell' then
			actual = #cells
		else
			for _,cell in pairs(chunk.border[k]) do
				actual = actual + (cell and 1 or 0)
			end
		end
		table.insert(counts, string.format("\t\t%s = "..PRETTYCHECK, direction[k] or k, check(count, actual)))
	end
	table.insert(strings, "\tcount = {\n" .. table.concat(counts, ",\n") .. "\n\t}")
	return "HeatChunk{\n" .. table.concat(strings, ",\n") .. "\n}"
end
function dbgHeatNetwork(network)
	local strings = {}
	table.insert(strings, "\tid = " .. network.id)
	local chunks = {}
	local cell_count = 0
	for x,xs in pairs(network.chunks) do
		for z,chunk in pairs(xs) do
			table.insert(chunks, "\t\t" .. string.gsub(dbgHeatChunk(chunk), "\n", "\n\t\t"))
			for _,cell in pairs(chunk.cells) do
				cell_count = cell_count + 1
			end
		end
	end
	local reactors = {}
	for _,reactor in pairs(network.reactors) do
		table.insert(reactors, "\t\t" .. dbgReactorPosition(reactor))
	end
	local counts = {}
	for k,count in pairs(network.count) do
		actual = 0
		if k == 'chunk' then
			actual = #chunks
		elseif k == 'cell' then
			actual = cell_count
		elseif k == 'reactor' then
			actual = #reactors
		end
		table.insert(counts, string.format("\t\t%s = "..PRETTYCHECK, k, check(count, actual)))
	end
	if isempty(chunks) then
		table.insert(strings, "\tchunks = {}")
	else
		table.insert(strings, "\tchunks = {\n" .. table.concat(chunks, ",\n") .. "\n\t}")
	end
	if isempty(reactors) then
		table.insert(strings, "\treactors = {}")
	else
		table.insert(strings, "\treactors = {\n" .. table.concat(reactors, ",\n") .. "\n\t}")
	end
	table.insert(strings, "\tcount = {\n" .. table.concat(counts, ",\n") .. "\n\t}")
	return "HeatNetwork{\n" .. table.concat(strings, ",\n") .. "\n}"
end


-- debug rendering

local WIDTH = 2 -- in pixels
local F = 0.5 - WIDTH/32 -- in tiles
local function debug_entity(cell, x,y, entity, color)
	local ids = {}
	if not entity.valid then return ids end
	local p = entity.position
	local surface = entity.surface
	cell_nodes(cell.entities)(entity,function (other,q)
		local o = {x=q.x+0.5, y=q.y+0.5}
		if o.x - p.x > 0 or o.y - p.y > 0 or entity.type == 'reactor' then
			table.insert(ids, rendering.draw_line{
				surface = surface,
				color = color,
				width = WIDTH,
				from = p,
				to   = o,
			})
		end
	end)
	table.insert(ids, rendering.draw_text{
		surface = entity.surface,
		color = color,
		target = {p.x-0.3, p.y-0.2},
		text = tostring(cell.chunk.network.id),
	})
	return ids
end

local function debug_cell(cell, color)
	local ids = {}
	for x,xs in pairs(cell.entities) do
		for y,entity in pairs(xs) do
			for _,id in ipairs(debug_entity(cell, x,y, entity, color)) do
				table.insert(ids, id)
			end
		end
	end
	return ids
end

local function debug_chunk(chunk, color)
	local surface = game.surfaces[chunk.position.z]
	local ids = {}
	for cell in pairs(chunk.cells) do
		for _,id in ipairs(debug_cell(cell, color)) do
			table.insert(ids, id)
		end
	end
	for d,border in pairs(chunk.border) do
		local corner,k = next(M[d])
		local a = chunk.area[corner][k]
		local o = O[d]
		for c,cell in pairs(border) do
			local p = {[k]=a+0.5, [V[k]]=c+0.5}
			table.insert(ids, rendering.draw_line{
				surface = surface,
				color = color,
				width = WIDTH,
				from = {p.x-o.y*F+o.x*F, p.y-o.x*F+o.y*F},
				to   = {p.x+o.y*F+o.x*F, p.y+o.x*F+o.y*F},
			})
		end
	end
	return ids
end


local function debug_reactor(reactor, color)
	local p = reactor.position
	local surface = game.surfaces[reactor.cell.chunk.position.z]
	local entity = surface.find_entity(reactor.name, p)
	local area = entity and entity.bounding_box
	if not area then return {} end
	local ids = {rendering.draw_rectangle{
		surface = surface,
		color = color,
		filled = false,
		left_top = area.left_top,
		right_bottom = area.right_bottom,
	}}
	table.insert(ids, rendering.draw_text{
		surface = surface,
		color = color,
		target = {p.x-0.3, p.y-0.2},
		text = tostring(reactor.cell.chunk.network.id),
	})
	return ids
end


local function debug_network(network, color)
	if HEAT.debug_logging ~= false then log(dbgHeatNetwork(network)) end
	local ids = {}
	for x,xs in pairs(network.chunks) do
		for y,chunk in pairs(xs) do
			for _,id in ipairs(debug_chunk(chunk, color)) do
				table.insert(ids, id)
			end
		end
	end
	for _,reactor in pairs(network.reactors) do
		for _,id in ipairs(debug_reactor(reactor, color)) do
			table.insert(ids, id)
		end
	end
	return ids
end

local function HSL(h, s, l, a)
	if s<=0 then return l,l,l,a end
	h, s, l = h*6, s, l
	local c = (1-math.abs(2*l-1))*s
	local x = (1-math.abs(h%2-1))*c
	local m,r,g,b = (l-.5*c), 0,0,0
	if h < 1     then r,g,b = c,x,0
	elseif h < 2 then r,g,b = x,c,0
	elseif h < 3 then r,g,b = 0,c,x
	elseif h < 4 then r,g,b = 0,x,c
	elseif h < 5 then r,g,b = x,0,c
	else              r,g,b = c,0,x
	end return (r+m),(g+m),(b+m),a
end

local function random_color(id)
-- 	return {r=global.random(),g=global.random(),b=global.random(),a=1}
	local r,g,b = HSL(((id * 5)  % 23) / 23, 0.9, 0.5)
	return {r=r,g=g,b=b,a=1}
end

local function remove_debug(id, debug)
	HEAT.debug[id] = nil
	for _,id in ipairs(debug.ids) do
		rendering.destroy(id)
	end
	debug.ids = {}
end

local function create_debug(network)
	local id = network.id
	if not HEAT.network[id] then return end
	local debug = HEAT.debug[id] or {color=random_color(id)}
	debug.ids = debug_network(network, debug.color)
	HEAT.debug[id] = debug
end

local function debug_cleanup()
	if not HEAT.debug then return end
	for id,debug in pairs(HEAT.debug) do
		remove_debug(id, debug)
	end
	HEAT.debug = nil
end

local function debug_heat()
	if HEAT.debug then debug_cleanup() end
	HEAT.debug = {}
	for _,network in pairs(HEAT.network) do
		create_debug(network)
	end
end

local function update_debug()
	if not HEAT.debug then return end
	if isempty(HEAT.network) then log("no networks") end
	debug_heat()
end

local function debug_log(enabled)
	HEAT.debug_logging = enabled
	debug_heat()
end



return { -- exports
-- 	create = create_debug,
	update = update_debug,
-- 	remove = remove_debug,
	-- toggle
	 enable = debug_heat,
	disable = debug_cleanup,
	logging = debug_log,
}



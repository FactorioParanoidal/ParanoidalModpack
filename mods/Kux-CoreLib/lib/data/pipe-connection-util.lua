---@class EntityData.PipeConnectionUtil
local class = {}

local Table = KuxCoreLib.Table
local EntityData = KuxCoreLib.EntityData

---@param box BoundingBox
---@return number x1,number y1,number x2,number y2
local function unpackBoundingBox(box)
	if not box then error("BoundingBox is nil") end
	if not box.left_top then return box[1][1], box[1][2], box[2][1], box[2][2] end
	return box.left_top.x, box.left_top.y, box.right_bottom.x, box.right_bottom.y
end

---@param vector Vector
---@return number,number
local function unpackVector(vector)
	assert(vector ~= nil, "vector must not nil")
	if not vector.x then return vector[1],vector[2] end
	return vector.x, vector.y
end

---@param direction number|defines.direction
---@return boolean N,boolean E,boolean S,boolean W
---<p>Usage: <code>local N,E,S,W = get_edge_direction_flags(direction)</code></p>
local function get_edge_direction_flags(direction)
	local N,E,S,W = direction==0, direction==4, direction==8, direction==12
	return N,E,S,W
end

---@param pos Vector
---@param entity data.CraftingMachinePrototype
local function validatePosition(pos, entity)
	local x,y = unpackVector(pos)
	local x1,y1,x2,y2 = unpackBoundingBox(entity.collision_box)
	if x < x1 or x > x2 or y < y1 or y > y2 then
		error(string.format("Position %s is outside of the collision box %s, serpent.line(pos), serpent.line(entity.collision_box)"))
	end
end

---
---@param entity data.CraftingMachinePrototype
---@param edge_name "left"|"right"|"top"|"bottom"
---@return number
local function get_fixed_coord(entity, edge_name)
	local fixed_coord = 0
	local x1,y1,x2,y2 = unpackBoundingBox(entity.collision_box
						or {{-entity.tile_width / 2,-entity.tile_height/2 },{entity.tile_width / 2,entity.tile_height/2}})
	local tile_width = math.ceil(x2-x1)
	local tile_height = math.ceil(y2-y1)

	fixed_coord = (edge_name == "top"    and -tile_width  / 2) or
				  (edge_name == "bottom" and  tile_width  / 2) or
				  (edge_name == "left"   and -tile_height / 2) or
				  (edge_name == "right"  and  tile_height / 2) or
				  error("Invalid edge_name: " .. str(edge_name))

	-- edge position are always integer, which is completely illogical, but that's just the way it is
	fixed_coord = fixed_coord > 0 and math.floor(fixed_coord) or math.ceil(fixed_coord)

	return fixed_coord
end

---@param pt data.CraftingMachinePrototype
---@param pos TilePosition
---@return data.PipeConnectionDefinition?
---@return data.FluidBox?
---@return integer?
local function get_pipe_connection_by_pos(pt, pos)
	if not pt.fluid_boxes then return end
	for _, fluid_box in pairs(pt.fluid_boxes) do
		if not fluid_box.pipe_connections then goto next_box end
		for i, connection in pairs(fluid_box.pipe_connections) do
			local p = connection.position or {0,0}
			local px = p.x or p[1] or 0
			local py = p.y or p[2] or 0
			local posx = pos.x or pos[1] or 0
			local posy = pos.y or pos[2] or 0
			if px == posx and py == posy then
				return fluid_box.pipe_connections[i], fluid_box, i
			end
		end
		::next_box::
	end
end
class.get_pipe_connection_by_pos = get_pipe_connection_by_pos

---@class KuxCoreLib.EntityData.PipeConnectionInfo
---
---@field position number x or y coordinate
---@field fluid_box data.FluidBox
---@field connection data.PipeConnectionDefinition

---Gets a flat list of all pipe connections, ordered by edge and sorted by position
---@param entity data.CraftingMachinePrototype
---@return table<"top"|"left"|"bottom"|"right", KuxCoreLib.EntityData.PipeConnectionInfo[]>
function get_PipeConnectionInfo_by_edge(entity)
	local edges = { top = {}, bottom = {}, left = {}, right = {} }

	local scan_fluid_box = function(fluid_box)
		if not fluid_box then return end
		for _, conn in ipairs(fluid_box.pipe_connections or {}) do
			local x, y = conn.position[1] or conn.position.x, conn.position[2] or conn.position.y

			local edge = (conn.direction ==  0 and "top"   ) or
						 (conn.direction ==  4 and "right" ) or
						 (conn.direction ==  8 and "bottom") or
						 (conn.direction == 12 and "left"  )
			local orientation = (edge == "top" or edge == "bottom") and "h" or "v"

			---@type KuxCoreLib.EntityData.PipeConnectionInfo
			local ci = {
				position = (orientation=="h") and x or y,
				fluid_box = fluid_box,
				connection = conn
			}
			table.insert(edges[edge], ci)
		end
	end

	local sources = {"fluid_box", "energy_source.fluid_box", "energy_source.output_fluid_box", "energy_source.effectivity_fluid_box"}
	for _, source in ipairs(sources) do
		scan_fluid_box(safeget(entity, source))
		for _, fluid_box in ipairs(safeget(entity, source.."es") or {}) do
			scan_fluid_box(fluid_box)
		end
	end

	for _, edge in pairs(edges) do
		table.sort(edge, function(a, b) return a.position < b.position end)
	end

	return edges
end
class.get_PipeConnectionInfo_by_edge = get_PipeConnectionInfo_by_edge

---@class KuxCoreLib.EntityData.PipeConnectionEdge
---@field name "top"|"bottom"|"left"|"right"
---@field connections KuxCoreLib.EntityData.PipeConnectionInfo[]
---@field orientation "h"|"v"
---@field fixed_coord number
---@field min number
---@field max number
---@field old_size number
---@field new_size number


---
---@param entity data.CraftingMachinePrototype
---@return table<"top"|"bottom"|"left"|"right", KuxCoreLib.EntityData.PipeConnectionEdge>
function get_edges(entity)
	local edges = { top = {}, bottom = {}, left = {}, right = {} }

	local x1,y1,x2,y2 = unpackBoundingBox(entity.collision_box)
	local connections_by_edge = get_PipeConnectionInfo_by_edge(entity)

	for edge_name, connections in pairs(connections_by_edge) do
		local orientation = (edge_name == "top" or edge_name == "bottom") and "h" or "v"
		local min, max = table.unpack((edge_name == "top" or edge_name == "bottom") and {x1, x2} or {y1, y2})
		---@type KuxCoreLib.EntityData.PipeConnectionEdge
		local edge = {
			name = edge_name,
			connections = connections_by_edge[edge_name],
			orientation = orientation,
			fixed_coord = get_fixed_coord(entity, edge_name),
			min = min --[[@as number]],
			max = max --[[@as number]],
			old_size = -1, -- filled later
			new_size = -1, -- filled later
		}
		edges[edge_name] = edge
	end

	return edges
end
class.get_edges = get_edges


---@param edge KuxCoreLib.EntityData.PipeConnectionEdge
function shift_connections(edge)
	local done = false
	while not done do
		local shift,last_pos = 0,nil
		done = true
		for _, conn in ipairs(edge.connections) do
			if not conn.position then goto next_connection end
			if conn.position < edge.min then
				conn.position = conn.position + 1
				done = false
				if conn.position > 0 then
					conn.position = nil --remove
				else
					shift = shift + 1
					last_pos = conn.position
				end
			elseif shift>0 then
				if conn.position == last_pos then
					if conn.position > 0 then
						conn.position = nil --remove
					else
						--keep shift at 1
						last_pos = conn.position
					end
				else
					shift = shift - 1
				end
			else
				break
			end
			::next_connection::
		end
		shift,last_pos = 0,nil
		for i = #edge.connections, 1, -1 do
			local conn = edge.connections[i]
			if not conn.position then goto next_connection end
			if conn.position > edge.max then
				conn.position = conn.position - 1
				done = false
				if conn.position < 0 then
					conn.position = nil -- remove
				else
					shift = shift + 1
					last_pos = conn.position
				end
			elseif shift > 0 then
				if conn.position == last_pos then
					if conn.position < 0 then
						conn.position = nil -- remove
					else
						-- keep shift at 1
						last_pos = conn.position
					end
				else
					shift = shift - 1
				end
			else
				break
			end
			::next_connection::
		end
	end
	-- remove all connections with position=nil
	for i = #edge.connections, 1, -1 do
		if edge.connections[i].position == nil then
			Table.remove(edge.connections[i].fluid_box.pipe_connections, edge.connections[i].connection)
			table.remove(edge.connections, i)
		else
			local x = edge.orientation == "h" and edge.connections[i].position or edge.fixed_coord
			local y = edge.orientation == "h" and edge.fixed_coord or edge.connections[i].position
			edge.connections[i].connection.position = {x, y}
		end
	end
end


local function remove_excess_connections(fluid_boxes, new_size)
	-- Flexibles Auslesen von Breite und Höhe
	local max_x = new_size.width or new_size[1] or 0
	local max_y = new_size.height or new_size[2] or 0

	-- Tabelle zum Zählen der Positionen
	local position_count = {}

	-- Alle Positionen sammeln und als Key speichern
	for _, box in pairs(fluid_boxes) do
		if not box.pipe_connections then goto next_box end
		for index, connection in pairs(box.pipe_connections) do
			local pos = connection.position
			if pos then
				local key = pos[1] .. "," .. pos[2]
				position_count[key] = position_count[key] or {}
				table.insert(position_count[key], {box = box, index = index})
			end
		end
		::next_box::
	end

	-- Überzählige Anschlüsse auf allen Seiten entfernen
	for key, indices in pairs(position_count) do
		local x, y = key:match("(-?%d+%.?%d*),(-?%d+%.?%d*)")
		x, y = tonumber(x), tonumber(y)

		-- Maximal zulässige Anzahl berechnen
		local max_allowed = 0
		if y < 0 then -- Oben
			max_allowed = max_x
		elseif y > 0 then -- Unten
			max_allowed = max_x
		end

		if x < 0 then -- Links
			max_allowed = max_y
		elseif x > 0 then -- Rechts
			max_allowed = max_y
		end

		-- Überzählige Anschlüsse löschen
		if #indices > max_allowed then
			for j = #indices, max_allowed + 1, -1 do
				local entry = indices[j]
				entry.box.pipe_connections[entry.index] = nil
			end
		end
	end
end
class.remove_excess_connections = remove_excess_connections



local function print_pipe_connections(pt)
	if not pt.fluid_boxes then return end
	local results = {}
	local edges = get_PipeConnectionInfo_by_edge(pt)
	for _, edge in pairs(edges) do
		for _, conn in pairs(edge) do
			local p = conn.connection.position
			local px, py = p.x or p[1] or 0, p.y or p[2] or 0
			results[#results + 1] = string.format("(%g, %g)", px, py)
		end
	end
	if #results > 0 then
		print("pipe_connections: " .. table.concat(results, ", "))
	end
end


local function move_pipe_connection_for_resize_OLD(pt,old_size, new_size)
	print("move_pipe_connection_for_resize "..pt.name)
	if not pt.fluid_boxes then return end
	print_pipe_connections(pt)
	if type(old_size) ~="table" then old_size = {old_size, old_size} end
	if type(new_size) ~="table" then new_size = {new_size, new_size} end
	if old_size.width then old_size = {old_size.width, old_size.height} end
	if new_size.width then new_size = {new_size.width, new_size.height} end

	local rel_size_x, rel_size_y = new_size[1] - old_size[1], new_size[2] - old_size[2]
	local ox, oy = math.abs(rel_size_x) / 2, math.abs(rel_size_y) / 2           -- offset x/y
	local shift_x_needed = rel_size_x % 2 ~= 0
	local shift_y_needed = rel_size_y % 2 ~= 0

	for _, box in pairs(pt.fluid_boxes) do
		if not box.pipe_connections then goto next_box end
		for i, connection in pairs(box.pipe_connections) do
			local p = connection.position
			if not p then goto next_connection end
			local px,py = p.x or p[1] or 0, p.y or p[2] or 0
			local N,E,S,W = get_edge_direction_flags(connection.direction)

		    if     N then py = py - rel_size_y / 2
			elseif S then py = py + rel_size_y / 2
			elseif E then px = px + rel_size_x / 2
			elseif W then px = px - rel_size_x / 2
			end

			if     (N or S) and shift_x_needed and rel_size_x>0 then px = px + (px < 0 and -0.5 or  0.5)
			elseif (N or S) and shift_x_needed and rel_size_x<0 then px = px + (px < 0 and  0.5 or -0.5)
			elseif (E or W) and shift_y_needed and rel_size_y>0 then py = py + (py < 0 and -0.5 or  0.5)
			elseif (E or W) and shift_y_needed and rel_size_y<0 then py = py + (py < 0 and  0.5 or -0.5) end

			--if cx and shift_x_needed then px = px + 0.5 * (rel_size_y > 0 and 1 or -1) end
			--elseif cy and shift_y_needed then py = py + 0.5 * (rel_size_x > 0 and 1 or -1) end

			box.pipe_connections[i].position = {px, py}
			::next_connection::
		end
		::next_box::
	end

	print_pipe_connections(pt)
	for _, edge in pairs(get_edges(pt)) do
		shift_connections(edge)
	end
	print_pipe_connections(pt)
	remove_excess_connections(pt.fluid_boxes, new_size)
	if pt.name == "nuclear-reactor-mk01" then
		print(serpent.block(pt))
		error("stop")
	end
end


---
---@param edge KuxCoreLib.EntityData.PipeConnectionEdge
function adjust_grid_positions(edge)
	local old_even = (edge.old_size % 2) == 0
	local new_even = (edge.new_size % 2) == 0
	if old_even == new_even then return end
	local shrink = edge.new_size < edge.old_size
	local odd2even = not old_even and new_even
	local is0occupied = false
	for _, conn in ipairs(edge.connections) do if conn.position == 0 then is0occupied = true break end end

	local offs = 0.5                                   -- -1 0 +1 -> -1.5 1.5 | -0.5 0.5 -> -1 0 +1
	if shrink and odd2even and not is0occupied then offs = -0.5 end    -- 1 (0) +1 -> -0.5 0.5

	for _, conn in ipairs(edge.connections) do
		conn.position = conn.position + (conn.position < 0 and -offs or offs)
	end
end

---@param pt data.CraftingMachinePrototype
---@param old_size int|table
---@param new_size int|table
local function move_pipe_connection_for_resize(pt, old_size, new_size)
	--print("move_pipe_connection_for_resize "..pt.name)
	if not pt.fluid_boxes then return end

	if type(old_size) ~="table" then old_size = {old_size, old_size} end
	if type(new_size) ~="table" then new_size = {new_size, new_size} end
	if old_size.width then old_size = {old_size.width, old_size.height} end
	if new_size.width then new_size = {new_size.width, new_size.height} end

	local edges = get_edges(pt)
	for _, edge in pairs(edges) do
		edge.old_size = edge.orientation == "h" and old_size[1] or old_size[2]
		edge.new_size = edge.orientation == "h" and new_size[1] or new_size[2]
		adjust_grid_positions(edge) -- when the size parity changes
		shift_connections(edge)
	end
end
class.move_pipe_connection_for_resize = move_pipe_connection_for_resize

---
---@param pt data.CraftingMachinePrototype
---@param pos TilePosition
local function remove_pipe_connection(pt, pos)
	local con, box, i = get_pipe_connection_by_pos(pt, pos)
	if not con or not box then return end
	table.remove(box.pipe_connections, i)
end
class.remove_pipe_connection = remove_pipe_connection

---
---@param pt data.CraftingMachinePrototype
---@param pos TilePosition
local function move_pipe_connection(pt, pos, new_pos)
	local con, i, box = get_pipe_connection_by_pos(pt, pos)
	if not con or not box then return end
	con.position = new_pos
end
class.move_pipe_connection = move_pipe_connection

-----------------------------------------------------------------------------------------------------------------------
return class

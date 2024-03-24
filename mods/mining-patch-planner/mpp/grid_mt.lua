local floor, ceil, min, max = math.floor, math.ceil, math.min, math.max

local mpp_util = require("mpp.mpp_util")

---@class GridRow: table<number, GridTile>
---@field [number] GridTile

---@class Grid
---@field [number] GridRow
local grid_mt = {}
grid_mt.__index = grid_mt

---Coordinate aggregate of the resource patch
---@class Coords
---@field x1 double Top left corner of the patch
---@field y1 double Top left corner of the patch
---@field x2 double Bottom right corner of the patch
---@field y2 double Bottom right corner of the patch
---@field ix1 number Integer top left corner of the patch
---@field iy1 number Integer top left corner of the patch
---@field ix2 number Integer bottom right corner
---@field iy2 number Integer bottom right corner
---@field w integer Width of the patch
---@field h integer Height of the patch
---@field tw integer Width Rotation invariant width
---@field th integer Height Rotation invariant height
---@field gx double x1 but -1 for grid rendering
---@field gy double y1 but -1 for grid rendering
---@field extent_x1 number Internal grid dimensions
---@field extent_y1 number Internal grid dimensions
---@field extent_x2 number Internal grid dimensions
---@field extent_y2 number Internal grid dimensions

---@alias GridBuilding
---| nil
---| "miner"
---| "pole"
---| "beacon"
---| "belt"
---| "inserter"
---| "container"
---| "lamp"
---| "other"

local need_electricity = {
	miner = true,
	beacon = true,
	inserter = true
}

---@class GridTile
---@field amount number Amount of resource on tile
---@field neighbor_amount number Total resource sum of neighbors (performance killer?)
---@field neighbors_inner number Physical drill coverage
---@field neighbors_outer number Drill radius coverage
---@field x integer
---@field y integer
---@field gx double actual coordinate in surface
---@field gy double actual coordinate in surface
---@field built_on GridBuilding Is tile occupied by a building entity
---@field consumed boolean Is a miner consuming this tile

---@class BlueprintGridTile : GridTile
---@field neighbor_counts table<number, number>
---@field neighbors_inner nil
---@field neighbors_outer nil

---comment
---@param x integer Grid coordinate
---@param y integer Grid coordinate
---@return GridTile|nil
function grid_mt:get_tile(x, y)
	local row = self[y]
	if row then return row[x] end
end

---Convolves resource count for a grid cell
---For usage in blueprint layouts
---@param ox any
---@param oy any
---@param size any
function grid_mt:convolve(ox, oy, size)
	local nx1, nx2 = ox, ox+size - 1
	local ny1, ny2 = oy, oy+size - 1

	for y = ny1, ny2 do
		---@type table<number, BlueprintGridTile>
		local row = self[y]
		if row == nil then goto continue_row end
		for x = nx1, nx2 do
			local tile = row[x]
			if tile == nil then goto continue_column end
			local counts = tile.neighbor_counts
			counts[size] = counts[size] + 1
			::continue_column::
		end
		::continue_row::
	end
end

---Convolves resource count for a grid cell
---@param ox any
---@param oy any
---@param size any
function grid_mt:convolve_inner(ox, oy, size)
	local nx1, nx2 = ox, ox+size - 1
	local ny1, ny2 = oy, oy+size - 1

	for y = ny1, ny2 do
		---@type table<number, GridTile>
		local row = self[y]
		if row == nil then goto continue_row end
		for x = nx1, nx2 do
			local tile = row[x]
			if tile == nil then goto continue_column end
			tile.neighbors_inner = tile.neighbors_inner + 1
			::continue_column::
		end
		::continue_row::
	end
end

---Convolves resource count for a grid cell
---@param ox any
---@param oy any
---@param size any
function grid_mt:convolve_outer(ox, oy, size, amount)
	local nx1, nx2 = ox, ox+size - 1
	local ny1, ny2 = oy, oy+size - 1

	for y = ny1, ny2 do
		---@type table<number, GridTile>
		local row = self[y]
		if row == nil then goto continue_row end
		for x = nx1, nx2 do
			local tile = row[x]
			if tile == nil then goto continue_column end
			tile.neighbors_outer = tile.neighbors_outer + 1
			tile.neighbor_amount = tile.neighbor_amount + amount
			::continue_column::
		end
		::continue_row::
	end
end

---@param ox number
---@param oy number
---@param drill MinerStruct
function grid_mt:convolve_miner(ox, oy, drill)
	local x1, y1 = ox-drill.extent_positive, ox-drill.extent_positive
	local x2, y2 = x1+drill.area, y1+drill.area
	local ix1, iy1 = ox-drill.size+1, oy-drill.size+1
	local ix2, iy2 = x1+drill.size, y1+drill.size

	for y = y1, y2 do
		local row = self[y]
		if row then
			for x = x1, x2 do
				---@type GridTile
				local tile = row[x]
				if tile then
					tile.neighbors_outer = tile.neighbors_outer + 1
					if ix1 < x and x < ix2 and iy1 < y and y < iy2 then
						tile.neighbors_outer = tile.neighbors_outer + 1
					end
				end
			end
		end
	end
end


---Marks tiles (with resources) as consumed by a mining drill
---@param ox integer
---@param oy integer
function grid_mt:consume(ox, oy, size)
	local nx1, nx2 = ox, ox+size - 1
	local ny1, ny2 = oy, oy+size - 1

	for y = ny1, ny2 do
		local row = self[y]
		if row == nil then goto continue_row end
		for x = nx1, nx2 do
			local tile = row[x]
			if tile and tile.amount > 0 then
				tile.consumed = true
			end
		end
		::continue_row::
	end
end

---@param cx number
---@param cy number
---@param w number
---@param evenw boolean
---@param evenh boolean
---@deprecated
function grid_mt:consume_custom(cx, cy, w, evenw, evenh)
	local ox, oy = evenw and 1 or 0, evenh and 1 or 0
	local x1, x2 = cx+ox-w, cx+w
	for y = cy+oy-w, cy+w do
		local row = self[y]
		if row == nil then goto continue_row end
		for x = x1, x2 do
			local tile = row[x]
			if tile and tile.amount then
				tile.consumed = true
			end
		end
		::continue_row::
	end
end

---Marks tiles as consumed by a miner
---@param tiles GridTile[]
function grid_mt:clear_consumed(tiles)
	for _, tile in pairs(tiles) do
		---@cast tile GridTile
		tile.consumed = false
	end
end

---Builder function
---@param cx number x coord
---@param cy number y coord
---@param size_w number
---@param thing GridBuilding Type of building
function grid_mt:build_thing(cx, cy, thing, size_w, size_h)
	size_h = size_h or size_w
	for y = cy, cy + size_h do
		local row = self[y]
		if row == nil then goto continue_row end
		for x = cx, cx + size_w do
			local tile = row[x]
			if tile then
				tile.built_on = thing
			end
		end
		::continue_row::
	end
end

function grid_mt:build_thing_simple(cx, cy, thing)
	local row = self[cy]
	if row then
		local tile = row[cx]
		if tile then
			tile.built_on = thing
			return true
		end
	end
end

---@param t GhostSpecification
function grid_mt:build_specification(t)
	local cx, cy = t.grid_x, t.grid_y
	local left, right = t.padding_pre, t.padding_post
	local thing = t.thing

	if left == nil and right == nil then
		local row = self[cy]
		if row then
			local tile = row[cx]
			if tile then
				tile.built_on = thing
			end
		end
	else
		left, right = left or 0, right or 0
		local x1, x2 = cx-left, cx+right
		for y = cy-left, cy+right do
			local row = self[y]
			if row == nil then goto continue_row end
			for x = x1, x2 do
				local tile = row[x]
				if tile then
					tile.built_on = thing
				end
			end
			::continue_row::
		end
	end
end

---Finds if an entity type is built near
---@param cx number x coord
---@param cy number y coord
---@param thing GridBuilding Type of building
---@return boolean
function grid_mt:find_thing(cx, cy, thing, size)
	local x1, x2 = cx, cx + size
	for y = cy, cy+size do
		local row = self[y]
		if row == nil then goto continue_row end
		for x = x1, x2 do
			local tile = row[x]
			if tile and tile.built_on == thing then
				return true
			end
		end
		::continue_row::
	end
	return false
end

---Finds if an entity type is built near
---@param cx number x coord
---@param cy number y coord
---@param things table<string, true> Types of entities
---@param r number Radius
---@param even boolean Is even width building
---@return boolean
function grid_mt:find_thing_in(cx, cy, things, r, even)
	things = mpp_util.list_to_keys(things)
	local o = even and 1 or 0
	for y = cy+o-r, cy+r do
		local row = self[y]
		if row == nil then goto continue_row end
		for x = cx+o-r, cx+r do
			local tile = row[x]
			if tile and things[tile.built_on] then
				return true
			end
		end
		::continue_row::
	end
	return false
end

function grid_mt:build_miner(cx, cy, size)
	self:build_thing(cx, cy, "miner", size, size)
end

function grid_mt:get_unconsumed(ox, oy, size)
	local nx1, nx2 = ox, ox+size - 1
	local ny1, ny2 = oy, oy+size - 1
	local count = 0

	for y = ny1, ny2 do
		local row = self[y]
		if row == nil then goto continue_row end
		for x = nx1, nx2 do
			local tile = row[x]
			if tile and tile.amount > 0 and not tile.consumed then
					count = count + 1
			end
		end
		::continue_row::
	end
	return count
end

---@param mx number
---@param my number
---@param pole number|PoleStruct
---@return boolean
function grid_mt:needs_power(mx, my, pole)
	local nx1, nx2, ny1, ny2
	if type(pole) == "table" then
		local size = pole.size
		local extent = ceil((pole.supply_width-size) / 2)
		nx1, nx2 = mx - extent, mx + extent
		ny1, ny2 = my - extent, my + extent
	else
		nx1, nx2 = mx, mx+pole-1
		ny1, ny2 = my, my+pole-1
	end

	for y = ny1, ny2 do
		local row = self[y]
		if row == nil then goto continue_row end
		for x = nx1, nx2 do
			---@type GridTile
			local tile = row[x]
			if tile and need_electricity[tile.built_on] then
				return true
			end
		end
		::continue_row::
	end
	return false
end

return grid_mt

local mpp_util = require("mpp_util")

---@class GridRow: GridTile[]

---@class Grid
---@field miner MinerStruct
local grid_mt = {}
grid_mt.__index = grid_mt

---@class Coords
---@field x1 double Top left corner
---@field y1 double Top left corner
---@field x2 double Bottom right corner
---@field y2 double Bottom right corner
---@field ix1 number Integer top left corner
---@field iy1 number Integer top left corner
---@field ix2 number Integer bottom right corner
---@field iy2 number Integer bottom right corner
---@field w integer Width
---@field h integer Height
---@field tw integer Width Rotation invariant width
---@field th integer Height Rotation invariant height
---@field gx double x1 but -1 for grid rendering
---@field gy double y1 but -1 for grid rendering
---@field extent_x1 number Internal grid dimensions
---@field extent_y1 number Internal grid dimensions
---@field extent_x2 number Internal grid dimensions
---@field extent_y2 number Internal grid dimensions

---@class GridTile
---@field amount number Amount of resource on tile
---@field neighbor_count integer
---@field neighbor_counts table<number, number>
---@field far_neighbor_count integer
---@field x integer
---@field y integer
---@field gx double actual coordinate in surface
---@field gy double actual coordinate in surface
---@field boolean integer Is a miner consuming this tile
---@field built_on boolean|string Is tile occupied by a building entity

---@class Miner
---@field tile GridTile
---@field center GridTile Center tile
---@field line integer -- Line index of the miner
---@field unconsumed integer

---comment
---@param x integer Grid coordinate
---@param y integer Grid coordinate
---@return GridTile|nil
function grid_mt:get_tile(x, y)
	local row = self[y]
	if row then return row[x] end
end

---Convolves a resource patch reach using characteristics of a miner
---@param x integer coordinate of the resource patch
---@param y integer coordinate of the resource patch
function grid_mt:convolve(x, y)
	local near, far = self.miner.near, self.miner.far
	local ny1, ny2 = y-near, y+near
	local nx1, nx2 = x-near, x+near
	for sy = y-far, y+far do
		local row = self[sy]
		if row == nil then goto continue_row end
		for sx = x-far, x+far do
			local tile = row[sx]
			if tile == nil then goto continue_column end

			tile.far_neighbor_count = tile.far_neighbor_count + 1
			if nx1 <= sx and sx <= nx2 and ny1 <= sy and sy <= ny2 then
				tile.neighbor_count = tile.neighbor_count + 1
			end
			::continue_column::
		end
		::continue_row::
	end
end

function grid_mt:convolve_custom(x, y, w)
	for sy = y-w, y+w do
		local row = self[sy]
		if row == nil then goto continue_row end
		for sx = x-w, x+w do
			local tile = row[sx]
			if tile == nil then goto continue_column end
			tile.neighbor_counts[w] = (tile.neighbor_counts[w] or 0) + 1
			::continue_column::
		end
		::continue_row::
	end
end

---Marks tiles as consumed by a miner
---@param cx integer
---@param cy integer
function grid_mt:consume(cx, cy)
	local mc = self.miner
	local far = mc.far
	for y = cy-far, cy+far do
		local row = self[y]
		if row == nil then goto continue_row end
		for x = cx-far, cx+far do
			local tile = row[x]
			if tile and tile.amount then
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
	for _, tile in ipairs(tiles) do
		tile.consumed = false
	end
end

---Builder function
---@param cx number x coord
---@param cy number y coord
---@param thing string Type of building
---@param r number Radius
---@param even boolean Is even width building
function grid_mt:build_thing(cx, cy, thing, r, even)
	local o = even and 1 or 0
	for y = cy+o-r, cy+r do
		local row = self[y]
		if row == nil then goto continue_row end
		for x = cx+o-r, cx+r do
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
---@param thing string Type of building
---@param r number Radius
---@param even boolean Is even width building
---@return boolean
function grid_mt:find_thing(cx, cy, thing, r, even)
	local o = even and 1 or 0
	for y = cy+o-r, cy+r do
		local row = self[y]
		if row == nil then goto continue_row end
		for x = cx+o-r, cx+r do
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

function grid_mt:build_miner(cx, cy)
	local near = self.miner.near
	for y = cy-near, cy+near do
		local row = self[y]
		if row == nil then goto continue_row end
		for x = cx-near, cx+near do
			local tile = row[x]
			if tile then
				tile.built_on = "miner"
			end
		end
		::continue_row::
	end
end

function grid_mt:build_miner_custom(cx, cy, w)
	for y = cy-w, cy+w do
		local row = self[y]
		if row == nil then goto continue_row end
		for x = cx-w, cx+w do
			local tile = row[x]
			if tile then
				tile.built_on = "miner"
			end
		end
		::continue_row::
	end
end

function grid_mt:get_unconsumed(mx, my)
	local far = self.miner.far
	local count = 0
	for y = my-far, my+far do
		local row = self[y]
		if row == nil then goto continue_row end
		for x = mx-far, mx+far do
			local tile = row[x]
			if tile then
				if tile.amount and not tile.consumed then
					count = count + 1
				end
			end
		end
		::continue_row::
	end
	return count
end

function grid_mt:get_unconsumed_custom(mx, my, w)
	local count = 0
	for y = my-w, my+w do
		local row = self[y]
		if row == nil then goto continue_row end
		for x = mx-w, mx+w do
			local tile = row[x]
			if tile then
				if tile.amount and not tile.consumed then
					count = count + 1
				end
			end
		end
		::continue_row::
	end
	return count
end

return grid_mt

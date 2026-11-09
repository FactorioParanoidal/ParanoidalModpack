local metadata_lib = require("lib.core.metadata")
local bbox_lib = require("lib.core.math.bbox")

local bbox_new = bbox_lib.bbox_new

local lib = {}

---@alias Core.BlueprintGeometryParityTable table<defines.direction, [0|1, 0|1]>

---@type Core.BlueprintGeometryParityTable
local curved_rail_a_parity_table = {
	[0] = { 1, 0 },
	[2] = { 1, 0 },
	[4] = { 0, 1 },
	[6] = { 0, 1 },
	[8] = { 1, 0 },
	[10] = { 1, 0 },
	[12] = { 0, 1 },
	[14] = { 0, 1 },
}

---@type Core.BlueprintGeometryParityTable
local straight_rail_parity_table = {
	[0] = { 1, 1 },
	[2] = { 0, 0 },
	[4] = { 1, 1 },
	[6] = { 0, 0 },
	[8] = { 1, 1 },
	[10] = { 0, 0 },
	[12] = { 1, 1 },
	[14] = { 0, 0 },
}

---@type Core.BlueprintGeometryParityTable
local even_parity_table = {
	[0] = { 0, 0 },
	[2] = { 0, 0 },
	[4] = { 0, 0 },
	[6] = { 0, 0 },
	[8] = { 0, 0 },
	[10] = { 0, 0 },
	[12] = { 0, 0 },
	[14] = { 0, 0 },
}

---@type table<string, Core.BlueprintGeometryParityTable>
local parity_by_type = {
	["straight-rail"] = straight_rail_parity_table,
	["curved-rail-a"] = curved_rail_a_parity_table,
	["elevated-straight-rail"] = straight_rail_parity_table,
	["elevated-curved-rail-a"] = curved_rail_a_parity_table,
	["cargo-landing-pad"] = even_parity_table,
	["cargo-bay"] = even_parity_table,
}

---@class Core.BlueprintGeometryPrototypeInfo
---@field public name string
---@field public type string
---@field public collision_box BoundingBox
---@field public tile_width number
---@field public tile_height number
---@field public bbox BoundingBox
---@field public build_grid_size number
---@field public parity_table? Core.BlueprintGeometryParityTable If given, parity must be looked up per direction. If not given, parity is oddxodd for all directions. Never given unless build_Grid_size is 2.
---@field public global_center? boolean If true, this entity must be positioned at the global center (0,0) at worldspace. Only true for space platform hubs currently.

---@type table<string, Core.BlueprintGeometryPrototypeInfo>
local _cache = {}

---@param name string
---@return Core.BlueprintGeometryPrototypeInfo
local function get_prototype_geometry(name)
	local info = _cache[name]
	if not info then
		local eproto = prototypes.entity[name]
		local type = eproto.type
		local collision_box = bbox_new(eproto.collision_box)
		local tile_width = eproto.tile_width
		local tile_height = eproto.tile_height
		local bbox
		if eproto.has_flag("placeable-off-grid") then
			bbox = collision_box
		else
			bbox = bbox_new(
				-tile_width / 2,
				-tile_height / 2,
				tile_width / 2,
				tile_height / 2
			)
		end

		info = {
			name = eproto.name,
			type = type,
			collision_box = collision_box,
			bbox = bbox,
			tile_width = tile_width,
			tile_height = tile_height,
			build_grid_size = metadata_lib.build_grid_2_types[type] and 2 or 1,
			parity_table = parity_by_type[type],
			global_center = (type == "space-platform-hub"),
		}
		_cache[name] = info
	end
	return info
end
lib.get_prototype_geometry = get_prototype_geometry

return lib

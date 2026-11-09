local oclass = require("lib.core.orientation.orientation-class")
local dihedral = require("lib.core.math.dihedral")
local pos_lib = require("lib.core.math.pos")
local tlib = require("lib.core.table")

local pos_get = pos_lib.pos_get
local pos_add = pos_lib.pos_add
local OC = oclass.OrientationClass
local OrientationContext = oclass.OrientationContext
local props = oclass.class_properties
local floor = math.floor
local pairs = _G.pairs
local bextract = bit32.extract
local breplace = bit32.replace
local dih_encode = dihedral.encode
local dih_decode = dihedral.decode
local dih_product = dihedral.product
local NORTH = defines.direction.north
local EAST = defines.direction.east
local WEST = defines.direction.west
local EMPTY = tlib.EMPTY_STRICT
local get_orientation_class_for_entity = oclass.get_orientation_class_for_entity
local get_class_properties = oclass.get_class_properties

local lib = {}

---Information given about the orientation of a blueprint when being placed.
---This matches e.g. the `on_pre_build` event data.
---@alias Core.BlueprintOrientationData {position: MapPosition, direction: defines.direction, flip_horizontal?: boolean, flip_vertical?: boolean}

---Bitwise encoded orientation. The lower 17 bits encode the dihedral
---group element for this orientation; the next 8 bits encode the orientation
---class number.
---@alias Core.Orientation int32

---@param class Core.OrientationClass
---@param dih Core.Dihedral
---@return Core.Orientation
local function encode(class, dih)
	local x = breplace(0, dih, 0, 17) --[[@as int]]
	return breplace(x, class, 17, 8) --[[@as Core.Orientation]]
end

---@param class Core.OrientationClass
---@param order int32
---@param r int32
---@param s 0|1
---@return Core.Orientation
local function encode_wide(class, order, r, s)
	return encode(class, dih_encode(order, r, s))
end
lib.encode_wide = encode_wide

---@param orientation Core.Orientation
---@return Core.OrientationClass
---@return Core.Dihedral
local function decode(orientation)
	local dih = bextract(orientation, 0, 17)
	local class = bextract(orientation, 17, 8)
	return class, dih
end

---@param orientation Core.Orientation
---@return Core.OrientationClass
---@return int32
---@return int32
---@return 0|1
local function decode_wide(orientation)
	local class, dih = decode(orientation)
	local order, r, s = dih_decode(dih)
	return class, order, r, s
end
lib.decode_wide = decode_wide

---Get direction and mirroring values from an exploded orientation.
---@param oc Core.OrientationClass
---@param order int32
---@param r int32
---@param s 0|1
---@return defines.direction
---@return boolean?
local function get_dm_wide(oc, order, r, s)
	local mirroring = nil
	local pr = props[oc] or EMPTY
	local can_mirror = pr.can_mirror
	if can_mirror then mirroring = (s == 1) end
	if order == 0 then
		return NORTH, mirroring
	elseif order == 1 then
		return (s == 0 and NORTH or EAST), mirroring
	elseif order == 4 then
		local dir = (r * 4) --[[@as defines.direction]]
		return dir, mirroring
	elseif order == 8 then
		-- TODO: implement non-mirrored flips
		local dir = (r * 2) --[[@as defines.direction]]
		return dir, mirroring
	end
	return NORTH, mirroring
end

---Create an empty orientation
---@param class Core.OrientationClass
---@return Core.Orientation
function lib.create(class)
	return encode_wide(class, props[class].dihedral_r_order, 0, 0)
end

---Get the `OrientationClass` of this orientation.
---@param orientation Core.Orientation
---@return Core.OrientationClass
function lib.get_class(orientation) return bextract(orientation, 17, 8) end

---Get the Factorio direction corresponding to this orientation.
---@param orientation Core.Orientation
---@return defines.direction
local function get_direction(orientation)
	local dir = get_dm_wide(decode_wide(orientation))
	return dir
end
lib.get_direction = get_direction

---Create an Orientation from (class, direction, mirroring) data
---@param oc Core.OrientationClass
---@param direction defines.direction
---@param mirroring boolean?
function lib.from_cdm(oc, direction, mirroring)
	local order = props[oc].dihedral_r_order
	local r, s = 0, 0
	if order == 0 then
		-- No-op
	elseif order == 1 then
		s = direction ~= NORTH and 1 or 0
	elseif order == 4 then
		r = floor(direction / 4) % 4
		if props[oc].can_mirror then s = mirroring and 1 or 0 end
	elseif order == 8 then
		r = floor(direction / 2) % 8
		if props[oc].can_mirror then s = mirroring and 1 or 0 end
	end
	return encode_wide(oc, order --[[@as int]], r, s)
end

---Convert an orientation to (class, direction, mirroring) data
---@param orientation Core.Orientation
---@return Core.OrientationClass class
---@return defines.direction direction
---@return boolean? mirroring
function lib.to_cdm(orientation)
	local oc, order, r, s = decode_wide(orientation)
	local direction, mirroring = get_dm_wide(oc, order, r, s)
	return oc, direction, mirroring
end

---Compare two orientations for equality. This is strict (class must match
---as well as dihedral element)
---@param a Core.Orientation
---@param b Core.Orientation
---@return boolean
function lib.eq(a, b) return a == b end

---Compare two orientations for loose equality. This is true if the direction
---and mirroring (if supported by both) is the same between them, regardless
---of class.
---@param a Core.Orientation|nil
---@param b Core.Orientation|nil
---@return boolean
function lib.loose_eq(a, b)
	if a == b then return true end
	if a == nil or b == nil then return false end
	local ad, am = get_dm_wide(decode_wide(a))
	local bd, bm = get_dm_wide(decode_wide(b))
	if ad ~= bd then return false end
	if am ~= nil and bm ~= nil then
		if am ~= bm then return false end
	end
	return true
end

---Get a transform corresponding to rotating an entity with the given
---orientation clockwise in a given context.
---If `nil`, the operation cannot be performed in that context.
---@param orientation Core.Orientation
---@param context Core.OrientationContext
---@return Core.Dihedral|nil
function lib.R(orientation, context)
	local oc = decode(orientation)
	local pr = props[oc] or EMPTY
	if context == OrientationContext.Blueprint then
		return pr.R_blueprint or pr.R_hand or pr.R_world or dih_encode(4, 1, 0)
	elseif context == OrientationContext.Cursor then
		return pr.R_hand
	elseif context == OrientationContext.World then
		return pr.R_world
	else
		return nil
	end
end

---Get a transform corresponding to rotating an entity with the given
---orientation CCW in a given context.
---If `nil`, the operation cannot be performed in that context.
---@param orientation Core.Orientation
---@param context Core.OrientationContext
---@return Core.Dihedral|nil
function lib.Rinv(orientation, context)
	local oc = decode(orientation)
	local pr = props[oc] or EMPTY
	if context == OrientationContext.Blueprint then
		return pr.Rinv_blueprint
			or pr.Rinv_hand
			or pr.Rinv_world
			or dih_encode(4, 3, 0)
	elseif context == OrientationContext.Cursor then
		return pr.Rinv_hand
	elseif context == OrientationContext.World then
		return pr.Rinv_world
	else
		return nil
	end
end

---Get a transform corresponding to H-flipping an entity with the given
---orientation in a given context.
---If `nil`, the operation cannot be performed in that context.
---@param orientation Core.Orientation
---@param context Core.OrientationContext
---@return Core.Dihedral|nil
function lib.H(orientation, context)
	local oc = decode(orientation)
	local pr = props[oc] or EMPTY
	if context == OrientationContext.Blueprint then
		return pr.H_blueprint or pr.H_hand or pr.H_world or dih_encode(4, 0, 1)
	elseif context == OrientationContext.Cursor then
		return pr.H_hand
	elseif context == OrientationContext.World then
		return pr.H_world
	else
		return nil
	end
end

---Get a transform corresponding to V-flipping an entity with the given
---orientation in a given context.
---If `nil`, the operation cannot be performed in that context.
---@param orientation Core.Orientation
---@param context Core.OrientationContext
---@return Core.Dihedral|nil
function lib.V(orientation, context)
	local oc = decode(orientation)
	local pr = props[oc] or EMPTY
	if context == OrientationContext.Blueprint then
		return pr.V_blueprint or pr.V_hand or pr.V_world or dih_encode(4, 2, 1)
	elseif context == OrientationContext.Cursor then
		return pr.V_hand
	elseif context == OrientationContext.World then
		return pr.V_world
	else
		return nil
	end
end

---Appply a dihedral transform to this orientation, returning the new one.
---The transform should be `self:R(context)`, `self:H(context)`, `self:V(context)`, or a product thereof.
---@param O Core.Orientation
---@param transform Core.Dihedral
---@return Core.Orientation
function lib.apply(O, transform)
	local class, dih = decode(O)
	return encode(class, dih_product(transform, dih))
end

---Apply a blueprint D8 transform to this orientation
---@param O Core.Orientation Orientation to transform.
---@param index 0|1|2|3|4|5|6|7 The index of the D8 transform to apply.
---@return Core.Orientation
function lib.apply_blueprint(O, index)
	local class, dih = decode(O)
	-- False positive; blueprint_transforms are generated by a function that runs at top of control
	---@diagnostic disable-next-line: need-check-nil
	local transform = props[class].blueprint_transforms[index] --[[@as Core.Dihedral]]
	return encode(class, dih_product(transform, dih))
end

---Extract the orientation of an entity or ghost.
---@param entity LuaEntity A *valid* entity or ghost
---@return Core.Orientation?
function lib.extract(entity)
	local oc = get_orientation_class_for_entity(entity)
	if not oc then return nil end
	return lib.from_cdm(oc, entity.direction, entity.mirroring)
end

---Extract the orientation of a blueprint entity.
---@param bp_entity BlueprintEntity
---@return Core.Orientation
function lib.extract_bp(bp_entity)
	-- EmmyLua false positive: coercion of string enum to string
	local oc =
		oclass.get_orientation_class_by_name(bp_entity.name --[[@as string]])
	if not oc then return encode_wide(OC.Unknown, 0, 0, 0) end
	return lib.from_cdm(oc, bp_entity.direction or NORTH, bp_entity.mirror)
end

---Impose the orientation on the given entity or ghost by setting its direction
---and mirroring.
---@param orientation Core.Orientation
---@param entity LuaEntity A *valid* entity or ghost of this orientation's class
function lib.impose(orientation, entity)
	local eoc = get_orientation_class_for_entity(entity)
	local eoc_props = get_class_properties(eoc)
	local oc, order, r, s = decode_wide(orientation)
	if order ~= eoc_props.dihedral_r_order then
		error(
			"lib.orientation.impose: Orientation dihedral order "
				.. order
				.. " does not match entity orientation class dihedral order "
				.. eoc_props.dihedral_r_order
		)
	end
	local direction, mirroring = get_dm_wide(eoc, order, r, s)
	entity.direction = direction
	if mirroring ~= nil then entity.mirroring = mirroring end
end

---Transform a vector from a null orientation (north = -Y, east = +X) to this orientation.
---@param orientation Core.Orientation
---@param vec MapPosition
---@return MapPosition
function lib.transform_vector(orientation, vec)
	-- TODO: this is wrong. consider group order and mirroring property
	local _, _, r, s = decode_wide(orientation)
	local x, y = pos_get(vec)
	if s == 1 then x = -x end
	if r == 0 then
		return { x, y }
	elseif r == 1 then
		return { -y, x }
	elseif r == 2 then
		return { -x, -y }
	elseif r == 3 then
		return { y, -x }
	else
		error("Invalid orientation state")
	end
end

---Get the dihedral transformation corresponding to the given blueprint orientation data.
---@param blueprint_orientation Core.BlueprintOrientationData
---@return 0|1|2|3|4|5|6|7 i Index of the transform in the D8 dihedral group.
function lib.get_blueprint_transform_index(blueprint_orientation)
	local v_r2 = blueprint_orientation.flip_vertical and 2 or 0
	local v_s = blueprint_orientation.flip_vertical and 1 or 0
	local h_s = blueprint_orientation.flip_horizontal and 1 or 0
	local order, r, s = dihedral.exploded_product(
		4,
		floor(blueprint_orientation.direction / 4),
		h_s,
		4,
		v_r2,
		v_s
	)
	return dihedral.index(order, r, s)
end

---Given a blueprint transform index, return: (1) the unit vector of bpspace
---X in world space, (2) the unit vector of bpspace Y in world space, and (3)
---the point of a square to which the top-left corner would be mapped.
---@param index 0|1|2|3|4|5|6|7
---@return MapPosition bpspace_x_in_world
---@return MapPosition bpspace_y_in_world
---@return 0|1|2|3 top_left_corner_in_world
function lib.get_blueprint_transform_axes(index)
	if index == 0 then
		return { 1, 0 }, { 0, 1 }, 0
	elseif index == 1 then
		return { 0, 1 }, { -1, 0 }, 1
	elseif index == 2 then
		return { -1, 0 }, { 0, -1 }, 2
	elseif index == 3 then
		return { 0, -1 }, { 1, 0 }, 3
	elseif index == 4 then
		return { -1, 0 }, { 0, 1 }, 1
	elseif index == 5 then
		return { 0, -1 }, { -1, 0 }, 2
	elseif index == 6 then
		return { 1, 0 }, { 0, -1 }, 3
	elseif index == 7 then
		return { 0, 1 }, { 1, 0 }, 0
	else
		error("Invalid blueprint transform index: " .. index)
	end
end

---Stringify an orientation for debugging.
---@param orientation Core.Orientation?
---@return string
function lib.stringify(orientation)
	if not orientation then return "O(nil)" end
	local oc, direction, mirroring = lib.to_cdm(orientation)
	return string.format(
		"O(%s,%d%s)",
		-- EmmyLua false positive
		---@diagnostic disable-next-line: undefined-field
		OC[oc] or "!!UNKNOWN!!",
		direction,
		mirroring ~= nil and (mirroring and "M" or "") or ""
	)
end

---Determine if rotation from one direction to another is clockwise.
---@param dir_from defines.direction
---@param dir_to defines.direction
---@return boolean
function lib.is_direction_clockwise(dir_from, dir_to)
	local cw_dir = math.abs((dir_to - dir_from) % 16)
	local ccw_dir = math.abs((dir_from - dir_to) % 16)
	return cw_dir <= ccw_dir
end

---Given a parent position and orientation, together with an offset in the parent's local space, get the offset in world space.
---@param parent_pos MapPosition
---@param parent_orientation Core.Orientation?
---@param offset MapPosition
---@return MapPosition transformed_offset
function lib.transform_offset(parent_pos, parent_orientation, offset)
	if parent_orientation then
		offset = lib.transform_vector(parent_orientation, offset)
	end
	local offset_x, offset_y = pos_get(offset)
	local parent_x, parent_y = pos_get(parent_pos)
	return { parent_x + offset_x, parent_y + offset_y }
end

return lib

--------------------------------------------------------------------------------
-- BLUEPRINT ENTITY BOUNDING BOXES
--------------------------------------------------------------------------------

local lib = {}

local pos_lib = require("lib.core.math.pos")
local bbox_lib = require("lib.core.math.bbox")
local num_lib = require("lib.core.math.numeric")
local bp_proto_lib = require("lib.core.blueprint.proto")

local get_prototype_geometry = bp_proto_lib.get_prototype_geometry
local pos_get = pos_lib.pos_get
local bbox_new = bbox_lib.bbox_new
local bbox_get = bbox_lib.bbox_get
local bbox_set = bbox_lib.bbox_set
local bbox_rotate_ortho = bbox_lib.bbox_rotate_ortho
local bbox_translate = bbox_lib.bbox_translate
local bbox_union = bbox_lib.bbox_union
local bbox_add_point = bbox_lib.bbox_add_point
local floor = math.floor
local floor_approx = num_lib.floor_approx
local ceil_approx = num_lib.ceil_approx
local floor_tile = num_lib.floor_tile
local ZERO = { 0, 0 }

---Compute the bounding box of a blueprint entity in blueprint space.
---@param bp_entity BlueprintEntity
---@return BoundingBox
function lib.get_blueprint_entity_bbox(bp_entity)
	-- XXX: TYPES: FMTK string union bug
	---@diagnostic disable-next-line: param-type-mismatch
	local eproto = get_prototype_geometry(bp_entity.name)
	local direction = bp_entity.direction or 0
	local ebox = bbox_new(eproto.bbox)
	bbox_rotate_ortho(ebox, ZERO, floor(direction / 4))
	bbox_translate(ebox, 1, bp_entity.position)
	return ebox
end

---Get the net bounding box of an entire set of BP entities. Also locates an
---entity within the blueprint that will cause implied snapping for relative
---placement, if any.
---@deprecated Use `BlueprintGeometry` instead.
---@param bp_entities BlueprintEntity[] A *nonempty* set of blueprint entities.
---@param entity_bounding_boxes? BoundingBox[] If provided, will be filled with the bounding boxes of each entity by index. NOTE: this may not be a strict array (i.e. some indices may be nil) if some entities are ignored.
---@return BoundingBox bbox The bounding box of the blueprint in blueprint space
---@return uint? snap_index The index of the entity that causes implied snapping, if any.
---@return BoundingBox pos_bbox The bounding box encompassing the positions of the BP entities, without regard to their individual bounding boxes.
function lib.get_blueprint_bbox(bp_entities, entity_bounding_boxes)
	local snap_index = nil

	local e1 = bp_entities[1] --[[@as BlueprintEntity]]
	local e1x, e1y = pos_get(e1.position)
	-- XXX: TYPES: FMTK vector types bug
	---@diagnostic disable-next-line: missing-fields
	---@type BoundingBox
	local bpspace_bbox = { { e1x, e1y }, { e1x, e1y } }
	-- XXX: TYPES: FMTK vector types bug
	---@diagnostic disable-next-line: missing-fields
	---@type BoundingBox
	local pos_bbox = { { e1x, e1y }, { e1x, e1y } }

	for i = 1, #bp_entities do
		local bp_entity = bp_entities[i]
		local edir = bp_entity.direction or 0
		local ename = bp_entity.name
		-- XXX: TYPES: FMTK string union bug
		---@diagnostic disable-next-line: param-type-mismatch
		local eproto = get_prototype_geometry(ename)

		-- Detect entities which cause implied snapping of the blueprint.
		if snap_index == nil and eproto.build_grid_size == 2 then snap_index = i end

		-- Get bbox for entity and union it with existing bbox.
		local ebox = bbox_new(eproto.bbox)
		-- TODO: this probably doesn't work for railgun turrets/D16 ents
		bbox_rotate_ortho(ebox, ZERO, floor(edir / 4))
		bbox_translate(ebox, 1, bp_entity.position)
		if entity_bounding_boxes then entity_bounding_boxes[i] = ebox end
		bbox_union(bpspace_bbox, ebox)

		-- Update posbox to contain the entity's position.
		bbox_add_point(pos_bbox, bp_entity.position)
	end

	-- NEW ROUNDING
	-- Round to entity bbox
	local l, t, r, b = bbox_get(bpspace_bbox)
	bbox_set(
		bpspace_bbox,
		floor_approx(l),
		floor_approx(t),
		ceil_approx(r),
		ceil_approx(b)
	)

	-- Then round to tile-floor of position bbox if needed. This picks up
	-- cases where sub-entities positioned off tile centers extend the effective
	-- bounding box.
	l, t, r, b = bbox_get(pos_bbox)
	bbox_set(pos_bbox, floor_tile(l), floor_tile(t), floor_tile(r), floor_tile(b))
	bbox_union(bpspace_bbox, pos_bbox)

	return bpspace_bbox, snap_index, pos_bbox
end

return lib

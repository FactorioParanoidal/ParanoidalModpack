local class = require("lib.core.class").class
local pos_lib = require("lib.core.math.pos")
local bbox_lib = require("lib.core.math.bbox")
local proto_lib = require("lib.core.blueprint.proto")
local num_lib = require("lib.core.math.numeric")
local snap_lib = require("lib.core.blueprint.snap")
local strace = require("lib.core.strace")
local orientation_lib = require("lib.core.orientation.orientation")

local ipairs = ipairs
local pos_get = pos_lib.pos_get
local pos_new = pos_lib.pos_new
local pos_add = pos_lib.pos_add
local pos_blueprint_transform = pos_lib.pos_blueprint_transform
local bbox_get = bbox_lib.bbox_get
local bbox_set = bbox_lib.bbox_set
local bbox_new = bbox_lib.bbox_new
local bbox_flip_horiz = bbox_lib.bbox_flip_horiz
local bbox_flip_vert = bbox_lib.bbox_flip_vert
local bbox_rotate_ortho = bbox_lib.bbox_rotate_ortho
local bbox_translate = bbox_lib.bbox_translate
local bbox_union = bbox_lib.bbox_union
local bbox_add_point = bbox_lib.bbox_add_point
local floor = math.floor
local floor_approx = num_lib.floor_approx
local ceil_approx = num_lib.ceil_approx
local floor_tile = num_lib.floor_tile
local pos_set_center = bbox_lib.pos_set_center
local ZERO = { 0, 0 }

local lib = {}

---@class Core.BlueprintEntityGeometry
---@field public entity_number uint32
---@field public name string
---@field public position MapPosition Pos in bpspace, before any transforms are applied.
---@field public direction defines.direction Direction in bpspace, before any transforms are applied.
---@field public bpspace_bbox? BoundingBox
---@field public world_pos? MapPosition Pos in worldspace, after transforms are applied.

---@class Core.BlueprintGeometry
---@field public entities Core.BlueprintEntityGeometry[]
---@field public direction? defines.direction
---@field public flip_horizontal? boolean
---@field public flip_vertical? boolean
---@field public transform_index? 0|1|2|3|4|5|6|7 D8 group index of the transform applied to the blueprint.
---@field public rot_n? 0|1|2|3 Number of 90 degree CW rotations equivalent to the direction.
---@field public bpspace_bbox? BoundingBox
---@field public bpspace_center? MapPosition
---@field public snap_grid? TilePosition Global Grid to snap to.
---@field public snap_offset? TilePosition Offset from snap grid.
---@field public snap_type "relative-1x1"|"relative-2x2"|"absolute"|"fixed"
---@field public snap_entity_index? uint32
---@field public placement_bbox? BoundingBox The computed placement bbox after transforms and snapping.
---@field public placement_center? MapPosition The computed placement center after transforms and snapping.
---@field public debug_render_surface? LuaSurface If given, render debug info to this surface when calculating geometry.
local BlueprintGeometry = class("Core.BlueprintGeometry")
lib.BlueprintGeometry = BlueprintGeometry

---@param bp_entities BlueprintEntity[]
function BlueprintGeometry:new(bp_entities)
	local entities = {}
	for i, bp_entity in ipairs(bp_entities) do
		entities[i] = {
			entity_number = bp_entity.entity_number,
			name = bp_entity.name,
			position = bp_entity.position,
			direction = bp_entity.direction or 0,
		}
	end

	return setmetatable({ entities = entities, snap_type = "relative-1x1" }, self) --[[@as Core.BlueprintGeometry]]
end

---Set applied orientation of the blueprint.
---@param direction defines.direction
---@param flip_horizontal boolean?
---@param flip_vertical boolean?
function BlueprintGeometry:set_orientation(
	direction,
	flip_horizontal,
	flip_vertical
)
	self.direction = direction
	self.flip_horizontal = flip_horizontal
	self.flip_vertical = flip_vertical
	self.rot_n = floor(direction / 4)
	self.transform_index = orientation_lib.get_blueprint_transform_index({
		direction = direction,
		flip_horizontal = flip_horizontal,
		flip_vertical = flip_vertical,
	} --[[@as Core.BlueprintOrientationData]])
end

---Set absolute snapping parameters for the blueprint. This will override any relative snapping.
---@param snap_grid TilePosition?
---@param snap_offset TilePosition?
function BlueprintGeometry:set_snapping(snap_grid, snap_offset)
	self.snap_grid = snap_grid
	self.snap_offset = snap_offset
end

---Compute the bounding box of the blueprint in blueprint space, and determine
---the snapping type and snap entity, if any.
function BlueprintGeometry:compute_bbox()
	local entities = self.entities
	local e1 = entities[1] --[[@as Core.BlueprintEntityGeometry]]
	local e1x, e1y = pos_get(e1.position)
	-- XXX: TYPES: FMTK vector types bug
	---@diagnostic disable-next-line: missing-fields
	---@type BoundingBox
	local bpspace_bbox = { { e1x, e1y }, { e1x, e1y } }
	-- XXX: TYPES: FMTK vector types bug
	---@diagnostic disable-next-line: missing-fields
	---@type BoundingBox
	local pos_bbox = { { e1x, e1y }, { e1x, e1y } }

	if self.snap_grid then
		self.snap_type = "absolute"
	else
		self.snap_type = nil
	end

	-- Iterative phase: add each entity's bbox to the overall bbox
	for i = 1, #entities do
		local entity = entities[i]
		local ename = entity.name
		local epos = entity.position
		local eproto = proto_lib.get_prototype_geometry(ename)

		-- Detect entities that impact relative snapping.
		if eproto.global_center then
			self.snap_type = "fixed"
			self.snap_entity_index = i
		elseif (eproto.build_grid_size == 2) and not self.snap_type then
			self.snap_type = "relative-2x2"
			self.snap_entity_index = i
		end

		-- Generate bpspace bbox for this entity
		local ebox = bbox_new(eproto.bbox)
		-- TODO: this probably doesn't work for railgun turrets/D16 ents
		bbox_rotate_ortho(ebox, ZERO, floor(entity.direction / 4))
		bbox_translate(ebox, 1, epos)
		entity.bpspace_bbox = ebox

		-- Union this entity's bbox with the overall bbox
		bbox_union(bpspace_bbox, ebox)
		bbox_add_point(pos_bbox, epos)
	end

	if not self.snap_type then self.snap_type = "relative-1x1" end

	-- Rounding
	-- Round to entity bboxes
	local l, t, r, b = bbox_get(bpspace_bbox)
	bbox_set(
		bpspace_bbox,
		floor_approx(l),
		floor_approx(t),
		ceil_approx(r),
		ceil_approx(b)
	)

	-- Round to tile-floored pos bbox. This picks up cases where off-center sub
	-- entities extend the effective bounding box.
	l, t, r, b = bbox_get(pos_bbox)
	bbox_set(pos_bbox, floor_tile(l), floor_tile(t), floor_tile(r), floor_tile(b))
	bbox_union(bpspace_bbox, pos_bbox)

	self.bpspace_bbox = bpspace_bbox
	local l2, t2, r2, b2 = bbox_get(bpspace_bbox)
	-- XXX: TYPES: FMTK vector types bug
	---@diagnostic disable-next-line: missing-fields
	self.bpspace_center = { (l2 + r2) / 2, (t2 + b2) / 2 }
	strace.trace(
		"BPLIB: BlueprintGeometry:compute_bbox: computed bpspace_bbox",
		bpspace_bbox,
		"bpspace_center",
		self.bpspace_center,
		"snap_type",
		self.snap_type,
		"snap_entity",
		self.snap_entity_index and entities[self.snap_entity_index] or "nil"
	)
end

---Place the blueprint as if the cursor were at the given position.
---@param pos MapPosition
function BlueprintGeometry:place(pos)
	local x, y = pos_get(pos)
	local cx, cy = pos_get(self.bpspace_center --[[@as MapPosition]])
	local l, t, r, b = bbox_get(self.bpspace_bbox --[[@as BoundingBox]])
	local placement_bbox = bbox_new(self.bpspace_bbox --[[@as BoundingBox]])
	local snap_type = self.snap_type
	local rot_n = (self.rot_n or 0) --[[@as int]]

	if self.debug_render_surface then
		-- Debug: draw purple circle at placement pos
		rendering.draw_circle({
			color = { r = 1, g = 0, b = 1, a = 0.75 },
			width = 1,
			filled = true,
			target = pos,
			radius = 0.3,
			surface = self.debug_render_surface,
			time_to_live = 1800,
		})
	end

	-- Snapping
	if snap_type == "relative-1x1" or snap_type == "relative-2x2" then
		-- Relative snapping case. The center of the transformed bbox is mapped to
		-- a snapped point determined by the placement position.

		-- Map the center to zero of bpspace
		bbox_translate(placement_bbox, 1, -cx, -cy)
		-- Enact flip/rot on the bbox
		if self.flip_horizontal then bbox_flip_horiz(placement_bbox, 0) end
		if self.flip_vertical then bbox_flip_vert(placement_bbox, 0) end
		bbox_rotate_ortho(placement_bbox, ZERO, -rot_n)

		-- Snap to grid as needed
		local snap_point
		if snap_type == "relative-1x1" then
			local snapx, snapy = snap_lib.snap_1x1(placement_bbox, pos)
			snap_point = { snapx, snapy }
		else
			local snap_entity = self.entities[self.snap_entity_index or 0]
			if not snap_entity then
				error(
					"LOGIC ERROR: relative-2x2 snapping requires a snap entity, but none was found"
				)
			end
			snap_point = snap_lib.snap_2x2(
				pos,
				placement_bbox,
				snap_entity,
				self.bpspace_center or ZERO,
				rot_n,
				self.flip_horizontal,
				self.flip_vertical,
				self.debug_render_surface
			)
		end

		-- Map center of bbox to snapped point
		local sx, sy = pos_get(snap_point)
		if self.debug_render_surface then
			-- Debug: blue circle at snap point
			rendering.draw_circle({
				color = { r = 0, g = 0, b = 1, a = 0.75 },
				width = 1,
				filled = true,
				target = { sx, sy },
				radius = 0.3,
				surface = self.debug_render_surface,
				time_to_live = 1800,
			})
		end
		bbox_translate(placement_bbox, 1, sx, sy)
	elseif snap_type == "absolute" then
		-- Absolute snapping case
		-- When absolute snapping, the mouse cursor is snapped to a grid square
		-- first, then the zero of BP space is made to match the topleft of that grid square.
		local gx, gy = pos_get(self.snap_grid or ZERO)
		local ox, oy = pos_get(self.snap_offset or ZERO)
		if (rot_n % 2) == 1 then
			gx, gy = gy, gx
			ox, oy = oy, ox
		end
		local gl, gt, gr, gb =
			snap_lib.get_absolute_grid_square(x, y, gx, gy, ox, oy)

		-- Map the bbox into the new worldspace unit cell.
		-- TODO: we need mat2d...
		local bpxaxis, bpyaxis, bpcorner =
			orientation_lib.get_blueprint_transform_axes(
				self.transform_index --[[@cast -?]]
			)

		local bporigin
		if bpcorner == 0 then
			bporigin = { gl, gt }
		elseif bpcorner == 1 then
			bporigin = { gr, gt }
		elseif bpcorner == 2 then
			bporigin = { gr, gb }
		elseif bpcorner == 3 then
			bporigin = { gl, gb }
		end

		local bb_tl = pos_new(bporigin)
		pos_add(bb_tl, l, bpxaxis)
		pos_add(bb_tl, t, bpyaxis)
		local bb_l, bb_t = pos_get(bb_tl)
		local bb_br = pos_new(bporigin)
		pos_add(bb_br, r, bpxaxis)
		pos_add(bb_br, b, bpyaxis)
		local bb_r, bb_b = pos_get(bb_br)

		bbox_set(placement_bbox, bb_l, bb_t, bb_r, bb_b)

		-- Debug: draw green box around computed absolute gridsquare
		if self.debug_render_surface then
			rendering.draw_rectangle({
				color = { r = 0, g = 1, b = 0, a = 1 },
				width = 1,
				filled = false,
				left_top = { gl, gt },
				right_bottom = { gr, gb },
				surface = self.debug_render_surface,
				time_to_live = 1800,
			})
		end
	elseif snap_type == "fixed" then
		-- Given entity has to map to 0,0 worldspace. Rotation is about that centre.
		local snap_entity = self.entities[self.snap_entity_index or 0]
		if not snap_entity then
			error(
				"LOGIC ERROR: fixed snapping requires a snap entity, but none was found"
			)
		end
		-- Make the 0 of BPspace equal to the fixed entity's position.
		local fixed_pos = snap_entity.position
		bbox_translate(placement_bbox, -1, fixed_pos)
		-- Apply flip/rot about the fixed entity's position
		if self.flip_horizontal then bbox_flip_horiz(placement_bbox, 0) end
		if self.flip_vertical then bbox_flip_vert(placement_bbox, 0) end
		bbox_rotate_ortho(placement_bbox, ZERO, -rot_n)
	else
		error("LOGIC ERROR: invalid snap_type: " .. tostring(snap_type))
	end

	local placement_center = { 0, 0 }
	pos_set_center(placement_center, placement_bbox)

	if self.debug_render_surface then
		-- Debug: draw world bbox in blue
		local pl, pt, pr, pb = bbox_get(placement_bbox)
		rendering.draw_rectangle({
			color = { r = 0, g = 0, b = 1, a = 1 },
			width = 1,
			filled = false,
			left_top = { pl, pt },
			right_bottom = { pr, pb },
			surface = self.debug_render_surface,
			time_to_live = 1800,
		})
	end

	self.placement_bbox = placement_bbox
	self.placement_center = placement_center
end

function BlueprintGeometry:place_entities()
	local bp_center = self.bpspace_center --[[@as MapPosition]]
	local placement_center = self.placement_center
	if not placement_center then
		error("LOGIC ERROR: must call place() before place_entities()")
	end
	local debug_render_surface = self.debug_render_surface

	local entities = self.entities
	for i = 1, #entities do
		local entity = entities[i]
		local epos = pos_new(entity.position)
		pos_blueprint_transform(
			epos,
			bp_center,
			self.rot_n or 0,
			self.flip_horizontal,
			self.flip_vertical
		)
		pos_add(epos, 1, placement_center)
		entity.world_pos = epos
		if debug_render_surface then
			-- Debug: blue square at computed entity pos.
			-- This should overlap precisely with the green square drawn by the F4
			-- debug mode when showing entity positions.
			rendering.draw_rectangle({
				color = { r = 0, g = 0, b = 1, a = 1 },
				width = 1,
				filled = true,
				left_top = { epos[1] - 0.2, epos[2] - 0.2 },
				right_bottom = { epos[1] + 0.2, epos[2] + 0.2 },
				surface = debug_render_surface,
				time_to_live = 1800,
			})
		end
	end
end

---@return MapPosition[]
function BlueprintGeometry:get_world_positions()
	local entities = self.entities
	local world_positions = {}
	for i = 1, #entities do
		local entity = entities[i]
		world_positions[i] = entity.world_pos
	end
	return world_positions
end

return lib

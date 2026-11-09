local tlib = require("lib.core.table")
local events = require("lib.core.event")
local actual_lib = require("lib.core.blueprint.actual")
local bp_geom_lib = require("lib.core.blueprint.geometry")
local mpos_lib = require("lib.core.math.pos")
require("types")

local pairs = pairs
local next = next
local get_actual_blueprint = actual_lib.get_actual_blueprint
local pos_close = mpos_lib.pos_close

--------------------------------------------------------------------------------
-- ENTITY FILTERS
--------------------------------------------------------------------------------

local bplib_mod_data = prototypes.mod_data.bplib.data --[[@as bplib.ModData]]

local extract_entity_names =
	tlib.assign({}, bplib_mod_data.extract_entity_names)
local position_entity_names =
	tlib.assign({}, bplib_mod_data.position_entity_names)
local overlap_entity_names =
	tlib.assign({}, bplib_mod_data.overlap_entity_names)
local get_all_positions = false

--------------------------------------------------------------------------------
-- BLUEPRINT EXTRACTION
--------------------------------------------------------------------------------

events.bind(
	defines.events.on_player_setup_blueprint,
	---@param event EventData.on_player_setup_blueprint
	function(event)
		if not next(extract_entity_names) then return end

		local player = game.get_player(event.player_index)
		if not player then return end

		local bp = get_actual_blueprint(player, event.record, event.stack)
		if not bp then return end

		local bp_to_world = event.mapping.get()
		local extracted_entities = nil

		for bp_index, entity in pairs(bp_to_world) do
			if extract_entity_names[entity.name] then
				extracted_entities = extracted_entities or {}
				extracted_entities[bp_index] = entity
			end
		end

		if not extracted_entities then return end

		---@type bplib.ExtractEvent
		local extract_event = {
			player_index = event.player_index,
			blueprint = bp,
			entities = extracted_entities,
			name = "bplib-extract",
			tick = event.tick,
		}

		script.raise_event("bplib-extract", extract_event)
	end
)

--------------------------------------------------------------------------------
-- BLUEPRINT PLACEMENT/OVERLAP
--------------------------------------------------------------------------------

local STATUS_MFD = defines.entity_status.marked_for_deconstruction

events.bind(
	defines.events.on_pre_build,
	---@param event EventData.on_pre_build
	function(event)
		if
			(not next(position_entity_names)) and (not next(overlap_entity_names))
		then
			return
		end

		local player = game.get_player(event.player_index)
		if (not player) or (not player.is_cursor_blueprint()) then return end

		local bp =
			get_actual_blueprint(player, player.cursor_record, player.cursor_stack)
		if not bp then return end

		local entities = bp.get_blueprint_entities()
		if (not entities) or (#entities == 0) then return end

		-- Check for relevant entities
		local position_index_set = nil
		local overlap_index_set = nil
		for index, entity in pairs(entities) do
			local name = entity.name
			if position_entity_names[name] then
				position_index_set = position_index_set or {}
				position_index_set[index] = true
			end
			if overlap_entity_names[name] then
				overlap_index_set = overlap_index_set or {}
				overlap_index_set[index] = true
			end
		end
		if
			not get_all_positions
			and not position_index_set
			and not overlap_index_set
		then
			return
		end

		local surface = player.surface
		local snap = bp.blueprint_snap_to_grid
		local snap_offset = bp.blueprint_position_relative_to_grid
		local snap_absolute = bp.blueprint_absolute_snapping

		local function filter(bp_entity, index)
			return get_all_positions
				or (position_index_set and position_index_set[index])
				or (overlap_index_set and overlap_index_set[index])
		end

		local geom = bp_geom_lib.BlueprintGeometry:new(entities)
		geom:set_orientation(
			event.direction,
			event.flip_horizontal,
			event.flip_vertical
		)
		if snap_absolute then geom:set_snapping(snap, snap_offset) end
		geom:compute_bbox()
		geom:place(event.position)
		geom:place_entities()
		local bbox = geom.placement_bbox
		local bp_to_world_pos = geom:get_world_positions()

		---@type Core.BlueprintOrientationData
		local orientation_info = {
			position = event.position,
			direction = event.direction,
			flip_horizontal = event.flip_horizontal,
			flip_vertical = event.flip_vertical,
		}

		if position_index_set or get_all_positions then
			script.raise_event("bplib-positions", {
				player_index = event.player_index,
				blueprint = bp,
				bbox = bbox,
				positions = bp_to_world_pos,
				name = "bplib-positions",
				tick = event.tick,
				orientation_info = orientation_info,
				surface_index = surface.index,
				cause = event,
			})
		end

		if overlap_index_set then
			local overlaps = {}
			for index in pairs(overlap_index_set) do
				local pos = bp_to_world_pos[index]
				local entity = entities[index]
				if pos and entity then
					local bp_entity_name = entity.name
					local overlapped = tlib.filter_in_place(
						surface.find_entities_filtered({
							position = pos,
						}),
						function(e)
							return e.status ~= STATUS_MFD
								and (e.name == bp_entity_name or (e.type == "entity-ghost" and e.ghost_name == bp_entity_name))
								and pos_close(e.position, pos)
						end
					)
					local first_overlapped = overlapped[1]
					if first_overlapped then overlaps[index] = first_overlapped end
				end
			end
			if next(overlaps) then
				script.raise_event("bplib-overlaps", {
					player_index = event.player_index,
					blueprint = bp,
					bbox = bbox,
					positions = bp_to_world_pos,
					overlaps = overlaps,
					name = "bplib-overlaps",
					tick = event.tick,
					orientation_info = orientation_info,
					surface_index = surface.index,
					cause = event,
				})
			end
		end
	end
)

--------------------------------------------------------------------------------
-- DYNAMIC REGISTRATION
--------------------------------------------------------------------------------

local remote_interface = {}

---@param entity_name string Prototype name of an entity that should trigger `bplib-overlaps` events.
function remote_interface.register_overlap_entity(entity_name)
	overlap_entity_names[entity_name] = true
end

---@param entity_name string Prototype name of an entity that should trigger `bplib-positions` events.
function remote_interface.register_position_entity(entity_name)
	position_entity_names[entity_name] = true
end

---@param entity_name string Prototype name of an entity that should trigger `bplib-extract` events.
function remote_interface.register_extract_entity(entity_name)
	extract_entity_names[entity_name] = true
end

---Set bplib to compute positions for ALL entities in EVERY blueprint. It is
---highly recommended to avoid this, as it WILL cause significant CPU usage
---and muiltiplayer lag.
function remote_interface.always_compute_positions() get_all_positions = true end

remote.add_interface("bplib", remote_interface)

local floor, ceil = math.floor, math.ceil
local min, max = math.min, math.max
local table_insert = table.insert

local base = require("layouts.base")
local simple = require("layouts.simple")
local grid_mt = require("mpp.grid_mt")
local mpp_util = require("mpp.mpp_util")
local color = require("mpp.color")
local builder = require("mpp.builder")
local common   = require("layouts.common")
local compatibility = require("mpp.compatibility")
local belt_planner  = require("mpp.belt_planner")
local is_buildable_in_space = compatibility.is_buildable_in_space
local direction_coord = mpp_util.direction_coord

local EAST, NORTH, SOUTH, WEST, ROTATION = mpp_util.directions()

---@param dir defines.direction
---@return defines.direction
local function opposing(dir) return (dir + SOUTH) % ROTATION end

---@class BlueprintLayout : Layout
local layout = table.deepcopy(base)

---@class BlueprintState : SimpleState
---@field bp_w number
---@field bp_h number
---@field bp_mining_drills BlueprintEntityEx[]
---@field bp_category_map table<string, GridBuilding>
---@field attempts BpPlacementAttempt[]
---@field attempt_index number
---@field best_attempt BpPlacementAttempt
---@field best_attempt_score number Heuristic value
---@field best_attempt_index number
---@field beacons BpPlacementEnt[]
---@field builder_power_poles BpPlacementEnt[]
---@field lamps BpPlacementEnt[]
---
---@field belt_grid Grid BpBeltPiece grid
---@field all_belts table<BpBeltPiece, true>
---@field belt_exits List<{ [1]: number, [2]: number, belt: BpBeltPiece }>
---@field group_tributaries table<number, number>
---@field entity_output_locations table<number, table<number, true>> Mining drill output locations
---@field drill_output_locations BpDrillOutputLocation
---@field entity_input_locations table<number, table<number, true>> Inserter pickup spots
---@field collected_beacons List<BpPlacementEnt>
---@field collected_containers List<BpPlacementEnt> Entities that can contain items (containers/assemblers)
---@field collected_inserters List<BpPlacementEnt> Entities that transfer items (inserters/loaders)
---@field collected_recyclers List<BpPlacementEnt> Entities that have output (like recyclers)
---@field collected_pipes List<BpPlacementEnt>
---@field collected_power List<BpPlacementEnt>
---@field collected_belts List<BpPlacementEnt>
---@field collected_other List<BpPlacementEnt>
---
---@field builder_all List<GhostSpecification>
---@field builder_index number Progress index of creating entities

--- Coordinate space for the attempt
---@class BpPlacementAttempt : PlacementAttempt
---@field other_ents BpPlacementEnt[]
---@field s_ix number Current blueprint metatile x
---@field s_iy number Current blueprint metatile y
---@field s_ie number Current entity index
---@field sx number x start
---@field sy number y start
---@field cx number number of blueprint repetitions on x axis
---@field cy number number of blueprint repetitions on y axis

---@class BpPlacementEnt
---@field name string
---@field quality string
---@field ent BlueprintEntityEx
---@field type string
---@field thing GridBuilding
---@field tile GridTile Top-left tile
---@field x number Top-left tile coordinate
---@field y number Top-left tile coordinate
---@field w number Direction rotated width
---@field h number Direction rotated height
---@field origin_x number Grid-independent position for correct in-world placement
---@field origin_y number Grid-independent position for correct in-world placement
---@field direction defines.direction

---@class BpPlacementEnt.inserter : BpPlacementEnt
---@field out_x number Output coordinate in grid
---@field out_y number Output coordinate in grid
---@field in_x number Input coordinate in grid
---@field in_y number Input coordinate in grid

---@alias BpDrillOutputLocation table<number, table<number, {[defines.direction]: number}>>

layout.name = "blueprints"
layout.translation = {"", "[item=blueprint] ", {"mpp.settings_layout_choice_blueprints"}}

layout.restrictions.miner_available = false
layout.restrictions.belt_available = false
layout.restrictions.pole_available = false
layout.restrictions.lamp_available = false
layout.restrictions.coverage_tuning = true
layout.restrictions.landfill_omit_available = true
layout.restrictions.start_alignment_tuning = true
layout.restrictions.belt_planner_available = true
layout.restrictions.lane_filling_info_available = true

---Called from script.on_load
---@param self BlueprintLayout
---@param state BlueprintState
function layout:on_load(state)
	if state.grid then
		setmetatable(state.grid, grid_mt)
	end
end

---@param self BlueprintLayout
---@param state BlueprintState
function layout:validate(state)
	return base.validate(self, state)
end

---@param self BlueprintLayout
---@param state BlueprintState
function layout:initialize(state)
	state.miner = mpp_util.miner_struct(state.cache.miner_name, true)
	state.miner_choice = state.cache.miner_name
end

---@param self BlueprintLayout
---@param state BlueprintState
function layout:start(state)
	local c = state.coords
	local bp = state.cache

	bp.tw, bp.th = bp.w, bp.h
	local th, tw = c.h, c.w
	if state.direction_choice == "south" or state.direction_choice == "north" then
		th, tw = tw, th
		bp.tw, bp.th = bp.h, bp.w
	end
	c.th, c.tw = th, tw

	state.bp_mining_drills = bp:get_mining_drills()
	state.bp_category_map = bp:get_entity_categories()

	state.entity_output_locations = {}
	state.drill_output_locations = {}
	state.entity_input_locations = {}
	state.collected_beacons = List()
	state.collected_power = List()
	state.collected_belts = List()
	state.collected_inserters = List()
	state.collected_containers = List()
	state.collected_recyclers = List()
	state.collected_pipes = List()
	state.collected_other = List()

	state.builder_all = List()

	return "deconstruct_previous_ghosts"
end

layout.initialize_grid = simple.initialize_grid
layout.preprocess_grid = simple.preprocess_grid
layout.process_grid = simple.process_grid
layout.process_grid_convolution = simple.process_grid_convolution

---@param self BlueprintLayout
---@param state BlueprintState
function layout:prepare_layout_attempts(state)
	local c = state.coords
	local bp = state.cache
	---@type BpPlacementAttempt[]
	local attempts = {}
	state.attempts = attempts
	state.best_attempt_index = 1
	state.attempt_index = 1

	local function calc_slack(tw, bw, offset)
		local count = ceil((tw-offset) / (bw))
		local overrun = count * bw - tw + offset
		local start = -ceil(overrun / 2)
		local slack = overrun % 2
		return count, start, slack
	end

	local count_x, start_x, slack_x = calc_slack(c.tw, bp.w, bp.ox)
	local count_y, start_y, slack_y = calc_slack(c.th, bp.h, bp.oy)

	if state.start_choice then
		start_x, slack_x = 0, 0
	end

	attempts[1] = {
		sx = start_x, sy = start_y,
		cx = count_x, cy = count_y,
		slack_x = slack_x, slack_y = slack_y,
		miners = {}, postponed = {},
		other_ents = {},
		s_ix = 0, s_iy = 0, s_ie = 1,
	}

	--[[ debug rendering
	rendering.draw_rectangle{
		surface=state.surface,
		left_top={state.coords.ix1, state.coords.iy1},
		right_bottom={state.coords.ix1 + c.tw, state.coords.iy1 + c.th},
		filled=false, width=8, color={0, 0, 1, 1},
		players={state.player},
	}

	for iy = 0, count_y-1 do
		for ix = 0, count_x-1 do
			rendering.draw_rectangle{
				surface=state.surface,
				left_top={
					c.ix1 + start_x + bp.w * ix,
					c.iy1 + start_y + bp.h * iy,
				},
				right_bottom={
					c.ix1 + start_x + bp.w * (ix+1),
					c.iy1 + start_y + bp.h * (iy+1),
				},
				filled=false, width=2, color={0, 0.5, 1, 1},
				players={state.player},
			}
		end
	end
	--]]

	return "layout_attempts"
end

layout.layout_attempts = simple.layout_attempts
layout.layout_attempts_fallback = simple.layout_attempts_fallback


---Overridable CallbackState provider what step to continue after determining best attempt
---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState
function layout:get_post_attempts_callback(state)
	return "collect_entities"
end

function layout:_get_layout_heuristic(state)
	if state.coverage_choice then
		return common.overfill_layout_heuristic
	else
		return common.simple_layout_heuristic
	end
end

---@param self BlueprintLayout
---@param state BlueprintState
---@param attempt BpPlacementCoords
---@return BpPlacementAttempt
function layout:_placement_attempt(state, attempt)
	local grid = state.grid
	local bp = state.cache
	local M = state.miner
	local size, area = M.size, M.area
	local entities, num_ents = state.bp_mining_drills, #state.bp_mining_drills
	local sx, sy, countx, county = attempt.sx, attempt.sy, attempt.cx-1, attempt.cy-1
	local bx, by = state.coords.extent_x2 + sx, state.coords.extent_y2 + sx
	local b2x, b2y = state.coords.extent_x1 + sy, state.coords.extent_y1 + sy
	local bpw, bph = bp.w, bp.h
	local heuristic = simple._get_miner_placement_heuristic(self --[[@as SimpleLayout]], state)
	local heuristic_values = common.init_heuristic_values()

	--local debug_draw = drawing(state, true, false)

	-- debug_draw:draw_circle{
	-- 	x = 0,
	-- 	y = 0,
	-- 	color = {0, 0, 0},
	-- 	radius = 0.5,
	-- }
	
	local miners, postponed = attempt.miners, {}
	local s_ix = attempt.s_ix or 0
	local s_iy = attempt.s_iy or 0
	local s_ie = attempt.s_ie or 1
	local progress, progress_cap = 0, 100
	--local ix, iy, ie = s_ix, s_iy, s_ie
	for iy = s_iy, county do
	--while iy <= county do
		local capstone_y = iy == county
		for ix = s_ix, countx do
			--while ix <= countx do
			--for _, ent in pairs(bp.entities) do
			for ie = s_ie, num_ents do
			--while ie <= #entities do
				local ent = entities[ie]
				ie = ie + 1
				local capstone_x = ix == countx
				if (ent.capstone_y and not capstone_y) or (ent.capstone_x and not capstone_x) then
					goto skip_ent
				end

				local ent_struct = mpp_util.entity_struct(ent.name)
				local bpx = ceil(ent.position.x - ent_struct.x)
				local bpy = ceil(ent.position.y - ent_struct.y)
				local x, y = sx + ix * bpw + bpx, sy + iy * bph + bpy
				local tile = grid:get_tile(x, y)

				if not tile or M.name ~= ent.name then goto skip_ent end

				local struct = {
					ent = ent,
					tile = tile,
					x = x, y = y,
					origin_x = x + M.x,
					origin_y = y + M.y,
					line = s_iy,
					column = s_ix,
					direction = ent.direction,
					name = ent.name,
				}
				if tile.forbidden then
					-- no op
				elseif heuristic(tile) then
					miners[#miners+1] = struct
					common.add_heuristic_values(heuristic_values, M, tile)
					bx, by = min(bx, x-1), min(by, y-1)
					b2x, b2y = max(b2x, x + size - 1), max(b2y, y + size - 1)
				else
					postponed[#postponed+1] = struct
				end

				::skip_ent::
			end
			s_ie = 1
		end
		s_ix = 0
	end

	local result = {
		sx = sx,
		sy = sy,
		cx = attempt.cx,
		cy = attempt.cy,
		bx = bx,
		by = by,
		b2x = b2x,
		b2y = b2y,
		miners = miners,
		postponed = postponed,
		lane_layout = {},
		heuristics = heuristic_values,
		heuristic_score = -(0/0),
		price = 0,
	}

	common.finalize_heuristic_values(result, heuristic_values, state.coords)

	return result
end

---@param self BlueprintLayout
---@param state BlueprintState
function layout:_get_deconstruction_objects(state)
	return {
		state.builder_miners,
		state.builder_all,
		--state.builder_pipes,
		--state.builder_belts,
		--state.builder_power_poles,
		--state.builder_lamps,
	}
end

---@param self SimpleLayout
---@param state BlueprintState
---@return CallbackState
function layout:collect_entities(state)
	local grid = state.grid
	local C = state.coords
	local bp = state.cache
	local category_map = state.bp_category_map
	local attempt = state.best_attempt
	local entities, num_ents = bp.entities, #bp.entities
	local sx, sy, countx, county = attempt.sx, attempt.sy, attempt.cx-1, attempt.cy-1
	local bpw, bph = bp.w, bp.h
	local is_space = state.is_space

	--local debug_draw = drawing(state, true, false)

	local collected_beacons = state.collected_beacons
	local collected_inserters = state.collected_inserters
	local collected_power = state.collected_power
	local collected_belts = state.collected_belts
	local collected_other = state.collected_other
	local collected_containers = state.collected_containers
	local collected_recyclers = state.collected_recyclers
	local collected_pipes = state.collected_pipes

	local s_ix = attempt.s_ix or 0
	local s_iy = attempt.s_iy or 0
	local s_ie = attempt.s_ie or 1
	local progress, progress_cap = 0, 1000 * state.performance_scaling
	--local ix, iy, ie = s_ix, s_iy, s_ie
	for iy = s_iy, county do
	--while iy <= county do
		local capstone_y = iy == county
		for ix = s_ix, countx do
		--while ix <= countx do
			--for _, ent in pairs(bp.entities) do
			for ie = s_ie, num_ents do
				local ent = entities[ie]
				local ent_name = ent.name
				if is_space and not is_buildable_in_space(ent_name) then goto skip_ent end
				local ent_category = category_map[ent_name]
				ie = ie + 1
				local capstone_x = ix == countx
				if
					ent_category == "miner"
					or (ent.capstone_y and not capstone_y)
					or (ent.capstone_x and not capstone_x)
				then
					goto skip_ent
				end
				local entity_struct = mpp_util.entity_struct(ent_name)
				local rx, ry, rw, rh = mpp_util.transpose_struct(entity_struct, ent.direction)
				local bpx = ceil(ent.position.x - rx)
				local bpy = ceil(ent.position.y - ry)
				local x, y = sx + ix * bpw + bpx, sy + iy * bph + bpy
				local tile = grid:get_tile(x, y)
				if not tile then goto skip_ent end

				---@type BpPlacementEnt
				local base_collected = {
					tile = tile,
					ent = ent,
					name = ent_name,
					type = entity_struct.type,
					x = x,
					y = y,
					origin_x = x + rx,
					origin_y = y + ry,
					w = rw, h = rh,
					direction = ent.direction,
					quality = ent.quality,
				}

				if ent_category == "beacon" then
					collected_beacons:push(base_collected)
				elseif ent_category == "inserter" then
					collected_inserters:push(base_collected)
				elseif ent_category == "pole" then
					collected_power:push(base_collected)
				elseif ent_category == "belt" then
					collected_belts:push(base_collected)
				elseif ent_category == "container" then
					collected_containers:push(base_collected)
				elseif ent_category == "pipe" then
					collected_pipes:push(base_collected)
				elseif ent_category == "assembler" then
					collected_recyclers:push(base_collected)
				else
					collected_other:push(base_collected)
				end

				progress = progress + 1
				if progress > progress_cap then
					attempt.s_ix, attempt.s_iy, attempt.s_ie = ix, iy, ie
					return true
				end

				::skip_ent::
			end
			s_ie = 1
		end
		s_ix = 0
	end

	return "prepare_miner_layout"
end

local function append_transfer_location(locations, x, y)
	local output_row = locations[y]
	if output_row then
		output_row[x] = true
	else
		locations[y] = {[x] = true}
	end
end

local function append_drill_output_location(locations, x, y, direction)
	local output_row = locations[y]
	if output_row then
		local struct = output_row[x]
		if struct then
			struct[direction] = 1
		else
			output_row[x] = {[direction] = 1}
		end
	else
		locations[y] = {[x] = {[direction] = 1}}
	end
end

---@param self SimpleLayout
---@param state BlueprintState
---@return CallbackState
function layout:prepare_miner_layout(state)
	local C, M, G = state.coords, state.miner, state.grid

	local builder_miners = {}
	state.builder_miners = builder_miners

	local output_locations = state.entity_output_locations
	local drill_output_locations = state.drill_output_locations

	for _, miner in ipairs(state.best_attempt.miners) do

		G:build_miner(miner.x, miner.y, M.size-1)

		builder_miners[#builder_miners+1] = {
			thing = "miner",
			name = miner.ent.name,
			direction = miner.direction,
			grid_x = miner.origin_x,
			grid_y = miner.origin_y,
			extent_w = M.extent_w,
			extent_h = M.extent_h,
		}

		local output = M.output_rotated[miner.direction]
		-- local output = M.output_rotated[mpp_util.clamped_rotation(miner.direction, M.rotation_bump)]
		local pos_x, pos_y = miner.x + output.x, miner.y + output.y
		append_transfer_location(output_locations, pos_x, pos_y)
		append_drill_output_location(drill_output_locations, pos_x, pos_y, miner.direction)
		
		--[[ debug visualisation - mining drill placement
		local converter = mpp_util.reverter_delegate(state.coords, state.direction_choice)
		local x, y = miner.origin_x, miner.origin_y
		local off = state.miner.size / 2
		rendering.draw_rectangle{
			surface = state.surface,
			filled = false,
			color = miner.postponed and {1, 0, 0} or {0, 1, 0},
			width = 3,
			--target = {c.x1 + x, c.y1 + y},
			left_top = {C.gx+x-off, C.gy + y - off},
			right_bottom = {C.gx+x+off, C.gy + y + off},
		}
		rendering.draw_circle{
			surface = state.surface,
			target = {converter(pos_x+.5, pos_y+.5)},
			filled = false,
			color = {1, 1, 1},
			radius = 0.4, width = 6,
		}
		--]]

	end

	return "prepare_beacon_layout"
end

---@param self BlueprintLayout
---@param state BlueprintState
---@return CallbackState
function layout:prepare_beacon_layout(state)
	local c = state.coords
	local surface = state.surface
	local grid = state.grid
	local builder_all = state.builder_all

	--local debug_draw = drawing(state, true, false)

	for _, beacon in ipairs(state.collected_beacons) do
		local struct = mpp_util.beacon_struct(beacon.name)
		local x, y = beacon.x, beacon.y
		local ext = struct.extent_negative
		local found = grid:find_thing(x+ext, y+ext, "miner", struct.area-1)

		if not found then goto continue end

		grid:build_thing(x, y, "beacon", struct.w-1, struct.h-1)

		builder_all:push{
			thing = "beacon",
			name = struct.name,
			quality = beacon.quality,
			grid_x = beacon.origin_x,
			grid_y = beacon.origin_y,
			extent_w = struct.extent_w,
			extent_h = struct.extent_h,
			items = beacon.ent.items,
		}

		::continue::
	end

	return "prepare_container_layout"
end


---@param self BlueprintLayout
---@param state BlueprintState
---@return CallbackState
function layout:prepare_container_layout(state)
	local G = state.grid
	local builder_all = state.builder_all
	local output_locations = state.entity_output_locations
	local input_locations = state.entity_input_locations

	local function find_output(x1, y1, x2, y2)
		for iy = y1, y2 do
			local output_row = output_locations[iy]
			if output_row then
				for ix = x1, x2 do
					if output_row[ix] then
						return true
					end
				end
			end
		end
	end

	for _, container in ipairs(state.collected_containers) do
		local name = container.name
		local struct = mpp_util.entity_struct(name)
		local x, y = container.x, container.y

		if not find_output(x, y, x+struct.w-1, y+struct.h-1) then goto continue end

		G:build_thing(container.x, container.y, "container", struct.w-1, struct.h-1)

		builder_all:push{
			thing = "container",
			name = name,
			quality = container.quality,
			grid_x = container.origin_x,
			grid_y = container.origin_y,
			extent_w = struct.extent_w,
			extent_h = struct.extent_h,
		}

		::continue::
	end

	return "prepare_inserter_layout"
end

---@param self BlueprintLayout
---@param state BlueprintState
---@return CallbackState
function layout:prepare_inserter_layout(state)
	local G = state.grid
	local builder_all = state.builder_all
	local output_locations = state.entity_output_locations
	local input_locations = state.entity_input_locations

	--local debug_draw = drawing(state, true, false)

	for _, inserter in ipairs(state.collected_inserters) do
		local struct, out_x, out_y, in_x, in_y
		if inserter.type == "inserter" then
			struct = mpp_util.inserter_struct(inserter.name)
			local pickup, drop = mpp_util.inserter_hand_locations(inserter.ent)
			out_x = inserter.x + drop.x
			out_y = inserter.y + drop.y
			in_x = inserter.x + pickup.x
			in_y = inserter.y + pickup.y
		elseif inserter.type == "loader-1x1" then
			struct = mpp_util.entity_struct(inserter.name)
			local next_coord = direction_coord[inserter.direction]
			out_x = inserter.x + next_coord.x
			out_y = inserter.y + next_coord.y
			in_x = inserter.x - next_coord.x
			in_y = inserter.y - next_coord.y

			if inserter.ent.type == "input" then
				in_x, in_y, out_x, out_y = out_x, out_y, in_x, in_y
			end
			--debug_draw:draw_rectangle{x=inserter.x-.5,y=inserter.y-.5,w=inserter.w,h=inserter.h}
		elseif inserter.type == "loader" then
			local direction = inserter.direction
			local simple_direction = (inserter.direction) % 4
			local next_coord = direction_coord[inserter.direction % 4]

			struct = mpp_util.entity_struct(inserter.name)

			local tx1, ty1, tx2, ty2

			if simple_direction == EAST then
				tx1 = inserter.x - next_coord.x
				ty1 = inserter.y - next_coord.y
				tx2 = inserter.x + inserter.w - 1 + next_coord.x
				ty2 = inserter.y + inserter.h - 1 + next_coord.y
			else
				tx1 = inserter.x + inserter.w - 1 - next_coord.x
				ty1 = inserter.y + inserter.h - 1 - next_coord.y
				tx2 = inserter.x + next_coord.x
				ty2 = inserter.y + next_coord.y
			end

			if direction > EAST then
				tx1, ty1, tx2, ty2 = tx2, ty2, tx1, ty1
			end
			out_x, out_y, in_x, in_y = tx1, ty1, tx2, ty2
		else
			goto continue
		end

		--debug_draw:draw_circle{x = inserter.x, y = inserter.y, filled = true, radius = 0.2}
		-- output point is green
		--debug_draw:draw_circle{x = out_x, y = out_y, radius = 0.3, color = {0.2, 0.8, 0.2}}
		-- input point is blue
		--debug_draw:draw_circle{x = in_x, y = in_y, radius = 0.3, color = {0.2, 0.2, 0.8}}

		local input_tile = G:get_tile(in_x, in_y)
		local output_tile = G:get_tile(out_x, out_y)

		-- TODO: figure out a better way to determine if inserter should be placed
		if
			(not input_tile or not output_tile)
			or
			(
				input_tile
				and not (
					input_tile.built_thing == "miner"
					or input_tile.built_thing == "container"
				)
				and output_tile
				and not (
					output_tile.built_thing == "miner"
					or output_tile.built_thing == "container"
				)
			)
		then
			goto continue
		end

		append_transfer_location(output_locations, out_x, out_y)
		--debug_draw:draw_circle{radius=0.2, x=out_x, y=out_y, color={1, 1, 0}}
		append_transfer_location(input_locations, in_x, in_y)
		--debug_draw:draw_circle{radius=0.2, x=in_x, y=in_y, color={1, 0, 1}}

		builder_all:push{
			thing = "inserter",
			name = struct.name,
			quality = inserter.quality,
			grid_x = inserter.origin_x,
			grid_y = inserter.origin_y,
			direction = inserter.direction,
			extent_w = struct.extent_w,
			extent_h = struct.extent_h,
			conditions = inserter.ent.conditions, -- inserter
			use_filters = inserter.ent.use_filters, -- inserter
			filters = inserter.ent.filters, -- inserter
			filter_mode = inserter.ent.filter_mode,
			override_stack_size = inserter.ent.override_stack_size,
			drop_position=inserter.ent.drop_position,
			pickup_position=inserter.ent.pickup_position,
		}

		-- output_locations[#output_locations+1] = {
		-- 	inserter.x,-- + output.x,
		-- 	inserter.y,-- + output.y,
		-- }
		::continue::
	end

	return "prepare_electricity"
end

---@param self BlueprintLayout
---@param state BlueprintState
---@return CallbackState
function layout:prepare_electricity(state)
	local c = state.coords
	local G = state.grid
	local surface = state.surface
	local grid = state.grid
	local builder_all = state.builder_all

	for _, power_pole in ipairs(state.collected_power) do
		local struct = mpp_util.pole_struct(power_pole.name, power_pole.quality)
		local x, y = power_pole.x, power_pole.y
		local needs_power = G:needs_power(x, y, struct)

		if not needs_power then goto continue end

		grid:build_thing(x, y, "pole", struct.w-1, struct.h-1)

		builder_all:push{
			thing = "pole",
			name = struct.name,
			quality = power_pole.quality,
			grid_x = power_pole.origin_x,
			grid_y = power_pole.origin_y,
			direction = power_pole.direction,
			extent_w = struct.extent_w,
			extent_h = struct.extent_h,
		}

		::continue::
	end

	return "prepare_belt_layout_init"
end

---@class BpBeltPiece
---@field ent BlueprintEntityEx
---@field type string
---@field x number
---@field y number
---@field direction defines.direction
---@field is_underground "input"|"output"|false
---@field w number
---@field h number
---@field group_output number?
---@field group_input number?
---@field previous table<BpBeltPiece, true>
---@field next BpBeltPiece?
---@field lane1 number Drill count outputting to this lane
---@field lane2 number Drill count outputting to this lane

---@type table<string, number>
local underground_belt_length_cache = {}

---@param self BlueprintLayout
---@param state BlueprintState
---@return CallbackState
function layout:prepare_belt_layout_init(state)
	local G = state.grid
	local builder_all = state.builder_all

	--local debug_draw = drawing(state, true, false)

	if not state.collected_belts or #state.collected_belts == 0 then
		return "prepare_other"
	end

	---@type table<BpBeltPiece, true>
	local all_belts = {}
	state.all_belts = all_belts
	local belt_grid = setmetatable({}, grid_mt)
	state.belt_grid = belt_grid
	---@type table<BpBeltPiece, true>
	local belts_unvisited = {}

	local function set_piece(px, py, piece)
		local belt_row = belt_grid[py]
		if belt_row then
			belt_row[px] = piece --[[@as GridTile]]
		else
			belt_grid[py] = {[px]=piece --[[@as GridTile]] }
		end
	end

	for _, belt in ipairs(state.collected_belts) do
		local struct = mpp_util.entity_struct(belt.name)

		---@type BpBeltPiece
		local belt_piece = {
			ent = belt.ent,
			type = belt.type,
			x = belt.x, y = belt.y,
			origin_x = belt.origin_x,
			origin_y = belt.origin_y,
			w = belt.w, h = belt.h,
			direction = belt.direction,
			is_underground = belt.ent.type or false,
			group_input = nil,
			group_output = nil,
			next = nil,
			previous = {},
			extent_w = belt.w/2,
			extent_h = belt.h/2,
			lane1 = 0,
			lane2 = 0,
		}
		--all_belts[#all_belts+1] = belt_piece
		--belts_unvisited[belt_piece] = true

		if struct.type == "splitter" then
			set_piece(belt.x+belt.w-1, belt.y+belt.h-1, belt_piece)
		end
		set_piece(belt.x, belt.y, belt_piece)

	end

	return "prepare_belt_layout_forward"
end

---@param self BlueprintLayout
---@param state BlueprintState
---@return CallbackState
function layout:prepare_belt_layout_forward(state)
	local active_group_id = 1
	local belt_grid = state.belt_grid
	local all_belts = state.all_belts
	---@type table<number, number>
	local group_tributaries = {} -- mapping of belts groups feeding into larger group
	state.group_tributaries = group_tributaries
	
	---@type List<{ [1]: number, [2]: number, belt: BpBeltPiece }>
	local belt_exits = List()
	state.belt_exits = belt_exits

	---@param piece BpBeltPiece?
	---@param previous BpBeltPiece?
	local function traverse(piece, previous)
		if piece and piece.group_output then
			local other_group = piece.group_output
			local aux_tributary = group_tributaries[other_group]
			if aux_tributary then
				group_tributaries[active_group_id] = aux_tributary
			else
				group_tributaries[active_group_id] = other_group
			end
		elseif
			piece == nil
			or (previous and (piece.direction == (previous.direction+SOUTH) % ROTATION) )
		then
			if previous then
				-- rendering.draw_circle{
				-- 	surface = state.surface,
				-- 	target = {converter(previous.x+.5, previous.y+.5)},
				-- 	radius = 0.5, color = {1, 1, 1},
				-- }
				belt_exits:push{previous.x, previous.y, belt=previous}
			end
			return
		end

		--belts_unvisited[piece] = nil
		piece.group_output = active_group_id
		if previous then
			piece.previous[previous] = true
		end
		all_belts[piece] = true

		local x, y = piece.x, piece.y
		local next_pos = direction_coord[piece.direction] --[[@as BpBeltPiece]]
		local next_x, next_y = next_pos.x, next_pos.y
		local nx, ny = x+next_x, y+next_y

		if piece.type == "splitter" then
			local other_x = x + next_pos.x + piece.w - 1
			local other_y = y + next_pos.y + piece.h - 1
			traverse(
				belt_grid:get_tile(other_x, other_y) --[[@as BpBeltPiece]],
				piece
			)
			return traverse(
				belt_grid:get_tile(nx, ny) --[[@as BpBeltPiece]],
				piece
			)
		elseif piece.type == "underground-belt" and piece.is_underground == "input" then
			local underground_length = underground_belt_length_cache[piece.ent.name]
			if not underground_length then
				local proto = prototypes.entity[piece.ent.name]
				underground_length = proto.max_underground_distance or 0
				underground_belt_length_cache[piece.ent.name] = underground_length
			end

			for i = 1, underground_length do
				local next_piece = belt_grid:get_tile(x+next_x*i, y+next_y*i) --[[@as BpBeltPiece]]
				if next_piece and next_piece.is_underground == "output" and next_piece.direction == piece.direction then
					return traverse(next_piece, piece)
				end
			end
		elseif piece.type == "underground-belt" then
			local next_piece = belt_grid:get_tile(x+next_x, y+next_y) --[[@as BpBeltPiece]]
			return traverse(next_piece, piece)
		end

		return traverse(
			belt_grid:get_tile(nx, ny) --[[@as BpBeltPiece]],
			piece
		)
	end

	for y, output_row in pairs(state.entity_output_locations) do
		local belt_row = belt_grid[y]
		if not belt_row then goto continue end
		for x in pairs(output_row) do
			traverse(belt_row[x] --[[@as BpBeltPiece]])
			active_group_id = active_group_id + 1
		end
		::continue::
	end

	return "process_forward_outputs"
end

---@param self BlueprintLayout
---@param state BlueprintState
---@return CallbackState
function layout:process_forward_outputs(state)
	local group_tributaries = state.group_tributaries
	local belt_grid = state.belt_grid
	local all_belts = state.all_belts
	local belt_exits = state.belt_exits
	
	local converter = mpp_util.reverter_delegate(state.coords, state.direction_choice)
	
	if state.display_lane_filling_choice then
		for piece, _ in pairs(all_belts) do
			local tributary = group_tributaries[piece.group_output]
			if tributary then
				piece.group_output = tributary
			end
			-- local set_color = color.hue_sequence(piece.group_output)
			-- rendering.draw_circle{
			-- 	surface = state.surface,
			-- 	target = {converter(piece.x+.5, piece.y+.5)},
			-- 	radius = 0.45, color = set_color, width=4,
			-- }
		end
	end
	
	table.sort(belt_exits, function(a, b) return a[2] < b[2] end)
	
	local belt_choice = nil
	local ent_prot = prototypes.entity
	---@type table<number, BaseBeltSpecification>
	local tributary_to_belts_map = {}
	local belts = List() --[[@as List<BaseBeltSpecification>]]
	for _, coord in pairs(belt_exits) do
		local piece = coord.belt
		if not belt_choice then
			local belt = ent_prot[piece.ent.name]
			if belt.type == "transport-belt" then
				belt_choice = belt.name
				state.belt_choice = belt_choice
			end
		end
		local x, y = coord[1], coord[2]
		local belt = {
			x1 = x,
			x2 = x,
			x_start = x,
			x_entry = x,
			x_end = x,
			y = y,
			has_drills = false,
			is_output = true,
			throughput1 = 0,
			throughput2 = 0,
			merged_throughput1 = 0,
			merged_throughput2 = 0,
			lane1 = {},
			lane2 = {},
		}
		tributary_to_belts_map[piece.group_output] = belt
		-- belts:push(belt)
	end
	state.belts = belts
	
	for _, belt in pairs(tributary_to_belts_map) do
		-- deduplicate belt outputs from tributary
		belts:push(belt)
	end
	state.belt_count = #belts
	
	if belt_choice and state.display_lane_filling_choice then
		local belt_struct = mpp_util.belt_struct(belt_choice)
		state.belt = belt_struct
		local belt_speed = state.belt.speed
		local multiplier = common.get_mining_drill_production_from_state(state)
		
		for iy, row in pairs(state.drill_output_locations) do
			for ix, outputs in pairs(row) do
				local piece = belt_grid:get_tile(ix, iy) --[[@as BpBeltPiece?]]
				if not piece then goto continue end
				local belt = tributary_to_belts_map[piece.group_output --[[@as number]]]
				local l1, l2 = common.get_belt_lane_inputs(piece.direction, outputs)
				belt.throughput1 = belt.throughput1 + l1
				belt.throughput2 = belt.throughput2 + l2
				::continue::
			end
		end
		
		for _, belt in ipairs(belts) do
			belt.throughput1 = belt.throughput1 * multiplier / belt_speed
			belt.throughput2 = belt.throughput2 * multiplier / belt_speed
			belt.merged_throughput1 = belt.throughput1
			belt.merged_throughput2 = belt.throughput2
			
			if belt.throughput1 > 0 or belt.throughput2 > 0 then
				belt.has_drills = true
			end
		end
	end
	
	return "prepare_belt_layout_backward"
end

---@param self BlueprintLayout
---@param state BlueprintState
---@return CallbackState
function layout:prepare_belt_layout_backward(state)
	--local debug_draw = drawing(state, true, false)

	local active_group = 1
	local belt_grid = state.belt_grid
	local all_belts = state.all_belts

	---@class BeltTraverseBacktrack
	---@field piece BpBeltPiece
	---@field next BpBeltPiece
	---@field direction defines.direction Direction to which piece should be pointed

	local backtrack_positions = {}

	---@param piece BpBeltPiece
	---@param next BpBeltPiece? Feeding into this piece
	---@param to_direction defines.direction? Direction to which piece should point to
	local function traverse(piece, next, to_direction)
		if
			piece == nil
			or piece.group_input
			or (to_direction and (piece.direction ~= to_direction) )
		then
			return
		end
		local piece_dir = piece.direction
		local x, y = piece.x, piece.y

		piece.group_input = active_group
		if next then
			next.previous[piece] = true
		end

		all_belts[piece] = true

		--local backtrack_directions = direction_previous[piece.direction]
		if piece.type == "transport-belt" then
			local dir_side1 = (piece_dir - EAST) % ROTATION
			local side1 = direction_coord[dir_side1]
			local piece_side1 = belt_grid:get_tile(x+side1.x, y+side1.y)
			backtrack_positions[#backtrack_positions+1] = {
				piece=piece_side1,
				next=piece,
				direction=opposing(dir_side1)
			}

			local dir_side2 = (piece_dir + EAST) % ROTATION
			local side2 = direction_coord[dir_side2]
			local piece_side2 = belt_grid:get_tile(x+side2.x, y+side2.y)
			backtrack_positions[#backtrack_positions+1] = {
				piece=piece_side2,
				next=piece,
				direction=opposing(dir_side2)
			}

			local dir_straight = (piece_dir + SOUTH) % ROTATION
			local straight = direction_coord[dir_straight]
			local piece_straight = belt_grid:get_tile(x+straight.x, y+straight.y)
			return traverse(
				piece_straight --[[@as BpBeltPiece]],
				piece,
				opposing(dir_straight)
			)
		elseif piece.type == "splitter" then
			local next_pos = direction_coord[opposing(piece.direction)]

			backtrack_positions[#backtrack_positions+1] = {
				piece = belt_grid:get_tile(x + next_pos.x, y + next_pos.y),
				next = piece,
				piece.direction
			}

			return traverse(
				belt_grid:get_tile(x + next_pos.x + piece.w - 1, y + next_pos.y + piece.h - 1),
				piece,
				piece.direction
			)
		elseif piece.type == "underground-belt" then
			local next_pos = direction_coord[opposing(piece.direction)]

			local underground_length = underground_belt_length_cache[piece.ent.name]
			if not underground_length then
				local proto = prototypes.entity[piece.ent.name]
				underground_length = proto.max_underground_distance or 0
				underground_belt_length_cache[piece.ent.name] = underground_length
			end

			for i = 1, underground_length do
				local next_piece = belt_grid:get_tile(x+next_pos.x*i, y+next_pos.y*i) --[[@as BpBeltPiece]]
				if next_piece then
					return traverse(next_piece, piece)
				end
			end
		end
	end

	-- for y, output_row in pairs(state.entity_input_locations) do
	-- 	local belt_row = belt_grid[y]
	-- 	if not belt_row then goto continue end
	-- 	for x in pairs(output_row) do
	-- 		traverse(belt_row[x] --[[@as BpBeltPiece]])
	-- 	end
	-- 	::continue::
	-- end

	for y, input_row in pairs(state.entity_input_locations) do
		for x in pairs(input_row) do
			backtrack_positions[#backtrack_positions+1] = {
				piece = belt_grid:get_tile(x, y),
			}
		end
	end

	local iter, position = next(backtrack_positions)
	while iter do
		traverse(position.piece, position.next, position.direction)
		iter, position = next(backtrack_positions, iter)
	end

	return "prepare_belt_layout_finalize"
end


---@param self BlueprintLayout
---@param state BlueprintState
---@return CallbackState
function layout:prepare_belt_layout_finalize(state)
	local G = state.grid
	local builder_all = state.builder_all

	for piece in pairs(state.all_belts) do
		local bp_ent = piece.ent
		G:build_thing(piece.x, piece.y, "belt", piece.w-1, piece.h-1)
		builder_all:push{
			thing="belt",
			name = bp_ent.name,
			quality = bp_ent.quality,
			grid_x = piece.origin_x,
			grid_y = piece.origin_y,
			direction = piece.direction,
			extent_w = piece.extent_w,
			extent_h = piece.extent_h,
			type = bp_ent.type, -- underground belt
			conditions = bp_ent.conditions, -- inserter
			filters = bp_ent.filters, -- inserter
			request_filters = bp_ent.request_filters,
			input_priority=bp_ent.input_priority,
			output_priority=bp_ent.output_priority,
			filter=bp_ent.filter,
		}
	end

	return "prepare_recyclers"
end

---@param self BlueprintLayout
---@param state BlueprintState
function layout:prepare_recyclers(state)
	local G = state.grid
	local builder_all = state.builder_all

	for _, assembler in ipairs(state.collected_recyclers) do
		local name = assembler.name
		local struct = mpp_util.entity_struct(name)
		G:build_thing(assembler.x, assembler.y, "assembler", struct.w-1, struct.h-1)
		local ent = assembler.ent

		builder_all:push{
			thing = "assembler",
			name = name,
			quality = assembler.quality,
			grid_x = assembler.origin_x,
			grid_y = assembler.origin_y,
			extent_w = struct.extent_w,
			extent_h = struct.extent_h,
			direction = assembler.direction,
			items = assembler.ent.items,
			recipe = ent.recipe,
			recipe_quality = ent.recipe_quality,
			control_behavior = ent.control_behavior,
		}
	end
	
	return "prepare_pipes"
end

---@param self BlueprintLayout
---@param state BlueprintState
function layout:prepare_pipes(state)
	local G = state.grid
	local builder_all = state.builder_all

	for _, pipe in ipairs(state.collected_pipes) do
		local name = pipe.name
		local struct = mpp_util.entity_struct(name)
		G:build_thing(pipe.x, pipe.y, "pipe", struct.w-1, struct.h-1)

		builder_all:push{
			thing = "pipe",
			name = name,
			quality = pipe.quality,
			grid_x = pipe.origin_x,
			grid_y = pipe.origin_y,
			extent_w = struct.extent_w,
			extent_h = struct.extent_h,
			direction = pipe.direction,
		}
	end
	
	return "prepare_other"
end

---@param self BlueprintLayout
---@param state BlueprintState
function layout:prepare_other(state)
	local G = state.grid
	local builder_all = state.builder_all

	for _, other in ipairs(state.collected_other) do
		local name = other.name
		local struct = mpp_util.entity_struct(name)
		G:build_thing(other.x, other.y, "other", struct.w-1, struct.h-1)

		builder_all:push{
			thing = "other",
			name = name,
			quality = other.quality,
			grid_x = other.origin_x,
			grid_y = other.origin_y,
			extent_w = struct.extent_w,
			extent_h = struct.extent_h,
			direction = other.direction,
		}

		::continue::
	end

	return "expensive_deconstruct"
end

---@param self BlueprintLayout
---@param state BlueprintState
function layout:expensive_deconstruct(state)
	simple.expensive_deconstruct(self --[[@as SimpleLayout]], state)
	return "placement_miners"
end

---@param self BlueprintLayout
---@param state BlueprintState
---@return CallbackState
function layout:placement_miners(state)
	local create_entity = builder.create_entity_builder(state)

	for i, miner in ipairs(state.best_attempt.miners) do

		local ghost = create_entity{
			name = state.miner_choice,
			thing="miner",
			grid_x = miner.origin_x,
			grid_y = miner.origin_y,
			direction = miner.direction,
			quality = miner.ent.quality,
		}

		if ghost and miner.ent.items then
			ghost.insert_plan = miner.ent.items
		end
	end

	return "placement_all"
end

---@param self BlueprintLayout
---@param state BlueprintState
---@return CallbackState
function layout:placement_all(state)

	local create_entity = builder.create_entity_builder(state)

	local builder_all = state.builder_all
	local builder_index = state.builder_index or 1

	local progress = builder_index + ceil(100 * state.performance_scaling)
	for i = builder_index, #builder_all do
	--for _, thing in pairs(builder_all) do
		if i > progress then
			state.builder_index = i
			return true
		end

		local thing = builder_all[i]

		local ghost = create_entity(thing)

		if ghost and thing.items then
			ghost.insert_plan = thing.items
		end

		::continue::
	end

	return "placement_landfill"
end

layout.placement_landfill = simple.placement_landfill

---@param self BlueprintLayout
---@param state BlueprintState
function layout:finish(state)
	
	if state.belt and state.belts then
		common.display_lane_filling(state)
	end
	
	if state.belt_planner_choice then
		belt_planner.clear_belt_planner_stack(storage.players[state.player.index])
		common.give_belt_blueprint(state)
	end
	
	return false
end

return layout

local mpp_util = require("mpp.mpp_util")
local common   = require("layouts.common")
local renderer = require("mpp.render_util")
local drawing  = require("mpp.drawing")
local pole_grid_mt = require("mpp.pole_grid_mt")

local floor, ceil = math.floor, math.ceil
local min, max, mina, maxa = math.min, math.max, math.mina, math.maxa
local EAST, NORTH, SOUTH, WEST, ROTATION = mpp_util.directions()

local base = require("layouts.base")
local simple = require("layouts.simple")

---@class SparseLayout : SimpleLayout
local layout = table.deepcopy(simple)

layout.name = "sparse"
layout.translation = {"", "[entity=transport-belt] ", {"mpp.settings_layout_choice_sparse"}}

layout.restrictions.miner_size = {1, 10e3}
layout.restrictions.miner_radius = {1, 10e3}
layout.restrictions.pole_omittable = true
layout.restrictions.pole_width = {1, 1}
layout.restrictions.pole_length = {7.5, 10e3}
layout.restrictions.pole_supply_area = {2.5, 10e3}
layout.restrictions.pole_zero_gap = false
layout.restrictions.lamp_available = true
layout.restrictions.module_available = true
layout.restrictions.pipe_available = true
layout.restrictions.coverage_tuning = false

layout.do_power_pole_joiners = true

---@param self CompactLayout
---@param state CompactState
function layout:initialize(state)
	base.initialize(self, state)
	local M = state.miner
	state.pole_gap = M.area - M.size + 1
end

---@param state SimpleState
---@return PlacementAttempt
function layout:_placement_attempt(state, attempt)
	local grid = state.grid
	local M = state.miner
	local size, area = state.miner.size, state.miner.area
	local miners = {}
	local heuristic_values = common.init_heuristic_values()
	local row_index = 1
	local lane_layout = {}
	local shift_x, shift_y = attempt[1], attempt[2]

	for uy = shift_y, state.coords.th + size, area do
		local column_index = 1
		local y = uy - M.extent_negative
		lane_layout[#lane_layout+1] = {y=y, row_index = row_index}
		for ux = shift_x, state.coords.tw, area do
			local x = ux - M.extent_negative
			local tile = grid:get_tile(x, y) --[[@as GridTile]]
			local miner = {
				x = x,
				y = y,
				origin_x = x + M.x,
				origin_y = y + M.y,
				tile = tile,
				line = row_index,
				column = column_index,
				direction = row_index % 2 == 1 and SOUTH or NORTH
			}
			if tile.forbidden then
				-- no op
			elseif tile.neighbors_outer > 0 then
				miners[#miners+1] = miner
			end
			column_index = column_index + 1
		end
		row_index = row_index + 1
	end

	local result = {
		sx=shift_x,
		sy=shift_y,
		bx = 1,
		by = 1,
		b2x = 1,
		b2y = 1,
		miners=miners,
		postponed = {},
		lane_layout=lane_layout,
		heuristics = heuristic_values,
		heuristic_score = #miners,
		unconsumed = 0,
		price = 0,
	}

	common.finalize_heuristic_values(result, heuristic_values, state.coords)

	result.heuristic_score = #miners

	return result
end

---@param self SimpleLayout
---@param state SimpleState
function layout:prepare_layout_attempts(state)
	local c = state.coords
	local m = state.miner
	local attempts = {}
	state.attempts = attempts
	state.best_attempt_index = 1
	state.attempt_index = 1 -- first attempt is used up
	
	local M_area = m.area
	
	local function calc_slack(tw)
		local count = ceil(tw / M_area)
		local overrun = (count * M_area - tw)
		local slack = overrun % 2
		local start = -floor(overrun / 2) - slack + 1
		return count, start, slack
	end

	local countx, slackw2, modx = calc_slack(c.tw)
	local county, slackh2, mody = calc_slack(c.th)

	for sy = slackh2, slackh2 + mody do
		for sx = slackw2, slackw2 + modx do
			attempts[#attempts+1] = {
				sx,
				sy,
				cx = countx,
				cy = county,
				slackw = slackw2,
				slackh = slackh2,
				modx = modx,
				mody = mody,
			}
		end
	end
	
	return "layout_attempts"
end

function layout:_get_layout_heuristic(state)
	return function(heuristic, miner) return heuristic.drill_count end
end

---@param self SimpleLayout
---@param state SimpleState
---@return PlacementSpecification[]
function layout:_get_pipe_layout_specification(state)
	local pipe_layout = List()
	
	local M = state.miner
	local attempt = state.best_attempt
	local gutter = M.outer_span
	
	local front_connections = true
	if M.pipe_left and M.pipe_left[NORTH] == 0 then
		front_connections = false
	end

	for _, pre_lane in pairs(state.miner_lanes) do
		if not pre_lane[1] then goto continue_lanes end
		local y = pre_lane[1].y
		local sx = attempt.sx + M.outer_span - 1
		---@type MinerPlacement[]
		local lane = table.mapkey(pre_lane, function(t) return t.column end) -- make array with intentional gaps between miners

		local skipped_initial = false
		local current_start, current_length = nil, 0
		for i = 1, state.miner_max_column do
			local miner = lane[i]
			if not miner and not front_connections and not skipped_initial then
				-- no op
			elseif miner and current_start then
				local start_shift = 0
				if current_start == 1 then start_shift = gutter * 2 end
				pipe_layout:push{
					structure="horizontal",
					x=sx + start_shift + (current_start-1) * M.area - gutter * 2 + 1,
					y=y + M.pipe_left[pre_lane[1].line%2*SOUTH] ,
					w=current_length * M.area+gutter * 2 - 1 - start_shift,
				}
				current_start, current_length = nil, 0
			elseif not front_connections and not skipped_initial then
				skipped_initial = true
			elseif not miner and not current_start then
				current_start, current_length = i, 1
				skipped_initial = true
			elseif current_start then
				current_length = current_length + 1
			elseif i > 1 then
				pipe_layout:push{
					structure="horizontal",
					x=sx+(i-1)*M.area-gutter*2+1,
					y=y+ M.pipe_left[pre_lane[1].line%2*SOUTH],
					w=gutter*2-1
				}
			end
		end
		
		if not front_connections and not lane[state.miner_max_column] then
			local start_shift = 0
			if current_start == 1 then start_shift = gutter * 2 end
			pipe_layout:push{
				structure="horizontal",
				x=sx + start_shift + (current_start-1) * M.area - gutter * 2 + 1,
				y=y + M.pipe_left[pre_lane[1].line%2*SOUTH] ,
				w=current_length * M.area - 1 - start_shift,
			}
		end

		::continue_lanes::
	end

	local cap_x = attempt.sx + M.outer_span - 1 - M.wrong_parity
	if not front_connections then
		cap_x = attempt.sx + (state.miner_max_column - 1) * M.area + M.size + 1
	end
	
	for i = 1, state.miner_lane_count do
		local lane = attempt.lane_layout[i]
		pipe_layout[#pipe_layout+1] = {
			structure="cap_vertical",
			x=cap_x,
			y=lane.y+M.pipe_left[lane.row_index%2*SOUTH],
			skip_up=i == 1,
			skip_down=i == state.miner_lane_count,
		}
		if i > 1 then
			local prev_lane = attempt.lane_layout[i-1]
			local y1 = prev_lane.y+M.pipe_left[prev_lane.row_index%2*SOUTH]+1
			local y2 = lane.y+M.pipe_left[lane.row_index%2*SOUTH]-1
			pipe_layout[#pipe_layout+1] = {
				structure="joiner_vertical",
				x=cap_x,
				y=y1,
				h=y2-y1+1,
				belt_y=prev_lane.y+M.size,
			}
		end
	end

	return pipe_layout
end

---@param self SparseLayout
---@param state SimpleState
function layout:prepare_pole_layout(state)
	local next_step ="prepare_belt_layout"
	
	local C, M, G, P, A = state.coords, state.miner, state.grid, state.pole, state.best_attempt
	
	local pole_struct = mpp_util.pole_struct(state.pole_choice, state.pole_quality_choice)
	local supply_area = pole_struct.supply_width
	local wire_distance = pole_struct.wire
	
	local power_grid = pole_grid_mt.new()
	state.power_grid = power_grid
	
	local miner_lanes = state.miner_lanes
	local y_provider = self:_mining_drill_lane_y_provider(state, A)
	
	local builder_power_poles = {}
	state.builder_power_poles = builder_power_poles
	
	local area_reaches_both = M.area - M.size < floor(P.supply_area_distance) * 2
	local pole_start = M.outer_span
	local pole_step = min(floor(wire_distance), supply_area + M.size - 1)
	state.pole_step = pole_step
	
	local function place_pole_lane(y, iy, skip_light)
		local pole_lane = {}
		local ix = 1
		for x = A.sx + pole_start, C.tw+M.size, pole_step do
			local built = false
			local has_consumers = G:needs_power(x, y, P)
			if has_consumers then
				built = true
				G:build_thing_simple(x, y, "pole")
			end
			
			---@type GridPole
			local pole = {
				grid_x = x, grid_y = y,
				ix = ix, iy = iy,
				has_consumers = has_consumers,
				backtracked = false,
				built = has_consumers or built,
				connections = {},
				no_light = skip_light,
			}
			--power_poles_grid:set_pole(ix, iy, pole)

			power_grid:add_pole(pole)
			
			pole_lane[ix] = pole
			ix = ix + 1
		end
		
		local backtrack_built = false
		for pole_i = #pole_lane, 1, -1 do
			local no_light = (P.wire < 9) and (pole_i % 2 == 0) or nil
			---@type GridPole
			local backtrack_pole = pole_lane[pole_i]
			if backtrack_built or backtrack_pole.built then
				backtrack_built = true
				backtrack_pole.built = true

				builder_power_poles[#builder_power_poles+1] = {
					name=state.pole_choice,
					quality=state.pole_quality_choice,
					thing="pole",
					grid_x = backtrack_pole.grid_x,
					grid_y = backtrack_pole.grid_y,
					no_light = skip_light or no_light,
				}
				G:build_thing_simple(backtrack_pole.grid_x, backtrack_pole.grid_y, "pole")
			end
		end

		return pole_lane
	end
	
	local power_row_index = 1
	for i = 1, state.miner_lane_count do
		-- local lane = miner_lanes[i]
		local even, odd = i % 2 == 0, i % 2 == 1
		local y = y_provider(i) - M.size
		
		if i == 1 then
			place_pole_lane(y, power_row_index)
			power_row_index = power_row_index + 1
		elseif i == state.miner_lane_count and even then
			place_pole_lane(y+M.size+1, power_row_index)
		elseif area_reaches_both and even then
			place_pole_lane(y + M.size + M.outer_span, power_row_index)
			-- place_pole_lane(y, power_row_index)
			power_row_index = power_row_index + 1
		elseif not area_reaches_both then
			if even then
				place_pole_lane(y+M.size+1, power_row_index)
			else
				place_pole_lane(y, power_row_index)
			end
			power_row_index = power_row_index + 1
		end
		
	end
		
	return next_step
end

---Determine and set merge strategies
---@param self SparseLayout
---@param source BaseBeltSpecification
---@param target BaseBeltSpecification
---@param direction defines.direction.north | defines.direction.south
function layout:_apply_belt_merge_strategy(state, source, target, direction)
	local source_t1, source_t2 = source.throughput1, source.throughput2
	local source_total = source_t1 + source_t2
	local target_t1, target_t2 = target.merged_throughput1, target.merged_throughput2
	local target_total = target_t1 + target_t2
	
	-- if source.merge_direction or target.merge_strategy == "target" then
	if (
		source.has_drills ~= true
		or target.has_drills ~= true
		or source.merge_direction
		or source.merge_strategy
		or target.merge_strategy
		or source_total > target_total
	) then
		return -- no op
	elseif direction == SOUTH and source_t1 == 0 and source_total <= 1 - target_t1 then
		source.merge_target = target
		source.merge_direction = direction
		source.is_output = false
		source.merge_strategy = "side-merge"
		target.merge_strategy = "target"
		target.merged_throughput1 = target_t1 + source_total
	elseif direction == NORTH and source_t2 == 0 and source_total <= 1 - target_t2 then
		source.merge_target = target
		source.merge_direction = direction
		source.is_output = false
		source.merge_strategy = "side-merge"
		target.merge_strategy = "target"
		target.merged_throughput2 = target_t2 + source_total
	elseif (
		source_total <= target_total
		and (source_t1 + target_t2) <= 1
		and (source_t2 + target_t1) <= 1
		and target.merge_strategy ~= "target-back-merge"
		and source.merge_strategy ~= "target"
	)
	then
		source.merge_target = target
		source.merge_direction = direction
		source.is_output = false
		source.merge_strategy = "back-merge"
		target.merge_strategy = "target-back-merge"
		target.merged_throughput2 = target_t2 + source_t1
		target.merged_throughput1 = target_t1 + source_t2
		target.merge_slave = true
	elseif direction == SOUTH and source_total <= 1 - target_t1 then
		source.merge_target = target
		source.merge_direction = direction
		source.is_output = false
		source.merge_strategy = "side-merge"
		target.merge_strategy = "target"
		target.merged_throughput1 = target_t1 + source_total
	elseif direction == NORTH and source_total <= 1 - target_t2 then
		source.merge_target = target
		source.merge_direction = direction
		source.is_output = false
		source.merge_strategy = "side-merge"
		target.merge_strategy = "target"
		target.merged_throughput2 = target_t2 + source_total
	end
end

---@param state SimpleState
---@param attempt PlacementAttempt
---@return fun(i): number
function layout:_mining_drill_lane_y_provider(state, attempt)
	local extent_positive = state.miner.extent_positive
	local area = state.miner.area
	return function(i)
		return ceil(attempt.sy + extent_positive + area * (i-1))
	end
end

---@param self SparseLayout
---@param state SimpleState
---@return CallbackState
function layout:prepare_belt_layout(state)
	local G, M, P = state.grid, state.miner, state.pole

	local belts = self:_process_mining_drill_lanes(state)
	for _, belt in ipairs(belts) do
		belt.x_start = belt.x_start - M.extent_negative
		belt.y = belt.y + 1
	end
	state.belts = belts
	state.belt_count = #belts
	local belt_count = #belts

	local belt_env, builder_belts, deconstruct_spec = common.create_belt_building_environment(state)
	
	if state.belt_merge_choice and belt_count > 1 then
		for i = 1, belt_count - 1 do
			self:_apply_belt_merge_strategy(state, belts[i],  belts[i+1], SOUTH)
		end
		
		for i = belt_count, 2, -1 do
			self:_apply_belt_merge_strategy(state, belts[i], belts[i-1], NORTH)
		end
		
		for _, belt in ipairs(belts) do
			if belt.has_drills ~= true or belt.merge_slave then
				goto continue
			elseif belt.merge_strategy == "back-merge" then
				belt_env.make_sparse_back_merge_belt(belt)
			elseif belt.is_output then
				belt_env.make_sparse_output_belt(belt, belt.x_start)
			elseif belt.merge_strategy == "side-merge" then
				belt_env.make_sparse_side_merge_belt(belt)
			else
				belt_env.make_sparse_output_belt(belt, belt.x_start)
			end
			belt.merge_target = nil
			
			::continue::
		end
	else
		for _, belt in ipairs(belts) do
			if belt.has_drills then
				belt_env.make_sparse_output_belt(belt, belt.x_start)
			end
		end
	end
	
	state.builder_belts = builder_belts
	common.commit_built_tiles_to_grid(G, builder_belts, "belt")
	
	if (
		self.do_power_pole_joiners
		and state.pole_choice ~= "none"
		and state.pole_choice ~= "zero_gap"
		and M.size * 2 + 1 >= floor(P.wire)
		and M.size < (P.wire - 1) * 2
		and state.power_grid:get_y_gap() < P.wire * 2
	) then
		return "prepare_power_pole_joiners"
	end
	return "prepare_lamp_layout"
end

return layout

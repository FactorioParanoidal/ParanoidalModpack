local mpp_util = require("mpp_util")

local floor, ceil = math.floor, math.ceil
local min, max = math.min, math.max
local EAST, NORTH, SOUTH, WEST = mpp_util.directions()

local simple = require("layouts.simple")

local layout = table.deepcopy(simple) --[[@as Layout]]

layout.name = "sparse"
layout.translation = {"mpp.settings_layout_choice_sparse"}

layout.restrictions.miner_near_radius = {1, 10e3}
layout.restrictions.miner_far_radius = {2, 10e3}
layout.restrictions.pole_omittable = true
layout.restrictions.pole_width = {1, 1}
layout.restrictions.pole_length = {7.5, 10e3}
layout.restrictions.pole_supply_area = {2.5, 10e3}
layout.restrictions.lamp_available = true
layout.restrictions.module_available = true
layout.restrictions.pipe_available = true
layout.restrictions.coverage_tuning = false

---@param state SimpleState
---@return PlacementAttempt
function layout:_placement_attempt(state, shift_x, shift_y)
	local grid = state.grid
	local size, near, far = state.miner.size, state.miner.near, state.miner.far
	local full_size = far * 2 + 1
	local miners = {}
	local row_index = 1
	local lane_layout = {}

	for y = 1 + shift_y, state.coords.th + near, full_size do
		local column_index = 1
		lane_layout[#lane_layout+1] = {y=y+near, row_index = row_index}
		for x = 1 + shift_x, state.coords.tw, full_size do
			local tile = grid:get_tile(x, y)
			local center = grid:get_tile(x+near, y+near) --[[@as GridTile]]
			local miner = {
				tile = tile,
				line = row_index,
				column = column_index,
				center = center,
				direction = row_index % 2 == 1 and SOUTH or NORTH
			}
			if center.far_neighbor_count > 0 then
				miners[#miners+1] = miner
			end
			column_index = column_index + 1
		end
		row_index = row_index + 1
	end
	return {
		sx=shift_x, sy=shift_y,
		miners=miners,
		miner_count=#miners,
		lane_layout=lane_layout,
	}
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
	
	local function calc_slack(tw, near, far)
		local fullsize = far * 2 + 1
		local count = ceil(tw / fullsize)
		local overrun = count * fullsize - tw
		local slack = overrun % 2
		--local start = far-near-floor(overrun / 2) - slack
		local start = (far-near)-floor(overrun / 2) - slack
		return count, start, slack
	end

	local countx, slackw2, modx = calc_slack(c.tw, m.near, m.far)
	local county, slackh2, mody = calc_slack(c.th, m.near, m.far)
	
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
	
	return "init_layout_attempt"
end

---@param self SimpleLayout
---@param state SimpleState
function layout:init_layout_attempt(state)

	local attempt = state.attempts[state.attempt_index]

	state.best_attempt = self:_placement_attempt(state, attempt[1], attempt[2])
	state.best_attempt_score = #state.best_attempt.miners

	if state.debug_dump then
		state.best_attempt.heuristic_score = state.best_attempt_score
		state.saved_attempts = {}
		state.saved_attempts[#state.saved_attempts+1] = state.best_attempt
	end

	if #state.attempts > 1 then
		return "layout_attempt"
	end

	return "prepare_miner_layout"
end

function layout:_get_layout_heuristic(state)
	return function(attempt) return #attempt.miners end
end

---Bruteforce the best solution
---@param self SimpleLayout
---@param state SimpleState
function layout:layout_attempt(state)
	local attempt_state = state.attempts[state.attempt_index]

	---@type PlacementAttempt
	local current_attempt = self:_placement_attempt(state, attempt_state[1], attempt_state[2])
	local current_attempt_score = #current_attempt.miners

	if current_attempt_score < state.best_attempt_score  then
		state.best_attempt_index = state.attempt_index
		state.best_attempt = current_attempt
		state.best_attempt_score = current_attempt_score
	end

	if state.attempt_index >= #state.attempts then
		return "prepare_miner_layout"
	end
	state.attempt_index = state.attempt_index + 1
	return true
end

---@param self SimpleLayout
---@param state SimpleState
---@return PlacementSpecification[]
function layout:_get_pipe_layout_specification(state)
	local pipe_layout = {}
	
	local m = state.miner
	local attempt = state.best_attempt
	local gutter = m.far-m.near

	for _, pre_lane in ipairs(state.miner_lanes) do
		if not pre_lane[1] then goto continue_lanes end
		local y = pre_lane[1].center.y
		local sx = attempt.sx
		---@type MinerPlacement[]
		local lane = table.mapkey(pre_lane, function(t) return t.column end) -- make array with intentional gaps between miners

		local current_start, current_length = nil, 0
		for i = 1, state.miner_max_column do
			local miner = lane[i]
			if miner and current_start then
				local start_shift = 0
				if current_start == 1 then start_shift = gutter * 2 end
				pipe_layout[#pipe_layout+1] = {
					structure="horizontal",
					x=sx+start_shift+(current_start-1)*m.full_size-gutter*2+1,
					y=y,
					w=current_length*m.full_size+gutter*2-1-start_shift,
				}
				current_start, current_length = nil, 0
			elseif not miner and not current_start then
				current_start, current_length = i, 1
			elseif current_start then
				current_length = current_length + 1
			elseif i > 1 then
				pipe_layout[#pipe_layout+1] = {
					structure="horizontal",
					x=sx+(i-1)*m.full_size-gutter*2+1,
					y=y,
					w=gutter*2-1
				}
			end
		end

		::continue_lanes::
	end

	for i = 1, state.miner_lane_count do
		local lane = attempt.lane_layout[i]
		pipe_layout[#pipe_layout+1] = {
			structure="cap_vertical",
			x=attempt.sx,
			y=lane.y,
			skip_up=i == 1,
			skip_down=i == state.miner_lane_count,
		}
	end

	return pipe_layout
end


---@param self SimpleLayout
---@param state SimpleState
function layout:prepare_belt_layout(state)
	local m = state.miner
	local g = state.grid
	local attempt = state.best_attempt

	local miner_lanes = state.miner_lanes
	local miner_lane_count = state.miner_lane_count
	local miner_max_column = state.miner_max_column

	for _, lane in ipairs(miner_lanes) do
		table.sort(lane, function(a, b) return a.center.x < b.center.x end)
	end

	local builder_belts = {}
	state.builder_belts = builder_belts

	local function get_lane_length(lane) if lane then return lane[#lane].center.x end return 0 end
	local function que_entity(t) builder_belts[#builder_belts+1] = t end

	local belt_lanes = {}
	state.belts = belt_lanes
	local longest_belt = 0
	local pipe_adjust = state.place_pipes and -1 or 0
	for i = 1, miner_lane_count, 2 do
		local lane1 = miner_lanes[i]
		local lane2 = miner_lanes[i+1]

		local y = attempt.sy + m.size + 1 + (m.far * 2 + 1) * (i-1)

		local belt = {x1=attempt.sx + 1, x2=attempt.sx + 1, y=y, built=false, lane1=lane1, lane2=lane2}
		belt_lanes[#belt_lanes+1] = belt

		if lane1 or lane2 then
			local x1 = attempt.sx + 1 + pipe_adjust
			local x2 = max(get_lane_length(lane1), get_lane_length(lane2)) + m.near
			longest_belt = max(longest_belt, x2 - x1 + 1)
			belt.x1, belt.x2, belt.built = x1, x2, true

			for x = x1, x2 do
				que_entity{
					name=state.belt_choice,
					thing="belt",
					grid_x=x,
					grid_y=y,
					direction=defines.direction.west,
				}
			end
		end

		if lane2 then
			for _, miner in ipairs(lane2) do
				local center = miner.center
				local mx, my = center.x, center.y

				for ny = y + 1, y + (m.far - m.near) * 2 - 1 do
					que_entity{
						name=state.belt_choice,
						thing="belt",
						grid_x=mx,
						grid_y=ny,
						direction=defines.direction.north,
					}
				end
			end
		end
	end

	state.belt_count = #belt_lanes
	
	return "prepare_pole_layout"
end

---@param self SimpleLayout
---@param state SimpleState
function layout:prepare_pole_layout(state)
	local c = state.coords
	local m = state.miner
	local g = state.grid
	local attempt = state.best_attempt

	local pole_proto = game.entity_prototypes[state.pole_choice] or {supply_area_distance=3, max_wire_distance=9}
	local supply_area_distance, supply_radius, supply_area = 3.5, 3, 6
	if pole_proto then
		supply_area = pole_proto.supply_area_distance
		supply_area_distance = pole_proto.supply_area_distance or supply_area_distance
		supply_radius = floor(supply_area_distance)
		supply_area = floor(supply_area_distance * 2)
	end

	local builder_power_poles = {}
	state.builder_power_poles = builder_power_poles

	local pole_step = min(floor(pole_proto.max_wire_distance), supply_area + 2)
	state.pole_step = pole_step

	local miner_lane_width = (state.miner_max_column-1)*m.far*2 + state.miner_max_column
	local slack = ceil(miner_lane_width / pole_step) * pole_step - c.tw
	local pole_start = supply_radius - floor(slack / 2) - 1

	local function get_covered_miners(ix, iy)
		for sy = -supply_radius, supply_radius do
			for sx = -supply_radius, supply_radius do
				local tile = g:get_tile(ix+sx, iy+sy)
				if tile and tile.built_on == "miner" then
					return true
				end
			end
		end
	end

	local function place_pole_lane(y, iy, no_light)
		local pole_lane = {}
		local ix = 1
		for x = attempt.sx + pole_start, c.tw, pole_step do
			local built = false
			if get_covered_miners(x, y) then
				built = true
			end
			local pole = {x=x, y=y, ix=ix, iy=iy, built=built, no_light=no_light}
			pole_lane[ix] = pole
			ix = ix + 1
		end
		
		-- if built and ix > 1 and pole_lane[ix-1] then
		-- 	for bx = ix - 1, 1, -1 do
		-- 		local backtrack_pole = pole_lane[bx]
		-- 		if not backtrack_pole.built then
		-- 			backtrack_pole.built = true
		-- 		else
		-- 			break
		-- 		end

		-- 	end
		-- end
		-- builder_power_poles[#builder_power_poles+1] = pole

		local backtrack_built = false
		for pole_i = #pole_lane, 1, -1 do
			---@type GridPole
			local backtrack_pole = pole_lane[pole_i]
			if backtrack_built or backtrack_pole.built then
				backtrack_built = true
				backtrack_pole.built = true

				builder_power_poles[#builder_power_poles+1] = {
					name=state.pole_choice,
					thing="pole",
					grid_x = backtrack_pole.x,
					grid_y = backtrack_pole.y,
				}

			end
		end

		return pole_lane
	end

	local initial_y = attempt.sy
	local iy = 1
	local y_max, y_step = c.th + m.full_size, m.full_size * 2
	for y = initial_y, y_max, y_step do
		if ((m.far - m.near) * 2 + 2 > supply_area) then -- single pole can't supply two lanes
			place_pole_lane(y, iy)
			if y ~= initial_y then
				iy = iy + 1
				place_pole_lane(y - (m.far - m.near) * 2 + 1, iy, true)
			end
		elseif y + y_step > y_max and state.miner_lane_count % 2 == 0 then -- last pole lane
			local backstep = (m.far - m.near) * 2 - 1
			place_pole_lane(y - backstep)
		else
			local backstep = y == initial_y and 0 or m.near - m.far
			place_pole_lane(y + backstep)
		end
		iy = iy + 1
	end

	return "expensive_deconstruct"
end

return layout

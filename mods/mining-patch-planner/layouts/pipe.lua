local mpp_util = require("mpp.mpp_util")
local base = require("layouts.base")
local simple = require("layouts.simple")
local compact = require("layouts.compact")
local common  = require("layouts.common")

local table_insert, table_sort = table.insert, table.sort
local floor, ceil = math.floor, math.ceil
local min, max, mina, maxa = math.min, math.max, math.mina, math.maxa
local EAST, NORTH, SOUTH, WEST = mpp_util.directions()

---@class PipeLayout : SimpleLayout
local layout = table.deepcopy(simple)

layout.name = "pipe"
layout.translation = {"", "[entity=pipe] ", {"mpp.settings_layout_choice_pipe"}}

layout.restrictions.pole_zero_gap = false
layout.restrictions.pole_width = {1, 1}

layout.belt_merging_strategies.side_merging_front = false
layout.belt_merging_strategies.side_merging_back = false
layout.belts_and_power_inline = true

---@param self SuperCompactLayout
---@param proto MinerStruct
function layout:restriction_miner(proto)
	return proto.pipe_back ~= nil
end

function layout:validate(state)
	if state.pipe_choice == "none" then
		return false, {"mpp.msg_err_no_pipe_choice"}
	end
	return true
end

---@param self PipeLayout
---@param state CompactState
function layout:initialize(state)
	simple.initialize(self, state)
	state.pole_gap = 1
end

layout._apply_belt_merge_strategy = compact._apply_belt_merge_strategy
layout._process_mining_drill_lanes = compact._process_mining_drill_lanes
layout._placement_capable = compact._placement_capable
layout._placement_incapable = compact._placement_incapable
layout.prepare_pole_layout = compact.prepare_pole_layout
layout.prepare_belt_layout = compact.prepare_belt_layout

---@param self PipeLayout
---@param state SimpleState
function layout:prepare_pipe_layout(state)
	local G, M = state.grid, state.miner
	state.place_pipes = true
	
	local pipe = state.pipe_choice
	local pipe_quality = state.pipe_quality_choice
	local pipe_back = M.pipe_back
	local ground_pipe, ground_proto = mpp_util.find_underground_pipe(pipe)
	---@cast ground_pipe string
	local step, span
	if ground_proto then
		step = ground_proto.max_underground_distance
		span = step + 1
	end
	
	local builder_pipes = List()
	state.builder_pipes = builder_pipes
	
	---@type table<number, MinerPlacement[]>
	local miner_lanes = state.miner_lanes
	local miner_lane_count = state.miner_lane_count
	local attempt = state.best_attempt
	
	local function que_entity(t)
		builder_pipes:push(t)
		G:build_thing_simple(t.grid_x, t.grid_y, "pipe")
	end
	
	local y_provider = self:_mining_drill_lane_y_provider(state, attempt)
	
	local pipe_environment = common.create_pipe_building_environment(state)
	local pipe_specification = List()
	
	local previous_y = nil
	for i = 0, miner_lane_count, 2 do
		local y = y_provider(i)
		local lane1, lane2 = miner_lanes[i], miner_lanes[i+1]
		local x_start = attempt.sx
		
		local pipe_backs = {}
		do
			local function iterate_lane(lane)
				if not lane then return end
				for _, drill in ipairs(lane) do
					pipe_backs[drill.x + pipe_back[drill.direction][1]] = true
					if pipe_back[drill.direction][2] then
						pipe_backs[drill.x + pipe_back[drill.direction][2]] = true
					end
				end
			end
			iterate_lane(lane1)
			iterate_lane(lane2)
		end

		local x_iteration = List()
		
		for x_pos, _ in pairs(pipe_backs) do
			x_iteration:push(x_pos)
		end
		table.sort(x_iteration)
		
		local last_x = x_start - 1
		for j = 1, #x_iteration do
			local x = x_iteration[j]
			que_entity{
				name=pipe,
				quality=pipe_quality,
				thing="pipe",
				grid_x = x,
				grid_y = y,
			}
			pipe_specification:push{
				structure = "horizontal",
				x = last_x + 1,
				w = x - last_x - 1 - 1,
				y = y,
			}
			
			last_x = x
		end
		
		pipe_specification:push{
			structure="cap_vertical",
			x=x_start - 1,
			y=y,
			skip_up = i == 0,
			skip_down = i >= state.miner_lane_count - 1,
		}
		if previous_y and span < y-previous_y-1 then
			pipe_specification:push{
				structure="joiner_vertical",
				x=x_start-1,
				y=previous_y+1,
				h=y-previous_y,
				belt_y=previous_y+M.size+1,
			}
			local a = 1
		end
		previous_y = y
	end
	
	pipe_environment.process_specification(pipe_specification)
	
	return "prepare_pole_layout"
end

function layout:prepare_power_pole_joiners(state)
	simple.prepare_power_pole_joiners(self, state)
	return "expensive_deconstruct"
end

return layout

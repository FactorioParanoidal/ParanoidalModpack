local floor, ceil = math.floor, math.ceil
local min, max = math.min, math.max

local simple = require("layouts.simple")
local mpp_util = require("mpp.mpp_util")
local mpp_revert = mpp_util.revert
local pole_grid_mt = require("mpp.pole_grid_mt")

---@class LogisticsLayout:SimpleLayout
local layout = table.deepcopy(simple)

layout.name = "logistics"
layout.translation = {"", "[entity=logistic-chest-passive-provider] ", {"mpp.settings_layout_choice_logistics"}}

layout.restrictions.belt_available = false
layout.restrictions.logistics_available = true
layout.restrictions.lane_filling_info_available = false

---@param self LogisticsLayout
---@param state SimpleState
function layout:prepare_belt_layout(state)
	local m = state.miner
	local attempt = state.best_attempt

	local power_poles = {}
	state.builder_power_poles = power_poles

	---@type table<number, MinerPlacement[]>
	local miner_lanes = {{}}
	local miner_lane_number = 0 -- highest index of a lane, because using # won't do the job if a lane is missing
	local miner_max_column = 0

	for _, miner in ipairs(attempt.miners) do
		local index = miner.line
		miner_lane_number = max(miner_lane_number, index)
		if not miner_lanes[index] then miner_lanes[index] = {} end
		local line = miner_lanes[index]
		line[#line+1] = miner
		miner_max_column = max(miner_max_column, miner.column)
	end
	state.miner_lane_count = miner_lane_number
	state.miner_max_column = miner_max_column

	for _, lane in pairs(miner_lanes) do
		table.sort(lane, function(a, b) return a.x < b.x end)
	end
	---@param lane MinerPlacement[]
	local function get_lane_length(lane) if lane then return lane[#lane].x end return 0 end
	---@param lane MinerPlacement[]
	local function get_lane_column(lane) if lane and #lane > 0 then return lane[#lane].column or 0 end return 0 end

	local belts = {}
	state.builder_belts = belts

	for i = 1, miner_lane_number, 2 do
		local lane1 = miner_lanes[i]
		local lane2 = miner_lanes[i+1]

		local y = attempt.sy - 1 + (m.size + 1) * i
		local x0 = attempt.sx
		
		local column_count = max(get_lane_column(lane1), get_lane_column(lane2))
		local indices = {}
		if lane1 then for _, v in ipairs(lane1) do indices[v.column] = v end end
		if lane2 then for _, v in ipairs(lane2) do indices[v.column] = v end end

		for j = 1, column_count do
			local x = x0 + m.out_x + m.size * (j-1)
			if indices[j] then
				belts[#belts+1] = {
					name=state.logistics_choice,
					thing="belt",
					grid_x=x,
					grid_y=y,
				}
			end
		end
	end

	return "prepare_pole_layout"
end

---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState
function layout:finish(state)
	if state.print_placement_info_choice and state.player.valid then
		state.player.print({"mpp.msg_print_info_miner_placement_no_lanes", #state.best_attempt.miners, #state.resources})
	end
	return false
end

return layout

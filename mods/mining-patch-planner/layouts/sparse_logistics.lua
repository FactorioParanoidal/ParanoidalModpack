local mpp_util = require("mpp.mpp_util")

local floor, ceil = math.floor, math.ceil
local min, max = math.min, math.max
local EAST, NORTH, SOUTH, WEST = mpp_util.directions()

local sparse = require("layouts.sparse")
local logistics = require("layouts.logistics")

---@class SparseLogisticsLayout : SparseLayout
local layout = table.deepcopy(sparse)

layout.name = "sparse_logistics"
layout.translation = {"", "[entity=logistic-chest-passive-provider] ", {"mpp.settings_layout_choice_sparse_logistics"}}

layout.restrictions.belt_available = false
layout.restrictions.logistics_available = true
layout.restrictions.lane_filling_info_available = false

---@param self SparseLayout
---@param state SimpleState
function layout:prepare_belt_layout(state)
	local M = state.miner

	local belts = {}
	state.builder_belts = belts

	for _, miner in ipairs(state.best_attempt.miners) do
		local out_pos = state.miner.output_rotated[miner.direction]
		belts[#belts+1] = {
			name=state.logistics_choice,
			thing="belt",
			grid_x=miner.x + out_pos.x,
			grid_y=miner.y + out_pos.y,
		}
	end

	return "prepare_pole_layout"
end

layout.finish = logistics.finish

return layout

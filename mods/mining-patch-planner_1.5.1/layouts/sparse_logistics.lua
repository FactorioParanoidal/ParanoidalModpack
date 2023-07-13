local mpp_util = require("mpp_util")

local floor, ceil = math.floor, math.ceil
local min, max = math.min, math.max
local EAST, NORTH, SOUTH, WEST = mpp_util.directions()

local sparse = require("layouts.sparse")
local logistics = require("layouts.logistics")

local layout = table.deepcopy(sparse) --[[@as Layout]]

layout.name = "sparse_logistics"
layout.translation = {"mpp.settings_layout_choice_sparse_logistics"}

layout.restrictions.belt_available = false
layout.restrictions.logistics_available = true
layout.restrictions.lane_filling_info_available = false

---@param self SimpleLayout
---@param state SimpleState
function layout:prepare_belt_layout(state)
	local m = state.miner

	local belts = {}
	state.builder_belts = belts

	for _, miner in ipairs(state.best_attempt.miners) do
		local center = miner.center
		local y_shift = miner.direction == SOUTH and (1+m.near) or (-1-m.near)
		belts[#belts+1] = {
			name=state.logistics_choice,
			thing="belt",
			grid_x=center.x,
			grid_y=center.y + y_shift,
		}
	end

	return "prepare_pole_layout"
end

layout.finish = logistics.finish

return layout

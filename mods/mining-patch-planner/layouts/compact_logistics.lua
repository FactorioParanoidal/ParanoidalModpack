local floor, ceil = math.floor, math.ceil
local min, max = math.min, math.max

local super_compact = require("layouts.super_compact")
local logistics =require("layouts.logistics")
local builder = require("mpp.builder")

---@class CompactLogisticsLayout: SuperCompactLayout
local layout = table.deepcopy(super_compact)

layout.name = "compact_logistics"
layout.translation = {"", "[entity=logistic-chest-passive-provider] ", {"mpp.settings_layout_choice_compact_logistics"}}

layout.restrictions.lamp_available = false
layout.restrictions.belt_available = false
layout.restrictions.logistics_available = true
layout.restrictions.lane_filling_info_available = false

---@param self SimpleLayout
---@param state SimpleState
function layout:prepare_belt_layout(state)
	local m = state.miner
	local g = state.grid
	local C = state.coords
	local attempt = state.best_attempt

	local power_poles = {}
	state.builder_power_poles = power_poles

	---@type table<number, MinerPlacement[]>
	local miner_lanes = {{}}
	local miner_lane_number = 0 -- highest index of a lane, because using # won't do the job if a lane is missing
	
	local builder_belts = {}
	state.builder_belts = builder_belts
	local function que_entity(t) builder_belts[#builder_belts+1] = t end

	for _, miner in ipairs(attempt.miners) do
		local index = miner.line
		miner_lane_number = max(miner_lane_number, index)
		if not miner_lanes[index] then miner_lanes[index] = {} end
		local line = miner_lanes[index]
		line._index = index
		local out_x = m.output_rotated[defines.direction[miner.direction]][1]
		if line.last_x == nil or (miner.x+out_x) > line.last_x then
			line.last_x = miner.x + out_x
			line.last_miner = miner
		end
		line[#line+1] = miner
	end

	local shift_x, shift_y = state.best_attempt.sx, state.best_attempt.sy

	local function place_logistics(lane, start_x, end_x, y)
		local belt_start = 1 + shift_x + start_x
		if start_x ~= 0 then
			local miner = g:get_tile(shift_x+m.size, y)
			if miner and miner.built_on == "miner" then
				que_entity{
					name=state.logistics_choice,
					thing="belt",
					grid_x=shift_x+m.size+1,
					grid_y=y,
				}
				power_poles[#power_poles+1] = {
					name=state.pole_choice,
					thing="pole",
					grid_x = shift_x,
					grid_y = y,
				}
			end
		end

		for x = belt_start, end_x, m.size * 2 do
			local miner1 = g:get_tile(x, y-1) --[[@as GridTile]]
			local miner2 = g:get_tile(x, y+1) --[[@as GridTile]]
			local miner3 = g:get_tile(x+3, y) --[[@as GridTile]]
			local built = (miner1 and miner1.built_on == "miner") or (miner2 and miner2.built_on == "miner")
			local capped = miner3 and miner3.built_on == "miner"
			local pole_built = built or capped

			if capped then
				que_entity{
					name=state.logistics_choice,
					thing="belt",
					grid_x=x+m.size*2,
					grid_y=y,
				}
			end
			if built then
				que_entity{
					name=state.logistics_choice,
					thing="belt",
					grid_x=x+1,
					grid_y=y,
				}
			end

			if pole_built then
				power_poles[#power_poles+1] = {
					name=state.pole_choice,
					thing="pole",
					grid_x = x + 2,
					grid_y = y,
				}
			end
		end
	end

	for i = 1, miner_lane_number do
		local lane = miner_lanes[i]
		if lane and lane.last_x then
			local y = m.size + shift_y - 1 + (m.size + 2) * (i-1)
			local x_start = i % 2 == 0 and 3 or 0
			place_logistics(lane, x_start, lane.last_x, y)
		end
	end
	return "expensive_deconstruct"
end

layout.finish = logistics.finish

return layout

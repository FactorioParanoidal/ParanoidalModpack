
local common = require("layouts.common")
local simple = require("layouts.simple")
local mpp_util = require("mpp_util")
local builder = require("builder")

local floor, ceil = math.floor, math.ceil
local min, max = math.min, math.max
local EAST, NORTH, SOUTH, WEST = mpp_util.directions()

---@class SuperCompactLayout : SimpleLayout
local layout = table.deepcopy(simple)

layout.name = "super_compact"
layout.translation = {"mpp.settings_layout_choice_super_compact"}

layout.restrictions.miner_near_radius = {1, 1}
layout.restrictions.miner_far_radius = {1, 10e3}
layout.restrictions.uses_underground_belts = true
layout.restrictions.pole_omittable = true
layout.restrictions.pole_width = {1, 1}
layout.restrictions.pole_length = {5, 10e3}
layout.restrictions.pole_supply_area = {2.5, 10e3}
layout.restrictions.coverage_tuning = true
layout.restrictions.lamp_available = false
layout.restrictions.module_available = true
layout.restrictions.pipe_available = false

---@class SuperCompactState : SimpleState
---@field miner_bounds any

-- Validate the selection
---@param self SuperCompactLayout
---@param state SimpleState
function layout:validate(state)
	local c = state.coords
	if (state.direction_choice == "west" or state.direction_choice == "east") then
		if c.h < 3 then
			return nil, {"mpp.msg_miner_err_1_w", 3}
		end
	else
		if c.w < 3 then
			return nil, {"mpp.msg_miner_err_1_h", 3}
		end
	end
	return true
end

---@param self SuperCompactLayout
---@param state SimpleState
---@return PlacementAttempt
function layout:_placement_attempt(state, shift_x, shift_y)
	local grid = state.grid
	local size, near, fullsize = state.miner.size, state.miner.near, state.miner.full_size
	local neighbor_sum = 0
	local far_neighbor_sum = 0
	local miners, postponed = {}, {}
	local simple_density = 0
	local real_density = 0
	local leech_sum = 0
	local empty_space = 0
	local lane_layout = {}
	
	--@param tile GridTile
	--local function heuristic(tile) return tile.neighbor_count > 2 end

	local heuristic = self:_get_miner_placement_heuristic(state)
	
	local function miner_stagger(start_x, start_y, direction, stagger_step, mark_lane)
		local miner_index = 1
		for y = 1 + shift_y + start_y, state.coords.th + 2, size * 3 + 1 do
			if mark_lane then lane_layout[#lane_layout+1] = {y=y} end
			for x = 1 + shift_x + start_x, state.coords.tw + 2, size * 2 do
				local tile = grid:get_tile(x, y)
				local center = grid:get_tile(x+near, y+near) --[[@as GridTile]]
				local miner = {
					tile = tile,
					center = center,
					direction = direction,
					stagger = stagger_step,
					line = miner_index,
				}
				if center.far_neighbor_count > 0 then
					if heuristic(center) then
						miners[#miners+1] = miner
						neighbor_sum = neighbor_sum + center.neighbor_count
						far_neighbor_sum = far_neighbor_sum + center.far_neighbor_count
						empty_space = empty_space + (size^2) - center.neighbor_count
						simple_density = simple_density + center.neighbor_count / (size ^ 2)
						real_density = real_density + center.far_neighbor_count / (fullsize ^ 2)
						leech_sum = leech_sum + max(0, center.far_neighbor_count - center.neighbor_count)
					else
						postponed[#postponed+1] = miner
					end
				end
			end
			miner_index = miner_index + 1
		end
	end

	miner_stagger(0, -2, "south", 1)
	miner_stagger(3, 0, "east", 1, true)
	miner_stagger(0, 2, "north", 1)

	-- the redundant calculation makes it easier to find the stagger offset
	miner_stagger(0+size, -2+size+2, "south", 2)
	miner_stagger(3-size, 0+size+2, "east", 2, true)
	miner_stagger(0+size, 2+size+2, "north", 2)

	local result = {
		sx=shift_x, sy=shift_y,
		miners = miners,
		miner_count=#miners,
		lane_layout=lane_layout,
		postponed = postponed,
		neighbor_sum = neighbor_sum,
		far_neighbor_sum = far_neighbor_sum,
		leech_sum=leech_sum,
		simple_density = simple_density,
		real_density = real_density,
		empty_space=empty_space,
		unconsumed_count = 0,
		postponed_count = 0,
	}

	common.process_postponed(state, result, miners, postponed)

	return result
end


---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState
function layout:prepare_miner_layout(state)
	local grid = state.grid

	local builder_miners = {}
	state.builder_miners = builder_miners

	for _, miner in ipairs(state.best_attempt.miners) do
		local center = miner.center
		grid:build_miner(center.x, center.y)

		-- used for deconstruction, not ghost placement
		builder_miners[#builder_miners+1] = {
			thing="miner",
			extent_=state.miner.size,
			grid_x = miner.center.x,
			grid_y = miner.center.y,
			padding_pre = state.miner.near,
			padding_post = state.miner.near,
		}

		--[[ debug visualisation - miner placement
		local color = {1, 0, 0}
		if miner.direction == "west" then
			color = {0, 1, 0}
		elseif miner.direction == "north" then
			color = {0, 0, 1}
		end
		local rect_color = miner.stagger == 1 and {1, 1, 1} or {0, 0, 0}
		local off = state.miner.size / 2 - 0.1

		local tx, ty = coord_revert[DIR](center.x, center.y, c.tw, c.th)
		rendering.draw_rectangle{
			surface = state.surface,
			filled = false,
			--color = miner.postponed and {1, 0, 0} or {0, 1, 0},
			color = rect_color,
			width = 3,
			--target = {c.x1 + x, c.y1 + y},
			left_top = {c.gx+tx-off, c.gy + ty - off},
			right_bottom = {c.gx+tx+off, c.gy + ty + off},
		}

		rendering.draw_text{
			surface=state.surface,
			color=color,
			text=miner_dir,
			target=mpp_revert(c.gx, c.gy, DIR, center.x, center.y, c.tw, c.th),
			vertical_alignment = "top",
			alignment = "center",
		}

		rendering.draw_text{
			surface=state.surface,
			color={1, 1, 1},
			text=miner.line * 2 + miner.stagger - 2,
			target={c.gx + tx, c.gy + ty},
			vertical_alignment = "bottom",
			alignment = "center",
		}

		--]]
	end

	return "prepare_belt_layout"
end

---@param self SuperCompactLayout
---@param state SimpleState
function layout:prepare_belt_layout(state)
	local m = state.miner
	local g = state.grid
	local attempt = state.best_attempt
	local underground_belt = game.entity_prototypes[state.belt_choice].related_underground_belt.name

	local power_poles = {}
	state.builder_power_poles = power_poles
	
	---@type table<number, MinerPlacement[]>
	local belt_lanes = {}
	local miner_lane_number = 0 -- highest index of a lane, because using # won't do the job if a lane is missing

	local builder_belts = {}
	state.builder_belts = builder_belts
	local function que_entity(t) builder_belts[#builder_belts+1] = t end
	state.belt_count = 0

	for _, miner in ipairs(attempt.miners) do
		local index = miner.line * 2 + miner.stagger - 2
		miner_lane_number = max(miner_lane_number, index)
		if not belt_lanes[index] then belt_lanes[index] = {} end
		local line = belt_lanes[index]
		line._index = index
		if miner.center.x > (line.last_x or 0) then
			line.last_x = miner.center.x
			line.last_miner = miner
		end
		line[#line+1] = miner
	end

	local temp_belts = {}
	for k, v in pairs(belt_lanes) do temp_belts[#temp_belts+1] = v end
	table.sort(temp_belts, function(a, b) return a._index < b._index end)
	state.belts = temp_belts

	local shift_x, shift_y = state.best_attempt.sx, state.best_attempt.sy

	local function place_belts(start_x, end_x, y)
		local belt_start, belt_end = 1 + shift_x + start_x, end_x
		if start_x == 0 then
			-- straight runoff
			for sx = 0, 2 do
				que_entity{
					name=state.belt_choice,
					thing="belt",
					grid_x=belt_start-sx,
					grid_y=y,
					direction=WEST,
				}
			end
		else
			-- underground exit
			que_entity{
				name=underground_belt,
				type="output",
				thing="belt",
				grid_x=shift_x-1,
				grid_y=y,
				direction=WEST,
			}
			que_entity{
				name=underground_belt,
				type="input",
				thing="belt",
				grid_x=shift_x+m.size+1,
				grid_y=y,
				direction=WEST,
			}
			local miner = g:get_tile(shift_x+m.size, y)
			if miner and miner.built_on == "miner" then
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
			local built = miner1.built_on == "miner" or miner2.built_on == "miner"
			local capped = miner3.built_on == "miner"
			local pole_built = built or capped
			local last = x + m.size * 2 > end_x

			if last and not capped then
				-- last passtrough and no trailing miner
				que_entity{
					name=state.belt_choice,
					thing="belt",
					grid_x=x+1,
					grid_y=y,
					direction=WEST,
				}
			elseif capped or built then
				que_entity{
					name=underground_belt,
					type="output",
					thing="belt",
					grid_x=x+1,
					grid_y=y,
					direction=WEST,
				}
				que_entity{
					name=underground_belt,
					type="input",
					thing="belt",
					grid_x=x+m.size*2,
					grid_y=y,
					direction=WEST,
				}
			else
				for sx = 1, 6 do
					que_entity{
						name=state.belt_choice,
						thing="belt",
						grid_x=x+sx,
						grid_y=y,
						direction=WEST,
					}
				end
			end
			if last and capped then belt_end = x+6 end

			if pole_built then
				power_poles[#power_poles+1] = {
					name=state.pole_choice,
					thing="pole",
					grid_x = x + 2,
					grid_y = y,
				}
			end
		end
		return belt_start, belt_end
	end

	local stagger_shift = 1
	for i = 1, miner_lane_number do
		local belt = belt_lanes[i]
		if belt and belt.last_x then
			local y = m.size + shift_y - 1 + (m.size + 2) * (i-1)
			local x_start =stagger_shift % 2 == 0 and 3 or 0
			local bx1, bx2 = place_belts(x_start, belt.last_x, y)
			belt.x1, belt.x2, belt.y = bx1-3, bx2, y
			state.belt_count = state.belt_count + 1
			local lane1, lane2 = {}, {}
			for _, miner in ipairs(belt) do
				if miner.direction == "north" then
					lane2[#lane2+1] = miner
				else
					lane1[#lane1+1] = miner
				end
			end
			if #lane1 > 0 then belt.lane1 = lane1 end
			if #lane2 > 0 then belt.lane2 = lane2 end

		end
		stagger_shift = stagger_shift + 1
	end

	return "expensive_deconstruct"
end

---@param self SuperCompactLayout
---@param state SimpleState
---@return CallbackState
function layout:placement_miners(state)
	local create_entity = builder.create_entity_builder(state)

	local grid = state.grid
	local module_inv_size = state.miner.module_inventory_size --[[@as uint]]

	for _, miner in ipairs(state.best_attempt.miners) do
		local center = miner.center
		
		grid:build_miner(center.x, center.y)
		local ghost = create_entity{
			name = state.miner_choice,
			grid_x = center.x,
			grid_y = center.y,
			direction = defines.direction[miner.direction],
		}

		if state.module_choice ~= "none" then
			ghost.item_requests = {[state.module_choice] = module_inv_size}
		end
	end

	return "placement_belts"
end

return layout

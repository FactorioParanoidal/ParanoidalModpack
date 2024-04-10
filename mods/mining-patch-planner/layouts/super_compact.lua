
local common = require("layouts.common")
local simple = require("layouts.simple")
local mpp_util = require("mpp.mpp_util")
local builder = require("mpp.builder")

local table_insert = table.insert
local floor, ceil = math.floor, math.ceil
local min, max = math.min, math.max
local EAST, NORTH, SOUTH, WEST = mpp_util.directions()

---@class SuperCompactLayout : SimpleLayout
local layout = table.deepcopy(simple)

layout.name = "super_compact"
layout.translation = {"", "[entity=underground-belt] ", {"mpp.settings_layout_choice_super_compact"}}

layout.restrictions.miner_size = {3, 3}
layout.restrictions.miner_radius = {1, 20}
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

---@param proto MinerStruct
function layout:restriction_miner(proto)
	return proto.symmetric
end


---@param self SuperCompactLayout
---@param state SimpleState
---@return PlacementAttempt
function layout:_placement_attempt(state, shift_x, shift_y)
	local grid = state.grid
	local M = state.miner
	local size, area = M.size, M.area
	local miners, postponed = {}, {}
	local heuristic_values = common.init_heuristic_values()
	local lane_layout = {}
	local bx, by = shift_x + size - 1, shift_y + size - 1
	
	--@param tile GridTile
	--local function heuristic(tile) return tile.neighbor_count > 2 end

	local heuristic = self:_get_miner_placement_heuristic(state)
	
	local function miner_stagger(start_x, start_y, direction, row_start, mark_lane)
		local row_index = row_start
		for y = 1 + shift_y + start_y, state.coords.th + 2, size * 3 + 1 do
			if mark_lane then lane_layout[#lane_layout+1] = {y=y+1, row_index=row_index} end
			local ix = 1
			for x = 1 + shift_x + start_x, state.coords.tw + 2, size * 2 do
				local tile = grid:get_tile(x, y) --[[@as GridTile]]
				---@type MinerPlacementInit
				local miner = {
					x = x,
					y = y,
					origin_x = x + M.x,
					origin_y = y + M.y,
					tile = tile,
					direction = direction,
					stagger = row_start,
					line = row_index,
					column = ix,
				}
				if tile.neighbors_outer > 0 and heuristic(tile) then
					table_insert(miners, miner)
					common.add_heuristic_values(heuristic_values, M, tile)
				elseif tile.neighbors_outer > 0 then
					postponed[#postponed+1] = miner
				end
				ix = ix + 1
			end
			row_index = row_index + 2

		end
	end

	miner_stagger(0, -2, "south", 1)
	miner_stagger(3,  0, "east",  1, true)
	miner_stagger(0,  2, "north", 1)

	-- the redundant calculation makes it easier to find the stagger offset
	miner_stagger(0+size, -2+size+2, "south", 2)
	miner_stagger(3-size,  0+size+2, "east",  2, true)
	miner_stagger(0+size,  2+size+2, "north", 2)

	local result = {
		sx = shift_x,
		sy = shift_y,
		bx = bx,
		by = by,
		miners = miners,
		lane_layout = lane_layout,
		heuristics = heuristic_values,
		heuristic_score = -(0/0),
		unconsumed = 0,
	}

	common.process_postponed(state, result, miners, postponed)

	common.finalize_heuristic_values(result, heuristic_values, state.coords)

	
	for _, miner in pairs(miners) do
		---@cast miner MinerPlacement
		local current_lane = lane_layout[miner.line]
		if not current_lane then
			current_lane = {}
			lane_layout[miner.line] = current_lane
		end
		table_insert(current_lane, miner)
	end

	return result
end


---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState
function layout:prepare_miner_layout(state)
	local grid = state.grid
	local M = state.miner

	local builder_miners = {}
	state.builder_miners = builder_miners

	for _, miner in ipairs(state.best_attempt.miners) do
		grid:build_miner(miner.x, miner.y, state.miner.size-1)

		-- used for deconstruction, not ghost placement
		builder_miners[#builder_miners+1] = {
			thing="miner",
			extent_=state.miner.size,
			grid_x = miner.origin_x,
			grid_y = miner.origin_y,
			radius = M.size / 2,
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
	local underground_belt = state.belt.related_underground_belt

	local power_poles = {}
	state.builder_power_poles = power_poles
	
	---@type table<number, MinerPlacement[]>
	local belt_lanes = attempt.lane_layout
	local miner_lane_number = 0 -- highest index of a lane, because using # won't do the job if a lane is missing

	local builder_belts = {}
	state.builder_belts = builder_belts
	local function que_entity(t) builder_belts[#builder_belts+1] = t end
	state.belt_count = 0

	for _, miner in ipairs(attempt.miners) do
		local index = miner.line
		miner_lane_number = max(miner_lane_number, index)
		if not belt_lanes[index] then belt_lanes[index] = {} end
		local line = belt_lanes[index]
		line._index = index
		local out_x = m.output_rotated[defines.direction[miner.direction]][1]
		if line.last_x == nil or (miner.x + out_x) > line.last_x then
			line.last_x = miner.x + out_x
			line.last_miner = miner
		end
		line[#line+1] = miner
	end

	local temp_belts = {}
	for k, v in pairs(belt_lanes) do temp_belts[#temp_belts+1] = v end
	table.sort(temp_belts, function(a, b) return a.row_index < b.row_index end)
	state.belts = temp_belts

	local shift_x, shift_y = state.best_attempt.sx, state.best_attempt.sy

	local function place_belts(start_x, end_x, y)
		local belt_start, belt_end = 1 + shift_x + start_x, end_x
		local pre_miner = g:get_tile(shift_x+m.size, y)
		local built_miner = pre_miner and pre_miner.built_on == "miner"
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
		elseif not built_miner then
			for sx = 0, m.size+2 do
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
			if built_miner then
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

	for i = 1, miner_lane_number do
		local belt = belt_lanes[i]
		if belt and belt.last_x then
			local y = m.size + shift_y - 1 + (m.size + 2) * (i-1)
			local x_start = i % 2 == 0 and 3 or 0
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
	end

	return "expensive_deconstruct"
end

---@param self SuperCompactLayout
---@param state SimpleState
---@return CallbackState
function layout:placement_miners(state)
	local create_entity = builder.create_entity_builder(state)

	local M = state.miner
	local grid = state.grid
	local module_inv_size = state.miner.module_inventory_size --[[@as uint]]

	for _, miner in ipairs(state.best_attempt.miners) do
		
		local ghost = create_entity{
			name = state.miner_choice,
			thing = "miner",
			grid_x = miner.origin_x,
			grid_y = miner.origin_y,
			direction = defines.direction[miner.direction],
		}

		if state.module_choice ~= "none" then
			ghost.item_requests = {[state.module_choice] = module_inv_size}
		end
	end

	return "placement_belts"
end

return layout


local common = require("layouts.common")
local simple = require("layouts.simple")
local mpp_util = require("mpp.mpp_util")
local builder = require("mpp.builder")

local table_insert = table.insert
local floor, ceil = math.floor, math.ceil
local min, max, mina, maxa = math.min, math.max, math.mina, math.maxa
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
layout.restrictions.pole_zero_gap = false
layout.restrictions.coverage_tuning = true
layout.restrictions.lamp_available = false
layout.restrictions.module_available = true
layout.restrictions.pipe_available = false

layout.do_power_pole_joiners = false

---@class SuperCompactState : SimpleState
---@field miner_bounds any

-- Validate the selection
---@param self SuperCompactLayout
---@param state SuperCompactState
function layout:validate(state)
	return true
end

---@param self SuperCompactLayout
---@param proto MinerStruct
function layout:restriction_miner(proto)
	return proto.symmetric
end

---@param self SuperCompactLayout
---@param state SuperCompactState
---@return PlacementAttempt
function layout:_placement_attempt(state, attempt)
	local grid = state.grid
	local M = state.miner
	local size, area = M.size, M.area
	local miners, postponed = {}, {}
	local heuristic_values = common.init_heuristic_values()
	local lane_layout = {}
	local shift_x, shift_y = attempt[1], attempt[2]
	local bx, by = state.coords.extent_x2 + shift_x, state.coords.extent_y2 + shift_x
	local b2x, b2y = state.coords.extent_x1 + shift_y, state.coords.extent_y1 + shift_y
	
	--@param tile GridTile
	--local function heuristic(tile) return tile.neighbor_count > 2 end

	local heuristic = self:_get_miner_placement_heuristic(state)
	
	---@param start_x number
	---@param start_y number
	---@param direction defines.direction
	---@param row_start number
	local function miner_stagger(start_x, start_y, direction, row_start)
		local row_index = row_start
		for y = 1 + shift_y + start_y, state.coords.th + 2, size * 3 + 1 do
			if not lane_layout[row_index] then lane_layout[row_index] = {y=y, row_index=row_index} end
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
				if tile.forbidden then
					-- no op
				elseif tile.neighbors_outer > 0 and heuristic(tile) then
					table_insert(miners, miner)
					common.add_heuristic_values(heuristic_values, M, tile)
					bx, by = min(bx, x-1), min(by, y-1)
					b2x, b2y = max(b2x, x + size - 1), max(b2y, y + size - 1)
				elseif tile.neighbors_outer > 0 then
					postponed[#postponed+1] = miner
				end
				ix = ix + 1
			end
			row_index = row_index + 4

		end
	end

	miner_stagger(0, -2, SOUTH, 1)
	miner_stagger(3,  0, EAST,  1)
	miner_stagger(0,  2, NORTH, 2)

	-- the redundant calculation makes it easier to find the stagger offset
	miner_stagger(0+size, -2+size+2, SOUTH, 3)
	miner_stagger(3-size,  0+size+2, EAST,  3)
	miner_stagger(0+size,  2+size+2, NORTH, 4)

	local result = {
		sx = shift_x,
		sy = shift_y,
		bx = bx,
		by = by,
		b2x = b2x,
		b2y = b2y,
		miners = miners,
		postponed = postponed,
		lane_layout = lane_layout,
		heuristics = heuristic_values,
		heuristic_score = -(0/0),
		price = 0,
	}

	common.finalize_heuristic_values(result, heuristic_values, state.coords)

	return result
end

---Sets proper throughput calculations on a belt
---@param self Layout
---@param state State
---@param belt BaseBeltSpecification
---@param direction defines.direction.west | defines.direction.east | nil
---@return number, number
function layout:_calculate_belt_throughput(state, belt, direction)
	local belt_speed = state.belt.speed
	local multiplier = common.get_mining_drill_production_from_state(state)
	local lane1, lane2 = belt.lane1, belt.lane2
	
	local dirs =  {[NORTH]=0, [EAST]=0, [SOUTH]=0, [WEST]=0}
	---@param lane MinerPlacement[]
	local function sum_miner_directions(lane)
		for _, drill in ipairs(lane or {}) do
			dirs[drill.direction] = dirs[drill.direction] + 1
		end
	end
	sum_miner_directions(lane1)
	sum_miner_directions(lane2)
	if direction == WEST then
		return (dirs[SOUTH]) * multiplier / belt_speed, (dirs[NORTH] + dirs[EAST]) * multiplier / belt_speed
	else
		return (dirs[SOUTH] + dirs[EAST]) * multiplier / belt_speed, (dirs[NORTH]) * multiplier / belt_speed
	end
end

---@param self SuperCompactLayout
---@param state SuperCompactState
---@return List<BaseBeltSpecification>
function layout:_process_mining_drill_lanes(state)
	local G = state.grid
	local m = state.miner
	local m_size = m.size
	local attempt = state.best_attempt
	local output_positions = m.output_rotated
	local miner_lanes = attempt.lane_layout

	for _, miner in pairs(attempt.miners) do
		---@cast miner MinerPlacement
		local current_lane = miner_lanes[miner.line]
		if not current_lane then
			current_lane = {}
			miner_lanes[miner.line] = current_lane
		end
		table_insert(current_lane, miner)
	end

	---@type table<number, MinerPlacement[]>
	local miner_lanes = attempt.lane_layout
	local miner_lane_count = 0 -- highest index of a lane, because using # won't do the job if a lane is missing
	for _, lane in pairs(miner_lanes) do
		miner_lane_count = max(miner_lane_count, lane.row_index)
	end

	---@param lane MinerPlacement[]
	---@return number?
	local function get_lane_start(lane, out_x) if lane and lane[1] then return lane[1].x + out_x end end

	local belts = List() --[[@as List<BaseBeltSpecification>]]
	for i = 1, miner_lane_count, 2 do
		local x_default = attempt.sx + 1
		local lane1 = miner_lanes[i]
		local lane2 = miner_lanes[i+1]
		
		local y = attempt.sy + 2 + (m.size + 2) * floor(i/2)

		if (not lane1 or #lane1 == 0) and (not lane2 or #lane2 == 0) then
			belts:push{
				index=ceil(i/2),
				x1=x_default,
				x2=x_default,
				x_start=x_default,
				x_entry=x_default,
				x_end=x_default,
				y=y,
				has_drills=false,
				is_output=false,
				lane1=lane1,
				lane2=lane2,
				throughput1=0,
				throughput2=0,
				merged_throughput1=0,
				merged_throughput2=0,
			}
			goto continue
		end

		---@param drill MinerPlacement
		local function get_output_position(drill)
			return drill.x + output_positions[drill.direction].x
		end
		
		---@param lane MinerPlacement[]
		local function get_x_positions(lane)
			local x1, x2, x_end
			if not lane or #lane == 0 then
				return
			elseif lane[1] then
				local drill = lane[1]
				local x = get_output_position(drill)
				x1, x2, x_end = x, x, drill.x + m_size - 1
			end
			for _, drill in ipairs(lane) do
				x1 = mina(x1, get_output_position(drill))
				x2 = maxa(x2, get_output_position(drill))
				x_end = maxa(x_end, x2, drill.x + m_size - 1)
			end
			return x1, x2, x_end
		end
		
		local x1_1, x2_1, x_end_1 = get_x_positions(lane1)
		local x1_2, x2_2, x_end_2 = get_x_positions(lane2)
		local x1 = mina(x1_1, x1_2)
		local x2 = maxa(x2_1, x2_2)
		local x_end = maxa(x_end_1, x_end_2, x2)
		local x_entry = mina(get_lane_start(lane1, 0), get_lane_start(lane2, 0)) --[[@as number]]
		
		local belt = {
			index=ceil(i/2),
			x1=x1,
			x2=x2,
			y=y,
			lane1=lane1,
			lane2=lane2,
			has_drills = true,
			is_output = true,
			x_start = attempt.sx,
			x_entry = x_entry,
			x_end = max(x2, x_end),
			throughput1 = 0,
			throughput2 = 0,
			merged_throughput1 = 0,
			merged_throughput2 = 0,
		}
		
		local throughput1, throughput2 = self:_calculate_belt_throughput(state, belt, EAST)
		belt.throughput1, belt.throughput2 = throughput1, throughput2
		belt.merged_throughput1, belt.merged_throughput2 = throughput1, throughput2
		
		belts:push(belt)

		::continue::
	end
	
	for i = #belts, 1, -1 do
		local belt = belts[i]
		if belt.has_drills ~= true then
			belts[i] = nil
		else
			break
		end
	end
	
	return belts
end

---@param self SuperCompactLayout
---@param state SuperCompactState
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

	local belts = self:_process_mining_drill_lanes(state)
	state.belts = belts
	state.belt_count = #belts

	return "prepare_pole_layout"
end

---@param self SuperCompactLayout
---@param state SuperCompactState
---@return CallbackState
function layout:prepare_pole_layout(state)
	local next_step ="prepare_belt_layout"
	local G = state.grid
	local size = state.miner.size
	local pole_choice = state.pole_choice
	local pole_quality = state.pole_quality_choice
	
	---@type List<PowerPoleGhostSpecification>
	local builder_power_poles = List()
	state.builder_power_poles = builder_power_poles
	
	local belt_start_adjust = 0
	
	for i, belt in ipairs(state.belts) do
		local y = belt.y
		local index_x = 1
		local x_start = belt.x_start + (belt.index % 2) * 3
		for x = x_start, belt.x_end, size * 2 do
			local miner1 = G:get_tile(x, y-1)
			local miner2 = G:get_tile(x, y+1)
			local miner3 = G:get_tile(x+1, y)
			
			local built = (miner1 and miner1.built_thing) or (miner2 and miner2.built_thing) or (miner3 and miner3.built_thing)
			
			if built then
				if x == belt.x_start then
					belt_start_adjust = min(belt_start_adjust, -1)
				end
				
				if pole_choice ~= "none" then
					builder_power_poles:push{
						name=pole_choice,
						quality=pole_quality,
						thing = "pole",
						grid_x = x,
						grid_y = y,
						no_light = true,
						ix = index_x, iy = i,
					}
				end
				G:build_thing_simple(x, y, "pole")
			end
			
			index_x = index_x + 1
		end
	end
	
	state.belt_start_adjust = belt_start_adjust
	
	return next_step
end

---Determine and set merge strategies
---@param self SuperCompactLayout
---@param source BaseBeltSpecification
---@param target BaseBeltSpecification
---@param direction defines.direction.north | defines.direction.south
function layout:_apply_belt_merge_strategy(state, source, target, direction)
	local source_t1, source_t2 = source.throughput1, source.throughput2
	local source_total = source_t1 + source_t2
	local target_t1, target_t2 = target.merged_throughput1, target.merged_throughput2
	local target_total = target_t1 + target_t2
	local source_west1, source_west2 = self:_calculate_belt_throughput(state, source, WEST)
	
	if (
		source.has_drills ~= true
		or target.has_drills ~= true
		or source.merge_direction
		or source.merge_strategy == "target"
		or target.merge_strategy == "target"
		or source_total > target_total
	) then
		return
	elseif source_total <= target_total and (source_west1 + target_t2) <= 1 and (source_west2 + target_t1) <= 1 then
		source.merge_target = target
		source.merge_direction = direction
		source.is_output = false
		source.merge_strategy = "back-merge"
		source.throughput1, source.throughput2 = source_west1, source_west2
		source.merged_throughput1, source.merged_throughput2 = source_west1, source_west2
		source_t1, source_t2 = source.throughput1, source.throughput2
		target.merge_strategy = "target"
		target.merge_slave = true
		target.merged_throughput2 = target_t2 + source_t1
		target.merged_throughput1 = target_t1 + source_t2
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

---@param self SuperCompactLayout
---@param state SuperCompactState
function layout:prepare_belt_layout(state)
	local belts = state.belts
	local belt_count = #belts
	for _, belt in pairs(belts) do
		belt.x_start = belt.x_start + state.belt_start_adjust
	end
	
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
				belt_env.make_interleaved_back_merge_belt(belt)
				-- belt_env.make_interleaved_output_belt(target, target.x2 ~= merge_x)
			elseif belt.is_output then
				belt_env.make_interleaved_output_belt(belt)
			-- elseif belt.merge_strategy == "side-merge" then
			-- 	belt_env.make_side_merge_belt(belt)
			else
				belt_env.make_interleaved_output_belt(belt)
			end
			belt.merge_target = nil

			::continue::
		end
	else
		for i, belt in pairs(belts) do
			if belt.has_drills then
				belt_env.make_interleaved_output_belt(belt)
			end
		end
	end

	state.builder_belts = builder_belts
	common.commit_built_tiles_to_grid(state.grid, builder_belts, "belt")
	
	return "expensive_deconstruct"
end

---@param self SuperCompactLayout
---@param state SuperCompactState
---@return CallbackState
function layout:placement_miners(state)
	local create_entity = builder.create_entity_builder(state)

	local M = state.miner
	local grid = state.grid
	local module_inv_size = state.miner.module_inventory_size --[[@as uint]]

	for _, miner in ipairs(state.best_attempt.miners) do
		
		local ghost = create_entity{
			name = state.miner_choice,
			quality = state.miner_quality_choice,
			thing = "miner",
			grid_x = miner.origin_x,
			grid_y = miner.origin_y,
			direction = mpp_util.clamped_rotation(miner.direction, M.rotation_bump),
		}

		if state.module_choice ~= "none" then
			local item_plan = {}
			for j = 1, module_inv_size do
				item_plan[j] = {
					inventory=defines.inventory.mining_drill_modules,
					stack=j-1,
				}
			end
			ghost.insert_plan = {
				{
					id={name=state.module_choice, quality=state.module_quality_choice},
					items={in_inventory=item_plan},
				}
			}
		end
	end

	return "placement_belts"
end

return layout

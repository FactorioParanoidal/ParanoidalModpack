local floor, ceil = math.floor, math.ceil
local min, max = math.min, math.max

local base = require("layouts.base")
local common = require("layouts.common")
local simple = require("layouts.simple")
local mpp_util = require("mpp.mpp_util")
local pole_grid_mt = require("mpp.pole_grid_mt")
local drawing      = require("mpp.drawing")
local EAST, NORTH, SOUTH, WEST = mpp_util.directions()
local table_insert = table.insert

---@class CompactLayout : SimpleLayout
local layout = table.deepcopy(simple)

---@class CompactState : SimpleState

layout.name = "compact"
layout.translation = {"", "[entity=underground-belt] ", {"mpp.settings_layout_choice_compact"}}

layout.restrictions.miner_size = {3, 10e3}
layout.restrictions.miner_radius = {1, 10e3}
layout.restrictions.uses_underground_belts = true
layout.restrictions.pole_omittable = true
layout.restrictions.pole_width = {1, 1}
layout.restrictions.pole_length = {7.5, 10e3}
layout.restrictions.pole_supply_area = {2.5, 10e3}
layout.restrictions.pole_zero_gap = false
layout.restrictions.coverage_tuning = true
layout.restrictions.lamp_available = true
layout.restrictions.module_available = true
layout.restrictions.pipe_available = true
layout.restrictions.belt_merging_available = true
layout.restrictions.belt_planner_available = true
layout.belts_and_power_inline = true

layout.do_power_pole_joiners = true

---@param self CompactLayout
---@param state CompactState
function layout:initialize(state)
	base.initialize(self, state)
	state.pole_gap = 0
end

---@param state CompactState
---@return PlacementAttempt
function layout:_placement_attempt(state, attempt)
	local grid = state.grid
	local M = state.miner
	local size = M.size
	local miners, postponed = {}, {}
	local heuristic_values = common.init_heuristic_values()
	local lane_layout = {}
	local shift_x, shift_y = attempt[1], attempt[2]
	local bx, by = state.coords.extent_x2 + shift_x, state.coords.extent_y2 + shift_x
	local b2x, b2y = state.coords.extent_x1 + shift_y, state.coords.extent_y1 + shift_y

	local heuristic = self:_get_miner_placement_heuristic(state)

	local row_index = 1
	for y_float = shift_y, state.coords.th + size, size + 0.5 do
		local y = ceil(y_float)
		local column_index = 1
		lane_layout[#lane_layout+1] = {y = y, row_index = row_index}
		for x = shift_x, state.coords.tw, size do
			local tile = grid:get_tile(x, y) --[[@as GridTile]]
			local miner = {
				x = x,
				y = y,
				origin_x = x + M.x,
				origin_y = y + M.y,
				tile = tile,
				line = row_index,
				column = column_index,
				direction = row_index % 2 == 1 and SOUTH or NORTH,
			}
			if tile.forbidden then
				-- no op
			elseif tile.neighbors_outer > 0 and heuristic(tile) then
				miners[#miners+1] = miner
				common.add_heuristic_values(heuristic_values, M, tile)
				bx, by = min(bx, x-1), min(by, y-1)
				b2x, b2y = max(b2x, x + size - 1), max(b2y, y + size - 1)
			elseif tile.neighbors_outer > 0 then
				postponed[#postponed+1] = miner
			end
			column_index = column_index + 1
		end
		row_index = row_index + 1
	end
	
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
		unconsumed = 0,
		price = 0,
	}

	common.finalize_heuristic_values(result, heuristic_values, state.coords)
	
	return result
end

---@param self CompactLayout
---@param state CompactState
function layout:prepare_pole_layout(state)
	local M, C, P, G = state.miner, state.coords, state.pole, state.grid
	local power_grid = pole_grid_mt.new()
	state.power_grid = power_grid
	
	local belts = self:_process_mining_drill_lanes(state)
	state.belts = belts
	state.belt_count = #belts
	
	local coverage = mpp_util.calculate_pole_coverage_interleaved(state, state.miner_max_column, state.miner_lane_count, state.best_attempt.sx)
	
	---@type List<PowerPoleGhostSpecification>
	local builder_power_poles = List()
	state.builder_power_poles = builder_power_poles
	local lamps = List()
	state.builder_lamps = lamps
	
	if coverage.capable_span then
		self:_placement_capable(state, coverage, power_grid)
	else
		self:_placement_incapable(state, coverage, power_grid)
	end
	
	local connectivity = power_grid:find_connectivity(state.pole)
	state.power_connectivity = connectivity
	
	local connected = power_grid:ensure_connectivity(connectivity)
	local drill_output_positions = coverage.drill_output_positions
	
	for _, pole in pairs(connected) do
		builder_power_poles:push{
			name=state.pole_choice,
			quality=state.pole_quality_choice,
			thing="pole",
			grid_x = pole.grid_x,
			grid_y = pole.grid_y,
			no_light = pole.no_light,
			ix = pole.ix, iy = pole.iy,
		}
		G:build_thing_simple(pole.grid_x, pole.grid_y, "pole")
		
		if state.lamp_choice == false then
			-- no op
		elseif pole.no_light ~= true and not drill_output_positions[pole.grid_x+1] then
			lamps:push{
				name="small-lamp",
				thing="lamp",
				grid_x=pole.grid_x+1,
				grid_y=pole.grid_y,
			}
			G:build_thing_simple(pole.grid_x+1, pole.grid_y, "lamp")
		elseif pole.no_light ~= true and not drill_output_positions[pole.grid_x-1] then
			lamps:push{
				name="small-lamp",
				thing="lamp",
				grid_x=pole.grid_x-1,
				grid_y=pole.grid_y,
			}
			G:build_thing_simple(pole.grid_x-1, pole.grid_y, "lamp")
		end
	end
	
	return "prepare_belt_layout"
end

---Placement of belts+poles when they tile nicely (enough reach/supply area)
---@param self CompactLayout
---@param state CompactState
---@param coverage PoleSpacingStruct
---@param power_grid PowerPoleGrid
function layout:_placement_capable(state, coverage, power_grid)
	local M, C, P, G = state.miner, state.coords, state.pole, state.grid
	
	local pole_lanes = {}
	
	local sx = state.best_attempt.sx
	for iy, lane in pairs(state.belts) do
		local ix, y = 1, lane.y
		local pole_lane = {}
		pole_lanes[#pole_lanes+1] = pole_lane
		for x_step = coverage.pole_start, coverage.full_miner_width, coverage.pole_step do
			local x = x_step + sx
			local no_light = coverage.lamp_alter and ix % 2 == 0 or nil
			local has_consumers = G:needs_power(x, y, P)
			
			---@type GridPole
			local pole = {
				grid_x = x, grid_y = y,
				ix = ix, iy = iy,
				has_consumers = has_consumers,
				backtracked = false,
				built = has_consumers,
				connections = {},
				no_light = no_light,
			}
			
			power_grid:add_pole(pole)
			
			ix = ix + 1
		end
		
		local backtrack_built = false
		for pole_i = #pole_lane, 1, -1 do
			---@type GridPole
			local backtrack_pole = pole_lane[pole_i]
			if backtrack_pole.has_consumers then
				backtrack_built = true
				backtrack_pole.backtracked = backtrack_built
				backtrack_pole.has_consumers = true
			else
				backtrack_pole.backtracked = backtrack_built
			end
		end
	end
end

---Placement of belts+poles when they don't tile nicely (not enough reach/supply area)
---@param self CompactLayout
---@param state CompactState
---@param coverage PoleSpacingStruct
---@param power_grid PowerPoleGrid
function layout:_placement_incapable(state, coverage, power_grid)
	local M, C, P, G = state.miner, state.coords, state.pole, state.grid
	
	local pole_lanes = {}
	
	local sx = state.best_attempt.sx
	for iy, lane in pairs(state.belts) do
		local ix, y = 1, lane.y
		local pole_lane = {}
		pole_lanes[#pole_lanes+1] = pole_lane
		for _, px in ipairs(coverage.pattern) do
			local x = sx + px
			local no_light = coverage.lamp_alter and ix % 2 == 0 or nil
			local has_consumers = G:needs_power(x, y, P)
			
			---@type GridPole
			local pole = {
				grid_x = x, grid_y = y,
				ix = ix, iy = iy,
				has_consumers = has_consumers,
				backtracked = false,
				built = has_consumers,
				connections = {},
				no_light = no_light,
			}
			
			power_grid:add_pole(pole)
			
			--[[ debug rendering - coverage power pole positions
			rendering.draw_circle{
				surface = state.surface, players = {state.player},
				color = {1, 1, 1},
				target = {C.gx + x, C.gy + y},
				radius = 0.47,
				width = 3,
			} --]]
			
			ix = ix + 1
		end
		
		--[[ debug rendering - bad power pole (and lamp) positions
		for pos_x, _ in pairs(coverage.drill_output_positions) do
			rendering.draw_circle{
				surface = state.surface, players = {state.player},
				color = {1, 0, 0},
				target = {C.gx + sx + pos_x, C.gy + y},
				radius = 0.47,
				width = 3,
			}
		end --]]
		
		local backtrack_built = false
		for pole_i = #pole_lane, 1, -1 do
			---@type GridPole
			local backtrack_pole = pole_lane[pole_i]
			if backtrack_pole.has_consumers then
				backtrack_built = true
				backtrack_pole.backtracked = backtrack_built
				backtrack_pole.has_consumers = true
			else
				backtrack_pole.backtracked = backtrack_built
			end
		end
	end
end

---Determine and set merge strategies
---@param self CompactLayout
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
		or source.merge_strategy == "target"
		or target.merge_strategy == "target"
		or source_total > target_total
	) then
		return
	elseif source_total <= target_total and (source_t1 + target_t2) <= 1 and (source_t2 + target_t1) <= 1 then
		source.merge_target = target
		source.merge_direction = direction
		source.is_output = false
		source.merge_strategy = "back-merge"
		target.merge_strategy = "target"
		target.merge_slave = true
		target.merged_throughput2 = target_t2 + source_t1
		target.merged_throughput1 = target_t1 + source_t2
	end
end

---@param self CompactLayout
---@param state CompactState
function layout:prepare_belt_layout(state)
	local M, C, P, G = state.miner, state.coords, state.pole, state.grid

	local belts = state.belts
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
				belt_env.make_interleaved_back_merge_belt(belt)
				-- belt_env.make_interleaved_output_belt(target, target.x2 ~= merge_x)
			elseif belt.is_output then
				belt_env.make_interleaved_output_belt(belt, false)
			-- elseif belt.merge_strategy == "side-merge" then
			-- 	belt_env.make_side_merge_belt(belt)
			else
				belt_env.make_interleaved_output_belt(belt)
			end
			belt.merge_target = nil

			::continue::
		end
	else
		for _, belt in ipairs(belts) do
			if belt.has_drills then
				belt_env.make_interleaved_output_belt(belt)
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

	return "expensive_deconstruct"
end

function layout:prepare_power_pole_joiners(state)
	simple.prepare_power_pole_joiners(self, state)
	return "expensive_deconstruct"
end

return layout

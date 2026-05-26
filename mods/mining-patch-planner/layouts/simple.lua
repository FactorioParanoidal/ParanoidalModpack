local common = require("layouts.common")
local base = require("layouts.base")
local grid_mt = require("mpp.grid_mt")
local pole_grid_mt = require("mpp.pole_grid_mt")
local mpp_util = require("mpp.mpp_util")
local builder = require("mpp.builder")
local cliffs = require("mpp.cliffs")
local belt_planner = require("mpp.belt_planner")
local coord_convert, coord_revert = mpp_util.coord_convert, mpp_util.coord_revert
local internal_revert, internal_convert = mpp_util.internal_revert, mpp_util.internal_convert
local miner_direction, opposite = mpp_util.miner_direction, mpp_util.opposite

local table_insert, table_sort = table.insert, table.sort
local floor, ceil = math.floor, math.ceil
local min, max, mina, maxa = math.min, math.max, math.mina, math.maxa
local EAST, NORTH, SOUTH, WEST = mpp_util.directions()

---@class SimpleLayout : Layout
local layout = table.deepcopy(base)

---@class SimpleState : State
---@field debug_dump boolean
---@field saved_attempts PlacementAttempt[] -- for debugging, exporting state data
---@field first_pass any
---@field attempts PlacementCoords[]
---@field attempt_index number
---@field best_attempt PlacementAttempt
---@field best_attempt_score number Heuristic value
---@field best_attempt_index number
---@field resource_iter number
---@field pole_gap number Vertical gap size in the power pole lane
---@field pole_step number
---@field miner_lane_count number Miner lane count
---@field miner_max_column number Miner column span
---@field grid Grid
---@field power_grid PowerPoleGrid For connectivity
---@field power_connectivity PoleConnectivity
---@field belts BeltSpecification[]
---@field belt_count number For info printout
---@field belt_start_adjust? number Adjusts belt start x for power pole accomodation
---@field miner_lanes table<number, MinerPlacement[]>
---@field place_pipes boolean
---@field pipe_layout_specification PlacementSpecification[]
---@field builder_miners GhostSpecification[]
---@field builder_pipes GhostSpecification[]
---@field builder_belts GhostSpecification[]
---@field builder_power_poles PowerPoleGhostSpecification[]
---@field builder_lamps GhostSpecification[]
---@field fill_tiles LuaTile[]
---@field fill_tile_progress number
---@field _profiler LuaProfiler

layout.name = "simple"
layout.translation = {"", "[entity=transport-belt] ", {"mpp.settings_layout_choice_simple"}}

layout.restrictions.miner_size = {0, 10e3}
layout.restrictions.miner_radius = {0, 10e3}
layout.restrictions.pole_zero_gap = true
layout.restrictions.pole_omittable = true
layout.restrictions.pole_width = {1, 1}
layout.restrictions.pole_length = {5, 10e3}
layout.restrictions.pole_supply_area = {2.5, 10e3}
layout.restrictions.lamp_available = true
layout.restrictions.coverage_tuning = true
layout.restrictions.module_available = true
layout.restrictions.pipe_available = true
layout.restrictions.placement_info_available = true
layout.restrictions.lane_filling_info_available = true
layout.restrictions.belt_merging_available = true
layout.restrictions.belt_planner_available = true

layout.do_power_pole_joiners = true

--[[-----------------------------------

	Basic process rundown:
	* Create a virtual grid
	* Rotate the resources for the desired direction
	* Convolve the resource amounts onto grid tiles
	* Check several mining drill layouts on the grid
	* Pick the best one according to a vague heuristic score
	* Collect placement of mining drills and group them into "lanes"
	* (If needed) Collect placement pipes between mining drills
	* Collect placement of transport belts or logistics chests
	* Collect placement power poles and lamps
	* Deconstruct in spots where placement locations were collected
	* Place the entity ghosts and mark built-on tiles
	* Place landfill

--]]-----------------------------------

--- Called from script.on_load
--- ONLY FOR SETTING UP METATABLES
---@param self SimpleLayout
---@param state SimpleState
function layout:on_load(state)
	if state.grid then
		setmetatable(state.grid, grid_mt)
	end
	if state.power_grid then
		setmetatable(state.power_grid, pole_grid_mt)
	end
end

---@param self SimpleLayout
---@param state SimpleState
function layout:initialize(state)
	base.initialize(self, state)
	if state.pole_choice == "zero_gap" then
		state.pole_gap = 0
		state.lamp_choice = false
	else
		state.pole_gap =  state.pole.size
	end
end

-- Validate the selection
---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState
function layout:validate(state)
	local c = state.coords
	-- if (state.direction_choice == "west" or state.direction_choice == "east") then
	-- 	if c.h < 7 then
	-- 		return nil, {"mpp.msg_miner_err_1_w", 7}
	-- 	end
	-- else
	-- 	if c.w < 7 then
	-- 		return nil, {"mpp.msg_miner_err_1_h", 7}
	-- 	end
	-- end
	return base.validate(self, state)
end

---@param self SimpleLayout
---@param state SimpleState
function layout:start(state)
	return "deconstruct_previous_ghosts"
end

---Initializes virtual grid
---@param self SimpleLayout
---@param state SimpleState
function layout:initialize_grid(state)
	local miner = state.miner
	local c = state.coords

	local th, tw = c.h, c.w
	if state.direction_choice == "south" or state.direction_choice == "north" then
		th, tw = tw, th
	end
	c.th, c.tw = th, tw

	local y1, y2 = -miner.area-2, th + miner.area+3
	local x1, x2 = -miner.area-2, tw + miner.area+3
	c.extent_x1, c.extent_y1, c.extent_x2, c.extent_y2 = x1, y1, x2, y2

	--[[ debug rendering - bounds
	state._render_objects[#state._render_objects+1] = rendering.draw_rectangle{
		surface=state.surface,
		left_top={state.coords.ix1, state.coords.iy1},
		right_bottom={state.coords.ix1 + c.tw, state.coords.iy1 + c.th},
		filled=false, width=4, color={0, 0, 1, .2},
		players={state.player},
	}

	state._render_objects[#state._render_objects+1] = rendering.draw_rectangle{
		surface=state.surface,
		left_top={state.coords.ix1-miner.area-1, state.coords.iy1-miner.area-1},
		right_bottom={state.coords.ix1+state.coords.tw+miner.area+1, state.coords.iy1+state.coords.th+miner.area+1},
		filled=false, width=4, color={0, 0.5, 1, .1},
		players={state.player},
	}
	--]]

	-- local m_size, m_area =  state.miner.size, state.miner.area
	-- local function init_counts()
	-- 	return {[m_size]=0, [m_area]=0}
	-- end

	local grid = {}

	for y = y1, y2 do
		local row = {}
		grid[y] = row
		for x = x1, x2 do
			--local tx1, ty1 = conv(c.x1, c.y1, c.tw, c.th)
			row[x] = {
				x = x, y = y,
				amount = 0,
				neighbors_inner = 0,
				neighbors_outer = 0,
				neighbors_amount = 0,
				--neighbor_counts = init_counts(),
				gx = c.x1 + x, gy = c.y1 + y,
				consumed = false,
				convolve_amount = 0,
				convolve_outer = 0,
				convolve_inner = 0,
			} --[[@as GridTile]]
		end
	end

	state.grid = setmetatable(grid, grid_mt)
	state.convolution_cache = {}

	return "preprocess_grid"
end

---@param self SimpleLayout
---@param state SimpleState
function layout:preprocess_grid(state)
	local miner = state.miner
	local c = state.coords
	local grid = state.grid
	local M = state.miner

	local tile_area = {
		left_top={c.x1-miner.area-1, c.y1-miner.area-1},
		right_bottom={c.x2+miner.area+1, c.y2+miner.area+1}
	}
	local conv = coord_convert[state.direction_choice]
	local gx, gy = state.coords.ix1 - 1, state.coords.iy1 - 1
	if state.avoid_water_choice then
		local avoid_tiles = state.surface.find_tiles_filtered{area=tile_area, collision_mask="water_tile"}

		for i, avoid_tile in ipairs(avoid_tiles) do
			local tx, ty = avoid_tile.position.x-.5, avoid_tile.position.y-.5
			local x, y = conv(tx-gx, ty-gy, c.w, c.h)
			local tile = grid:get_tile(ceil(x), ceil(y))
			tile.avoid = true
			grid:forbid(ceil(x)-M.size+1, ceil(y)-M.size+1, M.size)
		end
	end
	
	if state.avoid_cliffs_choice then
		local avoided_cliffs = state.surface.find_entities_filtered{area=tile_area, type="cliff"}
		
		for _, cliff in ipairs(avoided_cliffs) do
			local px, py = cliff.position.x-1, cliff.position.y-1
			local fx, fy = px-gx, py-gy
			
			for _, exclusion in ipairs(cliffs.hardcoded_collisions[cliff.cliff_orientation]) do
				
				local x, y = conv(fx+exclusion[1], fy+exclusion[2], c.w, c.h)
				-- rendering.draw_circle{
				-- 	surface=state.surface,
				-- 	target = {fx+.5+exclusion[1], fy+.5+exclusion[2]},
				-- 	radius = 0.45,
				-- 	filled = false,
				-- 	width = 1,
				-- 	color = {.8, 0, 0},
				-- }
				
				x, y = ceil(x), ceil(y)
				local tile = grid:get_tile(x, y)
				if tile then
					tile.avoid = true
				end
				grid:forbid(x-M.size+1, y-M.size+1, M.size)
			end
		end
	end
	
	return "process_grid"
end

---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState
function layout:process_grid(state)
	local grid = state.grid
	local c = state.coords
	local conv = coord_convert[state.direction_choice]
	local gx, gy = state.coords.gx, state.coords.gy
	local resources = state.resources
	local num_resources = #resources

	local m = state.miner
	local size, area = m.size, m.area
	local extent_positive, extent_negative = m.extent_positive, m.extent_negative

	state.resource_tiles = state.resource_tiles or {}
	local resource_tiles = state.resource_tiles

	local price, price2 = m.area, m.area_sq
	local budget, cost = 8192 * state.performance_scaling, 0

	local filtering_choice = state.ore_filtering_choice
	
	local convlist = state.convolution_cache
	
	local i = state.resource_iter or 1
	while i <= num_resources and cost < budget do
		local ent = resources[i] --[[@as LuaEntity]]
		local x, y, tx, ty, tile, amount
		i = i + 1
		if ent == nil or not ent.valid then
			goto skip_resource
		end
		
		amount = ent.amount
		x, y = ent.position.x - gx - .5, ent.position.y - gy - .5
		tx, ty = conv(x, y, c.w, c.h)
		tx, ty = floor(tx + 1), floor(ty + 1)
		-- tile = grid:get_tile(tx, ty) --[[@as GridTile]]
		tile = grid[ty][tx]
		tile.amount = amount

		if filtering_choice and state.ore_filtering_selected ~= ent.name then
			grid:forbid(tx-extent_positive, ty-extent_positive, area)
			cost = cost + price2
		else
			-- grid:convolve_separable_horizontal(tx-size+1, ty-size+1, extent_negative, size, area, convlist)
			grid:convolve_separable_horizontal(tx-size+1, ty-size+1, extent_negative, size, area, convlist, amount)
			table_insert(resource_tiles, tile)
			cost = cost + price
		end

		::skip_resource::
	end
	state.resource_iter = i

	--[[ debug visualisation - resource and coord

	for _, tile in ipairs(resource_tiles) do
		---@cast tile GridTile
		state._render_objects[#state._render_objects+1] = rendering.draw_circle{
			surface = state.surface,
			filled = false,
			color = {0.3, 0.3, 1},
			width = 1,
			target = {c.gx + tile.x, c.gy + tile.y},
			radius = 0.5,
		}
		state._render_objects[#state._render_objects+1] = rendering.draw_text{
			text=string.format("%i,%i", tile.x, tile.y),
			surface = state.surface,
			color={1,1,1},
			target={c.gx + tile.x, c.gy + tile.y},
			alignment = "center",
			vertical_alignment="middle",
		}
	end --]]

	--[[ debug visualisation - neighbours calculations
	local m_size, m_area =  state.miner.size, state.miner.area
	local render_objects = state._render_objects
	for _, row in pairs(grid) do
		for _, tile in pairs(row) do
			---@cast tile GridTile
			--local c1, c2 = tile.neighbor_counts[m_size], tile.neighbor_counts[m_area]
			local c1, c2 = tile.neighbors_inner, tile.neighbors_outer
			if c1 == 0 and c2 == 0 then goto continue end

			table_insert(render_objects, rendering.draw_circle{
				surface = state.surface, filled=false, color = {0.3, 0.3, 1},
				width=1, radius = 0.5,
				target={c.gx + tile.x, c.gy + tile.y},
			})
			local stagger = (.5 - (tile.x % 2)) * .25
			local col = c1 == 0 and {0.3, 0.3, 0.3} or {0.6, 0.6, 0.6}
			table_insert(render_objects, rendering.draw_text{
				surface = state.surface, filled = false, color = col,
				target={c.gx + tile.x, c.gy + tile.y + stagger},
				text = string.format("%i,%i", c1, c2),
				alignment = "center",
				vertical_alignment="middle",
			})

			::continue::
		end
	end --]]

	if state.resource_iter >= num_resources then
		state.resource_iter = 1
		local convolved = state.convolution_cache
		local new = {}
		for k, _ in pairs(convolved) do
			table_insert(new, k)
		end
		state.convolution_cache = new

		return "process_grid_convolution"
	end
	return true
end

---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState
function layout:process_grid_convolution(state)
	local grid = state.grid
	
	local resource_tiles = state.convolution_cache
	local num_resources = #state.convolution_cache
	
	local m = state.miner
	local size, area = m.size, m.area
	local extent_positive, extent_negative = m.extent_positive, m.extent_negative
	
	local price = m.area
	local budget, cost = 8192 * state.performance_scaling, 0
	
	local i = state.resource_iter or 1
	while i <= num_resources and cost < budget do
		local tile = resource_tiles[i]

		grid:convolve_separable_vertical(tile.x, tile.y, extent_negative, size, area, tile)

		cost = cost + price
		i = i + 1
	end
	state.resource_iter = i

	if state.resource_iter >= num_resources then
		state.convolution_cache = nil
		return self:prepare_layout_attempts(state)
	end
	return true
end

---@class MinerPlacementInit
---@field x number Top left corner in the grid
---@field y number Top left corner in the grid
---@field origin_x number Entity placement coordinate
---@field origin_y number Entity placement coordinate
---@field tile GridTile Top left tile
---@field line number lane index
---@field column number column index
---@field direction? defines.direction

---@class MinerPlacement : MinerPlacementInit
---@field stagger number Super compact layout stagger index
---@field ent BlueprintEntity|nil
---@field unconsumed number Unconsumed resource count for postponed miners
---@field direction defines.direction
---@field postponed boolean

---@class PlacementCoords
---@field sx number x shift
---@field sy number y shift

---@class PlacementAttempt
---@field index number
---@field sx number x shift
---@field sy number y shift
---@field heuristics HeuristicsBlock
---@field final_heuristics? HeuristicsBlock
---@field miners MinerPlacement[]
---@field postponed MinerPlacement[]
---@field heuristic_score number
---@field lane_layout LaneInfo[]
---@field bx number Upper left mining drill bound
---@field by number Upper left mining drill bound
---@field b2x number Lower right mining drill bound
---@field b2y number Lower right mining drill bound
---@field price number Performance cost of the operation

---@class LaneInfo
---@field y number
---@field row_index number
---@field first_x number?
---@field last_x number?
---@field [number] MinerPlacement
---@field last_miner MinerPlacement?

function layout:_get_miner_placement_heuristic(state)
	if state.coverage_choice then
		return common.overfill_miner_placement(state.miner)
	else
		return common.simple_miner_placement(state.miner)
	end
end

function layout:_get_layout_heuristic(state)
	if state.coverage_choice then
		return common.overfill_layout_heuristic
	else
		return common.simple_layout_heuristic
	end
end

---@param self SimpleLayout
---@param state SimpleState
---@param attempt PlacementCoords
---@return PlacementAttempt
function layout:_placement_attempt(state, attempt)
	local shift_x, shift_y = attempt[1], attempt[2]
	local grid = state.grid
	local M = state.miner
	local size, area = M.size, M.area
	local pole_gap = state.pole_gap
	local miners, postponed = {}, {}
	local heuristic_values = common.init_heuristic_values()
	local lane_layout = {}
	local bx, by = state.coords.extent_x2 + shift_x, state.coords.extent_y2 + shift_x
	local b2x, b2y = state.coords.extent_x1 + shift_y, state.coords.extent_y1 + shift_y

	local heuristic = self:_get_miner_placement_heuristic(state)

	local row_index = 1
	local y = shift_y
	-- for y = shift_y, state.coords.th + size, size * 2 + pole_gap do
	
	while y < state.coords.th + size do
		local column_index = 1
		lane_layout[#lane_layout+1] = {y = y, row_index = row_index}
		
		for x = shift_x, state.coords.tw + size+1, size do
			local tile = grid:get_tile(x, y) --[[@as GridTile]]
			---@type MinerPlacementInit
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
		
		if row_index % 2 == 0 then
			y = y + size + pole_gap
		else
			y = y + size + 1
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
		price = 0,
	}

	common.finalize_heuristic_values(result, heuristic_values, state.coords)

	return result
end

---@param self SimpleLayout
---@param state SimpleState
function layout:prepare_layout_attempts(state)
	local m = state.miner
	--local init_pos_x, init_pos_y = -m.near, -m.near
	-- local init_pos_x, init_pos_y = 1, 1
	local init_pos_x, init_pos_y = 1-m.middle, 1-m.middle
	local attempts = {{init_pos_x, init_pos_y}}
	state.attempts = attempts
	state.best_attempt_index = 1
	state.attempt_index = 1
	local outer = floor((m.area - m.size)/2)
	local ext_pos = m.extent_positive
	local ext_neg = m.extent_negative

	local ext_start_x, ext_end_x = 1, 1-ext_pos
	local ext_start_y, ext_end_y = max(1-ext_neg, 1), 1-ext_pos
	
	for sy = ext_start_y, ext_end_y, -1 do
		for sx = ext_start_x, ext_end_x, -1 do
			if not (sx == init_pos_x and sy == init_pos_y) then
				attempts[#attempts+1] = {sx, sy}
			end
		end
	end

	--[[ debug visualisation - attempt origins
	local gx, gy = state.coords.gx, state.coords.gy
	for i, attempt in pairs(attempts) do
		state._render_objects[#state._render_objects+1] = rendering.draw_circle{
			surface = state.surface,
			filled = false,
			color = {1, 1, 1},
			width = 1,
			target = {gx + attempt[1], gy + attempt[2]},
			radius = 0.5,
		}
		state._render_objects[#state._render_objects+1] = rendering.draw_text{
			text=string.format("%i", i),
			surface = state.surface,
			color={1,1,1},
			target = {gx + attempt[1], gy + attempt[2]},
			alignment = "center",
			vertical_alignment="bottom",
		}
		state._render_objects[#state._render_objects+1] = rendering.draw_text{
			text=string.format("%i,%i", attempt[1], attempt[2]),
			surface = state.surface,
			color={1,1,1},
			target = {gx + attempt[1], gy + attempt[2]},
			alignment = "center",
			vertical_alignment="top",
		}
	end
	--]]

	return "layout_attempts"
end

---Overridable CallbackState provider what step to continue after determining best attempt
---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState
function layout:get_post_attempts_callback(state)
	return "prepare_miner_layout"
end

---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState
function layout:layout_attempts(state)
	local M, C = state.miner, state.coords
	local layout_heuristic = self:_get_layout_heuristic(state)
	local attempt_count = #state.attempts
	local attempts_done = 0
	local budget, cost = 12345 * state.performance_scaling, 0
	
	local saved_attempts = state.saved_attempts or List()
	state.saved_attempts = saved_attempts
	if state.attempt_index == 1 then
		local attempt_state = state.attempts[state.attempt_index]
		local current_attempt = self:_placement_attempt(state, attempt_state)
		local current_attempt_score = layout_heuristic(current_attempt.heuristics, M, C)
		current_attempt.heuristic_score = current_attempt_score
		current_attempt.index = state.attempt_index
		-- state.best_attempt = current_attempt
		-- state.best_attempt_score = current_attempt_score
		-- state.best_attempt.heuristic_score = state.best_attempt_score
		
		saved_attempts[#saved_attempts+1] = current_attempt
		if state.debug_dump == true then
			local heuristics = table.deepcopy(current_attempt.heuristics) --[[@as HeuristicsBlock]]
			common.process_postponed(state, current_attempt, current_attempt.miners, current_attempt.postponed)
			current_attempt.heuristics = heuristics
		end
		
		state.attempt_index = state.attempt_index + 1
		attempts_done = 1
		cost = cost + current_attempt.price
	end
	
	while state.attempt_index <= attempt_count do
		local attempt_state = state.attempts[state.attempt_index]
		local current_attempt = self:_placement_attempt(state, attempt_state)
		local current_attempt_score = layout_heuristic(current_attempt.heuristics, M, C)
		current_attempt.index = state.attempt_index
		current_attempt.heuristic_score = current_attempt_score
		state.attempt_index = state.attempt_index + 1
		local price = current_attempt.price
		cost = cost + price
		attempts_done = attempts_done + 1
		
		if current_attempt.heuristics.drill_count > 0 then
			saved_attempts[#saved_attempts+1] = current_attempt
			local heuristics = table.deepcopy(current_attempt.heuristics) --[[@as HeuristicsBlock]]
			if state.debug_dump == true then
				common.process_postponed(state, current_attempt, current_attempt.miners, current_attempt.postponed)
				current_attempt.final_heuristics = current_attempt.heuristics
				current_attempt.heuristics = heuristics
			end
		end
		
		local remainder = budget - cost
		local avg = cost / attempts_done
		if avg * 0.65 > remainder then
			break
		end
	end
	
	if state.attempt_index > #state.attempts then
		-- table_sort(saved_attempts, function(a, b) return a.heuristic_score < b.heuristic_score end) -- we minimizing a value
		table_sort(saved_attempts, function(a, b) return a.heuristic_score > b.heuristic_score end) -- maximize a value
		
		local attempt = saved_attempts[1]
				
		if state.debug_dump ~= true then
			common.process_postponed(state, attempt, attempt.miners, attempt.postponed)
		end
		
		if attempt.heuristics.unconsumed > 0 then
			-- Found unconsumed resources, falling back to test subsequent attempts
			state.attempt_index = 2
			return "layout_attempts_fallback"
		end
		
		state.best_attempt_index = attempt.index
		state.best_attempt = attempt
		state.best_attempt_score = attempt.heuristic_score
		
		if __DebugAdapter ~= nil then
			state.saved_attempts = nil
		end
		
		return self:get_post_attempts_callback(state)
	end

	return true
end

---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState, LocalisedString
function layout:layout_attempts_fallback(state)
	local attempt_index = state.attempt_index or 2
	local attempt_count = #state.saved_attempts
	local attempt = state.saved_attempts[attempt_index]
	local attempts_done = 0
	
	local saved_attempts = state.saved_attempts
	if attempt_index > attempt_count then
		if #state.saved_attempts > 0 then
			table_sort(saved_attempts, function(a, b) return a.heuristics.unconsumed < b.heuristics.unconsumed end) -- maximize a value
		end
		
		local first = saved_attempts[1]
		if first.heuristics.unconsumed < #state.resources then
			if __DebugAdapter ~= nil then
				state.saved_attempts = nil
			end
			state.best_attempt_index = 1
			state.best_attempt = first
			state.best_attempt_score = first.heuristic_score
			
			return self:get_post_attempts_callback(state)
		end
		
		state.player.print{"mpp.msg_err_unable_to_create_a_layout"}
		return false
	end
	
	local budget, cost = 12345 * state.performance_scaling, 0
	while cost < budget and attempt_index <= attempt_count do
		local price
		if state.debug_dump ~= true then
			price = common.process_postponed(state, attempt, attempt.miners, attempt.postponed)
		end
		cost = cost + price
		
		if attempt.heuristics.unconsumed == 0 then
			state.best_attempt = attempt
			return self:get_post_attempts_callback(state)
		end
		
		attempt_index = attempt_index + 1
		state.attempt_index = attempt_index
		attempt = state.saved_attempts[attempt_index]
		
		attempts_done = attempts_done + 1
		local remainder = budget - cost
		local avg = cost / attempts_done
		if avg * 0.65 > remainder then
			break
		end
	end
	
	if state.attempt_index > #state.attempts then
		attempt = state.saved_attempts[1]
		if __DebugAdapter ~= nil then
			state.saved_attempts = nil
		end
		state.best_attempt_index = 1
		state.best_attempt = attempt
		state.best_attempt_score = attempt.heuristic_score
		
		return self:get_post_attempts_callback(state)
	end
	
	return true
end

---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState
function layout:prepare_miner_layout(state)
	local c = state.coords
	local g = state.grid
	local M = state.miner

	---@type GhostSpecification[]
	local builder_miners = {}
	state.builder_miners = builder_miners

	---@type table<number, MinerPlacement[]>
	local miner_lanes = {}
	local miner_lane_count = 0 -- highest index of a lane, because using # won't do the job if a lane is missing
	local miner_max_column = 0
	state.miner_lanes = miner_lanes

	for _, miner in ipairs(state.best_attempt.miners) do
		g:build_miner(miner.x, miner.y, M.size-1)

		-- local can_place = surface.can_place_entity{
		-- 	name=state.miner.name,
		-- 	force = state.player.force,
		-- 	position={center.gx, center.gy},
		-- 	direction = defines.direction.north,
		-- 	build_check_type = 
		-- }

		--local x, y = c.ix1+miner.x-1, c.iy1+miner.y-1

		--[[ debug visualisation - miner
		rendering.draw_rectangle{
			surface = state.surface,
			filled = false,
			color = miner.postponed and {1, 0, 0} or {0, 1, 0},
			width = 3,
			--target = {c.x1 + x, c.y1 + y},
			left_top = {x, y},
			right_bottom = {x+M.size, y+M.size},
		}
		--]]

		local index = miner.line
		miner_lane_count = max(miner_lane_count, index)
		if not miner_lanes[index] then miner_lanes[index] = {} end
		local line = miner_lanes[index]
		line[#line+1] = miner
		miner_max_column = max(miner_max_column, miner.column)

		-- used for deconstruction, not ghost placement
		-- TODO: fix rotation
		--local build_x, build_y = miner.x + M.x, miner.y + M.y

		builder_miners[#builder_miners+1] = {
			name=state.miner.name,
			thing="miner",
			grid_x = miner.origin_x,
			grid_y = miner.origin_y,
			radius = M.size / 2,
		}
	end
	state.miner_lane_count = miner_lane_count
	state.miner_max_column = miner_max_column

	for _, lane in pairs(miner_lanes) do
		table.sort(lane, function(a, b) return a.x < b.x end)
	end

	--[[ debug visualisation - miner
	local render_objects = state._render_objects
	for _, row in pairs(g) do
		for _, tile in pairs(row) do
			--local c1, c2 = tile.neighbor_counts[m_size], tile.neighbor_counts[m_area]
			---@cast tile GridTile
			local thing = tile.built_thing
			if thing == false then goto continue end

			table_insert(render_objects, rendering.draw_circle{
				surface = state.surface, filled=false, color = {0.3, 0.3, 1},
				width=1, radius = 0.5,
				target={c.gx + tile.x, c.gy + tile.y},
			})
			::continue::
		end
	end
	--]]

	return "prepare_pipe_layout"
end

---@class PlacementSpecification
---@field x number
---@field w number
---@field y number
---@field h number
---@field structure string
---@field entity string
---@field radius number
---@field skip_up boolean
---@field skip_down boolean
---@field belt_y number

--- Process gaps between miners in "miner space" and translate them to grid specification
---@param self SimpleLayout
---@param state SimpleState
---@return PlacementSpecification[]
function layout:_get_pipe_layout_specification(state)
	local pipe_layout = {}

	local M = state.miner
	local attempt = state.best_attempt
	
	local front_connections = true
	if M.pipe_left and M.pipe_left[NORTH] == 0 then
		front_connections = false
	end

	for _, pre_lane in pairs(state.miner_lanes) do
		if not pre_lane[1] then goto continue_lanes end
		local y = pre_lane[1].y
		local sx = state.best_attempt.sx - 1
		local lane = table.mapkey(pre_lane, function(t) return t.column end) -- make array with intentional gaps between miners

		-- Calculate a list of run-length gaps
		-- start and length are in miner count
		local gaps = {}
		local current_start, current_length = nil, 0
		local skipped_initial = false
		for i = 1, state.miner_max_column do
			local miner = lane[i]
			if not miner and not front_connections and not skipped_initial then
				-- no op
			elseif miner and current_start then
				gaps[#gaps+1] = {start=current_start, length=current_length}
				current_start, current_length = nil, 0
			elseif not front_connections and not skipped_initial and #gaps == 0 then
				skipped_initial = true
			elseif not miner and not current_start then
				current_start, current_length = i, 1
				skipped_initial = true
			else
				current_length = current_length + 1
			end
		end
		
		if not front_connections and not lane[state.miner_max_column] then
			gaps[#gaps+1] = {start=current_start, length=current_length}
		end

		for i, gap in ipairs(gaps) do
			local start, length = gap.start, gap.length
			local gap_length = M.size * length
			local gap_start = sx + (start-1) * M.size + 1
			
			pipe_layout[#pipe_layout+1] = {
				structure="horizontal",
				x = gap_start,
				w = gap_length-1,
				y = y + M.pipe_left[pre_lane[1].line%2*SOUTH],
			}
		end

		::continue_lanes::
	end

	if front_connections then
		for i = 1, state.miner_lane_count do
			local lane = attempt.lane_layout[i]
			pipe_layout[#pipe_layout+1] = {
				structure="cap_vertical",
				x=attempt.sx-1,
				y=lane.y + M.pipe_left[lane.row_index%2*SOUTH],
				skip_up=i == 1,
				skip_down=i == state.miner_lane_count,
			}
			if i > 1 then
				local prev_lane = attempt.lane_layout[i-1]
				local y1 = prev_lane.y+M.pipe_left[prev_lane.row_index%2*SOUTH]+1
				local y2 = lane.y+M.pipe_left[lane.row_index%2*SOUTH]-1
				pipe_layout[#pipe_layout+1] = {
					structure="joiner_vertical",
					x=attempt.sx-1,
					y=y1,
					h=y2-y1+1,
					belt_y=prev_lane.y+M.size,
				}
			end
		end
	else
		local x = attempt.sx + state.miner_max_column * M.size
		for i = 1, state.miner_lane_count, 2 do
			local lane1 = attempt.lane_layout[i]
			local lane2 = attempt.lane_layout[i+1]
			pipe_layout[#pipe_layout+1] = {
				structure="cap_vertical_high",
				x=x,
				y=lane1.y + M.size - 1 + M.pipe_left[lane1.row_index%2*SOUTH],
				skip_up=i == 1,
				skip_down=i == state.miner_lane_count,
				lane1 = lane1 ~= nil,
				lane2 = lane2 ~= nil,
				
			}
			if i > 1 then
				local prev_lane = attempt.lane_layout[i-1]
				local y1 = prev_lane.y+M.pipe_left[prev_lane.row_index%2*SOUTH]+1
				local y2 = lane1.y+M.pipe_left[lane1.row_index%2*SOUTH]-1
				pipe_layout[#pipe_layout+1] = {
					structure="joiner_vertical",
					x=x,
					y=y1,
					h=y2-y1+1,
					belt_y=prev_lane.y+M.size,
				}
			end
		end
	end

	return pipe_layout
end

---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState
function layout:prepare_pipe_layout(state)
	local G = state.grid
	local builder_pipes = {}
	state.builder_pipes = builder_pipes

	local next_step = "prepare_pole_layout"
	if state.pipe_choice == "none"
		or (not state.requires_fluid and not state.force_pipe_placement_choice)
		or (not state.miner.supports_fluids)
	then
		state.place_pipes = false
		return next_step
	end
	state.place_pipes = true

	state.pipe_layout_specification = self:_get_pipe_layout_specification(state)

	local pipe_environment = common.create_pipe_building_environment(state)
	local pipe_specification = state.pipe_layout_specification

	pipe_environment.process_specification(pipe_specification)

	return next_step
end


---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState
function layout:prepare_pole_layout(state)
	local next_step ="prepare_belt_layout"

	local C, M, P, G = state.coords, state.miner, state.pole, state.grid
	local attempt = state.best_attempt

	local supply_area, wire_reach = 3, 9
	supply_area, wire_reach = P.supply_width, P.wire

	---@type PowerPoleGhostSpecification[]
	local builder_power_poles = {}
	state.builder_power_poles = builder_power_poles

	if state.pole_gap == 0 then return next_step end

	local coverage = mpp_util.calculate_pole_coverage_simple(state, state.miner_max_column, state.miner_lane_count)

	local power_grid = pole_grid_mt.new()
	state.power_grid = power_grid

	-- rendering.draw_circle{
	-- 	surface = state.surface,
	-- 	player = state.player,
	-- 	filled = true,
	-- 	color = {1, 1, 1},
	-- 	radius = 0.5,
	-- 	target = mpp_revert(c.gx, c.gy, DIR, attempt.sx, attempt.sy, c.tw, c.th),
	-- }

	local pole_lanes = {}

	--local y = attempt.sy + m.size + (m.size + pole_gap) * (i-1)

	local iy = 1
	for y = attempt.sy + coverage.lane_start - 1, C.th + M.size, coverage.lane_step do
		local ix, pole_lane = 1, {}
		pole_lanes[#pole_lanes+1] = pole_lane
		for x = attempt.sx + coverage.pole_start, attempt.sx + coverage.full_miner_width + 1, coverage.pole_step do
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
			--power_poles_grid:set_pole(ix, iy, pole)

			power_grid:add_pole(pole)

			pole_lane[ix] = pole
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

		iy = iy + 1
	end

	local connectivity = power_grid:find_connectivity(state.pole)
	state.power_connectivity = connectivity

	local connected = power_grid:ensure_connectivity(connectivity)

	for _, pole in pairs(connected) do
		builder_power_poles[#builder_power_poles+1] = {
			name=state.pole_choice,
			quality=state.pole_quality_choice,
			thing="pole",
			grid_x = pole.grid_x,
			grid_y = pole.grid_y,
			no_light = pole.no_light,
			ix = pole.ix, iy = pole.iy,
		}
		G:build_thing_simple(pole.grid_x, pole.grid_y, "pole")
	end

	return next_step
end

---Sets proper throughput calculations on a belt
---@param self SimpleLayout
---@param state SimpleState
---@param belt BaseBeltSpecification
---@param direction defines.direction.west | defines.direction.east | nil
---@return number, number
function layout:_calculate_belt_throughput(state, belt, direction)
	local belt_speed = state.belt.speed
	local multiplier = common.get_mining_drill_production_from_state(state)
	---@param lane MinerPlacement[]
	local function lane_capacity(lane) if lane then return #lane * multiplier / belt_speed end return 0 end
	local lane1, lane2 = belt.lane1, belt.lane2

	return lane_capacity(lane1), lane_capacity(lane2)
	-- belt.throughput1 = lane_capacity(lane1)
	-- belt.throughput2 = lane_capacity(lane2)
	-- belt.merged_throughput1 = belt.throughput1
	-- belt.merged_throughput2 = belt.throughput2
end

---@param state SimpleState
---@param attempt PlacementAttempt
---@return fun(i): number
function layout:_mining_drill_lane_y_provider(state, attempt)
	local size = state.miner.size
	local pole_gap = (1 + state.pole_gap) / 2
	return function(i)
		return ceil(attempt.sy + size + (size + pole_gap) * (i-1))
	end
end

---@param state SimpleState
---@return List<BaseBeltSpecification>
function layout:_process_mining_drill_lanes(state)
	local m = state.miner
	local out_rot = m.output_rotated
	local attempt = state.best_attempt

	---@type table<number, MinerPlacement[]>
	local miner_lanes = state.miner_lanes
	local miner_lane_count = state.miner_lane_count -- highest index of a lane, because using # won't do the job if a lane is missing

	---@param lane MinerPlacement[]
	---@return number?
	local function get_lane_length(lane, out_x) return lane and lane[#lane] and lane[#lane].x + out_x end
	---@param lane MinerPlacement[]
	---@return number?
	local function get_lane_start(lane, out_x) return lane and lane[1] and lane[1].x + out_x end
	---@param lane MinerPlacement[]
	---@return number?
	local function get_lane_end(lane, size) return lane and lane[#lane] and lane[#lane].x + size end

	local y_provider = self:_mining_drill_lane_y_provider(state, attempt)
	
	local pipe_adjust = state.place_pipes and -1 or 0
	local belts = List() --[[@as List<BaseBeltSpecification>]]
	for i = 1, miner_lane_count, 2 do
		local lane1 = miner_lanes[i]
		local lane2 = miner_lanes[i+1]

		local y = y_provider(i)

		if not lane1 and not lane2 then
			belts:push{
				index=ceil(i/2),
				x1=attempt.sx + pipe_adjust,
				x2=attempt.sx,
				x_start=attempt.sx + pipe_adjust,
				x_entry=attempt.sx + pipe_adjust,
				x_end=attempt.sx,
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
		
		local x1 = mina(get_lane_start(lane1, out_rot[SOUTH].x), get_lane_start(lane2, out_rot[NORTH].x))
		local x2 = maxa(get_lane_length(lane1, out_rot[SOUTH].x), get_lane_length(lane2, out_rot[NORTH].x))
		local x_end = maxa(get_lane_end(lane1, m.size-1), get_lane_end(lane2, m.size-1))
		local x_entry = mina(get_lane_start(lane1, 0), get_lane_start(lane2, 0))
		
		local belt = {
			index=ceil(i/2),
			x1=x1,
			x2=x2,
			y=y,
			lane1=lane1,
			lane2=lane2,
			has_drills = true,
			is_output = true,
			x_start = attempt.sx + pipe_adjust,
			x_entry=x_entry,
			x_end = x_end,
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
	
	return belts
end

---Determine and set merge strategies
---@param self SimpleLayout
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
		or source.merge_strategy
		or target.merge_strategy
		or source_total > target_total
	) then
		return -- no op
	elseif direction == SOUTH and source_t1 == 0 and source_total <= 1 - target_t1 then
		source.merge_target = target
		source.merge_direction = direction
		source.is_output = false
		source.merge_strategy = "side-merge"
		target.merge_strategy = "target"
		target.merged_throughput1 = target_t1 + source_total
	elseif direction == NORTH and source_t2 == 0 and source_total <= 1 - target_t2 then
		source.merge_target = target
		source.merge_direction = direction
		source.is_output = false
		source.merge_strategy = "side-merge"
		target.merge_strategy = "target"
		target.merged_throughput2 = target_t2 + source_total
	elseif (
		source_total <= target_total
		and (source_west1 + target_t2) <= 1
		and (source_west2 + target_t1) <= 1
		and target.merge_strategy ~= "target-back-merge"
		and source.merge_strategy ~= "target"
	)
	then
		source.merge_target = target
		source.merge_direction = direction
		source.is_output = false
		source.merge_strategy = "back-merge"
		source.throughput1, source.throughput2 = source_west1, source_west2
		source.merged_throughput1, source.merged_throughput2 = source_west1, source_west2
		source_t1, source_t2 = source.throughput1, source.throughput2
		target.merge_strategy = "target-back-merge"
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

---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState
function layout:prepare_belt_layout(state)
	local G, M, P = state.grid, state.miner, state.pole

	local belts = self:_process_mining_drill_lanes(state)
	state.belts = belts
	local belt_count = #belts
	state.belt_count = belt_count

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
			elseif belt.is_output then
				belt_env.make_output_belt(belt)
			elseif belt.merge_strategy == "side-merge" then
				belt_env.make_side_merge_belt(belt)
			elseif belt.merge_strategy == "back-merge" then
				belt_env.make_back_merge_belt(belt)
			else
				belt_env.make_output_belt(belt)
			end
			belt.merge_target = nil
			
			::continue::
		end
	else
		for _, belt in ipairs(belts) do
			if belt.has_drills then
				belt_env.make_output_belt(belt)
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
	return "prepare_lamp_layout"
end

---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState
function layout:prepare_power_pole_joiners(state)
	local G, M, P, B, C = state.grid, state.miner, state.pole, state.belts, state.coords
	local builder_poles = state.builder_power_poles
	local power_grid = state.power_grid
	local max_x, max_y = power_grid._max_x, power_grid._max_y
	
	do
		local last_row = power_grid[max_y] --[[@as table<number, GridPole>]]
		local consumers_exist = false
		for _, pole in pairs(last_row) do
			if pole.has_consumers then
				consumers_exist = true
				break
			end
		end
		if not consumers_exist then
			max_y = max_y - 1
		end
	end
	
	local function build_pole(x, y)
		table_insert(
			builder_poles,
			{
				name=state.pole_choice, quality=state.pole_quality_choice,
				thing="pole",
				grid_x = x,
				grid_y = y,
				no_light = true,
				ix = 0, iy = 0,
			}
		)
	end
	
	-- no, don't tell me to put it in an array and loop like a normal person
	local function find_free_tile(start_x, start_y)
		local function get_tile(x_shift, y_shift)
			local tile = G:get_tile(start_x + x_shift, start_y + y_shift)
			if tile and tile.built_thing == nil then return tile end
		end
		return get_tile( 0,  0)
			or get_tile( 0,  1)
			or get_tile( 0, -1)
			or get_tile( 1,  0)
			or get_tile(-1,  0)
			or get_tile( 1,  1)
			or get_tile( 1, -1)
			or get_tile(-1,  1)
			or get_tile(-1, -1)
	end
	
	---@param p1 GridPole
	---@param p2 GridPole
	---@param tile GridTile
	local function get_spot_viability(p1, p2, tile)
		local p1_tile = G:get_tile(p1.grid_x, p1.grid_y)
		local p2_tile = G:get_tile(p2.grid_x, p2.grid_y)

		if p1.built and p2.built then
			return 2
		elseif (tile and tile.built_thing == nil)
			and (p1_tile and p1_tile.built_thing == nil)
			and (p2_tile and p2_tile.built_thing == nil)
		then
			return 1
		end
		return 0
	end
	
	---@param p1 GridPole
	---@param p2 GridPole
	---@param tile GridTile
	local function try_build_joiner(p1, p2, tile)
		if not p1.built then
			local p_tile = G:get_tile(p1.grid_x, p1.grid_y)
			if p_tile and not p_tile.built_thing then
				p1.built = true
				build_pole(p1.grid_x, p1.grid_y)
			else
				p_tile = G:get_tile(p1.grid_x, p1.grid_y+1)
				if p_tile and not p_tile.built_thing then
					p1.built = true
					build_pole(p1.grid_x, p1.grid_y+1)
				end
			end
		end
		if not p2.built then
			local p_tile = G:get_tile(p2.grid_x, p2.grid_y)
			if p_tile and not p_tile.built_thing then
				p2.built = true
				build_pole(p2.grid_x, p2.grid_y)
			else
				p_tile = G:get_tile(p2.grid_x, p2.grid_y-1)
				if p_tile and not p_tile.built_thing then
					p2.built = true
					build_pole(p2.grid_x, p2.grid_y-1)
				end
			end
		end
		build_pole(tile.x, tile.y)
	end
	
	---@class PoleSpotStruct
	---@field row_index number
	---@field sort number
	---@field p1 GridPole
	---@field p2 GridPole
	---@field tile GridTile
	
	---@param row_index number
	---@param row1 table<number, GridPole>
	---@param row2 table<number, GridPole>
	---@return PoleSpotStruct?
	local function try_find_spot_at_start(row_index, row1, row2)
		local current_pole = row1[1]
		local next_pole
		for col = 2, max_x do
			local pole = row1[col]
			if pole.built then
				current_pole = pole
				break
			end
		end
		
		if current_pole then -- try first built pole
			next_pole = row2[current_pole.ix]
			local mx, my = power_grid:get_pole_midpoint(current_pole, next_pole)
			
			local tile = find_free_tile(mx, my)
			if tile then
				return {
					sort = get_spot_viability(current_pole, next_pole, tile),
					row_index = row_index,
					p1 = current_pole,
					p2 = next_pole,
					tile = tile,
					
				}
			end
		end
		
		if current_pole.ix > 1 then -- try previous
			local index = current_pole.ix - 1
			next_pole = row2[index]
			current_pole = row1[index]
			local mx, my = power_grid:get_pole_midpoint(current_pole, next_pole)
			local tile = find_free_tile(mx, my)
			if tile then
				return {
					sort = get_spot_viability(current_pole, next_pole, tile),
					row_index = row_index,
					p1 = current_pole,
					p2 = next_pole,
					tile = tile,
				}
			end
		end
	end
	
	---@param row_index number
	---@param row1 table<number, GridPole>
	---@param row2 table<number, GridPole>
	---@return PoleSpotStruct?
	local function try_find_spot_at_end(row_index, row1, row2)
		local current_pole = row1[max_x]
		local next_pole
		for col = max_x - 1, 1, -1 do
			local pole = row1[col]
			if pole.built then
				current_pole = pole
				break
			end
		end
		
		if current_pole then -- try first built pole
			next_pole = row2[current_pole.ix]
			local mx, my = power_grid:get_pole_midpoint(current_pole, next_pole)
			
			local tile = find_free_tile(mx, my)
			if tile then
				return {
					sort = get_spot_viability(current_pole, next_pole, tile),
					row_index = row_index,
					p1 = current_pole,
					p2 = next_pole,
					tile = tile,
				}
			end
		end
		
		if current_pole.ix < max_x then -- try next
			local index = current_pole.ix + 1
			current_pole = row1[index]
			next_pole = row2[index]
			local mx, my = power_grid:get_pole_midpoint(current_pole, next_pole)
			local tile = find_free_tile(mx, my)
			if tile then
				return {
					sort = get_spot_viability(current_pole, next_pole, tile),
					row_index = row_index,
					p1 = current_pole,
					p2 = next_pole,
					tile = tile,
				}
			end
		end
	end
	
	---@param row_index number
	---@param row1 table<number, GridPole>
	---@param row2 table<number, GridPole>
	---@param belt BaseBeltSpecification
	---@return PoleSpotStruct?
	local function try_find_spot_last_resort(row_index, row1, row2, belt)
		if not belt then return end
		local p1, p2 = row1[max_x], row2[max_x]
		
		local tile = find_free_tile(belt.x_end+1, belt.y)
		if tile then
			local joiner = {grid_x = tile.x, grid_y = tile.y}
			if (
				power_grid:pole_reaches(p1, joiner, P)
				and power_grid:pole_reaches(p2, joiner, P)
			) then
				return {
					sort = get_spot_viability(p1, p2, tile) - 1,
					row_index = row_index,
					p1 = p1,
					p2 = p2,
					tile = tile,
				}
			end
		end
		
		local mid_x, mid_y = power_grid:get_pole_midpoint(p1, p2)
		
		tile = find_free_tile(belt.x_end+1, mid_y)
		if tile then
			local joiner = {grid_x = tile.x, grid_y = tile.y}
			if (
				power_grid:pole_reaches(p1, joiner, P)
				and power_grid:pole_reaches(p2, joiner, P)
			) then
				return {
					sort = get_spot_viability(p1, p2, tile) - 1,
					row_index = row_index,
					p1 = p1,
					p2 = p2,
					tile = tile,
				}
			end
		end
	end
	
	local found_spots = {} -- keep track which unconnected power pole lanes we joined
	
	local current_row = power_grid[1]
	for row_index = 2, max_y do
		local next_row = power_grid[row_index]
		
		local p1, p2 = current_row[1], next_row[1]
		
		if power_grid:pole_reaches(p1, p2, P) then
			found_spots[row_index-1] = true
		end
		
		current_row = next_row
	end
	
	current_row = power_grid[1]
	for row_index = 2, max_y do
		local next_row = power_grid[row_index]
		local modified_row_index = row_index - 1
		local spot, spots
		if found_spots[modified_row_index] then goto continue end
		
		spots = List{}
		spots:push(try_find_spot_at_end(modified_row_index, next_row, current_row))
		spots:push(try_find_spot_at_end(modified_row_index, current_row, next_row))
		spots:push(try_find_spot_at_start(modified_row_index, current_row, next_row))
		spots:push(try_find_spot_at_start(modified_row_index, next_row, current_row))
		spots:push(try_find_spot_last_resort(modified_row_index, current_row, next_row, B[modified_row_index]))
		spots:push(try_find_spot_last_resort(modified_row_index, next_row, current_row, B[modified_row_index]))
		table.sort(spots, function(a, b) return a.sort > b.sort end)
		
		spot = spots[1] --[[@as PoleSpotStruct?]]
		
		if spot then
			try_build_joiner(spot.p1, spot.p2, spot.tile)
			found_spots[spot.row_index] = true
		end
		
		::continue::
		current_row = next_row
	end
	
	return "prepare_lamp_layout"
end

---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState
function layout:prepare_lamp_layout(state)
	local next_step = "expensive_deconstruct"

	if state.lamp_choice ~= true then return next_step end

	local G = state.grid
	local lamps = {}
	state.builder_lamps = lamps

	local sx, sy = -1, 0
	if state.pole_choice == "none" then sx = 0 end

	for _, pole in ipairs(state.builder_power_poles) do
		---@cast pole PowerPoleGhostSpecification
		local tile1 = G:get_tile(pole.grid_x+sx, pole.grid_y+sy)
		local tile2 = G:get_tile(pole.grid_x-sx, pole.grid_y+sy)
		if not pole.no_light and (tile1 and not tile1.built_thing) then
			lamps[#lamps+1] = {
				name="small-lamp",
				thing="lamp",
				grid_x=tile1.x,
				grid_y=tile1.y,
			}
		elseif not pole.no_light and (tile2 and not tile2.built_thing) then
			lamps[#lamps+1] = {
				name="small-lamp",
				thing="lamp",
				grid_x=tile2.x,
				grid_y=tile2.y,
			}
		end
	end

	return next_step
end

---@param self SimpleLayout
---@param state SimpleState
function layout:_get_deconstruction_objects(state)
	return {
		state.builder_miners,
		state.builder_pipes,
		state.builder_belts,
		state.builder_power_poles,
		state.builder_lamps,
	}
end

---@param self SimpleLayout
---@param state SimpleState
function layout:expensive_deconstruct(state)
	local c, DIR = state.coords, state.direction_choice
	local player, surface = state.player, state.surface

	local deconstructor = storage.script_inventory[state.deconstruction_choice and 2 or 1]

	for _, t in pairs(self:_get_deconstruction_objects(state)) do
		for _, object in ipairs(t) do
			---@cast object GhostSpecification
			local extent_w = object.extent_w or object.radius or 0.5
			local extent_h = object.extent_h or extent_w

			local x1, y1 = object.grid_x-extent_w, object.grid_y-extent_h
			local x2, y2 = object.grid_x+extent_w, object.grid_y+extent_h

			x1, y1 = mpp_util.revert_ex(c.gx, c.gy, DIR, x1, y1, c.tw, c.th)
			x2, y2 = mpp_util.revert_ex(c.gx, c.gy, DIR, x2, y2, c.tw, c.th)

			surface.deconstruct_area{
				force=player.force,
				player=player.index,
				area={
					left_top={min(x1, x2), min(y1, y2)},
					right_bottom={max(x1, x2), max(y1, y2)},
				},
				item=deconstructor,
			}

			--[[ debug rendering - deconstruction areas
			rendering.draw_rectangle{
				surface=state.surface,
				players={state.player},
				filled=false,
				width=1,
				color={1, 0, 0},
				-- left_top={x1+.1,y1+.1},
				-- right_bottom={x2-.1,y2-.1},
				left_top={x1,y1},
				right_bottom={x2,y2},
			} --]]
		end
	end

	return "placement_miners"
end

---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState
function layout:placement_miners(state)
	local create_entity = builder.create_entity_builder(state)
	local M = state.miner

	local module_inv_size = state.miner.module_inventory_size --[[@as uint]]
	local grid = state.grid

	for i, miner in ipairs(state.best_attempt.miners) do
		local direction = "south"
		local flip_lane = miner.line % 2 ~= 1
		if flip_lane then direction = opposite[direction] end

		local ghost = create_entity{
			name = state.miner_choice,
			quality = state.miner_quality_choice,
			thing="miner",
			grid_x = miner.origin_x,
			grid_y = miner.origin_y,
			direction = mpp_util.clamped_rotation(defines.direction[direction], M.rotation_bump),
		}

		if state.module_choice ~= "none" and M.module_inventory_size > 0 then
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

	return "placement_pipes"
end


--- Pipe placement deals in tile grid space with spectifications from previous step
---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState
function layout:placement_pipes(state)
	local create_entity = builder.create_entity_builder(state)

	if state.builder_pipes then
		for _, belt in ipairs(state.builder_pipes) do
			create_entity(belt)
		end
	end
	return "placement_belts"
end

---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState
function layout:placement_belts(state)
	local create_entity = builder.create_entity_builder(state)

	for _, belt in ipairs(state.builder_belts or {}) do
		create_entity(belt)
	end

	return "placement_poles"
end

---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState
function layout:placement_poles(state)
	local next_step = "placement_lamps"
	if state.pole_choice == "none" then return next_step end

	local create_entity = builder.create_entity_builder(state)

	for  _, pole in ipairs(state.builder_power_poles or {}) do
		local ghost = create_entity(pole)
		--ghost.disconnect_neighbour()
		--pole.ghost = ghost
	end

	return next_step
end

---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState
function layout:placement_lamps(state)
	local next_step = "placement_landfill"
	if not layout.restrictions.lamp_available or not state.lamp_choice then return next_step end
	if not state.builder_lamps then return next_step end

	local create_entity = builder.create_entity_builder(state)

	for _, lamp in ipairs(state.builder_lamps) do
		create_entity(lamp)
	end

	return next_step
end

---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState
function layout:placement_landfill(state)
	local c = state.coords
	local m = state.miner
	local grid = state.grid
	local surface = state.surface
	
	if state.landfill_choice then
		return "finish"
	end
	
	local fill_tiles, tile_progress = state.fill_tiles, state.fill_tile_progress or 1
	local landfill = state.is_space and state.space_landfill_choice or "landfill"
	local landfill_tile = prototypes.tile[landfill]

	local conv = coord_convert[state.direction_choice]
	local gx, gy = state.coords.ix1 - 1, state.coords.iy1 - 1

	if fill_tiles == nil then

		local area = {
			left_top={c.x1-m.area-1, c.y1-m.area-1},
			right_bottom={c.x2+m.area+1, c.y2+m.area+1}
		}
		if state.is_space then
			fill_tiles = surface.find_tiles_filtered{area=area, name="se-space"}
		else
			fill_tiles = surface.find_tiles_filtered{area=area, collision_mask="water_tile"}
		end
		state.fill_tiles = fill_tiles
	end

	local collected_ghosts = state._collected_ghosts

	--for _, fill in ipairs(fill_tiles) do

	local _ply, _force = state.player, state.player.force
	
	local progress = tile_progress + 64
	for i = tile_progress, #fill_tiles do
		if i > progress then
			state.fill_tile_progress = i
			return true
		end

		local fill = fill_tiles[i]
		local tx, ty = fill.position.x-.5, fill.position.y-.5
		local x, y = conv(tx-gx, ty-gy, c.w, c.h)
		local tile = grid:get_tile(ceil(x), ceil(y))

		if tile and tile.built_thing then
			if fill.name == "out-of-map" then
				goto skip_fill
			end
			local cover_tile = fill.prototype.default_cover_tile
			
			if not cover_tile then
				goto skip_fill
			elseif state.is_space then
				cover_tile = landfill_tile
			end
				
			local tile_ghost = surface.create_entity{
				raise_built=true,
				name="tile-ghost",
				player=_ply,
				force=_force,
				position=fill.position --[[@as MapPosition]],
				inner_name=cover_tile.name,
			}

			if tile_ghost then
				collected_ghosts[#collected_ghosts+1] = tile_ghost
			end

			--[[ debug rendering - landfill placement
			rendering.draw_circle{
				surface=state.surface,
				players={state.player},
				filled = true,
				color={0, .3, 0},
				radius=0.3,
				target={tx+.5, ty+.5},
			}
			--]]
			::skip_fill::
		end
	end

	return "finish"
end

---@param self SimpleLayout
---@param state SimpleState
---@return CallbackState
function layout:finish(state)
	if state.print_placement_info_choice and state.player.valid then
		state.player.print({"mpp.msg_print_info_miner_placement", #state.best_attempt.miners, state.belt_count, #state.resources})
		
		if state.best_attempt.heuristics.unconsumed > 0 then
			state.player.print({"", "[color=#EE1100]", {"mpp.msg_print_missed_resource", state.best_attempt.heuristics.unconsumed}, "[/color]"})
		end
	end

	common.display_lane_filling(state)

	if mpp_util.get_dump_state(state.player.index) then
		common.save_state_to_file(state, "json")
	end
	
	if state.belt_planner_choice then
		belt_planner.clear_belt_planner_stack(storage.players[state.player.index])
		common.give_belt_blueprint(state)
	end

	return false
end

return layout

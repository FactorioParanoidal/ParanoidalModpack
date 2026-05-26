local mpp_util = require("mpp.mpp_util")
local render_util = require("mpp.render_util")
local belt_planner = require("mpp.belt_planner")

local common = {}

local floor, ceil = math.floor, math.ceil
local min, max = math.min, math.max
local sqrt, log = math.sqrt, math.log
local EAST, NORTH, SOUTH, WEST = mpp_util.directions()

---@alias HeuristicMinerPlacement fun(tile: GridTile): boolean

---@param miner MinerStruct
---@return HeuristicMinerPlacement
function common.simple_miner_placement(miner)
	local size, area = miner.size, miner.area
	local neighbor_cap = ceil((size / 2) ^ 2)

	return function(tile)
		return tile.neighbors_inner > neighbor_cap
		-- return tile.neighbor_count > neighbor_cap or tile.far_neighbor_count > leech
	end
end

---@param miner MinerStruct
---@return HeuristicMinerPlacement
function common.overfill_miner_placement(miner)
	local leech = miner.area_sq * 0.20
	local leech2 = miner.size_sq
	
	return function(tile)
		return tile.neighbors_inner > 0 or tile.neighbors_outer > leech or tile.neighbors_outer > leech2
	end
end

---@param heuristic HeuristicsBlock
---@param miner MinerStruct
---@param coords Coords
function common.simple_layout_heuristic(heuristic, miner, coords)
	local lane_mult = 1 / (1 + ceil(heuristic.lane_count / 2))
	local centricity = 1 / (1 + log(1 + heuristic.centricity, 20))
	local outer_density = 1 / (1 + log(heuristic.outer_density + 1, 10))
	local inner_density = 1 + log(heuristic.inner_density + 1, 10)
	local value = 1
		* outer_density
		* inner_density
		* centricity
		* lane_mult
		* (0.75 ^ heuristic.penalty)
	return value
end

---@param heuristic HeuristicsBlock
---@param miner MinerStruct
---@param coords Coords
function common.overfill_layout_heuristic(heuristic, miner, coords)
	local centricity = 1 / (1 + log(1 + heuristic.centricity, 20))
	local outer_density = 1 + log(heuristic.outer_density + 1, 10)
	local drills = 1 + log(heuristic.drill_count ^ 0.5, 2)
	local value = 1
		* drills
		* outer_density
		* centricity
		* heuristic.resource_sum_deviation
		* (0.75 ^ heuristic.penalty)
	return value
end

---@param attempt PlacementAttempt
function common.heuristic_penalties(attempt)
	local only_postponed = true
	local no_first_column = true
	local no_first_row = true
	for _, miner in pairs(attempt.miners) do
		only_postponed = only_postponed and miner.postponed
		if no_first_column then
			no_first_column = miner.column ~= 1
		end
		if no_first_row then
			no_first_row = miner.line ~= 1
		end
		if only_postponed then
			only_postponed = miner.postponed ~= true
		end
		if not (only_postponed or no_first_column or no_first_row) then
			break
		end
	end
	local penalty = 0
	if only_postponed then
		penalty = penalty + 1
	end
	if no_first_column then
		penalty = penalty + 1
	end
	if no_first_row then
		penalty = penalty + 1
	end
	return penalty
end

---@class HeuristicsBlock
--- Values counted per miner placement
---@field resource_sum number
---@field inner_neighbor_sum number Sum of resource tiles drills physically cover
---@field outer_neighbor_sum number Sum of all resource tiles drills physically cover
---@field empty_space number Sum of empty tiles drills physically cover
---@field leech_sum number Sum of resources only in the outer reach
---@field postponed_count number Number of postponed drills
---@field biggest_resource number Biggest resource tile found
---
--- Values calculated after completed layout placement
---@field drill_count number Total number of mining drills
---@field lane_count number Number of lanes
---@field inner_density number Density of tiles physically covered by drills
---@field outer_density number Pseudo (because of overlap) density of all tiles reached by drills
---@field centricity number Distance from center of mining drill bounds
---@field unconsumed number Unreachable resources count (usually insufficient drill reach)
---@field resource_sum_deviation number
---@field outer_sum_deviation number
---@field inner_sum_deviation number
---@field penalty number

---@return HeuristicsBlock
function common.init_heuristic_values()
	return {
		resource_sum = 0,
		biggest_resource = 0,
		inner_neighbor_sum = 0,
		outer_neighbor_sum = 0,
		empty_space = 0,
		leech_sum = 0,
		postponed_count = 0,

		drill_count = 1,
		lane_count = 1,
		inner_density = 1,
		outer_density = 1,
		centricity = 0,
		unconsumed = 0,
		penalty = 0,
	}
end

---@param H HeuristicsBlock
---@param M MinerStruct
---@param tile GridTile
---@param postponed boolean?
function common.add_heuristic_values(H, M, tile, postponed)
	H.resource_sum = H.resource_sum + tile.neighbors_amount
	H.inner_neighbor_sum = H.inner_neighbor_sum + tile.neighbors_inner
	H.outer_neighbor_sum = H.outer_neighbor_sum + tile.neighbors_outer
	H.empty_space = H.empty_space + (M.size_sq - tile.neighbors_inner)
	H.leech_sum = H.leech_sum + max(0, tile.neighbors_outer - tile.neighbors_inner)
	H.biggest_resource = max(H.biggest_resource, tile.amount)

	if postponed then H.postponed_count = H.postponed_count + 1 end
end

---@param attempt PlacementAttempt
---@param block HeuristicsBlock
---@param coords Coords
function common.finalize_heuristic_values(attempt, block, coords)
	local count = block.drill_count
	local biggest = block.biggest_resource
	block.drill_count = #attempt.miners
	block.lane_count = #attempt.lane_layout
	block.inner_density = block.inner_neighbor_sum / block.drill_count
	block.outer_density = block.outer_neighbor_sum / block.drill_count
	
	local function centricity(m1, m2, size)
		local center = size / 2
		local drill_middle = m1+(m2-m1)/2
		return center - drill_middle
	end
	local x = centricity(attempt.bx, attempt.b2x, coords.w)
	local y = centricity(attempt.by, attempt.b2y, coords.h)
	block.centricity = (x * x + y * y) ^ 0.5

	local resource_sum_deviation, resource_sum_avg = 0, block.resource_sum / biggest / count
	local outer_sum_deviation, outer_sum_avg = 0, block.outer_neighbor_sum / biggest / count
	local inner_sum_deviation, inner_sum_avg = 0, block.inner_density / biggest / count
	
	for _, miner in ipairs(attempt.miners) do
		resource_sum_deviation = resource_sum_deviation + (miner.tile.neighbors_amount / biggest - resource_sum_avg) ^ 2
		outer_sum_deviation = outer_sum_deviation + (miner.tile.convolve_outer / biggest - outer_sum_avg) ^ 2
		inner_sum_deviation = inner_sum_deviation + (miner.tile.convolve_inner / biggest - inner_sum_avg) ^ 2
	end
	block.resource_sum_deviation = (resource_sum_deviation / count) ^ 0.5
	block.outer_sum_deviation = (outer_sum_deviation / count) ^ 0.5
	block.inner_sum_deviation = (inner_sum_deviation / count) ^ 0.5
	block.penalty = common.heuristic_penalties(attempt)
end

---Utility to fill in postponed miners on unconsumed resources
---@param state SimpleState
---@param attempt PlacementAttempt
---@param miners MinerPlacement[]
---@param postponed MinerPlacement[]
---@return number #Cost of operation
function common.process_postponed(state, attempt, miners, postponed)
	local price = 0
	local grid = state.grid
	local M = state.miner

	local ext_negative, ext_positive = M.extent_negative, M.extent_positive
	local area, size = M.area, M.size
	local area_sq = M.area_sq
	local consume_cache = {}
	
	grid:clear_consumed(state.resource_tiles)
	
	for _, miner in ipairs(miners) do
		-- grid:consume(miner.x+ext_negative, miner.y+ext_negative, area)
		grid:consume_separable_horizontal(miner.x+ext_negative, miner.y+ext_negative, area, consume_cache)
		price = price + area
	end

	for tile, _ in pairs(consume_cache) do
		grid:consume_separable_vertical(tile.x, tile.y, area)
	end
	
	for _, miner in ipairs(postponed) do
		miner.unconsumed = grid:get_unconsumed(miner.x+ext_negative, miner.y+ext_negative, area)
		price = price + area
	end

	table.sort(postponed, function(a, b)
		if a.unconsumed == b.unconsumed then
			local atile, btile = a.tile, b.tile
			if atile.neighbors_outer == btile.neighbors_outer then
				return atile.neighbors_inner > btile.neighbors_inner
			end
			return atile.neighbors_outer > btile.neighbors_outer
		end
		return a.unconsumed > b.unconsumed
	end)

	for _, miner in ipairs(postponed) do
		local tile = miner.tile
		local unconsumed_count = grid:get_unconsumed(miner.x+ext_negative, miner.y+ext_negative, area)
		if unconsumed_count > 0 then
			common.add_heuristic_values(attempt.heuristics, M, tile, true)

			grid:consume(tile.x+ext_negative, tile.y+ext_negative, area)
			price = price + area_sq
			miners[#miners+1] = miner
			miner.postponed = true
		end
	end
	local unconsumed_sum = 0
	for _, tile in ipairs(state.resource_tiles) do
		if not tile.consumed then unconsumed_sum = unconsumed_sum + 1 end
	end
	attempt.heuristics.unconsumed = unconsumed_sum
	-- attempt.bx, attempt.by = bx, by
	
	-- grid:clear_consumed(state.resource_tiles)
	
	return price + #state.resource_tiles
end

local seed
local function get_map_seed()
	if seed then return seed end
	
	local game_exchange_string = game.get_map_exchange_string()
	local map_data = helpers.parse_map_exchange_string(game_exchange_string)

	local seed_number = map_data.map_gen_settings.seed
	seed = string.format("%x", seed_number)
	return seed
end

---Dump state to json for inspection
---@param state SimpleState
function common.save_state_to_file(state, type_)

	local c = state.coords
	local gx, gy = floor(c.gx), floor(c.gy)
	local dir = state.direction_choice

	local coverage = state.coverage_choice and "t" or "f"
	local filename = string.format("layout_%s_%i;%i_%s_%i_%s_%s_%x.%s", get_map_seed(), gx, gy, state.miner_choice, #state.resources, dir, coverage, game.tick, type_)

	state.power_grid = nil
	state.power_connectivity = nil
	
	if type_ == "json" then
		state._previous_state = nil
		game.print(string.format("Dumped data to %s ", filename))
		helpers.write_file("mpp-inspect/"..filename, helpers.table_to_json(state), false, state.player.index)
	elseif type_ == "lua" then
		game.print(string.format("Dumped data to %s ", filename))
		helpers.write_file("mpp-inspect/"..filename, serpent.dump(state, {}), false, state.player.index)
	end
end

---Determines if mining drill is restricted by the layout
---@param miner MinerStruct
---@param restrictions Restrictions
---@return boolean
function common.is_miner_restricted(miner, restrictions)
	return false
		or miner.size < restrictions.miner_size[1]
		or restrictions.miner_size[2] < miner.size
		or miner.radius < restrictions.miner_radius[1]
		or restrictions.miner_radius[2] < miner.radius
end

---Determines if transport belt is restricted by the layout
---@param belt BeltStruct
---@param restrictions Restrictions
function common.is_belt_restricted(belt, restrictions)
	return false
		or (restrictions.uses_underground_belts and not belt.related_underground_belt)
end

---Determines if power pole is restricted by the layout
---@param pole PoleStruct
---@param restrictions Restrictions
function common.is_pole_restricted(pole, restrictions)
	return false
		or pole.size < restrictions.pole_width[1]
		or restrictions.pole_width[2] < pole.size
		or pole.supply_area_distance < restrictions.pole_supply_area[1]
		or restrictions.pole_supply_area[2] < pole.supply_area_distance
		or pole.wire < restrictions.pole_length[1]
		or restrictions.pole_length[2] < pole.wire
end


local triangles = {
	west={
		{{-.6, 0}, {.6, -0.6}, {.6, 0.6}},
		{{-.4, 0}, {.5, -0.45}, {.5, 0.45}},
	},
	east={
		{{.6, 0}, {-.6, -0.6}, {-.6, 0.6}},
		{{.4, 0}, {-.5, -0.45}, {-.5, 0.45}},
	},
	north={
		{{0, -.6}, {-.6, .6}, {.6, .6}},
		{{0, -.4}, {-.45, .5}, {.45, .5}},
	},
	south={
		{{0, .6}, {-.6, -.6}, {.6, -.6}},
		{{0, .4}, {-.45, -.5}, {.45, -.5}},
	},
}
local alignment = {
	west={"center", "center"},
	east={"center", "center"},
	north={"left", "right"},
	south={"right", "left"},
}

local bound_alignment = {
	west="right",
	east="left",
	north="center",
	south="center",
}

---Draws a belt lane overlay
---@param state State
---@param belt BeltSpecification
function common.draw_belt_lane(state, belt)
	if not belt.has_drills then return end
	local r = state._render_objects
	local c, ttl, player = state.coords, 0, {state.player}
	local function l2w(x, y) -- local to world
		return mpp_util.revert(c.gx, c.gy, state.direction_choice, x, y, c.tw, c.th)
	end
	local c1, c2, c3 = {.9, .9, .9}, {0, 0, 0}, {.4, .4, .4}
	local w1, w2 = 4, 10
	if not belt.lane1 and not belt.lane2 then c1 = c3 end
	
	local overlay_line = belt.overlay_line
	if overlay_line then
		---@type List<LuaRenderObject>
		local background = List()
		local x1, y1, x2, y2 = nil, nil, overlay_line[1][1], overlay_line[1][2]
		
		r:push(rendering.draw_polygon{ -- background arrow
			surface=state.surface, players=player, only_in_alt_mode=true,
			width=w2, color=c2, time_to_live=ttl or 1,
			target=l2w(x2, y2),
			vertices=triangles[state.direction_choice][1],
		})
		
		for i = 2, #overlay_line do
			local step = overlay_line[i]
			if #step == 0 then goto continue end
			x1, y1, x2, y2 = x2, y2, step[1], step[2]
			background:push(rendering.draw_line{ -- background main line
				surface=state.surface, players=player, only_in_alt_mode=true,
				width=w2, color=c2, time_to_live=ttl or 1,
				from=l2w(x1, y1), to=l2w(x2, y2),
			})
			background:push(rendering.draw_circle{
				surface=state.surface, players=player, only_in_alt_mode=true,
				width=w2, color=c2, time_to_live=ttl or 1,
				target=l2w(x2, y2),
				filled = true, radius = w2 / 64,
			})
			r:push(rendering.draw_line{ -- main line
				surface=state.surface, players=player, only_in_alt_mode=true,
				width=w1, color=c1, time_to_live=ttl or 1,
				from=l2w(x1, y1), to=l2w(x2, y2),
			})
			r:push(rendering.draw_circle{
				surface=state.surface, players=player, only_in_alt_mode=true,
				width=w1, color=c1, time_to_live=ttl or 1,
				target=l2w(x2, y2),
				filled = true, radius = w1 / 64,
			})
			::continue::
		end
		
		background:push(rendering.draw_polygon{ -- background arrow
			surface=state.surface, players=player, only_in_alt_mode=true,
			width=w2, color=c2, time_to_live=ttl or 1,
			target=l2w(belt.x_start, belt.y),
			vertices=triangles[state.direction_choice][1],
		})
		r:push(rendering.draw_polygon{ -- arrow
			surface=state.surface, players=player, only_in_alt_mode=true,
			width=0, color=c1, time_to_live=ttl or 1,
			target=l2w(belt.x_start, belt.y),
			vertices=triangles[state.direction_choice][2],
		})
		
		background:push(rendering.draw_line{ -- background vertical cap
			surface=state.surface, players=player, only_in_alt_mode=true,
			width=w2, color=c2, time_to_live=ttl or 1,
			from=l2w(x2, y1-.6), to=l2w(x2, y2+.6),
		})
		r:push(rendering.draw_line{ -- vertical cap
			surface=state.surface, players=player, only_in_alt_mode=true,
			width=w1, color=c1, time_to_live=ttl or 1,
			from=l2w(x2, y1-.5), to=l2w(x2, y2+.5),
		})
		
		for _, obj in pairs(background) do
			obj.move_to_back()
			r:push(obj)
		end
	else
		-- simple output belt rendering
		local x1, y1, x2, y2 = belt.x_start, belt.y, math.max(belt.x_entry+2, belt.x2), belt.y
		r:push(rendering.draw_line{ -- background main line
			surface=state.surface, players=player, only_in_alt_mode=true,
			width=w2, color=c2, time_to_live=ttl or 1,
			from=l2w(x1, y1), to=l2w(x2+.5, y1),
		})
		r:push(rendering.draw_line{ -- background vertical cap
			surface=state.surface, players=player, only_in_alt_mode=true,
			width=w2, color=c2, time_to_live=ttl or 1,
			from=l2w(x2+.5, y1-.6), to=l2w(x2+.5, y2+.6),
		})
		r:push(rendering.draw_polygon{ -- background arrow
			surface=state.surface, players=player, only_in_alt_mode=true,
			width=w2, color=c2, time_to_live=ttl or 1,
			target=l2w(x1, y1),
			vertices=triangles[state.direction_choice][1],
		})
		r:push(rendering.draw_line{ -- main line
			surface=state.surface, players=player, only_in_alt_mode=true,
			width=w1, color=c1, time_to_live=ttl or 1,
			from=l2w(x1-.2, y1), to=l2w(x2+.5, y1),
		})
		r:push(rendering.draw_line{ -- vertical cap
			surface=state.surface, players=player, only_in_alt_mode=true,
			width=w1, color=c1, time_to_live=ttl or 1,
			from=l2w(x2+.5, y1-.5), to=l2w(x2+.5, y2+.5),
		})
		r:push(rendering.draw_polygon{ -- arrow
			surface=state.surface, players=player, only_in_alt_mode=true,
			width=0, color=c1, time_to_live=ttl or 1,
			target=l2w(x1, y1),
			vertices=triangles[state.direction_choice][2],
		})
	end
end

---Draws a belt lane overlay
---@param state State
---@param belt BeltSpecification
function common.draw_belt_stats(state, belt, belt_speed, speed1, speed2, stagger)
	if not belt.has_drills then return end
	stagger = stagger or 0
	local r = state._render_objects
	local c, ttl, player = state.coords, 0, {state.player}
	local x1, y1, x2, y2 = belt.x_start, belt.y, belt.x2, belt.y
	local function l2w(x, y) -- local to world
		return mpp_util.revert(c.gx, c.gy, state.direction_choice, x, y, c.tw, c.th)
	end
	local c1, c2, c3, c4 = {.9, .9, .9}, {0, 0, 0}, {1, .2, 0}, {.4, .4, .4}
	x1 = x1 + stagger
	local capacity_mult = 1
	if state.use_stack_capacity_multiplier_choice then
		capacity_mult = 1 + state.player.force.belt_stack_size_bonus
	end
	
	local ratio1 = speed1
	local ratio2 = speed2
	local function get_color(ratio)
		return ratio > capacity_mult + .01 and c3 or ratio == 0 and c4 or c1
	end
	local function cap_prod(speed)
		return min(capacity_mult, speed) * belt_speed, speed > capacity_mult and  "+" or ""
	end
	
	r[#r+1] = rendering.draw_text{
		surface=state.surface, players=player, only_in_alt_mode=true,
		color=get_color(ratio1), time_to_live=ttl or 1,
		alignment=alignment[state.direction_choice][1], vertical_alignment="middle",
		target=l2w(x1-2, y1-.6), scale=1.6,
		text=string.format("%.2f%s/s", cap_prod(ratio1))
	}
	r[#r+1] = rendering.draw_text{
		surface=state.surface, players=player, only_in_alt_mode=true,
		color=get_color(ratio2), time_to_live=ttl or 1,
		alignment=alignment[state.direction_choice][2], vertical_alignment="middle",
		target=l2w(x1-2, y1+.6), scale=1.6,
		text=string.format("%.2f%s/s", cap_prod(ratio2))
	}
	local total_ratio = min(capacity_mult, ratio1) + min(capacity_mult, ratio2)
	local total_color = c1
	if ratio1 > capacity_mult or ratio2 > capacity_mult then
		total_color = c3
	end
	local accomodation = c.is_horizontal and -5.5 or -3.5
	r[#r+1] = rendering.draw_text{
		surface=state.surface, players=player, only_in_alt_mode=true,
		color=total_color, time_to_live=ttl or 1,
		alignment="center", vertical_alignment="middle",
		target=l2w(x1+accomodation, y1), scale=2,
		text=string.format("%.2f%s/s", min(2*capacity_mult, total_ratio) * belt_speed, (ratio1>capacity_mult or ratio2>capacity_mult) and  "+" or "")
	}
end

---Draws a belt lane overlay
---@param state State
---@param pos_x number
---@param pos_y number
---@param speed number Belt speed
---@param capped1 number
---@param capped2 number
---@param uncapped1 number
---@param uncapped2 number
function common.draw_belt_total(state, pos_x, pos_y, speed, capped1, capped2, uncapped1, uncapped2)
	local r = state._render_objects
	local c, ttl, player = state.coords, 0, {state.player}
	local function l2w(x, y, b) -- local to world
		if ({south=true, north=true})[state.direction_choice] then
			x = x + (b and -.5 or .5)
			y = y + (b and -.5 or .5)
		end
		return mpp_util.revert(c.gx, c.gy, state.direction_choice, x, y, c.tw, c.th)
	end
	local c1 = {0.7, 0.7, 1.0}

	local lower_bound = math.min(capped1, capped2)
	local upper_bound = math.max(capped1, capped2)
	local capped_total = capped1+capped2
	local uncapped_total = uncapped1 + uncapped2
	local unused_capacity = uncapped_total - capped_total

	r:push(rendering.draw_text{
		surface=state.surface, players=player, only_in_alt_mode=true,
		color=c1, time_to_live=ttl or 1,
		alignment="center", vertical_alignment="middle",
		target=l2w(pos_x-4, pos_y-.6, false), scale=2,
		-- text={"mpp.msg_print_info_lane_saturation_belts", string.format("%.2fx", upper_bound), },
		text = {"mpp.msg_print_info_lane_throuput_total", ("%.2f"):format(capped_total*speed), ceil(upper_bound)},
	})
	if unused_capacity > 0 then
		local color = unused_capacity > capped_total * .1 and {1, .2, 0} or {1, 1, 1}
		r:push(rendering.draw_text{
			surface=state.surface, players=player, only_in_alt_mode=true,
			color=color, time_to_live=ttl or 1,
			alignment="center", vertical_alignment="middle",
			target=l2w(pos_x-4, pos_y+.6, true), scale=2,
			-- text={"mpp.msg_print_info_lane_saturation_bounds", string.format("%.2fx", lower_bound), string.format("%.2fx", upper_bound)},
			text = {"mpp.msg_print_info_lane_throuput_unused", ("%.2f"):format(unused_capacity*speed)},
		})
	end
end

---@param state State
---@return number
function common.get_mining_drill_production_from_state(state)
	local drill_speed = prototypes.entity[state.miner_choice].mining_speed
	local belt_speed = prototypes.entity[state.belt_choice].belt_speed * 60 * 4
	local dominant_resource = state.resource_counts[1].name
	local resource_hardness = prototypes.entity[dominant_resource].mineable_properties.mining_time or 1
	local drill_productivity, module_speed = 1, 1
	if state.miner.uses_force_mining_productivity_bonus then
		drill_productivity = drill_productivity + state.player.force.mining_drill_productivity_bonus
	end
	local function quality_clamp(val, level) return floor((val + val * .3 * level) * 100)/100 end
	if state.module_choice ~= "none" then
		local mod = prototypes.item[state.module_choice]
		local level = prototypes.quality[state.module_quality_choice].level
		local speed = mod.module_effects.speed and mod.module_effects.speed or 0
		local productivity = mod.module_effects.productivity and mod.module_effects.productivity or 0
		if mod.category == "speed" then
			speed = quality_clamp(speed, level)
		elseif mod.category == "productivity" then
			productivity = quality_clamp(productivity, level)
		end
		module_speed = module_speed + speed * state.miner.module_inventory_size
		drill_productivity = drill_productivity + productivity * state.miner.module_inventory_size
	end
	local multiplier = drill_speed / resource_hardness * module_speed * drill_productivity
	return multiplier
end

---@class BeltThroughput
---@field lane1 number
---@field lane2 number
---@field direction defines.direction

---Belt creation environment
---@param state SimpleState
---@return BeltEnvironment
---@return GhostSpecification[]
---@return DeconstructSpecification[]
function common.create_belt_building_environment(state)
	local G, M, B = state.grid, state.miner, state.belt
	local table_insert = table.insert

	local belts = state.belts
	local belt_count = #belts
	local belt_choice = state.belt_choice
	local underground_choice = B.related_underground_belt
	local quality_choice = state.belt_quality_choice

	-- Function verb explanation
	-- create - add specific entity to the builder list (like LuaSurface.create_entity)
	-- place  - utility function to place specific belt structures like lines
	-- make   - utility function that makes belt structures defined in belt specification

	-- Indexing the virtual grid for built things should be mostly inside the bounds of the resource patch
	
	---@type GhostSpecification[]
	local builder_belts = {}
	local deconstruct_spec = List()
	---@class BeltEnvironment
	local environment = {
		builder_belts = builder_belts,
		deconstruct_specification = deconstruct_spec
	}

	---Base utility function to create belt tiles
	---@param x any
	---@param y any
	---@param direction any
	local function create_belt(x, y, direction)
		table_insert(builder_belts, {
			name = belt_choice, quality = quality_choice,
			thing = "belt", grid_x = x, grid_y = y,
			direction = direction,
		})
		-- do not do G:build_thing_simple(x, y, "belt") here
		-- commit belts with common.commit_built_tiles_to_grid after planning
	end
	environment.create_belt = create_belt

	---Base utility function to create belt tiles
	---@param x any
	---@param y any
	---@param direction any
	---@param belt_type "input" | "output"
	local function create_underground(x, y, direction, belt_type)
		table_insert(builder_belts, {
			name = underground_choice, quality = quality_choice,
			thing = "belt", grid_x = x, grid_y = y,
			direction = direction, type = belt_type or "input",
		})
	end
	environment.create_underground = create_underground

	---Utility function to create underground belt tiles
	---@param x number
	---@param y1 number
	---@param y2 number
	---@param direction defines.direction
	local function place_vertical_belt(x, y1, y2, direction)
		for y = min(y1, y2), max(y1, y2) do
			create_belt(x, y, direction)
		end
	end
	environment.place_vertical_belt = place_vertical_belt

	---@param x1 number
	---@param x2 number
	---@param y number
	---@param direction defines.direction
	local function place_horizontal_belt(x1, x2, y, direction)
		for x = min(x1, x2), max(x1, x2) do
			create_belt(x, y, direction)
		end
	end
	environment.place_horizontal_belt = place_horizontal_belt

	---@param belt BaseBeltSpecification
	local function make_output_belt(belt, endpoint)
		if endpoint == nil then endpoint = belt.x2 end
		place_horizontal_belt(belt.x_start, endpoint, belt.y, WEST)
	end
	environment.make_output_belt = make_output_belt

	---@param x number
	---@param y1 number
	---@param y2 number
	---@param direction? defines.direction.north | defines.direction.south
	local function gap_exists(x, y1, y2, direction)
		y1, y2 = min(y1, y2), max(y1, y2)
		local s1, s2 = 0, 0
		if direction == NORTH then
			s1, s2 = 1, 0
		elseif direction == SOUTH then
			s1, s2 = 0, -1
		end
		for y = y1+s1, y2+s2 do
			local tile = G[y][x]
			if tile.built_thing then
				return false, 0, 0
			end
		end
		return true, y1+s1, y2+s2
	end
	environment.gap_exists = gap_exists
	
	---@param belt BaseBeltSpecification
	local function make_side_merge_belt(belt)
		---@type defines.direction.east | defines.direction.west
		local belt_direction = EAST -- merge output to left of right of belt
		local vertical_dir = belt.merge_direction
		local target = belt.merge_target --[[@as BaseBeltSpecification]]
		local s_entry, t_entry = belt.x_entry, target.x_entry
		local y = belt.y
		
		local lane = vertical_dir == NORTH and target.lane2 or target.lane1
		if lane then
			t_entry = lane[1].x - 1
		end
		
		local merge_x = nil
		local exists, y1, y2, accomodation = false, 0, 0, 0
		if target.x_start <= t_entry and t_entry < s_entry then
			local entry = min(s_entry, t_entry)
			for x = entry, target.x_start, -1 do
				exists, y1, y2 = gap_exists(x, belt.y, target.y, vertical_dir)
				if exists then
					merge_x, accomodation = x, 1
					break
				end
			end
		end
		if merge_x == nil then
			belt_direction = WEST
			local entry = belt.x_end
			for x = entry, target.x_end+M.outer_span do
				exists, y1, y2 = gap_exists(x, belt.y, target.y, vertical_dir)
				if exists then
					merge_x, accomodation = x, -1
					break
				end
			end
		end
		
		if merge_x and belt_direction == EAST then
			-- found spot to merge at the front
			place_horizontal_belt(merge_x+accomodation, belt.x2, y, WEST) -- main belt
			place_vertical_belt(merge_x, y1, y2, vertical_dir) -- vertical segment
		elseif merge_x and belt_direction == WEST then
			-- found spot to merge at the back
			place_horizontal_belt(belt.x1, merge_x+accomodation, y, EAST) -- main belt
			place_vertical_belt(merge_x, y1, y2, vertical_dir) -- vertical segment
			if merge_x >= target.x2 + 1 then
				place_horizontal_belt(target.x2+1, merge_x+1, target.y, WEST) -- target merge accomodation
			end
		else
			-- fallback
			belt.is_output = true
			make_output_belt(belt)
		end
	end
	environment.make_side_merge_belt = make_side_merge_belt
	
	---@param belt BaseBeltSpecification
	local function make_back_merge_belt(belt)
		local vertical_dir = belt.merge_direction
		local target = belt.merge_target --[[@as BaseBeltSpecification]]
		local y = belt.y
		local yt = target.y
		
		local merge_x = nil
		local entry = max(belt.x2+1, target.x2+1)
		for x = entry, max(belt.x2, target.x2)+M.size do
			exists, y1, y2 = gap_exists(x, belt.y, target.y, vertical_dir)
			if exists then
				merge_x, accomodation = x, -1
				break
			end
		end
		
		if merge_x then
			place_horizontal_belt(belt.x1, merge_x+accomodation, y, EAST) -- main belt
			place_vertical_belt(merge_x, y1, y2, vertical_dir) -- vertical segment
			place_horizontal_belt(target.x2+1, merge_x, target.y, WEST) -- target merge accomodation
			target.overlay_line = {{target.x_start, yt}, {merge_x, yt}, {merge_x, y}, {belt.x1, y}}
		else
			place_horizontal_belt(belt.x_start, belt.x2, y, WEST)
		end
	end
	environment.make_back_merge_belt = make_back_merge_belt
	
	---@param x1 number
	---@param x2 number
	---@param y number
	---@param open_capstone boolean If open, place an underground output belt
	local function place_interleaved_belt_west(x1, x2, y, open_capstone)
		local row = G[y]
		local tile_before, tile, tile_ahead = nil, row[x1-1], row[x1]
		
		for x = x1, x2-1 do
			tile_before, tile, tile_ahead = tile, tile_ahead, row[x+1]
			local free = tile.built_thing
			if free ~= nil then
				-- no op
			elseif tile_before.built_thing ~= nil then
				create_underground(x, y, WEST, "input")
			elseif tile_ahead.built_thing ~= nil then
				create_underground(x, y, WEST, "output")
			else
				create_belt(x, y, WEST)
			end
		end
		
		tile_before, tile, tile_ahead = tile, tile_ahead, row[x2+1]
		if open_capstone and tile_ahead.built_thing ~= nil then
			create_belt(x2, y, WEST)
		elseif tile_before.built_thing ~= nil then
			create_underground(x2, y, WEST, "input")
		else
			create_belt(x2, y, WEST)
		end
	end
	environment.place_interleaved_belt_west = place_interleaved_belt_west

	---@param belt BaseBeltSpecification
	local function make_interleaved_output_belt(belt, open_capstone)
		place_interleaved_belt_west(belt.x_start, belt.x2, belt.y, open_capstone)
	end
	environment.make_interleaved_output_belt = make_interleaved_output_belt

	local function place_interleaved_belt_east(x1, x2, y)
		local row = G[y]
		local tile_before, tile, tile_ahead = nil, row[x1], row[x1+1]
		
		if tile_ahead.built_thing ~= nil then
			create_underground(x1, y, WEST, "output")
		else
			create_belt(x1, y, EAST)
		end
		
		for x = x1+1, x2 do
			tile_before, tile, tile_ahead = tile, tile_ahead, row[x+1]
			local free = tile.built_thing
			if free ~= nil then
				-- no op
			elseif tile_before.built_thing ~= nil then
				create_underground(x, y, EAST, "output")
			elseif tile_ahead.built_thing ~= nil then
				create_underground(x, y, EAST, "input")
			else
				create_belt(x, y, EAST)
			end
		end
	end
	environment.place_interleaved_belt_east = place_interleaved_belt_east

	---@param belt BaseBeltSpecification
	local function make_interleaved_back_merge_belt(belt)
		local vertical_dir = belt.merge_direction
		local target = belt.merge_target --[[@as BaseBeltSpecification]]
		local y = belt.y
		local yt = target.y
		
		local s_row, t_row = G[y], G[target.y]
		
		local merge_x = nil
		local entry = max(belt.x2+1, target.x2)
		local free_entry = s_row[entry-1].built_thing == nil and t_row[entry-1].built_thing == nil
		for x = entry, max(belt.x2, target.x_end)+M.size do
			if s_row[x-1].built_thing or s_row[x+1].built_thing then
				goto continue
			end
			exists, y1, y2 = gap_exists(x, belt.y, target.y, vertical_dir)
			if free_entry and exists then
				merge_x, accomodation = x, -1
				break
			end
			::continue::
			free_entry = s_row[x].built_thing == nil and t_row[x].built_thing == nil
		end
		
		if merge_x then
			place_interleaved_belt_east(belt.x1, merge_x+accomodation, y) -- main belt
			place_vertical_belt(merge_x, y1, y2, vertical_dir) -- vertical segment
			place_interleaved_belt_west(target.x_start, merge_x, target.y, merge_x == target.x2)
			target.overlay_line = {{target.x_start, yt}, {merge_x, yt}, {merge_x, y}, {belt.x1, y}}
		else
			state.player.print("Failed placing a belt")
		end
	end
	environment.make_interleaved_back_merge_belt = make_interleaved_back_merge_belt
	
	---@param belt BaseBeltSpecification
	---@param opts {x1:number, x2:number, direction:defines.direction}?
	local function place_sparse_belt(belt, opts)
		opts = opts or {}
		local lane1, lane2 = belt.lane1, belt.lane2
		local y = belt.y
		local x1 = opts.x1 or belt.x_start
		local x2 = opts.x2 or belt.x2
		local out_x1, out_x2 = M.output_rotated[SOUTH].x, M.output_rotated[NORTH].x
		local function get_lane_length(lane) if lane then return lane[#lane].x end return 0 end
		if opts.x2 then
			-- no op
		elseif lane1 and lane2 then
			x2 = max(get_lane_length(lane1)+out_x1, get_lane_length(lane2)+ out_x2+1)
		elseif lane1 then
			x2 = get_lane_length(lane1) + out_x1
		else
			x2 = get_lane_length(lane2) + out_x2 + 1
		end
		
		if lane2 then
			local out_x = M.output_rotated[NORTH].x
			for _, miner in ipairs(lane2) do
				local my = miner.y
				place_vertical_belt(miner.x + out_x, y + 1, my - 1, NORTH)
			end
		end
		
		place_horizontal_belt(x1, x2, y, opts.direction or WEST)
	end
	environment.place_sparse_belt = place_sparse_belt
	
	local function make_sparse_output_belt(belt, x)
		place_sparse_belt(belt, {x1 = x or belt.x_start})
	end
	environment.make_sparse_output_belt = make_sparse_output_belt
	
	---@param belt BaseBeltSpecification
	local function make_sparse_back_merge_belt(belt)
		local vertical_dir = belt.merge_direction
		local target = belt.merge_target --[[@as BaseBeltSpecification]]
		local y = belt.y
		local yt = target.y
		
		local s_row, t_row = G[y], G[target.y]
		
		local merge_x = nil
		local entry = max(belt.x2+1, target.x2)
		local free_entry = s_row[entry-1].built_thing == nil and t_row[entry-1].built_thing == nil
		for x = entry, max(belt.x2, target.x_end)+M.size do
			if s_row[x-1].built_thing or s_row[x+1].built_thing then
				goto continue
			end
			exists, y1, y2 = gap_exists(x, belt.y, target.y, vertical_dir)
			if free_entry and exists then
				merge_x, accomodation = x, -1
				break
			end
			::continue::
			free_entry = s_row[x].built_thing == nil and t_row[x].built_thing == nil
		end
		
		if merge_x then
			place_sparse_belt(belt, {x1 = belt.x1, direction = EAST, x2 = merge_x+accomodation})
			place_vertical_belt(merge_x, y1, y2, vertical_dir) -- vertical segment
			place_sparse_belt(target, {x1 = target.x_start, x2 = merge_x}) -- target belt
			target.overlay_line = {{target.x_start, yt}, {merge_x, yt}, {merge_x, y}, {belt.x1, y}}
		else
			state.player.print("Failed placing a belt")
		end
	end
	environment.make_sparse_back_merge_belt = make_sparse_back_merge_belt
	
	---@param belt BaseBeltSpecification
	local function make_sparse_side_merge_belt(belt)
		make_side_merge_belt(belt)
		local y = belt.y
		
		local lane2 = belt.lane2
		if lane2 then
			local out_x = M.output_rotated[NORTH].x
			for _, miner in ipairs(lane2) do
				local my = miner.y
				place_vertical_belt(miner.x + out_x, y + 1, my - 1, NORTH)
			end
		end
	end
	environment.make_sparse_side_merge_belt = make_sparse_side_merge_belt
	
	return environment, builder_belts, deconstruct_spec
end

local clamped_rotation = mpp_util.clamped_rotation

---@param belt_direction defines.direction
---@param drill_directions table<defines.direction, 1>
function common.get_belt_lane_inputs(belt_direction, drill_directions)
	local lane1, lane2 = 0, 0
	for unrot_drill_dir, count in pairs(drill_directions) do
		local drill_dir = clamped_rotation(unrot_drill_dir - belt_direction)
		if drill_dir == EAST then
			lane2 = lane2 + count
		else
			lane1 = lane1 + count
		end
	end
	return lane1, lane2
end

---@param state SimpleState
function common.display_lane_filling(state)
	if not state.display_lane_filling_choice or not state.belts or not state.belt then return end

	local belt_speed = state.belt.speed
	local capacity_mult = 1
	if state.use_stack_capacity_multiplier_choice then
		capacity_mult = 1 + state.player.force.belt_stack_size_bonus
	end
	
	local belts = state.belts
	local throughput_capped1, throughput_capped2 = 0, 0
	local throughput_total1, throughput_total2 = 0, 0
	local do_stagger, y_stagger = false, 0
	if state.coords.is_vertical and #belts > 1 and belts[2].y - belts[1].y < 6 then
		do_stagger, y_stagger = true, .4
	end

	for i, belt in pairs(belts) do
		---@cast belt BeltSpecification
		if belt.merge_direction or (not belt.lane1 and not belt.lane2) then goto continue end

		local speed1, speed2 = belt.merged_throughput1, belt.merged_throughput2

		throughput_capped1 = throughput_capped1 + math.min(capacity_mult, speed1)
		throughput_capped2 = throughput_capped2 + math.min(capacity_mult, speed2)
		throughput_total1 = throughput_total1 + speed1
		throughput_total2 = throughput_total2 + speed2

		common.draw_belt_lane(state, belt)
		if do_stagger ~= true then
			common.draw_belt_stats(state, belt, belt_speed, speed1, speed2, 0)
		elseif i % 2 == 0 then
			common.draw_belt_stats(state, belt, belt_speed, speed1, speed2, -y_stagger)
		else
			common.draw_belt_stats(state, belt, belt_speed, speed1, speed2, y_stagger)
		end
		::continue::
	end
	
	if #belts > 1 then
		local x = state.best_attempt.sx + 2
		local y = belts[1].y
		if state.direction_choice == "east" then
			y = belts[state.belt_count].y + 6
		elseif state.coords.is_vertical then
			y = y + (belts[state.belt_count].y - y) / 2 + 3
			x = x - 6
		end

		common.draw_belt_total(
			state, x, y - 3, belt_speed,
			throughput_capped1, throughput_capped2,
			throughput_total1, throughput_total2
		)
	end

	--local lanes = math.ceil(math.max(throughput1, throughput2))
	--state.player.print("Enough to fill "..lanes.." belts after balancing")
end

---@param grid Grid
---@param things GhostSpecification[]
---@param typ GridBuilding
function common.commit_built_tiles_to_grid(grid, things, typ)
	typ = typ or "other"
	for _, v in pairs(things) do
		grid[v.grid_y][v.grid_x].built_thing = typ
	end
end

---@param state MinimumPreservedState
function common.give_belt_blueprint(state)
	local belts = state.belts
	
	if belts == nil or #belts == 0 then return end
	
	---@type BeltPlannerSpecification
	local belt_planner_spec = {
		surface = state.surface,
		player = state.player,
		coords = state.coords,
		direction_choice = state.direction_choice,
		belt_choice = state.belt_choice,
		count = 0,
		ungrouped = true,
		_renderables = {},
	}
	
	table.sort(belts, function(a, b) return a.y < b.y end)
	
	local count = 0
	for index, belt in pairs(belts) do
		if belt.is_output == true then
			count = count + 1
			belt.index = count
			belt_planner_spec[count] = table.deepcopy(belt)
		end
	end
	
	local converter = mpp_util.reverter_delegate(state.coords, state.direction_choice)
	
	for i, belt in ipairs(belt_planner_spec) do
		local index = count - i + 1
		belt.index = index
		local gx, gy = converter(belt.x_start-1, belt.y)
		belt.world_x = gx
		belt.world_y = gy
		
		-- rendering.draw_circle{
		-- 	surface = state.surface,
		-- 	target = {gx+.5, gy+.5},
		-- 	radius = 0.45,
		-- 	width = 3,
		-- 	color = {1, 1, 1},
		-- }
		
		-- rendering.draw_text{
		-- 	surface = state.surface,
		-- 	target = {gx+.5, gy},
		-- 	color = {1, 1, 1},
		-- 	text = index,
		-- 	alignment= "center",
		-- 	scale = 2,
		-- }
	end
	
	belt_planner_spec.count = count
	belt_planner_spec.ungrouped = true
	
	belt_planner.push_belt_planner_step(state.player.index, belt_planner_spec)

	return belt_planner.give_blueprint(state, belt_planner_spec)
end

function common.create_pipe_building_environment(state)
	local G = state.grid
	
	local pipe = state.pipe_choice
	local pipe_quality = state.pipe_quality_choice

	local ground_pipe, ground_proto = mpp_util.find_underground_pipe(pipe)
	---@cast ground_pipe string
	local step, span
	if ground_proto then
		step = ground_proto.max_underground_distance
		span = step + 1
	end
	
	---@type GhostSpecification[]
	local builder_pipes = state.builder_pipes or {}
	local deconstruct_spec = List()
	---@class PipeEnvironment
	local environment = {
		builder_pipes = builder_pipes,
		deconstruct_specification = deconstruct_spec
	}
	
	local function que_entity(t)
		builder_pipes[#builder_pipes+1] = t
		G:build_thing_simple(t.grid_x, t.grid_y, "pipe")
	end
	
	local function horizontal_underground(x, y, w)
		que_entity{name=ground_pipe, quality=pipe_quality, thing="pipe", grid_x=x, grid_y=y, direction=WEST}
		que_entity{name=ground_pipe, quality=pipe_quality, thing="pipe", grid_x=x+w, grid_y=y, direction=EAST}
	end
	local function horizontal_filled(x1, y, w)
		for x = x1, x1+w do
			que_entity{name=pipe, quality=pipe_quality, thing="pipe", grid_x=x, grid_y=y}
		end
	end
	local function vertical_filled(x, y1, h)
		for y = y1, y1 + h do
			que_entity{name=pipe, quality=pipe_quality, thing="pipe", grid_x=x, grid_y=y}
		end
	end
	local function cap_vertical(x, y, skip_up, skip_down)
		que_entity{name=pipe, quality=pipe_quality, thing="pipe", grid_x=x, grid_y=y}

		if not ground_pipe then return end
		if not skip_up then
			que_entity{name=ground_pipe, quality=pipe_quality, thing="pipe", grid_x=x, grid_y=y-1, direction=SOUTH}
		end
		if not skip_down then
			que_entity{name=ground_pipe, quality=pipe_quality, thing="pipe", grid_x=x, grid_y=y+1, direction=NORTH}
		end
	end
	local function joiner_vertical(x, y, h, belt_y)
		if h <= span then return end
		local quotient, remainder = math.divmod(h, span)
		function make_points(step_size)
			local t = {}
			for i = 1, quotient do
				t[#t+1] = y+i*step_size-1
			end
			return t
		end
		local stepping = make_points(ceil(h / (quotient+1)))
		local overlaps = false
		for _, py in ipairs(stepping) do
			if py == belt_y or (py+1) == belt_y then
				overlaps = true
				break
			end
		end
		if overlaps then
			quotient = quotient+1
			stepping = make_points(ceil(h / (quotient+1)))
		end
		
		for _, py in ipairs(stepping) do
			que_entity{
				name=ground_pipe,
				quality=pipe_quality,
				thing="pipe",
				grid_x=x,
				grid_y = py,
				direction=SOUTH,
			}
			que_entity{
				name=ground_pipe,
				quality=pipe_quality,
				thing="pipe",
				grid_x=x,
				grid_y = py+1,
				direction=NORTH,
			}
		end
		
	end
	
	local function cap_vertical_high(x, y, skip_up, skip_down, lane1, lane2)
		if not ground_pipe then return end
		if not skip_up then
			que_entity{name=ground_pipe, quality=pipe_quality, thing="pipe", grid_x=x, grid_y=y-2, direction=SOUTH}
		end
		if lane1 or not skip_up then
			que_entity{name=pipe, quality=pipe_quality, thing="pipe", grid_x=x, grid_y=y-1}
		end
		if lane1 and lane2 then
			que_entity{name=pipe, quality=pipe_quality, thing="pipe", grid_x=x, grid_y=y}
		end
		if lane2 or not skip_down then
			que_entity{name=pipe, quality=pipe_quality, thing="pipe", grid_x=x, grid_y=y+1}
		end
		if not skip_down then
			que_entity{name=ground_pipe, quality=pipe_quality, thing="pipe", grid_x=x, grid_y=y+2, direction=NORTH}
		end
	end
	
	local function process_specification(spec)
		for _, p in ipairs(spec) do
			local structure = p.structure
			local x1, w, y1, h = p.x, p.w, p.y, p.h
			if structure == "horizontal" then
				if not ground_pipe then
					horizontal_filled(x1, y1, w)
					goto continue_pipe
				end
	
				local quotient, remainder = math.divmod(w, span)
				for j = 1, quotient do
					local x = x1 + (j-1)*span
					horizontal_underground(x, y1, step)
				end
				local x = x1 + quotient * span
				if remainder >= 2 then
					horizontal_underground(x, y1, remainder)
				else
					horizontal_filled(x, y1, remainder)
				end
			elseif structure == "vertical" then
				vertical_filled(x, y1, h)
			elseif structure == "cap_vertical" then
				cap_vertical(x1, y1, p.skip_up, p.skip_down)
			elseif structure == "joiner_vertical" then
				joiner_vertical(x1, y1, h, p.belt_y)
			elseif structure == "cap_vertical_high" then
				cap_vertical_high(x1, y1, p.skip_up, p.skip_down, p.lane1, p.lane2)
			end
			::continue_pipe::
		end
	end
	environment.process_specification = process_specification
	
	return environment
end

return common

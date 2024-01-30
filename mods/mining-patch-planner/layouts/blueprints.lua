local floor, ceil = math.floor, math.ceil
local min, max = math.min, math.max

local base = require("layouts.base")
local grid_mt = require("grid_mt")
local mpp_util = require("mpp_util")
local coord_convert, coord_revert = mpp_util.coord_convert, mpp_util.coord_revert
local bp_direction = mpp_util.bp_direction

---@class BlueprintLayout : Layout
local layout = table.deepcopy(base)

---@class BlueprintState : SimpleState
---@field bp_w number
---@field bp_h number
---@field attempts BpPlacementAttempt[]
---@field best_attempt BpPlacementAttempt
---@field beacons BpPlacementEnt[]
---@field builder_power_poles BpPlacementEnt[]
---@field lamps BpPlacementEnt[]

--- Coordinate space for the attempt
---@class BpPlacementAttempt : PlacementAttempt
---@field other_ents BpPlacementEnt[]
---@field s_ix number Current blueprint metatile x
---@field s_iy number Current blueprint metatile y
---@field s_ie number Current entity index
---@field x number x start
---@field y number y start
---@field cx number number of blueprint repetitions on x axis
---@field cy number number of blueprint repetitions on y axis


---@class BpPlacementEnt
---@field ent BlueprintEntityEx
---@field center GridTile
---@field x number
---@field y number
---@field direction defines.direction

layout.name = "blueprints"
layout.translation = {"mpp.settings_layout_choice_blueprints"}

layout.restrictions.miner_available = false
layout.restrictions.belt_available = false
layout.restrictions.pole_available = false
layout.restrictions.lamp_available = false
layout.restrictions.coverage_tuning = true
layout.restrictions.landfill_omit_available = true
layout.restrictions.start_alignment_tuning = true

---Called from script.on_load
---@param self BlueprintLayout
---@param state BlueprintState
function layout:on_load(state)
	if state.grid then
		setmetatable(state.grid, grid_mt)
	end
end

---@param self BlueprintLayout
---@param state BlueprintState
function layout:validate(state)
	return base.validate(self, state)
end

---@param self BlueprintLayout
---@param state BlueprintState
function layout:start(state)
	local grid = {}
	local c = state.coords
	local bp = state.cache

	bp.tw, bp.th = bp.w, bp.h
	local th, tw = c.h, c.w
	if state.direction_choice == "south" or state.direction_choice == "north" then
		th, tw = tw, th
		bp.tw, bp.th = bp.h, bp.w
	end
	c.th, c.tw = th, tw

	for y = -bp.h, th+bp.h do
		local row = {}
		grid[y] = row
		for x = -bp.w, tw+bp.w do
			row[x] = {
				resources = 0,
				x = x, y = y,
				gx = c.x1 + x, gy = c.y1 + y,
				consumed = false,
				built_on = false,
				neighbor_counts = {},
			}
		end
	end

	state.grid = setmetatable(grid, grid_mt)
	return "process_grid"
end

---Called from script.on_load
---@param self BlueprintLayout
---@param state BlueprintState
function layout:process_grid(state)
	local c = state.coords
	local grid = state.grid
	local resources = state.resources
	local conv = coord_convert[state.direction_choice]
	local gx, gy = state.coords.gx, state.coords.gy
	local gw, gh = state.coords.w, state.coords.h
	local resources = state.resources

	state.resource_tiles = state.resource_tiles or {}
	local resource_tiles = state.resource_tiles

	local convolve_size = 0
	local convolve_steps = {}
	for _, miner in pairs(state.cache.miners) do
		---@cast miner MinerStruct
		convolve_size = miner.full_size ^ 2 + miner.size ^ 2
		convolve_steps[miner.far] = true
		convolve_steps[miner.near] = true
	end
	local budget, cost = 12000, 0

	local i = state.resource_iter or 1
	while i <= #resources and cost < budget do
		local r = resources[i]
		local x, y = r.position.x, r.position.y
		local tx, ty = conv(x-gx, y-gy, gw, gh)
		local tile = grid:get_tile(tx, ty)
		tile.amount = r.amount
		for width, _ in pairs(convolve_steps) do
			grid:convolve_custom(tx, ty, width)
		end
		resource_tiles[#resource_tiles+1] = tile
		cost = cost + convolve_size
		i = i + 1

		--[[ debug visualisation - resource
		rendering.draw_circle{
			surface = state.surface,
			filled = false,
			color = {0, 1, 0.3},
			width = 1,
			target = {c.gx + tx, c.gy + ty},
			radius = 0.5,
		}
		--]]
	end
	state.resource_iter = i

	if state.resource_iter >= #state.resources then
		return "init_first_pass"
	end
	return true
end

---@param self BlueprintLayout
---@param state BlueprintState
function layout:init_first_pass(state)
	local c = state.coords
	local bp = state.cache
	---@type BpPlacementAttempt[]
	local attempts = {}
	state.attempts = attempts
	state.best_attempt_index = 1
	state.attempt_index = 1

	local function calc_slack(tw, bw, offset)
		local count = ceil((tw-offset) / bw)
		local overrun = count * bw - tw + offset
		local start = -floor(overrun / 2)
		local slack = overrun % 2
		return count, start, slack
	end

	local count_x, start_x, slack_x = calc_slack(c.tw, bp.w, bp.ox)
	local count_y, start_y, slack_y = calc_slack(c.th, bp.h, bp.oy)

	if state.start_choice then
		start_x, slack_x = 0, 0
	end

	attempts[1] = {
		x = start_x, y = start_y,
		cx = count_x, cy = count_y,
		slack_x = slack_x, slack_y = slack_y,
		miners = {}, postponed = {},
		other_ents = {},
	}

	state.bp_grid = {}
	for iy = 0, start_y - 1 do
		local row = state.bp_grid[iy]
		for ix = 0, start_x - 1 do
			row[ix] = {completed = false}
		end
	end

	--[[ debug rendering
	rendering.draw_rectangle{
		surface=state.surface,
		left_top={state.coords.ix1, state.coords.iy1},
		right_bottom={state.coords.ix1 + c.tw, state.coords.iy1 + c.th},
		filled=false, width=8, color={0, 0, 1, 1},
		players={state.player},
	}

	for iy = 0, count_y-1 do
		for ix = 0, count_x-1 do
			rendering.draw_rectangle{
				surface=state.surface,
				left_top={
					c.ix1 + start_x + bp.w * ix,
					c.iy1 + start_y + bp.h * iy,
				},
				right_bottom={
					c.ix1 + start_x + bp.w * (ix+1),
					c.iy1 + start_y + bp.h * (iy+1),
				},
				filled=false, width=2, color={0, 0.5, 1, 1},
				players={state.player},
			}
		end
	end
	--]]

	return "first_pass"
end

---@param miner MinerStruct
local function miner_heuristic(miner, coverage)
	local near, far = miner.near, miner.far
	local full, size = miner.full_size, miner.size
	local neighbor_cap = ceil((size ^ 2) * 0.5)
	if coverage then
		---@param tile GridTile
		return function(tile)
			local nearc, farc = tile.neighbor_counts[near], tile.neighbor_counts[far]
			return nearc and (nearc > 0 or
				(farc and farc > neighbor_cap and nearc > (size * near))
			)
		end
	end
	---@param tile GridTile
	return function(tile)
		local nearc, farc = tile.neighbor_counts[near], tile.neighbor_counts[far]
		return nearc and (nearc > neighbor_cap or
			(farc and farc > neighbor_cap and nearc > (size * near))
		)
	end
end

---@param self BlueprintLayout
---@param state BlueprintState
function layout:first_pass(state)
	local grid = state.grid
	local bp = state.cache
	local entities = bp.entities
	local attempt = state.attempts[state.attempt_index]
	local sx, sy, countx, county = attempt.x, attempt.y, attempt.cx-1, attempt.cy-1
	local bpconv = bp_direction[state.direction_choice]
	local bpw, bph = bp.w, bp.h
	local heuristics = {}
	for k, v in pairs(bp.miners) do heuristics[k] = miner_heuristic(v, state.coverage_choice) end
	
	local miners, postponed = attempt.miners, attempt.postponed
	local other_ents = attempt.other_ents
	local s_ix = attempt.s_ix or 0
	local s_iy = attempt.s_iy or 0
	local s_ie = attempt.s_ie or 1
	local progress, progress_cap = 0, 64
	--local ix, iy, ie = s_ix, s_iy, s_ie
	for iy = s_iy, county do
	--while iy <= county do
		local capstone_y = iy == county
		for ix = s_ix, countx do
		--while ix <= countx do
			--for _, ent in pairs(bp.entities) do
			for ie = s_ie, #entities do
			--while ie <= #entities do
				local ent = entities[ie]
				ie = ie + 1
				local capstone_x = ix == countx
				if ent.capstone_y and not capstone_y then goto skip_ent end
				if ent.capstone_x and not capstone_x then goto skip_ent end
				local bpx, bpy = ceil(ent.position.x), ceil(ent.position.y)
				local x, y = sx + ix * bpw + bpx, sy + iy * bph + bpy
				local tile = grid:get_tile(x, y)
				if not tile then goto skip_ent end
				local bptr = bpconv[ent.direction or defines.direction.north]

				local miner = state.cache.miners[ent.name]
				if state.cache.miners[ent.name] then
					local struct = {
						ent = ent,
						line = s_iy,
						center = tile,
						column = s_ix,
						direction = bptr,
						name = ent.name,
						near = miner.near,
						far = miner.far,
						x = x, y = y,
					}
					local count_near = tile.neighbor_counts[miner.near]
					local count_far = tile.neighbor_counts[miner.far]
					if heuristics[ent.name](tile) then
						miners[#miners+1] = struct
						
						local even = mpp_util.entity_even_width(ent.name)
						grid:consume_custom(x, y, miner.far, even[1], even[2])
					else
						postponed[#postponed+1] = struct
					end
				else
					other_ents[#other_ents+1] = {
						ent = ent,
						center = tile,
						x = x, y = y,
						direction = bptr,
					}
				end

				--[[ debug rendering
				rendering.draw_circle{
					surface = state.surface,
					player = state.player,
					filled = false,
					color = {1,1,1,1},
					radius= 0.5,
					target = {c.gx + x, c.gy + y},
				}
				--]]

				progress = progress + 1
				if progress > progress_cap then
					attempt.s_ix, attempt.s_iy, attempt.s_ie = ix, iy, ie
					return true
				end

				::skip_ent::
			end
			s_ie = 1
		end
		s_ix = 0
	end
	return "first_pass_finish"
end

---@param self BlueprintLayout
---@param state BlueprintState
function layout:first_pass_finish(state)
	local grid = state.grid
	local attempt = state.attempts[state.attempt_index]
	local miners, postponed = attempt.miners, attempt.postponed

	-- second pass
	for _, miner in ipairs(miners) do
		local even = mpp_util.entity_even_width(miner.ent.name)
		grid:consume_custom(miner.center.x, miner.center.y, miner.far, even[1], even[2])
	end

	for _, miner in ipairs(postponed) do
		local center = miner.center
		miner.unconsumed = grid:get_unconsumed_custom(center.x, center.y, miner.far)
	end

	table.sort(postponed, function(a, b)
		if a.unconsumed == b.unconsumed then
			local sizes = mpp_util.keys_to_set(a.center.neighbor_counts, b.center.neighbor_counts)
			for i = #sizes, 1, -1 do
				local size = sizes[i]
				local left, right = a.center.neighbor_counts[size], b.center.neighbor_counts[size]
				if left ~= nil and right ~= nil then
					return left > right
				elseif left ~= nil then
					return true
				end
			end
			return false
		end
		return a.unconsumed > b.unconsumed
	end)

	for _, miner in ipairs(postponed) do
		local center = miner.center
		local unconsumed_count = grid:get_unconsumed_custom(center.x, center.y, miner.far)
		if unconsumed_count > 0 then
			local even = mpp_util.entity_even_width(miner.ent.name)
			grid:consume_custom(center.x, center.y, miner.far, even[1], even[2])
			miners[#miners+1] = miner
		end
	end

	state.best_attempt = attempt

	return "simple_deconstruct"
end

---@param self BlueprintLayout
---@param state BlueprintState
function layout:simple_deconstruct(state)
	local c = state.coords
	local m = state.miner
	local player = state.player
	local surface = state.surface
	local bp = state.cache

	local deconstructor = global.script_inventory[state.deconstruction_choice and 2 or 1]
	surface.deconstruct_area{
		force=player.force,
		player=player.index,
		area={
			left_top={c.x1-(bp.tw/2), c.y1-(bp.th/2)},
			right_bottom={c.x2+(bp.tw/2), c.y2+(bp.th/2)}
		},
		item=deconstructor,
	}

	--[[ debug rendering - deconstruction area
	rendering.draw_rectangle{
		surface=state.surface,
		players={state.player},
		filled=false,
		width=3,
		color={1, 0, 0},
		left_top={c.x1-(bp.tw/2), c.y1-(bp.th/2)},
		right_bottom={c.x2+(bp.tw/2), c.y2+(bp.th/2)}
	}
	]]

	return "place_miners"
end

---@param tile GridTile
---@param ent BlueprintEntity|MinerPlacement
---@return number
---@return number
local function fix_offgrid(tile, ent)
	local ex, ey = ent.position.x, ent.position.y
	local ox, oy = 0, 0
	if ex == ceil(ex) then ox = 0.5 end
	if ey == ceil(ey) then oy = 0.5 end
	return tile.x + ox, tile.y + oy
end

---@param self SimpleLayout
---@param state BlueprintState
function layout:place_miners(state)
	local c = state.coords
	local grid = state.grid
	local surface = state.surface
	for _, miner in ipairs(state.best_attempt.miners) do
		local center = miner.center
		--g:build_miner_custom(center.x, center.y, miner.near)

		local even = mpp_util.entity_even_width(miner.ent.name)
		grid:build_thing(center.x, center.y, "miner", miner.near, even[1])
		local ex, ey = fix_offgrid(center, miner.ent)
		local x, y = coord_revert[state.direction_choice](ex, ey, c.tw, c.th)
		-- local can_place = surface.can_place_entity{
		-- 	name=state.miner.name,
		-- 	force = state.player.force,
		-- 	position={center.gx, center.gy},
		-- 	direction = defines.direction.north,
		-- 	build_check_type = 
		-- }

		--[[ debug visualisation - miner placement
		local off = state.miner.size / 2
		rendering.draw_rectangle{
			surface = state.surface,
			filled = false,
			color = miner.postponed and {1, 0, 0} or {0, 1, 0},
			width = 3,
			--target = {c.x1 + x, c.y1 + y},
			left_top = {c.gx+x-off, c.gy + y - off},
			right_bottom = {c.gx+x+off, c.gy + y + off},
		}
		--]]

		local target = surface.create_entity{
			raise_built=true,
			name="entity-ghost",
			player=state.player,
			force = state.player.force,
			position = {c.gx + x, c.gy + y},
			direction = miner.direction,
			inner_name = miner.name,
		}
		if miner.ent.items then
			target.item_requests = miner.ent.items
		end
	end

	return "place_other"
end

---@param self BlueprintLayout
---@param state BlueprintState
function layout:place_other(state)
	local c = state.coords
	local grid = state.grid
	local surface = state.surface
	local beacons, power, lamps = {}, {}, {}
	state.beacons, state.builder_power_poles, state.lamps = beacons, power, lamps

	for _, other_ent in ipairs(state.best_attempt.other_ents) do
		---@type BlueprintEntity
		local ent = other_ent.ent
		local center = other_ent.center
		local ent_type = game.entity_prototypes[ent.name].type

		if ent_type == "beacon" then
			beacons[#beacons+1] = other_ent
			goto continue
		elseif ent_type == "electric-pole" then
			power[#power+1] = other_ent
			goto continue
		--elseif ent_type == "lamp" then
			--lamps[#lamps+1] = other_ent
			--goto continue
		end

		local ex, ey = fix_offgrid(center, ent)
		local x, y = coord_revert[state.direction_choice](ex, ey, c.tw, c.th)
		local target = surface.create_entity{
			raise_built=true,
			name="entity-ghost",
			player=state.player,
			force=state.player.force,
			position= {c.gx + x, c.gy + y},
			direction = other_ent.direction,
			inner_name = ent.name,
			type=ent.type,
			output_priority=ent.output_priority,
			input_priority=ent.input_priority,
			filter=ent.filter,
			filters=ent.filters,
			filter_mode=ent.filter_mode,
			override_stack_size=ent.override_stack_size,
		}

		if ent.items then
			target.item_requests = ent.items
		end

		--[[ debug rendering 
		rendering.draw_circle{
			surface = state.surface,
			player = state.player,
			filled = false,
			color = {0.5,0.5,1,1},
			width=3,
			radius= 0.4,
			target = {c.gx + center.x, c.gy + center.y},
		}
		--]]

		::continue::
	end

	return "place_beacons"
end

---@param self BlueprintLayout
---@param state BlueprintState
function layout:place_beacons(state)
	local c = state.coords
	local surface = state.surface
	local grid = state.grid

	for _, other_ent in ipairs(state.beacons) do
		---@type BlueprintEntity
		local ent = other_ent.ent
		local center = other_ent.center
		
		local even = mpp_util.entity_even_width(ent.name)
		local range = floor(game.entity_prototypes[ent.name].supply_area_distance)
		if grid:find_thing(center.x, center.y, "miner", range+even.near, even[1]) then
			local ex, ey = fix_offgrid(center, ent)
			local x, y = coord_revert[state.direction_choice](ex, ey, c.tw, c.th)
			local target = surface.create_entity{
				raise_built=true,
				name="entity-ghost",
				player=state.player,
				force=state.player.force,
				position= {c.gx + x, c.gy + y},
				direction = other_ent.direction,
				inner_name = ent.name,
				type=ent.type,
			}
			if ent.items then
				target.item_requests = ent.items
			end
			grid:build_thing(center.x, center.y, "beacon", even.near, even[1])
		end

	end

	return "place_electricity"
end

---@param self BlueprintLayout
---@param state BlueprintState
function layout:place_electricity(state)
	local c = state.coords
	local surface = state.surface
	local grid = state.grid

	for _, other_ent in ipairs(state.builder_power_poles) do
		---@type BlueprintEntity
		local ent = other_ent.ent
		local center = other_ent.center
		
		local even = mpp_util.entity_even_width(ent.name)
		local range = floor(game.entity_prototypes[ent.name].supply_area_distance)
		if grid:find_thing_in(center.x, center.y, {"miner", "beacon"}, range, even[1]) then
			local ex, ey = fix_offgrid(center, ent)
			local x, y = coord_revert[state.direction_choice](ex, ey, c.tw, c.th)
			local target = surface.create_entity{
				raise_built=true,
				name="entity-ghost",
				player=state.player,
				force=state.player.force,
				position= {c.gx + x, c.gy + y},
				direction = other_ent.direction,
				inner_name = ent.name,
				type=ent.type,
			}
			if ent.items then
				target.item_requests = ent.items
			end
			grid:build_thing(center.x, center.y, "electricity", even.near, even[1])
		end
	end
	return "finish"
end

---@param self BlueprintLayout
---@param state BlueprintState
function layout:debug_overlay(state)
	local c = state.coords
	local surface = state.surface
	local grid = state.grid

	-- Draws built thing overlay

	for iy, row in pairs(grid) do
		if type(iy) ~= "number" then
			game.print("asdf")
			return
		end
		for ix, tile in pairs(row) do
			local building = tile.built_on
			if building then
				local color = {0.3, 0.3, 0.3, 0.5}
				if building == "miner" then
					color = {0.1, 0.1, 0.8, 0.7}
				elseif building == "beacon" then
					color = {0.1, 0.8, 0.8, 0.7}
				end

				rendering.draw_circle{
					surface=state.surface,
					player=state.player,
					filled=false,
					radius=0.5,
					color=color,
					target={tile.gx-1, tile.gy-1},
				}
			end
		end
	end

	return "finish"
end

---@param self BlueprintLayout
---@param state BlueprintState
function layout:finish(state)
	return false
end

return layout

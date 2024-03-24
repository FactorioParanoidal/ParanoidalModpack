local mpp_util = require("mpp.mpp_util")
local color = require("mpp.color")

local floor, ceil = math.floor, math.ceil
local min, max = math.min, math.max
local EAST, NORTH, SOUTH, WEST = mpp_util.directions()

local render_util = {}

---@class RendererParams
---@field origin MapPosition?
---@field target MapPosition?
---@field x number?
---@field y number?
---@field w number?
---@field h number?
---@field r number?
---@field color Color?
---@field width number?
---@field c Color?
---@field left_top MapPosition?
---@field right_bottom MapPosition?

---this went off the rails
---@param event EventData.on_player_reverse_selected_area
---@return MppRendering
function render_util.renderer(event)

	---@param t RendererParams
	local function parametrizer(t, overlay)

		for k, v in pairs(overlay or {}) do t[k] = v end
		if t.x and t.y then t.origin = {t.x, t.y} end
		local target = t.origin or t.left_top --[[@as MapPosition]]
		local left_top, right_bottom = t.left_top or t.origin or target, t.right_bottom or t.origin

		if t.origin and t.w or t.h then
			t.w, t.h = t.w or t.h, t.h or t.w
			right_bottom = {(target[1] or target.x) + t.w, (target[2] or target.y) + t.h}
		elseif t.r then
			local r = t.r
			local ox, oy = target[1] or target.x, target[2] or target.y
			left_top = {ox-r, oy-r}
			right_bottom = {ox+r, oy+r}
		end

		local new = {
			surface = event.surface,
			players = {event.player_index},
			filled = false,
			radius = t.r or 1,
			color = t.c or t.color or {1, 1, 1},
			left_top = left_top,
			right_bottom = right_bottom,
			target = target, -- circles
			from = left_top,
			to = right_bottom, -- lines
			width = 1,
		}
		for k, v in pairs(t) do new[k]=v end
		for _, v in ipairs{"x", "y", "h", "w", "r", "origin"} do new[v]=nil end
		return new
	end

	local meta_renderer_meta = {}
	meta_renderer_meta.__index = function(self, k)
		return function(t, t2)
			return {
				rendering[k](
					parametrizer(t, t2)
				)
			}
	end end
	local rendering = setmetatable({}, meta_renderer_meta)

	---@class MppRendering
	local rendering_extension = {}

	---Draws an x between left_top and right_bottom
	---@param params RendererParams
	function rendering_extension.draw_cross(params)
		rendering.draw_line(params)
		rendering.draw_line({
			width = params.width,
			color = params.color,
			left_top={
				params.right_bottom[1],
				params.left_top[2]
			},
			right_bottom={
				params.left_top[1],
				params.right_bottom[2],
			}
		})
	end

	function rendering_extension.draw_rectangle_dashed(params)
		rendering.draw_line(params, {
			from={params.left_top[1], params.left_top[2]},
			to={params.right_bottom[1], params.left_top[2]},
			dash_offset = 0.0,
		})
		rendering.draw_line(params, {
			from={params.left_top[1], params.right_bottom[2]},
			to={params.right_bottom[1], params.right_bottom[2]},
			dash_offset = 0.5,
		})
		rendering.draw_line(params, {
			from={params.right_bottom[1], params.left_top[2]},
			to={params.right_bottom[1], params.right_bottom[2]},
			dash_offset = 0.0,
		})
		rendering.draw_line(params, {
			from={params.left_top[1], params.left_top[2]},
			to={params.left_top[1], params.right_bottom[2]},
			dash_offset = 0.5,
		})
	end

	local meta = {}
	function meta:__index(k)
		return function(t, t2)
			if rendering_extension[k] then
				rendering_extension[k](parametrizer(t, t2))
			else
				rendering[k](parametrizer(t, t2))
			end
		end
	end

	return setmetatable({}, meta)
end

function render_util.draw_clear_rendering(player_data, event)
	rendering.clear("mining-patch-planner")
end

---Draws the properties of a mining drill
---@param player_data PlayerData
---@param event EventData.on_player_reverse_selected_area
function render_util.draw_drill_struct(player_data, event)

	local renderer = render_util.renderer(event)

	local fx1, fy1 = event.area.left_top.x, event.area.left_top.y
	fx1, fy1 = floor(fx1), floor(fy1)
	local x, y = fx1 + 0.5, fy1 + 0.5
	local fx2, fy2 = event.area.right_bottom.x, event.area.right_bottom.y
	fx2, fy2 = ceil(fx2), ceil(fy2)

	--renderer.draw_cross{x=fx1, y=fy1, w=fx2-fx1, h=fy2-fy1}
	--renderer.draw_cross{x=fx1, y=fy1, w=2}

	local drill = mpp_util.miner_struct(player_data.choices.miner_choice)

	renderer.draw_circle{
		x = fx1 + drill.drop_pos.x,
		y = fy1 + drill.drop_pos.y,
		c = {0, 1, 0},
		r = 0.2,
	}

	-- drop pos
	renderer.draw_cross{
		x = fx1 + 0.5 + drill.out_x,
		y = fy1 + 0.5 + drill.out_y,
		r = 0.3,
	}

	for _, pos in pairs(drill.output_rotated) do
		renderer.draw_cross{
			x = fx1 + 0.5 + pos[1],
			y = fy1 + 0.5 + pos[2],
			r = 0.15,
			width = 3,
			c={0, 0, 0, .5},
		}
	end

	renderer.draw_line{
		from={x + drill.x, y},
		to={x + drill.x, y + 2},
		width = 2, color={0.5, 0.5, 0.5}
	}
	renderer.draw_line{
		from={x + drill.x, y},
		to={x + drill.x-.5, y + .65},
		width = 2, color={0.5, 0.5, 0.5}
	}
	renderer.draw_line{
		from={x + drill.x, y},
		to={x + drill.x+.5, y + .65},
		width = 2, color={0.5, 0.5, 0.5}
	}


	-- drill origin
	renderer.draw_circle{
		x = fx1 + 0.5,
		y = fy1 + 0.5,
		width = 2,
		r = 0.4,
	}

	renderer.draw_text{
		target={fx1 + .5, fy1 + .5},
		text = "(0, 0)",
		alignment = "center",
		vertical_alignment="middle",
		scale = 0.6,
	}

	-- negative extent - cyan
	renderer.draw_cross{
		x = fx1 +.5 + drill.extent_negative,
		y = fy1 +.5 + drill.extent_negative,
		r = 0.25,
		c = {0, 0.8, 0.8},
	}

	-- positive extent - purple
	renderer.draw_cross{
		x = fx1 +.5 + drill.extent_positive,
		y = fy1 +.5 + drill.extent_positive,
		r = 0.25,
		c = {1, 0, 1},
	}

	renderer.draw_rectangle{
		x=fx1,
		y=fy1,
		w=drill.size,
		h=drill.size,
		width=3,
		gap_length=0.5,
		dash_length=0.5,
	}

	renderer.draw_rectangle_dashed{
		x=fx1 + drill.extent_negative,
		y=fy1 + drill.extent_negative,
		w=drill.area,
		h=drill.area,
		c={0.5, 0.5, 0.5},
		width=5,
		gap_length=0.5,
		dash_length=0.5,
	}

	if drill.supports_fluids then
		-- pipe connections
		renderer.draw_line{
			width=4, color = {0, .7, 1},
			from={fx1-.3, y+drill.pipe_left-.5},
			to={fx1-.3, y+drill.pipe_left+.5},
		}
		renderer.draw_line{
			width=4, color = {.7, .7, 0},
			from={fx1+drill.size+.3, y+drill.pipe_left-.5},
			to={fx1+drill.size+.3, y+drill.pipe_left+.5},
		}
	end

	renderer.draw_text{
		target={fx1 + drill.extent_negative, fy1 + drill.extent_negative-1.5},
		text = string.format("skip_outer: %s", drill.skip_outer),
		alignment = "left",
		vertical_alignment="middle",
	}

	renderer.draw_circle{x = fx1, y = fy1, r = 0.1}
	--renderer.draw_circle{ x = fx2, y = fy2, r = 0.15, color={1, 0, 0} }
end

---Preview the pole coverage
---@param player_data PlayerData
---@param event EventData.on_player_reverse_selected_area
function render_util.draw_pole_layout(player_data, event)
	rendering.clear("mining-patch-planner")

	local renderer = render_util.renderer(event)

	local fx1, fy1 = event.area.left_top.x, event.area.left_top.y
	fx1, fy1 = floor(fx1), floor(fy1)

	--renderer.draw_cross{x=fx1, y=fy1, w=fx2-fx1, h=fy2-fy1}
	--renderer.draw_cross{x=fx1, y=fy1, w=2}

	local drill = mpp_util.miner_struct(player_data.choices.miner_choice)
	local pole = mpp_util.pole_struct(player_data.choices.pole_choice)

	local function draw_lane(x, y, count)
		for i = 0, count-1 do
			renderer.draw_rectangle{
				x = x + drill.size * i + 0.15 , y = y+.15,
				w = drill.size-.3, h=1-.3,
				color = i % 2 == 0 and {143/255, 86/255, 59/255} or {223/255, 113/255, 38/255},
				width=2,
			}
		end

		---@diagnostic disable-next-line: param-type-mismatch
		local coverage = mpp_util.calculate_pole_coverage(player_data.choices, count, 1)

		renderer.draw_circle{
			x=x+.5, y=y-0.5, radius = .25, color={0.7, 0.7, 0.7},
		}
		for i = coverage.pole_start, coverage.full_miner_width, coverage.pole_step do
			renderer.draw_circle{
				x = x + i + .5,
				y = y - .5,
				radius = 0.3, width=2,
				color = {0, 1, 1},
			}
			renderer.draw_line{
				x = x + i +.5 - pole.supply_width / 2+.2,
				y = y - .2,
				h = 0,
				w = pole.supply_width-.4,
				color = {0, 1, 1},
				width = 2,
			}
			renderer.draw_line{
				x = x + i +.5 - pole.supply_width / 2 + .2,
				y = y - .7,
				h = .5,
				w = 0,
				color = {0, 1, 1},
				width = 2,
			}
			renderer.draw_line{
				x = x + i +.5 + pole.supply_width / 2 - .2,
				y = y - .7,
				h = .5,
				w = 0,
				color = {0, 1, 1},
				width = 2,
			}
		end
	end

	for i = 1, 10 do
		draw_lane(fx1, fy1+(i-1)*3, i)
	end

end

---Preview the pole coverage
---@param player_data PlayerData
---@param event EventData.on_player_reverse_selected_area
function render_util.draw_pole_layout_compact(player_data, event)
	rendering.clear("mining-patch-planner")

	local renderer = render_util.renderer(event)

	local fx1, fy1 = event.area.left_top.x, event.area.left_top.y
	fx1, fy1 = floor(fx1), floor(fy1)

	--renderer.draw_cross{x=fx1, y=fy1, w=fx2-fx1, h=fy2-fy1}
	--renderer.draw_cross{x=fx1, y=fy1, w=2}

	local drill = mpp_util.miner_struct(player_data.choices.miner_choice)
	local pole = mpp_util.pole_struct(player_data.choices.pole_choice)

	local function draw_lane(x, y, count)
		for i = 0, count-1 do
			renderer.draw_rectangle{
				x = x + drill.size * i + 0.15 , y = y+.15,
				w = drill.size-.3, h=1-.3,
				color = i % 2 == 0 and {143/255, 86/255, 59/255} or {223/255, 113/255, 38/255},
				width=2,
			}
		end

		---@diagnostic disable-next-line: param-type-mismatch
		local coverage = mpp_util.calculate_pole_spacing(player_data.choices, count, 1)

		renderer.draw_circle{
			x=x+.5, y=y-0.5, radius = .25, color={0.7, 0.7, 0.7},
		}
		for i = coverage.pole_start, coverage.full_miner_width, coverage.pole_step do
			renderer.draw_circle{
				x = x + i + .5,
				y = y - .5,
				radius = 0.3, width=2,
				color = {0, 1, 1},
			}
			renderer.draw_line{
				x = x + i +.5 - pole.supply_width / 2+.2,
				y = y - .2,
				h = 0,
				w = pole.supply_width-.4,
				color = {0, 1, 1},
				width = 2,
			}
			renderer.draw_line{
				x = x + i +.5 - pole.supply_width / 2 + .2,
				y = y - .7,
				h = .5,
				w = 0,
				color = {0, 1, 1},
				width = 2,
			}
			renderer.draw_line{
				x = x + i +.5 + pole.supply_width / 2 - .2,
				y = y - .7,
				h = .5,
				w = 0,
				color = {0, 1, 1},
				width = 2,
			}
		end
	end

	for i = 1, 10 do
		draw_lane(fx1, fy1+(i-1)*3, i)
	end

end

---Displays the labels of built things on the grid
---@param player_data PlayerData
---@param event EventData.on_player_reverse_selected_area
function render_util.draw_built_things(player_data, event)
	rendering.clear("mining-patch-planner")

	local renderer = render_util.renderer(event)

	local state = player_data.last_state

	if not state then return end

	local C = state.coords
	local G = state.grid

	for _, row in pairs(G) do
		for _, tile in pairs(row) do
			---@cast tile GridTile
			local thing = tile.built_on
			if thing then
				-- renderer.draw_circle{
				-- 	x = C.gx + tile.x, y = C.gy + tile.y,
				-- 	w = 1,
				-- 	color = {0, 0.5, 0, 0.1},
				-- 	r = 0.5,
				-- }
				renderer.draw_rectangle{
					x = C.ix1 + tile.x -.9, y = C.iy1 + tile.y -.9,
					w = .8,
					color = {0, 0.2, 0, 0.1},
				}
				renderer.draw_text{
					x = C.gx + tile.x, y = C.gy + tile.y - .3,
					alignment = "center",
					vertical_alignment = "top",
					--vertical_alignment = tile.x % 2 == 1 and "top" or "bottom",
					text = thing,
					scale = 0.6,
				}
			end
		end
	end

end

---@param player_data PlayerData
---@param event EventData.on_player_reverse_selected_area
function render_util.draw_drill_convolution(player_data, event)
	rendering.clear("mining-patch-planner")

	local renderer = render_util.renderer(event)

	local fx1, fy1 = event.area.left_top.x, event.area.left_top.y
	fx1, fy1 = floor(fx1), floor(fy1)

	local state = player_data.last_state
	if not state then return end

	local C = state.coords
	local grid = state.grid

	for _, row in pairs(grid) do
		for _, tile in pairs(row) do
			---@cast tile GridTile
			--local c1, c2 = tile.neighbor_counts[m_size], tile.neighbor_counts[m_area]
			local c1, c2 = tile.neighbors_inner, tile.neighbors_outer
			if c1 == 0 and c2 == 0 then goto continue end

			rendering.draw_circle{
				surface = state.surface, filled=false, color = {0.3, 0.3, 1},
				width=1, radius = 0.5,
				target={C.gx + tile.x, C.gy + tile.y},
			}
			local stagger = (.5 - (tile.x % 2)) * .25
			local col = c1 == 0 and {0.3, 0.3, 0.3} or {0.6, 0.6, 0.6}
			rendering.draw_text{
				surface = state.surface, filled = false, color = col,
				target={C.gx + tile.x, C.gy + tile.y + stagger},
				text = string.format("%i,%i", c1, c2),
				alignment = "center",
				vertical_alignment="middle",
			}

			::continue::
		end
	end

end


---@param player_data PlayerData
---@param event EventData.on_player_reverse_selected_area
function render_util.draw_power_grid(player_data, event)
	local renderer = render_util.renderer(event)

	local fx1, fy1 = event.area.left_top.x, event.area.left_top.y
	fx1, fy1 = floor(fx1), floor(fy1)

	local state = player_data.last_state
	if not state then return end
	---@cast state SimpleState

	local C = state.coords
	local grid = state.grid

	local connectivity = state.power_connectivity
	if not connectivity then
		game.print("No connectivity exists")
		return
	end
	local rendered = {}

	for set_id, set in pairs(connectivity) do
		local set_color = color.hue_sequence(set_id)
		if set_id == 0 then set_color = {1, 1, 1} end
		for pole, _ in pairs(set) do
			---@cast pole GridPole
			-- if rendered[pole] then goto continue end
			-- rendered[pole] = true
			local pole_color = set_color
			-- if not pole.backtracked and not pole.has_consumers then
			-- 	pole_color = {0, 0, 0}
			-- end

			renderer.draw_circle{
				surface = state.surface,
				filled = not pole.backtracked,
				color = pole_color,
				width = 5,
				target = {C.gx + pole.grid_x, C.gy + pole.grid_y},
				radius = 0.65,
			}
			renderer.draw_text{
				surface = state.surface,
				target={C.gx + pole.grid_x, C.gy + pole.grid_y},
				text = set_id,
				alignment = "center",
				vertical_alignment="middle",
				scale = 2,
			}
			renderer.draw_text{
				surface = state.surface,
				target={C.gx + pole.grid_x, C.gy + pole.grid_y-1.25},
				text = ("%i,%i"):format(pole.ix, pole.iy),
				alignment = "center",
				vertical_alignment="middle",
				scale = 2,
			}
			::continue::
		end
	end --]]

end

---@param player_data PlayerData
---@param event EventData.on_player_reverse_selected_area
function render_util.draw_centricity(player_data, event)
	local renderer = render_util.renderer(event)

	local fx1, fy1 = event.area.left_top.x, event.area.left_top.y
	fx1, fy1 = floor(fx1), floor(fy1)

	local state = player_data.last_state
	if not state then return end

	local C = state.coords
	local grid = state.grid

	

end


---@param player_data PlayerData
---@param event EventData.on_player_reverse_selected_area
function render_util.draw_blueprint_data(player_data, event)
	local renderer = render_util.renderer(event)

	local fx1, fy1 = event.area.left_top.x, event.area.left_top.y
	fx1, fy1 = floor(fx1), floor(fy1)
	local x, y = fx1 + 0.5, fy1 + 0.5

	local id = player_data.choices.blueprint_choice and player_data.choices.blueprint_choice.item_number
	if not id then return end
	local bp = player_data.blueprints.cache[id]
	if not bp then return end

	renderer.draw_line{x = fx1, y = fy1-1, w = 0, h = 2, width = 7, color={0, 0, 0}}
	renderer.draw_line{x = fx1-1, y = fy1, w = 2, h = 0, width = 7, color={0, 0, 0}}

	renderer.draw_rectangle{
		x = fx1,
		y = fy1,
		w = bp.w,
		h = bp.h,
	}

	for _, ent in pairs(bp.entities) do
		local struct = mpp_util.entity_struct(ent.name)
		local clr = {1, 1, 1}
		if ent.capstone_x and ent.capstone_y then
			clr = {0, 1, 1}
		elseif ent.capstone_x then
			clr = {0, 1, 0}
		elseif ent.capstone_y then
			clr = {0, 0, 1}
		end
		renderer.draw_circle{
			x = fx1 + ent.position.x,
			y = fy1 + ent.position.y,
			r = struct.size / 2,
			color = clr,
		}
	end

end

---@param player_data PlayerData
---@param event EventData.on_player_reverse_selected_area
function render_util.draw_deconstruct_preview(player_data, event)
	local renderer = render_util.renderer(event)

	local fx1, fy1 = event.area.left_top.x, event.area.left_top.y
	fx1, fy1 = floor(fx1), floor(fy1)

	local state = player_data.last_state
	if not state then return end

	local c = state.coords
	local grid = state.grid

	local layout = algorithm.layouts[state.layout_choice]
	if not layout._get_deconstruction_objects then return end
	local objects = layout:_get_deconstruction_objects(state)
	
	local DIR = state.direction_choice

	for _, t in pairs(objects) do
		for _, object in ipairs(t) do
			---@cast object GhostSpecification
			local extent_w = object.extent_w or object.radius or 0.5
			local extent_h = object.extent_h or extent_w

			local x1, y1 = object.grid_x-extent_w, object.grid_y-extent_h
			local x2, y2 = object.grid_x+extent_w, object.grid_y+extent_h

			x1, y1 = mpp_util.revert_ex(c.gx, c.gy, DIR, x1, y1, c.tw, c.th)
			x2, y2 = mpp_util.revert_ex(c.gx, c.gy, DIR, x2, y2, c.tw, c.th)

			rendering.draw_rectangle{
				surface=state.surface,
				players={state.player},
				filled=false,
				width=3,
				color={1, 0, 0},
				left_top={x1+.1,y1+.1},
				right_bottom={x2-.1,y2-.1},
			}
		end
	end

end

---@param player_data PlayerData
---@param event EventData.on_player_reverse_selected_area
function render_util.draw_can_place_entity(player_data, event)
	local renderer = render_util.renderer(event)

	local fx1, fy1 = event.area.left_top.x, event.area.left_top.y
	fx1, fy1 = floor(fx1), floor(fy1)
	local x, y = fx1 + 0.5, fy1 + 0.5

	local id = player_data.choices.blueprint_choice and player_data.choices.blueprint_choice.item_number
	if not id then return end
	local bp = player_data.blueprints.cache[id]
	if not bp then return end

	renderer.draw_line{x = fx1, y = fy1-1, w = 0, h = 1, width = 7, color={0.3, 0.3, 0.3}}
	renderer.draw_line{x = fx1-1, y = fy1, w = 1, h = 0, width = 7, color={0.3, 0.3, 0.3}}

	local build_check_type = defines.build_check_type
	local can_forced = {
		[{false, false}] = 0,
		[{true, false}] = 1,
		[{false, true}] = 2,
		[{true, true}] = 3,
	}

	for check_type, i1 in pairs(build_check_type) do
		
		for forced_ghost, i2 in pairs(can_forced) do

			local forced, ghost = forced_ghost[1], forced_ghost[2]

			local nx = x + (bp.w + 3) * i1
			local ny = y + (bp.h + 3) * i2

			renderer.draw_rectangle{
				x = nx-.5,
				y = ny-.5,
				w = bp.w,
				h = bp.h,
				color = {0.2, 0.2, .7},
			}

			-- renderer.draw_text{
			-- 	x = nx+(bp.w-1)/2, y = ny-.5,
			-- 	text = ("%i,%i"):format(i1, i2),
			-- 	alignment = "center",
			-- 	vertical_alignment="bottom",
			-- }
			
			renderer.draw_text{
				x = nx+(bp.w-1)/2, y = ny-1.5,
				text = ("%s"):format(check_type),
				alignment = "center",
				vertical_alignment="bottom",
			}
			renderer.draw_text{
				x = nx+(bp.w-1)/2, y = ny-1,
				text = ("forced: %s"):format(forced),
				alignment = "center",
				vertical_alignment="bottom",
			}
			renderer.draw_text{
				x = nx+(bp.w-1)/2, y = ny-.5,
				text = ("ghost: %s"):format(ghost),
				alignment = "center",
				vertical_alignment="bottom",
			}

			for _, ent in pairs(bp.entities) do
				local ex = nx + ent.position.x - .5
				local ey = ny + ent.position.y - .5
				local t = {
					name = ent.name,
					position = {ex, ey},
					direction = ent.direction,
					build_check_type = defines.build_check_type[check_type],
					force = game.get_player(event.player_index).force,
					forced = forced,
				}
				if ghost then
					t.name, t.inner_name = "entity-ghost", t.name
				end

				local can_place = event.surface.can_place_entity(t)

				renderer.draw_circle{x = ex, y = ey, r = 0.5, width = 3,
					color = can_place and {0.1, .9, .1} or {0.9, .1, .1},
				}
				
				if can_place then
					if not ghost then
						t.name, t.inner_name = "entity-ghost", t.name
					end
					event.surface.create_entity(t)
				end
			end

		end

	end

end


return render_util

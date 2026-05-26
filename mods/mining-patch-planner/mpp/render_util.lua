local mpp_util = require("mpp.mpp_util")
local color = require("mpp.color")
local cliffs = require("mpp.cliffs")

local floor, ceil, min, max, abs = math.floor, math.ceil, math.min, math.max, math.abs
local sin, cos, asin, acos = math.sin, math.cos, math.asin, math.acos
local rad, atan, atan2 = math.rad, math.atan, math.atan2
local EAST, NORTH, SOUTH, WEST = mpp_util.directions()

local render_util = {}

---@alias radian number

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
---@field from MapPosition?
---@field to MapPosition?

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
			radius = t.r or 0.5,
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

	local function vec2_length(x, y)
		return (x * x + y * y) ^ 0.5
	end

	---@param x number
	---@param y number
	---@return number, number
	local function vec2_normal(x, y)
		local len = (x * x + y * y) ^ 0.5
		return x / len, y / len
	end

	---@param x any
	---@param y any
	---@param angle radian
	---@return number, number
	local function vec2_rotate(x, y, angle)
		local a = atan2(y, x) + angle
		return cos(a), sin(a)
	end

	---Draws an arrow from A to B
	---@param params RendererParams
	function rendering_extension.draw_arrow(params)
		local from = params.from --[[@as MapPosition]]
		local to = params.to --[[@as MapPosition]]
		local x1, y1, x2, y2 = from.x or from[1], from.y or from[2], to.x or to[1], to.y or to[2]
		local len = vec2_length(x2-x1, y2-y1)
		local nx, ny = vec2_normal(x2-x1, y2-y1)
		local ax_1, ay_1 = vec2_rotate(nx, ny, rad(-90-45))
		local ax_2, ay_2 = vec2_rotate(nx, ny, rad(90+45))
		-- rendering.draw_circle(params, {origin=from, radius=0.2, color = {1, 1, 1}})
		rendering.draw_line(params)
		--rendering.draw_line(params, {from = to, to = {x2 + nx, y2 + ny}, width = 1, color = {0, 0, 0}})
		local arr_w = params.width ^ 0.5 * 0.3
		local back = 0.00390625 * 4 * params.width
		rendering.draw_line(params, {from = {x2 - ax_1 * back, y2 - ay_1 * back},  to = {x2 + ax_1 * arr_w, y2 + ay_1 * arr_w}})--, width = 1, color = {1,0,0}})
		rendering.draw_line(params, {from = to, to = {x2 + ax_2 * arr_w, y2 + ay_2 * arr_w}})--, width = 1, color = {0,0,1}})
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

	local drill = mpp_util.miner_struct(player_data.choices.miner_choice, false)

	renderer.draw_circle{
		x = fx1 + drill.size / 2 + drill.drop_pos.x,
		y = fy1 + drill.size / 2 + drill.drop_pos.y,
		c = {0, 1, 0},
		r = 0.1,
	}

	-- drop pos
	renderer.draw_cross{
		x = fx1 + 0.5 + drill.out_x,
		y = fy1 + 0.5 + drill.out_y,
		r = 0.3,
	}

	for i, pos in pairs(drill.output_rotated) do
		renderer.draw_cross{
			x = fx1 + 0.5 + pos[1],
			y = fy1 + 0.5 + pos[2],
			r = 0.15,
			width = 3,
			c={0, 0, 0, .5},
		}
		renderer.draw_text{
			target={fx1 + .5 + pos[1], fy1 + .5 + pos[2]},
			text = i,
			alignment = "center",
			vertical_alignment="middle",
			scale = 0.6,
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
			width=4, color = {0, .7, 1}, -- cyan - left
			from={fx1-.3, y+drill.pipe_left[0]-.5},
			to={fx1-.3, y+drill.pipe_left[0]+.5},
		}
		renderer.draw_line{
			width=4, color = {.7, .7, 0}, -- yellow - right
			from={fx1+drill.size+.3, y+drill.pipe_right[0]-.5},
			to={fx1+drill.size+.3, y+drill.pipe_right[0]+.5},
		}
		
		if drill.pipe_back then
			for _, back_x in ipairs(drill.pipe_back[0]) do
				renderer.draw_line{
					width=4, color = {.9, .5, 0}, -- yellow - right
					from={x+back_x-.5, fy1+drill.size+.3},
					to={x+back_x+.5, fy1+drill.size+.3},
				}
			end
		end
	end

	renderer.draw_text{
		target={fx1 + drill.extent_negative, fy1 + drill.extent_negative-1.5},
		text = string.format("oversized: %s", drill.oversized),
		alignment = "left",
		vertical_alignment="middle",
	}
	
	renderer.draw_text{
		target={fx1 + drill.extent_negative, fy1 + drill.extent_negative-2.0},
		text = string.format("rotation bump: %s", drill.rotation_bump),
		alignment = "left",
		vertical_alignment="middle",
	}

	renderer.draw_circle{x = fx1, y = fy1, r = 0.1}
	--renderer.draw_circle{ x = fx2, y = fy2, r = 0.15, color={1, 0, 0} }
end

---Preview the pole coverage
---@param player_data PlayerData
---@param event EventData.on_player_reverse_selected_area
function render_util.draw_pole_layout_simple(player_data, event)

	
	rendering.clear("mining-patch-planner")

	local renderer = render_util.renderer(event)

	local fx1, fy1 = event.area.left_top.x, event.area.left_top.y
	fx1, fy1 = floor(fx1), floor(fy1)

	--renderer.draw_cross{x=fx1, y=fy1, w=fx2-fx1, h=fy2-fy1}
	--renderer.draw_cross{x=fx1, y=fy1, w=2}

	local drill = mpp_util.miner_struct(player_data.choices.miner_choice)
	local pole = mpp_util.pole_struct(player_data.choices.pole_choice, player_data.choices.pole_quality_choice)

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
		local coverage = mpp_util.calculate_pole_coverage_simple(player_data.choices, count, 1)

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

function render_util.draw_raw_drill_struct(player_data, event)
	local direction = defines.direction[player_data.direction_choice]
	
	local renderer = render_util.renderer(event)
	
	local struct = mpp_util.miner_struct(player_data.choices.miner_choice, false)
	local proto = prototypes.entity[player_data.choices.miner_choice]
	
	local gx, gy = event.area.left_top.x, event.area.left_top.y
	gx, gy = ceil(gx), ceil(gy)
	
	if struct.size % 2 == 1 then
		gx, gy = gx - .5, gy - .5
	end
	
	renderer.draw_circle{
		x = gx, y = gy,
		r = .1, filled= true,
		color = {0, 0, 0}
	}
	
	local collision = proto.collision_box
	renderer.draw_rectangle{
		x = gx + (collision.left_top.x),
		y = gy + (collision.left_top.y),
		w = (collision.right_bottom.x - collision.left_top.x),
		h = (collision.right_bottom.y - collision.left_top.y),
		color = {.8, .8, .8},
		width = 1,
	}
	
end

---Preview the pole coverage
---@param player_data PlayerData
---@param event EventData.on_player_reverse_selected_area
function render_util.draw_pole_layout_interleaved(player_data, event)
	rendering.clear("mining-patch-planner")

	local renderer = render_util.renderer(event)

	local fx1, fy1 = event.area.left_top.x, event.area.left_top.y
	fx1, fy1 = floor(fx1), floor(fy1)

	--renderer.draw_cross{x=fx1, y=fy1, w=fx2-fx1, h=fy2-fy1}
	--renderer.draw_cross{x=fx1, y=fy1, w=2}

	local drill = mpp_util.miner_struct(player_data.choices.miner_choice)
	local pole = mpp_util.pole_struct(player_data.choices.pole_choice, player_data.choices.pole_quality_choice)

	local function draw_pole(x, y)
		renderer.draw_circle{
			x = x + .5,
			y = y - .5,
			radius = 0.3, width=2,
			color = {0, 1, 1},
		}
		renderer.draw_line{
			x = x +.5 - pole.supply_width / 2+.2,
			y = y - .2,
			h = 0,
			w = pole.supply_width-.4,
			color = {0, 1, 1},
			width = 2,
		}
		renderer.draw_line{
			x = x +.5 - pole.supply_width / 2 + .2,
			y = y - .7,
			h = .5,
			w = 0,
			color = {0, 1, 1},
			width = 2,
		}
		renderer.draw_line{
			x = x +.5 + pole.supply_width / 2 - .2,
			y = y - .7,
			h = .5,
			w = 0,
			color = {0, 1, 1},
			width = 2,
		}
	end
	
	local function draw_lane(x, y, count)
		local output_north = drill.output_rotated[NORTH]
		local output_south = drill.output_rotated[SOUTH]
		for i = 0, count-1 do
			renderer.draw_rectangle{
				x = x + drill.size * i + 0.1 , y = y+.1,
				w = drill.size-.2, h=1-.2,
				color = i % 2 == 0 and {143/255, 86/255, 59/255} or {223/255, 113/255, 38/255},
				width=2,
			}
			renderer.draw_rectangle{
				x = x + drill.size * i + output_north[1]+.2,
				y = y + .2,
				w = .6, h = .6,
				color = i % 2 == 1 and {143/255*.3, 86/255*.3, 59/255*.3, .3} or {223/255*.3, 113/255*.3, 38/255*.3, .5},
				width = 2,
			}
			renderer.draw_rectangle{
				x = x + drill.size * i + output_south[1]+.2,
				y = y + .2,
				w = .6, h = .6,
				color = i % 2 == 1 and {143/255*.3, 86/255*.3, 59/255*.3, .3} or {223/255*.3, 113/255*.3, 38/255*.3, .5},
				width = 2,
			}
		end

		---@diagnostic disable-next-line: param-type-mismatch
		local coverage = mpp_util.calculate_pole_coverage_interleaved(player_data.choices, count, 1)
		
		renderer.draw_circle{
			x=x+.5, y=y-0.5, radius = .25, color={0.7, 0.7, 0.7},
		}
		
		if coverage.capable_span then
			renderer.draw_circle{
				x = x - 3+.5, y = y + .5,
				color = {0, .9, 0},
				radius = 0.3, width = 2,
			}
			
			for x_step = coverage.pole_start, coverage.full_miner_width, coverage.pole_step do
				draw_pole(x+x_step, y)
			end
		else
			renderer.draw_cross{
				x = x - 3+.3,
				y = y + .3,
				w = .6,
				color = {.9, 0, 0},
				radius = 0.3, width = 2,
			}
			
			for pos, _ in pairs(coverage.drill_output_positions) do
				renderer.draw_circle{
					x = x + pos + .5,
					y = y + .5,
					color = {0.9, 0, 0},
					radius = 0.3,
				}
			end
			
			for _, px in ipairs(coverage.pattern) do
				draw_pole(x+px, y)
			end
		end

	end

	for i = 1, 20 do
		draw_lane(fx1, fy1+(i-1)*3, i)
	end
end

---Displays the labels of built things on the grid
---@param player_data PlayerData
---@param event EventData.on_player_reverse_selected_area
function render_util.draw_built_things(player_data, event)
	rendering.clear("mining-patch-planner")

	local renderer = render_util.renderer(event)

	local state = player_data.last_state --[[@as SimpleState?]]
	if not state then return end

	local C = state.coords
	local G = state.grid

	for _, row in pairs(G) do
		for _, tile in pairs(row) do
			---@cast tile GridTile
			local thing = tile.built_thing
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
			if tile.avoid then
				renderer.draw_circle{
					x = C.ix1 + tile.x -.9, y = C.iy1 + tile.y -.9,
					r = 0.10,
					filled = true,
					color = {1, 0.2, 0, 0.1},
				}
			end
			if tile.forbidden then
				renderer.draw_circle{
					x = C.ix1 + tile.x -.7, y = C.iy1 + tile.y -.9,
					r = 0.10,
					filled = true,
					color = {0, 0, 0},
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

	local state = player_data.last_state --[[@as SimpleState?]]
	if not state then return end

	local C = state.coords
	local grid = state.grid

	for _, row in pairs(grid) do
		for _, tile in pairs(row) do
			---@cast tile GridTile
			--local c1, c2 = tile.neighbor_counts[m_size], tile.neighbor_counts[m_area]
			local c1, c2 = tile.neighbors_inner, tile.neighbors_outer
			
			if c1 ~= 0 or c2 ~= 0 then
				rendering.draw_circle{
					surface = state.surface, filled=false, color = {0.3, 0.3, 1},
					width=1, radius = 0.5,
					target={C.gx + tile.x, C.gy + tile.y},
				}
			end
			
			local stagger = (.5 - (tile.x % 2)) * .25
			local col = c1 == 0 and {0.3, 0.3, 0.3} or {0.6, 0.6, 0.6}
			rendering.draw_text{
				surface = state.surface, filled = false, color = col,
				target={C.gx + tile.x, C.gy + tile.y - .2},
				text = string.format("i%i", c1),
				alignment = "center",
				vertical_alignment="middle",
			}
			
			rendering.draw_text{
				surface = state.surface, filled = false, color = col,
				target={C.gx + tile.x, C.gy + tile.y + .3},
				text = string.format("o%i", c2),
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

	local state = player_data.last_state --[[@as SimpleState]]
	if not state then return end

	local C = state.coords
	local grid = state.grid
	
	local attempt = state.best_attempt
	
	-- patch bounds
	renderer.draw_rectangle{
		x = C.ix1,
		y = C.iy1,
		w = C.tw,
		h = C.th,
		filled = false,
		width = 3,
		color = {0, 0, 0},
	}
	renderer.draw_circle{
		x = C.ix1 + C.w / 2,
		y = C.iy1 + C.h / 2,
		r = 0.2,
		c = {0, 0, 0},
		width = 3,
	}
	
	renderer.draw_text{
		x = C.gx,
		y = C.gy - 4,
		text = "Centricity: ".. attempt.heuristics.centricity,
	}
	renderer.draw_text{
		x = C.gx,
		y = C.gy - 3.5,
		text = "Heuristic: " ..(1 + (attempt.heuristics.centricity / state.miner.size * 0.5)),
	}
	
	renderer.draw_circle{
		x = C.ix1 + attempt.bx,
		y = C.iy1 + attempt.by,
		r = 0.5,
		c = {1, 1, 1},
	}
	renderer.draw_text{
		x = C.ix1 + attempt.bx,
		y = C.iy1 + attempt.by,
		alignment = "center", vertical_alignment="middle",
		text = "bx,by",
		c = {1, 1, 1},
		scale = 0.65,
	}
	renderer.draw_circle{ -- yellow
		x = C.ix1 + (attempt.b2x),
		y = C.iy1 + (attempt.b2y),
		c = {1, 1, 0},
		r = 0.5,
		width = 3,
	}
	renderer.draw_text{
		x = C.ix1 + (attempt.b2x),
		y = C.iy1 + (attempt.b2y),
		alignment = "center", vertical_alignment="middle",
		text = "b2x,b2y",
		c = {1, 1, 0},
		scale = 0.65,
	}
	
	renderer.draw_circle{ -- orange
		x = C.ix1 + attempt.bx + (attempt.b2x - attempt.bx) / 2,
		y = C.iy1 + attempt.by + (attempt.b2y - attempt.by) / 2,
		c = {1, 0.5, 0},
		r = 0.35,
		width = 3,
	}
	
	
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
		local capstone_text = ""
		if ent.capstone_x and ent.capstone_y then
			clr = {0, 1, 1}
			capstone_text = "xy"
		elseif ent.capstone_x then
			clr = {0, 1, 0}
			capstone_text = capstone_text .. "x"
		elseif ent.capstone_y then
			clr = {0, 0, 1}
			capstone_text = capstone_text .. "y"
		end
		renderer.draw_text{
			x = x + ent.position.x - 0.9,
			y =  y + ent.position.y,
			text = capstone_text, alignment = "left", vertical_alignment="bottom",
			scale = 0.7,
			color = {1, 1, 1},
		}
		renderer.draw_circle{
			x = fx1 + ent.position.x,
			y = fy1 + ent.position.y,
			r = struct.size / 2,
			color = clr,
		}

		if ent.name == "inserter" then
			local pickup, drop = mpp_util.inserter_hand_locations(ent)
			-- renderer.draw_circle{
			-- 	x = fx1 + ent.position.x,
			-- 	y = fy1 + ent.position.y,
			-- 	r = 0.15,
			-- 	filled = true,
			-- }
			local letter = {[NORTH] = "N", [EAST] = "E", [SOUTH] = "S", [WEST] = "W"}
			renderer.draw_text{
				x = fx1 + ent.position.x, y = fy1 + ent.position.y,
				text = letter[ent.direction or NORTH], alignment = "center", vertical_alignment="middle",
			}
			renderer.draw_arrow{
				from = {fx1 + ent.position.x + pickup.x, fy1 + ent.position.y + pickup.y},
				to = {fx1 + ent.position.x - .1, fy1 + ent.position.y - .1},
				color = {1, 0, 0},
			}
			renderer.draw_text{
				x = fx1 + ent.position.x - .1 + pickup.x,
				y = fy1 + ent.position.y - .1 + pickup.y,
				text = "P", alignment = "center", vertical_alignment="middle",
			}

			renderer.draw_arrow{
				x = fx1 + ent.position.x + .1, y = fy1 + ent.position.y + .1,
				w = drop.x, h = drop.y,
				color = {1, 1, 0},
			}
			renderer.draw_text{
				x = fx1 + ent.position.x + .1 + drop.x, y = fy1 + ent.position.y + .1 + drop.y,
				text = "D", alignment = "center", vertical_alignment="middle",
			}
		end
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

---@param player_data PlayerData
---@param event EventData.on_player_reverse_selected_area
function render_util.draw_inserter_rotation_preview(player_data, event)
	local renderer = render_util.renderer(event)

	local fx1, fy1 = event.area.left_top.x, event.area.left_top.y
	fx1, fy1 = floor(fx1), floor(fy1)
	local bx, by = fx1 + 0.5, fy1 + 0.5

	-- for _angle = 0, 360, 15 do
	-- 	local angle = -_angle + 180
	-- 	local x, y = bx + (_angle % 75) / 3, by + floor(_angle / 75) * 3
	-- 	renderer.draw_arrow{
	-- 		from = {x , y}, to = {x + sin(rad(angle)), y + cos(rad(angle))}
	-- 	}
	-- end

	-- if true then return nil end

	local inserter = mpp_util.inserter_struct("inserter")
	local letter = {[NORTH] = "N", [EAST] = "E", [SOUTH] = "S", [WEST] = "W"}

	local step = 3

	local i = 0
	for dir, _ in pairs(inserter.drop_rotated) do
		local x, y = bx + i * step, by - step
		local x1, y1, x2, y2 = -1, 0, 1, 0
		x1, y1 = mpp_util.rotate(x1, y1, dir)
		x2, y2 = mpp_util.rotate(x2, y2, dir)
		renderer.draw_arrow{from = {x+x1, y+y1}, to = {x+x2, y+y2}, width=5}
		i = i + 1
	end

	local _y = 0
	for action, rotations in pairs({drop = inserter.drop_rotated, pickup = inserter.pickup_rotated}) do
		local _x = 0

		renderer.draw_text{
			x = bx - step, y = by + _y,
			text = action,
			alignment = "center",
			vertical_alignment="middle",
		}
		for dir, rotation in pairs(rotations) do
			local x, y = bx + _x, by + _y

			renderer.draw_circle{x = x, y = y, r = 0.5}

			local rx, ry = rotation.x, rotation.y

			if action == "drop" then
				renderer.draw_arrow{from = {x, y}, to = {x+rx, y+ry}}
			else
				renderer.draw_arrow{to = {x, y}, from = {x+rx, y+ry}}
			end
			renderer.draw_text{
				x = x, y = y,
				text = letter[dir or NORTH],
				alignment = "center", vertical_alignment="middle",
			}

			_x = _x + step
		end

		_y = _y + step
	end

end

---@param player_data PlayerData
---@param event EventData.on_player_reverse_selected_area
function render_util.draw_cliff_collisions(player_data, event)
	local S = event.surface
	local renderer = render_util.renderer(event)

	rendering.clear("mining-patch-planner")
	
	local fx1, fy1 = event.area.left_top.x, event.area.left_top.y
	fx1, fy1 = floor(fx1), floor(fy1)
	local bx, by = fx1 + 0.5, fy1 + 0.5
	
	local ents = event.surface.find_entities{
		left_top = event.area.left_top,
		right_bottom = event.area.right_bottom,
		type = "cliff",
	}
	
	for _, ent in ipairs(ents) do
		if ent.type ~= "cliff" then goto continue end
		local x, y = ent.position.x, ent.position.y
		local fx, fy = floor(x), floor(y)
		rendering.draw_circle{
			surface = S,
			target = ent.position,
			filled = false,
			radius = 0.12,
			width = 1,
			color = {1, 1, 1},
		}
		rendering.draw_circle{
			surface = S,
			target = ent.position,
			filled = true,
			radius = 0.05,
			color = {1, 1, 1},
		}
		rendering.draw_circle{
			surface = S,
			target = {fx+.5, fy+.5},
			filled = true,
			radius = 0.1,
			color = {0, .8, 0},
		}
		
		local shift_y = 0.35
		rendering.draw_text{
			surface = S,
			target = {x, y-3+shift_y*0},
			text = "cliff.prototype"..serpent.line(ent.prototype.collision_box),
			color = {1, 1, 1},
			alignment = "center",
			scale = 0.5,
		}
		rendering.draw_text{
			surface = S,
			target = {x, y-4+shift_y*1},
			text = ent.name,
			color = {1, 1, 1},
			alignment = "center",
			scale = 0.5,
		}
		rendering.draw_text{
			surface = S,
			target = {x, y-3+shift_y*2},
			text = "cliff.cliff_orientation = "..ent.cliff_orientation,
			color = {1, 1, 1},
			alignment = "center",
			scale = 0.5,
		}
		
		local collision_box = cliffs.cliff_data[ent.cliff_orientation]
		
		renderer.draw_circle{
			target = {x + collision_box[1][1], y + collision_box[1][2]},
			color = {0, 1, 1},
			radius = .1,
			filled = true,
		}
		renderer.draw_circle{
			target = {x + collision_box[2][1], y + collision_box[2][2]},
			color = {0, 1, 1},
			radius = .1,
			filled = true,
		}
		
		renderer.draw_text{
			target = {x, y-3+shift_y*3},
			text = "rotation = "..(collision_box[3] or 0),
			color = {1, 1, 1},
			alignment = "center",
			scale = 0.5,
		}
		
		for _, exclusion in ipairs(cliffs.hardcoded_collisions[ent.cliff_orientation]) do
			renderer.draw_circle{
				target = {fx+.5+exclusion[1], fy+.5+exclusion[2]},
				radius = 0.45,
				color = {.8, 0, 0},
			}
		end

		::continue::
	end
	
end

---@param player_data PlayerData
---@param event EventData.on_player_reverse_selected_area
function render_util.draw_consumed_resources(player_data, event)
	rendering.clear("mining-patch-planner")

	local renderer = render_util.renderer(event)

	local state = player_data.last_state --[[@as SimpleState]]

	if not state then return end

	local C = state.coords
	local G = state.grid
	local A = state.best_attempt
	local M = state.miner
	local area, size = M.area, M.size
	
	local consume_cache = {}
	local miners = A.miners
	for _, miner in ipairs(miners) do
		-- grid:consume(miner.x+ext_negative, miner.y+ext_negative, area)
		-- G:consume_separable_horizontal(miner.x+M.extent_negative, miner.y+M.extent_negative, area, consume_cache)
		renderer.draw_rectangle{
			x = C.ix1 + miner.x - 1 + .1,
			y = C.iy1 + miner.y - 1 + .1,
			w = size - .2,
			filled=true,
			color=miner.postponed and {0.4, 0.2, .4} or {0.2, 0.4, .8},
		}
		renderer.draw_text{
			x = C.ix1 + miner.x - .75,
			y = C.iy1 + miner.y - .75,
			color = miner.postponed and {1, 0, 0} or {1, 1, 1},
			scale = 0.75,
			text = miner.postponed and "post" or "main",
			alignment = "left",
			vertical_alignment = "top",
		}
	end
	
	-- for tile, _ in pairs(consume_cache) do
	-- 	G:consume_separable_vertical(tile.x, tile.y, area)
	-- end
	
	for index, postponed in ipairs(A.postponed) do
		renderer.draw_rectangle{
			x = C.ix1 + postponed.x - 1 + .125, y = C.iy1 + postponed.y - 1 + .125,
			w = size - .25,
			width = 7,
			color={0.8, 0.6, .2},
		}
		renderer.draw_text{
			x = C.ix1 + postponed.x + .125,
			y = C.iy1 + postponed.y + .125,
			text = index,
		}
	end

	for _, row in pairs(G) do
		for _, tile in pairs(row) do
			---@cast tile GridTile
			local consumed = tile.consumed
			if tile.amount > 0 then
				-- renderer.draw_circle{
				-- 	x = C.gx + tile.x, y = C.gy + tile.y,
				-- 	w = 1,
				-- 	color = {0, 0.5, 0, 0.1},
				-- 	r = 0.5,
				-- }
				renderer.draw_rectangle{
					x = C.ix1 + tile.x -.9, y = C.iy1 + tile.y -.9,
					w = .8,
					color = consumed and {0, 0.8, 0, 1} or {1, 0, 0},
				}
				-- renderer.draw_text{
				-- 	x = C.gx + tile.x, y = C.gy + tile.y - .3,
				-- 	alignment = "center",
				-- 	vertical_alignment = "top",
				-- 	--vertical_alignment = tile.x % 2 == 1 and "top" or "bottom",
				-- 	text = consumed,
				-- 	scale = 0.6,
				-- }
			end
		end
	end

	-- G:clear_consumed(state.resource_tiles)
	
	renderer.draw_text{
		x = C.gx - 2,
		y = C.gy - 4,
		text = "Index: "..A.index,
	}
	renderer.draw_text{
		x = C.gx - 2,
		y = C.gy - 3,
		text = ""..A.sx..";"..A.sy,
	}
	renderer.draw_text{
		x = C.gx - 2,
		y = C.gy - 2,
		text = "Unconsumed: "..A.heuristics.unconsumed,
	}
end


---@param player_data PlayerData
---@param event EventData.on_player_reverse_selected_area
function render_util.draw_belt_specification(player_data, event)
	rendering.clear("mining-patch-planner")

	local renderer = render_util.renderer(event)

	local state = player_data.last_state --[[@as SimpleState]]

	if not state then return end

	local C = state.coords
	local G = state.grid
	local A = state.best_attempt
	local M = state.miner
	local area, size = M.area, M.size
	
	local belts = state.belts
	
	local coverage = mpp_util.calculate_pole_coverage_interleaved(state, state.miner_max_column, state.miner_lane_count, state.best_attempt.sx)
	
	renderer.draw_text{
		x = C.gx, y = C.gy,
		alignment = "center", vertical_alignment = "middle",
		text = "capable ".. tostring(coverage.capable_span),
	}
	
	for _, belt in pairs(belts) do
		do
			local drill_output_positions = coverage.drill_output_positions
			for x_pos, _ in pairs(drill_output_positions) do
				renderer.draw_circle{x = C.gx + x_pos, y = C.gy + belt.y, r = 0.2, color = {1, 0, 0}}
				renderer.draw_text{
					x = C.gx + belt.x2, y = C.gy + belt.y + .15,
					alignment = "center", vertical_alignment = "middle",
					text = "x2", scale = 0.75,
				}
			end
		end
		
		do -- Draws belt endpoints
			-- Draws x1
			renderer.draw_circle{x = C.gx + belt.x1, y = C.gy + belt.y}
			renderer.draw_text{
				x = C.gx + belt.x1, y = C.gy + belt.y + .15,
				alignment = "center", vertical_alignment = "middle",
				text = "x1", scale = 0.75,
			}
			-- Draws x2
			renderer.draw_circle{x = C.gx + belt.x2, y = C.gy + belt.y}
			renderer.draw_text{
				x = C.gx + belt.x2, y = C.gy + belt.y + .15,
				alignment = "center", vertical_alignment = "middle",
				text = "x2", scale = 0.75,
			}
			-- Draws x start
			renderer.draw_circle{x = C.gx + belt.x_start, y = C.gy + belt.y, r = 0.4}
			renderer.draw_text{
				x = C.gx + belt.x_start, y = C.gy + belt.y - .15,
				alignment = "center", vertical_alignment = "middle",
				text = "start", scale = 0.75,
			}
			-- Draws x entry
			renderer.draw_circle{x = C.gx + belt.x_entry, y = C.gy + belt.y, r = 0.4}
			renderer.draw_text{
				x = C.gx + belt.x_entry, y = C.gy + belt.y + .15,
				alignment = "center", vertical_alignment = "middle",
				text = "entry", scale = 0.75,
			}
			-- Draw x end
			renderer.draw_circle{x = C.gx + belt.x_end, y = C.gy + belt.y, r = 0.4}
			renderer.draw_text{
				x = C.gx + belt.x_end, y = C.gy + belt.y - .15,
				alignment = "center", vertical_alignment = "middle",
				text = "end",  scale = 0.75,
			}
		end
		
		do -- Draws throughput and merge strategies
			local x, y = C.gx + belt.x_start - 5, C.gy + belt.y
			renderer.draw_text{
				x = x - 3, y = y-.25,
				alignment = "center", vertical_alignment = "middle",
				text = ("t1 %.02f"):format(belt.merged_throughput1),
			}
			renderer.draw_text{
				x = x - 3, y = y+.25,
				alignment = "center", vertical_alignment = "middle",
				text = ("t2 %.02f"):format(belt.merged_throughput2),
			}
			if belt.merge_direction then
				renderer.draw_text{
					x = x, y = y-.25,
					alignment = "center", vertical_alignment = "middle",
					text = belt.merge_direction,
				}
			end
			if belt.merge_strategy then
				renderer.draw_text{
					x = x, y = y+.25,
					alignment = "center", vertical_alignment = "middle",
					text = belt.merge_strategy,
				}
			end
		end
	end
end

---Preview the pole coverage
---@param player_data PlayerData
---@param event EventData.on_player_reverse_selected_area
function render_util.draw_pole_joiner(player_data, event)
	local renderer = render_util.renderer(event)

	local fx1, fy1 = floor(event.area.left_top.x), floor(event.area.left_top.y)
	local gx, gy = fx1 + .5, fy1 + .5

	local M = mpp_util.miner_struct(player_data.choices.miner_choice)
	local P = mpp_util.pole_struct(player_data.choices.pole_choice, player_data.choices.pole_quality_choice)
	
	---@param x1 number
	---@param y1 number
	---@param x2 number
	---@param y2 number
	local function pole_joiner(x1, y1, x2, y2)
		local gap = y2 - y1
		renderer.draw_circle{
			x = gx + x1,
			y = gy + y1,
		}
		renderer.draw_circle{
			x = gx + x2,
			y = gy + y2,
		}
		
		local wire = P.wire
		if y2 - y1 <= wire then
			renderer.draw_line{
				from = {gx + x1, gy + y1},
				to = {gx + x2, gy + y2},
			}
			return
		end
		
		local function check_pos(sx, sy, step)
			local x = x1 + sx
			local y = y1+floor((y2-y1)/2) + sy
			renderer.draw_circle{
				x = gx + x,
				y = gy + y,
				r = 0.4,
				filled = true,
			}
			renderer.draw_text{
				x = gx + x,
				y = gy + y,
				text = step,
			}
		end
		
		local step_cap = 9
		local l_step, l_x, l_y, l_d, l_m = 0, 0, 0, 1, 1
		while l_step < step_cap do
			while 2 * l_y * l_d < l_m and l_step < step_cap do
				check_pos(l_x, l_y, l_step)
				l_y, l_step = l_y + l_d, l_step + 1
			end
			while 2 * l_x * l_d < l_m and l_step < step_cap do
				check_pos(l_x, l_y, l_step)
				l_x, l_step = l_x + l_d, l_step + 1
			end
			l_d, l_m = -1 * l_d, l_m + 1
		end
		
	end
	
	pole_joiner(0, 0, 0, 1 + M.size * 2 + 1)
	
end

return render_util

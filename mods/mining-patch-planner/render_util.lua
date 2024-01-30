local mpp_util = require("mpp_util")

local DIR = defines.direction

local render_util = {}

local triangles = {
	west={
		{{target={-.6, 0}}, {target={.6, -0.6}}, {target={.6, 0.6}}},
		{{target={-.4, 0}}, {target={.5, -0.45}}, {target={.5, 0.45}}},
	},
	east={
		{{target={.6, 0}}, {target={-.6, -0.6}}, {target={-.6, 0.6}}},
		{{target={.4, 0}}, {target={-.5, -0.45}}, {target={-.5, 0.45}}},
	},
	north={
		{{target={0, -.6}}, {target={-.6, .6}}, {target={.6, .6}}},
		{{target={0, -.4}}, {target={-.45, .5}}, {target={.45, .5}}},
	},
	south={
		{{target={0, .6}}, {target={-.6, -.6}}, {target={.6, -.6}}},
		{{target={0, .4}}, {target={-.45, -.5}}, {target={.45, -.5}}},
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
function render_util.draw_belt_lane(state, belt)
	local r = state._render_objects
	local c, ttl, player = state.coords, 0, {state.player}
	local x1, y1, x2, y2 = belt.x1, belt.y, math.max(belt.x1+2, belt.x2), belt.y
	local function l2w(x, y) -- local to world
		return mpp_util.revert(c.gx, c.gy, state.direction_choice, x, y, c.tw, c.th)
	end
	local c1, c2, c3 = {.9, .9, .9}, {0, 0, 0}, {.4, .4, .4}
	local w1, w2 = 4, 10
	if not belt.lane1 and not belt.lane2 then c1 = c3 end
	
	r[#r+1] = rendering.draw_line{ -- background main line
		surface=state.surface, players=player, only_in_alt_mode=true,
		width=w2, color=c2, time_to_live=ttl or 1,
		from=l2w(x1, y1), to=l2w(x2+.5, y1),
	}
	r[#r+1] = rendering.draw_line{ -- background vertical cap
		surface=state.surface, players=player, only_in_alt_mode=true,
		width=w2, color=c2, time_to_live=ttl or 1,
		from=l2w(x2+.5, y1-.6), to=l2w(x2+.5, y2+.6),
	}
	r[#r+1] = rendering.draw_polygon{ -- background arrow
		surface=state.surface, players=player, only_in_alt_mode=true,
		width=w2, color=c2, time_to_live=ttl or 1,
		target=l2w(x1, y1),
		vertices=triangles[state.direction_choice][1],
	}
	r[#r+1] = rendering.draw_line{ -- main line
		surface=state.surface, players=player, only_in_alt_mode=true,
		width=w1, color=c1, time_to_live=ttl or 1,
		from=l2w(x1-.2, y1), to=l2w(x2+.5, y1),
	}
	r[#r+1] = rendering.draw_line{ -- vertical cap
		surface=state.surface, players=player, only_in_alt_mode=true,
		width=w1, color=c1, time_to_live=ttl or 1,
		from=l2w(x2+.5, y1-.5), to=l2w(x2+.5, y2+.5),
	}
	r[#r+1] = rendering.draw_polygon{ -- arrow
		surface=state.surface, players=player, only_in_alt_mode=true,
		width=0, color=c1, time_to_live=ttl or 1,
		target=l2w(x1, y1),
		vertices=triangles[state.direction_choice][2],
	}
end

---Draws a belt lane overlay
---@param state State
---@param belt BeltSpecification
function render_util.draw_belt_stats(state, belt, belt_speed, speed1, speed2)
	local r = state._render_objects
	local c, ttl, player = state.coords, 0, {state.player}
	local x1, y1, x2, y2 = belt.x1, belt.y, belt.x2, belt.y
	local function l2w(x, y) -- local to world
		return mpp_util.revert(c.gx, c.gy, state.direction_choice, x, y, c.tw, c.th)
	end
	local c1, c2, c3, c4 = {.9, .9, .9}, {0, 0, 0}, {.9, 0, 0}, {.4, .4, .4}
	
	local ratio1 = speed1 / belt_speed
	local ratio2 = speed2 / belt_speed
	local function get_color(ratio)
		return ratio > 1.01 and c3 or ratio == 0 and c4 or c1
	end

	r[#r+1] = rendering.draw_text{
		surface=state.surface, players=player, only_in_alt_mode=true,
		color=get_color(ratio1), time_to_live=ttl or 1,
		alignment=alignment[state.direction_choice][1], vertical_alignment="middle",
		target=l2w(x1-2, y1-.6), scale=1.6,
		text=string.format("%.2fx", ratio1),
	}
	r[#r+1] = rendering.draw_text{
		surface=state.surface, players=player, only_in_alt_mode=true,
		color=get_color(ratio2), time_to_live=ttl or 1,
		alignment=alignment[state.direction_choice][2], vertical_alignment="middle",
		target=l2w(x1-2, y1+.6), scale=1.6,
		text=string.format("%.2fx", ratio2),
	}

end

---Draws a belt lane overlay
---@param state State
---@param pos_x number
---@param pos_y number
---@param speed1 number
---@param speed2 number
function render_util.draw_belt_total(state, pos_x, pos_y, speed1, speed2)
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

	local lower_bound = math.min(speed1, speed2)
	local upper_bound = math.max(speed1, speed2)

	r[#r+1] = rendering.draw_text{
		surface=state.surface, players=player, only_in_alt_mode=true,
		color=c1, time_to_live=ttl or 1,
		alignment=bound_alignment[state.direction_choice], vertical_alignment="middle",
		target=l2w(pos_x-4, pos_y-.6, false), scale=2,
		text={"mpp.msg_print_info_lane_saturation_belts", string.format("%.2fx", upper_bound), string.format("%.2fx", (lower_bound+upper_bound)/2)},
	}
	r[#r+1] = rendering.draw_text{
		surface=state.surface, players=player, only_in_alt_mode=true,
		color=c1, time_to_live=ttl or 1,
		alignment=bound_alignment[state.direction_choice], vertical_alignment="middle",
		target=l2w(pos_x-4, pos_y+.6, true), scale=2,
		text={"mpp.msg_print_info_lane_saturation_bounds", string.format("%.2fx", lower_bound), string.format("%.2fx", upper_bound)},
	}

end


return render_util

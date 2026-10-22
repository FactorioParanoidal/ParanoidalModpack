-- Charge bars (sprites), the animated hit effect (drawn by LuaRendering, no entity) and the plain
-- hit smoke. Names are prefixed so they cannot collide with Shield-FX (same 1.1 artwork).
local shared = require("kts_shared")

local path = shared.root .. "/graphics/"
local list = {}

for i = 0, shared.bar_short_steps do
	list[#list + 1] = {
		type = "sprite",
		name = shared.bar_short .. i,
		filename = path .. "square-" .. i .. ".png",
		width = 260,
		height = 40,
		scale = 0.25,
		shift = {0, 0.1},
	}
end

-- The playback speed is passed at draw time (control.lua), so the prototype runs at 1 frame/tick.
local function hit(name, file)
	return {
		type = "animation",
		name = name,
		filename = path .. file,
		width = 217,
		height = 217,
		frame_count = shared.hit_frames,
		line_length = shared.hit_frames,
		scale = 0.62,
		shift = {-0.02, 0.93},
		priority = "extra-high",
	}
end
list[#list + 1] = hit(shared.hit_animation, "shield-effect-alternate.png")

list[#list + 1] = {
	type = "trivial-smoke",
	name = shared.hit_smoke,
	duration = 45,
	fade_in_duration = 5,
	fade_away_duration = 35,
	spread_duration = 0,
	start_scale = 1,
	end_scale = 1,
	cyclic = true,
	affected_by_wind = false,
	movement_slow_down_factor = 0.5,
	show_when_smoke_off = true,
	render_layer = "wires-above",
	animation = {
		filename = path .. "shield-effect.png",
		width = 400,
		height = 400,
		frame_count = 1,
		shift = {0, -0.03},
		priority = "high",
		animation_speed = 0.05,
		scale = 0.26,
		flags = {"smoke"},
	},
}

data:extend(list)

local DLL = require("prototypes.globals")

local DLLFUNC = {}

-- sprite definitions for animation layers etc.

function DLLFUNC.get_sprite_def(filename, frame_count, line_length, shadow, repeat_count, animation_speed, width, height, x, y, scale, shift, blend_mode, flags, tint, direction_count, apply_runtime_tint, run_mode) 
	if shadow == true then shadow = "shadow" elseif shadow == false then shadow = nil end
	return {
		draw_as_shadow = (shadow == "shadow"),
		draw_as_light = (shadow == "light"),
		draw_as_glow = (shadow == "glow"),
		filename = string.format("%s/%s.png", DLL.entity_path, filename),
		blend_mode = blend_mode,
		animation_speed = animation_speed,
		repeat_count = repeat_count,
		frame_count = frame_count,
		direction_count = direction_count,
		line_length = line_length,
		height = height,
		width = width,
		x = x,
		y = y,
		scale = scale,
		shift = shift,
		tint = tint,
		apply_runtime_tint = apply_runtime_tint,
		run_mode = run_mode,
		priority = "high",
		flags = flags,
	}
end

function DLLFUNC.offset(shift1, shift2)
	return ({shift1[1]-shift2[1], shift1[2]-shift2[2]})
end

function DLLFUNC.shift_calc(x,y,tw,th,w,h)
	return {((tw/2) - (x + (w/2)))/64, ((th/2) - (y + (h/2)))/64}
end

function DLLFUNC.get_layer(filename, frame_count, line_length, shadow, repeat_count, animation_speed, width, height, x, y, tw, th, shift, blend_mode, flags, tint, direction_count, apply_runtime_tint, run_mode)
	local shift = DLLFUNC.offset(shift, DLLFUNC.shift_calc(x,y,tw,th,width,height))
	local layer = DLLFUNC.get_sprite_def("lr-"..filename, frame_count, line_length, shadow, repeat_count, animation_speed, width/2, height/2, x, y, 1, shift, blend_mode, flags, tint, direction_count, apply_runtime_tint, run_mode)
	layer.hr_version = DLLFUNC.get_sprite_def("hr-"..filename, frame_count, line_length, shadow, repeat_count, animation_speed, width, height, x, y, 0.5, shift, blend_mode, flags, tint, direction_count, apply_runtime_tint, run_mode)
	return layer
end

return DLLFUNC
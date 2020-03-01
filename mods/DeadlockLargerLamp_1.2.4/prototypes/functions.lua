require("prototypes.globals")

-- work with incredibly annoying fuel value string

function read_fuel_value(s)
	local units = {
		["J"]  = 1,
		["kJ"] = 1000,
		["MJ"] = 1000000,
		["GJ"] = 1000000000,
	}
	local number, unit = string.match(s, "(%d*%.?%d+)(%a+)")
	local number = tonumber(number)
	if not units[unit] then
		log("Error: couldn't read fuel unit ["..s.."], doesn't seem to be in J, kJ, MJ, GJ")
		return 0
	end
	return number * units[unit]
end

-- sprite definitions for animation layers etc.

function get_sprite_def(filename, frame_count, line_length, shadow, repeat_count, animation_speed, width, height, x, y, scale, shift, blend_mode, flags, tint, direction_count, apply_runtime_tint, run_mode) 
	return {
		draw_as_shadow = shadow,
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

function offset(shift1, shift2)
	return ({shift1[1]-shift2[1], shift1[2]-shift2[2]})
end

function shift_calc(x,y,tw,th,w,h)
	return {((tw/2) - (x + (w/2)))/64, ((th/2) - (y + (h/2)))/64}
end

function get_layer(filename, frame_count, line_length, shadow, repeat_count, animation_speed, width, height, x, y, tw, th, shift, blend_mode, flags, tint, direction_count, apply_runtime_tint, run_mode)
	local shift = offset(shift, shift_calc(x,y,tw,th,width,height))
	local layer = get_sprite_def("lr-"..filename, frame_count, line_length, shadow, repeat_count, animation_speed, width/2, height/2, x, y, 1, shift, blend_mode, flags, tint, direction_count, apply_runtime_tint, run_mode)
	layer.hr_version = get_sprite_def("hr-"..filename, frame_count, line_length, shadow, repeat_count, animation_speed, width, height, x, y, 0.5, shift, blend_mode, flags, tint, direction_count, apply_runtime_tint, run_mode)
	--log(serpent.block(layer))
	return layer
end

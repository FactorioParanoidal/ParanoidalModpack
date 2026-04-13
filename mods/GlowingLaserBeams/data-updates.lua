local laser_beam_blend_mode = "additive"
local r = 1
local g = 0
local b = 0
local glow_r = 0.5
local glow_g = 0.05
local glow_b = 0.05
local path = ""
local glow_blend_mode = nil
local graphics_location = "__GlowingLaserBeams__/graphics/"
local laserBeam = "laser-beam"


function rgbToDecimal(rgbValue)
	return rgbValue / 255
end


	--if settings.startup["laserfix-color"].value == "'Disco'" then
	--	r = 1
	--	g = 1
	--	b = 1
	--	glow_r = 1
	--	glow_g = 1
	--	glow_b = 1
	--	path = "disco/"
	--else
		r = rgbToDecimal(settings.startup["laserfix-r"].value)
		g = rgbToDecimal(settings.startup["laserfix-g"].value)
		b = rgbToDecimal(settings.startup["laserfix-b"].value)
		glow_r = rgbToDecimal(settings.startup["laserfix-glow-r"].value)
		glow_g = rgbToDecimal(settings.startup["laserfix-glow-g"].value)
		glow_b = rgbToDecimal(settings.startup["laserfix-glow-b"].value)
	--end

--log ('BEFORE: data.raw.beam[laserBeam]: ' .. serpent.block(data.raw.beam[laserBeam]))
	data.raw.beam[laserBeam].graphics_set.beam.head = table.deepcopy(data.raw.beam[laserBeam].graphics_set.beam.head)
	data.raw.beam[laserBeam].graphics_set.beam.head.layers[1].filename = graphics_location .. "beam-body-color.png"
	data.raw.beam[laserBeam].graphics_set.beam.head.layers[1].tint = {r=r,g=g,b=b}
	data.raw.beam[laserBeam].graphics_set.beam.head.layers[2].filename = graphics_location .. "beam-body-light.png"
	
	data.raw.beam[laserBeam].graphics_set.beam.tail = table.deepcopy(data.raw.beam[laserBeam].graphics_set.beam.tail)

	data.raw.beam[laserBeam].graphics_set.beam.tail.layers[1].filename = graphics_location .. "beam-end-color.png"
	data.raw.beam[laserBeam].graphics_set.beam.tail.layers[1].tint = {r=r,g=g,b=b}
	data.raw.beam[laserBeam].graphics_set.beam.tail.layers[2].filename = graphics_location .. "beam-end-light.png"
	
	data.raw.beam[laserBeam].graphics_set.beam.body = table.deepcopy(data.raw.beam[laserBeam].graphics_set.beam.body)

	data.raw.beam[laserBeam].graphics_set.beam.body[1].layers[1].filename = graphics_location .. "beam-body-color.png"
	data.raw.beam[laserBeam].graphics_set.beam.body[1].layers[1].tint = {r=r,g=g,b=b}
	data.raw.beam[laserBeam].graphics_set.beam.body[1].layers[2].filename = graphics_location .. "beam-body-light.png"

	if settings.startup["laserfix-doubletint"].value then
		data.raw.beam[laserBeam].graphics_set.beam.head.layers[2].tint = {r=r,g=g,b=b}
		data.raw.beam[laserBeam].graphics_set.beam.tail.layers[2].tint = {r=r,g=g,b=b}
		data.raw.beam[laserBeam].graphics_set.beam.body[1].layers[2].tint = {r=r,g=g,b=b}
	end

	data.raw.beam[laserBeam].graphics_set.ground.head.tint = {r=glow_r,g=glow_g,b=glow_b}
	data.raw.beam[laserBeam].graphics_set.ground.tail.tint = {r=glow_r,g=glow_g,b=glow_b}
	data.raw.beam[laserBeam].graphics_set.ground.body.tint = {r=glow_r,g=glow_g,b=glow_b}

	data.raw.beam[laserBeam].graphics_set.beam.head.layers[2].filename = graphics_location .. "hr-laser-body-light.png"
	data.raw.beam[laserBeam].graphics_set.beam.body[1].layers[2].filename = graphics_location .. "hr-laser-body-light.png"

--log ('AFTER: data.raw.beam[laserBeam]: ' .. serpent.block(data.raw.beam[laserBeam]))

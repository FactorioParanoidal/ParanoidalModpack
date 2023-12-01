require "config"

local function glowAnimation(anim)
	for _,layer in pairs(anim.layers) do
		if layer.flags and layer.flags[1] == "mask" then
			--layer.blend_mode = "additive"
		end
	end
end
--[[
if Config.glowBiters then
	for name,biter in pairs(data.raw.unit) do
		if string.find(name, "biter") then
			glowAnimation(biter.attack_parameters.animation)
			glowAnimation(biter.run_animation)
		end
	end
end
--]]
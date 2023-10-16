require "config"

require "__DragonIndustries__.strings"

local function parseColor(data)
	local clr = data.run_animation.layers[3].tint
	local ret = clr and (clr.r .. "-" .. clr.g .. "-" .. clr.b) or "1-1-1" --white if no color value
	return ret
end

local function getRefname(basename)
	return "biter-color-reference-" .. basename
end

function getColor(bitername)
	local ref = getRefname(bitername)
	if ref == nil then return nil end
	local item = game.item_prototypes[ref]
	if not item then error("Bitername '" .. bitername  .. "' refs to '" .. ref .. "', which returned null!") end
	local clrstring = item.order
	local vals = splitString(clrstring, "%-")
	return {r = vals[1], g = vals[2], b = vals[3]}
end

local function createItem(data)
	return
	{
		type = "item",
		name = getRefname(data.name),
		icon = "__core__/graphics/empty.png",
		icon_size = 1,
		stack_size = 1,
		order = parseColor(data),
		hidden = true
	}
end

function shouldLightUnit(biter)
	return string.find(biter.name, "biter", 1, true) or string.find(biter.name, "spitter", 1, true)
end

if data and Config.glowBiters then
	for name,biter in pairs(data.raw.unit) do
		if shouldLightUnit(biter) then
			--[[
			local ref = createItem(biter)
			log("Identified biter type '" .. name .. "' to be given color key '" .. ref.name .. "' and '" .. ref.order .. "'")
			data:extend({ref})
			--]]
			biter.light = {type = "basic", intensity = 1.0, size = 1.25+biter.run_animation.layers[3].scale*7.5, color=biter.run_animation.layers[3].tint}
			log("Identified biter type '" .. name .. "' to be given light: " .. biter.light.size .. " x " .. serpent.block(biter.light.color))
		end
	end
end
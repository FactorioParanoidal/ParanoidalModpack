--require "arrays"
require "util"

ALL_COLORS = {}
local COLORS_LOOKUP = {}
local COLORS_PRIMARY = {}
local COLORS_SECONDARY = {}
RENDER_COLORS = {}

local function calculateColor(tile)
	local colors = {}
	for part in string.gmatch(tile.name, "[^%-]+") do		
		local li = COLORS_PRIMARY[part]
		if li and #li > 0 then
			for _,color in pairs(li) do
				table.insert(colors, color)
			end
		end
		
		if #colors == 0 then --only go to secondary if there are no primaries
			li = COLORS_SECONDARY[part]
			if li and #li > 0 then
				for _,color in pairs(li) do
					table.insert(colors, color)
				end
			end	
		end
	end
	COLORS_LOOKUP[tile.name] = colors
end

function getColorsForTile(tile)
	if not tile.valid then return ALL_COLORS end
	if string.find(tile.name, "water") then
		return ALL_COLORS,true --need some way to prevent rainbow water
	end
	
	if not COLORS_LOOKUP[tile.name] then
		calculateColor(tile)
	end
	return util.table.deepcopy(COLORS_LOOKUP[tile.name])
end

local function addColor(color, render, tiles1, tiles2)
	for _,tile in pairs(tiles1) do
		if COLORS_PRIMARY[tile] == nil then COLORS_PRIMARY[tile] = {} end
		table.insert(COLORS_PRIMARY[tile], color)
	end
	
	if tiles2 then
		for _,tile in pairs(tiles2) do
			if COLORS_SECONDARY[tile] == nil then COLORS_SECONDARY[tile] = {} end
			table.insert(COLORS_SECONDARY[tile], color)
		end
	end
	
	table.insert(ALL_COLORS, color)
	RENDER_COLORS[color] = render
end

function getRandomColorForTile(tile, rand)
	local colors,water = getColorsForTile(tile)
	if colors == nil or #colors == 0 then return nil end
	local sel = colors[rand(1, #colors)]
	if water then
		
	end
	return sel, water
end

addColor("red", 0xff0000, {"red", "dustyrose"})
addColor("orange", 0xFF7F00, {"orange", "brown"}, {"desert", "dirt"})
addColor("yellow", 0xffD800, {"yellow", "tan", "beige", "cream", "olive"}, {"desert", "sand"})
addColor("green", 0x00ff00, {"green"}, {"grass"})
addColor("cyan", 0x00ffff, {"ice", "frozen", "turqoise"})
addColor("argon", 0x4CCCFF, {"blue", "turqoise"})
addColor("blue", 0x0045ff, {"blue"})
addColor("purple", 0xA426FF, {"purple", "mauve", "aubergine"})
addColor("magenta", 0xFF00FF, {"purple", "violet"})
addColor("white", 0xffffff, {"snow", "white", "black", "beige", "grey", "gray"})
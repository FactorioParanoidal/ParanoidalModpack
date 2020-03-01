-- changes color of base belts
data.raw["transport-belt"]["transport-belt"].friendly_map_color = {r = 0.98, g = 0.73, b = 0.0} -- 250, 186, 0
data.raw["splitter"]["splitter"].friendly_map_color = {r = 0.78, g = 0.58, b = 0.0} -- 200, 149, 0
data.raw["underground-belt"]["underground-belt"].friendly_map_color = {r = 0.74, g = 0.55, b = 0.0} -- 188, 140, 0

data.raw["transport-belt"]["fast-transport-belt"].friendly_map_color = {r = 0.98, g = 0.27, b = 0.06} -- 250, 69, 15
data.raw["splitter"]["fast-splitter"].friendly_map_color = {r = 0.78, g = 0.22, b = 0.05} -- 200, 55, 12
data.raw["underground-belt"]["fast-underground-belt"].friendly_map_color = {r = 0.74, g = 0.20, b = 0.04} -- 188, 52, 11

data.raw["transport-belt"]["express-transport-belt"].friendly_map_color = {r = 0.15, g = 0.67, b = 0.71} -- 38, 171, 181
data.raw["splitter"]["express-splitter"].friendly_map_color = {r = 0.12, g = 0.54, b = 0.57} -- 30, 137, 145
data.raw["underground-belt"]["express-underground-belt"].friendly_map_color = {r = 0.11, g = 0.50, b = 0.53} -- 29, 128, 136

--changes color of pipes/storage tank
data.raw["pipe"]["pipe"].friendly_map_color = {r = 0.29, g = 0.09, b = 0.56} -- 74, 23, 143
data.raw["pipe-to-ground"]["pipe-to-ground"].friendly_map_color = {r = 0.29, g = 0.09, b = 0.56}
data.raw["storage-tank"]["storage-tank"].friendly_map_color = {r = 0.29, g = 0.09, b = 0.56}

data.raw["heat-pipe"]["heat-pipe"].friendly_map_color = {r = 0.56, g = 0.0, b = 0.0} -- 142, 0, 0
data.raw["reactor"]["nuclear-reactor"].friendly_map_color = {r = 0.16, g = 0.73, b = 0.15} -- 41, 186, 37

--data.raw["mining-drill"]["burner-mining-drill"].map_color = {r = 0.0, g = 0.37, b = 0.08} -- 0, 95, 20
--data.raw["mining-drill"]["electric-mining-drill"].map_color = {r = 0.0, g = 0.37, b = 0.08} -- 74, 23, 143
--Bob's Belts
if data.raw["transport-belt"]["ultimate-transport-belt"] ~= nil then --green
	data.raw["transport-belt"]["ultimate-transport-belt"].friendly_map_color = {r = 0.07, g = 1.0, b = 0.62} -- 18, 255, 158
	data.raw["splitter"]["ultimate-splitter"].friendly_map_color = {r = 0.06, g = 0.80, b = 0.50} -- 14, 205, 126
	data.raw["underground-belt"]["ultimate-underground-belt"].friendly_map_color = {r = 0.05, g = 0.75, b = 0.46} -- 14, 191, 119
end

if data.raw["transport-belt"]["turbo-transport-belt"] ~= nil then --purple
	data.raw["transport-belt"]["turbo-transport-belt"].friendly_map_color = {r = 0.97, g = 0.07, b = 1.0} -- 247, 18, 255
	data.raw["splitter"]["turbo-splitter"].friendly_map_color = {r = 0.77, g = 0.06, b = 0.80} -- 198, 14, 204
	data.raw["underground-belt"]["turbo-underground-belt"].friendly_map_color = {r = 0.73, g = 0.05, b = 0.75} -- 185, 14, 191
end

--5dim belts
if data.raw["underground-belt"]["5d-mk1-transport-belt-to-ground-30"] then
	data.raw["underground-belt"]["5d-mk1-transport-belt-to-ground-30"].friendly_map_color = {r = 0.74, g = 0.55, b = 0.0} -- 188, 140, 0
	data.raw["underground-belt"]["5d-mk2-transport-belt-to-ground-30"].friendly_map_color = {r = 0.74, g = 0.20, b = 0.04} -- 188, 52, 11
	data.raw["underground-belt"]["5d-mk3-transport-belt-to-ground-30"].friendly_map_color = {r = 0.11, g = 0.50, b = 0.53} -- 29, 128, 136
	
	data.raw["underground-belt"]["5d-mk1-transport-belt-to-ground-50"].friendly_map_color = {r = 0.74, g = 0.55, b = 0.0} -- 188, 140, 0
	data.raw["underground-belt"]["5d-mk2-transport-belt-to-ground-50"].friendly_map_color = {r = 0.74, g = 0.20, b = 0.04} -- 188, 52, 11
	data.raw["underground-belt"]["5d-mk3-transport-belt-to-ground-50"].friendly_map_color = {r = 0.11, g = 0.50, b = 0.53} -- 29, 128, 136
end

if data.raw["transport-belt"]["5d-mk4-transport-belt"] ~= nil then
	data.raw["transport-belt"]["5d-mk4-transport-belt"].friendly_map_color = {r = 0.08, g = 0.66, b = 0.14} -- 20, 168, 36
	data.raw["splitter"]["5d-mk4-splitter"].friendly_map_color = {r = 0.06, g = 0.53, b = 0.11} -- 16, 134, 29
	
	data.raw["underground-belt"]["5d-mk4-transport-belt-to-ground"].friendly_map_color = {r = 0.06, g = 0.49, b = 0.11} -- 15, 126, 27
	data.raw["underground-belt"]["5d-mk4-transport-belt-to-ground-30"].friendly_map_color = {r = 0.06, g = 0.49, b = 0.11} -- 15, 126, 27
	data.raw["underground-belt"]["5d-mk4-transport-belt-to-ground-50"].friendly_map_color = {r = 0.06, g = 0.49, b = 0.11} -- 15, 126, 27
end

if data.raw["transport-belt"]["5d-mk5-transport-belt"] ~= nil then
	data.raw["transport-belt"]["5d-mk5-transport-belt"].friendly_map_color = {r = 0.89, g = 0.91, b = 0.96} -- 227, 232, 245
	data.raw["splitter"]["5d-mk5-splitter"].friendly_map_color = {r = 0.71, g = 0.73, b = 0.77} -- 182, 186, 196
	
	data.raw["underground-belt"]["5d-mk5-transport-belt-to-ground"].friendly_map_color = {r = 0.67, g = 0.68, b = 0.72} -- 170, 174, 184
	data.raw["underground-belt"]["5d-mk5-transport-belt-to-ground-30"].friendly_map_color = {r = 0.67, g = 0.68, b = 0.72} -- 170, 174, 184
	data.raw["underground-belt"]["5d-mk5-transport-belt-to-ground-50"].friendly_map_color = {r = 0.67, g = 0.68, b = 0.72} -- 170, 174, 184
end

--[[
--Better Belts mods
if data.raw["transport-belt"][""] ~= nil then
	data.raw["transport-belt"][""].map_color = {r = 0.14, g = 0.94, b = 0.05} --36, 240, 13
	data.raw["transport-belt"][""].map_color
	data.raw["transport-belt"][""].map_color
	data.raw["transport-belt"][""].map_color
	data.raw["transport-belt"][""].map_color
	
end
--]]

--[[ Dropping 'support', will delete in a future update

--DyTech belts
if data.raw["transport-belt"]["super-transport-belt"] ~= nil then
	data.raw["transport-belt"]["super-transport-belt"].friendly_map_color = {r = 0.81, g = 0.21, b = 0.80} -- 207, 54, 204
	data.raw["splitter"]["super-splitter"].friendly_map_color = {r = 0.64, g = 0.17, b = 0.64} -- 166, 43, 163
	data.raw["underground-belt"]["super-transport-belt-to-ground"].friendly_map_color = {r = 0.61, g = 0.16, b = 0.60} -- 155, 41, 153
end

if data.raw["transport-belt"]["extreme-transport-belt"] ~= nil then
	data.raw["transport-belt"]["extreme-transport-belt"].friendly_map_color = {r = 0.24, g = 0.83, b = 0.24} -- 61, 212, 61
	data.raw["splitter"]["extreme-splitter"].friendly_map_color = {r = 0.19, g = 0.67, b = 0.19} -- 49, 170, 49
	data.raw["underground-belt"]["extreme-transport-belt-to-ground"].friendly_map_color = {r = 0.18, g = 0.62, b = 0.18} -- 46, 159, 46
end
--]]

--Electric Poles including those in Bob's mods and 5dim
for _, v in pairs(data.raw["electric-pole"]) do
	v.friendly_map_color = {r = 0.65, g = 0.65, b = 0.65} -- 166, 166, 166
end

--Steam steam including Bob's Steam and 5dim
for _, v in pairs(data.raw["generator"]) do
	v.friendly_map_color = {r = 0.0, g = 0.35, b = 0.15} -- 0, 89, 38
end

--changes color of radars
for _, v in pairs(data.raw["radar"]) do
	v.friendly_map_color = {r = 0.49, g = 0.91, b = 0.75} -- 124, 232, 192
end

--changes color of roboports
for _, v in pairs(data.raw["roboport"]) do
	v.friendly_map_color = {r = 0.39, g = 0.53, b = 0.51} -- 99, 135, 130
end



--[[ possible future changes?
--fluid colors -or use game.fluid_prototypes["lubricant"].base_color.r?
local gas = data.raw.fluid["petroleum-gas"].base_color
local lubri = data.raw.fluid["lubricant"].base_color
local water = data.raw.fluid["water"].base_color
local crude = data.raw.fluid["crude-oil"].base_color
local acid = data.raw.fluid["sulfuric-acid"].base_color
local heavy = data.raw.fluid["heavy-oil"].base_color
local light = data.raw.fluid["light-oil"].base_color


if pipe.fluidbox[1] ~= nil then
	if pipe.fluidbox[1].type == gas then
		
	elseif pipe.fluidbox[1].type == lubri then
		
	elseif pipe.fluidbox[1].type == water then
		
	elseif pipe.fluidbox[1].type == crude then
		
	elseif pipe.fluidbox[1].type == acid then
		
	elseif pipe.fluidbox[1].type == heavy then
		
	elseif pipe.fluidbox[1].type == light then
		
	end
end
	--]]
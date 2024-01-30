local beltColorData = {
  --base
  ["transport-belt"] = {r = 0.98, g = 0.73, b = 0.0}, -- 250, 186, 0
  ["fast-transport-belt"] = {r = 0.98, g = 0.27, b = 0.06}, -- 250, 69, 15
  ["express-transport-belt"] = {r = 0.15, g = 0.67, b = 0.71}, -- 38, 171, 181
  --K2
  ["kr-advanced-transport-belt"] = {r = 0.13, g = 0.92, b = 0.09}, -- 34, 235, 23
  ["kr-superior-transport-belt"] = {r = 0.82, g = 0.004, b = 0.97}, -- 210, 1, 247
  --5Dim
  ["5d-transport-belt-04"] = {r = 1, g = 0.63, b = 0.97}, -- 255, 160, 247
  ["5d-transport-belt-05"] = {r = 0.18, g = 0.75, b = 0.16}, -- 47, 190, 40
  ["5d-transport-belt-06"] = {r = 0.42, g = 0.28, b = 0.18}, -- 107, 71, 478
  ["5d-transport-belt-07"] = {r = 0.45, g = 0.24, b = 0.61}, -- 116, 60, 155
  ["5d-transport-belt-08"] = {r = 0.87, g = 0.87, b = 0.87}, -- 222, 222, 222
  ["5d-transport-belt-09"] = {r = 0.98, g = 0.49, b = 0.06}, -- 250, 126, 16
  ["5d-transport-belt-10"] = {r = 0.44, g = 0.45, b = 1}, -- 111, 114, 255
  --Bob's
  ["basic-transport-belt"] = {r = 0.46, g = 0.47, b = 0.47}, -- 118, 120, 120
  ["turbo-transport-belt"] = {r = 0.97, g = 0.07, b = 1.0}, -- 247, 18, 255
  ["ultimate-transport-belt"] = {r = 0.07, g = 1.0, b = 0.62}, -- 18, 255, 158
  --RandomFactorioThings/PlutoniumEnergy
  ["nuclear-transport-belt"] = {r = 0.0, g = 1, b = 0.0}, -- 0, 255, 0
  ["plutonium-transport-belt"] = {r = 0.0, g = 1, b = 0.91} -- 0, 255, 231
}

local function changeColor(belt, percent)
  return {belt.r * percent, belt.g * percent, belt.b * percent}
end

local loaderColorData = {
  ["loader"] = changeColor(beltColorData["transport-belt"], .90),
  ["fast-loader"] = changeColor(beltColorData["fast-transport-belt"], .90),
  ["express-loader"] = changeColor(beltColorData["express-transport-belt"], .90),
  ["5d-loader-04"] = changeColor(beltColorData["5d-transport-belt-04"], .90),
  ["5d-loader-05"] = changeColor(beltColorData["5d-transport-belt-05"], .90),
  ["5d-loader-06"] = changeColor(beltColorData["5d-transport-belt-06"], .90),
  ["5d-loader-07"] = changeColor(beltColorData["5d-transport-belt-07"], .90),
  ["5d-loader-08"] = changeColor(beltColorData["5d-transport-belt-08"], .90)
}

local splitterColorData = { --80%
  ["splitter"] = changeColor(beltColorData["transport-belt"], .80),
  ["fast-splitter"] = changeColor(beltColorData["fast-transport-belt"], .80),
  ["express-splitter"] = changeColor(beltColorData["express-transport-belt"], .80),
  ["kr-advanced-splitter"] = changeColor(beltColorData["kr-advanced-transport-belt"], .80),
  ["kr-superior-splitter"] = changeColor(beltColorData["kr-superior-transport-belt"], .80),
  ["5d-splitter-04"] = changeColor(beltColorData["5d-transport-belt-04"], .80),
  ["5d-splitter-05"] = changeColor(beltColorData["5d-transport-belt-05"], .80),
  ["5d-splitter-06"] = changeColor(beltColorData["5d-transport-belt-06"], .80),
  ["5d-splitter-07"] = changeColor(beltColorData["5d-transport-belt-07"], .80),
  ["5d-splitter-08"] = changeColor(beltColorData["5d-transport-belt-08"], .80),
  ["5d-splitter-09"] = changeColor(beltColorData["5d-transport-belt-09"], .80),
  ["5d-splitter-10"] = changeColor(beltColorData["5d-transport-belt-10"], .80),
  ["basic-splitter"] = changeColor(beltColorData["basic-transport-belt"], .80),
  ["turbo-splitter"] = changeColor(beltColorData["turbo-transport-belt"], .80),
  ["ultimate-splitter"] = changeColor(beltColorData["ultimate-transport-belt"], .80),
  ["nuclear-splitter"] = changeColor(beltColorData["ultimate-transport-belt"], .80),
  ["plutonium-splitter"] = changeColor(beltColorData["plutonium-transport-belt"], .80),
}

local undergroundColorData = { --75%
  ["underground-belt"] = changeColor(beltColorData["transport-belt"], .70),
  ["fast-underground-belt"] = changeColor(beltColorData["fast-transport-belt"], .70),
  ["express-underground-belt"] = changeColor(beltColorData["express-transport-belt"], .70),
  ["kr-advanced-underground-belt"] = changeColor(beltColorData["kr-advanced-transport-belt"], .70),
  ["kr-superior-underground-belt"] = changeColor(beltColorData["kr-superior-transport-belt"], .70),
  ["5d-underground-belt-30-01"] = changeColor(beltColorData["transport-belt"], .70),
  ["5d-underground-belt-50-01"] = changeColor(beltColorData["transport-belt"], .70),
  ["5d-fast-underground-belt-30-02"] = changeColor(beltColorData["fast-transport-belt"], .70),
  ["5d-fast-underground-belt-50-02"] = changeColor(beltColorData["fast-transport-belt"], .70),
  ["5d-express-underground-belt-30-03"] = changeColor(beltColorData["express-transport-belt"], .70),
  ["5d-express-underground-belt-50-03"] = changeColor(beltColorData["express-transport-belt"], .70),
  ["5d-underground-belt-04"] = changeColor(beltColorData["5d-transport-belt-04"], .70),
  ["5d-underground-belt-30-04"] = changeColor(beltColorData["5d-transport-belt-04"], .70),
  ["5d-underground-belt-50-04"] = changeColor(beltColorData["5d-transport-belt-04"], .70),
  ["5d-underground-belt-05"] = changeColor(beltColorData["5d-transport-belt-05"], .70),
  ["5d-underground-belt-30-05"] = changeColor(beltColorData["5d-transport-belt-05"], .70),
  ["5d-underground-belt-50-05"] = changeColor(beltColorData["5d-transport-belt-05"], .70),
  ["5d-underground-belt-06"] = changeColor(beltColorData["5d-transport-belt-06"], .70),
  ["5d-underground-belt-30-06"] = changeColor(beltColorData["5d-transport-belt-06"], .70),
  ["5d-underground-belt-50-06"] = changeColor(beltColorData["5d-transport-belt-06"], .70),
  ["5d-underground-belt-07"] = changeColor(beltColorData["5d-transport-belt-07"], .70),
  ["5d-underground-belt-30-07"] = changeColor(beltColorData["5d-transport-belt-07"], .70),
  ["5d-underground-belt-50-07"] = changeColor(beltColorData["5d-transport-belt-07"], .70),
  ["5d-underground-belt-08"] = changeColor(beltColorData["5d-transport-belt-08"], .70),
  ["5d-underground-belt-30-08"] = changeColor(beltColorData["5d-transport-belt-08"], .70),
  ["5d-underground-belt-50-08"] = changeColor(beltColorData["5d-transport-belt-08"], .70),
  ["5d-underground-belt-09"] = changeColor(beltColorData["5d-transport-belt-09"], .70),
  ["5d-underground-belt-30-09"] = changeColor(beltColorData["5d-transport-belt-09"], .70),
  ["5d-underground-belt-50-09"] = changeColor(beltColorData["5d-transport-belt-09"], .70),
  ["5d-underground-belt-10"] = changeColor(beltColorData["5d-transport-belt-10"], .70),
  ["5d-underground-belt-30-10"] = changeColor(beltColorData["5d-transport-belt-10"], .70),
  ["5d-underground-belt-50-10"] = changeColor(beltColorData["5d-transport-belt-10"], .70),
  ["basic-underground-belt"] = changeColor(beltColorData["basic-transport-belt"], .70),
  ["turbo-underground-belt"] = changeColor(beltColorData["turbo-transport-belt"], .70),
  ["ultimate-underground-belt"] = changeColor(beltColorData["ultimate-transport-belt"], .70),
  ["nuclear-underground-belt"] = changeColor(beltColorData["ultimate-transport-belt"], .70),
  ["plutonium-underground-belt"] = changeColor(beltColorData["plutonium-transport-belt"], .70)
}

for k,v in pairs(data.raw["transport-belt"]) do
  if beltColorData[k] then
    data.raw["transport-belt"][k].friendly_map_color = beltColorData[k]
  end
end
for k,v in pairs(data.raw["splitter"]) do
  if splitterColorData[k] then
    data.raw["splitter"][k].friendly_map_color = splitterColorData[k]
  end
end
for k,v in pairs(data.raw["underground-belt"]) do
  if undergroundColorData[k] then
    data.raw["underground-belt"][k].friendly_map_color = undergroundColorData[k]
  end
end
for k,v in pairs(data.raw.loader) do
  if loaderColorData[k] then
    data.raw.loader[k].friendly_map_color = loaderColorData[k]
  end
end

if settings.startup["Use-Mod-Color-for-pipes"].value then
	for _, v in pairs(data.raw["pipe"]) do
		v.friendly_map_color = {r = 0.35, g = 0.15, b = 0.62} -- 89, 38, 158
	end
  for _, v in pairs(data.raw["storage-tank"]) do
		v.friendly_map_color = {r = 0.22, g = 0.07, b = 0.45} -- 56, 18, 115
	end
	for _, v in pairs(data.raw["pump"]) do
		v.friendly_map_color = {r = 0.20, g = 0.05, b = 0.40} -- 51, 13, 102
	end
	for _, v in pairs(data.raw["pipe-to-ground"]) do
		v.friendly_map_color = {r = 0.35, g = 0.15, b = 0.62} -- 89, 38, 158
	end
end

if settings.startup["Use-Mod-Color-for-heat-pipes"].value then
	for _, v in pairs(data.raw["heat-pipe"]) do
		v.friendly_map_color = {r = 0.56, g = 0.0, b = 0.0} -- 142, 0, 0
	end
end

for _, v in pairs(data.raw["reactor"]) do
	v.friendly_map_color = {r = 0.16, g = 0.73, b = 0.15} -- 41, 186, 37
end

--data.raw["mining-drill"]["burner-mining-drill"].map_color = {r = 0.0, g = 0.37, b = 0.08} -- 0, 95, 20
--data.raw["mining-drill"]["electric-mining-drill"].map_color = {r = 0.0, g = 0.37, b = 0.08} -- 74, 23, 143

--Electric Poles including those in Bob's mods and 5dim
for _, v in pairs(data.raw["electric-pole"]) do
	v.friendly_map_color = {r = 0.65, g = 0.65, b = 0.65} -- 166, 166, 166
end

--Steam including Bob's Steam and 5dim
for k, v in pairs(data.raw["generator"]) do
	if v.name:find("steam%-engine") or v.name:find("steam%-turbine") then
		if settings.startup["Use-Mod-Color-for-steam-generators"].value then
			v.friendly_map_color = {r = 0.0, g = 0.35, b = 0.15} -- 0, 89, 38
		else
			return
		end
	else
		v.friendly_map_color = {r = 0.0, g = 0.35, b = 0.15} -- 0, 89, 38
	end
end

--changes color of radars
for _, v in pairs(data.raw["radar"]) do
	v.friendly_map_color = {r = 0.49, g = 0.91, b = 0.75} -- 124, 232, 192
end

--changes color of roboports
if settings.startup["Use-Mod-Color-for-roboports"].value then
	for _, v in pairs(data.raw["roboport"]) do
		v.friendly_map_color = {r = 0.39, g = 0.53, b = 0.51} -- 99, 135, 130
	end
end




data.raw["unit-spawner"]["biter-spawner"].enemy_map_color = {r = 1.0, g = 0.10, b = 0.10} -- 255, 25, 25
--biters

data.raw["unit-spawner"]["spitter-spawner"].enemy_map_color = {r = 0.76, g = 0.10, b = 0.16} -- 195, 25, 40
--spitters

for k,v in pairs(data.raw["unit"]) do
	if k:find("biter") then
			v.enemy_map_color = {r = 1.0, g = 0.33, b = 0.22} -- 255, 85, 55
	elseif k:find("spitter") then
			v.enemy_map_color = {r = 0.76, g = 0.22, b = 0.16} -- 195, 55, 40
	end
end

for _,v in pairs(data.raw["turret"]) do
	v.enemy_map_color = {r = 0.53, g = 0.10, b = 0.16} -- 135, 25, 40
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
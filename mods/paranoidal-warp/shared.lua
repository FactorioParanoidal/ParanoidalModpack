-- Sectors of the warp (data and control stage). Each sector: a gate (the jump point) and two points, routes between
-- the three. Home orbit (Nauvis) is a jump point too. User decisions 2026-11-07 (ПР-077, stage 2 plan).
local M = {}

M.prefix = "paranoidal-warp-"
M.drive = "paranoidal-warp-drive"
M.charge = "paranoidal-warp-charge"
M.jump_recipe = "paranoidal-warp-jump"
M.technology = "paranoidal-warp-drive"
M.home = "nauvis"
-- Stage 3: the comfort field, the void shield, demons.
M.field = "paranoidal-warp-comfort-field"
M.field_recipe = "paranoidal-warp-comfort-field-hum"
M.field_technology = "paranoidal-warp-comfort-field"
M.shield = "paranoidal-warp-void-shield"
M.shield_technology = "paranoidal-warp-void-shield"
M.alert_sound = "paranoidal-warp-red-alert"
M.demon_prefix = "paranoidal-warp-demon-"
-- Stage 5: the rift at the first rocket.
M.fragment = "paranoidal-warp-bridge-fragment"
M.rift_sound_open = "paranoidal-warp-rift-open"
M.rift_sound_thunder = "paranoidal-warp-rift-thunder"
M.rift_sound_impact = "paranoidal-warp-rift-impact"

-- The four sins of consumption (user 2026-11-07: all four at once). base: vanilla unit line for sizes 1-3; tint1/2: mask
-- colours; health/speed: multipliers of the size's base values; group: wave size multiplier.
M.sins = {
	{id = "rage", base = "biter", tint1 = {r = 0.85, g = 0.08, b = 0.06, a = 1}, tint2 = {r = 1, g = 0.45, b = 0.1, a = 0.8},
		health = 1, speed = 1.35, group = 1}, -- Sale Rage: fast, furious melee
	{id = "fineprint", base = "spitter", tint1 = {r = 0.15, g = 0.3, b = 0.95, a = 1}, tint2 = {r = 0.7, g = 0.8, b = 1, a = 0.8},
		health = 0.9, speed = 0.8, group = 1}, -- Fine Print: spits from afar
	{id = "garbage", base = "biter", tint1 = {r = 0.35, g = 0.55, b = 0.12, a = 1}, tint2 = {r = 0.5, g = 0.4, b = 0.2, a = 0.8},
		health = 2.2, speed = 0.75, group = 1}, -- Garbage: slow, very tough
	{id = "excess", base = "biter", tint1 = {r = 0.95, g = 0.3, b = 0.75, a = 1}, tint2 = {r = 1, g = 0.8, b = 0.95, a = 0.8},
		health = 0.5, speed = 1.6, group = 2}, -- Eternal Excess: frail, very fast, twice as many
}
-- Sizes: lesser demon, demon, greater demon; vanilla unit size the graphics come from, base health and speed.
M.demon_sizes = {
	{source = "medium", health = 150, speed = 0.24},
	{source = "big", health = 600, speed = 0.24},
	{source = "behemoth", health = 3000, speed = 0.26},
}

-- Stage 4: warp years of a jump home; goods BnL takes for the Comfort™ field subscription (per warp year of the jump;
-- from: total years of the force before the good may be asked for).
M.home_years = {5, 10}
M.bill_goods = {
	{name = "plastic-bar", per_year = 40, from = 0},
	{name = "advanced-circuit", per_year = 20, from = 0},
	{name = "battery", per_year = 5, from = 0},
	{name = "engine-unit", per_year = 8, from = 0},
	{name = "explosives", per_year = 10, from = 0},
	{name = "processing-unit", per_year = 10, from = 150},
	{name = "low-density-structure", per_year = 2, from = 150},
	{name = "electric-engine-unit", per_year = 4, from = 150},
	{name = "flying-robot-frame", per_year = 2, from = 150},
	{name = "rocket-fuel", per_year = 2, from = 150},
}

function M.demon(sin, size)
	return M.demon_prefix .. sin.id .. "-" .. size
end

M.sectors = {
	{
		id = "coverage", -- «Зона покрытия BnL™»: calm, full sun, many chunks, a few small asteroids
		points = {"gate", "buoy", "feedback"},
		orientation = 0.08,
		solar = 300,
		tint = {r = 0.55, g = 0.8, b = 1},
		backdrop = "gleba",
		lut = nil,
		asteroids = {chunk = 0.0125, small = 0.0015, ratios = {3, 2, 1, 0}},
		danger = 0.6, -- how fast demons come while the comfort field is weak
		years = {10, 20}, -- warp years a jump to the gate adds (stage 4)
	},
	{
		id = "necropolis", -- «Некрополь флота BnL»: wrecks of other BnL liners, metal, medium and big asteroids
		points = {"gate", "wrecks", "hangar"},
		orientation = 0.42,
		solar = 150,
		tint = {r = 1, g = 0.65, b = 0.4},
		backdrop = "fulgora",
		lut = "__core__/graphics/color_luts/lut-sunset.png",
		asteroids = {chunk = 0.008, medium = 0.004, big = 0.0015, ratios = {6, 1, 1, 0}},
		danger = 1,
		years = {20, 35},
	},
	{
		id = "cutoff", -- «Зона отключения за неуплату»: no sun (the subscription is not paid), carbon and oxide
		points = {"gate", "collection", "tariff"},
		orientation = 0.75,
		solar = 0,
		tint = {r = 0.6, g = 0.55, b = 0.75},
		backdrop = nil,
		lut = "__core__/graphics/color_luts/night.png",
		asteroids = {chunk = 0.006, small = 0.003, medium = 0.002, ratios = {1, 4, 4, 0}},
		danger = 1.5,
		years = {30, 50},
	},
}

function M.location(sector, point)
	return M.prefix .. sector.id .. "-" .. point
end

function M.gate(sector)
	return M.location(sector, "gate")
end

-- Jump points: home orbit and the gate of every sector.
function M.jump_points()
	local list = {M.home}
	for _, sector in ipairs(M.sectors) do list[#list + 1] = M.gate(sector) end
	return list
end

-- The sector a location belongs to (nil for home and other places).
function M.sector_of(location)
	for _, sector in ipairs(M.sectors) do
		for _, point in ipairs(sector.points) do
			if M.location(sector, point) == location then return sector end
		end
	end
	return nil
end

-- The warp sector a platform is in or flies through (nil at home and in other places).
function M.sector_of_platform(platform)
	local location = platform.space_location
	if location then return M.sector_of(location.name) end
	local connection = platform.space_connection
	if connection and connection.name:sub(1, #M.prefix) == M.prefix then
		return M.sector_of(connection.name:match("^(.-)%-to%-") or "")
	end
	return nil
end

return M

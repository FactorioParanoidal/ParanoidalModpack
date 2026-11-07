-- Sectors of the warp (data and control stage). Each sector: a gate (the jump point) and two points, routes between
-- the three. Home orbit (Nauvis) is a jump point too. User decisions 2026-11-07 (ПР-077, stage 2 plan).
local M = {}

M.prefix = "paranoidal-warp-"
M.drive = "paranoidal-warp-drive"
M.charge = "paranoidal-warp-charge"
M.jump_recipe = "paranoidal-warp-jump"
M.technology = "paranoidal-warp-drive"
M.home = "nauvis"

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

return M

-- Resource configuration per planet. Paranoidal keeps only the configs of mods that can be in
-- the build: vanilla (incl. Space Age planets), Bob's ores, Angel's ores and Yuoki Industries.
local fillVanillaConfig = require("resourceconfigs.vanilla")
local fillEnemies = require("resourceconfigs.vanilla_enemies")
local fillBoboresConfig = require("resourceconfigs.bobores")
local fillAngelsOresConfig = require("resourceconfigs.angelsores")
local fillYuokiConfig = require("resourceconfigs.yuoki_industries")

return function()
	local config = {
		nauvis = {},
		gleba = {resourceChanceMultiplier = 0.25},
		aquilo = {resourceChanceMultiplier = 0.5},
		vulcanus = {resourceChanceMultiplier = 1.5},
	}

	fillVanillaConfig(config)
	fillEnemies(config)

	if prototypes.entity["y-res1"] then
		fillYuokiConfig(config)
	end

	if script.active_mods["bobores"] then
		fillBoboresConfig(config)
	end

	if script.active_mods["angelsrefining"] then
		fillAngelsOresConfig(config)

		if not script.active_mods["Atlas_NormalOresForAngels"] then
			-- Angel's replaces the vanilla ores
			local nauvis = config.nauvis
			nauvis["copper-ore"] = nil
			nauvis["iron-ore"] = nil
			nauvis["stone"] = nil
		end
	end

	return config
end

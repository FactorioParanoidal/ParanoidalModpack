-- Resource configuration per planet. Paranoidal keeps only the configs of mods that can be in
-- the build: vanilla (incl. Space Age planets), Bob's ores, Angel's ores and Yuoki Industries.
-- Used by both stages: env.has(name) tells whether a resource prototype with autoplace exists,
-- env.mods is the table of active mods, env.setting(name) the value of a startup setting.
local fillVanillaConfig = require("resourceconfigs.vanilla")
local fillEnemies = require("resourceconfigs.vanilla_enemies")
local fillBoboresConfig = require("resourceconfigs.bobores")
local fillAngelsOresConfig = require("resourceconfigs.angelsores")
local fillYuokiConfig = require("resourceconfigs.yuoki_industries")

return function(env)
	local config = {
		nauvis = {},
		gleba = {resourceChanceMultiplier = 0.25},
		aquilo = {resourceChanceMultiplier = 0.5},
		vulcanus = {resourceChanceMultiplier = 1.5},
	}

	fillVanillaConfig(config)
	fillEnemies(config, env)

	if env.has("y-res1") then
		fillYuokiConfig(config)
	end

	if env.mods["bobores"] then
		fillBoboresConfig(config, env)
	end

	if env.mods["angelsrefining"] then
		fillAngelsOresConfig(config, env)

		if not env.mods["Atlas_NormalOresForAngels"] then
			-- Angel's replaces the vanilla ores
			local nauvis = config.nauvis
			nauvis["copper-ore"] = nil
			nauvis["iron-ore"] = nil
			nauvis["stone"] = nil
		end
	end

	return config
end

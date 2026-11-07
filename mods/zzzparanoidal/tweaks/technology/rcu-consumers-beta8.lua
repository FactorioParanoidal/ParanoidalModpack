-- Beta 8 normal: доказанные RCU-потребители, без изменения механик/характеристик.
local patch = {
	-- Beta 8: два этих предка. Extended Angels 2.0 добавил отключённый bob-zinc-processing,
	-- заперев биокристаллы и модуль IV. Сам цинк/модули и прочие поля не меняются.
	["angels-bio-refugium-butchery-2"] = {
		prerequisites = { "angels-bio-refugium-butchery-1", "angels-bio-refugium-hatchery" },
	},
	["atomic-bomb"] = {
		prerequisites = { "military-4", "rocketry", "nuclear-fuel-reprocessing", "uranium-processing", "nuclear-power", "rocket-control-unit" },
	},
	["rocket-silo"] = {
		effects = {
			{ type = "unlock-recipe", recipe = "rsc-excavation-site" },
			{ type = "unlock-recipe", recipe = "rocket-part" },
			{ type = "unlock-recipe", recipe = "bob-rocket-engine" },
			{ type = "unlock-recipe", recipe = "cargo-landing-pad" },
			{
				type = "nothing",
				effect_description = { "research-evolution-factor-effect", "1.882" },
				icon = "__zzzparanoidal__/graphics/research-evolution-icon.png",
				icon_size = 64,
				use_icon_overlay_constant = false,
			},
		},
		prerequisites = { "concrete", "rocket-fuel", "utility-science-pack", "speed-module-3", "productivity-module-3", "bob-advanced-processing-unit", "bob-nitinol-processing", "bob-heat-shield", "bob-rtg", "bob-battery-3", "bob-radar-5", "bob-area-drills-3", "rocket-control-unit" },
	},
	spidertron = {
		prerequisites = { "military-4", "rocketry", "radar", "bob-rtg", "bob-tankotron", "rocket-control-unit" },
	},
}
-- Space Age branch: what Space Age adds to these technologies for space platforms stays (none without it).
local function platform_effects(technology)
	local kept = {}
	for _, effect in ipairs(technology.effects or {}) do
		if effect.type == "unlock-space-platforms" or (effect.type == "unlock-recipe"
			and (effect.recipe == "space-platform-starter-pack" or effect.recipe == "space-platform-foundation")) then
			kept[#kept + 1] = effect
		end
	end
	return kept
end
for name, fields in pairs(patch) do
	local prototype = data.raw.technology[name]
	if prototype then
		local kept = platform_effects(prototype)
		for field, value in pairs(fields) do prototype[field] = value end
		if fields.effects then
			for _, effect in ipairs(kept) do table.insert(prototype.effects, effect) end
		end
	end
end

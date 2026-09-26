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
for name, fields in pairs(patch) do
	local prototype = data.raw.technology[name]
	if prototype then for field, value in pairs(fields) do prototype[field] = value end end
end

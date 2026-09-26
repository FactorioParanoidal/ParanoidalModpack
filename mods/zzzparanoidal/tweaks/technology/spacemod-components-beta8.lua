-- Конечные технологии компонентов корабля: итоговые unit/prerequisites Beta 8 normal.
-- Имена науки и оборудования адаптированы к Bob 2.0; эффекты, иконки и описания не меняем.
if not mods["SpaceModFeorasFork"] then return end

local definitions = {
	["space-assembly"] = {
		count = 60000,
		prerequisites = { "space-assembler-theory", "bob-robots-3", "bob-speed-module-5", "bob-efficiency-module-5" },
		science = { "automation-science-pack", "logistic-science-pack", "chemical-science-pack", "production-science-pack", "space-science-pack", "utility-science-pack", "bob-advanced-logistic-science-pack" },
	},
	["space-construction"] = {
		count = 120000,
		prerequisites = { "space-assembly", "bob-robo-modular-4" },
		science = { "automation-science-pack", "logistic-science-pack", "chemical-science-pack", "production-science-pack", "space-science-pack", "utility-science-pack", "bob-advanced-logistic-science-pack" },
	},
	["space-casings"] = {
		count = 120000,
		prerequisites = { "space-construction" },
		science = { "automation-science-pack", "logistic-science-pack", "chemical-science-pack", "production-science-pack", "space-science-pack", "utility-science-pack", "bob-advanced-logistic-science-pack" },
	},
	["protection-fields"] = {
		count = 120000,
		prerequisites = { "space-construction", "bob-energy-shield-equipment-6" },
		science = { "automation-science-pack", "logistic-science-pack", "chemical-science-pack", "military-science-pack", "utility-science-pack", "space-science-pack", "bob-advanced-logistic-science-pack" },
	},
	["fusion-reactor"] = {
		count = 120000,
		prerequisites = { "space-construction", "orbital-assembler-power-problem", "bob-fission-reactor-equipment-4" },
		science = { "automation-science-pack", "logistic-science-pack", "chemical-science-pack", "military-science-pack", "production-science-pack", "utility-science-pack", "space-science-pack", "bob-advanced-logistic-science-pack" },
	},
	["space-thrusters"] = {
		count = 60000,
		prerequisites = { "space-construction" },
		science = { "automation-science-pack", "logistic-science-pack", "chemical-science-pack", "production-science-pack", "space-science-pack", "utility-science-pack", "bob-advanced-logistic-science-pack" },
	},
	["fuel-cells"] = {
		count = 60000,
		prerequisites = { "space-construction" },
		science = { "automation-science-pack", "logistic-science-pack", "chemical-science-pack", "utility-science-pack", "space-science-pack", "bob-advanced-logistic-science-pack" },
	},
	["habitation"] = {
		count = 120000,
		prerequisites = { "space-construction" },
		science = { "automation-science-pack", "logistic-science-pack", "chemical-science-pack", "production-science-pack", "utility-science-pack", "space-science-pack", "bob-advanced-logistic-science-pack" },
	},
	["life-support-systems"] = {
		count = 120000,
		prerequisites = { "space-construction" },
		science = { "automation-science-pack", "logistic-science-pack", "chemical-science-pack", "production-science-pack", "utility-science-pack", "space-science-pack", "bob-advanced-logistic-science-pack" },
	},
	["spaceship-command"] = {
		count = 240000,
		prerequisites = { "space-construction", "bob-god-module" },
		science = { "automation-science-pack", "logistic-science-pack", "chemical-science-pack", "production-science-pack", "utility-science-pack", "space-science-pack", "bob-advanced-logistic-science-pack", "military-science-pack" },
	},
	["astrometrics"] = {
		count = 140000,
		prerequisites = { "space-construction", "advanced-osmium-smelting" },
		science = { "automation-science-pack", "logistic-science-pack", "chemical-science-pack", "production-science-pack", "utility-science-pack", "space-science-pack", "bob-advanced-logistic-science-pack" },
	},
}
for name, definition in pairs(definitions) do
	local technology = data.raw.technology[name]
	if technology and technology.unit and technology.max_level ~= "infinite" then
		local ingredients = {}
		for _, pack in ipairs(definition.science) do
			ingredients[#ingredients + 1] = { pack, 1 }
		end
		technology.unit = { count = definition.count, time = 60, ingredients = ingredients }
		technology.prerequisites = definition.prerequisites
	end
end

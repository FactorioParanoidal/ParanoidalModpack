require("__SpaceModFeorasFork__/prototypes/technology")
require("__SpaceModFeorasFork__/prototypes/style")
require("__SpaceModFeorasFork__/prototypes/item")
require("__SpaceModFeorasFork__/prototypes/recipe")
require("__SpaceModFeorasFork__/prototypes/entities")

if settings.startup["SpaceX-no-ir"].value == false then
	if mods["IndustrialRevolution"] or mods["IndustrialRevolution3"] then
		for _, tech in pairs({ "space-ai-robots", "space-fluid-tanks", "exploration-satellite" }) do
			data.raw.technology[tech].unit.ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "production-science-pack", 1 },
				{ "utility-science-pack", 1 },
			}
		end

		if settings.startup["SpaceX-classic-mode"].value == true or settings.startup["SpaceX-ftl-ramp-up"].value == true then
			data.raw.technology["ftl-theory-A"].unit.ingredients = {
				{ "automation-science-pack", 1 },
			}
			data.raw.technology["ftl-theory-B"].unit.ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
			}
			data.raw.technology["ftl-theory-C"].unit.ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
			}
			data.raw.technology["ftl-theory-D1"].unit.ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "production-science-pack", 1 },
			}
			data.raw.technology["ftl-theory-D2"].unit.ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "utility-science-pack", 1 },
			}
			data.raw.technology["ftl-propulsion"].unit.ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "production-science-pack", 1 },
				{ "utility-science-pack", 1 },
				{ "space-science-pack", 1 },
			}
		end
	end

	if mods["IndustrialRevolution3"] then
		require("__SpaceModFeorasFork__/prototypes/recipe-ir3")
		require("__SpaceModFeorasFork__/prototypes/technology-ir3")
	end
end
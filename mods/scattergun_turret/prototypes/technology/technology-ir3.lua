function W93_UpdateTechIR3()
	data.raw["technology"]["w93-scattergun-turrets"].unit.count = 150
	data.raw["technology"]["w93-scattergun-turrets"].unit.time = 60
	data.raw["technology"]["w93-modular-turrets"].prerequisites = { "gun-turret", "ir-steel-milestone" }
	data.raw["technology"]["w93-modular-turrets"].unit.count = 300
	data.raw["technology"]["w93-modular-turrets"].unit.time = 60
	data.raw["technology"]["w93-modular-turrets"].unit.ingredients = { {"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1} }
	data.raw["technology"]["w93-modular-turrets2"].prerequisites = { "w93-modular-turrets", "low-density-structure" }
	data.raw["technology"]["w93-modular-turrets2"].unit.count = 700
	data.raw["technology"]["w93-modular-turrets2"].unit.ingredients = { {"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1} }
	data.raw["technology"]["w93-modular-turrets-gatling"].prerequisites = { "w93-modular-turrets", "military-3" }
	data.raw["technology"]["w93-modular-turrets-gatling"].unit.count = 800
	data.raw["technology"]["w93-modular-turrets-gatling"].unit.ingredients = { {"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1},{"production-science-pack", 1} }
	data.raw["technology"]["w93-modular-turrets-lcannon"].prerequisites = { "w93-modular-turrets", "military-2", "ir-electronics-2" }
	data.raw["technology"]["w93-modular-turrets-lcannon"].unit.count = 600
	data.raw["technology"]["w93-modular-turrets-lcannon"].unit.time = 60
	data.raw["technology"]["w93-modular-turrets-lcannon"].unit.ingredients = { {"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1} }
	data.raw["technology"]["w93-modular-turrets-dcannon"].prerequisites = { "w93-modular-turrets-lcannon", "military-3", "ir-modules-2" }
	data.raw["technology"]["w93-modular-turrets-dcannon"].unit.count = 800
	data.raw["technology"]["w93-modular-turrets-hcannon"].prerequisites = { "w93-modular-turrets-dcannon", "military-4" }
	data.raw["technology"]["w93-modular-turrets-hcannon"].unit.count = 1400
	data.raw["technology"]["w93-modular-turrets-rocket"].prerequisites = { "w93-modular-turrets", "military-3", "rocketry" }
	data.raw["technology"]["w93-modular-turrets-rocket"].unit.count = 800
	data.raw["technology"]["w93-modular-turrets-rocket"].unit.ingredients = { {"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1},{"production-science-pack", 1},{"military-science-pack", 1} }
	data.raw["technology"]["w93-modular-turrets-plaser"].prerequisites = { "w93-modular-turrets", "military-2", "laser", "ir-advanced-batteries" }
	data.raw["technology"]["w93-modular-turrets-plaser"].unit.count = 900
	data.raw["technology"]["w93-modular-turrets-plaser"].unit.ingredients = { {"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1} }
	data.raw["technology"]["w93-modular-turrets-tlaser"].prerequisites = { "w93-modular-turrets-plaser", "military-3", "ir-graphene", "ir-electrum-milestone" }
	data.raw["technology"]["w93-modular-turrets-tlaser"].unit.count = 1100
	data.raw["technology"]["w93-modular-turrets-tlaser"].unit.ingredients = { {"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1},{"production-science-pack", 1} }
	data.raw["technology"]["w93-modular-turrets-beam"].prerequisites = { "w93-modular-turrets-tlaser", "ir-force-fields", "military-4" }
	data.raw["technology"]["w93-modular-turrets-beam"].unit.count = 1400
	data.raw["technology"]["w93-modular-turrets-beam"].unit.ingredients = { {"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1},{"production-science-pack", 1},{"utility-science-pack", 1} }

	data.raw["technology"]["w93-modular-turrets-radar"].prerequisites = { "w93-modular-turrets2", "ir-radar", "ir-modules-3" }
	data.raw["technology"]["w93-modular-turrets-radar"].unit.count = 1300
	data.raw["technology"]["w93-modular-turrets-radar"].unit.ingredients = { {"automation-science-pack", 1},{"logistic-science-pack", 1},{"chemical-science-pack", 1},{"production-science-pack", 1},{"utility-science-pack", 1} }
end